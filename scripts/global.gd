extends Node

const GAME_VERSION: String = "v2.4.0"

# Flag di sessione: mostra la schermata d'entrata cinematografica solo all'apertura dell'app
var boot_entrance_shown: bool = false

# Identità Giocatore & Sistema Skin Cyberpunk
var profile_created: bool = false
var player_name: String = ""
var player_class: String = "RONIN" # RONIN, VANGUARD, NETRUNNER
var player_color_id: String = "CYAN" # CYAN, MAGENTA, GOLD, GREEN
var equipped_skin_id: String = "v_runner"
var unlocked_skins: Array = ["v_runner"]

const SKIN_ORDER: Array[String] = [
	"v_runner",
	"net_ghost",
	"neon_rebel",
	"trauma_valkyrie",
	"chrome_overlord"
]

const SKIN_DEFS: Dictionary = {
	"v_runner": {
		"id": "v_runner",
		"name": "V-RUNNER",
		"role": "MERCENARIO DI STRADA",
		"rarity": "RARE",
		"perk_title": "ISTINTO DI STRADA",
		"perk_desc": "+10% Velocità  •  +15% Crediti Raccolti",
		"unlock_world": 1,
		"gem_cost": 0,
		"accent": Color(0.0, 0.94, 1.0, 1.0),
		"spd_pct": 10.0,
		"coin_pct": 15.0
	},
	"net_ghost": {
		"id": "net_ghost",
		"name": "GHOST NETRUNNER",
		"role": "HACKER SINAPTICA",
		"rarity": "EPIC",
		"perk_title": "OVERCLOCK NEURALE",
		"perk_desc": "+16% Cadenza Fuoco  •  +25% EXP in Run",
		"unlock_world": 3,
		"gem_cost": 250,
		"accent": Color(0.76, 0.28, 1.0, 1.0),
		"fire_rate_pct": 16.0,
		"exp_pct": 25.0
	},
	"neon_rebel": {
		"id": "neon_rebel",
		"name": "NEON REBEL",
		"role": "CYBER-PUNK RIBELLE",
		"rarity": "EPIC",
		"perk_title": "SCARICA ADRENALINICA",
		"perk_desc": "+14% Prob. Critico  •  +30% Danno Critico",
		"unlock_world": 5,
		"gem_cost": 450,
		"accent": Color(1.0, 0.12, 0.56, 1.0),
		"crit_pct": 14.0,
		"crit_dmg_pct": 30.0
	},
	"trauma_valkyrie": {
		"id": "trauma_valkyrie",
		"name": "TRAUMA VALKYRIE",
		"role": "COMMANDO BIO-MED",
		"rarity": "LEGENDARY",
		"perk_title": "PROTOCOLLO TRAUMA-TEAM",
		"perk_desc": "+55 HP Massimi  •  Rigenera +4 HP ogni 3s",
		"unlock_world": 8,
		"gem_cost": 700,
		"accent": Color(0.10, 0.98, 0.72, 1.0),
		"hp_flat": 55,
		"regen_stacks": 1
	},
	"chrome_overlord": {
		"id": "chrome_overlord",
		"name": "CHROME OVERLORD",
		"role": "CYBORG CORPORATIVO",
		"rarity": "LEGENDARY",
		"perk_title": "TELAIO FULL-CHROME",
		"perk_desc": "+22% Danno Armi  •  +80 HP  •  +1 Scudo",
		"unlock_world": 11,
		"gem_cost": 1100,
		"accent": Color(0.99, 0.86, 0.12, 1.0),
		"atk_pct": 22.0,
		"hp_flat": 80,
		"start_shield": 1
	}
}

# Impostazioni Audio, Vibrazione & Account Google Play
var sfx_volume: float = 0.85
var music_volume: float = 0.65
var screen_shake_enabled: bool = true
var google_account_linked: bool = false
var google_account_name: String = ""

# Economia & Progressione (Partenza pulita da zero)
var total_credits: int = 0
var total_coins: int = 0
var upgrade_scrolls: int = 0
var max_unlocked_world: int = 1
var world_best_room: Dictionary = {}
var world_milestones_claimed: Dictionary = {}
var last_run_rewards: Dictionary = {}

# Contatori live della partita in corso (mostrati nell'HUD in alto a destra)
var run_coins: int = 0
var run_scrolls: int = 0

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
		"MAGENTA": return Color(1.0, 0.14, 0.54, 1.0)
		"GOLD": return Color(1.0, 0.86, 0.10, 1.0)
		"GREEN": return Color(0.12, 1.0, 0.54, 1.0)
		_: return Color(0.0, 0.94, 1.0, 1.0)

func get_class_display_name() -> String:
	match player_class.to_upper():
		"VANGUARD": return "VANGUARD"
		"NETRUNNER": return "NETRUNNER"
		_: return "RONIN"

func get_world_best_room(world_id: String) -> int:
	var rec: int = int(world_best_room.get(world_id, 0))
	var wdb: Node = get_node_or_null("/root/WorldDB")
	if wdb and "world_order" in wdb and "worlds" in wdb:
		var idx: int = wdb.world_order.find(world_id) + 1
		if idx > 0 and idx < max_unlocked_world and wdb.worlds.has(world_id):
			rec = maxi(rec, int(wdb.worlds[world_id].total_rooms))
	return rec

func record_world_progress(world_id: String, room_reached: int) -> void:
	var prev: int = int(world_best_room.get(world_id, 0))
	if room_reached > prev:
		world_best_room[world_id] = room_reached
		save_data()

func get_skin_def(skin_id: String = "") -> Dictionary:
	var sid: String = skin_id if not skin_id.is_empty() else equipped_skin_id
	if SKIN_DEFS.has(sid):
		return SKIN_DEFS[sid] as Dictionary
	return SKIN_DEFS["v_runner"] as Dictionary

func is_skin_unlocked(skin_id: String) -> bool:
	if skin_id == "v_runner" or unlocked_skins.has(skin_id):
		return true
	var d: Dictionary = get_skin_def(skin_id)
	var req_w: int = int(d.get("unlock_world", 99))
	return max_unlocked_world >= req_w

func unlock_skin_with_gems(skin_id: String) -> Dictionary:
	if is_skin_unlocked(skin_id):
		return {"success": true, "already": true}
	var d: Dictionary = get_skin_def(skin_id)
	var cost: int = int(d.get("gem_cost", 500))
	if total_credits < cost:
		return {"success": false, "message": "Gemme insufficienti! Servono " + str(cost) + " Gemme."}
	total_credits -= cost
	if not unlocked_skins.has(skin_id):
		unlocked_skins.append(skin_id)
	equipped_skin_id = skin_id
	save_data()
	return {"success": true, "name": str(d.get("name", skin_id))}

func unlock_all_skins_vip() -> void:
	for sid in SKIN_ORDER:
		if not unlocked_skins.has(sid):
			unlocked_skins.append(sid)
	save_data()

func save_data() -> void:
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"):
		ss.save_game()
