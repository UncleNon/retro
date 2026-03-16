class_name BattleAI
extends Node


func choose_action(actor, allies: Array, opponents: Array) -> Dictionary:
	var usable_skills = _get_usable_skills(actor)
	match String(actor.tactic):
		"全力で攻めろ":
			return _choose_aggressive_action(actor, opponents, usable_skills)
		"命を守れ":
			return _choose_guardian_action(actor, allies, opponents, usable_skills)
		"力だけで戦え":
			return _choose_physical_action(actor, opponents, usable_skills)
		"援護を頼む":
			return _choose_support_action(actor, allies, opponents, usable_skills)
	return _choose_balanced_action(actor, allies, opponents, usable_skills)


func _choose_aggressive_action(actor, opponents: Array, usable_skills: Array) -> Dictionary:
	var best_skill = _pick_best_skill(
		usable_skills, func(skill) -> bool: return skill.category in ["physical", "magic"]
	)
	if best_skill != null:
		return _build_skill_action(actor, best_skill, "enemy", _pick_low_hp_index(opponents))
	return _build_basic_attack(actor, opponents)


func _choose_guardian_action(
	actor, allies: Array, opponents: Array, usable_skills: Array
) -> Dictionary:
	var injured_index = _pick_most_injured_ally(allies)
	if injured_index != -1:
		var heal_skill = _pick_best_skill(
			usable_skills, func(skill) -> bool: return skill.category == "recover"
		)
		if heal_skill != null:
			return _build_skill_action(actor, heal_skill, "ally", injured_index)
	var support_skill = _pick_best_skill(
		usable_skills, func(skill) -> bool: return skill.category == "setup"
	)
	if support_skill != null:
		return _build_skill_action(actor, support_skill, "ally", _pick_frontline_index(allies))
	return _choose_balanced_action(actor, allies, opponents, usable_skills)


func _choose_physical_action(actor, opponents: Array, usable_skills: Array) -> Dictionary:
	var best_skill = _pick_best_skill(
		usable_skills, func(skill) -> bool: return skill.category == "physical"
	)
	if best_skill != null:
		return _build_skill_action(actor, best_skill, "enemy", _pick_low_hp_index(opponents))
	return _build_basic_attack(actor, opponents)


func _choose_support_action(
	actor, allies: Array, opponents: Array, usable_skills: Array
) -> Dictionary:
	var heal_skill = _pick_best_skill(
		usable_skills, func(skill) -> bool: return skill.category == "recover"
	)
	var injured_index = _pick_most_injured_ally(allies)
	if heal_skill != null and injured_index != -1:
		return _build_skill_action(actor, heal_skill, "ally", injured_index)

	var control_skill = _pick_best_skill(
		usable_skills,
		func(skill) -> bool: return skill.category in ["status", "setup", "utility", "magic"]
	)
	if control_skill != null:
		var target_index = _pick_unmarked_enemy(opponents)
		return _build_skill_action(actor, control_skill, "enemy", target_index)
	return _choose_balanced_action(actor, allies, opponents, usable_skills)


func _choose_balanced_action(
	actor, allies: Array, opponents: Array, usable_skills: Array
) -> Dictionary:
	var injured_index = _pick_most_injured_ally(allies)
	if injured_index != -1:
		var heal_skill = _pick_best_skill(
			usable_skills, func(skill) -> bool: return skill.category == "recover"
		)
		if heal_skill != null:
			return _build_skill_action(actor, heal_skill, "ally", injured_index)

	var mark_skill = _pick_best_skill(
		usable_skills,
		func(skill) -> bool: return skill.skill_id in ["SKL-028", "SKL-030", "SKL-032"]
	)
	if mark_skill != null and _pick_unmarked_enemy(opponents) != -1:
		return _build_skill_action(actor, mark_skill, "enemy", _pick_unmarked_enemy(opponents))

	var setup_skill = _pick_best_skill(
		usable_skills, func(skill) -> bool: return skill.category in ["status", "setup"]
	)
	if setup_skill != null:
		return _build_skill_action(actor, setup_skill, "enemy", _pick_low_hp_index(opponents))

	return _choose_aggressive_action(actor, opponents, usable_skills)


func _get_usable_skills(actor) -> Array:
	var usable: Array = []
	for skill in actor.skills:
		if actor.can_use_skill(skill):
			usable.append(skill)
	return usable


func _pick_best_skill(usable_skills: Array, predicate: Callable):
	var best_skill = null
	var best_score = -1000000
	for skill in usable_skills:
		if not predicate.call(skill):
			continue
		var score = _score_skill(skill)
		if score > best_score:
			best_score = score
			best_skill = skill
	return best_skill


func _score_skill(skill) -> int:
	var score = skill.base_power - skill.mp_cost * 3 + skill.base_rate
	if skill.category == "magic":
		score += 8
	if skill.category == "recover":
		score += 14
	if skill.category == "status":
		score += 12
	if skill.target_scope in ["spread", "ally_all"]:
		score += 10
	if skill.skill_id in ["SKL-019", "SKL-014", "SKL-018", "SKL-021", "SKL-024", "SKL-031"]:
		score += 8
	return score


func _build_skill_action(actor, skill, target_side: String, target_index: int) -> Dictionary:
	return {
		"kind": "skill",
		"actor": actor,
		"skill": skill,
		"target_side": target_side,
		"target_index": target_index,
	}


func _build_basic_attack(actor, opponents: Array) -> Dictionary:
	for skill in actor.skills:
		if skill.category == "physical" and actor.can_use_skill(skill):
			return _build_skill_action(actor, skill, "enemy", _pick_low_hp_index(opponents))
	return {
		"kind": "pass",
		"actor": actor,
		"target_side": "enemy",
		"target_index": _pick_low_hp_index(opponents),
	}


func _pick_most_injured_ally(allies: Array) -> int:
	var best_index = -1
	var lowest_ratio = 1.01
	for fighter in allies:
		if fighter == null or not fighter.is_alive():
			continue
		var ratio = fighter.hp_ratio()
		if ratio < 0.65 and ratio < lowest_ratio:
			lowest_ratio = ratio
			best_index = fighter.slot_index
	return best_index


func _pick_unmarked_enemy(opponents: Array) -> int:
	for fighter in opponents:
		if fighter != null and fighter.is_alive() and not fighter.has_ailment("marked"):
			return fighter.slot_index
	return _pick_low_hp_index(opponents)


func _pick_low_hp_index(fighters: Array) -> int:
	var best_index = -1
	var lowest_hp = 1000000
	for fighter in fighters:
		if fighter == null or not fighter.is_alive():
			continue
		if fighter.current_hp < lowest_hp:
			lowest_hp = fighter.current_hp
			best_index = fighter.slot_index
	return best_index


func _pick_frontline_index(fighters: Array) -> int:
	for fighter in fighters:
		if fighter != null and fighter.is_alive():
			return fighter.slot_index
	return -1
