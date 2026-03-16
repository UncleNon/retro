class_name BreedingService
extends RefCounted

const OwnedMonsterScript = preload("res://scripts/monster/owned_monster.gd")
const ResourceRegistryScript = preload("res://scripts/data/resource_registry.gd")

const HISTORY_LIMIT := 50
const CANDIDATE_LIMIT := 8
const FAMILY_LABELS := {
	"slime": "スライム",
	"beast": "けもの",
	"bird": "とり",
	"plant": "しょくぶつ",
	"magic": "まじゅつ",
	"material": "きぶつ",
	"undead": "ししゃ",
	"dragon": "りゅう",
	"divine": "せいなる",
}

var _registry := ResourceRegistryScript.new()
var _history: Array[Dictionary] = []
var _known_rule_ids: Dictionary = {}
var _resolved_rule_ids: Dictionary = {}
var _rule_cache: Array = []


func load_from_save(payload: Dictionary) -> void:
	_history.clear()
	for entry_variant in Array(payload.get("history", [])):
		if entry_variant is Dictionary:
			_history.append(Dictionary(entry_variant).duplicate(true))
	_history = _history.slice(maxi(_history.size() - HISTORY_LIMIT, 0), _history.size())
	_known_rule_ids = _array_to_bool_map(Array(payload.get("known_rule_ids", [])))
	_resolved_rule_ids = _array_to_bool_map(Array(payload.get("resolved_rule_ids", [])))


func serialize_state() -> Dictionary:
	return {
		"history": _history.duplicate(true),
		"known_rule_ids": _sorted_bool_map_keys(_known_rule_ids),
		"resolved_rule_ids": _sorted_bool_map_keys(_resolved_rule_ids),
	}


func build_menu_snapshot(collection) -> Dictionary:
	var entries := build_candidates(collection)
	for entry in entries:
		var rule_id := String(entry.get("rule_id", ""))
		if not rule_id.is_empty():
			_known_rule_ids[rule_id] = true
	return {
		"entries": entries,
		"history": _history.slice(maxi(_history.size() - 4, 0), _history.size()),
		"known_count": _known_rule_ids.size(),
		"resolved_count": _resolved_rule_ids.size(),
	}


func build_candidates(collection) -> Array[Dictionary]:
	_ensure_rules_loaded()
	var roster: Array[Dictionary] = collection.build_breeding_candidates()
	var candidates: Array[Dictionary] = []
	for index_a in range(roster.size()):
		var parent_a: Dictionary = roster[index_a]
		for index_b in range(index_a + 1, roster.size()):
			var parent_b: Dictionary = roster[index_b]
			var preview := preview_pair(parent_a, parent_b)
			if not bool(preview.get("accepted", false)):
				continue
			candidates.append(preview)
	if not candidates.is_empty():
		candidates.sort_custom(_sort_candidates)
	if candidates.size() > CANDIDATE_LIMIT:
		return candidates.slice(0, CANDIDATE_LIMIT)
	return candidates


func execute_candidate(collection, candidate: Dictionary) -> Dictionary:
	var preview := preview_pair(
		Dictionary(candidate.get("parent_a", {})), Dictionary(candidate.get("parent_b", {}))
	)
	if not bool(preview.get("accepted", false)):
		return preview

	var breed_result: Dictionary = collection.breed_monsters(
		String(preview.get("parent_a_instance_id", "")),
		String(preview.get("parent_b_instance_id", "")),
		Dictionary(preview.get("child", {}))
	)
	if not bool(breed_result.get("accepted", false)):
		return breed_result

	var rule_id := String(preview.get("rule_id", ""))
	if not rule_id.is_empty():
		_known_rule_ids[rule_id] = true
		_resolved_rule_ids[rule_id] = true

	var child_data: Dictionary = Dictionary(preview.get("child", {}))
	var child_name := String(preview.get("child_name", child_data.get("monster_id", "")))
	var history_entry := {
		"rule_id": rule_id,
		"child_monster_id": String(child_data.get("monster_id", "")),
		"child_name": child_name,
		"plus_value": int(child_data.get("plus_value", 0)),
		"inherit_preview": String(preview.get("inherit_preview", "")),
		"parents":
		[
			String(preview.get("parent_a_name", "")),
			String(preview.get("parent_b_name", "")),
		],
		"timestamp": Time.get_datetime_string_from_system(true, true),
	}
	_history.append(history_entry)
	if _history.size() > HISTORY_LIMIT:
		_history = _history.slice(_history.size() - HISTORY_LIMIT, _history.size())

	var result: Dictionary = breed_result.duplicate(true)
	result["rule_id"] = rule_id
	result["child"] = child_data
	result["history_entry"] = history_entry
	result["message"] = (
		"%s と %s を はいごうし、%s が うまれた"
		% [
			String(preview.get("parent_a_name", "")),
			String(preview.get("parent_b_name", "")),
			child_name,
		]
	)
	if not String(preview.get("inherit_preview", "")).is_empty():
		result["message"] += "。%s" % String(preview.get("inherit_preview", ""))
	return result


