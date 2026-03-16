# gdlint: disable=max-file-lines
extends Node

const BattleScene = preload("res://scenes/battle/battle_root.tscn")
const BattleRootScript = preload("res://scripts/battle/battle_root.gd")
const MenuScene = preload("res://scenes/menu/menu_root.tscn")
const MonsterCollectionScript = preload("res://scripts/monster/monster_collection.gd")
const InventoryRuntimeScript = preload("res://scripts/item/inventory_runtime.gd")
const RecruitmentServiceScript = preload("res://scripts/monster/recruitment_service.gd")
const BreedingServiceScript = preload("res://scripts/monster/breeding_service.gd")

const FIRST_GATE_ID := "GATE-001"
const DEFAULT_FIELD_ID := "FIELD-VIL-001"
const FIRST_BEYOND_GATE_FIELD_ID := "FIELD-W01-001"
const STARTING_GOLD := 80
const ADVENTURE_LOG_LIMIT := 12

var _active_battle: Node = null
var _menu_root: Node = null
var _menu_open: bool = false
var _monster_collection = MonsterCollectionScript.new()
var _inventory_runtime = InventoryRuntimeScript.new()
var _recruitment_service = RecruitmentServiceScript.new()
var _breeding_service = BreedingServiceScript.new()
var _save_state: Dictionary = {}
var _codex_seen: Dictionary = {}
var _codex_recruited: Dictionary = {}
var _codex_recipe_known: Dictionary = {}
var _codex_recipe_resolved: Dictionary = {}
var _npc_phases: Dictionary = {}
var _adventure_log: Array[Dictionary] = []
var _pending_facility_action: Dictionary = {}
var _menu_message: String = ""

@onready var _field_root: Node = $FieldRoot


func _ready() -> void:
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager != null:
		game_manager.call("bootstrap")
		var bootstrap_error := String(game_manager.call("get_bootstrap_error"))
		if not bootstrap_error.is_empty():
			push_error("content bootstrap failed:\n%s" % bootstrap_error)
			get_tree().quit(1)
			return
	_initialize_runtime_state()
	if _field_root != null and _field_root.has_signal("battle_requested"):
		_field_root.connect("battle_requested", _on_field_battle_requested)
	if _field_root != null and _field_root.has_signal("facility_requested"):
		_field_root.connect("facility_requested", _on_field_facility_requested)
	if _field_root != null and _field_root.has_signal("field_transition_requested"):
		_field_root.connect("field_transition_requested", _on_field_transition_requested)
	_install_menu_root()
	_sync_field_progress()
	_stage_runtime_save(false)


func _unhandled_input(event: InputEvent) -> void:
	if _active_battle != null:
		return
	if _menu_open:
		return
	if event.is_echo() or not event.is_pressed():
		return
	if event.is_action_pressed("ui_cancel"):
		open_menu()


func _on_field_battle_requested(payload: Dictionary) -> void:
	if _active_battle != null:
		return
	if _menu_open:
		close_menu()
	_pending_facility_action = {}
	if _field_root != null and _field_root.has_method("set_input_locked"):
		_field_root.call("set_input_locked", true)

	_active_battle = BattleScene.instantiate()
	add_child(_active_battle)
	_active_battle.connect("battle_finished", _on_battle_finished)

	var encounter_zone_id := String(payload.get("encounter_zone_id", "ZONE-VIL-TOWER"))
	var seed := 1977 + int(_save_state.get("stats", {}).get("total_battles", 0))
	var battle_payload := BattleRootScript.build_encounter_payload(
		_monster_collection.build_battle_party(),
		_inventory_runtime.serialize(),
		encounter_zone_id,
		seed
	)
	battle_payload.merge(payload.duplicate(true), true)
	_active_battle.call("configure", battle_payload)


func _on_field_facility_requested(payload: Dictionary) -> void:
	var result := _resolve_facility_interaction(payload)
	if _field_root != null and _field_root.has_method("apply_facility_result"):
		_field_root.call("apply_facility_result", result)
	if bool(result.get("state_changed", false)):
		_append_adventure_log(
			"facility",
			String(result.get("menu_message", result.get("field_message", ""))),
			{
				"npc_id": String(result.get("npc_id", "")),
				"interaction_kind": String(result.get("interaction_kind", "")),
			}
		)
	if bool(result.get("state_changed", false)):
		_stage_runtime_save(true)
	var menu_message := String(result.get("menu_message", result.get("field_message", "")))
	if not menu_message.is_empty():
		_menu_message = menu_message
	_refresh_menu_snapshot()


func _on_field_transition_requested(payload: Dictionary) -> void:
	if _field_root == null or not _field_root.has_method("load_field"):
		return
	if _active_battle != null:
		return
	if _menu_open:
		close_menu()

	var source_state: Dictionary = _capture_field_state()
	_remember_field_snapshot(source_state)

	var source_field_id := String(
		payload.get("source_field_id", _field_id_from_state(source_state))
	)
	var target_field_id := String(payload.get("target_field_id", DEFAULT_FIELD_ID))
	var target_snapshot: Dictionary = _resolve_saved_field_snapshot(target_field_id)

	if _field_root.has_method("set_input_locked"):
		_field_root.call("set_input_locked", true)
	_field_root.call(
		"load_field",
		target_field_id,
		String(payload.get("target_point_id", "")),
		target_snapshot,
		String(payload.get("target_facing", ""))
	)
	_sync_field_progress()
	if _field_root.has_method("apply_transition_message"):
		_field_root.call("apply_transition_message", String(payload.get("transition_message", "")))
	if _field_root.has_method("set_input_locked"):
		_field_root.call("set_input_locked", false)

	if _mark_first_gate_cross_complete(source_field_id, target_field_id):
		_append_adventure_log(
			"world_transition",
			"塔の最初の門を越え、名伏せの野へ出た",
			{
				"source_field_id": source_field_id,
				"target_field_id": target_field_id,
			}
		)
	_sync_field_progress()
	_stage_runtime_save(true)
	_refresh_menu_snapshot()


func _on_battle_finished(result: Dictionary) -> void:
	var enriched_result := _apply_battle_resolution(result)
	if _field_root != null and _field_root.has_method("apply_battle_result"):
		_field_root.call("apply_battle_result", enriched_result)
	_sync_field_progress()
	if _field_root != null and _field_root.has_method("set_input_locked"):
		_field_root.call("set_input_locked", false)
	_active_battle = null
	_stage_runtime_save(true)
	_refresh_menu_snapshot()


