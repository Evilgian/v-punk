extends Node

var talent_levels: Dictionary = {
	"atk": 0,
	"hp": 0,
	"crit": 0,
	"recovery": 0,
	"speed": 0,
	"gold": 0
}

const TALENT_DEFS := {
	"atk": {
		"name": "Forza Bruta",
		"icon": "⚔️",
		"desc": "+2 ATK per livello",
		"max_lvl": 10,
		"base_cost": 100,
		"cost_mult": 1.5,
		"bonus_per_lvl": 2.0,
		"unit": "ATK"
	},
	"hp": {
		"name": "Vitalità",
		"icon": "❤️",
		"desc": "+20 HP Max per livello",
		"max_lvl": 10,
		"base_cost": 100,
		"cost_mult": 1.5,
		"bonus_per_lvl": 20.0,
		"unit": "HP"
	},
	"crit": {
		"name": "Precisione",
		"icon": "🎯",
		"desc": "+2% Critico per livello",
		"max_lvl": 5,
		"base_cost": 100,
		"cost_mult": 1.5,
		"bonus_per_lvl": 2.0,
		"unit": "%"
	},
	"recovery": {
		"name": "Pronto Soccorso",
		"icon": "🧪",
		"desc": "Ripristina +5% HP tra le stanze",
		"max_lvl": 5,
		"base_cost": 100,
		"cost_mult": 1.5,
		"bonus_per_lvl": 5.0,
		"unit": "%"
	},
	"speed": {
		"name": "Riflessi Pronti",
		"icon": "⚡",
		"desc": "+10 Velocità di movimento",
		"max_lvl": 5,
		"base_cost": 100,
		"cost_mult": 1.5,
		"bonus_per_lvl": 10.0,
		"unit": "VEL"
	},
	"gold": {
		"name": "Golosità",
		"icon": "🪙",
		"desc": "+5% Monete extra guadagnate",
		"max_lvl": 5,
		"base_cost": 100,
		"cost_mult": 1.5,
		"bonus_per_lvl": 5.0,
		"unit": "%"
	}
}

func get_cost(talent_id: String) -> int:
	if not TALENT_DEFS.has(talent_id): return 99999
	var def: Dictionary = TALENT_DEFS[talent_id]
	var lvl: int = talent_levels.get(talent_id, 0)
	if lvl >= int(def["max_lvl"]): return -1
	return int(float(def["base_cost"]) * pow(float(def["cost_mult"]), lvl))

func get_bonus_value(talent_id: String) -> float:
	if not TALENT_DEFS.has(talent_id): return 0.0
	var def: Dictionary = TALENT_DEFS[talent_id]
	var lvl: int = talent_levels.get(talent_id, 0)
	return float(def["bonus_per_lvl"]) * float(lvl)

func upgrade_talent(talent_id: String) -> Dictionary:
	if not TALENT_DEFS.has(talent_id):
		return {"success": false, "message": "Talento non valido!"}

	var cost: int = get_cost(talent_id)
	if cost == -1:
		return {"success": false, "message": "Livello massimo già raggiunto!"}

	if Global.total_coins >= cost:
		Global.total_coins -= cost
		talent_levels[talent_id] = talent_levels.get(talent_id, 0) + 1
		Global.quest_talents += 1
		var ss: Node = get_node_or_null("/root/SaveSystem")
		if ss and ss.has_method("save_game"): ss.save_game()
		return {"success": true, "message": "🎉 Potenziato " + str(TALENT_DEFS[talent_id]["name"]) + " a Lv. " + str(talent_levels[talent_id]) + "!"}
	else:
		return {"success": false, "message": "❌ Monete insufficienti! Servono " + str(cost) + " 🪙"}
