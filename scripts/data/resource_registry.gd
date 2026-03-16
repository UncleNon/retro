# gdlint: disable=max-public-methods
class_name ResourceRegistry
extends RefCounted

const DEFAULT_MANIFEST_PATH := "res://data/generated/resource_manifest.json"
const TABLE_DEFINITIONS := {
	"gates":
	{
		"path": "res://data/csv/progress_gate_master.csv",
		"id_column": "gate_id",
	},
	"clues":
	{
		"path": "res://data/csv/clue_master.csv",
		"id_column": "clue_id",
	},
	"world_dependencies":
	{
		"path": "res://data/csv/world_dependency_map.csv",
		"id_column": "scope_id",
	},
	"localization_registry":
	{
		"path": "res://data/csv/localization_registry.csv",
		"id_column": "entry_id",
	},
	"asset_registry":
	{
		"path": "res://data/csv/asset_registry.csv",
		"id_column": "asset_id",
	},
	"master_index":
	{
		"path": "res://data/csv/master_index.csv",
		"id_column": "master_id",
	},
	"field_scenes":
	{
		"path": "res://data/csv/field_scene_master.csv",
		"id_column": "field_id",
	},
	"field_rects":
	{
		"path": "res://data/csv/field_rect_master.csv",
		"id_column": "field_rect_id",
	},
	"field_points":
	{
		"path": "res://data/csv/field_point_master.csv",
		"id_column": "field_point_id",
	},
	"field_triggers":
	{
		"path": "res://data/csv/field_trigger_master.csv",
		"id_column": "field_trigger_id",
	},
	"field_interactions":
	{
		"path": "res://data/csv/field_interaction_master.csv",
		"id_column": "field_interaction_id",
	},
	"item_texts":
	{
		"path": "res://data/csv/item_text_master.csv",
		"id_column": "item_text_id",
	},
}
const RESOURCE_CATEGORIES := [
	"monsters",
	"skills",
	"items",
	"encounters",
	"worlds",
	"breeding",
	"npcs",
	"shops",
	"services",
	"loot_tables",
]
const GATE_STATE_FIELDS := [
	"revealed",
	"listening",
	"awakened",
	"stable",
	"ruptured",
	"first_cross_complete",
]
const CLUE_STATE_FIELDS := [
	"seen",
	"logged",
	"resolved",
]

var _manifest_loaded: bool = false
var _tables_loaded: bool = false
var _manifest: Dictionary = {}
var _resource_cache: Dictionary = {}
var _table_rows := {
	"gates": {},
	"clues": {},
	"world_dependencies": {},
	"localization_registry": {},
	"asset_registry": {},
	"master_index": {},
	"field_scenes": {},
	"field_rects": {},
	"field_points": {},
	"field_triggers": {},
	"field_interactions": {},
	"item_texts": {},
}
var _bootstrap_errors: Array[String] = []
var _manifest_path_override: String = ""
var _table_path_overrides: Dictionary = {}


func _init() -> void:
	for category in RESOURCE_CATEGORIES:
		_resource_cache[category] = {}


func bootstrap() -> void:
	_ensure_manifest()
	_ensure_tables()


func get_bootstrap_error() -> String:
	if _bootstrap_errors.is_empty():
		return ""
	return "\n".join(_bootstrap_errors)


func set_manifest_path_override(path: String) -> void:
	_manifest_path_override = path.strip_edges()
	_reset_bootstrap_state()


func set_table_path_override(table_name: String, path: String) -> void:
	if not TABLE_DEFINITIONS.has(table_name):
		return
	var normalized_path := path.strip_edges()
	if normalized_path.is_empty():
		_table_path_overrides.erase(table_name)
	else:
		_table_path_overrides[table_name] = normalized_path
	_reset_bootstrap_state()


func get_manifest() -> Dictionary:
	_ensure_manifest()
	return _manifest.duplicate(true)


func get_manifest_counts() -> Dictionary:
	_ensure_manifest()
	var counts := {}
	for category in RESOURCE_CATEGORIES:
		var bucket: Dictionary = _manifest.get(category, {})
		counts[category] = bucket.size()
	return counts


