class_name StartingVillageLayout
extends RefCounted

const ResourceRegistryScript = preload("res://scripts/data/resource_registry.gd")

const FIELD_ID := "FIELD-VIL-001"
const DEFAULT_INTERACTION_MESSAGE := "調べられるものはない。"
const DIRECTION_BY_NAME := {
	"up": Vector2i.UP,
	"down": Vector2i.DOWN,
	"left": Vector2i.LEFT,
	"right": Vector2i.RIGHT,
}

var field_id: String = FIELD_ID
var tile_size: int = 8
var map_size: Vector2i = Vector2i.ZERO
var map_pixel_size: Vector2i = Vector2i.ZERO
var start_tile: Vector2i = Vector2i.ZERO
var default_facing: Vector2i = Vector2i.DOWN
var tower_center_tile: Vector2i = Vector2i.ZERO
var encounter_zone_id: String = ""
var first_gate_clue_id: String = ""
var intro_messages: Array[String] = []
var default_objective: String = ""
var objective_after_tag_trace: String = ""
var objective_flag_key: String = ""
var objective_after_encounter: String = ""
var objective_after_battle: String = ""
var objective_after_breed_hint: String = ""
var objective_after_gate_open: String = ""
var gate_listening_message: String = ""
var gate_open_message: String = ""
var post_victory_message: String = ""
var post_escape_message: String = ""
var post_defeat_message: String = ""
var default_interaction_message: String = DEFAULT_INTERACTION_MESSAGE

var _rect_rows: Array[Dictionary] = []
var _point_rows: Array[Dictionary] = []
var _trigger_rows: Array[Dictionary] = []
var _interaction_rows: Array[Dictionary] = []
var _rects_by_id: Dictionary = {}
var _points_by_id: Dictionary = {}
var _clue_ids_by_flag: Dictionary = {}


func _init(field_id_override: String = FIELD_ID) -> void:
	field_id = field_id_override
	_load()


func tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * tile_size + tile_size / 2, tile.y * tile_size + tile_size / 2)


func in_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < map_size.x and tile.y < map_size.y


func is_blocked(tile: Vector2i) -> bool:
	for rect_row in _rect_rows:
		var rect: Rect2i = Rect2i(rect_row.get("rect", Rect2i()))
		if bool(rect_row.get("blocked", false)) and rect.has_point(tile):
			return true
	return false


func get_rect(rect_id: String) -> Rect2i:
	var rect_row: Dictionary = Dictionary(_rects_by_id.get(rect_id, {}))
	return Rect2i(rect_row.get("rect", Rect2i()))


func get_point_tile(point_id: String) -> Vector2i:
	var point_row: Dictionary = Dictionary(_points_by_id.get(point_id, {}))
	return Vector2i(point_row.get("tile", Vector2i(-1, -1)))


func get_rect_rows() -> Array[Dictionary]:
	return _rect_rows.duplicate(true)


func get_point_rows() -> Array[Dictionary]:
	return _point_rows.duplicate(true)


func build_initial_flags() -> Dictionary:
	var flags := {}
	for trigger_row in _trigger_rows:
		_register_flag(flags, String(trigger_row.get("once_flag_key", "")))
		_register_flag(flags, String(trigger_row.get("required_flag_key", "")))
	for interaction_row in _interaction_rows:
		_register_flag(flags, String(interaction_row.get("set_flag_key", "")))
		var condition_key := String(interaction_row.get("condition_key", ""))
		if condition_key.begins_with("flag:"):
			_register_flag(flags, condition_key.trim_prefix("flag:"))
	return flags


func find_matching_trigger(
	tile: Vector2i, flags: Dictionary, encounter_triggered: bool
) -> Dictionary:
	for trigger_row in _trigger_rows:
		var rect: Rect2i = get_rect(String(trigger_row.get("rect_id", "")))
		if not rect.has_point(tile):
			continue
		var once_flag_key := String(trigger_row.get("once_flag_key", ""))
		if not once_flag_key.is_empty() and bool(flags.get(once_flag_key, false)):
			continue
		if String(trigger_row.get("trigger_kind", "")) == "encounter" and encounter_triggered:
			continue
		var required_flag_key := String(trigger_row.get("required_flag_key", ""))
		if not required_flag_key.is_empty() and not bool(flags.get(required_flag_key, false)):
			continue
		return trigger_row.duplicate(true)
	return {}