func preview_pair(parent_a: Dictionary, parent_b: Dictionary) -> Dictionary:
	var parent_a_id := String(parent_a.get("monster_id", ""))
	var parent_b_id := String(parent_b.get("monster_id", ""))
	var parent_a_data = _registry.get_monster(parent_a_id)
	var parent_b_data = _registry.get_monster(parent_b_id)
	if parent_a_data == null or parent_b_data == null:
		return {"accepted": false, "reason": "missing_parent_data"}
	if bool(parent_a.get("locked", false)) or bool(parent_b.get("locked", false)):
		return {"accepted": false, "reason": "parent_locked"}

	var rule = _resolve_rule(parent_a_data, parent_b_data, parent_a, parent_b)
	if rule == null:
		return {"accepted": false, "reason": "no_rule"}

	var child_data = _registry.get_monster(String(rule.child_monster_id))
	if child_data == null:
		return {"accepted": false, "reason": "missing_child_data"}

	var level_sum := int(parent_a.get("level", 1)) + int(parent_b.get("level", 1))
	var inherit_slots := 3 if level_sum >= 80 else 2
	var inherited_skill_ids := _build_inherited_skill_ids(parent_a, parent_b, inherit_slots)
	var child_plus := _calc_child_plus(parent_a, parent_b, int(rule.special_recipe_bonus))
	var child_level := maxi(1, int(floor(float(level_sum) / 2.0)) - 2)
	var child = (
		OwnedMonsterScript
		. from_dict(
			{
				"instance_id": "%s-%d" % [String(child_data.monster_id), Time.get_ticks_usec()],
				"monster_id": String(child_data.monster_id),
				"nickname": "",
				"level": child_level,
				"tactic": "まかせた",
				"plus_value": child_plus,
				"inherited_skills": inherited_skill_ids,
				"lineage":
				[
					{
						"rule_id": String(rule.rule_id),
						"parents":
						[
							String(parent_a.get("instance_id", "")),
							String(parent_b.get("instance_id", "")),
						],
					},
				],
				"generation_depth":
				(
					maxi(
						int(parent_a.get("generation_depth", 0)),
						int(parent_b.get("generation_depth", 0))
					)
					+ 1
				),
				"parent_instance_ids":
				[
					String(parent_a.get("instance_id", "")),
					String(parent_b.get("instance_id", "")),
				],
				"birth_rule_id": String(rule.rule_id),
				"joined_at_utc": Time.get_datetime_string_from_system(true, true),
				"source": "breeding",
			}
		)
		. to_dict()
	)

	var resolved := _resolved_rule_ids.has(String(rule.rule_id))
	return {
		"accepted": true,
		"rule_id": String(rule.rule_id),
		"rule_type": String(rule.rule_type),
		"priority": int(rule.priority),
		"resolved": resolved,
		"is_special": String(rule.rule_type) == "special",
		"parent_a": parent_a.duplicate(true),
		"parent_b": parent_b.duplicate(true),
		"parent_a_instance_id": String(parent_a.get("instance_id", "")),
		"parent_b_instance_id": String(parent_b.get("instance_id", "")),
		"parent_a_name": _entry_name(parent_a),
		"parent_b_name": _entry_name(parent_b),
		"child_name": String(child_data.name_jp),
		"child_monster_id": String(child_data.monster_id),
		"child_family": String(child_data.family),
		"child_rank": String(child_data.rank),
		"child_plus": child_plus,
		"inherit_slots": inherit_slots,
		"inherit_preview": _inherit_preview_text(inherited_skill_ids),
		"preview_text": _build_preview_text(rule, child_data, resolved),
		"child": child,
	}


func _resolve_rule(parent_a_data, parent_b_data, parent_a: Dictionary, parent_b: Dictionary):
	var parent_a_level := int(parent_a.get("level", 1))
	var parent_b_level := int(parent_b.get("level", 1))
	var best_rule = null
	var best_priority := -1
	for rule in _rule_cache:
		if parent_a_level < int(rule.lv_requirement) or parent_b_level < int(rule.lv_requirement):
			continue
		var direct_match := (
			_match_key(
				String(rule.parent_a_key),
				String(parent_a_data.monster_id),
				String(parent_a_data.family)
			)
			and _match_key(
				String(rule.parent_b_key),
				String(parent_b_data.monster_id),
				String(parent_b_data.family)
			)
		)
		var swapped_match := (
			_match_key(
				String(rule.parent_a_key),
				String(parent_b_data.monster_id),
				String(parent_b_data.family)
			)
			and _match_key(
				String(rule.parent_b_key),
				String(parent_a_data.monster_id),
				String(parent_a_data.family)
			)
		)
		if direct_match or swapped_match:
			if int(rule.priority) > best_priority:
				best_rule = rule
				best_priority = int(rule.priority)
	return best_rule


