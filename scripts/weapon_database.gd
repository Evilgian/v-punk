extends Node

var weapons: Dictionary = {}
var equipped_weapon_id: String = "pistol_base"

var armors: Dictionary = {}
var gloves: Dictionary = {}
var boots: Dictionary = {}

var equipped_armor_id: String = ""
var equipped_gloves_id: String = ""
var equipped_boots_id: String = ""

func _ready() -> void:
	_init_weapon_database()
	_init_equipment_database()

func _init_weapon_database() -> void:
	weapons.clear()

	# 1. Pistola Cyber Tattica (COMMON -> ~50 DPS)
	var pistol := WeaponStats.new()
	pistol.id = "pistol_base"
	pistol.display_name = "Pistola Cyber"
	pistol.base_damage = 14
	pistol.fire_rate = 0.28
	pistol.rarity = WeaponStats.Rarity.COMMON
	weapons[pistol.id] = pistol

	# 2. Conduttore Psionico Homing (RARE -> ~104 DPS, colpi a ricerca automatica)
	var wand := WeaponStats.new()
	wand.id = "homing_wand"
	wand.display_name = "Conduttore Psionico"
	wand.base_damage = 18
	wand.fire_rate = 0.26
	wand.rarity = WeaponStats.Rarity.RARE
	weapons[wand.id] = wand

	# 3. Fucile a Pompa Tattico (RARE -> ~138 DPS a 3 pallettoni + forte Knockback)
	var shotgun := WeaponStats.new()
	shotgun.id = "shotgun"
	shotgun.display_name = "Fucile a Pompa"
	shotgun.base_damage = 22
	shotgun.fire_rate = 0.72
	shotgun.rarity = WeaponStats.Rarity.RARE
	weapons[shotgun.id] = shotgun

	# 4. Mitraglietta Cyber (EPIC -> ~182 DPS, altissima cadenza per sinergie elementali)
	var smg := WeaponStats.new()
	smg.id = "smg"
	smg.display_name = "Mitraglietta Cyber"
	smg.base_damage = 10
	smg.fire_rate = 0.11
	smg.rarity = WeaponStats.Rarity.EPIC
	weapons[smg.id] = smg

	# 5. Fucile Laser High-Tech (EPIC -> ~233 DPS, raggio ad alta velocità e precisione)
	var laser := WeaponStats.new()
	laser.id = "laser_rifle"
	laser.display_name = "Fucile Laser"
	laser.base_damage = 21
	laser.fire_rate = 0.18
	laser.rarity = WeaponStats.Rarity.EPIC
	weapons[laser.id] = laser

	# 6. Katana Termica (EPIC -> ~255 DPS, onda fendente perforante ad ampio arco + spinta)
	var katana := WeaponStats.new()
	katana.id = "katana"
	katana.display_name = "Katana Termica"
	katana.base_damage = 34
	katana.fire_rate = 0.36
	katana.rarity = WeaponStats.Rarity.EPIC
	weapons[katana.id] = katana

	# 7. Falce Quasar Perforante (LEGENDARY -> ~310 DPS, lama rotante gigante che trapassa tutti i nemici)
	var scythe := WeaponStats.new()
	scythe.id = "scythe"
	scythe.display_name = "Falce Quasar"
	scythe.base_damage = 58
	scythe.fire_rate = 0.56
	scythe.rarity = WeaponStats.Rarity.LEGENDARY
	weapons[scythe.id] = scythe

	# 8. Cannone al Plasma (LEGENDARY -> ~300 DPS diretto + Esplosione AoE 82px al Plasma!)
	var plasma := WeaponStats.new()
	plasma.id = "plasma_cannon"
	plasma.display_name = "Cannone al Plasma"
	plasma.base_damage = 78
	plasma.fire_rate = 0.78
	plasma.rarity = WeaponStats.Rarity.LEGENDARY
	weapons[plasma.id] = plasma

	print("WeaponDB: Armi caricate (", weapons.size(), ")")

func _init_equipment_database() -> void:
	armors["kevlar"] = {"name": "Giubbotto Kevlar", "hp_bonus": 55, "desc": "+55 Max HP"}
	armors["nano_armor"] = {"name": "Armatura Nano-Tech", "hp_bonus": 115, "desc": "+115 Max HP"}

	gloves["cyber_gloves"] = {"name": "Guanti Cyber", "firerate_mult": 0.85, "desc": "-15% Delay Sparo"}
	gloves["tactical_gloves"] = {"name": "Guanti Tattici", "firerate_mult": 0.75, "desc": "-25% Delay Sparo"}

	boots["antigrav_boots"] = {"name": "Stivali Anti-Gravità", "speed_bonus": 30.0, "desc": "+30 Velocità Movimento"}
	boots["jet_boots"] = {"name": "Stivali a Reazione", "speed_bonus": 60.0, "desc": "+60 Velocità Movimento"}

	print("WeaponDB: Equipaggiamenti difensivi caricati!")

func get_weapon_trait_it(weapon_id: String) -> String:
	match weapon_id:
		"pistol_base": return "Bilanciata • Cadenza rapida e precisa"
		"homing_wand": return "Guida Psionica • I dardi inseguono i nemici"
		"shotgun": return "Tripla Rosa • 3 colpi ad alto impatto ravvicinato"
		"smg": return "Raffica Ultra • 9 colpi/sec ideali per effetti al colpo"
		"laser_rifle": return "Raggio Iper-Veloce • Alta precisione e danno continuo"
		"katana": return "Onda Fendente • Taglio energetico ad arco perforante"
		"scythe": return "Lama Quasar • Disco rotante largo che trapassa le file"
		"plasma_cannon": return "Supernova AoE • Esplode all'impatto danneggiando l'area"
	return "Modulo Offensivo Cyberware"

func get_equipped_weapon() -> WeaponStats:
	if weapons.has(equipped_weapon_id):
		return weapons[equipped_weapon_id] as WeaponStats
	return null

func get_equipped_armor_hp_bonus() -> int:
	if armors.has(equipped_armor_id):
		return int(armors[equipped_armor_id]["hp_bonus"])
	return 0

func get_equipped_gloves_firerate_multiplier() -> float:
	if gloves.has(equipped_gloves_id):
		return float(gloves[equipped_gloves_id]["firerate_mult"])
	return 1.0

func get_equipped_boots_speed_bonus() -> float:
	if boots.has(equipped_boots_id):
		return float(boots[equipped_boots_id]["speed_bonus"])
	return 0.0
