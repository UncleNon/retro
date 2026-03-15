class_name MonsterData
extends Resource

@export var monster_id: String = ""
@export var slug: String = ""
@export var name_jp: String = ""
@export var name_en: String = ""
@export var family: String = ""
@export var rank: String = ""
@export var size_class: String = ""
@export var motif_group: String = ""
@export var secondary_motif_group: String = ""
@export var motif_source: String = ""
@export var ontology_class: String = ""
@export var silhouette_type: String = ""
@export var palette_id: String = ""
@export var field_sprite_px: int = 16
@export var battle_sprite_px: int = 32
@export var base_level_cap: int = 1
@export var growth_curve_id: String = ""
@export var base_stats: Dictionary = {}
@export var cap_stats: Dictionary = {}
@export var base_recruit: int = 0
@export var scoutable: bool = true
@export var personality_bias: String = ""
@export var battle_role: String = ""
@export var trait_1: String = ""
@export var trait_2: String = ""
@export var loot_table_id: String = ""
@export var prompt_id: String = ""
@export var notes: String = ""
@export var resistances: Dictionary = {}
@export var learnset: Array = []
