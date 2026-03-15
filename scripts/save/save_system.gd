extends Node

const SAVE_SCHEMA_VERSION := "0.2.0"
const SLOT_COUNT := 3
const SAVE_ROOT := "user://saves"
const INDEX_FILE_NAME := "save_index.json"
const SESSION_LOCK_FILE_NAME := "session.lock.json"
const AUTOSAVE_FILE_NAME := "autosave.save.json"
const RECOVERY_FILE_NAME := "recovery.save.json"

var _save_root_override: String = ""
var _bootstrapped: bool = false
var _dirty_shutdown_detected: bool = false
var _recovery_snapshot_available: bool = false
var _index_cache: Dictionary = {}
var _staged_snapshot: Dictionary = {}


func _ready() -> void:
	bootstrap()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED and not _staged_snapshot.is_empty():
		save_autosave()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		shutdown()


func bootstrap() -> void:
	if _bootstrapped:
		return

	_ensure_save_root()
	_load_index()
	_dirty_shutdown_detected = FileAccess.file_exists(_get_session_lock_path())
	_recovery_snapshot_available = (
		_dirty_shutdown_detected and FileAccess.file_exists(_get_recovery_path())
	)
	if _staged_snapshot.is_empty():
		_staged_snapshot = _create_default_save_data()
	_write_session_lock()
	_bootstrapped = true


func shutdown() -> void:
	if not _bootstrapped:
		return

	_remove_file(_get_session_lock_path())
	_dirty_shutdown_detected = false
	_recovery_snapshot_available = false
	_bootstrapped = false


func set_save_root_override(path: String) -> void:
	_save_root_override = path.strip_edges()
	_bootstrapped = false
	_index_cache = {}
	_dirty_shutdown_detected = false
	_recovery_snapshot_available = false


func _get_save_root() -> String:
	if not _save_root_override.is_empty():
		return _save_root_override
	return SAVE_ROOT


func _get_save_root_absolute() -> String:
	return ProjectSettings.globalize_path(_get_save_root())


func _get_slot_path(slot_id: int) -> String:
	return _join_path(_get_save_root_absolute(), "slot_%02d.save.json" % slot_id)


func _get_autosave_path() -> String:
	return _join_path(_get_save_root_absolute(), AUTOSAVE_FILE_NAME)


func _get_recovery_path() -> String:
	return _join_path(_get_save_root_absolute(), RECOVERY_FILE_NAME)


func _get_session_lock_path() -> String:
	return _join_path(_get_save_root_absolute(), SESSION_LOCK_FILE_NAME)


func _get_index_path() -> String:
	return _join_path(_get_save_root_absolute(), INDEX_FILE_NAME)


func _create_default_save_data() -> Dictionary:
	return {
		"schema_version": SAVE_SCHEMA_VERSION,
		"player":
		{
			"name": "",
			"gold": 0,
			"play_time_seconds": 0,
			"current_scene": "res://scenes/main/app_root.tscn",
			"current_position": {"x": 0, "y": 0},
		},
		"party": [],
		"ranch": [],
		"inventory": [],
		"vault": [],
		"progress":
		{
			"main":
			{
				"act": 1,
				"chapter": 0,
				"story_complete": false,
				"postgame_open": false,
				"true_name_awareness": 0,
				"silence_broken": false,
			},
		},
		"worlds": {},
		"gates": {},
		"npcs": {},
		"clues": {},
		"codex":
		{
			"monster_count_seen": 0,
			"monster_count_recruited": 0,
			"recipe_count_known": 0,
			"recipe_count_resolved": 0,
			"mutation_count_seen": 0,
		},
		"stats":
		{
			"total_battles": 0,
			"total_wins": 0,
			"total_recruits": 0,
			"total_breeds": 0,
			"total_mutations": 0,
			"tower_entries": 0,
			"worlds_cleared": 0,
			"clues_logged": 0,
		},
	}


func stage_runtime_snapshot(save_data: Dictionary) -> void:
	_staged_snapshot = _normalize_save_data(save_data)


func save_manual(slot_id: int, save_data: Dictionary = {}) -> Dictionary:
	bootstrap()
	if slot_id < 1 or slot_id > SLOT_COUNT:
		push_error("invalid slot_id: %s" % slot_id)
		return {}

	var payload := _normalize_save_data(_coalesce_save_data(save_data))
	var envelope := _build_envelope(payload, "manual", slot_id)
	if not _write_json_atomic(_get_slot_path(slot_id), envelope):
		return {}

	_write_recovery_snapshot(envelope)
	_update_index_entry("slot_%02d" % slot_id, envelope)
	return payload


func save_autosave(save_data: Dictionary = {}) -> Dictionary:
	bootstrap()
	var payload := _normalize_save_data(_coalesce_save_data(save_data))
	var envelope := _build_envelope(payload, "autosave", 0)
	if not _write_json_atomic(_get_autosave_path(), envelope):
		return {}

	_write_recovery_snapshot(envelope)
	_update_index_entry("autosave", envelope)
	return payload


func load_manual(slot_id: int) -> Dictionary:
	var envelope := _read_envelope(_get_slot_path(slot_id))
	return envelope.get("payload", {})


func load_autosave() -> Dictionary:
	var envelope := _read_envelope(_get_autosave_path())
	return envelope.get("payload", {})


