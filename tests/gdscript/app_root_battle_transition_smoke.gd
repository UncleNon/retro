extends SceneTree

const AppScene = preload("res://scenes/main/app_root.tscn")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_system = root.get_node_or_null("/root/SaveSystem")
	var save_root := "/tmp/project_retro_app_battle_%s" % Time.get_ticks_usec()
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

	_assert(not bool(field.get("_input_locked")), "field input should start unlocked")
	field.emit_signal(
		"battle_requested",
		{
			"encounter_zone_id": "ZONE-VIL-TOWER",
			"encounter_source": "app_root_transition_smoke",
		}
	)
	await process_frame

	var battle = app.get("_active_battle")
	_assert(battle != null, "app root should instantiate battle scene")
	_assert(bool(field.get("_input_locked")), "field input should lock while battle is active")
	if battle == null:
		_finish(app)
		return

	battle.set("_battle_outcome", "victory")
	battle.call("_finish_battle")
	await process_frame

	_assert(app.get("_active_battle") == null, "battle scene should clear after finish")
	_assert(not bool(field.get("_input_locked")), "field input should unlock after battle")

	var field_state: Dictionary = field.get_state_snapshot()
	_assert(bool(field_state.get("battle_resolved", false)), "field should record battle result")
	_assert(
		"しりぞけた" in String(field_state.get("last_message", "")),
		"field should surface post-battle follow-up text"
	)

	_finish(app)


func _finish(app) -> void:
	if app != null:
		app.free()

	if _failures.is_empty():
		print("app root battle transition smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
