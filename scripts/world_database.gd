extends Node

var worlds: Dictionary = {}
var world_order: Array[String] = []
var selected_world_id: String = "world_1"

func _ready() -> void:
	_init_database()

func _make_world(
	id_str: String,
	name_str: String,
	rooms: int,
	hp_m: float,
	dmg_m: float,
	rew_m: float,
	desc_str: String,
	biome_c: Color,
	acc_c: Color,
	trap_str: String,
	boss_n: String,
	boss_c: Color
) -> void:
	var w := WorldData.new()
	w.id = id_str
	w.display_name = name_str
	w.total_rooms = rooms
	w.enemy_hp_multiplier = hp_m
	w.enemy_dmg_multiplier = dmg_m
	w.reward_multiplier = rew_m
	w.description = desc_str
	w.biome_color = biome_c
	w.accent_color = acc_c
	w.trap_type = trap_str
	w.boss_name = boss_n
	w.boss_color = boss_c
	w.floor_tile_path = "res://assets/sprites/PNG/Retina/Tile/scifiTile_01.png"
	w.obstacle_texture_path = "res://assets/sprites/PNG/Retina/Environment/scifiEnvironment_01.png"
	w.melee_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_05.png"
	w.ranged_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_09.png"
	w.heavy_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_10.png"
	w.boss_unit_texture = "res://assets/sprites/PNG/Retina/Unit/scifiUnit_12.png"
	worlds[w.id] = w
	world_order.append(w.id)

func _init_database() -> void:
	worlds.clear()
	world_order.clear()

	_make_world("world_1", "SERRA BIO-SYNTH", 10, 0.90, 0.80, 1.2,
		"Zona di quarantena botanica della megatorre Biotechnica.",
		Color(0.04, 0.12, 0.08, 1.0), Color(0.12, 0.98, 0.56, 1.0), "SPIKES", "BIO-GOLEM MK-I", Color(0.25, 1.0, 0.50, 1.0))

	_make_world("world_2", "AUTOSTRADA BADLANDS", 15, 1.35, 1.18, 1.5,
		"Arteria desertica abbandonata tra convogli in fiamme e tempeste tossiche.",
		Color(0.16, 0.11, 0.05, 1.0), Color(1.0, 0.72, 0.14, 1.0), "SANDPIT", "SCORPIO IMPERIALE", Color(1.0, 0.65, 0.15, 1.0))

	_make_world("world_3", "ELIPORTO ARASAKA", 20, 1.85, 1.48, 2.0,
		"Attico blindato sotto pioggia acida nel cuore finanziario di Night City.",
		Color(0.07, 0.05, 0.15, 1.0), Color(0.0, 0.94, 1.0, 1.0), "LASER", "DRON-CORE 3000", Color(0.0, 0.95, 1.0, 1.0))

	_make_world("world_4", "CRIPTA CRIOGENICA", 20, 2.40, 1.80, 2.6,
		"Archivio neurale sub-zero immerso in vapori d'azoto liquido.",
		Color(0.03, 0.11, 0.18, 1.0), Color(0.38, 0.88, 1.0, 1.0), "CRYO", "VALKYRIE ZERO", Color(0.42, 0.88, 1.0, 1.0))

	_make_world("world_5", "FONDERIA MAGMATICA", 25, 3.05, 2.15, 3.4,
		"Impianto siderurgico automatizzato sospeso su colate di metallo fuso.",
		Color(0.18, 0.05, 0.03, 1.0), Color(1.0, 0.36, 0.08, 1.0), "MAGMA", "VULCAN OVERLORD", Color(1.0, 0.32, 0.06, 1.0))

	_make_world("world_6", "CONDOTTI CHIMICI", 25, 3.75, 2.50, 4.3,
		"Sottosuolo industriale saturo di reagenti mutageni luminescenti.",
		Color(0.05, 0.14, 0.04, 1.0), Color(0.62, 1.0, 0.14, 1.0), "ACID", "HYDRA CHIMERA X", Color(0.58, 1.0, 0.12, 1.0))

	_make_world("world_7", "HANGAR ORBITALE", 30, 4.55, 2.90, 5.5,
		"Scalo aerospaziale in orbita bassa sopra l'emisfero notturno.",
		Color(0.05, 0.08, 0.18, 1.0), Color(0.98, 0.88, 0.20, 1.0), "TESLA", "ARCHON SERAPHIM", Color(1.0, 0.86, 0.25, 1.0))

	_make_world("world_8", "VICOLO KABUKI", 30, 5.45, 3.30, 6.8,
		"Dedalo clandestino del mercato nero immerso tra insegne cremisi.",
		Color(0.14, 0.03, 0.08, 1.0), Color(1.0, 0.05, 0.38, 1.0), "LASER", "KURO-SHINOBI X", Color(1.0, 0.12, 0.42, 1.0))

	_make_world("world_9", "BASTIONE MILITECH", 35, 6.45, 3.75, 8.4,
		"Piazzaforte corazzata ad alta sicurezza presidiata da artiglieria pesante.",
		Color(0.14, 0.04, 0.05, 1.0), Color(1.0, 0.18, 0.22, 1.0), "SPIKES", "ARES DREADNOUGHT", Color(1.0, 0.22, 0.18, 1.0))

	_make_world("world_10", "REATTORE ABISSALE", 40, 7.60, 4.20, 10.2,
		"Centrale geotermica sottomarina ancorata nella fossa oceanica.",
		Color(0.02, 0.10, 0.16, 1.0), Color(0.0, 0.90, 0.78, 1.0), "CRYO", "LEVIATHAN CRYO", Color(0.10, 0.95, 0.82, 1.0))

	_make_world("world_11", "CUPOLA SELENE", 45, 8.90, 4.70, 12.5,
		"Avamposto cibernetico sulla superficie lunare a gravità ridotta.",
		Color(0.06, 0.08, 0.14, 1.0), Color(0.72, 0.88, 1.0, 1.0), "TESLA", "CELESTIAL VALKYRIE", Color(0.82, 0.92, 1.0, 1.0))

	_make_world("world_12", "NUCLEO A.R.G.O.N.", 50, 10.40, 5.30, 16.0,
		"Cattedrale digitale dell'IA ribelle oltre l'orizzonte degli eventi.",
		Color(0.07, 0.02, 0.08, 1.0), Color(1.0, 0.0, 0.32, 1.0), "VOID", "OMEGA A.R.G.O.N.", Color(1.0, 0.08, 0.40, 1.0))

	print("WorldDB: ", worlds.size(), " Settori Cyberpunk caricati!")

