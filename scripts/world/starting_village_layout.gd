class_name StartingVillageLayout
extends RefCounted

const TILE_SIZE := 8
const MAP_SIZE := Vector2i(96, 64)
const MAP_PIXEL_SIZE := Vector2i(MAP_SIZE.x * TILE_SIZE, MAP_SIZE.y * TILE_SIZE)
const START_TILE := Vector2i(16, 33)
const TOWER_CENTER_TILE := Vector2i(45, 6)
const TOWER_APPROACH_ZONE := Rect2i(34, 0, 23, 13)
const TOWER_THRESHOLD_ZONE := Rect2i(43, 1, 5, 4)
const ENCOUNTER_ZONE := Rect2i(39, 4, 13, 8)

const SOUTH_ROAD := Rect2i(38, 56, 16, 8)
const PLAZA := Rect2i(36, 26, 23, 15)
const HERO_HOME := Rect2i(12, 29, 9, 8)
const BARN := Rect2i(24, 24, 12, 13)
const ELDER_HOME := Rect2i(60, 20, 10, 9)
const RECORD_SHED := Rect2i(55, 34, 10, 9)
const GRAVEYARD := Rect2i(70, 34, 14, 15)
const NORTH_ROAD := Rect2i(42, 0, 6, 26)
const WELL := Rect2i(45, 31, 3, 3)

const BUILDING_BODIES := {
	"hero_home": Rect2i(12, 29, 9, 4),
	"barn": Rect2i(24, 24, 12, 9),
	"elder_home": Rect2i(60, 20, 10, 5),
	"record_shed": Rect2i(55, 34, 10, 5),
}

const FENCE_BLOCKERS := [
	Rect2i(23, 23, 14, 1),
	Rect2i(23, 23, 1, 14),
	Rect2i(36, 23, 1, 14),
	Rect2i(23, 36, 4, 1),
	Rect2i(31, 36, 6, 1),
	Rect2i(69, 34, 1, 15),
	Rect2i(84, 34, 1, 15),
	Rect2i(70, 33, 14, 1),
	Rect2i(70, 49, 14, 1),
]

const INSPECT_POINTS := {
	"tag_trace": Vector2i(58, 39),
	"headcount_beam": Vector2i(28, 27),
	"blank_stone": Vector2i(75, 39),
	"warning_stake": Vector2i(44, 18),
	"tower_threshold": Vector2i(45, 3),
}

const NPC_POINTS := {
	"elder": Vector2i(64, 25),
	"record_keeper": Vector2i(58, 38),
	"barn_keeper": Vector2i(29, 31),
	"well_woman": Vector2i(44, 31),
	"child": Vector2i(49, 28),
}


static func tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(
		float(tile.x * TILE_SIZE + TILE_SIZE / 2), float(tile.y * TILE_SIZE + TILE_SIZE / 2)
	)


static func in_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < MAP_SIZE.x and tile.y < MAP_SIZE.y


static func is_blocked(tile: Vector2i) -> bool:
	for rect in BUILDING_BODIES.values():
		if rect.has_point(tile):
			return true

	for rect in FENCE_BLOCKERS:
		if rect.has_point(tile):
			return true

	return false
