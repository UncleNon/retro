extends Node2D

const BODY_COLOR := Color("2f5aa8")
const FACE_COLOR := Color("e9f1ff")

var _layout = null


func _ready() -> void:
	queue_redraw()


func configure(layout) -> void:
	_layout = layout


func set_tile_position(tile: Vector2i) -> void:
	if _layout == null:
		return
	position = _layout.tile_to_world(tile)


func _draw() -> void:
	draw_rect(Rect2(Vector2(-3, -4), Vector2(6, 8)), BODY_COLOR)
	draw_rect(Rect2(Vector2(-1, -2), Vector2(2, 2)), FACE_COLOR)
