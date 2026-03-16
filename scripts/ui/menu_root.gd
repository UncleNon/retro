# gdlint: disable=max-returns
extends Node2D

signal action_requested(action: Dictionary)
signal menu_closed

const SECTION_ORDER := ["party", "inventory", "ranch", "breeding", "codex", "log"]
const SECTION_LABELS := {
	"party": "なかま",
	"inventory": "もちもの",
	"ranch": "ぼくじょう",
	"breeding": "はいごう",
	"codex": "ずかん",
	"log": "きろく",
}

var _menu_open: bool = false
var _snapshot: Dictionary = {}
var _section_index: int = 0
var _detail_index: int = 0
var _active_column: String = "sections"
var _ranch_column: String = "party"
var _feedback_message: String = ""

@onready var _menu_ui: CanvasLayer = $MenuUI
@onready var _header_label: Label = %HeaderLabel
@onready var _section_label: Label = %SectionLabel
@onready var _detail_label: Label = %DetailLabel
@onready var _help_label: Label = %HelpLabel
@onready var _message_label: Label = %MessageLabel


func _ready() -> void:
	if _menu_ui != null:
		_menu_ui.visible = false
	_snapshot = _normalize_snapshot({})
	_refresh_ui()


func _unhandled_input(event: InputEvent) -> void:
	if not _menu_open or event.is_echo() or not event.is_pressed():
		return

	if event is InputEventKey and event.keycode == KEY_L:
		toggle_lock_selected()
	elif event.is_action_pressed("ui_cancel"):
		close_menu()
	elif event.is_action_pressed("ui_left"):
		_move_left()
	elif event.is_action_pressed("ui_right"):
		_move_right()
	elif event.is_action_pressed("ui_up"):
		_move_vertical(-1)
	elif event.is_action_pressed("ui_down"):
		_move_vertical(1)
	elif event.is_action_pressed("ui_accept"):
		_activate_selection()


func set_menu_snapshot(snapshot: Dictionary) -> void:
	_snapshot = _normalize_snapshot(snapshot)
	_clamp_selection()
	_refresh_ui()


func get_menu_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func get_ui_snapshot() -> Dictionary:
	return {
		"menu_open": _menu_open,
		"header": _header_label.text if _header_label != null else "",
		"section": _section_label.text if _section_label != null else "",
		"detail": _detail_label.text if _detail_label != null else "",
		"help": _help_label.text if _help_label != null else "",
		"message": _message_label.text if _message_label != null else "",
	}


func debug_select_section(section_id: String) -> void:
	var index := SECTION_ORDER.find(section_id)
	if index == -1:
		return
	_section_index = index
	_active_column = "sections"
	_detail_index = 0
	_ranch_column = "party"
	_feedback_message = ""
	_clamp_selection()
	_refresh_ui()


func open_menu(snapshot: Dictionary = {}) -> void:
	if not snapshot.is_empty():
		set_menu_snapshot(snapshot)
	_menu_open = true
	if _menu_ui != null:
		_menu_ui.visible = true
	_clamp_selection()
	_refresh_ui()


func close_menu() -> void:
	if not _menu_open:
		return
	_menu_open = false
	if _menu_ui != null:
		_menu_ui.visible = false
	menu_closed.emit()


func is_open() -> bool:
	return _menu_open


func get_cursor_snapshot() -> Dictionary:
	return {
		"section": _current_section_id(),
		"active_column": _active_column,
		"detail_index": _detail_index,
		"ranch_column": _ranch_column,
	}


func toggle_lock_selected() -> Dictionary:
	if _current_section_id() not in ["party", "ranch"]:
		_feedback_message = "ロックできる たいしょうがない"
		_refresh_ui()
		return {}

	var payload := _build_action_payload("toggle_lock")
	if payload.is_empty():
		_feedback_message = "ロックできる たいしょうがない"
		_refresh_ui()
		return {}

	action_requested.emit(payload)
	_feedback_message = "ロックきりかえを いらいした"
	_refresh_ui()
	return payload