func find_matching_interaction(target: Vector2i, context: Dictionary) -> Dictionary:
	var matches: Array[Dictionary] = []
	for interaction_row in _interaction_rows:
		if not _interaction_subject_matches(interaction_row, target):
			continue
		if not _interaction_condition_matches(interaction_row, context):
			continue
		matches.append(interaction_row.duplicate(true))
	if matches.is_empty():
		return {}
	matches.sort_custom(_sort_interactions)
	return matches[0].duplicate(true)


func get_logged_clue_ids(flags: Dictionary, first_gate_active: bool) -> Array[String]:
	var clue_ids: Array[String] = []
	for flag_key_variant in flags.keys():
		var flag_key := String(flag_key_variant)
		if not bool(flags.get(flag_key_variant, false)):
			continue
		for clue_id_variant in Array(_clue_ids_by_flag.get(flag_key, [])):
			var clue_id := String(clue_id_variant)
			if not clue_id.is_empty() and not clue_ids.has(clue_id):
				clue_ids.append(clue_id)
	if (
		first_gate_active
		and not first_gate_clue_id.is_empty()
		and not clue_ids.has(first_gate_clue_id)
	):
		clue_ids.append(first_gate_clue_id)
	clue_ids.sort()
	return clue_ids


func build_trigger_message(trigger_row: Dictionary, preview_source) -> String:
	var preview_text := ""
	if preview_source is Array:
		var names: Array[String] = []
		for name_variant in preview_source:
			names.append(String(name_variant))
		preview_text = " / ".join(names)
	else:
		preview_text = String(preview_source).strip_edges()
	var message := String(trigger_row.get("message_jp", ""))
	if preview_text.is_empty():
		var fallback := String(trigger_row.get("message_fallback_jp", ""))
		var base_text := fallback if not fallback.is_empty() else message
		return base_text.replace("{monster_preview}", "").strip_edges()
	return message.replace("{monster_preview}", preview_text).strip_edges()


func get_objective(
	flags: Dictionary,
	encounter_triggered: bool,
	battle_resolved: bool,
	first_gate_listening: bool,
	first_crossing_open: bool
) -> String:
	if first_crossing_open and not objective_after_gate_open.is_empty():
		return objective_after_gate_open
	if battle_resolved and first_gate_listening and not objective_after_breed_hint.is_empty():
		return objective_after_breed_hint
	if battle_resolved and not objective_after_battle.is_empty():
		return objective_after_battle
	if encounter_triggered and not objective_after_encounter.is_empty():
		return objective_after_encounter
	if (
		not objective_flag_key.is_empty()
		and bool(flags.get(objective_flag_key, false))
		and not objective_after_tag_trace.is_empty()
	):
		return objective_after_tag_trace
	return default_objective


func get_battle_followup(outcome: String) -> String:
	match outcome:
		"victory":
			return post_victory_message
		"escape":
			return post_escape_message
		"defeat":
			return post_defeat_message
		_:
			return ""


func _load() -> void:
	var source = _get_repository_source()
	var field_scene := _fetch_field_scene(source)
	if field_scene.is_empty():
		push_error("missing field scene row: %s" % field_id)
		return

	_apply_field_scene(field_scene)
	_rect_rows = _normalize_rect_rows(source.call("list_field_rects", field_id))
	_point_rows = _normalize_point_rows(source.call("list_field_points", field_id))
	_trigger_rows = _normalize_trigger_rows(source.call("list_field_triggers", field_id))
	_interaction_rows = _normalize_interaction_rows(
		source.call("list_field_interactions", field_id)
	)
	_index_rect_rows()
	_index_point_rows()
	_build_flag_contracts()


