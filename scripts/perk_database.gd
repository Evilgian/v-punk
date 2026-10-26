extends Node

var available_perks: Array[PerkData] = []

func _ready() -> void:
	_init_perks()

func _init_perks() -> void:
	available_perks.clear()

	# 1. Doppio Sparo / Multishot Cumulativo
	var front := PerkData.new()
	front.id = "front_arrow"
	front.display_name = "🎯 Multishot Cumulativo"
	front.description = "Aggiunge +1 proiettile frontale ad arco (Cumulabile)."
	available_perks.append(front)

	# 2. Sparo Diagonale (Diagonal Arrow)
	var diag := PerkData.new()
	diag.id = "diagonal_arrow"
	diag.display_name = "🏹 Sparo Diagonale"
	diag.description = "Spara 2 proiettili aggiuntivi a ±45°."
	available_perks.append(diag)

	# 3. Ventaglio Tattico (Spread Shot)
	var spread := PerkData.new()
	spread.id = "spread_shot"
	spread.display_name = "🔱 Ventaglio Cyber"
	spread.description = "Spara 2 proiettili angolari a ±18°."
	available_perks.append(spread)

	# 4. Rimbalzo Pareti (Bouncy Wall)
	var bounce := PerkData.new()
	bounce.id = "bouncy_wall"
	bounce.display_name = "🧱 Rimbalzo Pareti"
	bounce.description = "I proiettili rimbalzano sulle pareti perimetrali."
	available_perks.append(bounce)

	# 5. Trapasso Energetico (Piercing)
	var pierce := PerkData.new()
	pierce.id = "piercing"
	pierce.display_name = "⚡ Colpo Perforante"
	pierce.description = "I proiettili trapassano i nemici colpendo più bersagli."
	available_perks.append(pierce)

	# 6. Velocità d'Attacco (Attack Speed Up)
	var aspeed := PerkData.new()
	aspeed.id = "attack_speed"
	aspeed.display_name = "🔥 Overclock Cadenza"
	aspeed.description = "Riduce il tempo di ricarica sparo del 20%."
	available_perks.append(aspeed)

	# 7. Sovraccarico Danno (Damage Up)
	var dmg := PerkData.new()
	dmg.id = "damage_up"
	dmg.display_name = "💥 Sovraccarico Plasma"
	dmg.description = "Aumenta il danno base dei colpi di +8."
	available_perks.append(dmg)

	# 8. Cura Istantanea (Heal)
	var heal := PerkData.new()
	heal.id = "heal"
	heal.display_name = "❤️ Riparazione Nanobot"
	heal.description = "Ripristina immediatamente il 35% degli HP massimi."
	available_perks.append(heal)

	print("PerkDB inizializzato con ", available_perks.size(), " potenziamenti Archero!")

func get_random_perks(count: int = 3) -> Array[PerkData]:
	var shuffled := available_perks.duplicate()
	shuffled.shuffle()
	var result: Array[PerkData] = []
	for i in range(min(count, shuffled.size())):
		result.append(shuffled[i])
	return result
