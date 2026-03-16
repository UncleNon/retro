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

	var tag_tile: Dictionary = field.debug_get_point_tile("tag_trace")
	field.set_player_tile(Vector2i(int(tag_tile.get("x", 0)) - 1, int(tag_tile.get("y", 0))))
	field.set_facing(Vector2i.RIGHT)

	var tag_message: String = field.interact()
	_assert("家畜札" in tag_message, "tag trace interaction should be reachable from village path")
	state = field.get_state_snapshot()
	_assert(
		"CL-003" in Array(state.get("logged_clue_ids", [])),
		"tag trace interaction should log clue state from field data"
	)
	var tag_repeat_message: String = field.interact()
	_assert(
		"古い穴" in tag_repeat_message or "別の家" in tag_repeat_message,
		"tag trace should expose a repeat variant after the first read"
	)

	var nameplate_tile: Dictionary = field.debug_get_point_tile("nameplate_trace")
	field.set_player_tile(Vector2i(int(nameplate_tile.get("x", 0)), int(nameplate_tile.get("y", 0)) + 1))
	field.set_facing(Vector2i.UP)
	var nameplate_message: String = field.interact()
	_assert(
		"表札" in nameplate_message or "空き家" in nameplate_message,
		"nameplate trace interaction should expose the removed nameplate clue"
	)
	state = field.get_state_snapshot()
	_assert(
		"CL-001" in Array(state.get("logged_clue_ids", [])),
		"nameplate trace interaction should log the removed-nameplate clue"
	)

	var encounter_tile: Dictionary = field.debug_get_rect_anchor("rect_encounter")
	field.set_player_tile(Vector2i(int(encounter_tile.get("x", 0)), int(encounter_tile.get("y", 0))))

	state = field.get_state_snapshot()
	_assert(bool(state.get("encounter_triggered", false)), "tower approach should trigger encounter guidance")
	_assert(
		String(state.get("field_id", "")) == "FIELD-VIL-001",
		"field snapshot should retain canonical field id"
	)

	var threshold_tile: Dictionary = field.debug_get_point_tile("tower_threshold")
	field.set_player_tile(Vector2i(int(threshold_tile.get("x", 0)), int(threshold_tile.get("y", 0)) + 1))
	field.set_facing(Vector2i.UP)
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
