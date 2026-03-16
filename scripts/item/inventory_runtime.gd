class_name InventoryRuntime
extends RefCounted

const CARRY_LIMIT := 20
const STACK_LIMIT := 99

var _entries: Array[Dictionary] = []


func load_from_save(entries: Array) -> void:
	_entries.clear()
	for entry_variant in entries:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant.duplicate(true)
		entry["quantity"] = clampi(
			int(entry.get("quantity", entry.get("count", 0))), 0, STACK_LIMIT
		)
		if int(entry.get("quantity", 0)) <= 0:
			continue
		_entries.append(entry)


func seed_demo_state() -> void:
	load_from_save(
		[
			{"item_id": "item_heal_dryherb", "quantity": 2},
			{"item_id": "item_buff_ironmeal", "quantity": 1},
			{"item_id": "item_bait_drycrumb", "quantity": 2},
			{"item_id": "item_catalyst_bellsalt", "quantity": 1},
			{"item_id": "item_catalyst_namewax", "quantity": 1},
			{"item_id": "item_record_tagcase", "quantity": 1},
		]
	)


func serialize() -> Array[Dictionary]:
	return _entries.duplicate(true)


func sync_from_battle(entries: Array) -> void:
	load_from_save(entries)


func add_item(item_id: String, quantity: int = 1) -> Dictionary:
	if quantity <= 0:
		return {"accepted": false, "reason": "invalid_quantity"}

	var item = _load_item(item_id, _get_bootstrapped_game_manager())
	if item == null:
		return {"accepted": false, "reason": "missing_item"}

	for index in range(_entries.size()):
		var entry: Dictionary = _entries[index]
		if String(entry.get("item_id", "")) != item_id:
			continue
		entry["quantity"] = mini(int(entry.get("quantity", 0)) + quantity, STACK_LIMIT)
		_entries[index] = entry
		return {"accepted": true, "stacked": true, "item_id": item_id}

	if _uses_carry_slot(item) and used_carry_slots() >= CARRY_LIMIT:
		return {"accepted": false, "reason": "carry_full", "item_id": item_id}

	_entries.append({"item_id": item_id, "quantity": mini(quantity, STACK_LIMIT)})
	return {"accepted": true, "stacked": false, "item_id": item_id}


func consume_item(item_id: String, quantity: int = 1) -> Dictionary:
	if quantity <= 0:
		return {"accepted": false, "reason": "invalid_quantity", "item_id": item_id}

	for index in range(_entries.size()):
		var entry: Dictionary = _entries[index]
		if String(entry.get("item_id", "")) != item_id:
			continue
		var current_quantity := int(entry.get("quantity", 0))
		if current_quantity < quantity:
			return {"accepted": false, "reason": "insufficient_quantity", "item_id": item_id}
		current_quantity -= quantity
		if current_quantity <= 0:
			_entries.remove_at(index)
		else:
			entry["quantity"] = current_quantity
			_entries[index] = entry
		return {"accepted": true, "item_id": item_id, "remaining": maxi(current_quantity, 0)}

	return {"accepted": false, "reason": "missing_item", "item_id": item_id}


func list_breeding_catalysts() -> Array[Dictionary]:
	var catalysts: Array[Dictionary] = []
	var game_manager = _get_bootstrapped_game_manager()
	for entry in _entries:
		if int(entry.get("quantity", 0)) <= 0:
			continue
		var item = _load_item(String(entry.get("item_id", "")), game_manager)
		if item == null or String(item.target_scope) != "breed":
			continue
		var enriched := entry.duplicate(true)
		enriched["name_jp"] = String(item.name_jp)
		enriched["effect_key"] = String(item.effect_key)
		enriched["effect_value"] = String(item.effect_value)
		enriched["description"] = String(item.description)
		enriched["tags"] = Array(item.tags).duplicate()
		catalysts.append(enriched)
	return catalysts


func used_carry_slots() -> int:
	var used := 0
	var game_manager = _get_bootstrapped_game_manager()
	for entry in _entries:
		if int(entry.get("quantity", 0)) <= 0:
			continue
		var item = _load_item(String(entry.get("item_id", "")), game_manager)
		if item == null:
			continue
		if _uses_carry_slot(item):
			used += 1
	return used


func build_menu_snapshot() -> Dictionary:
	var carry_items: Array[Dictionary] = []
	var key_items: Array[Dictionary] = []
	var game_manager = _get_bootstrapped_game_manager()
	for entry in _entries:
		if int(entry.get("quantity", 0)) <= 0:
			continue
		var item_id := String(entry.get("item_id", ""))
		var item = _load_item(item_id, game_manager)
		var provenance_strip := _get_item_text(item_id, "menu_strip", "", "", game_manager)
		var enriched := entry.duplicate(true)
		enriched["name_jp"] = item.name_jp if item != null else item_id
		enriched["name_en"] = item.name_en if item != null else ""
		enriched["display_name"] = enriched["name_jp"]
		enriched["item_kind"] = item.item_kind if item != null else ""
		enriched["subtype"] = item.subtype if item != null else ""
		enriched["target_scope"] = item.target_scope if item != null else ""
		enriched["effect_key"] = item.effect_key if item != null else ""
		enriched["effect_value"] = item.effect_value if item != null else ""
		enriched["price"] = item.price if item != null else 0
		enriched["sell_price"] = item.sell_price if item != null else 0
		enriched["description"] = item.description if item != null else ""
		enriched["provenance_strip"] = provenance_strip
		enriched["tags"] = Array(item.tags).duplicate() if item != null else []
		enriched["key_item"] = bool(item != null and not _uses_carry_slot(item))
		if item != null and not _uses_carry_slot(item):
			key_items.append(enriched)
		else:
			carry_items.append(enriched)
	return {
		"carry": carry_items,
		"key_items": key_items,
		"carry_limit": CARRY_LIMIT,
		"carry_used": used_carry_slots(),
	}


func _uses_carry_slot(item) -> bool:
	return String(item.item_kind) != "key"


func _load_item(item_id: String, game_manager = null):
	if item_id.is_empty() or game_manager == null:
		return null
	return game_manager.call("get_item", item_id)


func _get_item_text(
	item_id: String,
	text_kind: String,
	scope_id: String = "",
	shop_id: String = "",
	game_manager = null
) -> String:
	if item_id.is_empty() or text_kind.is_empty() or game_manager == null:
		return ""
	var row: Dictionary = game_manager.call("get_item_text", item_id, text_kind, scope_id, shop_id)
	return String(row.get("text_jp", "")).strip_edges()


func _get_bootstrapped_game_manager():
	var main_loop = Engine.get_main_loop()
	if main_loop == null or main_loop.root == null:
		return null
	var game_manager = main_loop.root.get_node_or_null("/root/GameManager")
	if game_manager == null:
		return null
	game_manager.call("bootstrap")
	return game_manager