func get_runtime_snapshot() -> Dictionary:
	var breeding_snapshot := _breeding_service.build_menu_snapshot(_monster_collection)
	var field_snapshot: Dictionary = _capture_field_state()
	_sync_recipe_codex()
	return {
		"player":
		{
			"gold": _get_player_gold(),
			"current_field_id": _field_id_from_state(field_snapshot),
		},
		"field": field_snapshot,
		"log":
		{
			"entries": _serialize_adventure_log(),
		},
		"party": _monster_collection.serialize_party(),
		"ranch": _monster_collection.serialize_ranch(),
		"inventory": _inventory_runtime.serialize(),
		"breeding": breeding_snapshot,
		"codex":
		{
			"seen_ids": _sorted_bool_map_keys(_codex_seen),
			"recruited_ids": _sorted_bool_map_keys(_codex_recruited),
			"known_recipe_ids": _sorted_bool_map_keys(_codex_recipe_known),
			"resolved_recipe_ids": _sorted_bool_map_keys(_codex_recipe_resolved),
		},
		"gates": Dictionary(_save_state.get("gates", {})).duplicate(true),
		"clues": _build_logged_clue_snapshot(),
		"clue_states": Dictionary(_save_state.get("clues", {})).duplicate(true),
		"npcs": Dictionary(_save_state.get("npcs", {})).duplicate(true),
		"npc_phases": _npc_phases.duplicate(true),
		"pending_facility": _pending_facility_action.duplicate(true),
		"menu_open": _menu_open,
		"message": _menu_message,
	}


func open_menu() -> void:
	if _menu_root == null or _active_battle != null:
		return
	_menu_open = true
	if _field_root != null and _field_root.has_method("set_input_locked"):
		_field_root.call("set_input_locked", true)
	_refresh_menu_snapshot()
	_menu_root.call("open_menu")


func close_menu() -> void:
	if _menu_root == null:
		return
	_menu_root.call("close_menu")


func move_party_monster_to_ranch(index: int) -> Dictionary:
	var result = _monster_collection.move_party_member_to_ranch(index)
	_finalize_runtime_mutation(result, "party_to_ranch")
	return result


func move_ranch_monster_to_party(index: int) -> Dictionary:
	var result = _monster_collection.move_ranch_member_to_party(index)
	_finalize_runtime_mutation(result, "ranch_to_party")
	return result


func toggle_monster_lock(location: String, index: int) -> Dictionary:
	var result = _monster_collection.toggle_lock(location, index)
	_finalize_runtime_mutation(result, "toggle_lock")
	return result


func execute_breed_candidate(index: int) -> Dictionary:
	var breeding_snapshot: Dictionary = _breeding_service.build_menu_snapshot(_monster_collection)
	var entries := Array(breeding_snapshot.get("entries", []))
	if index < 0 or index >= entries.size():
		var failed_result := {"accepted": false, "reason": "invalid_candidate"}
		_apply_menu_feedback(failed_result)
		_refresh_menu_snapshot()
		return failed_result

	var result := _breeding_service.execute_candidate(_monster_collection, entries[index])
	if bool(result.get("accepted", false)):
		_increment_stat("total_breeds", 1)
		_menu_message = String(result.get("message", "はいごうが かんりょうした"))
		_append_adventure_log(
			"breeding",
			_menu_message,
			{
				"rule_id": String(result.get("rule_id", "")),
				"child_monster_id": String(result.get("child_monster_id", "")),
			}
		)
		_sync_recipe_codex()
		_advance_first_gate_from_breed_result(result)
	else:
		_apply_menu_feedback(result)
	_finalize_runtime_mutation(result, "breeding")
	return result


func debug_apply_battle_result_for_test(result: Dictionary, roll_override: int = -1) -> Dictionary:
	var enriched_result := _apply_battle_resolution(result, roll_override)
	_stage_runtime_save(true)
	_refresh_menu_snapshot()
	return enriched_result


func debug_resolve_facility_for_test(payload: Dictionary) -> Dictionary:
	return _resolve_facility_interaction(payload)


func debug_set_player_gold_for_test(amount: int) -> Dictionary:
	_set_player_gold(maxi(amount, 0))
	_stage_runtime_save(false)
	_refresh_menu_snapshot()
	return get_runtime_snapshot()


func debug_set_party_member_resources_for_test(index: int, hp: int, mp: int) -> Dictionary:
	_monster_collection.set_party_member_resources(index, hp, mp)
	_stage_runtime_save(false)
	_refresh_menu_snapshot()
	return get_runtime_snapshot()


func debug_record_clue_for_test(clue_id: String) -> Dictionary:
	if clue_id.is_empty():
		return get_runtime_snapshot()
	_mark_clue_logged(clue_id)
	_stage_runtime_save(true)
	return get_runtime_snapshot()


func debug_set_gate_state_for_test(gate_id: String, gate_state: Dictionary) -> Dictionary:
	if gate_id.is_empty():
		return get_runtime_snapshot()
	var gates: Dictionary = Dictionary(_save_state.get("gates", {})).duplicate(true)
	gates[gate_id] = _normalize_gate_state(gate_id, gate_state)
	_save_state["gates"] = gates
	_sync_field_progress()
	_stage_runtime_save(true)
	return get_runtime_snapshot()


func debug_set_npc_phase_for_test(npc_id: String, phase: int) -> Dictionary:
	if npc_id.is_empty():
		return get_runtime_snapshot()
	_set_npc_phase(npc_id, phase)
	_stage_runtime_save(true)
	return get_runtime_snapshot()


func _install_menu_root() -> void:
	if _menu_root != null:
		return
	_menu_root = MenuScene.instantiate()
	add_child(_menu_root)
	_menu_root.connect("action_requested", _on_menu_action_requested)
	_menu_root.connect("menu_closed", _on_menu_closed)
	_refresh_menu_snapshot()


func _initialize_runtime_state() -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	var loaded_payload: Dictionary = {}
	if save_system != null:
		save_system.call("bootstrap")
		loaded_payload = save_system.call("load_autosave")
	_save_state = loaded_payload.duplicate(true)
	if _field_root != null and _field_root.has_method("restore_state_snapshot"):
		var player: Dictionary = Dictionary(_save_state.get("player", {}))
		var current_field_id: String = String(player.get("current_field_id", DEFAULT_FIELD_ID))
		var field_snapshot: Dictionary = _resolve_saved_field_snapshot(current_field_id)
		if field_snapshot.is_empty():
			_field_root.call(
				"load_field",
				current_field_id if not current_field_id.is_empty() else DEFAULT_FIELD_ID
			)
		else:
			_field_root.call("restore_state_snapshot", field_snapshot)

	_monster_collection.load_from_save(
		Array(_save_state.get("party", [])), Array(_save_state.get("ranch", []))
	)
	if _monster_collection.is_empty():
		_monster_collection.seed_demo_state()

	_inventory_runtime.load_from_save(Array(_save_state.get("inventory", [])))
	if _inventory_runtime.serialize().is_empty():
		_inventory_runtime.seed_demo_state()

	var codex: Dictionary = _save_state.get("codex", {})
	_codex_seen = _array_to_bool_map(Array(codex.get("seen_ids", [])))
	_codex_recruited = _array_to_bool_map(Array(codex.get("recruited_ids", [])))
	_codex_recipe_known = _array_to_bool_map(Array(codex.get("known_recipe_ids", [])))
	_codex_recipe_resolved = _array_to_bool_map(Array(codex.get("resolved_recipe_ids", [])))
	_mark_owned_monsters_in_codex()
	_npc_phases = _build_npc_phase_map_from_save(_save_state)
	_seed_missing_npc_phases()
	_save_state["npcs"] = _build_npc_state_section()

	var recruit_payload: Dictionary = _save_state.get("recruitment", {})
	_recruitment_service.load_failure_streaks(
		Dictionary(recruit_payload.get("failure_streaks", {}))
	)

	var breeding_payload: Dictionary = _save_state.get("breeding", {})
	_breeding_service.load_from_save(breeding_payload)
	_sync_recipe_codex()
	_ensure_player_state_defaults()
	_load_adventure_log(Array(_save_state.get("adventure_log", [])))


