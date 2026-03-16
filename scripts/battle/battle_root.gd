extends Node2D

signal battle_finished(result: Dictionary)

const BattleFighterScript = preload("res://scripts/battle/battle_fighter.gd")
const BattleAIScript = preload("res://scripts/battle/battle_ai.gd")
const BattleStateMachineScript = preload("res://scripts/battle/battle_state_machine.gd")
const BattleTextBuilderScript = preload("res://scripts/battle/battle_text_builder.gd")
const TurnResolverScript = preload("res://scripts/battle/turn_resolver.gd")

const COMMANDS := [
	{"id": "fight", "label": "たたかう"},
	{"id": "tactics", "label": "さくせん"},
	{"id": "item", "label": "どうぐ"},
	{"id": "escape", "label": "にげる"},
]

const TACTIC_OPTIONS := [
	"まかせた",
	"全力で攻めろ",
	"命を守れ",
	"力だけで戦え",
	"援護を頼む",
	"直接指示",
]

const EXTERNAL_TACTIC_TO_INTERNAL := {
	"BALANCED": "まかせた",
	"GO_ALL_OUT": "全力で攻めろ",
	"STAY_SAFE": "命を守れ",
	"NO_SPELLS": "力だけで戦え",
	"SUPPORT": "援護を頼む",
	"MANUAL": "直接指示",
	"まかせた": "まかせた",
	"全力で攻めろ": "全力で攻めろ",
	"命を守れ": "命を守れ",
	"力だけで戦え": "力だけで戦え",
	"援護を頼む": "援護を頼む",
	"直接指示": "直接指示",
}

const INTERNAL_TACTIC_TO_EXTERNAL := {
	"まかせた": "BALANCED",
	"全力で攻めろ": "GO_ALL_OUT",
	"命を守れ": "STAY_SAFE",
	"力だけで戦え": "NO_SPELLS",
	"援護を頼む": "SUPPORT",
	"直接指示": "MANUAL",
}

var _state_machine
var _ai
var _turn_resolver
var _rng := RandomNumberGenerator.new()

var _payload: Dictionary = {}
var _party: Array = []
var _enemies: Array = []
var _inventory: Array[Dictionary] = []
var _messages: Array[String] = []
var _selected_command: int = 0
var _selected_tactic_slot: int = 0
var _selected_tactic_index: int = 0
var _selected_item_index: int = 0
var _selected_item_target_index: int = 0
var _direct_queue: Array[int] = []
var _current_direct_queue_index: int = 0
var _selected_skill_index: int = 0
var _selected_target_index: int = 0
var _direct_actions: Dictionary = {}
var _turn_number: int = 0
var _battle_outcome: String = ""

@onready var _enemy_label: Label = %EnemyLabel
@onready var _party_label: Label = %PartyLabel
@onready var _command_label: Label = %CommandLabel
@onready var _help_label: Label = %HelpLabel
@onready var _message_label: Label = %MessageLabel


static func build_tower_demo_payload() -> Dictionary:
	return build_encounter_payload(
		[
			{"monster_id": "MON-001", "nickname": "ケダ", "level": 9, "tactic": "全力で攻めろ"},
			{"monster_id": "MON-003", "level": 9, "tactic": "命を守れ"},
			{"monster_id": "MON-008", "level": 10, "tactic": "援護を頼む"},
		],
		[
			{"item_id": "item_heal_dryherb", "quantity": 2},
			{"item_id": "item_buff_ironmeal", "quantity": 1},
			{"item_id": "item_bait_drycrumb", "quantity": 1},
		],
		"ZONE-VIL-TOWER",
		1977
	)