func _build_inherited_skill_ids(
	parent_a: Dictionary, parent_b: Dictionary, inherit_slots: int
) -> Array[String]:
	var inherited_skill_ids: Array[String] = []
	var seen := {}
	for skill_id in _collect_skill_ids(parent_a) + _collect_skill_ids(parent_b):
		if seen.has(skill_id):
			continue
		seen[skill_id] = true
		inherited_skill_ids.append(skill_id)
		if inherited_skill_ids.size() >= inherit_slots:
			break
	return inherited_skill_ids


func _collect_skill_ids(entry: Dictionary) -> Array[String]:
	var skill_ids: Array[String] = []
	for skill_id_variant in Array(entry.get("inherited_skills", [])):
		var inherited_id := String(skill_id_variant)
		if not inherited_id.is_empty():
			skill_ids.append(inherited_id)
	var monster = _registry.get_monster(String(entry.get("monster_id", "")))
	if monster == null:
		return skill_ids
	for learn_entry_variant in monster.learnset:
		if not learn_entry_variant is Dictionary:
			continue
		var learn_entry: Dictionary = learn_entry_variant
		var learn_type := String(learn_entry.get("learn_type", ""))
		var learn_value := int(learn_entry.get("learn_value", 0))
		if learn_type != "innate" and int(entry.get("level", 1)) < learn_value:
			continue
		var skill_id := String(learn_entry.get("skill_id", ""))
		if not skill_id.is_empty():
			skill_ids.append(skill_id)
		if skill_ids.size() >= 6:
			break
	return skill_ids


func _calc_child_plus(parent_a: Dictionary, parent_b: Dictionary, special_bonus: int) -> int:
	var level_sum := int(parent_a.get("level", 1)) + int(parent_b.get("level", 1))
	var level_bonus := 0
	if level_sum >= 160:
		level_bonus = 6
	elif level_sum >= 120:
		level_bonus = 5
	elif level_sum >= 90:
		level_bonus = 4
	elif level_sum >= 60:
		level_bonus = 3
	elif level_sum >= 40:
		level_bonus = 2
	elif level_sum >= 20:
		level_bonus = 1
	return mini(
		24,
		(
			maxi(int(parent_a.get("plus_value", 0)), int(parent_b.get("plus_value", 0)))
			+ level_bonus
			+ special_bonus
		)
	)


func _build_preview_text(rule, child_data, resolved: bool) -> String:
	if resolved:
		return (
			"%s +%d  %s"
			% [
				String(child_data.name_jp),
				_calc_preview_plus(rule),
				_family_hint(String(child_data.family)),
			]
		)
	if String(rule.rule_type) == "special":
		return "特別反応: %s 系の影がのぞく" % _family_hint(String(child_data.family))
	return "系統反応: %s 寄りにまとまりそう" % _family_hint(String(child_data.family))


func _inherit_preview_text(skill_ids: Array[String]) -> String:
	if skill_ids.is_empty():
		return "継承なし"
	var labels: Array[String] = []
	for skill_id in skill_ids:
		var skill = _registry.get_skill(skill_id)
		if skill == null:
			continue
		labels.append(String(skill.name_jp))
	if labels.is_empty():
		return "継承なし"
	return "継承:%s" % " / ".join(labels)


func _entry_name(entry: Dictionary) -> String:
	var nickname := String(entry.get("nickname", ""))
	if not nickname.is_empty():
		return nickname
	return String(entry.get("name", entry.get("monster_id", "?")))


func _match_key(rule_key: String, monster_id: String, family: String) -> bool:
	if rule_key.is_empty():
		return false
	if rule_key.begins_with("family:"):
		return rule_key.trim_prefix("family:") == family
	if rule_key.begins_with("MON-"):
		return rule_key == monster_id
	return rule_key == family or rule_key == monster_id


func _family_hint(family: String) -> String:
	return String(FAMILY_LABELS.get(family, family))


func _ensure_rules_loaded() -> void:
	if not _rule_cache.is_empty():
		return
	for rule_id in _registry.list_resource_ids("breeding"):
		var rule = _registry.get_breed_rule(rule_id)
		if rule != null:
			_rule_cache.append(rule)


func _sort_candidates(a: Dictionary, b: Dictionary) -> bool:
	if bool(a.get("is_special", false)) != bool(b.get("is_special", false)):
		return bool(a.get("is_special", false))
	if int(a.get("priority", 0)) != int(b.get("priority", 0)):
		return int(a.get("priority", 0)) > int(b.get("priority", 0))
	return String(a.get("child_monster_id", "")) < String(b.get("child_monster_id", ""))


func _calc_preview_plus(rule) -> int:
	return maxi(int(rule.special_recipe_bonus), 0)


func _array_to_bool_map(entries: Array) -> Dictionary:
	var mapped := {}
	for entry in entries:
		var key := String(entry)
		if not key.is_empty():
			mapped[key] = true
	return mapped


func _sorted_bool_map_keys(entries: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key in entries.keys():
		keys.append(String(key))
	keys.sort()
	return keys