func _apply_battle_resolution(result: Dictionary, roll_override: int = -1) -> Dictionary:
	var enriched_result := result.duplicate(true)
	_monster_collection.sync_party_from_battle(Array(result.get("party", [])))
	_inventory_runtime.sync_from_battle(Array(result.get("inventory", [])))
	_record_seen_monsters(Array(result.get("enemies", [])))
	_record_seen_monsters(Array(result.get("recruit_contexts", [])))
	_update_battle_stats(String(result.get("outcome", "")))

	var recruit_result := _recruitment_service.resolve_victory_recruit(
		result, _monster_collection, roll_override
	)
	if bool(recruit_result.get("attempted", false)) and bool(recruit_result.get("success", false)):
		var storage_result := _monster_collection.add_recruited_monster(
			Dictionary(recruit_result.get("owned_monster", {}))
		)
		recruit_result["storage"] = storage_result
		if bool(storage_result.get("accepted", false)):
			recruit_result["received"] = true
			_record_recruited_monster(String(recruit_result.get("monster_id", "")))
			_increment_stat("total_recruits", 1)
			recruit_result["message"] = "%s が なかまになった" % String(recruit_result.get("name", ""))
			if String(storage_result.get("destination", "")) == "ranch":
				recruit_result["message"] += "。牧場へ まわした"
		else:
			recruit_result["received"] = false
			recruit_result["message"] = (
				"%s は ついてきたが、あずけさきが ない" % String(recruit_result.get("name", ""))
			)
	else:
		recruit_result["received"] = false
		if bool(recruit_result.get("attempted", false)):
			recruit_result["message"] = (
				"%s は %s"
				% [
					String(recruit_result.get("name", "")),
					String(recruit_result.get("reaction", "まだ警戒している"))
				]
			)
	enriched_result["recruit_result"] = recruit_result
	if String(result.get("outcome", "")) == "victory":
		_mark_first_gate_listening()
	var battle_log_text := _battle_outcome_log_text(
		String(result.get("outcome", "")), recruit_result
	)
	if not battle_log_text.is_empty():
		_append_adventure_log(
			"battle",
			battle_log_text,
			{
				"outcome": String(result.get("outcome", "")),
				"encounter_zone_id": String(result.get("encounter_zone_id", "")),
			}
		)
	if not String(recruit_result.get("message", "")).is_empty():
		_append_adventure_log(
			"recruit",
			String(recruit_result.get("message", "")),
			{
				"monster_id": String(recruit_result.get("monster_id", "")),
				"received": bool(recruit_result.get("received", false)),
			}
		)
	_menu_message = String(recruit_result.get("message", ""))
	return enriched_result


func _update_battle_stats(outcome: String) -> void:
	_increment_stat("total_battles", 1)
	if outcome == "victory":
		_increment_stat("total_wins", 1)


func _increment_stat(stat_key: String, delta: int) -> void:
	var stats: Dictionary = _save_state.get("stats", {})
	stats[stat_key] = int(stats.get(stat_key, 0)) + delta
	_save_state["stats"] = stats


func _record_seen_monsters(entries: Array) -> void:
	for entry_variant in entries:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant
		var monster_id := String(entry.get("monster_id", ""))
		if monster_id.is_empty():
			continue
		_codex_seen[monster_id] = true


func _record_recruited_monster(monster_id: String) -> void:
	if monster_id.is_empty():
		return
	_codex_seen[monster_id] = true
	_codex_recruited[monster_id] = true


func _mark_owned_monsters_in_codex() -> void:
	for entry in _monster_collection.serialize_party() + _monster_collection.serialize_ranch():
		var monster_id := String(entry.get("monster_id", ""))
		if monster_id.is_empty():
			continue
		_codex_seen[monster_id] = true
		_codex_recruited[monster_id] = true


func _refresh_menu_snapshot() -> void:
	if _menu_root == null:
		return
	_menu_root.call("set_menu_snapshot", _build_menu_snapshot())


func _build_menu_snapshot() -> Dictionary:
	var game_manager = _get_bootstrapped_game_manager()
	var inventory_payload := _inventory_runtime.build_menu_snapshot()
	var breeding_snapshot := _breeding_service.build_menu_snapshot(_monster_collection)
	_sync_recipe_codex()
	var inventory_entries: Array[Dictionary] = []
	for entry in Array(inventory_payload.get("carry", [])):
		var carry_entry: Dictionary = entry.duplicate(true)
		if String(carry_entry.get("display_name", "")).is_empty():
			carry_entry["display_name"] = String(
				carry_entry.get("name_jp", carry_entry.get("item_id", ""))
			)
		inventory_entries.append(carry_entry)
	for entry in Array(inventory_payload.get("key_items", [])):
		var key_entry: Dictionary = entry.duplicate(true)
		key_entry["display_name"] = (
			"%s [K]" % String(key_entry.get("name_jp", key_entry.get("item_id", "")))
		)
		key_entry["key_item"] = true
		inventory_entries.append(key_entry)
	var party_entries := _build_monster_menu_entries(
		_monster_collection.serialize_party(), game_manager
	)
	var ranch_entries := _build_monster_menu_entries(
		_monster_collection.serialize_ranch(), game_manager
	)

	return {
		"log":
		{
			"entries": _serialize_adventure_log(),
		},
		"party":
		{
			"entries": party_entries,
		},
		"economy":
		{
			"gold": _get_player_gold(),
		},
		"inventory":
		{
			"entries": inventory_entries,
			"carry_used": int(inventory_payload.get("carry_used", 0)),
			"carry_limit": int(inventory_payload.get("carry_limit", 20)),
		},
		"ranch":
		{
			"party": party_entries.duplicate(true),
			"ranch": ranch_entries,
			"summary":
			"P%d / R%d" % [_monster_collection.party_size(), _monster_collection.ranch_size()],
		},
		"breeding": breeding_snapshot,
		"codex":
		{
			"entries": _build_codex_entries(game_manager),
			"seen": _codex_seen.size(),
			"recruited": _codex_recruited.size(),
			"known_recipe_count": _codex_recipe_known.size(),
			"resolved_recipe_count": _codex_recipe_resolved.size(),
		},
		"message": _menu_message,
	}


func _build_monster_menu_entries(entries: Array, game_manager) -> Array[Dictionary]:
	var enriched_entries: Array[Dictionary] = []
	for entry_variant in entries:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = Dictionary(entry_variant).duplicate(true)
		var monster_id := String(entry.get("monster_id", ""))
		if monster_id.is_empty():
			enriched_entries.append(entry)
			continue
		if game_manager != null:
			var monster = game_manager.call("get_monster", monster_id)
			if monster != null:
				var species_name := String(monster.name_jp)
				if species_name.is_empty():
					species_name = monster_id
				entry["name"] = species_name
				entry["species_name"] = species_name
				entry["family"] = String(monster.family)
				entry["rank"] = String(monster.rank)
				entry["notes"] = String(monster.notes)
				entry["battle_role"] = String(monster.battle_role)
		enriched_entries.append(entry)
	return enriched_entries