static func build_encounter_payload(
	party: Array = [],
	inventory: Array = [],
	encounter_zone_id: String = "ZONE-VIL-TOWER",
	seed: int = 1977
) -> Dictionary:
	var normalized_party := party.duplicate(true)
	if normalized_party.is_empty():
		normalized_party = [
			{"monster_id": "MON-001", "nickname": "ケダ", "level": 9, "tactic": "全力で攻めろ"},
			{"monster_id": "MON-003", "level": 9, "tactic": "命を守れ"},
			{"monster_id": "MON-008", "level": 10, "tactic": "援護を頼む"},
		]
	var normalized_inventory := inventory.duplicate(true)
	if normalized_inventory.is_empty():
		normalized_inventory = [
			{"item_id": "item_heal_dryherb", "quantity": 2},
			{"item_id": "item_buff_ironmeal", "quantity": 1},
			{"item_id": "item_bait_drycrumb", "quantity": 1},
		]

	var encounter_zone = null
	var main_loop = Engine.get_main_loop()
	if main_loop != null and main_loop.root != null:
		var game_manager = main_loop.root.get_node_or_null("/root/GameManager")
		if game_manager != null:
			game_manager.bootstrap()
			encounter_zone = game_manager.get_encounter_zone(encounter_zone_id)
	var enemies := []
	if encounter_zone != null:
		for entry_variant in encounter_zone.entries:
			if not entry_variant is Dictionary:
				continue
			var entry: Dictionary = entry_variant
			(
				enemies
				. append(
					{
						"monster_id": String(entry.get("monster_id", "")),
						"level": maxi(int(entry.get("min_lv", 1)) - 1, 4),
						"tactic": "まかせた",
					}
				)
			)
			if enemies.size() >= 3:
				break
	if enemies.size() < 3:
		enemies = [
			{"monster_id": "MON-001", "level": 5, "tactic": "まかせた"},
			{"monster_id": "MON-002", "level": 5, "tactic": "まかせた"},
			{"monster_id": "MON-003", "level": 5, "tactic": "命を守れ"},
		]
	return {
		"seed": seed,
		"encounter_zone_id": encounter_zone_id,
		"party": normalized_party,
		"enemies": enemies,
		"inventory": normalized_inventory,
	}


func _ready() -> void:
	_state_machine = BattleStateMachineScript.new()
	add_child(_state_machine)
	_ai = BattleAIScript.new()
	add_child(_ai)
	_turn_resolver = TurnResolverScript.new()
	add_child(_turn_resolver)
	if _payload.is_empty():
		_payload = _normalize_payload({})
	_setup_battle()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if not event.is_pressed():
		return

	match _state_machine.current_state:
		BattleStateMachineScript.State.COMMAND_SELECT:
			_handle_command_input(event)
		BattleStateMachineScript.State.TACTIC_SELECT:
			_handle_tactic_input(event)
		BattleStateMachineScript.State.ITEM_SELECT:
			_handle_item_input(event)
		BattleStateMachineScript.State.DIRECT_SELECT:
			_handle_direct_input(event)
		BattleStateMachineScript.State.RESULT:
			if event.is_action_pressed("ui_accept"):
				_finish_battle()


func configure(payload: Dictionary) -> void:
	_payload = _normalize_payload(payload)
	if is_inside_tree():
		_setup_battle()


func start_demo_battle(payload: Dictionary = {}) -> void:
	configure(payload)


func get_state_snapshot() -> Dictionary:
	return {
		"state": int(_state_machine.current_state),
		"state_name": _state_name(_state_machine.current_state),
		"outcome": _snapshot_outcome(),
		"turn": _turn_number,
		"party": _serialize_fighters(_party, true),
		"enemies": _serialize_fighters(_enemies, true),
		"inventory": _serialize_inventory(),
		"messages": _messages.duplicate(),
	}


func get_battle_snapshot() -> Dictionary:
	return {
		"state": int(_state_machine.current_state),
		"state_name": _state_name(_state_machine.current_state),
		"outcome": _battle_outcome if not _battle_outcome.is_empty() else "ongoing",
		"party": _serialize_fighters(_party, false),
		"enemies": _serialize_fighters(_enemies, false),
		"inventory": _serialize_inventory(),
		"recruit_contexts": _serialize_recruit_contexts(),
		"messages": _messages.duplicate(),
	}


func run_player_turn(command_id: String, options: Dictionary = {}) -> void:
	match command_id:
		"tactics":
			_apply_tactic_change(options)
		"item":
			_execute_item_turn(options)
		"escape", "run":
			_execute_escape_turn()
		_:
			_execute_fight_turn(options)


func choose_command(command_id: String, options: Dictionary = {}) -> void:
	run_player_turn(command_id, options)


