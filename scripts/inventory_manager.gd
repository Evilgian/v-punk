extends Node

var equipped_weapon_id: String = "pistol_base"
var equipped_armor_id: String = ""
var equipped_ring1_id: String = ""
var equipped_ring2_id: String = ""
var equipped_pet1_id: String = ""
var equipped_pet2_id: String = ""

# Traccia la rarità esatta dell'esemplare equipaggiato in ciascuno dei 6 slot (mai più doppioni marcati ATTIVI!)
var equipped_rarities: Dictionary = {
	"ARMA": "COMMON",
	"CORAZZA": "",
	"ANELLO 1": "",
	"ANELLO 2": "",
	"PET 1": "",
	"PET 2": ""
}

var inventory: Array = [
	{"id": "pistol_base", "name": "Pistola Cyber", "slot": "ARMA", "rarity": "COMMON", "count": 1}
]

var item_levels: Dictionary = {}

const RARITY_ORDER := ["COMMON", "RARE", "EPIC", "LEGENDARY"]
const RARITY_MULT := {"COMMON": 1.0, "RARE": 1.25, "EPIC": 1.55, "LEGENDARY": 2.0}

func init_starter_loadout(chosen_class: String) -> void:
	equipped_armor_id = ""
	equipped_ring1_id = ""
	equipped_ring2_id = ""
	equipped_pet1_id = ""
	equipped_pet2_id = ""
	equipped_rarities = {
		"ARMA": "COMMON",
		"CORAZZA": "",
		"ANELLO 1": "",
		"ANELLO 2": "",
		"PET 1": "",
		"PET 2": ""
	}
	WeaponDB.equipped_armor_id = ""
	item_levels = {}

	match chosen_class.to_upper():
		"VANGUARD":
			equipped_weapon_id = "shotgun"
			WeaponDB.equipped_weapon_id = "shotgun"
			inventory = [
				{"id": "shotgun", "name": "Fucile a Pompa", "slot": "ARMA", "rarity": "COMMON", "count": 1}
			]
		"NETRUNNER":
			equipped_weapon_id = "homing_wand"
			WeaponDB.equipped_weapon_id = "homing_wand"
			inventory = [
				{"id": "homing_wand", "name": "Conduttore Psionico", "slot": "ARMA", "rarity": "COMMON", "count": 1}
			]
		_:
			equipped_weapon_id = "pistol_base"
			WeaponDB.equipped_weapon_id = "pistol_base"
			inventory = [
				{"id": "pistol_base", "name": "Pistola Cyber", "slot": "ARMA", "rarity": "COMMON", "count": 1}
			]

func get_item_level(item_id: String) -> int:
	if item_id.is_empty(): return 1
	return max(1, int(item_levels.get(item_id, 1)))

func get_upgrade_coin_cost(item_id: String) -> int:
	var lvl := get_item_level(item_id)
	return 40 * lvl

func get_upgrade_scroll_cost(item_id: String) -> int:
	var lvl := get_item_level(item_id)
	return 1 + int((lvl - 1) / 3)

func get_item_rarity_mult(rarity_str: String) -> float:
	return float(RARITY_MULT.get(rarity_str.to_upper(), 1.0))

