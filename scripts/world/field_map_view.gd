extends Node2D

const COLOR_GRASS := Color("6a8f5d")
const COLOR_PATH := Color("a18869")
const COLOR_PATH_NORTH := Color("95785e")
const COLOR_PATH_APPROACH := Color("7d6552")
const COLOR_LOT := Color("739566")
const COLOR_BUILDING := Color("6f5a47")
const COLOR_ROOF := Color("8b6c57")
const COLOR_FENCE := Color("4b3f34")
const COLOR_WELL := Color("647b8a")
const COLOR_GRAVE := Color("8c8c8c")
const COLOR_TOWER := Color("4b4f5d")
const COLOR_TOWER_SHADOW := Color("2d3038")
const COLOR_TOWER_CAP := Color("5a6070")

var _layout = null


func _ready() -> void:
	queue_redraw()


func configure(layout) -> void:
	_layout = layout
	queue_redraw()


func _draw() -> void:
	if _layout == null:
		return
	draw_rect(Rect2(Vector2.ZERO, _layout.map_pixel_size), COLOR_GRASS)
	for rect_row in _layout.get_rect_rows():
		_draw_rect_row(rect_row)
	_draw_markers()


func _draw_rect_row(rect_row: Dictionary) -> void:
	var rect: Rect2i = rect_row.get("rect", Rect2i())
	var rect_kind := String(rect_row.get("rect_kind", ""))
	var color_key := String(rect_row.get("draw_color_key", ""))
	match rect_kind:
		"terrain", "landmark":
			_draw_zone(rect, _color_for_key(color_key))
		"lot":
			_draw_zone(rect, COLOR_LOT)
		"building":
			_draw_zone(rect, COLOR_BUILDING)
		"roof":
			_draw_zone(rect, COLOR_ROOF)
		"fence":
			_draw_zone(rect, COLOR_FENCE)
		"tower":
			_draw_zone(rect, _color_for_key(color_key))


func _draw_zone(rect: Rect2i, color: Color) -> void:
	draw_rect(Rect2(rect.position * _layout.tile_size, rect.size * _layout.tile_size), color)


func _draw_markers() -> void:
	for point_row in _layout.get_point_rows():
		var point_tile: Vector2i = point_row.get("tile", Vector2i.ZERO)
		var point_kind := String(point_row.get("point_kind", ""))
		if point_kind == "inspect":
			var world_point: Vector2 = _layout.tile_to_world(point_tile) - Vector2(2, 2)
			draw_rect(Rect2(world_point, Vector2(4, 4)), Color("f4d35e"))
		elif point_kind == "npc":
			draw_circle(_layout.tile_to_world(point_tile), 3.0, Color("db5461"))
		elif point_kind == "facility":
			draw_circle(_layout.tile_to_world(point_tile), 3.0, Color("6dd3ce"))


func _color_for_key(color_key: String) -> Color:
	var palette := {
		"path": COLOR_PATH,
		"path_north": COLOR_PATH_NORTH,
		"path_approach": COLOR_PATH_APPROACH,
		"lot": COLOR_LOT,
		"building": COLOR_BUILDING,
		"roof": COLOR_ROOF,
		"fence": COLOR_FENCE,
		"well": COLOR_WELL,
		"grave": COLOR_GRAVE.darkened(0.18),
		"tower": COLOR_TOWER,
		"tower_shadow": COLOR_TOWER_SHADOW,
		"tower_cap": COLOR_TOWER_CAP,
	}
	return Color(palette.get(color_key, COLOR_GRASS))
