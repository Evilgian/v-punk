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
		"profile": {
			"profile_created": Global.profile_created,
			"player_name": Global.player_name,
			"player_class": Global.player_class,
			"player_color_id": Global.player_color_id
		},
		"settings": {
			"sfx_volume": Global.sfx_volume,
			"music_volume": Global.music_volume,
			"screen_shake_enabled": Global.screen_shake_enabled,
			"google_account_linked": Global.google_account_linked,
			"google_account_name": Global.google_account_name
		},
		"economy": {
			"total_coins": Global.total_coins,
			"total_credits": Global.total_credits,
			"upgrade_scrolls": Global.upgrade_scrolls,
			"daily_ads_watched": Global.daily_ads_watched,
			"checkin_day": Global.checkin_day,
			"checkin_claimed": Global.checkin_claimed
		},
		"world": {
			"selected_world_id": wdb.selected_world_id if (wdb and "selected_world_id" in wdb) else "world_1",
			"max_unlocked_world": Global.max_unlocked_world
		},
		"inventory": {
			"equipped_weapon_id": im.equipped_weapon_id if (im and "equipped_weapon_id" in im) else "pistol_base",
			"equipped_armor_id": im.equipped_armor_id if (im and "equipped_armor_id" in im) else "",
			"equipped_ring1_id": im.equipped_ring1_id if (im and "equipped_ring1_id" in im) else "",
			"equipped_ring2_id": im.equipped_ring2_id if (im and "equipped_ring2_id" in im) else "",
			"equipped_pet1_id": im.equipped_pet1_id if (im and "equipped_pet1_id" in im) else "",
			"equipped_pet2_id": im.equipped_pet2_id if (im and "equipped_pet2_id" in im) else "",
			"items": im.inventory if (im and "inventory" in im) else [],
			"item_levels": im.item_levels if (im and "item_levels" in im) else {}
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

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		Global.profile_created = false
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var json_text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_text)
	if not (parsed is Dictionary):
		Global.profile_created = false
		return

	var data: Dictionary = parsed as Dictionary

	# Se il salvataggio appartiene alla versione precedente senza creazione personaggio, forza la creazione da zero!
	if not data.has("profile") or not (data["profile"] is Dictionary) or not bool(data["profile"].get("profile_created", false)):
		reset_save()
		return

	var prof: Dictionary = data["profile"]
	Global.profile_created = bool(prof.get("profile_created", false))
	Global.player_name = str(prof.get("player_name", "V-RONIN"))
	Global.player_class = str(prof.get("player_class", "RONIN"))
	Global.player_color_id = str(prof.get("player_color_id", "CYAN"))

	if data.has("settings") and data["settings"] is Dictionary:
		var st: Dictionary = data["settings"]
		Global.sfx_volume = clampf(float(st.get("sfx_volume", 0.85)), 0.0, 1.0)
		Global.music_volume = clampf(float(st.get("music_volume", 0.65)), 0.0, 1.0)
		Global.screen_shake_enabled = bool(st.get("screen_shake_enabled", true))
		Global.google_account_linked = bool(st.get("google_account_linked", false))
		Global.google_account_name = str(st.get("google_account_name", ""))
		if SoundFX and SoundFX.has_method("apply_volume_settings"):
			SoundFX.apply_volume_settings()

	# Restore Economy & Profile
	if data.has("economy") and data["economy"] is Dictionary:
		var eco: Dictionary = data["economy"]
		Global.total_coins = int(eco.get("total_coins", 0))
		Global.total_credits = int(eco.get("total_credits", 0))
		Global.upgrade_scrolls = int(eco.get("upgrade_scrolls", 0))
		Global.daily_ads_watched = int(eco.get("daily_ads_watched", 0))
		Global.checkin_day = int(eco.get("checkin_day", 1))
		Global.checkin_claimed = bool(eco.get("checkin_claimed", false))

	# Restore World
	if data.has("world") and data["world"] is Dictionary:
		Global.max_unlocked_world = max(1, int(data["world"].get("max_unlocked_world", 1)))
		var wdb: Node = get_node_or_null("/root/WorldDB")
		if wdb and "selected_world_id" in wdb:
			wdb.selected_world_id = str(data["world"].get("selected_world_id", "world_1"))

	# Restore Inventory & 6 Slots
	if data.has("inventory") and data["inventory"] is Dictionary:
		var inv_data: Dictionary = data["inventory"]
		var im: Node = get_node_or_null("/root/InventoryManager")
		if im:
			if "equipped_weapon_id" in im:
				im.equipped_weapon_id = str(inv_data.get("equipped_weapon_id", "pistol_base"))
				WeaponDB.equipped_weapon_id = im.equipped_weapon_id
			if "equipped_armor_id" in im:
				im.equipped_armor_id = str(inv_data.get("equipped_armor_id", ""))
				WeaponDB.equipped_armor_id = im.equipped_armor_id
			if "equipped_ring1_id" in im: im.equipped_ring1_id = str(inv_data.get("equipped_ring1_id", ""))
			if "equipped_ring2_id" in im: im.equipped_ring2_id = str(inv_data.get("equipped_ring2_id", ""))
			if "equipped_pet1_id" in im: im.equipped_pet1_id = str(inv_data.get("equipped_pet1_id", ""))
			if "equipped_pet2_id" in im: im.equipped_pet2_id = str(inv_data.get("equipped_pet2_id", ""))
			if "inventory" in im and inv_data.get("items") is Array:
				im.inventory = inv_data["items"]
			if "item_levels" in im and inv_data.get("item_levels") is Dictionary:
				im.item_levels = inv_data["item_levels"]

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

func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	Global.profile_created = false
	Global.player_name = ""
	Global.player_class = "RONIN"
	Global.player_color_id = "CYAN"
	Global.total_coins = 0
	Global.total_credits = 0
	Global.upgrade_scrolls = 3 # 3 Nuclei iniziali di benvenuto per provare il potenziamento
	Global.max_unlocked_world = 1
	Global.daily_ads_watched = 0
	Global.checkin_day = 1
	Global.checkin_claimed = false
	Global.quest_kills = 0
	Global.quest_runs = 0
	Global.quest_talents = 0
	Global.quests_claimed = {}

	var wdb: Node = get_node_or_null("/root/WorldDB")
	if wdb and "selected_world_id" in wdb:
		wdb.selected_world_id = "world_1"

	var im: Node = get_node_or_null("/root/InventoryManager")
	if im and im.has_method("init_starter_loadout"):
		im.init_starter_loadout("RONIN")

	var tm: Node = get_node_or_null("/root/TalentManager")
	if tm and "talent_levels" in tm:
		tm.talent_levels = {"atk": 0, "hp": 0, "crit": 0, "recovery": 0, "speed": 0, "gold": 0}