func get_table_counts() -> Dictionary:
	_ensure_tables()
	var counts := {}
	for table_name in TABLE_DEFINITIONS.keys():
		var bucket: Dictionary = _table_rows.get(table_name, {})
		counts[table_name] = bucket.size()
	return counts


func has_resource(category: String, resource_id: String) -> bool:
	return not get_resource_path(category, resource_id).is_empty()


func get_resource_path(category: String, resource_id: String) -> String:
	_ensure_manifest()
	var category_manifest: Dictionary = _manifest.get(category, {})
	return String(category_manifest.get(resource_id, ""))


func list_resource_ids(category: String) -> Array[String]:
	_ensure_manifest()
	var category_manifest: Dictionary = _manifest.get(category, {})
	return _sorted_dictionary_keys(category_manifest)


func load_resource_data(category: String, resource_id: String) -> Resource:
	if resource_id.is_empty():
		return null

	var category_cache: Dictionary = _resource_cache.get(category, {})
	if category_cache.has(resource_id):
		return category_cache[resource_id] as Resource

	var resource_path := get_resource_path(category, resource_id)
	if resource_path.is_empty():
		push_error("missing resource path for %s:%s" % [category, resource_id])
		return null

	var resource := load(resource_path)
	if resource == null:
		push_error("failed to load resource: %s" % resource_path)
		return null

	category_cache[resource_id] = resource
	_resource_cache[category] = category_cache
	return resource


func get_monster(monster_id: String) -> Resource:
	return load_resource_data("monsters", monster_id)


func get_skill(skill_id: String) -> Resource:
	return load_resource_data("skills", skill_id)


func get_item(item_id: String) -> Resource:
	return load_resource_data("items", item_id)


func get_world(world_id: String) -> Resource:
	return load_resource_data("worlds", world_id)


func get_encounter_zone(zone_id: String) -> Resource:
	return load_resource_data("encounters", zone_id)


func get_breed_rule(rule_id: String) -> Resource:
	return load_resource_data("breeding", rule_id)


func get_npc(npc_id: String) -> Resource:
	return load_resource_data("npcs", npc_id)


func get_shop(shop_id: String) -> Resource:
	return load_resource_data("shops", shop_id)


func get_service(service_id: String) -> Resource:
	return load_resource_data("services", service_id)


func get_loot_table(loot_table_id: String) -> Resource:
	return load_resource_data("loot_tables", loot_table_id)


func get_gate(gate_id: String) -> Dictionary:
	return _get_table_row("gates", gate_id)


func get_clue(clue_id: String) -> Dictionary:
	return _get_table_row("clues", clue_id)


func get_world_dependency(scope_id: String) -> Dictionary:
	return _get_table_row("world_dependencies", scope_id)


func get_localization_entry(entry_id: String) -> Dictionary:
	return _get_table_row("localization_registry", entry_id)


func get_asset_registry_entry(asset_id: String) -> Dictionary:
	return _get_table_row("asset_registry", asset_id)


func get_master_index_entry(master_id: String) -> Dictionary:
	return _get_table_row("master_index", master_id)


func get_field_map(field_id: String) -> Dictionary:
	return _get_table_row("field_scenes", field_id)


func get_field_scene(field_id: String) -> Dictionary:
	return _get_table_row("field_scenes", field_id)


func list_field_rects(field_id: String) -> Array[Dictionary]:
	return _filter_rows_by_value("field_rects", "field_id", field_id)


func list_field_points(field_id: String) -> Array[Dictionary]:
	return _filter_rows_by_value("field_points", "field_id", field_id)


func list_field_triggers(field_id: String) -> Array[Dictionary]:
	return _filter_rows_by_value("field_triggers", "field_id", field_id)


func list_field_interactions(field_id: String) -> Array[Dictionary]:
	return _filter_rows_by_value("field_interactions", "field_id", field_id)


