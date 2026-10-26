class_name WorldData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var total_rooms: int = 10
@export var enemy_hp_multiplier: float = 1.0
@export var enemy_dmg_multiplier: float = 1.0
@export var reward_multiplier: float = 1.0
@export var description: String = ""
@export var biome_color: Color = Color(0.04, 0.1, 0.06, 1.0)
@export var accent_color: Color = Color(0.0, 0.94, 1.0, 1.0)
@export var trap_type: String = "SPIKES"
@export var boss_name: String = "Boss"
@export var boss_color: Color = Color(1.0, 0.25, 0.55, 1.0)

@export var floor_tile_path: String = "res://assets/sprites/PNG/Retina/Tile/scifiTile_01.png"
@export var obstacle_texture_path: String = "res://assets/sprites/PNG/Retina/Structure/scifiStructure_03.png"
@export var melee_unit_texture: String = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_05.png"
@export var ranged_unit_texture: String = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_09.png"
@export var heavy_unit_texture: String = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_10.png"
@export var boss_unit_texture: String = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_33.png"