func _build_codex_entries(game_manager = null) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for monster_id in _sorted_bool_map_keys(_codex_seen):
		var monster_name := monster_id
		var family := ""
		var rank := ""
		var notes := ""
		if game_manager != null:
			var monster = game_manager.call("get_monster", monster_id)
			if monster != null:
				monster_name = String(monster.name_jp)
				if monster_name.is_empty():
					monster_name = monster_id
				family = String(monster.family)
				rank = String(monster.rank)
				notes = String(monster.notes)
		(
			entries
			. append(
				{
					"monster_id": monster_id,
					"name": monster_name,
					"family": family,
					"rank": rank,
					"notes": notes,
					"recruited": _codex_recruited.has(monster_id),
				}
			)
		)
	return entries


func _get_bootstrapped_game_manager():
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager != null:
		game_manager.call("bootstrap")
	return game_manager


func _monster_name(monster_id: String) -> String:
	var game_manager = _get_bootstrapped_game_manager()
	if game_manager == null:
		return monster_id
	var monster = game_manager.call("get_monster", monster_id)
	if monster == null:
		return monster_id
	return String(monster.get("name_jp"))


func _resolve_facility_interaction(payload: Dictionary) -> Dictionary:
	var fallback := {
		"accepted": false,
		"npc_id": String(payload.get("npc_id", "")),
		"mode": "preview",
		"field_message": "誰も応じない。",
		"menu_message": "施設の気配を読めない",
	}
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager == null:
		return fallback
	game_manager.call("bootstrap")

	var npc_id := String(payload.get("npc_id", ""))
	var npc = game_manager.call("get_npc", npc_id)
	if npc == null:
		return fallback

	var npc_name := String(npc.get("name_jp"))
	if npc_name.is_empty():
		npc_name = npc_id
	var result := {
		"accepted": true,
		"npc_id": npc_id,
		"npc_name": npc_name,
		"interaction_kind": String(payload.get("interaction_kind", "")),
		"mode": "preview",
		"action_ready": false,
		"shop_id": "",
		"shop_name": "",
		"service_id": "",
		"service_name": "",
		"service_price": 0,
		"preview_items": [],
		"field_message": "%sがこちらを見る。" % npc_name,
		"menu_message": "%s の気配を確かめた" % npc_name,
	}

	var shop_id := String(npc.get("shop_id"))
	if shop_id.is_empty():
		shop_id = String(payload.get("shop_id", ""))
	var service_id := String(npc.get("service_id"))
	if service_id.is_empty():
		service_id = String(payload.get("service_id", ""))
	var shop = null
	var service = null
	var default_offer: Dictionary = {}
	if not shop_id.is_empty():
		shop = game_manager.call("get_shop", shop_id)
		if shop != null:
			result["shop_id"] = shop_id
			var shop_name := String(shop.get("name_jp"))
			result["shop_name"] = shop_name if not shop_name.is_empty() else shop_id
			result["preview_items"] = _build_shop_preview(shop, game_manager, 3)
			default_offer = _get_default_shop_offer(shop, game_manager)
	if not service_id.is_empty():
		service = game_manager.call("get_service", service_id)
		if service != null:
			result["service_id"] = service_id
			var service_name := String(service.get("name_jp"))
			result["service_name"] = service_name if not service_name.is_empty() else service_id
			result["service_price"] = int(service.get("base_price"))

	var preview_items: Array = Array(result.get("preview_items", []))
	var interaction_kind := String(result.get("interaction_kind", ""))
	var provenance_text := _get_offer_provenance_text(default_offer)
	var bark_text := _get_offer_bark_text(default_offer)
	if interaction_kind == "merchant":
		var preview_text := _join_preview_items(preview_items)
		if preview_text.is_empty():
			preview_text = "いまは棚替え中"
		result["field_message"] = "%sが棚板を軽く叩く。『%s』" % [npc_name, preview_text]
		result["menu_message"] = (
			"%s: %s" % [String(result.get("shop_name", npc_name)), preview_text]
		)
		if not provenance_text.is_empty():
			result["field_message"] = (
				"%s  %s。" % [String(result.get("field_message", "")), provenance_text]
			)
			result["menu_message"] = (
				"%s / %s" % [String(result.get("menu_message", "")), provenance_text]
			)
		if not bark_text.is_empty():
			result["field_message"] = (
				"%s  %s" % [String(result.get("field_message", "")), bark_text]
			)
			result["menu_message"] = (
				"%s / %s" % [String(result.get("menu_message", "")), bark_text]
			)
	elif interaction_kind == "healer":
		var service_label := String(result.get("service_name", "手当て"))
		var service_price := int(result.get("service_price", 0))
		var medicine_text := _join_preview_items(
			preview_items.slice(0, mini(preview_items.size(), 2))
		)
		if not medicine_text.is_empty():
			result["field_message"] = (
				"%sが脈を見て、『%s %dG。薬は %s』と告げる。"
				% [npc_name, service_label, service_price, medicine_text]
			)
			result["menu_message"] = "%s %dG / %s" % [service_label, service_price, medicine_text]
		else:
			result["field_message"] = (
				"%sが脈を見て、『%s %dG』と告げる。" % [npc_name, service_label, service_price]
			)
			result["menu_message"] = "%s %dG" % [service_label, service_price]
		if not provenance_text.is_empty():
			result["field_message"] = (
				"%s  棚には %s。" % [String(result.get("field_message", "")), provenance_text]
			)
			result["menu_message"] = (
				"%s / %s" % [String(result.get("menu_message", "")), provenance_text]
			)
		if not bark_text.is_empty():
			result["field_message"] = (
				"%s  棚には %s。" % [String(result.get("field_message", "")), bark_text]
			)
			result["menu_message"] = (
				"%s / %s" % [String(result.get("menu_message", "")), bark_text]
			)

	var repeated_request := _is_pending_facility_action(result)
	result = _decorate_facility_preview(result, shop, service, game_manager)
	if repeated_request:
		_pending_facility_action = {}
		return _execute_facility_action(result, shop, service, game_manager)

	_arm_facility_action(result)
	return result


func _build_shop_preview(shop, game_manager, limit: int) -> Array[String]:
	var preview: Array[String] = []
	for entry_variant in Array(shop.get("inventory_entries")):
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant
		if String(entry.get("status", "active")) != "active":
			continue
		var item_id := String(entry.get("item_id", ""))
		if item_id.is_empty():
			continue
		var item = game_manager.call("get_item", item_id)
		if item == null:
			continue
		var price := _resolve_shop_entry_price(shop, entry, item)
		var item_name := String(item.get("name_jp"))
		if item_name.is_empty():
			item_name = item_id
		preview.append("%s %dG" % [item_name, price])
		if limit > 0 and preview.size() >= limit:
			break
	return preview


func _resolve_shop_entry_price(shop, entry: Dictionary, item) -> int:
	var override_price = entry.get("price_override", null)
	if override_price != null and int(override_price) > 0:
		return int(override_price)
	var base_price := int(item.get("price"))
	var shop_multiplier := float(shop.get("base_price_multiplier"))
	var entry_multiplier := float(entry.get("price_multiplier", 1.0))
	return maxi(1, int(round(base_price * shop_multiplier * entry_multiplier)))