func get_selected_world() -> WorldData:
	if worlds.has(selected_world_id):
		return worlds[selected_world_id] as WorldData
	return worlds["world_1"] as WorldData

## Restituisce i 3 Traguardi Intermedi di avanzamento per un dato Settore (30%, 60%, 100%)
func get_world_milestones(world_id: String) -> Array[Dictionary]:
	if not worlds.has(world_id):
		return []
	var w: WorldData = worlds[world_id]
	var w_idx: int = maxi(1, world_order.find(world_id) + 1)
	var tot: int = maxi(5, w.total_rooms)
	var r1: int = maxi(2, int(round(float(tot) * 0.30)))
	var r2: int = maxi(r1 + 2, int(round(float(tot) * 0.65)))
	var r3: int = tot

	return [
		{
			"key": world_id + "_m1",
			"tier": 1,
			"target_room": r1,
			"title": "ZONA " + str(r1),
			"coins": 180 * w_idx,
			"gems": 0,
			"scrolls": 2 + int(w_idx / 2),
			"gear_rarity": "",
			"summary": "+" + str(180 * w_idx) + " Crediti  •  +" + str(2 + int(w_idx / 2)) + " Nuclei"
		},
		{
			"key": world_id + "_m2",
			"tier": 2,
			"target_room": r2,
			"title": "ZONA " + str(r2),
			"coins": 320 * w_idx,
			"gems": 25 + w_idx * 5,
			"scrolls": 0,
			"gear_rarity": "",
			"summary": "+" + str(25 + w_idx * 5) + " Gemme  •  +" + str(320 * w_idx) + " Crediti"
		},
		{
			"key": world_id + "_m3",
			"tier": 3,
			"target_room": r3,
			"title": "BOSS ZONA " + str(r3),
			"coins": 0,
			"gems": 50 + w_idx * 10,
			"scrolls": 3 + w_idx,
			"gear_rarity": "EPIC" if w_idx >= 3 else "RARE",
			"summary": "+" + str(50 + w_idx * 10) + " Gemme  •  Cromo " + ("Epico" if w_idx >= 3 else "Raro")
		}
	]

func count_claimable_milestones(filter_world_id: String = "") -> int:
	var g: Node = get_node_or_null("/root/Global")
	if not g:
		return 0
	var cnt: int = 0
	var ids: Array = [filter_world_id] if not filter_world_id.is_empty() else world_order
	for wid in ids:
		var best_r: int = g.get_world_best_room(str(wid))
		for m in get_world_milestones(str(wid)):
			var mk: String = str(m["key"])
			if best_r >= int(m["target_room"]) and not bool(g.world_milestones_claimed.get(mk, false)):
				cnt += 1
	return cnt
