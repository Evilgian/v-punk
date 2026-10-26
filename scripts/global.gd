extends Node

var total_credits: int = 200
var total_coins: int = 1250
var upgrade_dmg_lvl: int = 0
var upgrade_hp_lvl: int = 0

var daily_ads_watched: int = 0
var checkin_day: int = 1
var checkin_claimed: bool = false

var quest_kills: int = 15
var quest_runs: int = 2
var quest_talents: int = 1
var quests_claimed: Dictionary = {}

const DMG_COST: int = 50
const HP_COST: int = 50

const SAVE_PATH: String = "user://v_punk_save.dat"

func _ready() -> void:
	load_data()

func save_data() -> void:
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"):
		ss.save_game()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nessun salvataggio trovato. Inizializzazione nuovo profilo.")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_text := file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(json_text)
		if parsed is Dictionary:
			total_credits = int(parsed.get("total_credits", 200))
			total_coins = int(parsed.get("total_coins", 1250))
			upgrade_dmg_lvl = int(parsed.get("upgrade_dmg_lvl", 0))
			upgrade_hp_lvl = int(parsed.get("upgrade_hp_lvl", 0))
			daily_ads_watched = int(parsed.get("daily_ads_watched", 0))
			checkin_day = int(parsed.get("checkin_day", 1))
			checkin_claimed = bool(parsed.get("checkin_claimed", false))
			quest_kills = int(parsed.get("quest_kills", 15))
			quest_runs = int(parsed.get("quest_runs", 2))
			quest_talents = int(parsed.get("quest_talents", 1))
			if parsed.has("quests_claimed") and parsed["quests_claimed"] is Dictionary:
				quests_claimed = parsed["quests_claimed"]
			print("Salvataggio caricato! Gemme: ", total_credits, " | Monete: ", total_coins)