func _join_preview_items(entries: Array) -> String:
	if entries.is_empty():
		return ""
	return " / ".join(entries)


func _decorate_facility_preview(result: Dictionary, shop, service, game_manager) -> Dictionary:
	var decorated := result.duplicate(true)
	var action_hint := ""
	match String(decorated.get("interaction_kind", "")):
		"merchant":
			var default_offer := _get_default_shop_offer(shop, game_manager)
			if not default_offer.is_empty():
				decorated["action_ready"] = true
				decorated["default_item_id"] = String(default_offer.get("item_id", ""))
				decorated["default_item_name"] = String(default_offer.get("item_name", ""))
				decorated["default_price"] = int(default_offer.get("price", 0))
				action_hint = "もう一度で一番上を買う"
		"healer":
			if service != null:
				decorated["action_ready"] = true
				decorated["default_price"] = int(decorated.get("service_price", 0))
				action_hint = "もう一度で手当てを頼む"
	if not action_hint.is_empty():
		decorated["field_message"] = (
			"%s  %s。" % [String(decorated.get("field_message", "")), action_hint]
		)
		decorated["menu_message"] = (
			"%s / %s" % [String(decorated.get("menu_message", "")), action_hint]
		)
	return decorated


func _arm_facility_action(result: Dictionary) -> void:
	if not bool(result.get("action_ready", false)):
		_pending_facility_action = {}
		return
	_pending_facility_action = {
		"npc_id": String(result.get("npc_id", "")),
		"interaction_kind": String(result.get("interaction_kind", "")),
		"shop_id": String(result.get("shop_id", "")),
		"service_id": String(result.get("service_id", "")),
	}


func _is_pending_facility_action(result: Dictionary) -> bool:
	return (
		String(_pending_facility_action.get("npc_id", "")) == String(result.get("npc_id", ""))
		and (
			String(_pending_facility_action.get("interaction_kind", ""))
			== String(result.get("interaction_kind", ""))
		)
	)


func _execute_facility_action(result: Dictionary, shop, service, game_manager) -> Dictionary:
	match String(result.get("interaction_kind", "")):
		"merchant":
			return _execute_shop_purchase(result, shop, game_manager)
		"healer":
			return _execute_party_restore_service(result, service)
		_:
			var failed := result.duplicate(true)
			failed["accepted"] = false
			failed["mode"] = "execute"
			failed["reason"] = "unsupported_facility_action"
			failed["field_message"] = "いまは何も頼めない。"
			failed["menu_message"] = "施設処理が未接続"
			return failed


func _execute_shop_purchase(result: Dictionary, shop, game_manager) -> Dictionary:
	var offer := _get_default_shop_offer(shop, game_manager)
	var purchase_result := result.duplicate(true)
	purchase_result["mode"] = "execute"
	if offer.is_empty():
		purchase_result["accepted"] = false
		purchase_result["reason"] = "shop_empty"
		purchase_result["field_message"] = "%sは棚を閉じている。" % String(result.get("npc_name", "店番"))
		purchase_result["menu_message"] = "買える物がない"
		return purchase_result

	var item_id := String(offer.get("item_id", ""))
	var item_name := String(offer.get("item_name", item_id))
	var price := int(offer.get("price", 0))
	var gold_before := _get_player_gold()
	purchase_result["item_id"] = item_id
	purchase_result["item_name"] = item_name
	purchase_result["price"] = price
	purchase_result["gold_before"] = gold_before
	if gold_before < price:
		purchase_result["accepted"] = false
		purchase_result["reason"] = "insufficient_gold"
		purchase_result["field_message"] = (
			"%sが首を振る。『%s は %dG。いまの手持ちじゃ足りないよ』"
			% [String(result.get("npc_name", "店番")), item_name, price]
		)
		purchase_result["menu_message"] = "%s %dG / 所持金が足りない" % [item_name, price]
		return purchase_result

	var add_result := _inventory_runtime.add_item(item_id, 1)
	if not bool(add_result.get("accepted", false)):
		purchase_result["accepted"] = false
		purchase_result["reason"] = String(add_result.get("reason", "inventory_rejected"))
		purchase_result["field_message"] = "荷袋がいっぱいで、%s を受け取れない。" % item_name
		purchase_result["menu_message"] = "%s をしまえない" % item_name
		return purchase_result

	_set_player_gold(gold_before - price)
	purchase_result["state_changed"] = true
	purchase_result["inventory_result"] = add_result
	purchase_result["gold_after"] = _get_player_gold()
	purchase_result["field_message"] = (
		"%sが小袋を差し出す。%s を 1つ買った。%dG払った。" % [String(result.get("npc_name", "店番")), item_name, price]
	)
	purchase_result["menu_message"] = (
		"%s を買った -%dG / 残り %dG"
		% [
			item_name,
			price,
			int(purchase_result.get("gold_after", 0)),
		]
	)
	var provenance_text := _get_offer_provenance_text(offer)
	var bark_text := _get_offer_bark_text(offer)
	if not provenance_text.is_empty():
		purchase_result["field_message"] = (
			"%s  %s。" % [String(purchase_result.get("field_message", "")), provenance_text]
		)
		purchase_result["menu_message"] = (
			"%s / %s" % [String(purchase_result.get("menu_message", "")), provenance_text]
		)
	if not bark_text.is_empty():
		purchase_result["field_message"] = (
			"%s  %s" % [String(purchase_result.get("field_message", "")), bark_text]
		)
		purchase_result["menu_message"] = (
			"%s / %s" % [String(purchase_result.get("menu_message", "")), bark_text]
		)
	return purchase_result


func _execute_party_restore_service(result: Dictionary, service) -> Dictionary:
	var restore_result := result.duplicate(true)
	restore_result["mode"] = "execute"
	if service == null:
		restore_result["accepted"] = false
		restore_result["reason"] = "missing_service"
		restore_result["field_message"] = "手当ての段取りが見つからない。"
		restore_result["menu_message"] = "回復 service が未解決"
		return restore_result

	var price := int(result.get("service_price", service.get("base_price")))
	var gold_before := _get_player_gold()
	restore_result["price"] = price
	restore_result["gold_before"] = gold_before
	if gold_before < price:
		restore_result["accepted"] = false
		restore_result["reason"] = "insufficient_gold"
		restore_result["field_message"] = (
			"%sが手を止める。『手当ては %dG。いまは薬代が足りないね』" % [String(result.get("npc_name", "薬師")), price]
		)
		restore_result["menu_message"] = (
			"%s %dG / 所持金が足りない"
			% [
				String(result.get("service_name", "手当て")),
				price,
			]
		)
		return restore_result

	var party_restore := _monster_collection.restore_party_resources()
	if not bool(party_restore.get("accepted", false)):
		restore_result["accepted"] = false
		restore_result["reason"] = String(party_restore.get("reason", "restore_rejected"))
		restore_result["field_message"] = "診る相手がいない。"
		restore_result["menu_message"] = "手当てする仲間がいない"
		return restore_result

	_set_player_gold(gold_before - price)
	restore_result["state_changed"] = true
	restore_result["restore_result"] = party_restore
	restore_result["gold_after"] = _get_player_gold()
	restore_result["field_message"] = (
		"%sが包帯と薬草を手早く回す。連れの息が整った。%dG払った。" % [String(result.get("npc_name", "薬師")), price]
	)
	restore_result["menu_message"] = (
		"%s を頼んだ -%dG / 残り %dG"
		% [
			String(result.get("service_name", "手当て")),
			price,
			int(restore_result.get("gold_after", 0)),
		]
	)
	return restore_result