## Calcola il valore reale di ATK o HP fornito da un oggetto (tenendo conto di Base + Rarità + Livello!)
func get_item_primary_stat(item_id: String, slot_type: String, rarity_str: String = "COMMON", override_lvl: int = -1) -> Dictionary:
	var lvl: int = override_lvl if override_lvl > 0 else get_item_level(item_id)
	var r_mult: float = get_item_rarity_mult(rarity_str)
	var s := slot_type.to_upper()

	if "ARMA" in s:
		var w: WeaponStats = WeaponDB.weapons.get(item_id, null) as WeaponStats
		var base_d: float = float(w.base_damage) if w else 14.0
		var atk_val: int = int(round((base_d + float(lvl - 1) * 4.5) * r_mult * (1.0 + float(lvl - 1) * 0.04)))
		return {"stat": "ATK", "value": atk_val, "unit": "ATK"}
	elif "CORAZZA" in s or item_id in ["kevlar", "nano_armor"]:
		var base_hp: float = 115.0 if item_id == "nano_armor" else 55.0
		var hp_val: int = int(round((base_hp + float(lvl - 1) * 22.0) * r_mult))
		return {"stat": "HP", "value": hp_val, "unit": "HP"}
	elif "ANELLO 1" in s or item_id == "ring_crit":
		var c_atk: int = int(round((6.0 + float(lvl - 1) * 3.0) * r_mult))
		return {"stat": "ATK", "value": c_atk, "unit": "ATK CRIT"}
	elif "ANELLO 2" in s or item_id == "ring_speed":
		var spd: int = int(round((26.0 + float(lvl - 1) * 6.0) * (0.9 + r_mult * 0.1)))
		return {"stat": "VEL", "value": spd, "unit": "VEL"}
	elif "PET 1" in s or item_id == "drone_laser":
		var pct: int = int(round((55.0 + float(lvl - 1) * 9.0) * (0.85 + r_mult * 0.15)))
		return {"stat": "DRONE", "value": pct, "unit": "% ATK"}
	else:
		var sh_hp: int = int(round((35.0 + float(lvl - 1) * 15.0) * r_mult))
		return {"stat": "HP", "value": sh_hp, "unit": "HP SCUDO"}

func get_item_stat_description(item_id: String, slot_type: String, rarity_str: String = "") -> String:
	var eff_rar: String = rarity_str
	if eff_rar.is_empty():
		var eq_d: Dictionary = get_equipped_item_in_slot(slot_type)
		if not eq_d.is_empty() and str(eq_d.get("id", "")) == item_id:
			eff_rar = str(eq_d.get("rarity", "COMMON"))
		else:
			eff_rar = "COMMON"
			for it in inventory:
				if str(it.get("id", "")) == item_id:
					eff_rar = str(it.get("rarity", "COMMON"))
					break
	var lvl := get_item_level(item_id)
	var cur := get_item_primary_stat(item_id, slot_type, eff_rar, lvl)
	var nxt := get_item_primary_stat(item_id, slot_type, eff_rar, lvl + 1)
	var s := slot_type.to_upper()
	if "ARMA" in s:
		var trait_txt := WeaponDB.get_weapon_trait_it(item_id)
		return "★ Danno: " + str(cur["value"]) + " ATK (Lv." + str(lvl + 1) + ": " + str(nxt["value"]) + " ATK)\n" + trait_txt
	return "✦ Bonus Attivo: +" + str(cur["value"]) + " " + str(cur["unit"]) + "  (Lv." + str(lvl + 1) + ": +" + str(nxt["value"]) + " " + str(nxt["unit"]) + ")"

## Confronta un oggetto con quello attualmente indossato nello stesso slot (restituisce testo + colore!)
func get_comparison_with_equipped(item_data: Dictionary) -> Dictionary:
	var iid: String = str(item_data.get("id", ""))
	var slot_str: String = str(item_data.get("slot", "ARMA"))
	var rar_str: String = str(item_data.get("rarity", "COMMON"))
	var cand := get_item_primary_stat(iid, slot_str, rar_str)
	var eq_item: Dictionary = get_equipped_item_in_slot(slot_str)
	if eq_item.is_empty() or str(eq_item.get("id", "")).is_empty():
		return {"delta": int(cand["value"]), "text": "▲ +" + str(cand["value"]) + " " + str(cand["unit"]), "is_better": true, "is_same": false}
	if str(eq_item.get("id", "")) == iid and str(eq_item.get("rarity", "COMMON")).to_upper() == rar_str.to_upper():
		return {"delta": 0, "text": "✓ ATTIVO: " + str(cand["value"]) + " " + str(cand["unit"]), "is_better": false, "is_same": true}
	var eq_stat := get_item_primary_stat(str(eq_item["id"]), slot_str, str(eq_item.get("rarity", "COMMON")))
	var diff: int = int(cand["value"]) - int(eq_stat["value"])
	if diff > 0:
		return {"delta": diff, "text": "▲ +" + str(diff) + " " + str(cand["unit"]), "is_better": true, "is_same": false}
	elif diff < 0:
		return {"delta": diff, "text": "▼ " + str(diff) + " " + str(cand["unit"]), "is_better": false, "is_same": false}
	return {"delta": 0, "text": "= " + str(cand["value"]) + " " + str(cand["unit"]), "is_better": false, "is_same": true}

