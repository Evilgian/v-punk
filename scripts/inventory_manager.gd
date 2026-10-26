extends Node

# 6 Active Equipment Slots (Solo l'arma base all'inizio; gli altri 5 slot sono vuoti!)
var equipped_weapon_id: String = "pistol_base"
var equipped_armor_id: String = ""
var equipped_ring1_id: String = ""
var equipped_ring2_id: String = ""
var equipped_pet1_id: String = ""
var equipped_pet2_id: String = ""

# Owned items inventory list: Array of Dictionaries
# Structure: {"id": String, "name": String, "slot": String, "rarity": String, "count": int}
var inventory: Array = [
	{"id": "pistol_base", "name": "Pistola Base", "slot": "ARMA", "rarity": "COMMON", "count": 1}
]

func init_starter_loadout(chosen_class: String) -> void:
	equipped_armor_id = ""
	equipped_ring1_id = ""
	equipped_ring2_id = ""
	equipped_pet1_id = ""
	equipped_pet2_id = ""
	WeaponDB.equipped_armor_id = ""

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
				{"id": "pistol_base", "name": "Pistola Base", "slot": "ARMA", "rarity": "COMMON", "count": 1}
			]

const RARITY_ORDER := ["COMMON", "RARE", "EPIC", "LEGENDARY"]

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

	for item in inventory:
		if item["id"] == target_id:
			return item

	return {"id": target_id, "name": target_id.capitalize(), "slot": slot_type, "rarity": "COMMON"}

## Controlla se esiste un gruppo di 3 oggetti identici per la fusione
func get_fusible_items() -> Array:
	var fusible: Array = []
	for item in inventory:
		if int(item.get("count", 0)) >= 3 and item.get("rarity", "COMMON") != "LEGENDARY":
			fusible.append(item)
	return fusible

## Esegue la fusione 3-in-1: consuma 3 oggetti identici e crea 1 oggetto di rarità superiore
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
				return {"success": true, "message": "🎉 FUSIONE RIUSCITA: Creato " + new_item_name + " (" + next_rar + ")!"}
	return {"success": false, "message": "❌ Fusione fallita: Servono 3 oggetti identici!"}

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