func set_tactic(slot: int, tactic_name: String) -> void:
	run_player_turn("tactics", {"slot": slot, "tactic": tactic_name})


func queue_manual_action(
	slot: int,
	skill_id: String,
	target_side: String,
	target_index: int,
	action_kind: String = "skill"
) -> void:
	_direct_actions[slot] = {
		"kind": action_kind,
		"skill_id": skill_id,
		"target_side": target_side,
		"target_index": target_index,
	}


func debug_set_current_hp(side: String, slot: int, hp: int) -> void:
	var fighter = _fighter_from_side(side, slot)
	if fighter == null:
		return
	fighter.current_hp = clampi(hp, 0, fighter.max_hp)


func _setup_battle() -> void:
	_payload = _normalize_payload(_payload)
	_rng.seed = int(_payload.get("seed", 1))
	_party.clear()
	_enemies.clear()
	_inventory = _normalize_inventory(Array(_payload.get("inventory", [])))
	_messages.clear()
	_battle_outcome = ""
	_direct_actions.clear()
	_direct_queue.clear()
	_turn_number = 0
	_selected_command = 0
	_selected_tactic_slot = 0
	_selected_tactic_index = 0
	_selected_item_index = 0
	_selected_item_target_index = 0
	_selected_skill_index = 0
	_selected_target_index = 0

	for index in range(Array(_payload.get("party", [])).size()):
		var setup: Dictionary = Array(_payload.get("party", []))[index]
		var fighter = BattleFighterScript.new()
		_party.append(fighter.setup_from_dict(setup, true, index))

	for index in range(Array(_payload.get("enemies", [])).size()):
		var setup: Dictionary = Array(_payload.get("enemies", []))[index]
		var fighter = BattleFighterScript.new()
		_enemies.append(fighter.setup_from_dict(setup, false, index))

	_push_message("%s が あらわれた" % _format_enemy_names())
	_push_message("4コマンドで さばけ。難所だけ めいれいする。")
	_enter_command_select()


func _handle_command_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_selected_command = (_selected_command + 1) % COMMANDS.size()
		_update_ui()
	elif event.is_action_pressed("ui_up"):
		_selected_command = posmod(_selected_command - 1, COMMANDS.size())
		_update_ui()
	elif event.is_action_pressed("ui_accept"):
		var command_id = String(COMMANDS[_selected_command]["id"])
		match command_id:
			"fight":
				if _prepare_direct_queue():
					_enter_direct_select()
				else:
					run_player_turn("fight")
			"tactics":
				_enter_tactic_select()
			"item":
				if _has_battle_items():
					_enter_item_select()
				else:
					_push_message("つかえる どうぐが ない")
					_update_ui()
			"escape":
				run_player_turn("escape")


func _handle_tactic_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_selected_tactic_slot = posmod(_selected_tactic_slot - 1, _party.size())
	elif event.is_action_pressed("ui_right"):
		_selected_tactic_slot = (_selected_tactic_slot + 1) % _party.size()
	elif event.is_action_pressed("ui_down"):
		_selected_tactic_index = (_selected_tactic_index + 1) % TACTIC_OPTIONS.size()
	elif event.is_action_pressed("ui_up"):
		_selected_tactic_index = posmod(_selected_tactic_index - 1, TACTIC_OPTIONS.size())
	elif event.is_action_pressed("ui_accept"):
		run_player_turn(
			"tactics",
			{"slot": _selected_tactic_slot, "tactic": TACTIC_OPTIONS[_selected_tactic_index]}
		)
		_enter_command_select()
		return
	elif event.is_action_pressed("ui_cancel"):
		_enter_command_select()
		return
	_update_ui()


