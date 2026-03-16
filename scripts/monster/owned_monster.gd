class_name OwnedMonster
extends RefCounted

const DEFAULT_TACTIC := "まかせた"
const DEFAULT_LOYALTY := 30

var instance_id: String = ""
var monster_id: String = ""
var nickname: String = ""
var level: int = 1
var tactic: String = DEFAULT_TACTIC
var locked: bool = false
var loyalty: int = DEFAULT_LOYALTY
var joined_at_utc: String = ""
var current_hp: int = -1
var current_mp: int = -1
var source: String = "unknown"
var plus_value: int = 0
var inherited_skills: Array[String] = []
var lineage: Array[Dictionary] = []
var generation_depth: int = 0
var parent_instance_ids: Array[String] = []
var birth_rule_id: String = ""


static func from_dict(data: Dictionary):
	var monster = new()
	return monster.setup_from_dict(data)


func setup_from_dict(data: Dictionary):
	instance_id = String(data.get("instance_id", ""))
	monster_id = String(data.get("monster_id", ""))
	nickname = String(data.get("nickname", ""))
	level = maxi(int(data.get("level", 1)), 1)
	tactic = String(data.get("tactic", DEFAULT_TACTIC))
	locked = bool(data.get("locked", false))
	loyalty = clampi(int(data.get("loyalty", DEFAULT_LOYALTY)), 0, 100)
	joined_at_utc = String(data.get("joined_at_utc", ""))
	current_hp = int(data.get("current_hp", -1))
	current_mp = int(data.get("current_mp", -1))
	source = String(data.get("source", "unknown"))
	plus_value = maxi(int(data.get("plus_value", 0)), 0)
	inherited_skills.clear()
	for skill_id_variant in Array(data.get("inherited_skills", [])):
		var skill_id := String(skill_id_variant)
		if not skill_id.is_empty():
			inherited_skills.append(skill_id)
	lineage.clear()
	for lineage_entry_variant in Array(data.get("lineage", [])):
		if lineage_entry_variant is Dictionary:
			lineage.append(Dictionary(lineage_entry_variant).duplicate(true))
	generation_depth = maxi(int(data.get("generation_depth", lineage.size())), 0)
	parent_instance_ids.clear()
	for instance_id_variant in Array(data.get("parent_instance_ids", [])):
		var instance_id_value := String(instance_id_variant)
		if not instance_id_value.is_empty():
			parent_instance_ids.append(instance_id_value)
	birth_rule_id = String(data.get("birth_rule_id", ""))
	return self


func clone():
	return from_dict(to_dict())


func to_dict() -> Dictionary:
	return {
		"instance_id": instance_id,
		"monster_id": monster_id,
		"nickname": nickname,
		"level": level,
		"tactic": tactic,
		"locked": locked,
		"loyalty": loyalty,
		"joined_at_utc": joined_at_utc,
		"current_hp": current_hp,
		"current_mp": current_mp,
		"source": source,
		"plus_value": plus_value,
		"inherited_skills": inherited_skills.duplicate(),
		"lineage": lineage.duplicate(true),
		"generation_depth": generation_depth,
		"parent_instance_ids": parent_instance_ids.duplicate(),
		"birth_rule_id": birth_rule_id,
	}


func to_battle_setup() -> Dictionary:
	var setup := {
		"instance_id": instance_id,
		"monster_id": monster_id,
		"nickname": nickname,
		"level": level,
		"tactic": tactic,
		"plus_value": plus_value,
		"inherited_skill_ids": inherited_skills.duplicate(),
	}
	if current_hp >= 0:
		setup["current_hp"] = current_hp
	if current_mp >= 0:
		setup["current_mp"] = current_mp
	return setup