func get_item_text(
	item_id: String, text_kind: String, scope_id: String = "", shop_id: String = ""
) -> Dictionary:
	var best_match := {}
	var best_score := -1
	var best_priority := 999999
	for row in get_table_rows("item_texts"):
		if String(row.get("item_id", "")) != item_id:
			continue
		if String(row.get("text_kind", "")) != text_kind:
			continue
		var match_score := _score_item_text_match(row, scope_id, shop_id)
		if match_score < 0:
			continue
		var priority := int(row.get("priority", 999999))
		if match_score > best_score or (match_score == best_score and priority < best_priority):
			best_match = row
			best_score = match_score
			best_priority = priority
	return best_match


func list_item_texts(item_id: String = "", text_kind: String = "") -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for row in get_table_rows("item_texts"):
		if not item_id.is_empty() and String(row.get("item_id", "")) != item_id:
			continue
		if not text_kind.is_empty() and String(row.get("text_kind", "")) != text_kind:
			continue
		rows.append(row)
	return rows


func get_table_row(table_name: String, row_id: String) -> Dictionary:
	return _get_table_row(table_name, row_id)


func get_table_rows(table_name: String) -> Array[Dictionary]:
	_ensure_tables()
	var rows: Array[Dictionary] = []
	var bucket: Dictionary = _table_rows.get(table_name, {})
	for row_id_variant in bucket.keys():
		var row_id := String(row_id_variant)
		rows.append(Dictionary(bucket.get(row_id_variant, {})).duplicate(true))
	rows.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool: return _sort_table_rows(a, b, table_name)
	)
	return rows


func build_default_gate_state(gate_id: String = "") -> Dictionary:
	return _build_default_gate_state(gate_id)


func build_default_clue_state(clue_id: String = "") -> Dictionary:
	return _build_default_clue_state(clue_id)


func get_default_npc_phase(npc_id: String) -> int:
	return _get_default_npc_phase(npc_id)


func get_npc_phase_limit(npc_id: String) -> int:
	return _get_npc_phase_limit(npc_id)


func count_logged_clues(clue_states: Dictionary) -> int:
	return _count_logged_clues(clue_states)


func normalize_save_payload(payload: Dictionary) -> Dictionary:
	bootstrap()
	if not get_bootstrap_error().is_empty():
		return payload.duplicate(true)

	var normalized := payload.duplicate(true)
	normalized["gates"] = _normalize_gate_section(Dictionary(normalized.get("gates", {})))
	normalized["clues"] = _normalize_clue_section(Dictionary(normalized.get("clues", {})))
	normalized["npcs"] = _normalize_npc_section(Dictionary(normalized.get("npcs", {})))
	normalized["codex"] = _normalize_codex_section(Dictionary(normalized.get("codex", {})))
	normalized["stats"] = _normalize_stats_section(
		Dictionary(normalized.get("stats", {})), normalized
	)
	return normalized


func _build_default_gate_state(_gate_id: String = "") -> Dictionary:
	var state := {}
	for field_name in GATE_STATE_FIELDS:
		state[field_name] = false
	return state


func _build_default_clue_state(_clue_id: String = "") -> Dictionary:
	var state := {}
	for field_name in CLUE_STATE_FIELDS:
		state[field_name] = false
	return state


func _get_default_npc_phase(npc_id: String) -> int:
	var npc = load_resource_data("npcs", npc_id)
	if npc == null:
		return 0
	return 1 if int(npc.phase_count) > 0 else 0


func _get_npc_phase_limit(npc_id: String) -> int:
	var npc = load_resource_data("npcs", npc_id)
	if npc == null:
		return 0
	return maxi(int(npc.phase_count), 0)


func _count_logged_clues(clue_states: Dictionary) -> int:
	var count := 0
	for state_variant in clue_states.values():
		if not state_variant is Dictionary:
			continue
		var state: Dictionary = state_variant
		if bool(state.get("logged", false)):
			count += 1
	return count


func get_zone_monster_names(zone_id: String, limit: int = 3) -> Array[String]:
	var zone = get_encounter_zone(zone_id)
	if zone == null:
		return []

	var seen := {}
	var names: Array[String] = []
	for entry_variant in Array(zone.entries):
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant
		var monster_id := String(entry.get("monster_id", ""))
		if monster_id.is_empty() or seen.has(monster_id):
			continue
		seen[monster_id] = true

		var monster = get_monster(monster_id)
		names.append(monster_id if monster == null else String(monster.get("name_jp")))
		if limit > 0 and names.size() >= limit:
			break

	return names


