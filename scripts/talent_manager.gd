extends Node

var talent_levels: Dictionary = {
	"atk": 0,
	"hp": 0,
	"fire_rate": 0,
	"crit": 0,
	"crit_dmg": 0,
	"speed": 0,
	"dodge": 0,
	"aegis": 0,
	"recovery": 0,
	"vampirism": 0,
	"armor_pen": 0,
	"drone_tech": 0,
	"exp_boost": 0,
	"gold": 0
}

const TALENT_ORDER: Array[String] = [
	"atk", "hp", "fire_rate", "crit", "crit_dmg", "speed", "dodge",
	"aegis", "recovery", "vampirism", "armor_pen", "drone_tech", "exp_boost", "gold"
]

const TALENT_DEFS := {
	"atk": {
		"name": "ATTACCO",
		"icon": "★",
		"desc": "+2 ATK base",
		"max_lvl": 15,
		"base_cost": 180,
		"cost_mult": 1.56,
		"bonus_per_lvl": 2.0,
		"unit": "ATK"
	},
	"hp": {
		"name": "VITA MAX",
		"icon": "✦",
		"desc": "+20 HP max",
		"max_lvl": 15,
		"base_cost": 180,
		"cost_mult": 1.56,
		"bonus_per_lvl": 20.0,
		"unit": "HP"
	},
	"fire_rate": {
		"name": "CADENZA",
		"icon": "▲",
		"desc": "+2.5% Sparo",
		"max_lvl": 10,
		"base_cost": 240,
		"cost_mult": 1.62,
		"bonus_per_lvl": 2.5,
		"unit": "%"
	},
	"crit": {
		"name": "CRITICO",
		"icon": "◆",
		"desc": "+2% Critico",
		"max_lvl": 10,
		"base_cost": 220,
		"cost_mult": 1.60,
		"bonus_per_lvl": 2.0,
		"unit": "%"
	},
	"crit_dmg": {
		"name": "DANNO CRIT",
		"icon": "★",
		"desc": "+10% Crit DMG",
		"max_lvl": 10,
		"base_cost": 260,
		"cost_mult": 1.62,
		"bonus_per_lvl": 10.0,
		"unit": "%"
	},
	"speed": {
		"name": "VELOCITÀ",
		"icon": "⚡",
		"desc": "+8 Velocità",
		"max_lvl": 8,
		"base_cost": 200,
		"cost_mult": 1.58,
		"bonus_per_lvl": 8.0,
		"unit": "VEL"
	},
	"dodge": {
		"name": "SCHIVATA",
		"icon": "✦",
		"desc": "+1.5% Schivata",
		"max_lvl": 8,
		"base_cost": 280,
		"cost_mult": 1.65,
		"bonus_per_lvl": 1.5,
		"unit": "%"
	},
	"aegis": {
		"name": "SCUDO",
		"icon": "◆",
		"desc": "+1 Scudo run",
		"max_lvl": 2,
		"base_cost": 650,
		"cost_mult": 2.40,
		"bonus_per_lvl": 1.0,
		"unit": "SCUDO"
	},
	"recovery": {
		"name": "CURA ZONA",
		"icon": "✦",
		"desc": "+3% HP/stanza",
		"max_lvl": 8,
		"base_cost": 220,
		"cost_mult": 1.58,
		"bonus_per_lvl": 3.0,
		"unit": "%"
	},
	"vampirism": {
		"name": "VAMPIRISMO",
		"icon": "★",
		"desc": "+3% Cura colpo",
		"max_lvl": 6,
		"base_cost": 340,
		"cost_mult": 1.68,
		"bonus_per_lvl": 3.0,
		"unit": "%"
	},
	"armor_pen": {
		"name": "ANTI-BOSS",
		"icon": "▲",
		"desc": "+5% vs Boss",
		"max_lvl": 10,
		"base_cost": 250,
		"cost_mult": 1.60,
		"bonus_per_lvl": 5.0,
		"unit": "%"
	},
	"drone_tech": {
		"name": "DRONI",
		"icon": "◆",
		"desc": "+10% Droni",
		"max_lvl": 8,
		"base_cost": 240,
		"cost_mult": 1.60,
		"bonus_per_lvl": 10.0,
		"unit": "%"
	},
	"exp_boost": {
		"name": "EXP RUN",
		"icon": "✦",
		"desc": "+6% EXP run",
		"max_lvl": 8,
		"base_cost": 210,
		"cost_mult": 1.56,
		"bonus_per_lvl": 6.0,
		"unit": "%"
	},
	"gold": {
		"name": "CREDITI",
		"icon": "★",
		"desc": "+6% Crediti",
		"max_lvl": 10,
		"base_cost": 200,
		"cost_mult": 1.56,
		"bonus_per_lvl": 6.0,
		"unit": "%"
	}
}

func get_cost(talent_id: String) -> int:
	if not TALENT_DEFS.has(talent_id): return 99999
	var def: Dictionary = TALENT_DEFS[talent_id]
	var lvl: int = int(talent_levels.get(talent_id, 0))
	if lvl >= int(def["max_lvl"]): return -1
	return int(float(def["base_cost"]) * pow(float(def["cost_mult"]), lvl))

func get_bonus_value(talent_id: String) -> float:
	if not TALENT_DEFS.has(talent_id): return 0.0
	var def: Dictionary = TALENT_DEFS[talent_id]
	var lvl: int = int(talent_levels.get(talent_id, 0))
	return float(def["bonus_per_lvl"]) * float(lvl)

func upgrade_talent(talent_id: String) -> Dictionary:
	if not TALENT_DEFS.has(talent_id):
		return {"success": false, "message": "Talento non valido!"}

	var cost: int = get_cost(talent_id)
	if cost == -1:
		return {"success": false, "message": "Livello massimo già raggiunto!"}

	if Global.total_coins >= cost:
		Global.total_coins -= cost
		talent_levels[talent_id] = int(talent_levels.get(talent_id, 0)) + 1
		Global.quest_talents += 1
		var ss: Node = get_node_or_null("/root/SaveSystem")
		if ss and ss.has_method("save_game"): ss.save_game()
		return {"success": true, "message": str(TALENT_DEFS[talent_id]["name"]) + " potenziato!"}
	else:
		return {"success": false, "message": "Oro insufficiente! (Servono " + str(cost) + " Crediti Oro)"}