func load_recovery() -> Dictionary:
	var envelope := _read_envelope(_get_recovery_path())
	return envelope.get("payload", {})


func get_save_index() -> Dictionary:
	bootstrap()
	return _index_cache.duplicate(true)


func has_recovery_snapshot() -> bool:
	bootstrap()
	return _recovery_snapshot_available


func detected_dirty_shutdown() -> bool:
	bootstrap()
	return _dirty_shutdown_detected


func _debug_force_dirty_shutdown_for_test() -> void:
	bootstrap()
	_write_session_lock()
	_dirty_shutdown_detected = true


func _coalesce_save_data(save_data: Dictionary) -> Dictionary:
	if save_data.is_empty():
		return _staged_snapshot.duplicate(true)
	return save_data


func _normalize_save_data(save_data: Dictionary) -> Dictionary:
	var normalized := _create_default_save_data()
	_merge_nested(normalized, save_data)
	normalized["schema_version"] = SAVE_SCHEMA_VERSION
	return normalized


func _merge_nested(base_value: Dictionary, incoming_value: Dictionary) -> void:
	for key in incoming_value.keys():
		var incoming_item: Variant = incoming_value[key]
		if base_value.has(key) and base_value[key] is Dictionary and incoming_item is Dictionary:
			_merge_nested(base_value[key], incoming_item)
		else:
			base_value[key] = incoming_item


func _build_envelope(payload: Dictionary, save_kind: String, slot_id: int) -> Dictionary:
	return {
		"schema_version": SAVE_SCHEMA_VERSION,
		"saved_at_utc": Time.get_datetime_string_from_system(true, true),
		"save_kind": save_kind,
		"slot_id": slot_id,
		"payload": payload,
	}


func _ensure_save_root() -> void:
	var root_path := _get_save_root_absolute()
	var result: int = DirAccess.make_dir_recursive_absolute(root_path)
	if result != OK:
		push_error("failed to create save root: %s" % root_path)


func _load_index() -> void:
	var parsed: Variant = _read_json_file(_get_index_path())
	if parsed is Dictionary and parsed.get("schema_version", "") == SAVE_SCHEMA_VERSION:
		_index_cache = parsed
		return

	_index_cache = {
		"schema_version": SAVE_SCHEMA_VERSION,
		"slots": {},
		"autosave": {},
		"last_save_kind": "",
		"last_saved_at_utc": "",
	}


func _write_recovery_snapshot(envelope: Dictionary) -> void:
	if _write_json_atomic(_get_recovery_path(), envelope):
		_recovery_snapshot_available = true


func _update_index_entry(entry_key: String, envelope: Dictionary) -> void:
	if entry_key == "autosave":
		_index_cache["autosave"] = _metadata_from_envelope(envelope)
	else:
		var slots: Dictionary = _index_cache.get("slots", {})
		slots[entry_key] = _metadata_from_envelope(envelope)
		_index_cache["slots"] = slots

	_index_cache["last_save_kind"] = envelope.get("save_kind", "")
	_index_cache["last_saved_at_utc"] = envelope.get("saved_at_utc", "")
	_write_json_atomic(_get_index_path(), _index_cache)


func _metadata_from_envelope(envelope: Dictionary) -> Dictionary:
	var payload: Dictionary = envelope.get("payload", {})
	var player: Dictionary = payload.get("player", {})
	var stats: Dictionary = payload.get("stats", {})
	return {
		"schema_version": envelope.get("schema_version", SAVE_SCHEMA_VERSION),
		"saved_at_utc": envelope.get("saved_at_utc", ""),
		"save_kind": envelope.get("save_kind", ""),
		"slot_id": envelope.get("slot_id", 0),
		"player_name": player.get("name", ""),
		"current_scene": player.get("current_scene", ""),
		"play_time_seconds": player.get("play_time_seconds", 0),
		"total_battles": stats.get("total_battles", 0),
	}


func _read_envelope(path: String) -> Dictionary:
	var parsed: Variant = _read_json_file(path)
	if parsed is Dictionary:
		var payload: Dictionary = parsed.get("payload", {})
		parsed["payload"] = _normalize_save_data(payload)
		return parsed
	return {}


func _read_json_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("failed to open file for read: %s" % path)
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_error("failed to parse json: %s" % path)
		return {}
	return parsed


func _write_json_atomic(path: String, payload: Dictionary) -> bool:
	var temp_path := "%s.tmp" % path
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("failed to open file for write: %s" % temp_path)
		return false

	file.store_string(JSON.stringify(payload, "\t") + "\n")
	file.flush()
	file = null

	_remove_file(path)
	var rename_result := DirAccess.rename_absolute(temp_path, path)
	if rename_result != OK:
		push_error("failed to move temp save into place: %s" % path)
		return false
	return true


func _write_session_lock() -> void:
	var lock_payload := {
		"schema_version": SAVE_SCHEMA_VERSION,
		"started_at_utc": Time.get_datetime_string_from_system(true, true),
		"save_root": _get_save_root_absolute(),
	}
	_write_json_atomic(_get_session_lock_path(), lock_payload)


func _remove_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _join_path(base_path: String, leaf: String) -> String:
	if base_path.ends_with("/"):
		return "%s%s" % [base_path, leaf]
	return "%s/%s" % [base_path, leaf]
