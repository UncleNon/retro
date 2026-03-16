class_name BattleFighter
extends RefCounted

const ResourceRegistryScript = preload("res://scripts/data/resource_registry.gd")

const BUFF_KEYS := ["atk", "def", "spd", "int", "res"]

var monster_data = null
var fighter_id: String = ""
var instance_id: String = ""
var nickname: String = ""
var monster_name: String = ""
var display_name: String = ""
var level: int = 1
var plus_value: int = 0
var inherited_skill_ids: Array[String] = []
var base_stats: Dictionary = {}
var max_hp: int = 1
var current_hp: int = 1
var max_mp: int = 0
var current_mp: int = 0
var skills: Array = []
var tactic: StringName = &"まかせた"
var is_ally: bool = true
var slot_index: int = 0
var ailments: Dictionary = {}
var buff_stages: Dictionary = {}
var buff_turns: Dictionary = {}
var evasion_bonus: int = 0
var recruit_bonus: int = 0
var escape_bonus: int = 0
var guard_shell_turns: int = 0
var last_bait_item_id: String = ""
var last_bait_bonus: int = 0
var bait_family_match: bool = false


func setup_from_dict(setup: Dictionary, ally: bool, index: int):
	var monster_id := String(setup.get("monster_id", ""))
	var registry = ResourceRegistryScript.new()
	var loaded_monster = registry.get_monster(monster_id)
	if loaded_monster == null:
		return self

	monster_data = loaded_monster
	fighter_id = "%s_%s_%d" % [monster_id, "ally" if ally else "enemy", index]
	instance_id = String(setup.get("instance_id", fighter_id))
	nickname = String(setup.get("nickname", ""))
	monster_name = loaded_monster.name_jp
	display_name = nickname if not nickname.is_empty() else monster_name
	level = maxi(int(setup.get("level", 1)), 1)
	plus_value = clampi(int(setup.get("plus_value", 0)), 0, 24)
	inherited_skill_ids.clear()
	for skill_id_variant in Array(setup.get("inherited_skill_ids", [])):
		var skill_id := String(skill_id_variant)
		if not skill_id.is_empty():
			inherited_skill_ids.append(skill_id)
	tactic = StringName(setup.get("tactic", "まかせた"))
	is_ally = ally
	slot_index = index
	base_stats = _build_scaled_stats()
	max_hp = int(base_stats.get("hp", 1))
	current_hp = clampi(int(setup.get("current_hp", max_hp)), 0, max_hp)
	if current_hp <= 0:
		current_hp = max_hp
	max_mp = int(base_stats.get("mp", 0))
	current_mp = clampi(int(setup.get("current_mp", max_mp)), 0, max_mp)
	for stat_name in BUFF_KEYS:
		buff_stages[stat_name] = 0
	skills = _load_available_skills(registry)
	return self


func is_alive() -> bool:
	return current_hp > 0


func hp_ratio() -> float:
	if max_hp <= 0:
		return 0.0
	return float(current_hp) / float(max_hp)


func get_effective_stat(stat_name: String) -> int:
	var base_value := int(base_stats.get(stat_name, 1))
	var stage := int(buff_stages.get(stat_name, 0))
	var factor := 1.0 + float(stage) * 0.15
	if stat_name == "atk" and has_ailment("soot"):
		factor -= 0.10
	if stat_name == "def" and has_ailment("softened"):
		factor -= 0.15
	if stat_name == "spd" and has_ailment("wet"):
		factor -= 0.15
	if stat_name == "def" and guard_shell_turns > 0:
		factor += 0.12
	factor = maxf(factor, 0.4)
	return maxi(1, int(round(float(base_value) * factor)))


func apply_damage(amount: int) -> int:
	var actual := mini(current_hp, maxi(amount, 1))
	current_hp -= actual
	if current_hp <= 0:
		current_hp = 0
		guard_shell_turns = 0
	return actual


func apply_heal(amount: int) -> int:
	var actual := mini(max_hp - current_hp, maxi(amount, 0))
	current_hp += actual
	return actual


func spend_mp(amount: int) -> int:
	var actual := mini(current_mp, maxi(amount, 0))
	current_mp -= actual
	return actual


func restore_mp(amount: int) -> int:
	var actual := mini(max_mp - current_mp, maxi(amount, 0))
	current_mp += actual
	return actual


func can_use_skill(skill) -> bool:
	if skill == null:
		return false
	if current_mp < skill.mp_cost:
		return false
	if has_ailment("seal") and skill.category in ["magic", "status", "recover", "setup", "utility"]:
		return false
	if has_ailment("hushed") and skill.category in ["status", "utility"]:
		return false
	return true


func has_ailment(ailment_name: String) -> bool:
	return int(ailments.get(ailment_name, 0)) > 0


func set_ailment(ailment_name: String, turns: int) -> void:
	ailments[ailment_name] = maxi(int(ailments.get(ailment_name, 0)), turns)


func clear_ailment(ailment_name: String) -> void:
	ailments.erase(ailment_name)


