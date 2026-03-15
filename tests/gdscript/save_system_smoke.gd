extends SceneTree

const SaveSystemScript = preload("res://scripts/save/save_system.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := "/tmp/project_retro_save_smoke_%s" % Time.get_ticks_usec()
	var payload := {
		"player": {
			"name": "Session04",
			"play_time_seconds": 321,
		},
		"stats": {
			"total_battles": 7,
			"total_wins": 6,
		},
	}

	var save_a = SaveSystemScript.new()
	save_a.set_save_root_override(root_path)
	save_a.bootstrap()
	_assert(not save_a.detected_dirty_shutdown(), "fresh bootstrap should not detect dirty shutdown")
	_assert(not save_a.has_recovery_snapshot(), "fresh bootstrap should not have recovery snapshot")

	save_a.stage_runtime_snapshot(payload)
	var manual_result: Dictionary = save_a.save_manual(1, payload)
	var autosave_result: Dictionary = save_a.save_autosave()
	_assert(manual_result.get("player", {}).get("name", "") == "Session04", "manual save should persist payload")
	_assert(autosave_result.get("stats", {}).get("total_battles", 0) == 7, "autosave should use staged payload")
	_assert(save_a.load_manual(1).get("player", {}).get("name", "") == "Session04", "manual load should round-trip")
	_assert(save_a.load_autosave().get("stats", {}).get("total_wins", 0) == 6, "autosave load should round-trip")

	var save_b = SaveSystemScript.new()
	save_b.set_save_root_override(root_path)
	save_b.bootstrap()
	_assert(save_b.detected_dirty_shutdown(), "second bootstrap should detect stale session lock")
	_assert(save_b.has_recovery_snapshot(), "dirty shutdown should expose recovery snapshot")
	_assert(save_b.load_recovery().get("player", {}).get("name", "") == "Session04", "recovery payload should round-trip")
	save_b.shutdown()

	var save_c = SaveSystemScript.new()
	save_c.set_save_root_override(root_path)
	save_c.bootstrap()
	_assert(not save_c.detected_dirty_shutdown(), "clean shutdown should clear session lock")
	save_c.shutdown()
	save_a.free()
	save_b.free()
	save_c.free()

	if _failures.is_empty():
		print("save smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
