extends SceneTree

const AppScene = preload("res://scenes/main/app_root.tscn")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_system = root.get_node_or_null("/root/SaveSystem")
	var save_root := "/tmp/project_retro_field_transition_%s" % Time.get_ticks_usec()
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

	app.debug_set_gate_state_for_test(
		"GATE-001",
		{
			"revealed": true,
			"listening": true,
			"awakened": true,
			"first_cross_complete": false,
		}
	)
	await process_frame

	var threshold_tile: Dictionary = field.debug_get_point_tile("tower_threshold")
	field.set_player_tile(Vector2i(int(threshold_tile.get("x", 0)), int(threshold_tile.get("y", 0)) + 1))
	field.set_facing(Vector2i.UP)
	field.interact()
	await process_frame

	var gate_arrival: Dictionary = field.debug_get_point_tile("gate_arrival")
	var field_state: Dictionary = field.get_state_snapshot()
	_assert(
		String(field_state.get("field_id", "")) == "FIELD-W01-001",
		"first crossing should move into FIELD-W01-001"
	)
	_assert(
		field_state.get("player_tile", {}).get("x", -1) == gate_arrival.get("x", -2),
		"first crossing should land on gate_arrival x"
	)
	_assert(
		field_state.get("player_tile", {}).get("y", -1) == gate_arrival.get("y", -2),
		"first crossing should land on gate_arrival y"
	)
	_assert(
		"向こう側の風" in String(field_state.get("last_message", ""))
		or "越境" in String(field_state.get("last_message", "")),
		"transition should surface arrival text"
	)

	var autosave_payload: Dictionary = save_system.load_autosave() if save_system != null else {}
	var player: Dictionary = Dictionary(autosave_payload.get("player", {}))
	var worlds: Dictionary = Dictionary(autosave_payload.get("worlds", {}))
	var first_gate: Dictionary = Dictionary(autosave_payload.get("gates", {})).get("GATE-001", {})
	_assert(
		String(player.get("current_field_id", "")) == "FIELD-W01-001",
		"autosave should store the beyond-gate field as current_field_id"
	)
	_assert(worlds.has("FIELD-VIL-001"), "autosave should retain the village field snapshot")
	_assert(worlds.has("FIELD-W01-001"), "autosave should retain the beyond-gate field snapshot")
	_assert(
		bool(first_gate.get("first_cross_complete", false)),
		"first crossing should mark the gate as crossed"
	)

	app.free()

	var reloaded = AppScene.instantiate()
	root.add_child(reloaded)
	await process_frame

	var reloaded_field = reloaded.get_node("FieldRoot")
	var reloaded_state: Dictionary = reloaded_field.get_state_snapshot()
	_assert(
		String(reloaded_state.get("field_id", "")) == "FIELD-W01-001",
		"autosave reload should resume in the current field"
	)

	var tower_gate: Dictionary = reloaded_field.debug_get_point_tile("tower_gate")
	reloaded_field.set_player_tile(Vector2i(int(tower_gate.get("x", 0)) + 1, int(tower_gate.get("y", 0))))
	reloaded_field.set_facing(Vector2i.LEFT)
	reloaded_field.interact()
	await process_frame

	var return_tile: Dictionary = reloaded_field.debug_get_point_tile("first_crossing_return")
	var return_state: Dictionary = reloaded_field.get_state_snapshot()
	_assert(
		String(return_state.get("field_id", "")) == "FIELD-VIL-001",
		"return gate should move back into FIELD-VIL-001"
	)
	_assert(
		return_state.get("player_tile", {}).get("x", -1) == return_tile.get("x", -2),
		"return gate should land on first_crossing_return x"
	)
	_assert(
		return_state.get("player_tile", {}).get("y", -1) == return_tile.get("y", -2),
		"return gate should land on first_crossing_return y"
	)

	autosave_payload = save_system.load_autosave() if save_system != null else {}
	player = Dictionary(autosave_payload.get("player", {}))
	_assert(
		String(player.get("current_field_id", "")) == "FIELD-VIL-001",
		"return transition should update autosave current_field_id"
	)

	_finish(reloaded)


func _finish(app) -> void:
	if app != null:
		app.free()

	if _failures.is_empty():
		print("field transition smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