func _reset_bootstrap_state() -> void:
	_manifest_loaded = false
	_tables_loaded = false
	_manifest = {}
	for category in RESOURCE_CATEGORIES:
		_resource_cache[category] = {}
	for table_name in _table_rows.keys():
		_table_rows[table_name] = {}
	_bootstrap_errors.clear()


func _ensure_manifest() -> void:
	if _manifest_loaded:
		return

	var manifest_path := _get_manifest_path()
	if not FileAccess.file_exists(manifest_path):
		_record_bootstrap_error("missing manifest: %s" % manifest_path)
		_manifest_loaded = true
		return

	var json_text := FileAccess.get_file_as_string(manifest_path)
	if json_text.is_empty():
		_record_bootstrap_error("manifest is empty: %s" % manifest_path)
		_manifest_loaded = true
		return

	var parsed: Variant = JSON.parse_string(json_text)
	if parsed is Dictionary:
		_manifest = parsed
	else:
		_record_bootstrap_error("failed to parse manifest JSON: %s" % manifest_path)
		_manifest = {}

	_manifest_loaded = true
	for category in RESOURCE_CATEGORIES:
		if not _manifest.has(category):
			_record_bootstrap_error("manifest missing category: %s" % category)


func _ensure_tables() -> void:
	if _tables_loaded:
		return

	for table_name in TABLE_DEFINITIONS.keys():
		var definition: Dictionary = TABLE_DEFINITIONS[table_name]
		_table_rows[table_name] = _load_csv_table(
			table_name, _get_table_path(table_name), String(definition.get("id_column", ""))
		)

	_tables_loaded = true


func _load_csv_table(table_name: String, table_path: String, id_column: String) -> Dictionary:
	var rows := {}
	if table_path.is_empty():
		_record_bootstrap_error("missing table path for %s" % table_name)
		return rows
	if not FileAccess.file_exists(table_path):
		_record_bootstrap_error("missing %s table: %s" % [table_name, table_path])
		return rows

	var file := FileAccess.open(table_path, FileAccess.READ)
	if file == null:
		_record_bootstrap_error("failed to open %s table: %s" % [table_name, table_path])
		return rows

	var headers := PackedStringArray()
	var row_index := 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		row_index += 1
		if _row_is_blank(row):
			continue

		if headers.is_empty():
			headers = row
			if not headers.has(id_column):
				_record_bootstrap_error(
					"%s table missing id column %s: %s" % [table_name, id_column, table_path]
				)
				return {}
			continue

		if row.size() < headers.size():
			row.resize(headers.size())

		var row_dict := {}
		for index in range(headers.size()):
			row_dict[String(headers[index])] = String(row[index]).strip_edges()

		var row_id := String(row_dict.get(id_column, ""))
		if row_id.is_empty():
			_record_bootstrap_error("%s row %d is missing %s" % [table_name, row_index, id_column])
			continue
		if rows.has(row_id):
			_record_bootstrap_error("%s duplicate id %s" % [table_name, row_id])
			continue

		rows[row_id] = _normalize_table_row(table_name, row_dict)

	return rows


func _normalize_table_row(table_name: String, row: Dictionary) -> Dictionary:
	var normalized := row.duplicate(true)
	match table_name:
		"gates":
			normalized["required_record_count"] = int(normalized.get("required_record_count", "0"))
		"item_texts":
			normalized["priority"] = int(normalized.get("priority", "0"))
		"asset_registry":
			normalized["edited_by_hand"] = _string_to_bool(
				normalized.get("edited_by_hand", "false")
			)
			normalized["approved"] = _string_to_bool(normalized.get("approved", "false"))
	return normalized