func _get_default_shop_offer(shop, game_manager) -> Dictionary:
	if shop == null or game_manager == null:
		return {}
	var scope_id := String(shop.scope_id)
	var shop_id := String(shop.shop_id)
	for entry_variant in Array(shop.get("inventory_entries")):
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant
		if String(entry.get("status", "active")) != "active":
			continue
		var item_id := String(entry.get("item_id", ""))
		if item_id.is_empty():
			continue
		var item = game_manager.call("get_item", item_id)
		if item == null:
			continue
		var item_name := String(item.get("name_jp"))
		if item_name.is_empty():
			item_name = item_id
		return {
			"item_id": item_id,
			"item_name": item_name,
			"price": _resolve_shop_entry_price(shop, entry, item),
			"description": String(item.get("description")).strip_edges(),
			"menu_strip": _get_item_text_value(game_manager, item_id, "menu_strip"),
			"shop_voice":
			_get_item_text_value(game_manager, item_id, "shop_voice", scope_id, shop_id),
		}
	return {}


func _get_offer_provenance_text(offer: Dictionary) -> String:
	var menu_strip := _trim_lore_hint(String(offer.get("menu_strip", "")))
	if not menu_strip.is_empty():
		return menu_strip
	return _trim_lore_hint(String(offer.get("description", "")))


func _get_offer_bark_text(offer: Dictionary) -> String:
	var shop_voice := _trim_lore_hint(String(offer.get("shop_voice", "")))
	if not shop_voice.is_empty():
		return shop_voice
	return ""


func _get_item_text_value(
	game_manager, item_id: String, text_kind: String, scope_id: String = "", shop_id: String = ""
) -> String:
	if game_manager == null or item_id.is_empty() or text_kind.is_empty():
		return ""
	var row: Dictionary = game_manager.call("get_item_text", item_id, text_kind, scope_id, shop_id)
	return String(row.get("text_jp", "")).strip_edges()


func _trim_lore_hint(text: String, max_length: int = 26) -> String:
	var normalized_text := text.strip_edges()
	if normalized_text.is_empty():
		return ""
	if normalized_text.length() <= max_length:
		return normalized_text
	return "%s..." % normalized_text.substr(0, max_length - 3)


func _on_menu_action_requested(action: Dictionary) -> void:
	var action_name := String(action.get("action", ""))
	var location := String(action.get("location", ""))
	var index := int(action.get("index", -1))
	var result := {}
	match action_name:
		"move":
			if location == "party":
				result = move_party_monster_to_ranch(index)
			elif location == "ranch":
				result = move_ranch_monster_to_party(index)
		"breed":
			result = execute_breed_candidate(index)
		"toggle_lock":
			result = toggle_monster_lock(location, index)
		_:
			result = {"accepted": true, "reason": "inspect"}
			_menu_message = String(
				action.get("context_message", _describe_entry(Dictionary(action.get("entry", {}))))
			)
	if action_name != "inspect":
		_apply_menu_feedback(result)
	_refresh_menu_snapshot()


func _on_menu_closed() -> void:
	_menu_open = false
	if (
		_active_battle == null
		and _field_root != null
		and _field_root.has_method("set_input_locked")
	):
		_field_root.call("set_input_locked", false)
	_stage_runtime_save(false)
	_refresh_menu_snapshot()


func _apply_menu_feedback(result: Dictionary) -> void:
	if bool(result.get("accepted", false)):
		if not String(result.get("message", "")).is_empty():
			_menu_message = String(result.get("message", ""))
			return
		match String(result.get("destination", "")):
			"ranch":
				_menu_message = "牧場へ あずけた"
			"party":
				_menu_message = "パーティへ くわえた"
			_:
				_menu_message = "へんこうした"
		return
	match String(result.get("reason", "")):
		"ranch_full":
			_menu_message = "牧場が いっぱいだ"
		"party_full":
			_menu_message = "先に だれかを あずける"
		"party_minimum":
			_menu_message = "最後の 1体は あずけられない"
		"party_locked":
			_menu_message = "ロック中の なかまは いれかえられない"
		"parent_locked":
			_menu_message = "ロック中の おやは はいごうできない"
		"lock_limit":
			_menu_message = "ロックは 5体まで"
		"invalid_candidate":
			_menu_message = "はいごう候補が みつからない"
		"same_parent":
			_menu_message = "おなじ個体どうしは はいごうできない"
		"no_rule":
			_menu_message = "いまは つながる気配がない"
		_:
			_menu_message = "そのそうさは できない"


func _describe_entry(entry: Dictionary) -> String:
	if entry.has("monster_id"):
		var plus_text := ""
		if int(entry.get("plus_value", 0)) > 0:
			plus_text = " +%d" % int(entry.get("plus_value", 0))
		return (
			"%s Lv%d%s %s"
			% [
				String(entry.get("nickname", entry.get("name", entry.get("monster_id", "")))),
				int(entry.get("level", 1)),
				plus_text,
				String(entry.get("tactic", "まかせた")),
			]
		)
	if entry.has("item_id"):
		return (
			"%s x%d"
			% [
				String(entry.get("name_jp", entry.get("item_id", ""))),
				int(entry.get("quantity", 0)),
			]
		)
	if entry.has("rule_id"):
		return String(entry.get("preview_text", entry.get("label", "")))
	return String(entry.get("name", entry.get("label", "")))


func _ensure_player_state_defaults() -> void:
	var player: Dictionary = Dictionary(_save_state.get("player", {})).duplicate(true)
	if _save_state.is_empty() or not player.has("gold"):
		player["gold"] = STARTING_GOLD
	if not player.has("current_scene"):
		player["current_scene"] = "res://scenes/main/app_root.tscn"
	if not player.has("current_position"):
		player["current_position"] = {"x": 0, "y": 0}
	if not player.has("current_field_id"):
		player["current_field_id"] = DEFAULT_FIELD_ID
	_save_state["player"] = player


func _get_player_gold() -> int:
	var player: Dictionary = Dictionary(_save_state.get("player", {}))
	return maxi(int(player.get("gold", STARTING_GOLD)), 0)


func _set_player_gold(amount: int) -> void:
	var player: Dictionary = Dictionary(_save_state.get("player", {})).duplicate(true)
	player["gold"] = maxi(amount, 0)
	_save_state["player"] = player


func _append_adventure_log(kind: String, text: String, metadata: Dictionary = {}) -> void:
	var normalized_text := text.strip_edges()
	if normalized_text.is_empty():
		return
	var entry := {
		"kind": kind,
		"text": normalized_text,
	}
	for key_variant in metadata.keys():
		entry[String(key_variant)] = metadata[key_variant]
	_adventure_log.insert(0, entry)
	while _adventure_log.size() > ADVENTURE_LOG_LIMIT:
		_adventure_log.remove_at(_adventure_log.size() - 1)


