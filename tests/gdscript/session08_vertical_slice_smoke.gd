extends SceneTree

const AppScene = preload("res://scenes/main/app_root.tscn")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_system = root.get_node_or_null("/root/SaveSystem")
	var save_root := "/tmp/project_retro_session08_%s" % Time.get_ticks_usec()
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

	var tag_tile: Dictionary = field.debug_get_point_tile("tag_trace")
	field.set_player_tile(Vector2i(int(tag_tile.get("x", 0)) - 1, int(tag_tile.get("y", 0))))
	field.set_facing(Vector2i.RIGHT)
	field.interact()
	var encounter_tile: Dictionary = field.debug_get_rect_anchor("rect_encounter")
	field.set_player_tile(Vector2i(int(encounter_tile.get("x", 0)), int(encounter_tile.get("y", 0))))
	await process_frame

	var battle = app.get("_active_battle")
	_assert(battle != null, "tower approach should start a battle")
	if battle == null:
		_finish(app)
		return

	battle.set("_battle_outcome", "victory")
	battle.call("_finish_battle")
	await process_frame

	var runtime_snapshot: Dictionary = app.get_runtime_snapshot()
	var gate_state: Dictionary = Dictionary(runtime_snapshot.get("gates", {})).get("GATE-001", {})
	_assert(bool(gate_state.get("listening", false)), "first gate should start listening after victory")

	var breed_result: Dictionary = app.execute_breed_candidate(0)
	_assert(bool(breed_result.get("accepted", false)), "top breeding candidate should execute")
	_assert(String(breed_result.get("rule_id", "")) == "BRD-0005", "vertical slice should resolve BRD-0005 first")

	var child_data: Dictionary = breed_result.get("child", {})
	_assert(String(child_data.get("monster_id", "")) == "MON-010", "special breed should create MON-010")

	runtime_snapshot = app.get_runtime_snapshot()
	var breeding_snapshot: Dictionary = runtime_snapshot.get("breeding", {})
	_assert(
		"BRD-0005" in Array(runtime_snapshot.get("codex", {}).get("resolved_recipe_ids", [])),
		"codex should retain resolved special recipe ids"
	)
	_assert(Array(breeding_snapshot.get("history", [])).size() >= 1, "breeding history should record the result")

	var all_monsters := Array(runtime_snapshot.get("party", [])) + Array(runtime_snapshot.get("ranch", []))
	var has_child := false
	var has_parent_a := false
	var has_parent_b := false
	for monster_variant in all_monsters:
		if not monster_variant is Dictionary:
			continue
		var monster: Dictionary = monster_variant
		match String(monster.get("monster_id", "")):
			"MON-010":
				has_child = true
			"MON-002":
				has_parent_a = true
			"MON-008":
				has_parent_b = true
	_assert(has_child, "bred child should exist in the roster")
	_assert(not has_parent_a, "MON-002 should be consumed by breeding")
	_assert(not has_parent_b, "MON-008 should be consumed by breeding")

	gate_state = Dictionary(runtime_snapshot.get("gates", {})).get("GATE-001", {})
	_assert(bool(gate_state.get("awakened", false)), "first gate should awaken after MON-010 is bred")

	var threshold_tile: Dictionary = field.debug_get_point_tile("tower_threshold")
	field.set_player_tile(Vector2i(int(threshold_tile.get("x", 0)), int(threshold_tile.get("y", 0)) + 1))
	field.set_facing(Vector2i.UP)
	field.interact()
	await process_frame
	var post_cross_state: Dictionary = field.get_state_snapshot()
	_assert(
		String(post_cross_state.get("field_id", "")) == "FIELD-W01-001",
		"tower threshold should transition into the first beyond-gate field"
	)

	app.free()

	var reloaded = AppScene.instantiate()
	root.add_child(reloaded)
	await process_frame

	var reloaded_snapshot: Dictionary = reloaded.get_runtime_snapshot()
	var reloaded_gate: Dictionary = Dictionary(reloaded_snapshot.get("gates", {})).get("GATE-001", {})
	_assert(bool(reloaded_gate.get("awakened", false)), "gate awakening should persist after reload")
	_assert(
		"BRD-0005" in Array(reloaded_snapshot.get("codex", {}).get("resolved_recipe_ids", [])),
		"resolved recipe ids should persist after reload"
	)

	var reloaded_field = reloaded.get_node("FieldRoot")
	var reloaded_field_state: Dictionary = reloaded_field.get_state_snapshot()
	_assert(
		String(reloaded_field_state.get("field_id", "")) == "FIELD-W01-001",
		"autosave reload should restore the current beyond-gate field"
	)

	_finish(reloaded)


func _finish(app) -> void:
	if app != null:
		app.free()

	if _failures.is_empty():
		print("session08 vertical slice smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