func _normalize_gate_section(raw_gates: Dictionary) -> Dictionary:
	var normalized := {}
	for gate_id_variant in raw_gates.keys():
		var gate_id := String(gate_id_variant)
		if gate_id == "first_crossing_open":
			if (
				bool(raw_gates.get(gate_id_variant, false))
				and _get_table_row("gates", "GATE-001").size() > 0
			):
				var legacy_state := _build_default_gate_state("GATE-001")
				legacy_state["revealed"] = true
				legacy_state["listening"] = true
				legacy_state["awakened"] = true
				normalized["GATE-001"] = legacy_state
			continue
		if _get_table_row("gates", gate_id).is_empty():
			continue
		var state := _build_default_gate_state(gate_id)
		var incoming: Variant = raw_gates.get(gate_id_variant)
		if incoming is Dictionary:
			for field_name in GATE_STATE_FIELDS:
				state[field_name] = bool(incoming.get(field_name, state[field_name]))
		elif incoming is bool:
			var unlocked := bool(incoming)
			state["revealed"] = unlocked
			state["listening"] = unlocked
			state["awakened"] = unlocked
		if _has_true_progress_flag(state):
			normalized[gate_id] = state
	return normalized


func _normalize_clue_section(raw_clues: Dictionary) -> Dictionary:
	var normalized := {}
	for clue_id_variant in raw_clues.keys():
		var clue_id := String(clue_id_variant)
		if _get_table_row("clues", clue_id).is_empty():
			continue
		var state := _build_default_clue_state(clue_id)
		var incoming: Variant = raw_clues.get(clue_id_variant)
		if incoming is Dictionary:
			for field_name in CLUE_STATE_FIELDS:
				state[field_name] = bool(incoming.get(field_name, state[field_name]))
		elif incoming is bool:
			var logged := bool(incoming)
			state["seen"] = logged
			state["logged"] = logged
		if _has_true_progress_flag(state):
			normalized[clue_id] = state
	return normalized


func _normalize_npc_section(raw_npcs: Dictionary) -> Dictionary:
	var normalized := {}
	for npc_id_variant in raw_npcs.keys():
		var npc_id := String(npc_id_variant)
		var phase_limit := _get_npc_phase_limit(npc_id)
		if phase_limit <= 0:
			continue
		var default_phase := _get_default_npc_phase(npc_id)
		var incoming: Variant = raw_npcs.get(npc_id_variant)
		var phase := default_phase
		if incoming is Dictionary:
			phase = int(incoming.get("phase", phase))
		elif incoming is int:
			phase = int(incoming)
		phase = clampi(phase, 0, phase_limit)
		if phase != default_phase or incoming is Dictionary or incoming is int:
			normalized[npc_id] = {"phase": phase}
	return normalized


func _normalize_codex_section(raw_codex: Dictionary) -> Dictionary:
	var normalized := raw_codex.duplicate(true)
	var seen_ids := _sanitize_known_ids(Array(raw_codex.get("seen_ids", [])), "monsters")
	var recruited_ids := _sanitize_known_ids(Array(raw_codex.get("recruited_ids", [])), "monsters")
	var known_recipe_ids := _sanitize_known_ids(
		Array(raw_codex.get("known_recipe_ids", [])), "breeding"
	)
	var resolved_recipe_ids := _sanitize_known_ids(
		Array(raw_codex.get("resolved_recipe_ids", [])), "breeding"
	)

	for monster_id in recruited_ids:
		if not seen_ids.has(monster_id):
			seen_ids.append(monster_id)
	for rule_id in resolved_recipe_ids:
		if not known_recipe_ids.has(rule_id):
			known_recipe_ids.append(rule_id)

	seen_ids.sort()
	recruited_ids.sort()
	known_recipe_ids.sort()
	resolved_recipe_ids.sort()

	normalized["seen_ids"] = seen_ids
	normalized["recruited_ids"] = recruited_ids
	normalized["known_recipe_ids"] = known_recipe_ids
	normalized["resolved_recipe_ids"] = resolved_recipe_ids
	normalized["monster_count_seen"] = seen_ids.size()
	normalized["monster_count_recruited"] = recruited_ids.size()
	normalized["recipe_count_known"] = known_recipe_ids.size()
	normalized["recipe_count_resolved"] = resolved_recipe_ids.size()
	normalized["mutation_count_seen"] = int(normalized.get("mutation_count_seen", 0))
	return normalized


