extends GdUnitTestSuite

const BreedingServiceScript = preload("res://scripts/monster/breeding_service.gd")
const MonsterCollectionScript = preload("res://scripts/monster/monster_collection.gd")


func test_build_candidates_prioritizes_special_recipe() -> void:
	var collection := MonsterCollectionScript.new()
	collection.seed_demo_state()
	var breeding := BreedingServiceScript.new()

	var snapshot: Dictionary = breeding.build_menu_snapshot(collection)
	var entries := Array(snapshot.get("entries", []))

	assert_that(entries.is_empty()).is_false()
	var first_entry: Dictionary = Dictionary(entries[0])
	assert_that(String(first_entry.get("rule_id", ""))).is_equal("BRD-0005")
	assert_that(bool(first_entry.get("is_special", false))).is_true()
	assert_that(String(first_entry.get("child_monster_id", ""))).is_equal("MON-010")


func test_execute_candidate_consumes_parents_and_records_history() -> void:
	var collection := MonsterCollectionScript.new()
	collection.seed_demo_state()
	var breeding := BreedingServiceScript.new()

	var candidates := breeding.build_candidates(collection)
	assert_that(candidates.is_empty()).is_false()
	var result := breeding.execute_candidate(collection, Dictionary(candidates[0]))

	assert_that(bool(result.get("accepted", false))).is_true()
	assert_that(String(result.get("rule_id", ""))).is_equal("BRD-0005")

	var roster: Array = []
	roster.append_array(collection.serialize_party())
	roster.append_array(collection.serialize_ranch())

	var monster_ids: Array[String] = []
	for monster_variant in roster:
		if monster_variant is Dictionary:
			monster_ids.append(String(Dictionary(monster_variant).get("monster_id", "")))

	assert_that(monster_ids.has("MON-010")).is_true()
	assert_that(monster_ids.has("MON-002")).is_false()
	assert_that(monster_ids.has("MON-008")).is_false()

	var save_payload := breeding.serialize_state()
	assert_that(Array(save_payload.get("resolved_rule_ids", [])).has("BRD-0005")).is_true()
	assert_that(Array(save_payload.get("history", [])).size()).is_greater(0)
