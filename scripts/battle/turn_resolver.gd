class_name TurnResolver
extends Node


func resolve_turn(
	party: Array, enemies: Array, actions: Array[Dictionary], rng: RandomNumberGenerator
) -> Dictionary:
	var ordered_actions = actions.duplicate()
	for action in ordered_actions:
		action["initiative"] = _roll_initiative(action.get("actor", null), rng)
	ordered_actions.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("initiative", 0)) > int(b.get("initiative", 0))
	)

	var messages: Array[String] = []
	for action in ordered_actions:
		var actor = action.get("actor", null)
		if actor == null or not actor.is_alive():
			continue
		var act_result: Dictionary = actor.can_act(rng)
		if not bool(act_result.get("ok", false)):
			var blocked_message := String(act_result.get("message", ""))
			if not blocked_message.is_empty():
				messages.append(blocked_message)
			continue

		match String(action.get("kind", "pass")):
			"skill":
				messages.append_array(_resolve_skill(action, party, enemies, rng))
			"item":
				messages.append_array(_resolve_item(action, party, enemies))
			"pass":
				messages.append("%s は みようみまねで みあった" % actor.display_name)

		if _all_defeated(party) or _all_defeated(enemies):
			break

	var end_messages = _tick_end_of_turn(party, enemies)
	messages.append_array(end_messages)
	return {
		"messages": messages,
		"party_alive": not _all_defeated(party),
		"enemies_alive": not _all_defeated(enemies),
	}


func _resolve_skill(
	action: Dictionary, party: Array, enemies: Array, rng: RandomNumberGenerator
) -> Array[String]:
	var actor = action.get("actor", null)
	var skill = action.get("skill", null)
	if actor == null or skill == null:
		return []
	if not actor.can_use_skill(skill):
		return ["%s は %s を つかえない" % [actor.display_name, skill.name_jp]]

	actor.spend_mp(skill.mp_cost)
	var messages: Array[String] = ["%s の %s" % [actor.display_name, skill.name_jp]]
	var targets = _resolve_targets(action, party, enemies, rng)
	if targets.is_empty():
		return messages

	match skill.category:
		"physical":
			messages.append_array(_resolve_physical_skill(actor, skill, targets, rng))
		"magic":
			messages.append_array(_resolve_magic_skill(actor, skill, targets, rng))
		"status":
			messages.append_array(_resolve_status_skill(actor, skill, targets, rng))
		"recover":
			messages.append_array(_resolve_recover_skill(actor, skill, targets))
		"setup":
			messages.append_array(_resolve_setup_skill(actor, skill, targets))
		"utility":
			messages.append_array(_resolve_utility_skill(actor, skill, targets, rng))
		_:
			messages.append("%s は ようすをみた" % actor.display_name)
	return messages


func _resolve_item(action: Dictionary, party: Array, enemies: Array) -> Array[String]:
	var actor = action.get("actor", null)
	var item = action.get("item", null)
	if actor == null or item == null:
		return []
	var targets = _resolve_targets(action, party, enemies, RandomNumberGenerator.new())
	if targets.is_empty():
		return ["%s は %s を つかえなかった" % [actor.display_name, item.name_jp]]

	var messages: Array[String] = ["%s は %s を つかった" % [actor.display_name, item.name_jp]]
	for target in targets:
		match item.effect_key:
			"heal_hp":
				var healed = target.apply_heal(int(item.effect_value))
				messages.append("%s の HP が %d かいふく" % [target.display_name, healed])
			"heal_mp":
				var restored = target.restore_mp(int(item.effect_value))
				messages.append("%s の MP が %d かいふく" % [target.display_name, restored])
			"cure_status":
				var statuses = String(item.effect_value).split("|")
				for status_name in statuses:
					if status_name == "any2":
						for ailment_name_variant in target.ailments.keys().slice(0, 2):
							target.clear_ailment(String(ailment_name_variant))
					else:
						target.clear_ailment(status_name)
				messages.append("%s の からだが らくになった" % target.display_name)
			"buff_atk":
				target.add_buff("atk", int(item.effect_value), 1)
				messages.append("%s の こうげきが あがった" % target.display_name)
			"buff_def":
				target.add_buff("def", int(item.effect_value), 1)
				messages.append("%s の しゅびが あがった" % target.display_name)
			"buff_spd":
				target.add_buff("spd", int(item.effect_value), 1)
				messages.append("%s の すばやさが あがった" % target.display_name)
			"buff_res":
				target.add_buff("res", int(item.effect_value), 1)
				messages.append("%s の せいしんが あがった" % target.display_name)
			"recruit_bonus":
				var recruit_bonus := _calc_bait_bonus(item, target)
				target.recruit_bonus += recruit_bonus
				target.last_bait_item_id = String(item.item_id)
				target.last_bait_bonus = recruit_bonus
				target.bait_family_match = _bait_family_match(item, target)
				messages.append("%s は すこし きをゆるした" % target.display_name)
			_:
				messages.append("%s は いまは こうかが ない" % item.name_jp)
	return messages


