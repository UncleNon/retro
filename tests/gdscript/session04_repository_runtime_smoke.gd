extends SceneTree

const AppScene = preload("res://scenes/main/app_root.tscn")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_system = root.get_node_or_null("/root/SaveSystem")
	var save_root := "/tmp/project_retro_session04_%s" % Time.get_ticks_usec()
	if save_system != null:
		save_system.set_save_root_override(save_root)
		save_system.bootstrap()

	var game_manager = root.get_node_or_null("/root/GameManager")
	if game_manager != null:
		game_manager.bootstrap()

	var app = AppScene.instantiate()
	root.add_child(app)
	await process_frame

	_assert(game_manager != null, "autoload game manager should exist")
	if game_manager != null:
		_assert(game_manager.boot_count > 0, "app boot should trigger repository bootstrap")
		_assert(
			not game_manager.get_table_row("gates", "GATE-001").is_empty(),
			"runtime should expose gate repository lookup"
		)
		_assert(
			not game_manager.get_table_row("clues", "CL-003").is_empty(),
			"runtime should expose clue repository lookup"
		)

	var snapshot: Dictionary = app.get_runtime_snapshot()
	var npc_phases: Dictionary = snapshot.get("npc_phases", {})
	_assert(npc_phases.size() >= 10, "starting arc should seed npc phases from repository")
	_assert(int(npc_phases.get("NPC-VIL-001", -1)) == 0, "known village npc should start at phase 0")

	app.debug_record_clue_for_test("CL-003")
	app.debug_set_gate_state_for_test(
		"GATE-001", {"revealed": true, "listening": true, "awakened": false}
	)
	app.debug_set_npc_phase_for_test("NPC-VIL-001", 2)

	snapshot = app.get_runtime_snapshot()
	_assert(
		bool(Dictionary(snapshot.get("clues", {})).get("CL-003", false)),
		"runtime should record clue progress in save-backed state"
	)
	var gates: Dictionary = snapshot.get("gates", {})
	var gate_state: Dictionary = gates.get("GATE-001", {})
	_assert(bool(gate_state.get("listening", false)), "runtime should persist gate listening state")
	_assert(
		int(Dictionary(snapshot.get("npc_phases", {})).get("NPC-VIL-001", -1)) == 2,
		"runtime should persist npc phase mutations"
	)

	app.free()

	var reloaded = AppScene.instantiate()
	root.add_child(reloaded)
	await process_frame

	var reloaded_snapshot: Dictionary = reloaded.get_runtime_snapshot()
	_assert(
		bool(Dictionary(reloaded_snapshot.get("clues", {})).get("CL-003", false)),
		"autosave reload should preserve clue progress"
	)
	var reloaded_gate_state: Dictionary = Dictionary(reloaded_snapshot.get("gates", {})).get("GATE-001", {})
	_assert(
		bool(reloaded_gate_state.get("listening", false)),
		"autosave reload should preserve gate state"
	)
	_assert(
		int(Dictionary(reloaded_snapshot.get("npc_phases", {})).get("NPC-VIL-001", -1)) == 2,
		"autosave reload should preserve npc phase state"
	)

	_finish(reloaded)


func _finish(app) -> void:
	if app != null:
		app.free()

	if _failures.is_empty():
		print("session04 repository runtime smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
