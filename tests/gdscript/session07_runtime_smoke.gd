extends SceneTree

const AppScene = preload("res://scenes/main/app_root.tscn")
const InventoryRuntimeScript = preload("res://scripts/item/inventory_runtime.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_run_inventory_limit_smoke()
	await _run_app_runtime_smoke()

	if _failures.is_empty():
		print("session07 runtime smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _run_inventory_limit_smoke() -> void:
	var inventory = InventoryRuntimeScript.new()
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
		_assert(bool(add_result.get("accepted", false)), "carry slot fill should accept %s" % item_id)
	_assert(inventory.used_carry_slots() == 20, "inventory should report 20 carry slots in use")

	var overflow_result: Dictionary = inventory.add_item("item_record_rubbingset", 1)
	_assert(not bool(overflow_result.get("accepted", false)), "carry slot 21 should be rejected")
	_assert(String(overflow_result.get("reason", "")) == "carry_full", "overflow should fail with carry_full")

	var key_item_result: Dictionary = inventory.add_item("item_key_towerwrit", 1)
	_assert(bool(key_item_result.get("accepted", false)), "key items should bypass carry limit")


func _run_app_runtime_smoke() -> void:
	var save_system = root.get_node_or_null("/root/SaveSystem")
	var save_root := "/tmp/project_retro_session07_%s" % Time.get_ticks_usec()
	if save_system != null:
		save_system.set_save_root_override(save_root)
		save_system.bootstrap()

	var app = AppScene.instantiate()
	root.add_child(app)
	await process_frame

	var snapshot: Dictionary = app.get_runtime_snapshot()
	_assert(Array(snapshot.get("party", [])).size() == 3, "app should bootstrap with a 3-monster party")
	_assert(Array(snapshot.get("ranch", [])).size() >= 1, "app should bootstrap with ranch data")

	app.open_menu()
	await process_frame
	snapshot = app.get_runtime_snapshot()
	_assert(bool(snapshot.get("menu_open", false)), "menu should open from app root")
	var menu = app.get("_menu_root")
	_assert(menu != null, "app should instantiate menu root")
	if menu != null:
		var menu_ui: Dictionary = menu.call("get_ui_snapshot")
		_assert("G080" in String(menu_ui.get("header", "")), "menu header should show starting gold")
		menu.call("debug_select_section", "inventory")
		var inventory_ui: Dictionary = menu.call("get_ui_snapshot")
		_assert(
			"HP20回復" in String(inventory_ui.get("message", "")),
			"inventory section should surface selected item effect in the message band"
		)
		_assert(
			"借り名の冬" in String(inventory_ui.get("message", "")),
			"inventory section should surface selected item lore text in the message band"
		)
		menu.call("debug_select_section", "codex")
		var codex_ui: Dictionary = menu.call("get_ui_snapshot")
		_assert(
			"beast E" in String(codex_ui.get("message", "")),
			"codex section should surface family and rank in the message band"
		)
		_assert(
			"開始村の家畜" in String(codex_ui.get("message", "")),
			"codex section should surface the selected monster lore note in the message band"
		)

	var lock_result: Dictionary = app.toggle_monster_lock("party", 0)
	_assert(bool(lock_result.get("accepted", false)), "party lock toggle should succeed")
	snapshot = app.get_runtime_snapshot()
	_assert(bool(Array(snapshot.get("party", []))[0].get("locked", false)), "party lock should persist in runtime snapshot")

	var withdraw_fail: Dictionary = app.move_ranch_monster_to_party(0)
	_assert(not bool(withdraw_fail.get("accepted", false)), "ranch withdraw should fail when party is full")
	_assert(String(withdraw_fail.get("reason", "")) == "party_full", "full party should block ranch withdraw")

	var park_result: Dictionary = app.move_party_monster_to_ranch(2)
	_assert(bool(park_result.get("accepted", false)), "party member should move to ranch")
	var withdraw_ok: Dictionary = app.move_ranch_monster_to_party(0)
	_assert(bool(withdraw_ok.get("accepted", false)), "ranch member should move into open party slot")

	snapshot = app.get_runtime_snapshot()
	var success_result: Dictionary = app.debug_apply_battle_result_for_test(
		{
			"outcome": "victory",
			"party": Array(snapshot.get("party", [])).duplicate(true),
			"inventory": Array(snapshot.get("inventory", [])).duplicate(true),
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
					"last_bait_bonus": 26,
					"bait_family_match": true,
				},
			],
		},
		12
	)
	var recruit_success: Dictionary = success_result.get("recruit_result", {})
	_assert(bool(recruit_success.get("attempted", false)), "victory with bait should attempt recruit")
	_assert(bool(recruit_success.get("received", false)), "high recruit score should add a monster")

	snapshot = app.get_runtime_snapshot()
	var failure_result: Dictionary = app.debug_apply_battle_result_for_test(
		{
			"outcome": "victory",
			"party": Array(snapshot.get("party", [])).duplicate(true),
			"inventory": Array(snapshot.get("inventory", [])).duplicate(true),
			"recruit_contexts":
			[
				{
					"monster_id": "MON-099",
					"name": "トオボエ",
					"level": 16,
					"rank": "A",
					"base_recruit": 8,
					"scoutable": true,
					"alive": false,
					"hp_ratio": 0.92,
					"ailments": {},
					"recruit_bonus": 4,
					"last_bait_item_id": "item_bait_drycrumb",
					"last_bait_bonus": 4,
					"bait_family_match": false,
				},
			],
		},
		99
	)
	var recruit_failure: Dictionary = failure_result.get("recruit_result", {})
	_assert(bool(recruit_failure.get("attempted", false)), "low recruit score should still attempt recruit")
	_assert(not bool(recruit_failure.get("received", false)), "low recruit score should fail to recruit")
	if menu != null:
		menu.call("debug_select_section", "log")
		var log_ui: Dictionary = menu.call("get_ui_snapshot")
		_assert("[戦]" in String(log_ui.get("detail", "")), "log section should record battle outcomes")
		_assert(
			"[仲]" in String(log_ui.get("detail", "")) and "オボロイヌ" in String(log_ui.get("detail", "")),
			"log section should record successful recruit outcomes"
		)

	app.close_menu()
	await process_frame
	app.free()

	var reloaded = AppScene.instantiate()
	root.add_child(reloaded)
	await process_frame

	var reloaded_snapshot: Dictionary = reloaded.get_runtime_snapshot()
	var all_monsters := Array(reloaded_snapshot.get("party", [])) + Array(reloaded_snapshot.get("ranch", []))
	var found_recruited := false
	var found_locked := false
	for monster_variant in all_monsters:
		if not monster_variant is Dictionary:
			continue
		var monster: Dictionary = monster_variant
		if String(monster.get("monster_id", "")) == "MON-004":
			found_recruited = true
		if bool(monster.get("locked", false)):
			found_locked = true
	_assert(found_recruited, "autosave load should keep the recruited monster")
	_assert(found_locked, "autosave load should keep lock state")

	var codex: Dictionary = reloaded_snapshot.get("codex", {})
	_assert(
		"MON-004" in Array(codex.get("recruited_ids", [])),
		"codex should retain recruited monster ids after reload"
	)

	reloaded.free()


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