func _move_left() -> void:
	if _active_column == "detail" and _current_section_id() == "ranch" and _ranch_column == "ranch":
		_ranch_column = "party"
	else:
		_active_column = "sections"
	_clamp_selection()
	_refresh_ui()


func _move_right() -> void:
	if _active_column == "sections":
		_active_column = "detail"
	elif _current_section_id() == "ranch" and _ranch_column == "party":
		_ranch_column = "ranch"
	_clamp_selection()
	_refresh_ui()


func _move_vertical(delta: int) -> void:
	if _active_column == "sections":
		_section_index = posmod(_section_index + delta, SECTION_ORDER.size())
		_detail_index = 0
		_ranch_column = "party"
	else:
		var entry_count := _current_entry_count()
		if entry_count > 0:
			_detail_index = posmod(_detail_index + delta, entry_count)
	_feedback_message = ""
	_refresh_ui()


func _activate_selection() -> void:
	if _active_column == "sections":
		_active_column = "detail"
		_clamp_selection()
		_refresh_ui()
		return

	var payload := _build_action_payload(_default_action_name())
	if payload.is_empty():
		_feedback_message = "つかえる こうどうがない"
		_refresh_ui()
		return

	action_requested.emit(payload)
	_feedback_message = _feedback_for_action(payload)
	_refresh_ui()


func _build_action_payload(action_name: String) -> Dictionary:
	var entry := _current_selected_entry()
	if entry.is_empty():
		return {}

	return {
		"section": _current_section_id(),
		"action": action_name,
		"location": _current_location_id(),
		"index": _detail_index,
		"entry": entry.duplicate(true),
		"context_message": _describe_selected_entry(entry),
	}


func _default_action_name() -> String:
	if _current_section_id() == "ranch":
		return "move"
	if _current_section_id() == "breeding":
		return "breed"
	return "inspect"


func _feedback_for_action(payload: Dictionary) -> String:
	match String(payload.get("action", "")):
		"move":
			return "いどうを いらいした"
		"toggle_lock":
			return "ロックきりかえを いらいした"
	return "しょうさいひょうじを いらいした"


func _current_section_id() -> String:
	return SECTION_ORDER[_section_index]


func _current_location_id() -> String:
	if _current_section_id() == "ranch":
		return _ranch_column
	return _current_section_id()


func _current_entries() -> Array:
	var section_id := _current_section_id()
	if section_id == "ranch":
		var ranch_section: Dictionary = _snapshot.get("ranch", {})
		return Array(ranch_section.get(_ranch_column, []))
	var section_payload: Variant = _snapshot.get(section_id, {})
	if section_payload is Array:
		return Array(section_payload)
	if section_payload is Dictionary:
		return Array(section_payload.get("entries", []))
	return []


func _current_entry_count() -> int:
	return _current_entries().size()


func _current_selected_entry() -> Dictionary:
	var entries := _current_entries()
	if entries.is_empty():
		return {}
	var index := clampi(_detail_index, 0, entries.size() - 1)
	var entry_variant = entries[index]
	if entry_variant is Dictionary:
		return entry_variant
	return {"label": String(entry_variant)}


func _clamp_selection() -> void:
	_section_index = clampi(_section_index, 0, SECTION_ORDER.size() - 1)
	var entry_count := _current_entry_count()
	if entry_count <= 0:
		_detail_index = 0
	else:
		_detail_index = clampi(_detail_index, 0, entry_count - 1)


