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
		"name": "Forza Bruta",
		"icon": "⚔️",
		"desc": "+3 ATK base a tutti i colpi",
		"max_lvl": 15,
		"base_cost": 90,
		"cost_mult": 1.42,
		"bonus_per_lvl": 3.0,
		"unit": "ATK"
	},
	"hp": {
		"name": "Telaio Titanio",
		"icon": "❤️",
		"desc": "+25 HP Massimi per livello",
		"max_lvl": 15,
		"base_cost": 90,
		"cost_mult": 1.42,
		"bonus_per_lvl": 25.0,
		"unit": "HP"
	},
	"fire_rate": {
		"name": "Canna Overclock",
		"icon": "🔥",
		"desc": "+3% Cadenza di fuoco base",
		"max_lvl": 10,
		"base_cost": 120,
		"cost_mult": 1.48,
		"bonus_per_lvl": 3.0,
		"unit": "%"
	},
	"crit": {
		"name": "Mirino Neurale",
		"icon": "🎯",
		"desc": "+2% Probabilità Critico",
		"max_lvl": 10,
		"base_cost": 110,
		"cost_mult": 1.45,
		"bonus_per_lvl": 2.0,
		"unit": "%"
	},
	"crit_dmg": {
		"name": "Impatto Letale",
		"icon": "💥",
		"desc": "+12% Danno dei Colpi Critici",
		"max_lvl": 10,
		"base_cost": 130,
		"cost_mult": 1.48,
		"bonus_per_lvl": 12.0,
		"unit": "%"
	},
	"speed": {
		"name": "Servo-Motori",
		"icon": "⚡",
		"desc": "+10 Velocità di movimento",
		"max_lvl": 8,
		"base_cost": 100,
		"cost_mult": 1.45,
		"bonus_per_lvl": 10.0,
		"unit": "VEL"
	},
	"dodge": {
		"name": "Riflessi Olografici",
		"icon": "💨",
		"desc": "+2% Schivata danni ostili",
		"max_lvl": 8,
		"base_cost": 135,
		"cost_mult": 1.50,
		"bonus_per_lvl": 2.0,
		"unit": "%"
	},
	"aegis": {
		"name": "Scudo d'Ingresso",
		"icon": "🛡️",
		"desc": "+1 Carica Scudo a inizio run",
		"max_lvl": 3,
		"base_cost": 260,
		"cost_mult": 1.85,
		"bonus_per_lvl": 1.0,
		"unit": "SCUDI"
	},
	"recovery": {
		"name": "Nano-Riparazione",
		"icon": "🧪",
		"desc": "Cura +4% HP tra le stanze",
		"max_lvl": 8,
		"base_cost": 110,
		"cost_mult": 1.45,
		"bonus_per_lvl": 4.0,
		"unit": "%"
	},
	"vampirism": {
		"name": "Sifone Bio-Cyber",
		"icon": "🩸",
		"desc": "+4% chance di curare +2 HP al colpo",
		"max_lvl": 6,
		"base_cost": 160,
		"cost_mult": 1.55,
		"bonus_per_lvl": 4.0,
		"unit": "%"
	},
	"armor_pen": {
		"name": "Proiettili al Tungsteno",
		"icon": "🔩",
		"desc": "+6% Danno contro Boss ed Élite",
		"max_lvl": 10,
		"base_cost": 125,
		"cost_mult": 1.46,
		"bonus_per_lvl": 6.0,
		"unit": "%"
	},
	"drone_tech": {
		"name": "Sincronia Droni",
		"icon": "🛸",
		"desc": "+12% Danno e Cadenza Droni Pet",
		"max_lvl": 8,
		"base_cost": 130,
		"cost_mult": 1.48,
		"bonus_per_lvl": 12.0,
		"unit": "%"
	},
	"exp_boost": {
		"name": "Sinapsi Rapide",
		"icon": "🧠",
		"desc": "+8% EXP guadagnata in battaglia",
		"max_lvl": 8,
		"base_cost": 115,
		"cost_mult": 1.45,
		"bonus_per_lvl": 8.0,
		"unit": "%"
	},
	"gold": {
		"name": "Algoritmo Avarizia",
		"icon": "🪙",
		"desc": "+8% Monete extra guadagnate",
		"max_lvl": 10,
		"base_cost": 100,
		"cost_mult": 1.44,
		"bonus_per_lvl": 8.0,
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
		return {"success": false, "message": "Monete insufficienti! (Servono " + str(cost) + " 🪙)"}