func _resolve_physical_skill(
	actor, skill, targets: Array, rng: RandomNumberGenerator
) -> Array[String]:
	var messages: Array[String] = []
	for target in targets:
		var damage = _calc_physical_damage(actor, target, skill, rng)
		var actual = target.apply_damage(damage)
		messages.append("%s に %d ダメージ" % [target.display_name, actual])
		match skill.skill_id:
			"SKL-005":
				target.set_ailment("softened", 3)
				messages.append("%s の たいせいが くずれた" % target.display_name)
			"SKL-008":
				actor.evasion_bonus = maxi(actor.evasion_bonus, 2)
				messages.append("%s は みをかわしやすくなった" % actor.display_name)
			"SKL-009":
				if _roll_status(skill.base_rate, actor, target, rng):
					target.set_ailment("hushed", 2)
					messages.append("%s は くちをつぐんだ" % target.display_name)
			"SKL-031":
				if target.has_ailment("marked"):
					target.clear_ailment("marked")
					var bonus_damage = target.apply_damage(maxi(4, int(skill.base_power / 2)))
					messages.append("%s の しるしを えぐって %d ダメージ" % [target.display_name, bonus_damage])
		if not target.is_alive():
			messages.append("%s を たおした" % target.display_name)
	return messages


func _resolve_magic_skill(
	actor, skill, targets: Array, rng: RandomNumberGenerator
) -> Array[String]:
	var messages: Array[String] = []
	for target in targets:
		var damage = _calc_magic_damage(actor, target, skill, rng)
		var actual = target.apply_damage(damage)
		messages.append("%s に %d ダメージ" % [target.display_name, actual])
		if skill.skill_id == "SKL-019" and _roll_status(skill.base_rate, actor, target, rng):
			target.set_ailment("soot", 2)
			messages.append("%s は すすに まかれた" % target.display_name)
		if not target.is_alive():
			messages.append("%s を たおした" % target.display_name)
	return messages


func _resolve_status_skill(
	actor, skill, targets: Array, rng: RandomNumberGenerator
) -> Array[String]:
	var messages: Array[String] = []
	for target in targets:
		if not _roll_status(skill.base_rate, actor, target, rng):
			messages.append("%s には きかなかった" % target.display_name)
			continue
		match skill.skill_id:
			"SKL-013":
				target.set_ailment("soot", 3)
				messages.append("%s は すすをかぶった" % target.display_name)
			"SKL-014":
				target.set_ailment("poison", 4)
				messages.append("%s は どくに おかされた" % target.display_name)
			"SKL-017":
				target.set_ailment("fear", 3)
				messages.append("%s は おそれた" % target.display_name)
			"SKL-018":
				target.set_ailment("seal", 3)
				messages.append("%s は ふういんされた" % target.display_name)
			_:
				target.set_ailment("marked", 2)
				messages.append("%s に しるしが ついた" % target.display_name)
	return messages