func _load_adventure_log(entries: Array) -> void:
	_adventure_log.clear()
	for entry_variant in entries:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = Dictionary(entry_variant).duplicate(true)
		var text := String(entry.get("text", "")).strip_edges()
		if text.is_empty():
			continue
		entry["kind"] = String(entry.get("kind", "note"))
		entry["text"] = text
		_adventure_log.append(entry)
	while _adventure_log.size() > ADVENTURE_LOG_LIMIT:
		_adventure_log.remove_at(_adventure_log.size() - 1)


func _serialize_adventure_log() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry in _adventure_log:
		entries.append(entry.duplicate(true))
	return entries


func _battle_outcome_log_text(outcome: String, recruit_result: Dictionary) -> String:
	match outcome:
		"victory":
			if bool(recruit_result.get("received", false)):
				return "遭遇に勝ち、気配を連れ帰った"
			return "遭遇に勝った"
		"escape":
			return "遭遇から引いた"
		"defeat":
			return "遭遇で押し返された"
		_:
			return ""


func _finalize_runtime_mutation(result: Dictionary, _source: String) -> void:
	if bool(result.get("accepted", false)):
		_stage_runtime_save(true)
	_refresh_menu_snapshot()


func _stage_runtime_save(autosave: bool) -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system == null:
		return
	var payload := _build_save_payload()
	save_system.call("stage_runtime_snapshot", payload)
	if autosave:
		save_system.call("save_autosave", payload)


func _build_save_payload() -> Dictionary:
	var payload := _save_state.duplicate(true)
	var player: Dictionary = payload.get("player", {})
	player["current_scene"] = "res://scenes/main/app_root.tscn"
	var field_state: Dictionary = _capture_field_state()
	var current_field_id: String = _field_id_from_state(field_state)
	player["current_field_id"] = current_field_id
	player["current_position"] = Dictionary(field_state.get("player_tile", {"x": 0, "y": 0}))
	payload["player"] = player
	_sync_story_clues_from_field(field_state)
	payload["party"] = _monster_collection.serialize_party()
	payload["ranch"] = _monster_collection.serialize_ranch()
	payload["inventory"] = _inventory_runtime.serialize()

	var codex: Dictionary = payload.get("codex", {})
	codex["monster_count_seen"] = _codex_seen.size()
	codex["monster_count_recruited"] = _codex_recruited.size()
	codex["recipe_count_known"] = _codex_recipe_known.size()
	codex["recipe_count_resolved"] = _codex_recipe_resolved.size()
	codex["seen_ids"] = _sorted_bool_map_keys(_codex_seen)
	codex["recruited_ids"] = _sorted_bool_map_keys(_codex_recruited)
	codex["known_recipe_ids"] = _sorted_bool_map_keys(_codex_recipe_known)
	codex["resolved_recipe_ids"] = _sorted_bool_map_keys(_codex_recipe_resolved)
	payload["codex"] = codex

	var recruitment: Dictionary = payload.get("recruitment", {})
	recruitment["failure_streaks"] = _recruitment_service.serialize_failure_streaks()
	payload["recruitment"] = recruitment

	payload["breeding"] = _breeding_service.serialize_state()
	payload["adventure_log"] = _serialize_adventure_log()
	var worlds: Dictionary = Dictionary(payload.get("worlds", {})).duplicate(true)
	if not field_state.is_empty():
		worlds[current_field_id] = field_state.duplicate(true)
		if current_field_id == DEFAULT_FIELD_ID:
			worlds["starting_village"] = field_state.duplicate(true)
	payload["worlds"] = worlds

	payload["gates"] = Dictionary(_save_state.get("gates", {})).duplicate(true)
	payload["clues"] = Dictionary(_save_state.get("clues", {})).duplicate(true)
	payload["npcs"] = _build_npc_state_section()
	payload["npc_phases"] = _npc_phases.duplicate(true)
	_save_state = payload.duplicate(true)
	return payload


func _sync_recipe_codex() -> void:
	var breeding_state: Dictionary = _breeding_service.serialize_state()
	_codex_recipe_known = _array_to_bool_map(Array(breeding_state.get("known_rule_ids", [])))
	_codex_recipe_resolved = _array_to_bool_map(Array(breeding_state.get("resolved_rule_ids", [])))


func _capture_field_state() -> Dictionary:
	if _field_root == null or not _field_root.has_method("get_state_snapshot"):
		return {}
	return Dictionary(_field_root.call("get_state_snapshot")).duplicate(true)


func _field_id_from_state(field_state: Dictionary) -> String:
	var field_id := String(field_state.get("field_id", ""))
	return field_id if not field_id.is_empty() else DEFAULT_FIELD_ID


func _remember_field_snapshot(field_state: Dictionary) -> void:
	if field_state.is_empty():
		return
	var field_id := _field_id_from_state(field_state)
	var worlds: Dictionary = Dictionary(_save_state.get("worlds", {})).duplicate(true)
	worlds[field_id] = field_state.duplicate(true)
	if field_id == DEFAULT_FIELD_ID:
		worlds["starting_village"] = field_state.duplicate(true)
	_save_state["worlds"] = worlds


func _resolve_saved_field_snapshot(field_id: String) -> Dictionary:
	var normalized_field_id := field_id if not field_id.is_empty() else DEFAULT_FIELD_ID
	var worlds: Dictionary = Dictionary(_save_state.get("worlds", {}))
	var snapshot: Dictionary = Dictionary(worlds.get(normalized_field_id, {})).duplicate(true)
	if snapshot.is_empty() and normalized_field_id == DEFAULT_FIELD_ID:
		snapshot = Dictionary(worlds.get("starting_village", {})).duplicate(true)
	if snapshot.is_empty():
		return {}
	if String(snapshot.get("field_id", "")).is_empty():
		snapshot["field_id"] = normalized_field_id
	return snapshot


func _advance_first_gate_from_breed_result(result: Dictionary) -> void:
	var gates: Dictionary = _save_state.get("gates", {})
	var first_gate := _ensure_first_gate_state(gates)
	if not bool(result.get("accepted", false)):
		_sync_field_progress()
		return
	if not bool(first_gate.get("listening", false)) and not bool(first_gate.get("awakened", false)):
		_sync_field_progress()
		return
	if bool(first_gate.get("awakened", false)):
		_sync_field_progress()
		return

	var child_data: Dictionary = result.get("child", {})
	var child_monster_id := String(child_data.get("monster_id", result.get("child_monster_id", "")))
	if child_monster_id != "MON-010":
		_sync_field_progress()
		return
	var child_name := _monster_name(child_monster_id)
	first_gate["revealed"] = true
	first_gate["listening"] = true
	first_gate["awakened"] = true
	first_gate["first_cross_complete"] = false
	gates[FIRST_GATE_ID] = first_gate
	_save_state["gates"] = gates
	if child_name.is_empty():
		child_name = "新しい子"
	_menu_message += "。%s の血が門にひびき、塔の最初の門が ひらいた" % child_name
	_sync_field_progress()