func _normalize_snapshot(snapshot: Dictionary) -> Dictionary:
	var normalized := {
		"economy": {"gold": 0},
		"party": {"entries": []},
		"inventory": {"entries": []},
		"ranch": {"party": [], "ranch": []},
		"breeding": {"entries": [], "history": [], "known_count": 0, "resolved_count": 0},
		"codex": {"entries": []},
		"log": {"entries": []},
		"message": "",
	}
	var economy_payload: Variant = snapshot.get("economy", {})
	if economy_payload is Dictionary:
		normalized["economy"] = {"gold": maxi(int(economy_payload.get("gold", 0)), 0)}
	for section_id in ["party", "inventory", "breeding", "codex", "log"]:
		var section_payload: Variant = snapshot.get(section_id, {})
		if section_payload is Array:
			normalized[section_id] = {"entries": Array(section_payload).duplicate(true)}
		elif section_payload is Dictionary:
			normalized[section_id] = section_payload.duplicate(true)
	var ranch_payload: Variant = snapshot.get("ranch", {})
	if ranch_payload is Dictionary:
		normalized["ranch"] = {
			"party": Array(ranch_payload.get("party", [])).duplicate(true),
			"ranch": Array(ranch_payload.get("ranch", [])).duplicate(true),
			"summary": String(ranch_payload.get("summary", "")),
		}
	elif ranch_payload is Array:
		normalized["ranch"] = {"party": [], "ranch": Array(ranch_payload).duplicate(true)}
	normalized["message"] = String(snapshot.get("message", ""))
	return normalized


func _refresh_ui() -> void:
	_header_label.text = _build_header_text()
	_section_label.text = _build_section_text()
	_detail_label.text = _build_detail_text()
	_help_label.text = _build_help_text()
	_message_label.text = _build_message_text()


func _build_header_text() -> String:
	var section_id := _current_section_id()
	var gold := int(Dictionary(_snapshot.get("economy", {})).get("gold", 0))
	if section_id == "ranch":
		var ranch_payload: Dictionary = _snapshot.get("ranch", {})
		var party_count := Array(ranch_payload.get("party", [])).size()
		var ranch_count := Array(ranch_payload.get("ranch", [])).size()
		return (
			"[MENU] %s G%03d P%d R%d" % [SECTION_LABELS[section_id], gold, party_count, ranch_count]
		)

	var entries := _current_entries()
	if section_id == "inventory":
		var inventory_payload: Dictionary = _snapshot.get("inventory", {})
		return (
			"[MENU] %s G%03d %d/%d"
			% [
				SECTION_LABELS[section_id],
				gold,
				int(inventory_payload.get("carry_used", 0)),
				int(inventory_payload.get("carry_limit", 20)),
			]
		)
	return "[MENU] %s G%03d %d" % [SECTION_LABELS[section_id], gold, entries.size()]


func _build_section_text() -> String:
	var lines: Array[String] = ["[SECTION]"]
	for index in range(SECTION_ORDER.size()):
		var section_id: String = SECTION_ORDER[index]
		var marker := ">" if index == _section_index else " "
		lines.append("%s %s" % [marker, SECTION_LABELS[section_id]])
	return "\n".join(lines)


func _build_detail_text() -> String:
	match _current_section_id():
		"party":
			return _build_monster_section_text(
				"[ALLY]", Array(_snapshot.get("party", {}).get("entries", []))
			)
		"inventory":
			return _build_inventory_text()
		"ranch":
			return _build_ranch_text()
		"breeding":
			return _build_breeding_text()
		"codex":
			return _build_codex_text()
		"log":
			return _build_log_text()
	return "[DETAIL]"


func _build_monster_section_text(title: String, entries: Array) -> String:
	var lines: Array[String] = [title]
	if entries.is_empty():
		lines.append("  とうろく なし")
		return "\n".join(lines)
	for index in range(entries.size()):
		var entry_variant = entries[index]
		var entry: Dictionary = (
			entry_variant if entry_variant is Dictionary else {"label": String(entry_variant)}
		)
		var marker := ">" if _active_column == "detail" and _detail_index == index else " "
		lines.append("%s %s" % [marker, _monster_line(entry)])
	return "\n".join(lines)


func _build_inventory_text() -> String:
	var section_payload: Dictionary = _snapshot.get("inventory", {})
	var entries := Array(section_payload.get("entries", []))
	var lines: Array[String] = [
		"[ITEM]",
		(
			"ふくろ %d/%d"
			% [
				int(section_payload.get("carry_used", 0)),
				int(section_payload.get("carry_limit", 20)),
			]
		),
	]
	if entries.is_empty():
		lines.append("  もちもの なし")
		return "\n".join(lines)
	lines.append("---")
	for index in range(entries.size()):
		var entry_variant = entries[index]
		var entry: Dictionary = (
			entry_variant if entry_variant is Dictionary else {"label": String(entry_variant)}
		)
		var marker := ">" if _active_column == "detail" and _detail_index == index else " "
		lines.append("%s %s" % [marker, _inventory_line(entry)])
	return "\n".join(lines)