func _resolve_recover_skill(actor, skill, targets: Array) -> Array[String]:
	var messages: Array[String] = []
	for target in targets:
		var power = skill.base_power + maxi(4, int(actor.get_effective_stat("int") / 3))
		var healed = target.apply_heal(power)
		messages.append("%s の HP が %d かいふく" % [target.display_name, healed])
		if skill.skill_id == "SKL-025":
			target.clear_ailment("poison")
			target.clear_ailment("sleep")
			messages.append("%s の けがれが うすれた" % target.display_name)
	return messages


func _resolve_setup_skill(_actor, skill, targets: Array) -> Array[String]:
	var messages: Array[String] = []
	for target in targets:
		match skill.skill_id:
			"SKL-022":
				target.set_ailment("wet", 3)
				messages.append("%s は しめりを まとった" % target.display_name)
			"SKL-023":
				target.guard_shell_turns = maxi(target.guard_shell_turns, 3)
				messages.append("%s の まわりに やわらかいかべ" % target.display_name)
			"SKL-024":
				target.add_buff("def", 3, 1)
				messages.append("%s の しゅびが あがった" % target.display_name)
			"SKL-026":
				target.add_buff("spd", 3, -1)
				messages.append("%s の すばやさが さがった" % target.display_name)
			"SKL-036":
				target.add_buff("int", 3, -1)
				target.add_buff("res", 3, -1)
				messages.append("%s の ちえと せいしんが くずれた" % target.display_name)
			_:
				target.add_buff("atk", 3, 1)
				messages.append("%s は ちからを ためた" % target.display_name)
	return messages


func _resolve_utility_skill(
	actor, skill, targets: Array, rng: RandomNumberGenerator
) -> Array[String]:
	var messages: Array[String] = []
	for target in targets:
		match skill.skill_id:
			"SKL-028", "SKL-030":
				target.set_ailment("marked", 3 if skill.skill_id == "SKL-030" else 2)
				messages.append("%s に しるしを つけた" % target.display_name)
			"SKL-029":
				target.set_ailment("marked", 2)
				target.recruit_bonus += 8
				messages.append("%s の すきを ぬすみみた" % target.display_name)
			"SKL-032":
				target.set_ailment("marked", 2)
				target.recruit_bonus += 10
				messages.append("%s の けいかいが ゆるんだ" % target.display_name)
			"SKL-033":
				actor.escape_bonus = maxi(actor.escape_bonus, 45)
				messages.append("%s は にげる じゅんびを した" % actor.display_name)
			_:
				if _roll_status(skill.base_rate, actor, target, rng):
					target.set_ailment("marked", 2)
					messages.append("%s は みぬかれた" % target.display_name)
	return messages


func _resolve_targets(
	action: Dictionary, party: Array, enemies: Array, rng: RandomNumberGenerator
) -> Array:
	var actor = action.get("actor", null)
	var skill = action.get("skill", null)
	var item = action.get("item", null)
	var scope = ""
	if skill != null:
		scope = skill.target_scope
	elif item != null:
		scope = item.target_scope
	var target_side = String(action.get("target_side", "enemy"))
	var target_index = int(action.get("target_index", -1))
	var allies = party if actor != null and actor.is_ally else enemies
	var opponents = enemies if actor != null and actor.is_ally else party
	var target_pool = opponents if target_side == "enemy" else allies

	if scope in ["spread", "enemy_all"]:
		return _alive_fighters(target_pool)
	if scope == "ally_all":
		return _alive_fighters(allies)
	if scope == "self":
		return [actor]
	if scope == "self_to_single":
		return _resolve_self_to_single_targets(actor, target_pool, target_index)
	if scope == "random3":
		return _resolve_random_targets(target_pool, rng)
	return _resolve_single_target(target_pool, target_index)


func _resolve_self_to_single_targets(actor, target_pool: Array, target_index: int) -> Array:
	var target = _pick_target(target_pool, target_index)
	if target == null:
		return [actor]
	return [target, actor]