func upgrade_item_level(item_id: String) -> Dictionary:
	var coin_cost := get_upgrade_coin_cost(item_id)
	var scroll_cost := get_upgrade_scroll_cost(item_id)
	if Global.total_coins < coin_cost:
		return {"success": false, "message": "Oro insufficiente! Servono " + str(coin_cost) + " Crediti Oro."}
	if Global.upgrade_scrolls < scroll_cost:
		return {"success": false, "message": "Nuclei insufficienti! Servono " + str(scroll_cost) + " Nuclei (trovane nei livelli!)."}

	Global.total_coins -= coin_cost
	Global.upgrade_scrolls -= scroll_cost
	var new_lvl := get_item_level(item_id) + 1
	item_levels[item_id] = new_lvl

	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"): ss.save_game()
	return {"success": true, "new_level": new_lvl, "message": "▲ POTENZIAMENTO COMPLETATO: Lv. " + str(new_lvl) + "!"}

const BASE_GEAR_CATALOG := [
	{"id": "pistol_base", "name": "Pistola Cyber", "slot": "ARMA", "min_world": 1},
	{"id": "shotgun", "name": "Fucile a Pompa", "slot": "ARMA", "min_world": 1},
	{"id": "homing_wand", "name": "Conduttore Psionico", "slot": "ARMA", "min_world": 1},
	{"id": "smg", "name": "Mitraglietta Cyber", "slot": "ARMA", "min_world": 2},
	{"id": "laser_rifle", "name": "Fucile Laser", "slot": "ARMA", "min_world": 2},
	{"id": "katana", "name": "Katana Termica", "slot": "ARMA", "min_world": 3},
	{"id": "scythe", "name": "Falce Quasar", "slot": "ARMA", "min_world": 4},
	{"id": "plasma_cannon", "name": "Cannone al Plasma", "slot": "ARMA", "min_world": 5},
	{"id": "kevlar", "name": "Giubbotto Kevlar", "slot": "CORAZZA", "min_world": 1},
	{"id": "nano_armor", "name": "Armatura Nano-Tech", "slot": "CORAZZA", "min_world": 2},
	{"id": "ring_crit", "name": "Anello Critico", "slot": "ANELLO 1", "min_world": 1},
	{"id": "ring_speed", "name": "Anello Velocità", "slot": "ANELLO 2", "min_world": 1},
	{"id": "drone_laser", "name": "Drone Laser", "slot": "PET 1", "min_world": 1},
	{"id": "drone_shield", "name": "Drone Scudo", "slot": "PET 2", "min_world": 2}
]

func roll_gear_rarity(world_num: int = 1, source: String = "RUN") -> String:
	var r: float = randf() * 100.0
	match source.to_upper():
		"CRATE_EPIC":
			# Cassa Ossidiana (300 Gemme): Raro garantito, buona chance Epico, 2% Leggendario!
			if r < 2.0: return "LEGENDARY"
			elif r < 30.0: return "EPIC"
			else: return "RARE"
		"CRATE_NORMAL":
			# Cassa Standard (100 Gemme): Comune/Raro, rarissimo Epico, 0% Leggendario
			if r < 2.5: return "EPIC"
			elif r < 28.0: return "RARE"
			else: return "COMMON"
		"BOSS":
			if world_num <= 4:
				if r < 3.5: return "EPIC"
				elif r < 32.0: return "RARE"
				else: return "COMMON"
			elif world_num <= 8:
				if r < 0.3: return "LEGENDARY"
				elif r < 9.5: return "EPIC"
				elif r < 48.0: return "RARE"
				else: return "COMMON"
			else:
				if r < 1.2: return "LEGENDARY"
				elif r < 18.0: return "EPIC"
				elif r < 64.0: return "RARE"
				else: return "COMMON"
		_: # "RUN" (nemici / casse in partita: la rarità alta si ottiene con la Sintesi 3-in-1!)
			if world_num <= 4:
				if r < 0.8: return "EPIC"
				elif r < 14.0: return "RARE"
				else: return "COMMON"
			elif world_num <= 8:
				if r < 0.1: return "LEGENDARY"
				elif r < 2.8: return "EPIC"
				elif r < 24.0: return "RARE"
				else: return "COMMON"
			else:
				if r < 0.35: return "LEGENDARY"
				elif r < 6.0: return "EPIC"
				elif r < 35.0: return "RARE"
				else: return "COMMON"

