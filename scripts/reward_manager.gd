extends Node

const CHECKIN_REWARDS := [
	{"day": 1, "type": "coins", "amount": 250, "label": "250 Monete", "icon": "🪙", "amt": 250},
	{"day": 2, "type": "gems", "amount": 20, "label": "20 Gemme", "icon": "💎", "amt": 20},
	{"day": 3, "type": "coins", "amount": 500, "label": "500 Monete", "icon": "🪙", "amt": 500},
	{"day": 4, "type": "gems", "amount": 50, "label": "50 Gemme", "icon": "💎", "amt": 50},
	{"day": 5, "type": "coins", "amount": 1000, "label": "1000 Monete", "icon": "🪙", "amt": 1000},
	{"day": 6, "type": "gems", "amount": 100, "label": "100 Gemme", "icon": "💎", "amt": 100},
	{"day": 7, "type": "key", "amount": 1, "label": "Chiave Cassa Epica", "icon": "🔑", "amt": 1}
]

const DAILY_QUESTS := [
	{"id": "d1", "category": "DAILY", "title": "🎯 Sconfiggi 30 Nemici", "desc": "Elimina 30 nemici in qualsiasi partita", "stat": "quest_kills", "target_amt": 30, "max": 30, "reward_type": "coins", "reward_amt": 250},
	{"id": "d2", "category": "DAILY", "title": "🚀 Gioca 2 Partite", "desc": "Avvia e gioca 2 partite della campagna", "stat": "quest_runs", "target_amt": 2, "max": 2, "reward_type": "gems", "reward_amt": 20},
	{"id": "d3", "category": "DAILY", "title": "💎 Potenzia 1 Talento", "desc": "Potenzia un talento permanente nel menu", "stat": "quest_talents", "target_amt": 1, "max": 1, "reward_type": "coins", "reward_amt": 300},
	{"id": "d4", "category": "DAILY", "title": "🎬 Guarda 1 Video Promo", "desc": "Guarda un video nel negozio gemme", "stat": "daily_ads_watched", "target_amt": 1, "max": 1, "reward_type": "gems", "reward_amt": 15}
]

const WEEKLY_QUESTS := [
	{"id": "w1", "category": "WEEKLY", "title": "⚔️ Sconfiggi 200 Nemici", "desc": "Elimina un totale di 200 nemici", "stat": "quest_kills", "target_amt": 200, "max": 200, "reward_type": "coins", "reward_amt": 1000},
	{"id": "w2", "category": "WEEKLY", "title": "👾 Gioca 5 Partite", "desc": "Completa 5 run della campagna", "stat": "quest_runs", "target_amt": 5, "max": 5, "reward_type": "gems", "reward_amt": 100},
	{"id": "w3", "category": "WEEKLY", "title": "🛡️ Potenzia 5 Talenti", "desc": "Acquista 5 potenziamenti di talento", "stat": "quest_talents", "target_amt": 5, "max": 5, "reward_type": "gems", "reward_amt": 50}
]

const MONTHLY_QUESTS := [
	{"id": "m1", "category": "MONTHLY", "title": "💀 Sconfiggi 1000 Nemici", "desc": "Sconfiggi 1000 nemici in totale", "stat": "quest_kills", "target_amt": 1000, "max": 1000, "reward_type": "gems", "reward_amt": 250},
	{"id": "m2", "category": "MONTHLY", "title": "🏆 Completa 10 Partite", "desc": "Avvia ed affronta 10 partite", "stat": "quest_runs", "target_amt": 10, "max": 10, "reward_type": "coins", "reward_amt": 5000},
	{"id": "m3", "category": "MONTHLY", "title": "📅 Accesso per 7 giorni", "desc": "Effettua il check-in per 7 giorni", "stat": "checkin_day", "target_amt": 7, "max": 7, "reward_type": "gems", "reward_amt": 300}
]

func claim_daily_reward() -> Dictionary:
	if Global.checkin_claimed:
		return {"success": false, "message": "Ricompensa già riscattata oggi!"}

	var current_day_idx: int = (Global.checkin_day - 1) % 7
	var reward: Dictionary = CHECKIN_REWARDS[current_day_idx]

	if reward["type"] == "coins":
		Global.total_coins += int(reward["amount"])
	elif reward["type"] == "gems":
		Global.total_credits += int(reward["amount"])
	elif reward["type"] == "key":
		Global.total_credits += 150

	Global.checkin_claimed = true
	Global.checkin_day = (Global.checkin_day % 7) + 1
	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()

	return {"success": true, "reward": reward, "message": "Riscatto effettuato: " + str(reward["label"])}