func _handle_item_input(event: InputEvent) -> void:
	var battle_items = _get_battle_items()
	if battle_items.is_empty():
		_enter_command_select()
		return
	if event.is_action_pressed("ui_down"):
		_selected_item_index = (_selected_item_index + 1) % battle_items.size()
	elif event.is_action_pressed("ui_up"):
		_selected_item_index = posmod(_selected_item_index - 1, battle_items.size())
	elif event.is_action_pressed("ui_left"):
		_selected_item_target_index = posmod(
			_selected_item_target_index - 1,
			_target_count_for_item(battle_items[_selected_item_index])
		)
	elif event.is_action_pressed("ui_right"):
		_selected_item_target_index = (
			(_selected_item_target_index + 1)
			% _target_count_for_item(battle_items[_selected_item_index])
		)
	elif event.is_action_pressed("ui_accept"):
		var item_entry: Dictionary = battle_items[_selected_item_index]
		run_player_turn(
			"item",
			{
				"item_index": int(item_entry.get("_inventory_index", -1)),
				"target_side": _item_target_side(item_entry),
				"target_index": _selected_item_target_index,
			}
		)
		return
	elif event.is_action_pressed("ui_cancel"):
		_enter_command_select()
		return
	_update_ui()


func _handle_direct_input(event: InputEvent) -> void:
	var fighter = _current_direct_fighter()
	if fighter == null:
		run_player_turn("fight", {"direct_actions": _direct_actions})
		return
	var skill_count = _direct_skill_count(fighter)
	if skill_count <= 0:
		run_player_turn("fight", {"direct_actions": _direct_actions})
		return
	if event.is_action_pressed("ui_down"):
		_selected_skill_index = (_selected_skill_index + 1) % skill_count
	elif event.is_action_pressed("ui_up"):
		_selected_skill_index = posmod(_selected_skill_index - 1, skill_count)
	elif event.is_action_pressed("ui_left"):
		_selected_target_index = posmod(_selected_target_index - 1, _direct_target_count(fighter))
	elif event.is_action_pressed("ui_right"):
		_selected_target_index = (_selected_target_index + 1) % _direct_target_count(fighter)
	elif event.is_action_pressed("ui_accept"):
		var usable_skills = _direct_usable_skills(fighter)
		var skill = usable_skills[_selected_skill_index]
		var target_side = _target_side_for_skill(skill)
		_direct_actions[fighter.slot_index] = {
			"kind": "skill",
			"skill_id": skill.skill_id,
			"target_side": target_side,
			"target_index": _selected_target_index,
		}
		_current_direct_queue_index += 1
		_selected_skill_index = 0
		_selected_target_index = 0
		if _current_direct_queue_index >= _direct_queue.size():
			run_player_turn("fight", {"direct_actions": _direct_actions})
			return
	elif event.is_action_pressed("ui_cancel"):
		_direct_actions.clear()
		_enter_command_select()
		return
	_update_ui()


func _enter_command_select() -> void:
	_state_machine.transition_to(BattleStateMachineScript.State.COMMAND_SELECT)
	_update_ui()


func _enter_tactic_select() -> void:
	_state_machine.transition_to(BattleStateMachineScript.State.TACTIC_SELECT)
	_selected_tactic_index = TACTIC_OPTIONS.find(String(_party[_selected_tactic_slot].tactic))
	if _selected_tactic_index == -1:
		_selected_tactic_index = 0
	_update_ui()


func _enter_item_select() -> void:
	_state_machine.transition_to(BattleStateMachineScript.State.ITEM_SELECT)
	_selected_item_index = 0
	_selected_item_target_index = 0
	_update_ui()


func _enter_direct_select() -> void:
	_state_machine.transition_to(BattleStateMachineScript.State.DIRECT_SELECT)
	_current_direct_queue_index = 0
	_selected_skill_index = 0
	_selected_target_index = 0
	_direct_actions.clear()
	_update_ui()


func _execute_fight_turn(options: Dictionary) -> void:
	_state_machine.transition_to(BattleStateMachineScript.State.TURN_RESOLVE)
	_turn_number += 1
	var direct_actions: Dictionary = Dictionary(options.get("direct_actions", {}))
	var actions: Array[Dictionary] = []
	for fighter in _party:
		if fighter == null or not fighter.is_alive():
			continue
		if String(fighter.tactic) == "直接指示" and direct_actions.has(fighter.slot_index):
			actions.append(_materialize_direct_action(fighter, direct_actions[fighter.slot_index]))
		else:
			actions.append(_ai.choose_action(fighter, _party, _enemies))
	for fighter in _enemies:
		if fighter == null or not fighter.is_alive():
			continue
		actions.append(_ai.choose_action(fighter, _enemies, _party))

	var result = _turn_resolver.resolve_turn(_party, _enemies, actions, _rng)
	for message in Array(result.get("messages", [])):
		_push_message(String(message))
	_after_turn_resolution()