func roll_random_in_run_gear_drop(world_num: int = 1, source: String = "RUN") -> Dictionary:
	var eligible: Array = []
	for g in BASE_GEAR_CATALOG:
		if world_num >= int(g["min_world"]) or source.begins_with("CRATE"):
			eligible.append(g)
	if eligible.is_empty():
		eligible = [BASE_GEAR_CATALOG[0]]

	var base_def: Dictionary = eligible[randi() % eligible.size()]
	var rolled_rar: String = roll_gear_rarity(world_num, source)
	var chosen := {
		"id": str(base_def["id"]),
		"name": str(base_def["name"]),
		"slot": str(base_def["slot"]),
		"rarity": rolled_rar
	}
	add_item(str(chosen["id"]), str(chosen["name"]), str(chosen["slot"]), rolled_rar)
	return chosen

func get_next_rarity(current: String) -> String:
	var idx: int = RARITY_ORDER.find(current.to_upper())
	if idx >= 0 and idx < RARITY_ORDER.size() - 1:
		return RARITY_ORDER[idx + 1]
	return current.to_upper()

func _get_slot_equipped_id(slot_up: String) -> String:
	match slot_up:
		"ARMA": return equipped_weapon_id
		"CORAZZA": return equipped_armor_id
		"ANELLO 1": return equipped_ring1_id
		"ANELLO 2": return equipped_ring2_id
		"PET 1": return equipped_pet1_id
		"PET 2": return equipped_pet2_id
	return ""

func _resolve_slot_rarity(slot_up: String, target_id: String) -> String:
	if target_id.is_empty():
		return ""
	var saved_r: String = str(equipped_rarities.get(slot_up, "")).to_upper()
	if not saved_r.is_empty():
		for item in inventory:
			if str(item.get("id", "")) == target_id and str(item.get("rarity", "")).to_upper() == saved_r and int(item.get("count", 0)) > 0:
				return saved_r
	# Se non ancora salvata (es. salvataggio precedente), aggancia UNA SOLA copia reale posseduta (la più alta) e la fissa!
	var best_r: String = ""
	var best_rank: int = -1
	for item in inventory:
		if str(item.get("id", "")) == target_id and int(item.get("count", 0)) > 0:
			var r_up: String = str(item.get("rarity", "COMMON")).to_upper()
			var r_idx: int = RARITY_ORDER.find(r_up)
			if r_idx > best_rank:
				best_rank = r_idx
				best_r = r_up
	if best_r.is_empty():
		best_r = saved_r if not saved_r.is_empty() else "COMMON"
	equipped_rarities[slot_up] = best_r
	return best_r

func is_item_equipped(item_id: String, rarity_str: String = "") -> bool:
	if item_id.is_empty():
		return false
	var check_rar: String = rarity_str.to_upper()
	var slots := ["ARMA", "CORAZZA", "ANELLO 1", "ANELLO 2", "PET 1", "PET 2"]
	for s in slots:
		var eq_id: String = _get_slot_equipped_id(s)
		if eq_id == item_id:
			if check_rar.is_empty():
				return true
			if _resolve_slot_rarity(s, eq_id) == check_rar:
				return true
	return false

