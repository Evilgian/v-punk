extends Node

# Database Armi
var weapons: Dictionary = {}
var equipped_weapon_id: String = "pistol_base"

# Database ed Equipaggiamento Difensivo / Accessori
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
	# 1. Pistola Base (COMMON)
	var pistol := WeaponStats.new()
	pistol.id = "pistol_base"
	pistol.display_name = "Pistola Base"
	pistol.base_damage = 10
	pistol.fire_rate = 0.3
	pistol.rarity = WeaponStats.Rarity.COMMON
	weapons[pistol.id] = pistol

	# 2. Fucile a Pompa (RARE)
	var shotgun := WeaponStats.new()
	shotgun.id = "shotgun"
	shotgun.display_name = "Fucile a Pompa"
	shotgun.base_damage = 25
	shotgun.fire_rate = 0.8
	shotgun.rarity = WeaponStats.Rarity.RARE
	weapons[shotgun.id] = shotgun

	# 3. Bacchetta Magica Homing (RARE)
	var wand := WeaponStats.new()
	wand.id = "homing_wand"
	wand.display_name = "Bacchetta Magica Homing"
	wand.base_damage = 14
	wand.fire_rate = 0.25
	wand.rarity = WeaponStats.Rarity.RARE
	weapons[wand.id] = wand

	# 4. Mitraglietta (EPIC)
	var smg := WeaponStats.new()
	smg.id = "smg"
	smg.display_name = "Mitraglietta Cyber"
	smg.base_damage = 6
	smg.fire_rate = 0.1
	smg.rarity = WeaponStats.Rarity.EPIC
	weapons[smg.id] = smg

	# 5. Katana Cyber (EPIC)
	var katana := WeaponStats.new()
	katana.id = "katana"
	katana.display_name = "Katana Lame Veloci"
	katana.base_damage = 30
	katana.fire_rate = 0.15
	katana.rarity = WeaponStats.Rarity.EPIC
	weapons[katana.id] = katana

	# 6. Fucile Laser (EPIC)
	var laser := WeaponStats.new()
	laser.id = "laser_rifle"
	laser.display_name = "Fucile Laser High-Tech"
	laser.base_damage = 18
	laser.fire_rate = 0.15
	laser.rarity = WeaponStats.Rarity.EPIC
	weapons[laser.id] = laser

	# 7. Falce Pesante Perforante (LEGENDARY)
	var scythe := WeaponStats.new()
	scythe.id = "scythe"
	scythe.display_name = "Falce Pesante Perforante"
	scythe.base_damage = 45
	scythe.fire_rate = 0.7
	scythe.rarity = WeaponStats.Rarity.LEGENDARY
	weapons[scythe.id] = scythe

	# 8. Cannone al Plasma (LEGENDARY)
	var plasma := WeaponStats.new()
	plasma.id = "plasma_cannon"
	plasma.display_name = "Cannone al Plasma"
	plasma.base_damage = 60
	plasma.fire_rate = 1.2
	plasma.rarity = WeaponStats.Rarity.LEGENDARY
	weapons[plasma.id] = plasma

	print("WeaponDB: Armi caricate (", weapons.size(), ")")

func _init_equipment_database() -> void:
	armors["kevlar"] = {"name": "Giubbotto Kevlar", "hp_bonus": 50, "desc": "+50 Max HP"}
	armors["nano_armor"] = {"name": "Armatura Nano-Tech", "hp_bonus": 100, "desc": "+100 Max HP"}

	gloves["cyber_gloves"] = {"name": "Guanti Cyber", "firerate_mult": 0.85, "desc": "-15% Delay Sparo"}
	gloves["tactical_gloves"] = {"name": "Guanti Tattici", "firerate_mult": 0.75, "desc": "-25% Delay Sparo"}

	boots["antigrav_boots"] = {"name": "Stivali Anti-Gravità", "speed_bonus": 30.0, "desc": "+30 Velocità Movimento"}
	boots["jet_boots"] = {"name": "Stivali a Reazione", "speed_bonus": 60.0, "desc": "+60 Velocità Movimento"}

	print("WeaponDB: Equipaggiamenti difensivi caricati!")

func get_equipped_weapon() -> WeaponStats:
	if weapons.has(equipped_weapon_id):
		return weapons[equipped_weapon_id] as WeaponStats
	return null

func get_equipped_armor_hp_bonus() -> int:
	if armors.has(equipped_armor_id):
		return armors[equipped_armor_id]["hp_bonus"]
	return 0

func get_equipped_gloves_firerate_multiplier() -> float:
	if gloves.has(equipped_gloves_id):
		return gloves[equipped_gloves_id]["firerate_mult"]
	return 1.0

func get_equipped_boots_speed_bonus() -> float:
	if boots.has(equipped_boots_id):
		return boots[equipped_boots_id]["speed_bonus"]
	return 0.0
