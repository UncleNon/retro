extends SceneTree

const FieldScene = preload("res://scenes/field/field_root.tscn")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var field = FieldScene.instantiate()
	root.add_child(field)
	await process_frame

	var state: Dictionary = field.get_state_snapshot()
	_assert(state.get("player_tile", {}).get("x", -1) == 16, "player should start at x=16")
	_assert(state.get("player_tile", {}).get("y", -1) == 33, "player should start at y=33")

	for _step in range(6):
		field.move_player(Vector2i.DOWN)
	for _step in range(41):
		field.move_player(Vector2i.RIGHT)

	var tag_message: String = field.interact()
	_assert("家畜札" in tag_message, "tag trace interaction should be reachable from village path")

	for _step in range(12):
		field.move_player(Vector2i.LEFT)
	for _step in range(35):
		field.move_player(Vector2i.UP)

	state = field.get_state_snapshot()
	_assert(bool(state.get("encounter_triggered", false)), "tower approach should trigger encounter guidance")

	var threshold_message: String = field.interact()
	_assert(
		"札" in threshold_message or "溝" in threshold_message,
		"tower threshold should be inspectable after reaching the approach"
	)

	field.free()

	if _failures.is_empty():
		print("field smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
