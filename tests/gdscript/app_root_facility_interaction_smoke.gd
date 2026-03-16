extends SceneTree

const AppScene = preload("res://scenes/main/app_root.tscn")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_system = root.get_node_or_null("/root/SaveSystem")
	var save_root := "/tmp/project_retro_app_facility_%s" % Time.get_ticks_usec()
	if save_system != null:
		save_system.set_save_root_override(save_root)
		save_system.bootstrap()

	var app = AppScene.instantiate()
	root.add_child(app)
	await process_frame

	var field = app.get_node("FieldRoot")
	_assert(field != null, "app root should expose field root")
	if field == null:
		_finish(app)
		return

	app.call("debug_set_player_gold_for_test", 80)
	app.call("debug_set_party_member_resources_for_test", 0, 1, 0)
	var before_runtime: Dictionary = app.call("get_runtime_snapshot")
	_assert(
		int(Dictionary(before_runtime.get("player", {})).get("gold", -1)) == 80,
		"facility smoke should start from seeded 80G"
	)
	_assert(
		int(Dictionary(Array(before_runtime.get("party", []))[0]).get("current_hp", -1)) == 1,
		"facility smoke should injure the first party monster before healing"
	)

	var merchant_tile: Dictionary = field.call("debug_get_point_tile", "merchant_counter")
	field.call(
		"set_player_tile",
		Vector2i(int(merchant_tile.get("x", 0)) - 1, int(merchant_tile.get("y", 0)))
	)
	field.call("set_facing", Vector2i.RIGHT)
	field.call("interact")
	await process_frame

	var merchant_state: Dictionary = field.get_state_snapshot()
	var merchant_result: Dictionary = merchant_state.get("last_facility_result", {})
	_assert(bool(merchant_result.get("accepted", false)), "merchant interaction should resolve")
	_assert(
		String(merchant_result.get("npc_id", "")) == "NPC-VIL-013",
		"merchant interaction should resolve village merchant npc"
	)
	_assert(
		String(merchant_result.get("shop_id", "")) == "shop_vil_general",
		"merchant interaction should resolve general store"
	)
	_assert(
		Array(merchant_result.get("preview_items", [])).size() >= 3,
		"merchant interaction should expose item preview"
	)
	_assert(
		String(merchant_result.get("mode", "")) == "preview",
		"first merchant interaction should stay in preview mode"
	)
	_assert(
		bool(merchant_result.get("action_ready", false)),
		"merchant preview should arm the default purchase"
	)
	_assert(
		"もう一度" in String(merchant_state.get("last_message", "")),
		"merchant preview should hint at confirm interaction in field log"
	)
	_assert(
		"借り名の冬" in String(merchant_state.get("last_message", "")),
		"merchant preview should surface item lore from the default shelf item"
	)
	_assert(
		"干し棚の品は切らせない" in String(merchant_state.get("last_message", "")),
		"merchant preview should surface canonical shop bark for the default item"
	)

	field.call("interact")
	await process_frame

	var merchant_purchase_state: Dictionary = field.get_state_snapshot()
	var merchant_purchase_result: Dictionary = merchant_purchase_state.get(
		"last_facility_result", {}
	)
	_assert(
		String(merchant_purchase_result.get("mode", "")) == "execute",
		"second merchant interaction should execute purchase"
	)
	_assert(
		String(merchant_purchase_result.get("item_id", "")) == "item_heal_dryherb",
		"merchant purchase should buy the first active item"
	)
	_assert(
		int(merchant_purchase_result.get("gold_after", -1)) == 60,
		"merchant purchase should subtract default item price from gold"
	)
	_assert(
		"借り名の冬" in String(merchant_purchase_result.get("field_message", "")),
		"merchant purchase should retain item lore in the execution message"
	)
	_assert(
		"干し棚の品は切らせない" in String(merchant_purchase_result.get("field_message", "")),
		"merchant purchase should retain canonical shop bark in the execution message"
	)
	var after_merchant_runtime: Dictionary = app.call("get_runtime_snapshot")
	_assert(
		int(Dictionary(after_merchant_runtime.get("player", {})).get("gold", -1)) == 60,
		"merchant purchase should persist gold consumption"
	)
	_assert(
		(
			_find_inventory_quantity(
				Array(after_merchant_runtime.get("inventory", [])), "item_heal_dryherb"
			)
			== 3
		),
		"merchant purchase should add one dry herb to the inventory"
	)

	var healer_tile: Dictionary = field.call("debug_get_point_tile", "healer_counter")
	field.call(
		"set_player_tile", Vector2i(int(healer_tile.get("x", 0)) - 1, int(healer_tile.get("y", 0)))
	)
	field.call("set_facing", Vector2i.RIGHT)
	field.call("interact")
	await process_frame

	var healer_state: Dictionary = field.get_state_snapshot()
	var healer_result: Dictionary = healer_state.get("last_facility_result", {})
	_assert(bool(healer_result.get("accepted", false)), "healer interaction should resolve")
	_assert(
		String(healer_result.get("npc_id", "")) == "NPC-VIL-014",
		"healer interaction should resolve village healer npc"
	)
	_assert(
		String(healer_result.get("service_id", "")) == "service_vil_restoration",
		"healer interaction should resolve restoration service"
	)
	_assert(
		int(healer_result.get("service_price", 0)) == 18,
		"healer interaction should preserve service price"
	)
	_assert(
		String(healer_result.get("mode", "")) == "preview",
		"first healer interaction should stay in preview mode"
	)
	_assert(
		bool(healer_result.get("action_ready", false)),
		"healer preview should arm the default service"
	)
	_assert(
		"もう一度" in String(healer_state.get("last_message", "")),
		"healer preview should hint at confirm interaction in field log"
	)
	_assert(
		"借り名の冬" in String(healer_state.get("last_message", "")),
		"healer preview should surface shelf lore from the clinic stock"
	)

	field.call("interact")
	await process_frame

	var healer_service_state: Dictionary = field.get_state_snapshot()
	var healer_service_result: Dictionary = healer_service_state.get("last_facility_result", {})
	_assert(
		String(healer_service_result.get("mode", "")) == "execute",
		"second healer interaction should execute service"
	)
	_assert(
		int(healer_service_result.get("gold_after", -1)) == 42,
		"healer service should subtract restoration price from gold"
	)
	var runtime_snapshot: Dictionary = app.call("get_runtime_snapshot")
	var runtime_party: Array = Array(runtime_snapshot.get("party", []))
	_assert(
		int(Dictionary(runtime_snapshot.get("player", {})).get("gold", -1)) == 42,
		"healer service should persist remaining gold"
	)
	_assert(
		int(Dictionary(runtime_party[0]).get("current_hp", 0)) == -1,
		"healer service should restore party HP sentinel"
	)
	_assert(
		int(Dictionary(runtime_party[0]).get("current_mp", 1)) == -1,
		"healer service should restore party MP sentinel"
	)
	_assert(
		"残り 42G" in String(runtime_snapshot.get("message", "")),
		"facility execution should propagate purchase summary into menu message"
	)

	app.open_menu()
	await process_frame
	var menu = app.get("_menu_root")
	_assert(menu != null, "app root should expose menu root after opening menu")
	if menu != null:
		var party_ui: Dictionary = menu.call("get_ui_snapshot")
		_assert(
			"G042" in String(party_ui.get("header", "")),
			"menu header should surface remaining gold after facility actions"
		)
		menu.call("debug_select_section", "inventory")
		var inventory_ui: Dictionary = menu.call("get_ui_snapshot")
		_assert(
			"6/20" in String(inventory_ui.get("header", "")),
			"inventory header should surface carry usage"
		)
		_assert(
			"ふくろ 6/20" in String(inventory_ui.get("detail", "")),
			"inventory detail should surface carry usage summary"
		)
		menu.call("debug_select_section", "log")
		var log_ui: Dictionary = menu.call("get_ui_snapshot")
		_assert(
			"[施]" in String(log_ui.get("detail", "")), "log section should tag facility actions"
		)
		_assert(
			(
				"ひからび草" in String(log_ui.get("detail", ""))
				and "手当て" in String(log_ui.get("detail", ""))
			),
			"log section should retain purchase and restoration history"
		)

	_finish(app)


func _finish(app) -> void:
	if app != null:
		app.free()

	if _failures.is_empty():
		print("app root facility interaction smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _find_inventory_quantity(entries: Array, item_id: String) -> int:
	for entry_variant in entries:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant
		if String(entry.get("item_id", "")) == item_id:
			return int(entry.get("quantity", 0))
	return 0
