extends GdUnitTestSuite

const InventoryRuntimeScript = preload("res://scripts/item/inventory_runtime.gd")


func test_carry_limit_rejects_slot_twenty_one() -> void:
	var inventory := InventoryRuntimeScript.new()
	inventory.load_from_save([])

	var carry_item_ids := [
		"item_heal_dryherb",
		"item_heal_softmoss",
		"item_heal_bundleleaf",
		"item_heal_fatbroth",
		"item_heal_whitebulb",
		"item_heal_stillmilk",
		"item_heal_embersap",
		"item_heal_blackfeast",
		"item_mp_clearwater",
		"item_mp_bitterdew",
		"item_mp_milksalt",
		"item_mp_silentwax",
		"item_mp_bluepith",
		"item_mp_starcurd",
		"item_cure_saltleaf",
		"item_cure_wakebud",
		"item_cure_focussalt",
		"item_bait_drycrumb",
		"item_bait_smokedfat",
		"item_buff_ironmeal",
	]

	for item_id in carry_item_ids:
		var add_result: Dictionary = inventory.add_item(item_id, 1)
		assert_that(bool(add_result.get("accepted", false))).is_true()

	assert_that(inventory.used_carry_slots()).is_equal(20)

	var overflow_result: Dictionary = inventory.add_item("item_record_rubbingset", 1)
	assert_that(bool(overflow_result.get("accepted", false))).is_false()
	assert_that(String(overflow_result.get("reason", ""))).is_equal("carry_full")

	var key_item_result: Dictionary = inventory.add_item("item_key_towerwrit", 1)
	assert_that(bool(key_item_result.get("accepted", false))).is_true()
