extends Node

var equipped_weapon_id: String = "pistol_base"
var equipped_armor_id: String = ""
var equipped_ring1_id: String = ""
var equipped_ring2_id: String = ""
var equipped_pet1_id: String = ""
var equipped_pet2_id: String = ""

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

func roll_random_in_run_gear_drop(world_num: int = 1) -> Dictionary:
	var gear_pool := [
		{"id": "kevlar", "name": "Giubbotto Kevlar", "slot": "CORAZZA", "rarity": "COMMON"},
		{"id": "nano_armor", "name": "Armatura Nano-Tech", "slot": "CORAZZA", "rarity": "RARE" if world_num < 3 else "EPIC"},
		{"id": "ring_crit", "name": "Anello Critico", "slot": "ANELLO 1", "rarity": "COMMON"},
		{"id": "ring_speed", "name": "Anello Velocità", "slot": "ANELLO 2", "rarity": "COMMON" if world_num < 2 else "RARE"},
		{"id": "drone_laser", "name": "Drone Laser", "slot": "PET 1", "rarity": "RARE"},
		{"id": "drone_shield", "name": "Drone Scudo", "slot": "PET 2", "rarity": "RARE" if world_num < 3 else "EPIC"},
		{"id": "pistol_base", "name": "Pistola Cyber", "slot": "ARMA", "rarity": "COMMON"},
		{"id": "shotgun", "name": "Fucile a Pompa", "slot": "ARMA", "rarity": "COMMON"},
		{"id": "homing_wand", "name": "Conduttore Psionico", "slot": "ARMA", "rarity": "RARE"},
		{"id": "smg", "name": "Mitraglietta Cyber", "slot": "ARMA", "rarity": "RARE"},
		{"id": "katana", "name": "Katana Termica", "slot": "ARMA", "rarity": "EPIC"},
		{"id": "laser_rifle", "name": "Fucile Laser", "slot": "ARMA", "rarity": "EPIC"}
	]
	if world_num >= 3:
		gear_pool.append({"id": "scythe", "name": "Falce Quasar", "slot": "ARMA", "rarity": "LEGENDARY"})
		gear_pool.append({"id": "plasma_cannon", "name": "Cannone al Plasma", "slot": "ARMA", "rarity": "LEGENDARY"})

	var chosen: Dictionary = gear_pool[randi() % gear_pool.size()].duplicate()
	add_item(str(chosen["id"]), str(chosen["name"]), str(chosen["slot"]), str(chosen["rarity"]))
	return chosen

func get_next_rarity(current: String) -> String:
	var idx: int = RARITY_ORDER.find(current.to_upper())
	if idx >= 0 and idx < RARITY_ORDER.size() - 1:
		return RARITY_ORDER[idx + 1]
	return current.to_upper()

func is_item_equipped(item_id: String) -> bool:
	return (equipped_weapon_id == item_id or equipped_armor_id == item_id or \
			equipped_ring1_id == item_id or equipped_ring2_id == item_id or \
			equipped_pet1_id == item_id or equipped_pet2_id == item_id)

func equip_item(item_id: String, slot_type: String) -> void:
	match slot_type.to_upper():
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

	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()

func unequip_item(slot_type: String) -> void:
	match slot_type.to_upper():
		"ARMA":
			equipped_weapon_id = "pistol_base"
			WeaponDB.equipped_weapon_id = "pistol_base"
		"CORAZZA":
			equipped_armor_id = ""
			WeaponDB.equipped_armor_id = ""
		"ANELLO 1":
			equipped_ring1_id = ""
		"ANELLO 2":
			equipped_ring2_id = ""
		"PET 1":
			equipped_pet1_id = ""
		"PET 2":
			equipped_pet2_id = ""

	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()

func get_equipped_item_in_slot(slot_type: String) -> Dictionary:
	var target_id: String = ""
	match slot_type.to_upper():
		"ARMA": target_id = equipped_weapon_id
		"CORAZZA": target_id = equipped_armor_id
		"ANELLO 1": target_id = equipped_ring1_id
		"ANELLO 2": target_id = equipped_ring2_id
		"PET 1": target_id = equipped_pet1_id
		"PET 2": target_id = equipped_pet2_id

	if target_id.is_empty(): return {}

	var best_match: Dictionary = {}
	var best_rank: int = -1
	for item in inventory:
		if item["id"] == target_id and (int(item.get("count", 0)) > 0 or best_match.is_empty()):
			var r_idx: int = RARITY_ORDER.find(str(item.get("rarity", "COMMON")).to_upper())
			if r_idx > best_rank:
				best_rank = r_idx
				best_match = item

	if not best_match.is_empty():
		return best_match
	return {"id": target_id, "name": target_id.capitalize(), "slot": slot_type, "rarity": "COMMON"}

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
			if int(item.get("count", 0)) <= 0 and not is_item_equipped(str(item.get("id", ""))):
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
		var best_id: String = str(cur_eq.get("id", ""))
		var best_score: int = get_item_power_score(cur_eq) if not best_id.is_empty() else -1
		for item in inventory:
			var iid: String = str(item.get("id", ""))
			if iid.is_empty():
				continue
			if int(item.get("count", 0)) <= 0 and not is_item_equipped(iid):
				continue
			if str(item.get("slot", "")).to_upper() == s:
				var sc: int = get_item_power_score(item)
				if sc > best_score:
					best_score = sc
					best_id = iid
		if not best_id.is_empty() and best_id != str(cur_eq.get("id", "")):
			equip_item(best_id, s)
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