func _mark_first_gate_cross_complete(source_field_id: String, target_field_id: String) -> bool:
	if source_field_id != DEFAULT_FIELD_ID or target_field_id != FIRST_BEYOND_GATE_FIELD_ID:
		return false
	var gates: Dictionary = _save_state.get("gates", {})
	var first_gate := _ensure_first_gate_state(gates)
	if not bool(first_gate.get("awakened", false)):
		return false
	if bool(first_gate.get("first_cross_complete", false)):
		return false
	first_gate["first_cross_complete"] = true
	gates[FIRST_GATE_ID] = first_gate
	_save_state["gates"] = gates
	return true


func _sync_field_progress() -> void:
	if _field_root == null or not _field_root.has_method("set_vertical_slice_progress"):
		return
	var gates: Dictionary = _save_state.get("gates", {})
	var first_gate := _ensure_first_gate_state(gates)
	(
		_field_root
		. call(
			"set_vertical_slice_progress",
			{
				"first_crossing_open": bool(first_gate.get("awakened", false)),
				"first_gate_listening":
				bool(first_gate.get("listening", false)) or bool(first_gate.get("awakened", false)),
				"total_breeds": int(_save_state.get("stats", {}).get("total_breeds", 0)),
			}
		)
	)


func _mark_first_gate_listening() -> void:
	var gates: Dictionary = _save_state.get("gates", {})
	var first_gate := _ensure_first_gate_state(gates)
	if bool(first_gate.get("listening", false)):
		_sync_field_progress()
		return
	first_gate["revealed"] = true
	first_gate["listening"] = true
	first_gate["awakened"] = bool(first_gate.get("awakened", false))
	first_gate["first_cross_complete"] = bool(first_gate.get("first_cross_complete", false))
	gates[FIRST_GATE_ID] = first_gate
	_save_state["gates"] = gates
	_sync_field_progress()


func _ensure_first_gate_state(gates: Dictionary) -> Dictionary:
	var first_gate: Dictionary = gates.get(FIRST_GATE_ID, {})
	if first_gate.is_empty():
		var game_manager = get_node_or_null("/root/GameManager")
		if game_manager != null and game_manager.has_method("build_default_gate_state"):
			first_gate = game_manager.call("build_default_gate_state", FIRST_GATE_ID)
		else:
			first_gate = {
				"revealed": false,
				"listening": false,
				"awakened": false,
				"stable": false,
				"ruptured": false,
				"first_cross_complete": false,
			}
	return first_gate.duplicate(true)


func _sync_story_clues_from_field(field_state: Dictionary) -> void:
	for clue_id_variant in Array(field_state.get("logged_clue_ids", [])):
		var clue_id := String(clue_id_variant)
		if not clue_id.is_empty():
			_mark_clue_logged(clue_id)


func _build_logged_clue_snapshot() -> Dictionary:
	var snapshot := {}
	var clue_states: Dictionary = Dictionary(_save_state.get("clues", {}))
	for clue_id_variant in clue_states.keys():
		var clue_id := String(clue_id_variant)
		if clue_id.is_empty():
			continue
		var state: Dictionary = Dictionary(clue_states.get(clue_id_variant, {}))
		snapshot[clue_id] = bool(state.get("logged", false))
	return snapshot


func _mark_clue_logged(clue_id: String) -> void:
	if clue_id.is_empty():
		return
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager != null:
		var clue_row: Dictionary = game_manager.call("get_clue", clue_id)
		if clue_row.is_empty():
			return
	var clues: Dictionary = Dictionary(_save_state.get("clues", {})).duplicate(true)
	var clue_state := {
		"seen": true,
		"logged": true,
		"resolved": bool(Dictionary(clues.get(clue_id, {})).get("resolved", false)),
	}
	if clues.get(clue_id, null) is Dictionary:
		var existing_state: Dictionary = clues.get(clue_id, {})
		clue_state["seen"] = bool(existing_state.get("seen", true))
		clue_state["logged"] = true
		clue_state["resolved"] = bool(existing_state.get("resolved", false))
	clues[clue_id] = clue_state
	_save_state["clues"] = clues
	var stats: Dictionary = Dictionary(_save_state.get("stats", {})).duplicate(true)
	var stats_manager = get_node_or_null("/root/GameManager")
	if stats_manager != null and stats_manager.has_method("count_logged_clues"):
		stats["clues_logged"] = int(stats_manager.call("count_logged_clues", clues))
	else:
		stats["clues_logged"] = clues.size()
	_save_state["stats"] = stats


func _normalize_gate_state(gate_id: String, gate_state: Dictionary) -> Dictionary:
	var normalized := _ensure_first_gate_state({}) if gate_id == FIRST_GATE_ID else {}
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("build_default_gate_state"):
		normalized = game_manager.call("build_default_gate_state", gate_id)
	elif normalized.is_empty():
		normalized = {
			"revealed": false,
			"listening": false,
			"awakened": false,
			"stable": false,
			"ruptured": false,
			"first_cross_complete": false,
		}
	for key in gate_state.keys():
		normalized[String(key)] = bool(gate_state[key])
	return normalized


func _build_npc_state_section() -> Dictionary:
	var npc_states := {}
	for npc_id_variant in _npc_phases.keys():
		var npc_id := String(npc_id_variant)
		if npc_id.is_empty():
			continue
		npc_states[npc_id] = {"phase": int(_npc_phases.get(npc_id_variant, 0))}
	return npc_states


func _build_npc_phase_map_from_save(save_payload: Dictionary) -> Dictionary:
	var phases := {}
	var stored_phase_map: Dictionary = Dictionary(save_payload.get("npc_phases", {}))
	for npc_id_variant in stored_phase_map.keys():
		var npc_id := String(npc_id_variant)
		if npc_id.is_empty():
			continue
		phases[npc_id] = int(stored_phase_map.get(npc_id_variant, 0))
	var npc_states: Dictionary = Dictionary(save_payload.get("npcs", {}))
	for npc_id_variant in npc_states.keys():
		var npc_id := String(npc_id_variant)
		if npc_id.is_empty() or phases.has(npc_id):
			continue
		var npc_state: Dictionary = Dictionary(npc_states.get(npc_id_variant, {}))
		phases[npc_id] = int(npc_state.get("phase", 0))
	return phases


func _set_npc_phase(npc_id: String, phase: int) -> void:
	var next_phase := maxi(phase, 0)
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("get_npc_phase_limit"):
		var phase_limit := int(game_manager.call("get_npc_phase_limit", npc_id))
		if phase_limit > 0:
			next_phase = clampi(next_phase, 0, phase_limit)
	_npc_phases[npc_id] = next_phase


func _seed_missing_npc_phases() -> void:
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager == null or not game_manager.has_method("list_resource_ids"):
		return
	for npc_id_variant in game_manager.call("list_resource_ids", "npcs"):
		var npc_id := str(npc_id_variant)
		if npc_id.is_empty() or _npc_phases.has(npc_id):
			continue
		var npc = game_manager.call("get_npc", npc_id)
		if npc == null:
			continue
		var scope_id := String(npc.get("scope_id"))
		if scope_id != "VIL":
			continue
		_npc_phases[npc_id] = 0


func _array_to_bool_map(entries: Array) -> Dictionary:
	var mapped := {}
	for entry in entries:
		var key := String(entry)
		if not key.is_empty():
			mapped[key] = true
	return mapped


func _sorted_bool_map_keys(entries: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key in entries.keys():
		keys.append(String(key))
	keys.sort()
	return keys