func _execute_item_turn(options: Dictionary) -> void:
	var inventory_index := int(options.get("item_index", -1))
	if inventory_index < 0 or inventory_index >= _inventory.size():
		_push_message("そのどうぐは つかえない")
		_enter_command_select()
		return
	var item_entry: Dictionary = _inventory[inventory_index]
	var item = _load_item(String(item_entry.get("item_id", "")))
	if item == null:
		_push_message("どうぐが みつからない")
		_enter_command_select()
		return
	item_entry["quantity"] = maxi(int(item_entry.get("quantity", 0)) - 1, 0)
	_inventory[inventory_index] = item_entry
	_prune_empty_inventory()
	_turn_number += 1
	var acting_fighter = _first_alive(_party)
	var actions: Array[Dictionary] = [
		{
			"kind": "item",
			"actor": acting_fighter,
			"item": item,
			"target_side": String(options.get("target_side", "ally")),
			"target_index": int(options.get("target_index", 0)),
		}
	]
	for fighter in _party:
		if fighter == null or not fighter.is_alive() or fighter == acting_fighter:
			continue
		actions.append(_ai.choose_action(fighter, _party, _enemies))
	for fighter in _enemies:
		if fighter == null or not fighter.is_alive():
			continue
		actions.append(_ai.choose_action(fighter, _enemies, _party))
	var result = _turn_resolver.resolve_turn(_party, _enemies, actions, _rng)
	for message in Array(result.get("messages", [])):
		_push_message(String(message))
	_after_turn_resolution()


func _execute_escape_turn() -> void:
	_state_machine.transition_to(BattleStateMachineScript.State.ESCAPE_ATTEMPT)
	_turn_number += 1
	var chance = _calc_escape_chance()
	if _rng.randf() <= chance:
		_battle_outcome = "escape"
		_push_message("うまく にげきれた")
		_state_machine.transition_to(BattleStateMachineScript.State.RESULT)
	else:
		_push_message("にげきれない")
		var enemy_actions: Array[Dictionary] = []
		for fighter in _enemies:
			if fighter == null or not fighter.is_alive():
				continue
			enemy_actions.append(_ai.choose_action(fighter, _enemies, _party))
		var result = _turn_resolver.resolve_turn(_party, _enemies, enemy_actions, _rng)
		for message in Array(result.get("messages", [])):
			_push_message(String(message))
		_after_turn_resolution()


func _after_turn_resolution() -> void:
	if _all_defeated(_enemies):
		_battle_outcome = "victory"
		_push_message("しょうりした")
		_state_machine.transition_to(BattleStateMachineScript.State.RESULT)
	elif _all_defeated(_party):
		_battle_outcome = "defeat"
		_push_message("ぜんめつした")
		_state_machine.transition_to(BattleStateMachineScript.State.RESULT)
	else:
		_enter_command_select()


func _finish_battle() -> void:
	_state_machine.transition_to(BattleStateMachineScript.State.EXIT)
	(
		battle_finished
		. emit(
			{
				"outcome": _battle_outcome,
				"party": _serialize_fighters(_party),
				"enemies": _serialize_fighters(_enemies),
				"inventory": _inventory.duplicate(true),
				"encounter_zone_id": String(_payload.get("encounter_zone_id", "")),
				"recruit_contexts": _serialize_recruit_contexts(),
				"messages": _messages.duplicate(),
			}
		)
	)
	queue_free()


func _prepare_direct_queue() -> bool:
	_direct_queue.clear()
	for fighter in _party:
		if fighter != null and fighter.is_alive() and String(fighter.tactic) == "直接指示":
			_direct_queue.append(fighter.slot_index)
	_current_direct_queue_index = 0
	_direct_actions.clear()
	return not _direct_queue.is_empty()


func _apply_tactic_change(options: Dictionary) -> void:
	var slot = clampi(int(options.get("slot", 0)), 0, maxi(_party.size() - 1, 0))
	var tactic_name = _normalize_tactic(String(options.get("tactic", "まかせた")))
	_party[slot].tactic = StringName(tactic_name)
	_push_message("%s の さくせんを %s にした" % [_party[slot].display_name, tactic_name])
	_update_ui()