func _build_ranch_text() -> String:
	var ranch_payload: Dictionary = _snapshot.get("ranch", {})
	var party_entries := Array(ranch_payload.get("party", []))
	var ranch_entries := Array(ranch_payload.get("ranch", []))
	var lines: Array[String] = ["[RANCH]"]
	lines.append(
		"%s PARTY" % (">" if _active_column == "detail" and _ranch_column == "party" else " ")
	)
	if party_entries.is_empty():
		lines.append("  とうろく なし")
	else:
		for index in range(party_entries.size()):
			var entry_variant = party_entries[index]
			var entry: Dictionary = (
				entry_variant if entry_variant is Dictionary else {"label": String(entry_variant)}
			)
			var marker := (
				">"
				if (
					_active_column == "detail"
					and _ranch_column == "party"
					and _detail_index == index
				)
				else " "
			)
			lines.append("%s %s" % [marker, _monster_line(entry)])
	lines.append("---")
	lines.append(
		"%s RANCH" % (">" if _active_column == "detail" and _ranch_column == "ranch" else " ")
	)
	if ranch_entries.is_empty():
		lines.append("  あずかり なし")
	else:
		for index in range(ranch_entries.size()):
			var entry_variant = ranch_entries[index]
			var entry: Dictionary = (
				entry_variant if entry_variant is Dictionary else {"label": String(entry_variant)}
			)
			var marker := (
				">"
				if (
					_active_column == "detail"
					and _ranch_column == "ranch"
					and _detail_index == index
				)
				else " "
			)
			lines.append("%s %s" % [marker, _monster_line(entry)])
	return "\n".join(lines)


func _build_codex_text() -> String:
	var section_payload: Dictionary = _snapshot.get("codex", {})
	var entries := Array(section_payload.get("entries", []))
	var lines: Array[String] = ["[CODEX]"]
	var seen := int(section_payload.get("seen", entries.size()))
	var recruited := int(section_payload.get("recruited", 0))
	var known_recipe_count := int(section_payload.get("known_recipe_count", 0))
	var resolved_recipe_count := int(section_payload.get("resolved_recipe_count", 0))
	lines.append("みた:%d  なかま:%d" % [seen, recruited])
	lines.append("はいごう:%d/%d" % [resolved_recipe_count, known_recipe_count])
	if entries.is_empty():
		lines.append("  きろく なし")
		return "\n".join(lines)
	lines.append("---")
	for index in range(entries.size()):
		var entry_variant = entries[index]
		var entry: Dictionary = (
			entry_variant if entry_variant is Dictionary else {"label": String(entry_variant)}
		)
		var marker := ">" if _active_column == "detail" and _detail_index == index else " "
		lines.append("%s %s" % [marker, _codex_line(entry)])
	return "\n".join(lines)


func _build_breeding_text() -> String:
	var section_payload: Dictionary = _snapshot.get("breeding", {})
	var entries := Array(section_payload.get("entries", []))
	var history := Array(section_payload.get("history", []))
	var lines: Array[String] = ["[BREED]"]
	(
		lines
		. append(
			(
				"候補:%d  発見:%d  成立:%d"
				% [
					entries.size(),
					int(section_payload.get("known_count", 0)),
					int(section_payload.get("resolved_count", 0)),
				]
			)
		)
	)
	if entries.is_empty():
		lines.append("  はいごう候補なし")
	else:
		lines.append("---")
		for index in range(entries.size()):
			var entry_variant = entries[index]
			var entry: Dictionary = (
				entry_variant if entry_variant is Dictionary else {"label": String(entry_variant)}
			)
			var marker := ">" if _active_column == "detail" and _detail_index == index else " "
			lines.append("%s %s" % [marker, _breeding_line(entry)])
	if not history.is_empty():
		lines.append("---")
		for history_variant in history:
			if not history_variant is Dictionary:
				continue
			var history_entry: Dictionary = history_variant
			(
				lines
				. append(
					(
						"%s<=%s"
						% [
							String(history_entry.get("child_name", "?")),
							" + ".join(Array(history_entry.get("parents", []))),
						]
					)
				)
			)
	return "\n".join(lines)


