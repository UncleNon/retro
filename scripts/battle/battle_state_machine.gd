class_name BattleStateMachine
extends Node

signal state_changed(old_state: int, new_state: int)

enum State {
	ENCOUNTER_INTRO,
	COMMAND_SELECT,
	TACTIC_SELECT,
	ITEM_SELECT,
	DIRECT_SELECT,
	TURN_RESOLVE,
	ESCAPE_ATTEMPT,
	TURN_END,
	VICTORY,
	DEFEAT,
	ESCAPE_SUCCESS,
	RESULT,
	EXIT,
}

var current_state: State = State.ENCOUNTER_INTRO


func transition_to(new_state: State) -> void:
	var old_state := current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)
