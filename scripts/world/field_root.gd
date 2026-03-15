extends Node2D

const Layout = preload("res://scripts/world/starting_village_layout.gd")

var _player_tile: Vector2i = Layout.START_TILE
var _facing: Vector2i = Vector2i.DOWN
var _message_log: Array[String] = []
var _flags := {
	"tag_trace": false,
	"headcount_beam": false,
	"blank_stone": false,
	"warning_stake": false,
	"tower_approach_seen": false,
	"tower_threshold_seen": false,
}
var _encounter_triggered: bool = false

@onready var _player: Node2D = $Player
@onready var _camera: Camera2D = $Camera2D
@onready var _status_label: Label = %StatusLabel
@onready var _objective_label: Label = %ObjectiveLabel
@onready var _message_label: Label = %MessageLabel


func _ready() -> void:
	_camera.limit_right = Layout.MAP_PIXEL_SIZE.x
	_camera.limit_bottom = Layout.MAP_PIXEL_SIZE.y
	_apply_player_position()
	_push_message("小さな村の朝。井戸広場から北へ進むと、塔がある。")
	_push_message("家畜札の削り跡を確かめてから、塔へ向かう。")
	_update_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		interact()
		return

	if event.is_action_pressed("ui_left"):
		move_player(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		move_player(Vector2i.RIGHT)
	elif event.is_action_pressed("ui_up"):
		move_player(Vector2i.UP)
	elif event.is_action_pressed("ui_down"):
		move_player(Vector2i.DOWN)


func move_player(direction: Vector2i) -> bool:
	if direction == Vector2i.ZERO:
		return false

	_facing = direction
	var target := _player_tile + direction
	if not Layout.in_bounds(target) or Layout.is_blocked(target):
		_push_message("進めない。")
		return false

	_player_tile = target
	_apply_player_position()
	_handle_tile_events()
	_update_ui()
	return true


func interact() -> String:
	var target := _player_tile + _facing
	var message := _resolve_interaction(target)
	_push_message(message)
	_update_ui()
	return message


func set_player_tile(tile: Vector2i) -> void:
	if not Layout.in_bounds(tile):
		return
	_player_tile = tile
	_apply_player_position()
	_handle_tile_events()
	_update_ui()


func get_state_snapshot() -> Dictionary:
	return {
		"player_tile": {"x": _player_tile.x, "y": _player_tile.y},
		"facing": {"x": _facing.x, "y": _facing.y},
		"flags": _flags.duplicate(true),
		"encounter_triggered": _encounter_triggered,
		"last_message": _message_log[-1] if not _message_log.is_empty() else "",
	}


func _apply_player_position() -> void:
	_player.call("set_tile_position", _player_tile)


func _handle_tile_events() -> void:
	if not _flags["tower_approach_seen"] and Layout.TOWER_APPROACH_ZONE.has_point(_player_tile):
		_flags["tower_approach_seen"] = true
		_push_message("北道に入ると、家畜の気配が消えて塔だけが残る。")

	if (
		not _encounter_triggered
		and _flags["tag_trace"]
		and Layout.ENCOUNTER_ZONE.has_point(_player_tile)
	):
		_encounter_triggered = true
		_push_message("タグツツキの群れが札をつつき、道をふさいだ。遭遇の気配。")


func _resolve_interaction(target: Vector2i) -> String:
	var message := "調べられるものはない。"

	if target == Layout.INSPECT_POINTS["tag_trace"]:
		_flags["tag_trace"] = true
		message = "削れた家畜札。村の札なのに、人名を消した跡がある。"
	elif target == Layout.INSPECT_POINTS["headcount_beam"]:
		_flags["headcount_beam"] = true
		message = "梁の刻み傷。頭数の数えが一つ多い。"
	elif target == Layout.INSPECT_POINTS["blank_stone"]:
		_flags["blank_stone"] = true
		message = "空碑だ。死者の名ではなく、消えた者の名を置く場所に見える。"
	elif target == Layout.INSPECT_POINTS["warning_stake"]:
		_flags["warning_stake"] = true
		message = "古い杭。読めるのは『近づくな』ではなく『返るな』に近い。"
	elif target == Layout.INSPECT_POINTS["tower_threshold"]:
		_flags["tower_threshold_seen"] = true
		if _flags["tag_trace"]:
			message = "塔の溝幅が家畜札と合う。生活道具と門が同じ寸法をしている。"
		else:
			message = "扉脇の細い溝。何か札のようなものを差し込めそうだ。"
	elif target == Layout.NPC_POINTS["elder"]:
		message = "長老は視線を逸らす。『上の方には、昔から行かん』。"
	elif target == Layout.NPC_POINTS["record_keeper"]:
		message = "記録番が帳面を閉じる。『札の削れは昔の癖だ。気にするな』。"
	elif target == Layout.NPC_POINTS["barn_keeper"]:
		message = "畜舎主は藁を払う。『数が合わん日は、数え直すしかねえ』。"
	elif target == Layout.NPC_POINTS["well_woman"]:
		message = "井戸端の女は声を落とす。『昔も何人か、上へ行って減ったよ』。"
	elif target == Layout.NPC_POINTS["child"]:
		message = "子どもは塔を指ささない。『あっちの高いの、夜は見ないほうがいい』。"
	elif _encounter_triggered and Layout.TOWER_THRESHOLD_ZONE.has_point(target):
		message = "扉が呼吸している。群れを越えれば、塔に触れられそうだ。"

	return message


func _push_message(message: String) -> void:
	_message_log.append(message)
	if _message_log.size() > 3:
		_message_log = _message_log.slice(_message_log.size() - 3, _message_log.size())


func _update_ui() -> void:
	var objective := "目的: 記録小屋の札を確かめ、北道から塔へ向かう"
	if _flags["tag_trace"] and not _encounter_triggered:
		objective = "目的: 北道を抜けて塔前荒地へ進む"
	elif _encounter_triggered:
		objective = "目的: 遭遇導線を確認し、塔の扉まで触れる"

	_status_label.text = (
		"Tile %02d,%02d  Facing %s"
		% [
			_player_tile.x,
			_player_tile.y,
			_direction_name(_facing),
		]
	)
	_objective_label.text = objective
	_message_label.text = "\n".join(_message_log)


func _direction_name(direction: Vector2i) -> String:
	if direction == Vector2i.UP:
		return "N"
	if direction == Vector2i.DOWN:
		return "S"
	if direction == Vector2i.LEFT:
		return "W"
	if direction == Vector2i.RIGHT:
		return "E"
	return "?"