func _materialize_direct_action(fighter, action_options: Dictionary) -> Dictionary:
	var action_kind = String(action_options.get("kind", "skill"))
	if action_kind == "guard":
		return {
			"kind": "pass",
			"actor": fighter,
			"target_side": "ally",
			"target_index": fighter.slot_index,
		}
	if action_kind == "attack":
		for skill in fighter.skills:
			if skill.category == "physical" and fighter.can_use_skill(skill):
				return {
					"kind": "skill",
					"actor": fighter,
					"skill": skill,
					"target_side": String(action_options.get("target_side", "enemy")),
					"target_index": int(action_options.get("target_index", 0)),
				}
	var skill_id = String(action_options.get("skill_id", ""))
	for skill in fighter.skills:
		if skill.skill_id == skill_id and fighter.can_use_skill(skill):
			return {
				"kind": "skill",
				"actor": fighter,
				"skill": skill,
				"target_side":
				String(action_options.get("target_side", _target_side_for_skill(skill))),
				"target_index": int(action_options.get("target_index", 0)),
			}
	return _ai.choose_action(fighter, _party, _enemies)


func _current_direct_fighter():
	if _current_direct_queue_index >= _direct_queue.size():
		return null
	var slot = _direct_queue[_current_direct_queue_index]
	for fighter in _party:
		if fighter != null and fighter.slot_index == slot:
			return fighter
	return null


func _direct_usable_skills(fighter) -> Array:
	var usable: Array = []
	for skill in fighter.skills:
		if fighter.can_use_skill(skill):
			usable.append(skill)
	return usable


func _direct_skill_count(fighter) -> int:
	return _direct_usable_skills(fighter).size()


func _direct_target_count(fighter) -> int:
	var usable_skills = _direct_usable_skills(fighter)
	if usable_skills.is_empty():
		return 1
	var skill = usable_skills[_selected_skill_index]
	var target_side = _target_side_for_skill(skill)
	return maxi(_party.size() if target_side == "ally" else _enemies.size(), 1)


func _target_side_for_skill(skill) -> String:
	if skill.target_scope in ["ally_single", "ally_all", "self"]:
		return "ally"
	return "enemy"


func _has_battle_items() -> bool:
	return not _get_battle_items().is_empty()


func _get_battle_items() -> Array[Dictionary]:
	var battle_items: Array[Dictionary] = []
	for index in range(_inventory.size()):
		var item_entry: Dictionary = _inventory[index]
		if int(item_entry.get("quantity", 0)) <= 0:
			continue
		var item = _load_item(String(item_entry.get("item_id", "")))
		if item == null:
			continue
		if item.item_kind != "consumable":
			continue
		if item.subtype == "field":
			continue
		var copy_entry = item_entry.duplicate(true)
		copy_entry["_inventory_index"] = index
		copy_entry["_target_scope"] = item.target_scope
		copy_entry["_name_jp"] = item.name_jp
		battle_items.append(copy_entry)
	return battle_items


func _item_target_side(item_entry: Dictionary) -> String:
	var target_scope = String(item_entry.get("_target_scope", "ally_single"))
	if target_scope.begins_with("enemy"):
		return "enemy"
	return "ally"


func _target_count_for_item(item_entry: Dictionary) -> int:
	return maxi(_enemies.size() if _item_target_side(item_entry) == "enemy" else _party.size(), 1)


func _calc_escape_chance() -> float:
	var ally_speed = _average_speed(_party)
	var enemy_speed = maxf(_average_speed(_enemies), 1.0)
	var bonus = 0.0
	for fighter in _party:
		if fighter != null and fighter.is_alive():
			bonus += float(fighter.escape_bonus)
	return clampf((ally_speed / enemy_speed) * 0.5 + bonus / 300.0, 0.1, 0.95)


func _average_speed(fighters: Array) -> float:
	var total := 0.0
	var count := 0.0
	for fighter in fighters:
		if fighter == null or not fighter.is_alive():
			continue
		total += float(fighter.get_effective_stat("spd"))
		count += 1.0
	if count <= 0.0:
		return 1.0
	return total / count