func equip_item(item_id: String, slot_type: String, rarity_str: String = "") -> void:
	var s_up := slot_type.to_upper()
	var chosen_rar := rarity_str.to_upper()
	if chosen_rar.is_empty():
		var best_rank: int = -1
		for item in inventory:
			if str(item.get("id", "")) == item_id and int(item.get("count", 0)) > 0:
				var r_up := str(item.get("rarity", "COMMON")).to_upper()
				var rk := RARITY_ORDER.find(r_up)
				if rk > best_rank:
					best_rank = rk
					chosen_rar = r_up
		if chosen_rar.is_empty():
			chosen_rar = "COMMON"

	# Garantisce che nei 2 slot Anello non finisca mai duplicato lo stesso singolo esemplare!
	if s_up == "ANELLO 1" and equipped_ring2_id == item_id and _resolve_slot_rarity("ANELLO 2", equipped_ring2_id) == chosen_rar:
		var copies := 0
		for it in inventory:
			if str(it.get("id", "")) == item_id and str(it.get("rarity", "")).to_upper() == chosen_rar:
				copies = int(it.get("count", 0))
		if copies < 2:
			equipped_ring2_id = ""
			equipped_rarities["ANELLO 2"] = ""
	elif s_up == "ANELLO 2" and equipped_ring1_id == item_id and _resolve_slot_rarity("ANELLO 1", equipped_ring1_id) == chosen_rar:
		var copies2 := 0
		for it in inventory:
			if str(it.get("id", "")) == item_id and str(it.get("rarity", "")).to_upper() == chosen_rar:
				copies2 = int(it.get("count", 0))
		if copies2 < 2:
			equipped_ring1_id = ""
			equipped_rarities["ANELLO 1"] = ""

	match s_up:
		"ARMA":
			equipped_weapon_id = item_id
			WeaponDB.equipped_weapon_id = item_id
		"CORAZZA":
			equipped_armor_id = item_id
			WeaponDB.equipped_armor_id = item_id
		"ANELLO 1":
			equipped_ring1_id = item_id
		"ANELLO 2":
			equipped_ring2_id = item_id
		"PET 1":
			equipped_pet1_id = item_id
		"PET 2":
			equipped_pet2_id = item_id
	equipped_rarities[s_up] = chosen_rar

	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()

func unequip_item(slot_type: String) -> void:
	var s_up := slot_type.to_upper()
	match s_up:
		"ARMA":
			equipped_weapon_id = "pistol_base"
			WeaponDB.equipped_weapon_id = "pistol_base"
			equipped_rarities["ARMA"] = _resolve_slot_rarity("ARMA", "pistol_base")
		"CORAZZA":
			equipped_armor_id = ""
			WeaponDB.equipped_armor_id = ""
			equipped_rarities["CORAZZA"] = ""
		"ANELLO 1":
			equipped_ring1_id = ""
			equipped_rarities["ANELLO 1"] = ""
		"ANELLO 2":
			equipped_ring2_id = ""
			equipped_rarities["ANELLO 2"] = ""
		"PET 1":
			equipped_pet1_id = ""
			equipped_rarities["PET 1"] = ""
		"PET 2":
			equipped_pet2_id = ""
			equipped_rarities["PET 2"] = ""

	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()

func get_equipped_item_in_slot(slot_type: String) -> Dictionary:
	var s_up := slot_type.to_upper()
	var target_id: String = _get_slot_equipped_id(s_up)
	if target_id.is_empty(): return {}

	var target_rar: String = _resolve_slot_rarity(s_up, target_id)
	for item in inventory:
		if str(item.get("id", "")) == target_id and str(item.get("rarity", "COMMON")).to_upper() == target_rar and int(item.get("count", 0)) > 0:
			return item

	var best_match: Dictionary = {}
	var best_rank: int = -1
	for item in inventory:
		if item["id"] == target_id and (int(item.get("count", 0)) > 0 or best_match.is_empty()):
			var r_idx: int = RARITY_ORDER.find(str(item.get("rarity", "COMMON")).to_upper())
			if r_idx > best_rank:
				best_rank = r_idx
				best_match = item

	if not best_match.is_empty():
		equipped_rarities[s_up] = str(best_match.get("rarity", "COMMON")).to_upper()
		return best_match
	return {"id": target_id, "name": target_id.capitalize(), "slot": slot_type, "rarity": target_rar if not target_rar.is_empty() else "COMMON"}

func get_item_power_score(item: Dictionary) -> int:
	var iid: String = str(item.get("id", ""))
	if iid.is_empty():
		return -1
	var rar: String = str(item.get("rarity", "COMMON")).to_upper()
	var slot_s: String = str(item.get("slot", "ARMA"))
	var st := get_item_primary_stat(iid, slot_s, rar)
	var rar_idx: int = maxi(0, RARITY_ORDER.find(rar))
	return int(st["value"]) * 10 + rar_idx * 120

