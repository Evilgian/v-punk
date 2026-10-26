extends Node

# Identità Giocatore (Creazione Personaggio)
var profile_created: bool = false
var player_name: String = ""
var player_class: String = "RONIN" # RONIN, VANGUARD, NETRUNNER
var player_color_id: String = "CYAN" # CYAN, MAGENTA, GOLD, GREEN

# Impostazioni Audio, Vibrazione & Account Google Play
var sfx_volume: float = 0.85
var music_volume: float = 0.65
var screen_shake_enabled: bool = true
var google_account_linked: bool = false
var google_account_name: String = ""

# Economia & Progressione (Partenza pulita da zero)
var total_credits: int = 0
var total_coins: int = 0
var upgrade_scrolls: int = 0 # Nuclei Cyber-Upgrade ⚙️ per potenziare il livello di Armi, Corazze, Anelli e Droni
var max_unlocked_world: int = 1 # Sblocco sequenziale Mondi (1 -> 8)
var last_run_rewards: Dictionary = {} # Riepilogo premi fine mondo

var upgrade_dmg_lvl: int = 0
var upgrade_hp_lvl: int = 0

var daily_ads_watched: int = 0
var checkin_day: int = 1
var checkin_claimed: bool = false

var quest_kills: int = 0
var quest_runs: int = 0
var quest_talents: int = 0
var quests_claimed: Dictionary = {}

const DMG_COST: int = 50
const HP_COST: int = 50

func get_player_accent_color() -> Color:
	match player_color_id.to_upper():
		"MAGENTA": return Color(1.0, 0.12, 0.52, 1.0)
		"GOLD": return Color(1.0, 0.86, 0.08, 1.0)
		"GREEN": return Color(0.12, 1.0, 0.52, 1.0)
		_: return Color(0.0, 0.95, 1.0, 1.0)

func get_class_display_name() -> String:
	match player_class.to_upper():
		"VANGUARD": return "VANGUARD"
		"NETRUNNER": return "NETRUNNER"
		_: return "RONIN"

func save_data() -> void:
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"):
		ss.save_game()