func _build_log_text() -> String:
	var section_payload: Dictionary = _snapshot.get("log", {})
	var entries := Array(section_payload.get("entries", []))
	var lines: Array[String] = ["[LOG]"]
	if entries.is_empty():
		lines.append("  きろく なし")
		return "\n".join(lines)
	for index in range(entries.size()):
		var entry_variant = entries[index]
		var entry: Dictionary = (
			entry_variant if entry_variant is Dictionary else {"text": String(entry_variant)}
		)
		var marker := ">" if _active_column == "detail" and _detail_index == index else " "
		lines.append("%s %s" % [marker, _log_line(entry)])
	return "\n".join(lines)


func _build_help_text() -> String:
	if not _menu_open:
		return ""
	if _active_column == "sections":
		return "上下:項目  →/A:開く  B:閉じる"
	if _current_section_id() == "ranch":
		return "上下:選択  ←→:列  A:移動  L:ロック"
	if _current_section_id() == "party":
		return "上下:選択  A:詳細  L:ロック  B:閉じる"
	if _current_section_id() == "breeding":
		return "上下:候補  A:はいごう  B:閉じる"
	return "上下:選択  A:詳細  B:閉じる"


func _build_message_text() -> String:
	if not _feedback_message.is_empty():
		return _feedback_message
	var snapshot_message := String(_snapshot.get("message", ""))
	if not snapshot_message.is_empty():
		return snapshot_message
	return _describe_selected_entry(_current_selected_entry())


func _monster_line(entry: Dictionary) -> String:
	var display_name := String(entry.get("nickname", entry.get("name", entry.get("label", "?"))))
	var level := int(entry.get("level", 0))
	var tactic := String(entry.get("tactic", ""))
	var lock_marker := "*" if bool(entry.get("locked", false)) else "-"
	var plus_text := ""
	if int(entry.get("plus_value", 0)) > 0:
		plus_text = " +%d" % int(entry.get("plus_value", 0))
	if level > 0 and not tactic.is_empty():
		return "%s Lv%02d%s %s %s" % [display_name, level, plus_text, tactic, lock_marker]
	if level > 0:
		return "%s Lv%02d%s %s" % [display_name, level, plus_text, lock_marker]
	return "%s %s" % [display_name, lock_marker]


func _inventory_line(entry: Dictionary) -> String:
	var label := String(
		entry.get(
			"display_name",
			entry.get("name_jp", entry.get("name", entry.get("label", entry.get("item_id", "?"))))
		)
	)
	var quantity := int(entry.get("quantity", entry.get("count", 0)))
	return "%s x%d" % [label, quantity]


func _log_line(entry: Dictionary) -> String:
	var kind := String(entry.get("kind", "note"))
	var labels := {
		"battle": "戦",
		"recruit": "仲",
		"facility": "施",
		"breeding": "配",
	}
	var kind_label: String = String(labels.get(kind, "記"))
	return "[%s] %s" % [kind_label, String(entry.get("text", ""))]


func _codex_line(entry: Dictionary) -> String:
	var label := String(
		entry.get("name", entry.get("name_jp", entry.get("label", entry.get("monster_id", "?"))))
	)
	var status := "加入" if bool(entry.get("recruited", false)) else "発見"
	return "%s %s" % [label, status]


func _breeding_line(entry: Dictionary) -> String:
	var parent_a := String(entry.get("parent_a_name", "?"))
	var parent_b := String(entry.get("parent_b_name", "?"))
	var preview_text := String(entry.get("preview_text", "反応なし"))
	return "%s+%s %s" % [parent_a, parent_b, preview_text]