func can_improve_loadout() -> bool:
	var slots := ["ARMA", "CORAZZA", "ANELLO 1", "ANELLO 2", "PET 1", "PET 2"]
	for s in slots:
		var cur_eq: Dictionary = get_equipped_item_in_slot(s)
		var cur_score: int = get_item_power_score(cur_eq) if not cur_eq.is_empty() else -1
		for item in inventory:
			var i_rar := str(item.get("rarity", "COMMON"))
			if int(item.get("count", 0)) <= 0 and not is_item_equipped(str(item.get("id", "")), i_rar):
				continue
			if str(item.get("slot", "")).to_upper() == s:
				if get_item_power_score(item) > cur_score:
					return true
	return false

func auto_equip_best() -> int:
	var slots := ["ARMA", "CORAZZA", "ANELLO 1", "ANELLO 2", "PET 1", "PET 2"]
	var changed: int = 0
	for s in slots:
		var cur_eq: Dictionary = get_equipped_item_in_slot(s)
		var cur_id: String = str(cur_eq.get("id", ""))
		var cur_rar: String = str(cur_eq.get("rarity", "")).to_upper()
		var best_id: String = cur_id
		var best_rar: String = cur_rar
		var best_score: int = get_item_power_score(cur_eq) if not best_id.is_empty() else -1
		for item in inventory:
			var iid: String = str(item.get("id", ""))
			var irar: String = str(item.get("rarity", "COMMON")).to_upper()
			if iid.is_empty():
				continue
			if int(item.get("count", 0)) <= 0 and not is_item_equipped(iid, irar):
				continue
			if str(item.get("slot", "")).to_upper() == s:
				var sc: int = get_item_power_score(item)
				if sc > best_score:
					best_score = sc
					best_id = iid
					best_rar = irar
		if not best_id.is_empty() and (best_id != cur_id or best_rar != cur_rar):
			equip_item(best_id, s, best_rar)
			changed += 1
	return changed

func get_fusible_items() -> Array:
	var fusible: Array = []
	for item in inventory:
		if int(item.get("count", 0)) >= 3 and item.get("rarity", "COMMON") != "LEGENDARY":
			fusible.append(item)
	return fusible

func merge_items(item_id: String, rarity: String) -> Dictionary:
	for i in range(inventory.size()):
		var item: Dictionary = inventory[i]
		if item["id"] == item_id and item["rarity"] == rarity:
			if int(item["count"]) >= 3:
				item["count"] -= 3
				var next_rar := get_next_rarity(rarity)
				var new_item_name: String = str(item["name"])
				_add_merged_item(item_id, new_item_name, str(item["slot"]), next_rar)
				# Se avevi innestato proprio questa copia e sono finite le copie vecchie, promuove automaticamente lo slot alla nuova rarità!
				if int(item["count"]) <= 0:
					for s_k in equipped_rarities.keys():
						if _get_slot_equipped_id(str(s_k)) == item_id and str(equipped_rarities[s_k]).to_upper() == rarity.to_upper():
							equipped_rarities[s_k] = next_rar
				var ss: Node = get_node_or_null("/root/SaveSystem")
				if ss and ss.has_method("save_game"): ss.save_game()
				return {"success": true, "message": "★ FUSIONE RIUSCITA: Creato " + new_item_name + " (" + next_rar + ")!"}
	return {"success": false, "message": "Fusione non disponibile: servono 3 copie identiche."}

func add_item(item_id: String, item_name: String, slot_type: String, rarity: String) -> void:
	for item in inventory:
		if item["id"] == item_id and item["rarity"] == rarity:
			item["count"] = int(item.get("count", 1)) + 1
			var ss: Node = get_node_or_null("/root/SaveSystem")
			if ss and ss.has_method("save_game"): ss.save_game()
			return

	inventory.append({
		"id": item_id,
		"name": item_name,
		"slot": slot_type,
		"rarity": rarity,
		"count": 1
	})
	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()

func _add_merged_item(item_id: String, item_name: String, slot_type: String, rarity: String) -> void:
	add_item(item_id, item_name, slot_type, rarity)