func _apply_field_scene(field_scene: Dictionary) -> void:
	tile_size = _parse_int(field_scene.get("tile_size", 8), 8)
	map_size = Vector2i(
		_parse_int(field_scene.get("map_width", 96), 96),
		_parse_int(field_scene.get("map_height", 64), 64)
	)
	map_pixel_size = map_size * tile_size
	start_tile = Vector2i(
		_parse_int(field_scene.get("start_x", 0), 0), _parse_int(field_scene.get("start_y", 0), 0)
	)
	default_facing = _parse_direction(field_scene.get("default_facing", "down"))
	tower_center_tile = Vector2i(
		_parse_int(field_scene.get("tower_center_x", 0), 0),
		_parse_int(field_scene.get("tower_center_y", 0), 0)
	)
	encounter_zone_id = String(field_scene.get("encounter_zone_id", ""))
	first_gate_clue_id = String(field_scene.get("first_gate_clue_id", ""))
	intro_messages = _collect_intro_messages(field_scene)
	default_objective = String(field_scene.get("default_objective", ""))
	objective_after_tag_trace = String(field_scene.get("objective_after_tag_trace", ""))
	objective_flag_key = String(field_scene.get("objective_flag_key", ""))
	objective_after_encounter = String(field_scene.get("objective_after_encounter", ""))
	objective_after_battle = String(field_scene.get("objective_after_battle", ""))
	objective_after_breed_hint = String(field_scene.get("objective_after_breed_hint", ""))
	objective_after_gate_open = String(field_scene.get("objective_after_gate_open", ""))
	gate_listening_message = String(field_scene.get("gate_listening_message", ""))
	gate_open_message = String(field_scene.get("gate_open_message", ""))
	post_victory_message = String(field_scene.get("post_victory_message", ""))
	post_escape_message = String(field_scene.get("post_escape_message", ""))
	post_defeat_message = String(field_scene.get("post_defeat_message", ""))
	default_interaction_message = String(
		field_scene.get("default_interaction_message", DEFAULT_INTERACTION_MESSAGE)
	)


func _index_rect_rows() -> void:
	_rects_by_id.clear()
	for rect_row in _rect_rows:
		_rects_by_id[String(rect_row.get("rect_id", ""))] = rect_row


func _index_point_rows() -> void:
	_points_by_id.clear()
	for point_row in _point_rows:
		_points_by_id[String(point_row.get("point_id", ""))] = point_row


func _build_flag_contracts() -> void:
	_clue_ids_by_flag.clear()
	for interaction_row in _interaction_rows:
		var flag_key := String(interaction_row.get("set_flag_key", ""))
		if flag_key.is_empty():
			continue
		var clue_ids := _split_ids(
			interaction_row.get("clue_ids", interaction_row.get("clue_id", ""))
		)
		if clue_ids.is_empty():
			continue
		_clue_ids_by_flag[flag_key] = clue_ids


func _get_repository_source():
	var main_loop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var game_manager = main_loop.root.get_node_or_null("GameManager")
		if game_manager != null:
			game_manager.call("bootstrap")
			return game_manager
	var repository = ResourceRegistryScript.new()
	repository.bootstrap()
	return repository


func _fetch_field_scene(source) -> Dictionary:
	if source.has_method("get_field_scene"):
		return Dictionary(source.call("get_field_scene", field_id))
	if source.has_method("get_field_map"):
		return Dictionary(source.call("get_field_map", field_id))
	return Dictionary(source.call("get_table_row", "field_scenes", field_id))


func _normalize_rect_rows(rows_variant) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []
	for row in _filter_field_rows(rows_variant):
		row["x"] = _parse_int(row.get("x", 0), 0)
		row["y"] = _parse_int(row.get("y", 0), 0)
		row["width"] = _parse_int(row.get("width", 0), 0)
		row["height"] = _parse_int(row.get("height", 0), 0)
		row["draw_layer"] = _parse_int(row.get("draw_layer", 0), 0)
		row["blocked"] = _parse_bool(row.get("blocked", false))
		row["rect"] = Rect2i(
			int(row.get("x", 0)),
			int(row.get("y", 0)),
			int(row.get("width", 0)),
			int(row.get("height", 0))
		)
		normalized.append(row)
	normalized.sort_custom(_sort_rect_rows)
	return normalized


func _normalize_point_rows(rows_variant) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []
	for row in _filter_field_rows(rows_variant):
		row["x"] = _parse_int(row.get("x", 0), 0)
		row["y"] = _parse_int(row.get("y", 0), 0)
		row["tile"] = Vector2i(int(row.get("x", 0)), int(row.get("y", 0)))
		normalized.append(row)
	normalized.sort_custom(_sort_point_rows)
	return normalized


func _normalize_trigger_rows(rows_variant) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = _filter_field_rows(rows_variant)
	normalized.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return String(a.get("field_trigger_id", "")) < String(b.get("field_trigger_id", ""))
	)
	return normalized


