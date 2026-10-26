extends Node

var worlds: Dictionary = {}
var world_order: Array[String] = []
var selected_world_id: String = "world_1"

func _ready() -> void:
	_init_database()

func _init_database() -> void:
	worlds.clear()
	world_order.clear()

	# Mondo 1 - Foresta Bio-Cibernetica (25 Livelli)
	var w1 := WorldData.new()
	w1.id = "world_1"
	w1.display_name = "Mondo 1: Foresta Bio-Cyber"
	w1.total_rooms = 25
	w1.enemy_hp_multiplier = 1.0
	w1.enemy_dmg_multiplier = 1.0
	w1.reward_multiplier = 1.0
	w1.description = "Settore 01 (25 Livelli): Giungla sintetico-mutante pattugliata dal Golem Silvano MK-I."
	w1.biome_color = Color(0.04, 0.14, 0.08, 1.0)
	w1.accent_color = Color(0.2, 1.0, 0.55, 1.0)
	w1.trap_type = "SPIKES"
	w1.boss_name = "Golem Silvano MK-I"
	w1.boss_color = Color(0.3, 1.0, 0.45, 1.0)
	w1.floor_tile_path = "res://assets/sprites/PNG/Retina/Tile/scifiTile_01.png"
	w1.obstacle_texture_path = "res://assets/sprites/PNG/Retina/Environment/scifiEnvironment_01.png"
	w1.melee_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_05.png"
	w1.ranged_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_09.png"
	w1.heavy_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_10.png"
	w1.boss_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_12.png"
	_register_world(w1)

	# Mondo 2 - Deserto delle Rovine (30 Livelli)
	var w2 := WorldData.new()
	w2.id = "world_2"
	w2.display_name = "Mondo 2: Deserto delle Rovine"
	w2.total_rooms = 30
	w2.enemy_hp_multiplier = 1.55
	w2.enemy_dmg_multiplier = 1.35
	w2.reward_multiplier = 1.6
	w2.description = "Settore 02 (30 Livelli): Dune radioattive con vortici gravitazionali e Scorpione Imperiale."
	w2.biome_color = Color(0.18, 0.13, 0.05, 1.0)
	w2.accent_color = Color(1.0, 0.78, 0.2, 1.0)
	w2.trap_type = "SANDPIT"
	w2.boss_name = "Scorpione Meccanico"
	w2.boss_color = Color(1.0, 0.65, 0.15, 1.0)
	w2.floor_tile_path = "res://assets/sprites/PNG/Retina/Tile/scifiTile_05.png"
	w2.obstacle_texture_path = "res://assets/sprites/PNG/Retina/Environment/scifiEnvironment_04.png"
	w2.melee_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_13.png"
	w2.ranged_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_15.png"
	w2.heavy_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_16.png"
	w2.boss_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_18.png"
	_register_world(w2)

	# Mondo 3 - Stazione Cyberpunk (30 Livelli)
	var w3 := WorldData.new()
	w3.id = "world_3"
	w3.display_name = "Mondo 3: Stazione Cyberpunk"
	w3.total_rooms = 30
	w3.enemy_hp_multiplier = 2.25
	w3.enemy_dmg_multiplier = 1.75
	w3.reward_multiplier = 2.4
	w3.description = "Settore 03 (30 Livelli): Grattacielo Arasaka ad alta sicurezza difeso dal Mega Dron-Core."
	w3.biome_color = Color(0.10, 0.04, 0.20, 1.0)
	w3.accent_color = Color(0.0, 0.94, 1.0, 1.0)
	w3.trap_type = "LASER"
	w3.boss_name = "Mega Dron-Core 3000"
	w3.boss_color = Color(0.0, 0.95, 1.0, 1.0)
	w3.floor_tile_path = "res://assets/sprites/PNG/Retina/Tile/scifiTile_11.png"
	w3.obstacle_texture_path = "res://assets/sprites/PNG/Retina/Structure/scifiStructure_03.png"
	w3.melee_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_19.png"
	w3.ranged_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_21.png"
	w3.heavy_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_22.png"
	w3.boss_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_24.png"
	_register_world(w3)

	# Mondo 4 - Laboratorio Criogenico (35 Livelli)
	var w4 := WorldData.new()
	w4.id = "world_4"
	w4.display_name = "Mondo 4: Lab Criogenico"
	w4.total_rooms = 35
	w4.enemy_hp_multiplier = 3.1
	w4.enemy_dmg_multiplier = 2.2
	w4.reward_multiplier = 3.4
	w4.description = "Settore 04 (35 Livelli): Reattore sub-zero con trappole criogeniche e Cryo-Valkyrie Zero."
	w4.biome_color = Color(0.03, 0.13, 0.22, 1.0)
	w4.accent_color = Color(0.45, 0.90, 1.0, 1.0)
	w4.trap_type = "CRYO"
	w4.boss_name = "Cryo-Valkyrie Zero"
	w4.boss_color = Color(0.4, 0.85, 1.0, 1.0)
	w4.floor_tile_path = "res://assets/sprites/PNG/Retina/Tile/scifiTile_14.png"
	w4.obstacle_texture_path = "res://assets/sprites/PNG/Retina/Structure/scifiStructure_05.png"
	w4.melee_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_25.png"
	w4.ranged_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_27.png"
	w4.heavy_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_28.png"
	w4.boss_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_30.png"
	_register_world(w4)

	# Mondo 5 - Fonderia Magmatica (35 Livelli)
	var w5 := WorldData.new()
	w5.id = "world_5"
	w5.display_name = "Mondo 5: Fonderia Magmatica"
	w5.total_rooms = 35
	w5.enemy_hp_multiplier = 4.2
	w5.enemy_dmg_multiplier = 2.7
	w5.reward_multiplier = 4.6
	w5.description = "Settore 05 (35 Livelli): Fornace geotermica di metallo fuso presidiata da Vulcan Overlord."
	w5.biome_color = Color(0.20, 0.05, 0.03, 1.0)
	w5.accent_color = Color(1.0, 0.38, 0.1, 1.0)
	w5.trap_type = "MAGMA"
	w5.boss_name = "Vulcan Overlord"
	w5.boss_color = Color(1.0, 0.3, 0.05, 1.0)
	w5.floor_tile_path = "res://assets/sprites/PNG/Retina/Tile/scifiTile_21.png"
	w5.obstacle_texture_path = "res://assets/sprites/PNG/Retina/Structure/scifiStructure_08.png"
	w5.melee_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_31.png"
	w5.ranged_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_33.png"
	w5.heavy_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_34.png"
	w5.boss_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_36.png"
	_register_world(w5)

	# Mondo 6 - Raffineria Bio-Tossica (40 Livelli)
	var w6 := WorldData.new()
	w6.id = "world_6"
	w6.display_name = "Mondo 6: Raffineria Bio-Tossica"
	w6.total_rooms = 40
	w6.enemy_hp_multiplier = 5.6
	w6.enemy_dmg_multiplier = 3.3
	w6.reward_multiplier = 6.2
	w6.description = "Settore 06 (40 Livelli): Impianto chimico corrotto da vapori acidi e da Hydra Chimera X."
	w6.biome_color = Color(0.06, 0.16, 0.04, 1.0)
	w6.accent_color = Color(0.65, 1.0, 0.15, 1.0)
	w6.trap_type = "ACID"
	w6.boss_name = "Hydra Chimera X"
	w6.boss_color = Color(0.6, 1.0, 0.1, 1.0)
	w6.floor_tile_path = "res://assets/sprites/PNG/Retina/Tile/scifiTile_27.png"
	w6.obstacle_texture_path = "res://assets/sprites/PNG/Retina/Environment/scifiEnvironment_09.png"
	w6.melee_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_37.png"
	w6.ranged_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_39.png"
	w6.heavy_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_40.png"
	w6.boss_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_42.png"
	_register_world(w6)

	# Mondo 7 - Cittadella Astrale (45 Livelli)
	var w7 := WorldData.new()
	w7.id = "world_7"
	w7.display_name = "Mondo 7: Cittadella Astrale"
	w7.total_rooms = 45
	w7.enemy_hp_multiplier = 7.5
	w7.enemy_dmg_multiplier = 4.0
	w7.reward_multiplier = 8.5
	w7.description = "Settore 07 (45 Livelli): Santuario orbitale a plasma solare custodito da Archon Seraphim."
	w7.biome_color = Color(0.07, 0.09, 0.22, 1.0)
	w7.accent_color = Color(1.0, 0.86, 0.30, 1.0)
	w7.trap_type = "TESLA"
	w7.boss_name = "Archon Seraphim"
	w7.boss_color = Color(1.0, 0.88, 0.25, 1.0)
	w7.floor_tile_path = "res://assets/sprites/PNG/Retina/Tile/scifiTile_33.png"
	w7.obstacle_texture_path = "res://assets/sprites/PNG/Retina/Structure/scifiStructure_12.png"
	w7.melee_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_43.png"
	w7.ranged_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_45.png"
	w7.heavy_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_46.png"
	w7.boss_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_47.png"
	_register_world(w7)

	# Mondo 8 - Singolarità del Vuoto (50 Livelli)
	var w8 := WorldData.new()
	w8.id = "world_8"
	w8.display_name = "Mondo 8: Nexus della Singolarità"
	w8.total_rooms = 50
	w8.enemy_hp_multiplier = 10.0
	w8.enemy_dmg_multiplier = 5.0
	w8.reward_multiplier = 12.0
	w8.description = "Settore 08 (50 Livelli): Orizzonte degli eventi. Sconfiggi l'IA Suprema OMEGA PROTOCOL."
	w8.biome_color = Color(0.05, 0.02, 0.10, 1.0)
	w8.accent_color = Color(1.0, 0.15, 0.75, 1.0)
	w8.trap_type = "VOID"
	w8.boss_name = "Omega Protocol: A.R.G.O.N."
	w8.boss_color = Color(1.0, 0.15, 0.80, 1.0)
	w8.floor_tile_path = "res://assets/sprites/PNG/Retina/Tile/scifiTile_39.png"
	w8.obstacle_texture_path = "res://assets/sprites/PNG/Retina/Structure/scifiStructure_15.png"
	w8.melee_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_44.png"
	w8.ranged_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_45.png"
	w8.heavy_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_46.png"
	w8.boss_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_48.png"
	_register_world(w8)

	print("WorldDB: ", worlds.size(), " Mondi caricati con successo!")

func _register_world(w: WorldData) -> void:
	worlds[w.id] = w
	world_order.append(w.id)

func get_selected_world() -> WorldData:
	if worlds.has(selected_world_id):
		return worlds[selected_world_id] as WorldData
	return worlds["world_1"] as WorldData
