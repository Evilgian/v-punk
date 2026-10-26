extends Node

const SAVE_PATH: String = "user://save_data.json"

func _ready() -> void:
	load_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()

func save_game() -> void:
	var im: Node = get_node_or_null("/root/InventoryManager")
	var tm: Node = get_node_or_null("/root/TalentManager")
	var wdb: Node = get_node_or_null("/root/WorldDB")

	var save_dict := {
		"economy": {
			"total_coins": Global.total_coins,
			"total_credits": Global.total_credits,
			"daily_ads_watched": Global.daily_ads_watched,
			"checkin_day": Global.checkin_day,
			"checkin_claimed": Global.checkin_claimed
		},
		"world": {
			"selected_world_id": wdb.selected_world_id if (wdb and "selected_world_id" in wdb) else "world_1"
		},
		"inventory": {
			"equipped_weapon_id": im.equipped_weapon_id if (im and "equipped_weapon_id" in im) else "pistol_base",
			"equipped_armor_id": im.equipped_armor_id if (im and "equipped_armor_id" in im) else "kevlar",
			"equipped_ring1_id": im.equipped_ring1_id if (im and "equipped_ring1_id" in im) else "ring_crit",
			"equipped_ring2_id": im.equipped_ring2_id if (im and "equipped_ring2_id" in im) else "ring_speed",
			"equipped_pet1_id": im.equipped_pet1_id if (im and "equipped_pet1_id" in im) else "drone_laser",
			"equipped_pet2_id": im.equipped_pet2_id if (im and "equipped_pet2_id" in im) else "drone_shield",
			"items": im.inventory if (im and "inventory" in im) else []
		},
		"talents": {
			"levels": tm.talent_levels if (tm and "talent_levels" in tm) else {}
		},
		"quests": {
			"quest_kills": Global.quest_kills,
			"quest_runs": Global.quest_runs,
			"quest_talents": Global.quest_talents,
			"quests_claimed": Global.quests_claimed
		}
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))
		file.close()
		print("💾 SaveSystem: Dati salvati con successo su disco (user://save_data.json)!")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("💾 SaveSystem: Nessun salvataggio trovato. Creazione nuovo profilo iniziale.")
		save_game()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var json_text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_text)
	if not (parsed is Dictionary):
		print("❌ SaveSystem: Errore parsing JSON salvataggio!")
		return

	var data: Dictionary = parsed as Dictionary

	# Restore Economy & Profile
	if data.has("economy") and data["economy"] is Dictionary:
		var eco: Dictionary = data["economy"]
		Global.total_coins = int(eco.get("total_coins", 1250))
		Global.total_credits = int(eco.get("total_credits", 200))
		Global.daily_ads_watched = int(eco.get("daily_ads_watched", 0))
		Global.checkin_day = int(eco.get("checkin_day", 1))
		Global.checkin_claimed = bool(eco.get("checkin_claimed", false))

	# Restore World
	if data.has("world") and data["world"] is Dictionary:
		var wdb: Node = get_node_or_null("/root/WorldDB")
		if wdb and "selected_world_id" in wdb:
			wdb.selected_world_id = str(data["world"].get("selected_world_id", "world_1"))

	# Restore Inventory & 6 Slots
	if data.has("inventory") and data["inventory"] is Dictionary:
		var inv_data: Dictionary = data["inventory"]
		var im: Node = get_node_or_null("/root/InventoryManager")
		if im:
			if "equipped_weapon_id" in im: im.equipped_weapon_id = str(inv_data.get("equipped_weapon_id", "pistol_base"))
			if "equipped_armor_id" in im: im.equipped_armor_id = str(inv_data.get("equipped_armor_id", "kevlar"))
			if "equipped_ring1_id" in im: im.equipped_ring1_id = str(inv_data.get("equipped_ring1_id", "ring_crit"))
			if "equipped_ring2_id" in im: im.equipped_ring2_id = str(inv_data.get("equipped_ring2_id", "ring_speed"))
			if "equipped_pet1_id" in im: im.equipped_pet1_id = str(inv_data.get("equipped_pet1_id", "drone_laser"))
			if "equipped_pet2_id" in im: im.equipped_pet2_id = str(inv_data.get("equipped_pet2_id", "drone_shield"))
			if "inventory" in im and inv_data.get("items") is Array:
				im.inventory = inv_data["items"]

	# Restore Talents
	if data.has("talents") and data["talents"] is Dictionary:
		var tm: Node = get_node_or_null("/root/TalentManager")
		if tm and "talent_levels" in tm and data["talents"].get("levels") is Dictionary:
			tm.talent_levels = data["talents"]["levels"]

	# Restore Quests
	if data.has("quests") and data["quests"] is Dictionary:
		var q_data: Dictionary = data["quests"]
		Global.quest_kills = int(q_data.get("quest_kills", 0))
		Global.quest_runs = int(q_data.get("quest_runs", 0))
		Global.quest_talents = int(q_data.get("quest_talents", 0))
		if q_data.get("quests_claimed") is Dictionary:
			Global.quests_claimed = q_data["quests_claimed"]

	print("📂 SaveSystem: Salvataggio caricato con successo! Monete: ", Global.total_coins, " | Gemme: ", Global.total_credits)

func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	Global.total_coins = 1250
	Global.total_credits = 200
	Global.daily_ads_watched = 0
	Global.checkin_day = 1
	Global.checkin_claimed = false
	Global.quest_kills = 0
	Global.quest_runs = 0
	Global.quest_talents = 0
	Global.quests_claimed = {}

	var tm: Node = get_node_or_null("/root/TalentManager")
	if tm and "talent_levels" in tm:
		tm.talent_levels = {"atk": 0, "hp": 0, "crit": 0, "recovery": 0, "speed": 0, "gold": 0}

	save_game()
	print("⚠️ SaveSystem: Profilo resettato alle impostazioni di fabbrica!")
