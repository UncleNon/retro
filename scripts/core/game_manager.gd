# gdlint: disable=max-public-methods
extends Node

const ResourceRegistryScript = preload("res://scripts/data/resource_registry.gd")

const FIRST_GATE_ID := "GATE-001"
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

var boot_count: int = 0
var _repository = ResourceRegistryScript.new()


func _ready() -> void:
	bootstrap()


func bootstrap() -> void:
	boot_count += 1
	_repository.bootstrap()


func get_bootstrap_error() -> String:
	return _repository.get_bootstrap_error()


func get_manifest() -> Dictionary:
	return _repository.get_manifest()


func get_manifest_counts() -> Dictionary:
	return _repository.get_manifest_counts()


func get_table_counts() -> Dictionary:
	return _repository.get_table_counts()


func has_resource(kind: String, resource_id: String) -> bool:
	return _repository.has_resource(kind, resource_id)


func get_resource_path(kind: String, resource_id: String) -> String:
	return _repository.get_resource_path(kind, resource_id)


func list_resource_ids(kind: String) -> Array[String]:
	return _repository.list_resource_ids(kind)


func load_resource_data(kind: String, resource_id: String) -> Resource:
	return _repository.load_resource_data(kind, resource_id)


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
	return get_table_row("gates", gate_id)


func get_clue(clue_id: String) -> Dictionary:
	return get_table_row("clues", clue_id)


func get_world_dependency(scope_id: String) -> Dictionary:
	return get_table_row("world_dependencies", scope_id)


func get_localization_entry(entry_id: String) -> Dictionary:
	return get_table_row("localization_registry", entry_id)


func get_asset_registry_entry(asset_id: String) -> Dictionary:
	return get_table_row("asset_registry", asset_id)


func get_master_index_entry(master_id: String) -> Dictionary:
	return get_table_row("master_index", master_id)


func get_field_map(field_id: String) -> Dictionary:
	return _repository.get_field_map(field_id)


func get_field_scene(field_id: String) -> Dictionary:
	return _repository.get_field_scene(field_id)


func list_field_rects(field_id: String) -> Array[Dictionary]:
	return _repository.list_field_rects(field_id)


func list_field_points(field_id: String) -> Array[Dictionary]:
	return _repository.list_field_points(field_id)


func list_field_triggers(field_id: String) -> Array[Dictionary]:
	return _repository.list_field_triggers(field_id)


func list_field_interactions(field_id: String) -> Array[Dictionary]:
	return _repository.list_field_interactions(field_id)


func get_item_text(
	item_id: String, text_kind: String, scope_id: String = "", shop_id: String = ""
) -> Dictionary:
	return _repository.get_item_text(item_id, text_kind, scope_id, shop_id)


func list_item_texts(item_id: String = "", text_kind: String = "") -> Array[Dictionary]:
	return _repository.list_item_texts(item_id, text_kind)


func get_table_row(table_name: String, row_id: String) -> Dictionary:
	return _repository.get_table_row(table_name, row_id)


func get_table_rows(table_name: String) -> Array[Dictionary]:
	return _repository.get_table_rows(table_name)


func normalize_save_payload(payload: Dictionary) -> Dictionary:
	return _repository.normalize_save_payload(payload)


func build_default_gate_state(gate_id: String = "") -> Dictionary:
	return _repository.build_default_gate_state(gate_id)


func build_default_clue_state(clue_id: String = "") -> Dictionary:
	return _repository.build_default_clue_state(clue_id)


func get_default_npc_phase(npc_id: String) -> int:
	return _repository.get_default_npc_phase(npc_id)


func get_npc_phase_limit(npc_id: String) -> int:
	return _repository.get_npc_phase_limit(npc_id)


func count_logged_clues(clue_states: Dictionary) -> int:
	return _repository.count_logged_clues(clue_states)


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


func _normalize_gate_section(raw_gates: Dictionary) -> Dictionary:
	var normalized := {}
	for gate_id_variant in raw_gates.keys():
		var gate_id := String(gate_id_variant)
		if gate_id == "first_crossing_open":
			if (
				bool(raw_gates.get(gate_id_variant, false))
				and not get_gate(FIRST_GATE_ID).is_empty()
			):
				var legacy_state := build_default_gate_state(FIRST_GATE_ID)
				legacy_state["revealed"] = true
				legacy_state["listening"] = true
				legacy_state["awakened"] = true
				normalized[FIRST_GATE_ID] = legacy_state
			continue
		if get_gate(gate_id).is_empty():
			continue
		var state := build_default_gate_state(gate_id)
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
		if get_clue(clue_id).is_empty():
			continue
		var state := build_default_clue_state(clue_id)
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
		var phase_limit := get_npc_phase_limit(npc_id)
		if phase_limit <= 0:
			continue
		var default_phase := get_default_npc_phase(npc_id)
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
	normalized["clues_logged"] = count_logged_clues(Dictionary(payload.get("clues", {})))
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


func _has_true_progress_flag(state: Dictionary) -> bool:
	for value in state.values():
		if bool(value):
			return true
	return false