func _describe_selected_entry(entry: Dictionary) -> String:
	if entry.is_empty():
		return ""
	match _current_section_id():
		"inventory":
			return _describe_item_entry(entry)
		"codex":
			return _describe_codex_entry(entry)
		"breeding":
			return _describe_breeding_entry(entry)
		"log":
			return _describe_log_entry(entry)
		"party", "ranch":
			return _describe_monster_entry(entry)
	if entry.has("item_id"):
		return _describe_item_entry(entry)
	if entry.has("rule_id"):
		return _describe_breeding_entry(entry)
	if entry.has("monster_id"):
		return _describe_monster_entry(entry)
	return String(entry.get("label", entry.get("name", "")))


func _describe_item_entry(entry: Dictionary) -> String:
	var lines: Array[String] = []
	var display_name := String(
		entry.get(
			"display_name",
			entry.get("name_jp", entry.get("name", entry.get("label", entry.get("item_id", "?"))))
		)
	)
	var quantity := int(entry.get("quantity", entry.get("count", 0)))
	var effect_text := _item_effect_text(entry)
	var header := "%s x%d" % [display_name, quantity]
	if bool(entry.get("key_item", false)):
		header += " / 大事なもの"
	elif not effect_text.is_empty():
		header += " / %s" % effect_text
	lines.append(header)
	var scope_text := _item_scope_text(String(entry.get("target_scope", "")))
	if not scope_text.is_empty():
		lines.append(scope_text)
	var provenance_strip := String(entry.get("provenance_strip", "")).strip_edges()
	if not provenance_strip.is_empty():
		lines.append_array(_wrap_text_lines(provenance_strip, 18, 1))
	var description := String(entry.get("description", "")).strip_edges()
	if not description.is_empty():
		lines.append_array(_wrap_text_lines(description, 18, maxi(1, 3 - lines.size())))
	return "\n".join(lines.slice(0, 3))


func _describe_monster_entry(entry: Dictionary) -> String:
	var lines: Array[String] = []
	var display_name := String(
		entry.get(
			"nickname", entry.get("name", entry.get("species_name", entry.get("monster_id", "?")))
		)
	)
	var family := String(entry.get("family", ""))
	var rank := String(entry.get("rank", ""))
	var header_bits: Array[String] = [display_name]
	if not family.is_empty():
		header_bits.append(family)
	if not rank.is_empty():
		header_bits.append(rank)
	if int(entry.get("plus_value", 0)) > 0:
		header_bits.append("+%d" % int(entry.get("plus_value", 0)))
	lines.append(" ".join(header_bits))
	var hp_text := (
		"HPmax"
		if int(entry.get("current_hp", -1)) < 0
		else "HP%d" % int(entry.get("current_hp", -1))
	)
	var mp_text := (
		"MPmax"
		if int(entry.get("current_mp", -1)) < 0
		else "MP%d" % int(entry.get("current_mp", -1))
	)
	lines.append("%s / %s / %s" % [hp_text, mp_text, String(entry.get("tactic", "まかせた"))])
	var notes := String(entry.get("notes", "")).strip_edges()
	if not notes.is_empty():
		lines.append_array(_wrap_text_lines(notes, 18, 1))
	return "\n".join(lines.slice(0, 3))


func _describe_codex_entry(entry: Dictionary) -> String:
	var lines: Array[String] = []
	var name := String(entry.get("name", entry.get("name_jp", entry.get("monster_id", "?"))))
	var status := "加入済み" if bool(entry.get("recruited", false)) else "発見のみ"
	lines.append("%s / %s" % [name, status])
	var family := String(entry.get("family", ""))
	var rank := String(entry.get("rank", ""))
	if not family.is_empty() or not rank.is_empty():
		lines.append("%s %s" % [family, rank])
	var notes := String(entry.get("notes", "")).strip_edges()
	if not notes.is_empty():
		lines.append_array(_wrap_text_lines(notes, 18, maxi(1, 3 - lines.size())))
	return "\n".join(lines.slice(0, 3))


