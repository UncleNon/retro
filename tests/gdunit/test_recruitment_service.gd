extends GdUnitTestSuite

const MonsterCollectionScript = preload("res://scripts/monster/monster_collection.gd")
const RecruitmentServiceScript = preload("res://scripts/monster/recruitment_service.gd")


func test_resolve_victory_recruit_succeeds_for_high_score_candidate() -> void:
	var collection = MonsterCollectionScript.new()
	collection.seed_demo_state()
	var service = RecruitmentServiceScript.new()

	var result: Dictionary = service.resolve_victory_recruit(
		{
			"outcome": "victory",
			"recruit_contexts":
			[
				{
					"monster_id": "MON-004",
					"name": "オボロイヌ",
					"level": 6,
					"rank": "E",
					"base_recruit": 42,
					"scoutable": true,
					"alive": false,
					"hp_ratio": 0.04,
					"ailments": {"sleep": 2, "soot": 2},
					"recruit_bonus": 26,
					"last_bait_item_id": "item_bait_truefeast",
					"bait_family_match": true,
				},
			],
		},
		collection,
		12
	)

	assert_bool(bool(result.get("attempted", false))).is_true()
	assert_bool(bool(result.get("success", false))).is_true()
	assert_str(String(result.get("monster_id", ""))).is_equal("MON-004")
	assert_int(int(result.get("rate", 0))).is_greater_equal(70)
	assert_str(String(Dictionary(result.get("owned_monster", {})).get("source", ""))).is_equal("recruit")


func test_resolve_victory_recruit_requires_baited_candidate() -> void:
	var collection = MonsterCollectionScript.new()
	collection.seed_demo_state()
	var service = RecruitmentServiceScript.new()

	var result: Dictionary = service.resolve_victory_recruit(
		{
			"outcome": "victory",
			"recruit_contexts":
			[
				{
					"monster_id": "MON-010",
					"name": "トオボエ",
					"level": 16,
					"rank": "A",
					"base_recruit": 8,
					"scoutable": true,
					"alive": false,
					"hp_ratio": 0.50,
					"ailments": {},
					"recruit_bonus": 0,
					"last_bait_item_id": "",
					"bait_family_match": false,
				},
			],
		},
		collection,
		1
	)

	assert_bool(bool(result.get("attempted", false))).is_false()
	assert_str(String(result.get("reason", ""))).is_equal("no_candidate")