func _normalize_interaction_rows(rows_variant) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = _filter_field_rows(rows_variant)
	normalized.sort_custom(_sort_interactions)
	return normalized


func _filter_field_rows(rows_variant) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	if not rows_variant is Array:
		return filtered
	for row_variant in rows_variant:
		if not row_variant is Dictionary:
			continue
		var row: Dictionary = Dictionary(row_variant).duplicate(true)
		if String(row.get("field_id", "")) != field_id:
			continue
		filtered.append(row)
	return filtered


func _interaction_subject_matches(row: Dictionary, target: Vector2i) -> bool:
	match String(row.get("subject_kind", "")):
		"point":
			return get_point_tile(String(row.get("subject_id", ""))) == target
		"rect":
			return get_rect(String(row.get("subject_id", ""))).has_point(target)
		_:
			return false


func _interaction_condition_matches(row: Dictionary, context: Dictionary) -> bool:
	var condition_key := String(row.get("condition_key", "")).strip_edges()
	if condition_key.is_empty() or condition_key == "always":
		return true
	var flags: Dictionary = Dictionary(context.get("flags", {}))
	var context_conditions := {
		"encounter_triggered": bool(context.get("encounter_triggered", false)),
		"battle_resolved": bool(context.get("battle_resolved", false)),
		"first_gate_listening": bool(context.get("first_gate_listening", false)),
		"first_crossing_open": bool(context.get("first_crossing_open", false)),
	}
	if context_conditions.has(condition_key):
		return bool(context_conditions.get(condition_key, false))
	if condition_key.begins_with("flag:"):
		return bool(flags.get(condition_key.trim_prefix("flag:"), false))
	if condition_key.begins_with("not_flag:"):
		return not bool(flags.get(condition_key.trim_prefix("not_flag:"), false))
	return false


func _register_flag(flags: Dictionary, flag_key: String) -> void:
	var normalized_key := flag_key.strip_edges()
	if normalized_key.is_empty():
		return
	if not flags.has(normalized_key):
		flags[normalized_key] = false


func _collect_intro_messages(field_scene: Dictionary) -> Array[String]:
	var messages: Array[String] = []
	for key in ["intro_message_1", "intro_message_2"]:
		var message := String(field_scene.get(key, "")).strip_edges()
		if not message.is_empty():
			messages.append(message)
	return messages


func _split_ids(value_variant) -> Array[String]:
	var raw_value := String(value_variant).strip_edges()
	if raw_value.is_empty():
		return []
	var ids: Array[String] = []
	for token in raw_value.split(","):
		var normalized := token.strip_edges()
		if not normalized.is_empty():
			ids.append(normalized)
	return ids


func _parse_direction(value_variant) -> Vector2i:
	var key := String(value_variant).strip_edges().to_lower()
	return Vector2i(DIRECTION_BY_NAME.get(key, Vector2i.DOWN))


func _parse_int(value_variant, fallback: int) -> int:
	if value_variant is int:
		return int(value_variant)
	if value_variant is float:
		return int(round(float(value_variant)))
	var text := String(value_variant).strip_edges()
	if text.is_empty():
		return fallback
	return int(text)


func _parse_bool(value_variant) -> bool:
	if value_variant is bool:
		return bool(value_variant)
	var normalized := String(value_variant).strip_edges().to_lower()
	return normalized in ["1", "true", "yes"]


func _sort_rect_rows(a: Dictionary, b: Dictionary) -> bool:
	var a_layer := int(a.get("draw_layer", 0))
	var b_layer := int(b.get("draw_layer", 0))
	if a_layer != b_layer:
		return a_layer < b_layer
	return String(a.get("field_rect_id", "")) < String(b.get("field_rect_id", ""))


func _sort_point_rows(a: Dictionary, b: Dictionary) -> bool:
	var a_y := int(a.get("y", 0))
	var b_y := int(b.get("y", 0))
	if a_y != b_y:
		return a_y < b_y
	return int(a.get("x", 0)) < int(b.get("x", 0))


func _sort_interactions(a: Dictionary, b: Dictionary) -> bool:
	var a_priority := _parse_int(a.get("priority", 0), 0)
	var b_priority := _parse_int(b.get("priority", 0), 0)
	if a_priority != b_priority:
		return a_priority < b_priority
	return String(a.get("field_interaction_id", "")) < String(b.get("field_interaction_id", ""))
