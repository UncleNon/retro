extends SceneTree

const GameManagerScript = preload("res://scripts/core/game_manager.gd")
const ResourceRegistryScript = preload("res://scripts/data/resource_registry.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_manager = GameManagerScript.new()
	game_manager.bootstrap()

	_assert(game_manager.get_bootstrap_error().is_empty(), "game manager should load manifest without errors")
	_assert(game_manager.get_manifest_counts().get("monsters", 0) >= 400, "manifest should expose expanded monster corpus")
	_assert(game_manager.has_resource("skills", "SKL-001"), "starter skill should exist in manifest")
	_assert(game_manager.has_resource("items", "item_heal_dryherb"), "starter item should exist in manifest")
	_assert(game_manager.has_resource("worlds", "W-001"), "first world should exist in manifest")
	_assert(game_manager.has_resource("encounters", "ZONE-VIL-TOWER"), "tower encounter zone should exist in manifest")
	_assert(game_manager.has_resource("npcs", "NPC-W20-016"), "late-game NPC should exist in manifest")
	_assert(game_manager.has_resource("shops", "shop_w20_arena"), "arena facility shop should exist in manifest")
	_assert(game_manager.has_resource("services", "service_w20_arena_entry"), "arena service should exist in manifest")
	_assert(game_manager.has_resource("loot_tables", "loot_monster_tagtsutsuki"), "monster loot table should exist in manifest")
	_assert(game_manager.get_table_counts().get("gates", 0) >= 21, "gate master should be available to repository")
	_assert(game_manager.get_table_counts().get("clues", 0) >= 40, "clue master should be available to repository")
	_assert(game_manager.get_table_counts().get("field_scenes", 0) >= 1, "field scene master should be available to repository")
	_assert(game_manager.get_table_counts().get("field_points", 0) >= 5, "field point master should be available to repository")
	_assert(game_manager.get_table_counts().get("item_texts", 0) >= 10, "item text master should be available to repository")

	var zone = game_manager.get_encounter_zone("ZONE-VIL-TOWER")
	_assert(zone != null, "encounter zone should load")
	if zone != null:
		_assert(zone.bgm_id == "BGM-VILLAGE", "zone should preserve bgm_id from zone master")
		_assert(not zone.is_dungeon, "tower approach should not be flagged as dungeon")
		_assert(zone.entries.size() >= 4, "tower approach should keep encounter entries")

	var monster = game_manager.get_monster("MON-002")
	_assert(monster != null, "monster resource should load from manifest")
	if monster != null:
		_assert(monster.get("name_jp") == "タグツツキ", "monster name should round-trip through generated resource")

	var skill = game_manager.get_skill("SKL-001")
	_assert(skill != null, "skill resource should load from manifest")
	if skill != null:
		_assert(skill.get("name_jp") == "たいあたり", "skill name should round-trip through generated resource")

	var item = game_manager.get_item("item_heal_dryherb")
	_assert(item != null, "item resource should load from manifest")
	if item != null:
		_assert(item.get("name_jp") == "ひからび草", "item name should round-trip through generated resource")

	var world = game_manager.load_resource_data("worlds", "W-001")
	_assert(world != null, "world resource should load from manifest")
	if world != null:
		_assert(world.get("name_jp") == "名伏せの野", "world name should round-trip through generated resource")
		_assert(world.get("gate_condition") == "最初の門", "world should preserve gate condition text")

	var npc = game_manager.get_npc("NPC-W20-016")
	_assert(npc != null, "npc resource should load from manifest")
	if npc != null:
		_assert(npc.shop_id == "shop_w20_arena", "arena NPC should resolve canonical shop id")
		_assert(npc.service_id == "service_w20_arena_entry", "arena NPC should resolve canonical service id")

	var shop = game_manager.get_shop("shop_w20_arena")
	_assert(shop != null, "shop resource should load from manifest")
	if shop != null:
		_assert(shop.shop_type == "tournament_vendor", "arena facility should use tournament_vendor shop type")
		_assert("service_w20_arena_entry" in shop.service_ids, "arena shop should expose arena service")

	var service = game_manager.get_service("service_w20_arena_entry")
	_assert(service != null, "service resource should load from manifest")
	if service != null:
		_assert(service.scope_id == "W-020", "service should preserve scope_id")
		_assert(service.effect_key == "open_arena", "arena service should preserve effect key")

	var loot_table = game_manager.load_resource_data("loot_tables", "loot_monster_tagtsutsuki")
	_assert(loot_table != null, "loot table resource should load from manifest")
	if loot_table != null:
		_assert(loot_table.source_type == "enemy", "monster loot table should preserve source type")
		_assert(loot_table.source_ref == "MON-002", "monster loot table should point at canonical monster id")
		_assert(loot_table.entries.size() > 0, "loot table should keep at least one entry")

	var preview_names = game_manager.get_zone_monster_names("ZONE-VIL-TOWER", 3)
	_assert("タグツツキ" in preview_names, "zone preview should resolve monster names")

	var gate = game_manager.get_table_row("gates", "GATE-001")
	_assert(not gate.is_empty(), "gate row should load from repository")
	if not gate.is_empty():
		_assert(gate.get("world_id", "") == "W-001", "gate row should preserve target world")
		_assert(gate.get("condition_type", "") == "story_flag", "gate row should preserve condition type")

	var clue = game_manager.get_table_row("clues", "CL-003")
	_assert(not clue.is_empty(), "clue row should load from repository")
	if not clue.is_empty():
		_assert(clue.get("origin_scope_id", "") == "VIL", "clue row should preserve origin scope")
		_assert("家畜札" in String(clue.get("summary_jp", "")), "clue row should preserve localized summary")

	var dependency = game_manager.get_table_row("world_dependencies", "W-001")
	_assert(not dependency.is_empty(), "world dependency row should load from repository")
	if not dependency.is_empty():
		_assert(dependency.get("parent_scope_id", "") == "TWR", "dependency row should preserve parent scope")
		_assert(dependency.get("gate_id", "") == "GATE-001", "dependency row should preserve gate linkage")

	var field_scene = game_manager.get_table_row("field_scenes", "FIELD-VIL-001")
	_assert(not field_scene.is_empty(), "field scene row should load from repository")
	if not field_scene.is_empty():
		_assert(field_scene.get("encounter_zone_id", "") == "ZONE-VIL-TOWER", "field scene should preserve encounter linkage")

	var field_point_rows: Array = game_manager.get_table_rows("field_points")
	var found_threshold := false
	for row_variant in field_point_rows:
		if not row_variant is Dictionary:
			continue
		if String(Dictionary(row_variant).get("point_id", "")) == "tower_threshold":
			found_threshold = true
			break
	_assert(found_threshold, "field point table should expose tower threshold point")

	var localization = game_manager.get_table_row("localization_registry", "L10N-003")
	_assert(not localization.is_empty(), "localization registry row should load from repository")
	if not localization.is_empty():
		_assert(localization.get("key", "") == "gate.GATE-001.name", "localization entry should preserve lookup key")

	var asset = game_manager.get_table_row("asset_registry", "BGM-VILLAGE")
	_assert(not asset.is_empty(), "asset registry row should load from repository")
	if not asset.is_empty():
		_assert(asset.get("asset_type", "") == "bgm", "asset registry row should preserve asset type")
		_assert(asset.get("owner_id", "") == "VIL", "asset registry row should preserve owner id")

	var master_index = game_manager.get_table_row("master_index", "MST-001")
	_assert(not master_index.is_empty(), "master index row should load from repository")
	if not master_index.is_empty():
		_assert(master_index.get("file_name", "") == "monster_master.csv", "master index row should preserve file name")

	var generic_item_text = game_manager.get_item_text("item_record_tagcase", "menu_strip")
	_assert(not generic_item_text.is_empty(), "generic item text should resolve from repository")
	if not generic_item_text.is_empty():
		_assert(generic_item_text.get("text_jp", "") == "同寸札の札筒", "menu strip should preserve canonical short text")

	var scoped_item_text = game_manager.get_item_text("item_record_tagcase", "shop_voice", "W-003")
	_assert(not scoped_item_text.is_empty(), "scoped item text should resolve from repository")
	if not scoped_item_text.is_empty():
		_assert(
			"旅の身なら合う箱が要る" in String(scoped_item_text.get("text_jp", "")),
			"shop voice should preserve canonical bark"
		)

	var broken_registry = ResourceRegistryScript.new()
	broken_registry.set_manifest_path_override("/tmp/project_retro_missing_manifest.json")
	broken_registry.bootstrap()
	_assert(
		not broken_registry.get_bootstrap_error().is_empty(),
		"repository should surface bootstrap error when manifest is missing"
	)

	game_manager.free()

	if _failures.is_empty():
		print("resource registry smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