func add_buff(stat_name: String, turns: int, delta: int) -> void:
	var new_stage := clampi(int(buff_stages.get(stat_name, 0)) + delta, -2, 2)
	buff_stages[stat_name] = new_stage
	buff_turns[stat_name] = maxi(int(buff_turns.get(stat_name, 0)), turns)


func tick_end_of_turn() -> Array[String]:
	var messages: Array[String] = []
	if has_ailment("poison") and is_alive():
		var damage := maxi(1, int(floor(float(max_hp) / 16.0)))
		apply_damage(damage)
		messages.append("%s は どくで %d ダメージ" % [display_name, damage])

	var ailment_names: Array = ailments.keys().duplicate()
	for ailment_name_variant in ailment_names:
		var ailment_name := String(ailment_name_variant)
		var turns := int(ailments.get(ailment_name, 0))
		if turns <= 0:
			continue
		turns -= 1
		if turns <= 0:
			ailments.erase(ailment_name)
			messages.append("%s の %s が とけた" % [display_name, _ailment_label(ailment_name)])
		else:
			ailments[ailment_name] = turns

	var buff_names: Array = buff_turns.keys().duplicate()
	for buff_name_variant in buff_names:
		var buff_name := String(buff_name_variant)
		var turns := int(buff_turns.get(buff_name, 0))
		if turns <= 0:
			continue
		turns -= 1
		if turns <= 0:
			buff_turns.erase(buff_name)
			buff_stages[buff_name] = 0
			messages.append("%s の %s補正が もどった" % [display_name, buff_name.to_upper()])
		else:
			buff_turns[buff_name] = turns

	if guard_shell_turns > 0:
		guard_shell_turns -= 1
	if evasion_bonus > 0:
		evasion_bonus -= 1
	if recruit_bonus > 0:
		recruit_bonus = maxi(recruit_bonus - 4, 0)
	if escape_bonus > 0:
		escape_bonus = maxi(escape_bonus - 10, 0)

	return messages


func can_act(rng: RandomNumberGenerator) -> Dictionary:
	if not is_alive():
		return {"ok": false, "message": ""}
	if has_ailment("sleep"):
		return {"ok": false, "message": "%s は ねむっている" % display_name}
	if has_ailment("paralysis") and rng.randf() < 0.25:
		return {"ok": false, "message": "%s は しびれて うごけない" % display_name}
	if has_ailment("fear") and rng.randf() < 0.25:
		return {"ok": false, "message": "%s は おそれて ちぢこまった" % display_name}
	return {"ok": true, "message": ""}


func get_status_summary() -> String:
	var tags: Array[String] = []
	for ailment_name_variant in ailments.keys():
		var ailment_name := String(ailment_name_variant)
		if has_ailment(ailment_name):
			tags.append(_ailment_label(ailment_name))
	if guard_shell_turns > 0:
		tags.append("壁")
	if evasion_bonus > 0:
		tags.append("回避")
	if tags.is_empty():
		return ""
	return " [%s]" % "/".join(tags)


func _build_scaled_stats() -> Dictionary:
	var stats := {}
	for stat_name in ["hp", "mp", "atk", "def", "spd", "int", "res"]:
		var base_value := int(monster_data.base_stats.get(stat_name, 1))
		var cap_value := int(monster_data.cap_stats.get(stat_name, base_value))
		var cap_level := maxi(monster_data.base_level_cap, 2)
		var ratio := clampf(float(level - 1) / float(cap_level - 1), 0.0, 1.0)
		var scaled_value := lerpf(float(base_value), float(cap_value), ratio)
		var plus_factor := 1.0 + float(plus_value) * 0.02
		stats[stat_name] = maxi(1, int(round(scaled_value * plus_factor)))
	return stats


func _load_available_skills(registry) -> Array:
	var loaded_skills: Array = []
	var loaded_skill_ids := {}
	for learn_entry_variant in monster_data.learnset:
		if not learn_entry_variant is Dictionary:
			continue
		var learn_entry: Dictionary = learn_entry_variant
		var learn_type := String(learn_entry.get("learn_type", ""))
		var learn_value := int(learn_entry.get("learn_value", 0))
		if learn_type != "innate" and level < learn_value:
			continue
		var skill_id := String(learn_entry.get("skill_id", ""))
		var skill = registry.get_skill(skill_id)
		if skill == null:
			continue
		loaded_skills.append(skill)
		loaded_skill_ids[skill_id] = true
		if loaded_skills.size() >= 8:
			break
	for skill_id in inherited_skill_ids:
		if loaded_skills.size() >= 8 or loaded_skill_ids.has(skill_id):
			continue
		var inherited_skill = registry.get_skill(skill_id)
		if inherited_skill == null:
			continue
		loaded_skills.append(inherited_skill)
		loaded_skill_ids[skill_id] = true
	return loaded_skills


func _ailment_label(ailment_name: String) -> String:
	var labels := {
		"poison": "どく",
		"sleep": "ねむり",
		"paralysis": "まひ",
		"fear": "おそれ",
		"seal": "ふういん",
		"hushed": "ちんもく",
		"marked": "しるし",
		"soot": "すす",
		"softened": "くずし",
		"wet": "しめり",
	}
	return String(labels.get(ailment_name, ailment_name))
