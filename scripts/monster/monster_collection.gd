# gdlint: disable=max-public-methods
class_name MonsterCollection
extends RefCounted

const OwnedMonsterScript = preload("res://scripts/monster/owned_monster.gd")

const PARTY_LIMIT := 3
const RANCH_LIMIT := 38
const LOCK_LIMIT := 5

var _party: Array = []
var _ranch: Array = []


func clear() -> void:
	_party.clear()
	_ranch.clear()


func load_from_save(party_entries: Array, ranch_entries: Array) -> void:
	clear()
	for entry_variant in party_entries:
		if entry_variant is Dictionary:
			_party.append(OwnedMonsterScript.from_dict(entry_variant))
	for entry_variant in ranch_entries:
		if entry_variant is Dictionary:
			_ranch.append(OwnedMonsterScript.from_dict(entry_variant))


func seed_demo_state() -> void:
	load_from_save(
		[
			{
				"instance_id": "MON-001-demo-1",
				"monster_id": "MON-001",
				"nickname": "ケダ",
				"level": 10,
				"tactic": "全力で攻めろ",
				"loyalty": 80,
				"source": "field_companion",
			},
			{
				"instance_id": "MON-003-demo-1",
				"monster_id": "MON-003",
				"level": 9,
				"tactic": "命を守れ",
				"loyalty": 46,
				"source": "demo_party",
			},
			{
				"instance_id": "MON-008-demo-1",
				"monster_id": "MON-008",
				"level": 12,
				"tactic": "援護を頼む",
				"loyalty": 52,
				"source": "demo_party",
			},
		],
		[
			{
				"instance_id": "MON-002-demo-ranch-1",
				"monster_id": "MON-002",
				"level": 12,
				"tactic": "まかせた",
				"locked": false,
				"loyalty": 67,
				"source": "demo_ranch",
			},
		]
	)


func is_empty() -> bool:
	return _party.is_empty() and _ranch.is_empty()


func _get_party_members() -> Array:
	var members: Array = []
	for monster in _party:
		members.append(monster)
	return members


func _get_ranch_members() -> Array:
	var members: Array = []
	for monster in _ranch:
		members.append(monster)
	return members


func party_size() -> int:
	return _party.size()


func ranch_size() -> int:
	return _ranch.size()


func average_party_level() -> int:
	if _party.is_empty():
		return 1
	var total := 0
	for monster in _party:
		total += int(monster.level)
	return maxi(int(round(float(total) / float(_party.size()))), 1)


func has_species(monster_id: String) -> bool:
	for monster in _party + _ranch:
		if String(monster.monster_id) == monster_id:
			return true
	return false


func lock_count() -> int:
	var total := 0
	for monster in _party + _ranch:
		if bool(monster.locked):
			total += 1
	return total


func serialize_party() -> Array[Dictionary]:
	return _serialize_monsters(_party)


func serialize_ranch() -> Array[Dictionary]:
	return _serialize_monsters(_ranch)


func build_battle_party() -> Array[Dictionary]:
	var setup_entries: Array[Dictionary] = []
	for monster in _party:
		setup_entries.append(monster.to_battle_setup())
	return setup_entries


func build_breeding_candidates() -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	for index in range(_party.size()):
		var entry: Dictionary = _party[index].to_dict()
		entry["location"] = "party"
		entry["location_index"] = index
		entry["name"] = _display_name_for_monster(_party[index])
		candidates.append(entry)
	for index in range(_ranch.size()):
		var entry: Dictionary = _ranch[index].to_dict()
		entry["location"] = "ranch"
		entry["location_index"] = index
		entry["name"] = _display_name_for_monster(_ranch[index])
		candidates.append(entry)
	return candidates


func sync_party_from_battle(result_party: Array) -> void:
	var updates := {}
	for entry_variant in result_party:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant
		var key := String(entry.get("instance_id", ""))
		if key.is_empty():
			key = "slot:%d" % int(entry.get("slot", -1))
		updates[key] = entry

	for index in range(_party.size()):
		var monster = _party[index]
		var lookup_key: String = monster.instance_id
		if lookup_key.is_empty():
			lookup_key = "slot:%d" % index
		if not updates.has(lookup_key):
			continue
		var update: Dictionary = updates[lookup_key]
		monster.level = maxi(int(update.get("level", monster.level)), 1)
		monster.tactic = String(update.get("tactic", monster.tactic))
		monster.current_hp = int(update.get("hp", monster.current_hp))
		monster.current_mp = int(update.get("mp", monster.current_mp))
		monster.nickname = String(update.get("nickname", monster.nickname))


func restore_party_resources() -> Dictionary:
	if _party.is_empty():
		return {"accepted": false, "reason": "no_party"}

	for monster in _party:
		monster.current_hp = -1
		monster.current_mp = -1
	return {"accepted": true, "restored_members": _party.size()}


func set_party_member_resources(index: int, hp: int, mp: int) -> Dictionary:
	if index < 0 or index >= _party.size():
		return {"accepted": false, "reason": "invalid_party_index"}

	var monster = _party[index]
	monster.current_hp = maxi(hp, -1)
	monster.current_mp = maxi(mp, -1)
	return {
		"accepted": true,
		"index": index,
		"current_hp": monster.current_hp,
		"current_mp": monster.current_mp,
	}


func add_recruited_monster(monster_data: Dictionary) -> Dictionary:
	var recruited = OwnedMonsterScript.from_dict(monster_data)
	if _party.size() < PARTY_LIMIT:
		_party.append(recruited)
		return {"accepted": true, "destination": "party", "instance_id": recruited.instance_id}
	if _ranch.size() < RANCH_LIMIT:
		_ranch.append(recruited)
		return {"accepted": true, "destination": "ranch", "instance_id": recruited.instance_id}
	return {"accepted": false, "destination": "none", "reason": "capacity"}