func _normalize_stats_section(raw_stats: Dictionary, payload: Dictionary) -> Dictionary:
	var normalized := raw_stats.duplicate(true)
	for stat_key in [
		"total_battles",
		"total_wins",
		"total_recruits",
		"total_breeds",
		"total_mutations",
		"tower_entries",
		"worlds_cleared",
	]:
		normalized[stat_key] = int(normalized.get(stat_key, 0))
	normalized["clues_logged"] = _count_logged_clues(Dictionary(payload.get("clues", {})))
	return normalized


func _sanitize_known_ids(raw_ids: Array, category: String) -> Array[String]:
	var seen := {}
	var sanitized: Array[String] = []
	for value in raw_ids:
		var resource_id := String(value)
		if resource_id.is_empty() or seen.has(resource_id):
			continue
		if not has_resource(category, resource_id):
			continue
		seen[resource_id] = true
		sanitized.append(resource_id)
	return sanitized


func _get_table_row(table_name: String, row_id: String) -> Dictionary:
	_ensure_tables()
	var bucket: Dictionary = _table_rows.get(table_name, {})
	var row: Dictionary = bucket.get(row_id, {})
	return row.duplicate(true)


func _get_manifest_path() -> String:
	return (
		_manifest_path_override if not _manifest_path_override.is_empty() else DEFAULT_MANIFEST_PATH
	)


func _get_table_path(table_name: String) -> String:
	if _table_path_overrides.has(table_name):
		return String(_table_path_overrides[table_name])
	var definition: Dictionary = TABLE_DEFINITIONS.get(table_name, {})
	return String(definition.get("path", ""))


func _row_is_blank(row: PackedStringArray) -> bool:
	if row.is_empty():
		return true
	for value in row:
		if not String(value).strip_edges().is_empty():
			return false
	return true


func _record_bootstrap_error(message: String) -> void:
	if _bootstrap_errors.has(message):
		return
	_bootstrap_errors.append(message)
	push_error(message)


func _has_true_progress_flag(state: Dictionary) -> bool:
	for value in state.values():
		if bool(value):
			return true
	return false


func _sorted_dictionary_keys(entries: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key in entries.keys():
		keys.append(String(key))
	keys.sort()
	return keys


func _string_to_bool(value: Variant) -> bool:
	var normalized := String(value).strip_edges().to_lower()
	return normalized == "true" or normalized == "1" or normalized == "yes"


func _sort_table_rows(a: Dictionary, b: Dictionary, table_name: String) -> bool:
	match table_name:
		"field_rects":
			var left_layer := int(a.get("draw_layer", 0))
			var right_layer := int(b.get("draw_layer", 0))
			if left_layer != right_layer:
				return left_layer < right_layer
		"field_interactions":
			var left_priority := int(a.get("priority", 0))
			var right_priority := int(b.get("priority", 0))
			if left_priority != right_priority:
				return left_priority < right_priority
		"item_texts":
			var left_text_priority := int(a.get("priority", 0))
			var right_text_priority := int(b.get("priority", 0))
			if left_text_priority != right_text_priority:
				return left_text_priority < right_text_priority
	var definition: Dictionary = TABLE_DEFINITIONS.get(table_name, {})
	var id_column := String(definition.get("id_column", ""))
	if id_column.is_empty():
		return false
	return String(a.get(id_column, "")) < String(b.get(id_column, ""))


func _filter_rows_by_value(
	table_name: String, column_name: String, expected_value: String
) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	for row in get_table_rows(table_name):
		if String(row.get(column_name, "")) == expected_value:
			filtered.append(row)
	return filtered


func _score_item_text_match(row: Dictionary, scope_id: String, shop_id: String) -> int:
	var row_scope_id := String(row.get("scope_id", ""))
	var row_shop_id := String(row.get("shop_id", ""))
	if not row_shop_id.is_empty():
		if row_shop_id != shop_id:
			return -1
	if not row_scope_id.is_empty():
		if row_scope_id != scope_id:
			return -1
	var score := 0
	if not row_scope_id.is_empty():
		score += 10
	if not row_shop_id.is_empty():
		score += 20
	return score