func _describe_breeding_entry(entry: Dictionary) -> String:
	var lines: Array[String] = []
	var child_name := String(entry.get("child_name", entry.get("child_monster_id", "?")))
	(
		lines
		. append(
			(
				"%s <= %s + %s"
				% [
					child_name,
					String(entry.get("parent_a_name", "?")),
					String(entry.get("parent_b_name", "?")),
				]
			)
		)
	)
	var preview_text := String(entry.get("preview_text", "")).strip_edges()
	if not preview_text.is_empty():
		lines.append_array(_wrap_text_lines(preview_text, 18, 1))
	var inherit_preview := String(entry.get("inherit_preview", "")).strip_edges()
	if not inherit_preview.is_empty():
		lines.append_array(_wrap_text_lines(inherit_preview, 18, maxi(1, 3 - lines.size())))
	return "\n".join(lines.slice(0, 3))


func _describe_log_entry(entry: Dictionary) -> String:
	var text := String(entry.get("text", "")).strip_edges()
	if text.is_empty():
		return ""
	var lines: Array[String] = []
	var kind := String(entry.get("kind", "note"))
	var kind_label: String = String(
		{"battle": "戦", "recruit": "仲", "facility": "施", "breeding": "配"}.get(kind, "記")
	)
	lines.append("[%s]" % kind_label)
	lines.append_array(_wrap_text_lines(text, 18, 2))
	return "\n".join(lines.slice(0, 3))


func _item_scope_text(target_scope: String) -> String:
	match target_scope:
		"ally_single":
			return "対象: 味方1体"
		"enemy_single":
			return "対象: 敵1体"
		"enemy_all":
			return "対象: 敵全体"
		"party":
			return "対象: パーティ"
		"breed":
			return "対象: はいごう"
		"none":
			return "対象: 大事なもの"
	return ""


func _item_effect_text(entry: Dictionary) -> String:
	var effect_key := String(entry.get("effect_key", ""))
	var effect_value := String(entry.get("effect_value", ""))
	match effect_key:
		"heal_hp":
			return "HP%s回復" % effect_value
		"heal_mp":
			return "MP%s回復" % effect_value
		"cure_status":
			return "%s解除" % effect_value
		"recruit_bonus":
			return "勧誘+%s" % effect_value
		"buff_atk":
			return "攻+%sT" % effect_value
		"buff_def":
			return "守+%sT" % effect_value
		"buff_spd":
			return "早+%sT" % effect_value
		"buff_res":
			return "精+%sT" % effect_value
		"debuff_spd":
			return "敵早-%sT" % effect_value
		"debuff_acc":
			return "敵狙-%sT" % effect_value
		"escape_dungeon":
			return "場: 脱出"
		"reveal_path":
			return "場: 道印"
		"repel_low":
			return "場: 寄り避け"
		"lure_family":
			return "場: 呼び寄せ"
		"reduce_reaction":
			return "場: 反応鈍化"
		"night_event":
			return "場: 夜用"
		"mutation_bonus":
			return "配: 変異寄せ"
		"family_bonus":
			return "配: 系統寄せ"
		"inherit_protect":
			return "配: 継承保護"
		"plus_value":
			return "配: +%s" % effect_value
		"mutation_direct":
			return "配: 変異固定"
		"clue_log":
			return "記: clue記録"
		"clue_hold":
			return "記: clue保持"
		"ledger_check":
			return "記: 台帳照合"
		"bell_clue":
			return "記: 鈴痕跡"
		"recipe_hint":
			return "記: はいごう示唆"
		"story_flag":
			return "進行 key"
	return ""


func _wrap_text_lines(text: String, max_chars: int, max_lines: int) -> Array[String]:
	var normalized := text.strip_edges().replace("\n", "")
	if normalized.is_empty() or max_chars <= 0 or max_lines <= 0:
		return []
	var lines: Array[String] = []
	var start := 0
	while start < normalized.length() and lines.size() < max_lines:
		var remaining := normalized.length() - start
		var take := mini(max_chars, remaining)
		var chunk := normalized.substr(start, take)
		start += take
		if start < normalized.length() and lines.size() == max_lines - 1:
			if chunk.length() >= 3:
				chunk = chunk.substr(0, chunk.length() - 3) + "..."
			else:
				chunk += "..."
			start = normalized.length()
		lines.append(chunk)
	return lines
