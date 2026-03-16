class_name BattleTextBuilder
extends RefCounted

const BattleStateMachineScript = preload("res://scripts/battle/battle_state_machine.gd")


static func build_enemy_text(owner) -> String:
	var lines: Array[String] = ["[ENEMY]"]
	for fighter in owner._enemies:
		if fighter == null:
			continue
		var down_marker := " x" if not fighter.is_alive() else ""
		lines.append(
			(
				"%d:%s HP %03d%s%s"
				% [
					fighter.slot_index + 1,
					fighter.display_name,
					fighter.current_hp,
					down_marker,
					fighter.get_status_summary()
				]
			)
		)
	return "\n".join(lines)


static func build_party_text(owner) -> String:
	var lines: Array[String] = ["[ALLY]"]
	for fighter in owner._party:
		if fighter == null:
			continue
		(
			lines
			. append(
				(
					"%d:%s HP %03d/%03d MP %02d/%02d [%s]%s"
					% [
						fighter.slot_index + 1,
						fighter.display_name,
						fighter.current_hp,
						fighter.max_hp,
						fighter.current_mp,
						fighter.max_mp,
						owner._legacy_tactic_label(String(fighter.tactic)),
						fighter.get_status_summary(),
					]
				)
			)
		)
	return "\n".join(lines)


static func build_command_text(owner) -> String:
	match owner._state_machine.current_state:
		BattleStateMachineScript.State.TACTIC_SELECT:
			return build_tactic_text(owner)
		BattleStateMachineScript.State.ITEM_SELECT:
			return build_item_text(owner)
		BattleStateMachineScript.State.DIRECT_SELECT:
			return build_direct_text(owner)
		BattleStateMachineScript.State.RESULT:
			return "[RESULT]\nA: もどる"
	var lines: Array[String] = ["[COMMAND]"]
	for index in range(owner.COMMANDS.size()):
		var marker := ">" if index == owner._selected_command else " "
		lines.append("%s %s" % [marker, owner.COMMANDS[index]["label"]])
	return "\n".join(lines)


static func build_help_text(owner) -> String:
	match owner._state_machine.current_state:
		BattleStateMachineScript.State.TACTIC_SELECT:
			return "左右:味方  上下:作戦  A:決定  B:戻る"
		BattleStateMachineScript.State.ITEM_SELECT:
			return "上下:道具  左右:対象  A:使用  B:戻る"
		BattleStateMachineScript.State.DIRECT_SELECT:
			var fighter = owner._current_direct_fighter()
			if fighter == null:
				return ""
			return "%s に めいれい  上下:技  左右:対象" % fighter.display_name
		BattleStateMachineScript.State.RESULT:
			return "結果を閉じて フィールドへ戻る"
	return "上下:選択  A:決定"


static func build_tactic_text(owner) -> String:
	var lines: Array[String] = ["[TACTIC]"]
	for index in range(owner._party.size()):
		var fighter = owner._party[index]
		var marker := "<" if index == owner._selected_tactic_slot else " "
		lines.append(
			(
				"%s %s: %s"
				% [marker, fighter.display_name, owner._legacy_tactic_label(String(fighter.tactic))]
			)
		)
	lines.append("---")
	lines.append("候補: %s" % owner.TACTIC_OPTIONS[owner._selected_tactic_index])
	return "\n".join(lines)


static func build_item_text(owner) -> String:
	var battle_items = owner._get_battle_items()
	var lines: Array[String] = ["[ITEM]"]
	for index in range(battle_items.size()):
		var item_entry: Dictionary = battle_items[index]
		var marker := ">" if index == owner._selected_item_index else " "
		lines.append(
			(
				"%s %s x%d"
				% [
					marker,
					String(item_entry.get("_name_jp", "?")),
					int(item_entry.get("quantity", 0))
				]
			)
		)
	var selected_entry: Dictionary = battle_items[owner._selected_item_index]
	lines.append("---")
	lines.append(
		(
			"対象: %s"
			% target_name(
				owner, owner._item_target_side(selected_entry), owner._selected_item_target_index
			)
		)
	)
	return "\n".join(lines)


static func build_direct_text(owner) -> String:
	var fighter = owner._current_direct_fighter()
	if fighter == null:
		return "[DIRECT]\nめいれい なし"
	var usable_skills = owner._direct_usable_skills(fighter)
	var lines: Array[String] = ["[DIRECT %s]" % fighter.display_name]
	for index in range(usable_skills.size()):
		var skill = usable_skills[index]
		var marker := ">" if index == owner._selected_skill_index else " "
		lines.append("%s %s MP%d" % [marker, skill.name_jp, skill.mp_cost])
	var current_skill = usable_skills[owner._selected_skill_index]
	lines.append("---")
	lines.append(
		(
			"対象: %s"
			% target_name(
				owner, owner._target_side_for_skill(current_skill), owner._selected_target_index
			)
		)
	)
	return "\n".join(lines)


static func target_name(owner, target_side: String, target_index: int) -> String:
	var pool = owner._party if target_side == "ally" else owner._enemies
	for fighter in pool:
		if fighter != null and fighter.slot_index == target_index:
			return fighter.display_name
	return pool[0].display_name if not pool.is_empty() else "-"
