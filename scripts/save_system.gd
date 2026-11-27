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
			"player_color_id": Global.player_color_id,
			"equipped_skin_id": Global.equipped_skin_id,
			"unlocked_skins": Global.unlocked_skins
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
			"max_unlocked_world": Global.max_unlocked_world,
			"world_best_room": Global.world_best_room,
			"world_milestones_claimed": Global.world_milestones_claimed
		},
		"inventory": {
			"equipped_weapon_id": im.equipped_weapon_id if (im and "equipped_weapon_id" in im) else "pistol_base",
			"equipped_armor_id": im.equipped_armor_id if (im and "equipped_armor_id" in im) else "",
			"equipped_ring1_id": im.equipped_ring1_id if (im and "equipped_ring1_id" in im) else "",
			"equipped_ring2_id": im.equipped_ring2_id if (im and "equipped_ring2_id" in im) else "",
			"equipped_pet1_id": im.equipped_pet1_id if (im and "equipped_pet1_id" in im) else "",
			"equipped_pet2_id": im.equipped_pet2_id if (im and "equipped_pet2_id" in im) else "",
			"equipped_rarities": im.equipped_rarities if (im and "equipped_rarities" in im) else {},
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
	Global.player_name = str(prof.get("player_name", "V-77"))
	Global.player_class = str(prof.get("player_class", "RONIN"))
	Global.player_color_id = str(prof.get("player_color_id", "CYAN"))
	Global.equipped_skin_id = str(prof.get("equipped_skin_id", "v_runner"))
	if not Global.SKIN_DEFS.has(Global.equipped_skin_id):
		Global.equipped_skin_id = "v_runner"
	if prof.get("unlocked_skins") is Array:
		Global.unlocked_skins = prof["unlocked_skins"]
		if not Global.unlocked_skins.has("v_runner"):
			Global.unlocked_skins.append("v_runner")

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

	# Restore World & Milestone Progress
	if data.has("world") and data["world"] is Dictionary:
		var wd_d: Dictionary = data["world"]
		Global.max_unlocked_world = max(1, int(wd_d.get("max_unlocked_world", 1)))
		if wd_d.get("world_best_room") is Dictionary:
			Global.world_best_room = wd_d["world_best_room"]
		if wd_d.get("world_milestones_claimed") is Dictionary:
			Global.world_milestones_claimed = wd_d["world_milestones_claimed"]
		var wdb: Node = get_node_or_null("/root/WorldDB")
		if wdb and "selected_world_id" in wdb:
			wdb.selected_world_id = str(wd_d.get("selected_world_id", "world_1"))

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
			if "equipped_rarities" in im and inv_data.get("equipped_rarities") is Dictionary:
				var eq_r: Dictionary = inv_data["equipped_rarities"]
				for rk in eq_r.keys():
					im.equipped_rarities[str(rk)] = str(eq_r[rk])
			if "inventory" in im and inv_data.get("items") is Array:
				im.inventory = inv_data["items"]
			if "item_levels" in im and inv_data.get("item_levels") is Dictionary:
				im.item_levels = inv_data["item_levels"]

	# Restore Talents
	if data.has("talents") and data["talents"] is Dictionary:
		var tm: Node = get_node_or_null("/root/TalentManager")
		if tm and "talent_levels" in tm and data["talents"].get("levels") is Dictionary:
			var loaded_lvls: Dictionary = data["talents"]["levels"]
			for k in loaded_lvls.keys():
				tm.talent_levels[str(k)] = int(loaded_lvls[k])

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
	Global.equipped_skin_id = "v_runner"
	Global.unlocked_skins = ["v_runner"]
	Global.total_coins = 0
	Global.total_credits = 0
	Global.upgrade_scrolls = 3 # 3 Nuclei iniziali di benvenuto per provare il potenziamento
	Global.max_unlocked_world = 1
	Global.world_best_room = {}
	Global.world_milestones_claimed = {}
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
		for k in tm.talent_levels.keys():
			tm.talent_levels[k] = 0
