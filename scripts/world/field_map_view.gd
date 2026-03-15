extends Node2D

const Layout = preload("res://scripts/world/starting_village_layout.gd")

const COLOR_GRASS := Color("6a8f5d")
const COLOR_PATH := Color("a18869")
const COLOR_BUILDING := Color("6f5a47")
const COLOR_ROOF := Color("8b6c57")
const COLOR_FENCE := Color("4b3f34")
const COLOR_WELL := Color("647b8a")
const COLOR_GRAVE := Color("8c8c8c")
const COLOR_TOWER := Color("4b4f5d")
const COLOR_TOWER_SHADOW := Color("2d3038")


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Layout.MAP_PIXEL_SIZE), COLOR_GRASS)
	_draw_zone(Layout.SOUTH_ROAD, COLOR_PATH)
	_draw_zone(Layout.PLAZA, COLOR_PATH)
	_draw_zone(Layout.NORTH_ROAD, COLOR_PATH.darkened(0.08))
	_draw_zone(Layout.TOWER_APPROACH_ZONE, COLOR_PATH.darkened(0.18))
	_draw_zone(Layout.GRAVEYARD, COLOR_GRAVE.darkened(0.18))

	_draw_lot(Layout.HERO_HOME)
	_draw_lot(Layout.BARN)
	_draw_lot(Layout.ELDER_HOME)
	_draw_lot(Layout.RECORD_SHED)
	_draw_building(Layout.BUILDING_BODIES["hero_home"])
	_draw_building(Layout.BUILDING_BODIES["barn"])
	_draw_building(Layout.BUILDING_BODIES["elder_home"])
	_draw_building(Layout.BUILDING_BODIES["record_shed"])

	_draw_fences()
	_draw_zone(Layout.WELL, COLOR_WELL)
	_draw_tower()
	_draw_markers()


func _draw_zone(rect: Rect2i, color: Color) -> void:
	draw_rect(Rect2(rect.position * Layout.TILE_SIZE, rect.size * Layout.TILE_SIZE), color)


func _draw_lot(rect: Rect2i) -> void:
	draw_rect(
		Rect2(rect.position * Layout.TILE_SIZE, rect.size * Layout.TILE_SIZE),
		COLOR_GRASS.lightened(0.05)
	)


func _draw_building(rect: Rect2i) -> void:
	var base_rect := Rect2(rect.position * Layout.TILE_SIZE, rect.size * Layout.TILE_SIZE)
	draw_rect(base_rect, COLOR_BUILDING)
	draw_rect(
		Rect2(base_rect.position, Vector2(base_rect.size.x, Layout.TILE_SIZE * 2)), COLOR_ROOF
	)


func _draw_fences() -> void:
	for rect in Layout.FENCE_BLOCKERS:
		_draw_zone(rect, COLOR_FENCE)


func _draw_tower() -> void:
	var tower_position := Vector2(
		float((Layout.TOWER_CENTER_TILE.x - 9) * Layout.TILE_SIZE),
		float((Layout.TOWER_CENTER_TILE.y - 14) * Layout.TILE_SIZE)
	)
	var tower_size := Vector2(18 * Layout.TILE_SIZE, 28 * Layout.TILE_SIZE)
	draw_rect(Rect2(tower_position + Vector2(8, 8), tower_size), COLOR_TOWER_SHADOW)
	draw_rect(Rect2(tower_position, tower_size), COLOR_TOWER)
	draw_rect(
		Rect2(
			Vector2(float((Layout.TOWER_CENTER_TILE.x - 2) * Layout.TILE_SIZE), 0.0),
			Vector2(4 * Layout.TILE_SIZE, 4 * Layout.TILE_SIZE)
		),
		COLOR_TOWER_SHADOW.lightened(0.08)
	)


func _draw_markers() -> void:
	for point in Layout.INSPECT_POINTS.values():
		var world_point := Layout.tile_to_world(point) - Vector2(2, 2)
		draw_rect(Rect2(world_point, Vector2(4, 4)), Color("f4d35e"))

	for point in Layout.NPC_POINTS.values():
		draw_circle(Layout.tile_to_world(point), 3.0, Color("db5461"))