func move_party_member_to_ranch(party_index: int) -> Dictionary:
	if party_index < 0 or party_index >= _party.size():
		return {"accepted": false, "reason": "invalid_party_index"}
	if _ranch.size() >= RANCH_LIMIT:
		return {"accepted": false, "reason": "ranch_full"}
	if _party.size() <= 1:
		return {"accepted": false, "reason": "party_minimum"}

	var monster = _party[party_index]
	_party.remove_at(party_index)
	_ranch.append(monster)
	return {"accepted": true, "monster_id": monster.monster_id, "destination": "ranch"}


func move_ranch_member_to_party(ranch_index: int, party_index: int = -1) -> Dictionary:
	if ranch_index < 0 or ranch_index >= _ranch.size():
		return {"accepted": false, "reason": "invalid_ranch_index"}

	var incoming = _ranch[ranch_index]
	if _party.size() < PARTY_LIMIT:
		_ranch.remove_at(ranch_index)
		_party.append(incoming)
		return {"accepted": true, "destination": "party", "swapped": false}

	if party_index < 0 or party_index >= _party.size():
		return {"accepted": false, "reason": "party_full"}
	if bool(_party[party_index].locked):
		return {"accepted": false, "reason": "party_locked"}

	var outgoing = _party[party_index]
	_party[party_index] = incoming
	_ranch[ranch_index] = outgoing
	return {
		"accepted": true,
		"destination": "party",
		"swapped": true,
		"replaced_monster_id": outgoing.monster_id,
	}


func toggle_lock(location: String, index: int) -> Dictionary:
	var target = _monster_at(location, index)
	if target == null:
		return {"accepted": false, "reason": "invalid_target"}

	if bool(target.locked):
		target.locked = false
		return {"accepted": true, "locked": false}

	if lock_count() >= LOCK_LIMIT:
		return {"accepted": false, "reason": "lock_limit"}

	target.locked = true
	return {"accepted": true, "locked": true}


func breed_monsters(
	parent_a_instance_id: String, parent_b_instance_id: String, child_data: Dictionary
) -> Dictionary:
	if parent_a_instance_id.is_empty() or parent_b_instance_id.is_empty():
		return {"accepted": false, "reason": "missing_parent"}
	if parent_a_instance_id == parent_b_instance_id:
		return {"accepted": false, "reason": "same_parent"}

	var parent_a_ref := _find_monster_ref(parent_a_instance_id)
	var parent_b_ref := _find_monster_ref(parent_b_instance_id)
	if parent_a_ref.is_empty() or parent_b_ref.is_empty():
		return {"accepted": false, "reason": "missing_parent"}

	var parent_a = parent_a_ref["monster"]
	var parent_b = parent_b_ref["monster"]
	if bool(parent_a.locked) or bool(parent_b.locked):
		return {"accepted": false, "reason": "parent_locked"}

	var child = OwnedMonsterScript.from_dict(child_data)
	var prefer_party := (
		String(parent_a_ref.get("location", "")) == "party"
		or String(parent_b_ref.get("location", "")) == "party"
	)

	_remove_monster_ref(parent_a_ref, parent_b_ref)
	_remove_monster_ref(parent_b_ref, {})

	var destination := "ranch"
	if prefer_party and _party.size() < PARTY_LIMIT:
		_party.append(child)
		destination = "party"
	else:
		_ranch.append(child)

	return {
		"accepted": true,
		"destination": destination,
		"child_instance_id": child.instance_id,
		"parents":
		[
			{
				"instance_id": parent_a.instance_id,
				"monster_id": parent_a.monster_id,
				"nickname": parent_a.nickname,
			},
			{
				"instance_id": parent_b.instance_id,
				"monster_id": parent_b.monster_id,
				"nickname": parent_b.nickname,
			},
		],
	}


func build_menu_snapshot() -> Dictionary:
	return {
		"party": serialize_party(),
		"ranch": serialize_ranch(),
		"limits":
		{
			"party": PARTY_LIMIT,
			"ranch": RANCH_LIMIT,
			"locks": LOCK_LIMIT,
			"current_locks": lock_count(),
		},
	}


func _monster_at(location: String, index: int):
	var pool = _party if location == "party" else _ranch if location == "ranch" else []
	if index < 0 or index >= pool.size():
		return null
	return pool[index]


func _find_monster_ref(instance_id: String) -> Dictionary:
	for index in range(_party.size()):
		var monster = _party[index]
		if String(monster.instance_id) == instance_id:
			return {"location": "party", "index": index, "monster": monster}
	for index in range(_ranch.size()):
		var monster = _ranch[index]
		if String(monster.instance_id) == instance_id:
			return {"location": "ranch", "index": index, "monster": monster}
	return {}


func _remove_monster_ref(reference: Dictionary, sibling_reference: Dictionary) -> void:
	var location := String(reference.get("location", ""))
	var index := int(reference.get("index", -1))
	if location.is_empty() or index < 0:
		return

	if not sibling_reference.is_empty():
		var sibling_location := String(sibling_reference.get("location", ""))
		var sibling_index := int(sibling_reference.get("index", -1))
		if location == sibling_location and index > sibling_index:
			index -= 1

	var pool = _party if location == "party" else _ranch if location == "ranch" else []
	if index < 0 or index >= pool.size():
		return
	pool.remove_at(index)


func _serialize_monsters(monsters: Array) -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	for monster in monsters:
		serialized.append(monster.to_dict())
	return serialized


func _display_name_for_monster(monster) -> String:
	var nickname := String(monster.nickname)
	if not nickname.is_empty():
		return nickname
	return String(monster.monster_id)