func _resolve_random_targets(target_pool: Array, rng: RandomNumberGenerator) -> Array:
	var available = _alive_fighters(target_pool)
	var selected: Array = []
	while not available.is_empty() and selected.size() < 3:
		var chosen_index = rng.randi_range(0, available.size() - 1)
		selected.append(available[chosen_index])
		available.remove_at(chosen_index)
	return selected


func _resolve_single_target(target_pool: Array, target_index: int) -> Array:
	var target = _pick_target(target_pool, target_index)
	if target == null:
		return []
	return [target]


func _tick_end_of_turn(party: Array, enemies: Array) -> Array[String]:
	var messages: Array[String] = []
	for fighter in party + enemies:
		if fighter == null:
			continue
		messages.append_array(fighter.tick_end_of_turn())
	return messages


func _calc_physical_damage(attacker, defender, skill, rng: RandomNumberGenerator) -> int:
	var base_damage = (
		(float(attacker.get_effective_stat("atk")) * 0.5)
		- (float(defender.get_effective_stat("def")) * 0.25)
	)
	var skill_scale = maxf(float(skill.base_power) / 100.0, 0.65)
	var variance = rng.randf_range(0.85, 1.0)
	var crit = 1.5 if rng.randf() < 0.04 else 1.0
	var guard = 0.75 if defender.guard_shell_turns > 0 else 1.0
	return maxi(1, int(round(base_damage * skill_scale * variance * crit * guard)))


func _calc_magic_damage(attacker, defender, skill, rng: RandomNumberGenerator) -> int:
	var base_damage = (
		float(skill.base_power)
		+ (float(attacker.get_effective_stat("int")) * 0.35)
		- (float(defender.get_effective_stat("res")) * 0.2)
	)
	var variance = rng.randf_range(0.9, 1.1)
	return maxi(1, int(round(base_damage * variance)))


func _roll_status(base_rate: int, attacker, defender, rng: RandomNumberGenerator) -> bool:
	var chance = float(base_rate) / 100.0
	chance += float(attacker.get_effective_stat("int") - defender.get_effective_stat("res")) * 0.005
	chance = clampf(chance, 0.18, 0.92)
	return rng.randf() <= chance


func _roll_initiative(actor, rng: RandomNumberGenerator) -> int:
	if actor == null:
		return -1
	return (
		int(round(float(actor.get_effective_stat("spd")) * rng.randf_range(0.8, 1.05)))
		+ actor.escape_bonus
	)


func _pick_target(pool: Array, requested_index: int):
	for fighter in pool:
		if fighter != null and fighter.slot_index == requested_index and fighter.is_alive():
			return fighter
	for fighter in pool:
		if fighter != null and fighter.is_alive():
			return fighter
	return null


func _alive_fighters(pool: Array) -> Array:
	var fighters: Array = []
	for fighter in pool:
		if fighter != null and fighter.is_alive():
			fighters.append(fighter)
	return fighters


func _all_defeated(pool: Array) -> bool:
	for fighter in pool:
		if fighter != null and fighter.is_alive():
			return false
	return true


func _calc_bait_bonus(item, target) -> int:
	var base_bonus := int(item.effect_value)
	if base_bonus <= 0:
		return 0
	if _bait_is_generic(item):
		return base_bonus
	if _bait_family_match(item, target):
		return base_bonus
	return maxi(int(floor(float(base_bonus) * 0.5)), 4)


func _bait_family_match(item, target) -> bool:
	if target == null or target.monster_data == null:
		return false
	var family := String(target.monster_data.family)
	if family.is_empty():
		return false
	for tag_variant in item.tags:
		var tag := String(tag_variant)
		if tag == family or tag == "universal":
			return true
	return false


func _bait_is_generic(item) -> bool:
	var family_tags := [
		"beast",
		"bird",
		"plant",
		"undead",
		"magic",
		"material",
		"divine",
		"dragon",
	]
	for tag_variant in item.tags:
		if String(tag_variant) in family_tags:
			return false
	return true
