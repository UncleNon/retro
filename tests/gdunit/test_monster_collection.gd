extends GdUnitTestSuite

const MonsterCollectionScript = preload("res://scripts/monster/monster_collection.gd")


func test_move_party_member_to_ranch_keeps_party_minimum() -> void:
	var collection = MonsterCollectionScript.new()
	collection.seed_demo_state()

	assert_int(collection.party_size()).is_equal(3)
	assert_int(collection.ranch_size()).is_equal(1)

	var move_result: Dictionary = collection.move_party_member_to_ranch(2)
	assert_bool(bool(move_result.get("accepted", false))).is_true()
	assert_str(String(move_result.get("destination", ""))).is_equal("ranch")
	assert_int(collection.party_size()).is_equal(2)
	assert_int(collection.ranch_size()).is_equal(2)

	var second_move: Dictionary = collection.move_party_member_to_ranch(1)
	assert_bool(bool(second_move.get("accepted", false))).is_true()
	assert_int(collection.party_size()).is_equal(1)

	var blocked_move: Dictionary = collection.move_party_member_to_ranch(0)
	assert_bool(bool(blocked_move.get("accepted", false))).is_false()
	assert_str(String(blocked_move.get("reason", ""))).is_equal("party_minimum")


func test_toggle_lock_enforces_limit() -> void:
	var collection = MonsterCollectionScript.new()
	collection.load_from_save(
		[
			{"instance_id": "party-1", "monster_id": "MON-001", "locked": false},
			{"instance_id": "party-2", "monster_id": "MON-002", "locked": false},
			{"instance_id": "party-3", "monster_id": "MON-003", "locked": false},
		],
		[
			{"instance_id": "ranch-1", "monster_id": "MON-004", "locked": false},
			{"instance_id": "ranch-2", "monster_id": "MON-005", "locked": false},
			{"instance_id": "ranch-3", "monster_id": "MON-006", "locked": false},
		]
	)

	assert_bool(bool(collection.toggle_lock("party", 0).get("accepted", false))).is_true()
	assert_bool(bool(collection.toggle_lock("party", 1).get("accepted", false))).is_true()
	assert_bool(bool(collection.toggle_lock("party", 2).get("accepted", false))).is_true()
	assert_bool(bool(collection.toggle_lock("ranch", 0).get("accepted", false))).is_true()
	assert_bool(bool(collection.toggle_lock("ranch", 1).get("accepted", false))).is_true()

	assert_int(collection.lock_count()).is_equal(5)

	var blocked_result: Dictionary = collection.toggle_lock("ranch", 2)
	assert_bool(bool(blocked_result.get("accepted", false))).is_false()
	assert_str(String(blocked_result.get("reason", ""))).is_equal("lock_limit")


func test_breed_monsters_prefers_party_destination_when_slot_is_open() -> void:
	var collection = MonsterCollectionScript.new()
	collection.seed_demo_state()
	var move_result: Dictionary = collection.move_party_member_to_ranch(1)
	var child_payload := _child_payload("MON-010-child")

	var result: Dictionary = collection.breed_monsters(
		"MON-002-demo-ranch-1",
		"MON-008-demo-1",
		child_payload
	)
	var party := collection.serialize_party()
	var ranch := collection.serialize_ranch()

	assert_bool(bool(move_result.get("accepted", false))).is_true()
	assert_bool(bool(result.get("accepted", false))).is_true()
	assert_str(String(result.get("destination", ""))).is_equal("party")
	assert_int(collection.party_size()).is_equal(2)
	assert_int(collection.ranch_size()).is_equal(1)
	assert_bool(_entries_have_monster(party, "MON-010")).is_true()
	assert_bool(_entries_have_monster(ranch, "MON-003")).is_true()


func test_breed_monsters_rejects_locked_parent() -> void:
	var collection = MonsterCollectionScript.new()
	collection.seed_demo_state()
	var lock_result: Dictionary = collection.toggle_lock("ranch", 0)

	var result: Dictionary = collection.breed_monsters(
		"MON-002-demo-ranch-1",
		"MON-008-demo-1",
		_child_payload("MON-010-locked-check")
	)

	assert_bool(bool(lock_result.get("accepted", false))).is_true()
	assert_bool(bool(result.get("accepted", false))).is_false()
	assert_str(String(result.get("reason", ""))).is_equal("parent_locked")


func _child_payload(instance_id: String) -> Dictionary:
	return {
		"instance_id": instance_id,
		"monster_id": "MON-010",
		"level": 14,
		"tactic": "まかせた",
		"plus_value": 3,
		"source": "breeding",
	}


func _entries_have_monster(entries: Array, monster_id: String) -> bool:
	for entry_variant in entries:
		if entry_variant is Dictionary and String(entry_variant.get("monster_id", "")) == monster_id:
			return true
	return false