func _first_alive(fighters: Array):
	for fighter in fighters:
		if fighter != null and fighter.is_alive():
			return fighter
	return fighters[0] if not fighters.is_empty() else null


func _all_defeated(fighters: Array) -> bool:
	for fighter in fighters:
		if fighter != null and fighter.is_alive():
			return false
	return true


func _serialize_fighters(fighters: Array, use_external_tactics: bool = false) -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	for fighter in fighters:
		if fighter == null:
			continue
		var tactic_name = (
			_external_tactic(String(fighter.tactic))
			if use_external_tactics
			else _legacy_tactic_label(String(fighter.tactic))
		)
		(
			serialized
			. append(
				{
					"slot": fighter.slot_index,
					"instance_id": fighter.instance_id,
					"monster_id":
					fighter.monster_data.monster_id if fighter.monster_data != null else "",
					"nickname": fighter.nickname,
					"name": fighter.display_name,
					"level": fighter.level,
					"hp": fighter.current_hp,
					"max_hp": fighter.max_hp,
					"mp": fighter.current_mp,
					"max_mp": fighter.max_mp,
					"tactic": tactic_name,
					"tactic_code": _external_tactic(String(fighter.tactic)),
					"alive": fighter.is_alive(),
					"ailments": fighter.ailments.duplicate(true),
					"statuses": fighter.ailments.duplicate(true),
				}
			)
		)
	return serialized


func _serialize_inventory() -> Array[Dictionary]:
	return _inventory.duplicate(true)


func _serialize_recruit_contexts() -> Array[Dictionary]:
	var contexts: Array[Dictionary] = []
	for fighter in _enemies:
		if fighter == null or fighter.monster_data == null:
			continue
		(
			contexts
			. append(
				{
					"slot": fighter.slot_index,
					"monster_id": fighter.monster_data.monster_id,
					"name": fighter.monster_name,
					"level": fighter.level,
					"rank": String(fighter.monster_data.rank),
					"family": String(fighter.monster_data.family),
					"base_recruit": int(fighter.monster_data.base_recruit),
					"scoutable": bool(fighter.monster_data.scoutable),
					"alive": fighter.is_alive(),
					"hp_ratio": fighter.hp_ratio(),
					"ailments": fighter.ailments.duplicate(true),
					"recruit_bonus": fighter.recruit_bonus,
					"last_bait_item_id": fighter.last_bait_item_id,
					"last_bait_bonus": fighter.last_bait_bonus,
					"bait_family_match": fighter.bait_family_match,
				}
			)
		)
	return contexts


func _normalize_payload(payload: Dictionary) -> Dictionary:
	var normalized = build_tower_demo_payload()
	normalized.merge(payload.duplicate(true), true)
	if payload.has("allies"):
		normalized["party"] = Array(payload.get("allies", [])).duplicate(true)
	if payload.has("party"):
		normalized["party"] = Array(payload.get("party", [])).duplicate(true)
	if payload.has("enemies"):
		normalized["enemies"] = Array(payload.get("enemies", [])).duplicate(true)
	if payload.has("inventory"):
		normalized["inventory"] = Array(payload.get("inventory", [])).duplicate(true)

	var normalized_party: Array = []
	for setup_variant in Array(normalized.get("party", [])):
		if setup_variant is Dictionary:
			normalized_party.append(_normalize_setup_entry(setup_variant))
	normalized["party"] = normalized_party

	var normalized_enemies: Array = []
	for setup_variant in Array(normalized.get("enemies", [])):
		if setup_variant is Dictionary:
			normalized_enemies.append(_normalize_setup_entry(setup_variant))
	normalized["enemies"] = normalized_enemies

	normalized["inventory"] = _normalize_inventory(Array(normalized.get("inventory", [])))
	return normalized


func _normalize_setup_entry(entry: Dictionary) -> Dictionary:
	var normalized = entry.duplicate(true)
	normalized["tactic"] = _normalize_tactic(String(normalized.get("tactic", "まかせた")))
	return normalized


