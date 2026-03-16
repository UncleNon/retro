extends Node2D

signal battle_requested(payload: Dictionary)
signal facility_requested(payload: Dictionary)
signal field_transition_requested(payload: Dictionary)

const LayoutScript = preload("res://scripts/world/field_scene_model.gd")
const DEFAULT_FIELD_ID := "FIELD-VIL-001"

var _layout = null
var _current_field_id: String = DEFAULT_FIELD_ID
var _player_tile: Vector2i = Vector2i.ZERO
var _facing: Vector2i = Vector2i.DOWN
var _message_log: Array[String] = []
var _flags: Dictionary = {}
var _encounter_triggered: bool = false
var _input_locked: bool = false
var _battle_requested_once: bool = false
var _battle_resolved: bool = false
var _first_gate_listening: bool = false
var _first_crossing_open: bool = false
var _last_facility_result: Dictionary = {}

@onready var _map_view: Node2D = $MapView
@onready var _player: Node2D = $Player
@onready var _camera: Camera2D = $Camera2D
@onready var _status_label: Label = %StatusLabel
@onready var _objective_label: Label = %ObjectiveLabel
@onready var _message_label: Label = %MessageLabel


func _ready() -> void:
	load_field(_current_field_id)


func _unhandled_input(event: InputEvent) -> void:
	if _input_locked:
		return
	if event.is_action_pressed("ui_accept"):
		interact()
		return

	if event.is_action_pressed("ui_left"):
		move_player(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		move_player(Vector2i.RIGHT)
	elif event.is_action_pressed("ui_up"):
		move_player(Vector2i.UP)
	elif event.is_action_pressed("ui_down"):
		move_player(Vector2i.DOWN)


func move_player(direction: Vector2i) -> bool:
	_ensure_layout()
	if direction == Vector2i.ZERO or _input_locked:
		return false

	_facing = direction
	var target := _player_tile + direction
	if not _layout.in_bounds(target) or _layout.is_blocked(target):
		_push_message("進めない。")
		_update_ui()
		return false

	_player_tile = target
	_apply_player_position()
	_handle_tile_events()
	_update_ui()
	return true


func interact() -> String:
	_last_facility_result = {}
	var target := _player_tile + _facing
	var message := _resolve_interaction(target)
	if not message.is_empty():
		_push_message(message)
	_update_ui()
	return message


func set_player_tile(tile: Vector2i) -> void:
	_ensure_layout()
	if not _layout.in_bounds(tile):
		return
	_player_tile = tile
	_apply_player_position()
	_handle_tile_events()
	_update_ui()


func set_facing(direction: Vector2i) -> void:
	if direction == Vector2i.ZERO:
		return
	_facing = direction
	_update_ui()


func get_point_tile(point_id: String) -> Vector2i:
	_ensure_layout()
	return _layout.get_point_tile(point_id)


func debug_get_point_tile(point_id: String) -> Dictionary:
	var point_tile := get_point_tile(point_id)
	return {"x": point_tile.x, "y": point_tile.y}


func debug_get_rect_anchor(rect_id: String) -> Dictionary:
	_ensure_layout()
	var rect: Rect2i = _layout.get_rect(rect_id)
	return {"x": rect.position.x, "y": rect.position.y}


func restore_state_snapshot(snapshot: Dictionary) -> void:
	var snapshot_field_id := String(snapshot.get("field_id", _current_field_id))
	load_field(snapshot_field_id, "", snapshot)


func load_field(
	field_id: String,
	entry_point_id: String = "",
	snapshot: Dictionary = {},
	facing_name: String = ""
) -> void:
	_ensure_layout()
	_current_field_id = field_id if not field_id.is_empty() else DEFAULT_FIELD_ID
	_layout = LayoutScript.new(_current_field_id)
	_configure_layout_nodes()
	if snapshot.is_empty():
		_apply_default_field_state()
	else:
		_apply_snapshot_state(snapshot)
	if not entry_point_id.is_empty():
		var entry_tile: Vector2i = _layout.get_point_tile(entry_point_id)
		if _layout.in_bounds(entry_tile):
			_player_tile = entry_tile
	if not facing_name.is_empty():
		_facing = _direction_from_name(facing_name)
	_apply_player_position()
	_update_ui()


func get_state_snapshot() -> Dictionary:
	_ensure_layout()
	return {
		"field_id": _layout.field_id,
		"player_tile": {"x": _player_tile.x, "y": _player_tile.y},
		"facing": {"x": _facing.x, "y": _facing.y},
		"flags": _flags.duplicate(true),
		"encounter_triggered": _encounter_triggered,
		"battle_requested": _battle_requested_once,
		"battle_resolved": _battle_resolved,
		"first_gate_listening": _first_gate_listening,
		"first_crossing_open": _first_crossing_open,
		"logged_clue_ids":
		_layout.get_logged_clue_ids(_flags, _first_gate_listening or _first_crossing_open),
		"last_facility_result": _last_facility_result.duplicate(true),
		"last_message": _message_log[-1] if not _message_log.is_empty() else "",
	}


func get_current_field_id() -> String:
	_ensure_layout()
	return _layout.field_id


func set_input_locked(locked: bool) -> void:
	_input_locked = locked


func apply_facility_result(result: Dictionary) -> void:
	_last_facility_result = result.duplicate(true)
	var message := String(result.get("field_message", result.get("message", "")))
	if not message.is_empty():
		_push_message(message)
	_update_ui()


func apply_transition_message(message: String) -> void:
	if not message.is_empty():
		_push_message(message)
	_update_ui()


func set_vertical_slice_progress(progress: Dictionary) -> void:
	_ensure_layout()
	var previously_listening := _first_gate_listening
	var previously_open := _first_crossing_open
	_first_gate_listening = bool(progress.get("first_gate_listening", _first_gate_listening))
	_first_crossing_open = bool(progress.get("first_crossing_open", false))
	if (
		_first_gate_listening
		and not previously_listening
		and not _layout.gate_listening_message.is_empty()
	):
		_push_message(_layout.gate_listening_message)
	if _first_crossing_open and not previously_open and not _layout.gate_open_message.is_empty():
		_push_message(_layout.gate_open_message)
	_update_ui()


func apply_battle_result(result: Dictionary) -> void:
	_ensure_layout()
	_battle_resolved = true
	var followup: String = _layout.get_battle_followup(String(result.get("outcome", "")))
	if not followup.is_empty():
		_push_message(followup)
	var recruit_result: Dictionary = Dictionary(result.get("recruit_result", {}))
	var recruit_message := String(recruit_result.get("message", ""))
	if not recruit_message.is_empty():
		_push_message(recruit_message)
	_update_ui()


func _apply_player_position() -> void:
	_ensure_layout()
	_player.call("set_tile_position", _player_tile)


func _handle_tile_events() -> void:
	_ensure_layout()
	while true:
		var trigger: Dictionary = _layout.find_matching_trigger(
			_player_tile, _flags, _encounter_triggered
		)
		if trigger.is_empty():
			return
		var once_flag_key := String(trigger.get("once_flag_key", ""))
		if not once_flag_key.is_empty():
			_flags[once_flag_key] = true
			match String(trigger.get("trigger_kind", "")):
				"message":
					var message := String(trigger.get("message_jp", ""))
					if not message.is_empty():
						_push_message(message)
				"encounter":
					_encounter_triggered = true
					var preview_names: Array[String] = []
					var game_manager = get_node_or_null("/root/GameManager")
					if game_manager != null:
						preview_names = game_manager.get_zone_monster_names(
							String(trigger.get("encounter_zone_id", _layout.encounter_zone_id)), 3
						)
					var preview_text := ""
					if not preview_names.is_empty():
						preview_text = " / ".join(preview_names)
					_push_message(_layout.build_trigger_message(trigger, preview_text))
					_request_battle(
						String(trigger.get("encounter_zone_id", _layout.encounter_zone_id)),
						String(trigger.get("encounter_source", "field"))
					)


func _request_battle(encounter_zone_id: String, encounter_source: String) -> void:
	if _battle_requested_once:
		return
	_battle_requested_once = true
	(
		battle_requested
		. emit(
			{
				"encounter_zone_id": encounter_zone_id,
				"encounter_source": encounter_source,
			}
		)
	)


func _resolve_interaction(target: Vector2i) -> String:
	_ensure_layout()
	var interaction: Dictionary = (
		_layout
		. find_matching_interaction(
			target,
			{
				"flags": _flags,
				"encounter_triggered": _encounter_triggered,
				"battle_resolved": _battle_resolved,
				"first_gate_listening": _first_gate_listening,
				"first_crossing_open": _first_crossing_open,
			}
		)
	)
	if interaction.is_empty():
		return _layout.default_interaction_message

	var set_flag_key := String(interaction.get("set_flag_key", ""))
	if not set_flag_key.is_empty():
		_flags[set_flag_key] = true

	var facility_npc_id := String(interaction.get("facility_npc_id", ""))
	var facility_kind := String(interaction.get("facility_kind", ""))
	if not facility_npc_id.is_empty() and not facility_kind.is_empty():
		(
			facility_requested
			. emit(
				{
					"npc_id": facility_npc_id,
					"interaction_kind": facility_kind,
					"source": String(interaction.get("facility_source", "field_facility")),
				}
			)
		)
		return ""

	var target_field_id := String(interaction.get("transition_field_id", ""))
	if not target_field_id.is_empty():
		(
			field_transition_requested
			. emit(
				{
					"source_field_id": _layout.field_id,
					"target_field_id": target_field_id,
					"target_point_id": String(interaction.get("transition_point_id", "")),
					"target_facing": String(interaction.get("transition_facing", "")),
					"transition_message": String(interaction.get("transition_message_jp", "")),
				}
			)
		)
		return ""

	var message := String(interaction.get("message_jp", ""))
	if message.is_empty():
		return _layout.default_interaction_message
	return message


func _push_message(message: String) -> void:
	if message.is_empty():
		return
	_message_log.append(message)
	if _message_log.size() > 3:
		_message_log = _message_log.slice(_message_log.size() - 3, _message_log.size())


func _update_ui() -> void:
	_ensure_layout()
	var objective: String = _layout.get_objective(
		_flags, _encounter_triggered, _battle_resolved, _first_gate_listening, _first_crossing_open
	)
	_status_label.text = (
		"Tile %02d,%02d  Facing %s"
		% [
			_player_tile.x,
			_player_tile.y,
			_direction_name(_facing),
		]
	)
	_objective_label.text = objective
	_message_label.text = "\n".join(_message_log)


func _direction_name(direction: Vector2i) -> String:
	if direction == Vector2i.UP:
		return "N"
	if direction == Vector2i.DOWN:
		return "S"
	if direction == Vector2i.LEFT:
		return "W"
	if direction == Vector2i.RIGHT:
		return "E"
	return "?"


func _ensure_layout() -> void:
	if _layout == null:
		_layout = LayoutScript.new(_current_field_id)


func _configure_layout_nodes() -> void:
	if _map_view != null and _map_view.has_method("configure"):
		_map_view.call("configure", _layout)
	if _player != null and _player.has_method("configure"):
		_player.call("configure", _layout)
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = _layout.map_pixel_size.x
	_camera.limit_bottom = _layout.map_pixel_size.y


func _apply_default_field_state() -> void:
	_player_tile = _layout.start_tile
	_facing = _layout.default_facing
	_flags = _layout.build_initial_flags()
	_encounter_triggered = false
	_input_locked = false
	_battle_requested_once = false
	_battle_resolved = false
	_first_gate_listening = false
	_first_crossing_open = false
	_last_facility_result = {}
	_message_log.clear()
	for message in _layout.intro_messages:
		_push_message(message)


func _apply_snapshot_state(snapshot: Dictionary) -> void:
	_message_log.clear()
	var tile_snapshot: Dictionary = Dictionary(snapshot.get("player_tile", {}))
	var restored_tile := Vector2i(
		int(tile_snapshot.get("x", _layout.start_tile.x)),
		int(tile_snapshot.get("y", _layout.start_tile.y))
	)
	_player_tile = restored_tile if _layout.in_bounds(restored_tile) else _layout.start_tile
	var facing_snapshot: Dictionary = Dictionary(snapshot.get("facing", {}))
	_facing = Vector2i(
		int(facing_snapshot.get("x", _layout.default_facing.x)),
		int(facing_snapshot.get("y", _layout.default_facing.y))
	)
	var restored_flags: Dictionary = _layout.build_initial_flags()
	var snapshot_flags: Dictionary = Dictionary(snapshot.get("flags", {}))
	for flag_name_variant in snapshot_flags.keys():
		var flag_name := String(flag_name_variant)
		restored_flags[flag_name] = bool(snapshot_flags.get(flag_name_variant, false))
	_flags = restored_flags
	_encounter_triggered = bool(snapshot.get("encounter_triggered", false))
	_battle_requested_once = bool(snapshot.get("battle_requested", false))
	_battle_resolved = bool(snapshot.get("battle_resolved", false))
	_first_gate_listening = bool(snapshot.get("first_gate_listening", false))
	_first_crossing_open = bool(snapshot.get("first_crossing_open", false))
	_last_facility_result = Dictionary(snapshot.get("last_facility_result", {})).duplicate(true)


func _direction_from_name(direction_name: String) -> Vector2i:
	match direction_name.strip_edges().to_lower():
		"up":
			return Vector2i.UP
		"down":
			return Vector2i.DOWN
		"left":
			return Vector2i.LEFT
		"right":
			return Vector2i.RIGHT
	return _layout.default_facing if _layout != null else Vector2i.DOWN
