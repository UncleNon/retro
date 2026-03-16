class_name FieldSceneModel
extends "res://scripts/world/starting_village_layout.gd"


static func load_from_game_manager(_game_manager: Node, next_field_id: String):
	return new(next_field_id)