func _normalize_inventory(entries: Array) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []
	for entry_variant in entries:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant.duplicate(true)
		if entry.has("count") and not entry.has("quantity"):
			entry["quantity"] = int(entry.get("count", 0))
		entry["quantity"] = int(entry.get("quantity", 0))
		normalized.append(entry)
	return normalized


func _normalize_tactic(tactic_name: String) -> String:
	return String(EXTERNAL_TACTIC_TO_INTERNAL.get(tactic_name, tactic_name))


func _external_tactic(tactic_name: String) -> String:
	return String(INTERNAL_TACTIC_TO_EXTERNAL.get(tactic_name, tactic_name))


func _legacy_tactic_label(tactic_name: String) -> String:
	return _normalize_tactic(tactic_name)


func _fighter_from_side(side: String, slot: int):
	var fighters = _party if side == "ally" else _enemies
	for fighter in fighters:
		if fighter != null and fighter.slot_index == slot:
			return fighter
	return null


func _snapshot_outcome() -> String:
	if _battle_outcome == "escape":
		return "escaped"
	if _battle_outcome.is_empty():
		return "ongoing"
	return _battle_outcome


func _state_name(state_id: int) -> String:
	var state_name := "UNKNOWN"
	match state_id:
		BattleStateMachineScript.State.ENCOUNTER_INTRO:
			state_name = "ENCOUNTER_INTRO"
		BattleStateMachineScript.State.COMMAND_SELECT:
			state_name = "COMMAND_SELECT"
		BattleStateMachineScript.State.TACTIC_SELECT:
			state_name = "TACTIC_SELECT"
		BattleStateMachineScript.State.ITEM_SELECT:
			state_name = "ITEM_SELECT"
		BattleStateMachineScript.State.DIRECT_SELECT:
			state_name = "DIRECT_SELECT"
		BattleStateMachineScript.State.TURN_RESOLVE:
			state_name = "TURN_RESOLVE"
		BattleStateMachineScript.State.ESCAPE_ATTEMPT:
			state_name = "ESCAPE_ATTEMPT"
		BattleStateMachineScript.State.TURN_END:
			state_name = "TURN_END"
		BattleStateMachineScript.State.VICTORY:
			state_name = "VICTORY"
		BattleStateMachineScript.State.DEFEAT:
			state_name = "DEFEAT"
		BattleStateMachineScript.State.ESCAPE_SUCCESS:
			state_name = "ESCAPE_SUCCESS"
		BattleStateMachineScript.State.RESULT:
			state_name = "RESULT"
		BattleStateMachineScript.State.EXIT:
			state_name = "EXIT"
	return state_name


func _load_encounter_zone(zone_id: String):
	var main_loop = Engine.get_main_loop()
	if main_loop == null or main_loop.root == null:
		return null
	var game_manager = main_loop.root.get_node_or_null("/root/GameManager")
	if game_manager == null:
		return null
	game_manager.call("bootstrap")
	return game_manager.call("get_encounter_zone", zone_id)


func _load_item(item_id: String):
	var main_loop = Engine.get_main_loop()
	if main_loop == null or main_loop.root == null:
		return null
	var game_manager = main_loop.root.get_node_or_null("/root/GameManager")
	if game_manager == null:
		return null
	game_manager.call("bootstrap")
	return game_manager.call("load_resource_data", "items", item_id)


func _format_enemy_names() -> String:
	var names: Array[String] = []
	for fighter in _enemies:
		if fighter != null:
			names.append(fighter.display_name)
	return " / ".join(names)


func _prune_empty_inventory() -> void:
	var kept: Array[Dictionary] = []
	for item_entry in _inventory:
		if int(item_entry.get("quantity", 0)) > 0:
			kept.append(item_entry)
	_inventory = kept


func _push_message(message: String) -> void:
	_messages.append(message)
	if _messages.size() > 6:
		_messages = _messages.slice(_messages.size() - 6, _messages.size())


func _update_ui() -> void:
	_enemy_label.text = BattleTextBuilderScript.build_enemy_text(self)
	_party_label.text = BattleTextBuilderScript.build_party_text(self)
	_command_label.text = BattleTextBuilderScript.build_command_text(self)
	_help_label.text = BattleTextBuilderScript.build_help_text(self)
	_message_label.text = "\n".join(_messages)
