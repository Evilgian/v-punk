extends Node

var available_perks: Array[PerkData] = []
## Abilità proposte nell'ultima scelta: evitate nella successiva per non vedere sempre le stesse
var last_offer_ids: Array[String] = []

const RARITY_WEIGHT := {"COMMON": 10.0, "RARE": 6.5, "EPIC": 3.5, "LEGENDARY": 1.6}

func _ready() -> void:
	_init_perks()

func _add(id: String, display_name: String, desc: String, perk_type: String, rarity: String, max_stacks: int) -> void:
	var p := PerkData.new()
	p.id = id
	p.display_name = display_name
	p.description = desc
	p.perk_type = perk_type
	p.rarity = rarity
	p.max_stacks = max_stacks
	available_perks.append(p)

func _init_perks() -> void:
	available_perks.clear()

	# --- BALISTICA: pattern di fuoco ---
	_add("front_arrow", "🎯 Multishot", "+1 proiettile frontale a ventaglio stretto.", "BALISTICA", "RARE", 3)
	_add("twin_shot", "🔫 Doppio Colpo Parallelo", "Spara 2 colpi paralleli ravvicinati in avanti.", "BALISTICA", "RARE", 2)
	_add("diagonal_arrow", "🏹 Sparo Diagonale", "2 proiettili extra a ±45°.", "BALISTICA", "RARE", 1)
	_add("spread_shot", "🔱 Ventaglio Cyber", "2 proiettili extra a ±18°.", "BALISTICA", "COMMON", 1)
	_add("rear_arrow", "↩️ Colpo alle Spalle", "Spara anche un proiettile all'indietro.", "BALISTICA", "COMMON", 1)
	_add("side_arrows", "↔️ Fuoco Laterale", "2 proiettili extra a 90° ai fianchi.", "BALISTICA", "COMMON", 1)
	_add("bouncy_wall", "🧱 Rimbalzo Pareti", "I proiettili rimbalzano 2 volte su muri e coperture.", "BALISTICA", "COMMON", 1)
	_add("ricochet", "🪃 Rimbalzo a Catena", "I proiettili rimbalzano automaticamente verso un altro nemico vicino!", "BALISTICA", "EPIC", 2)
	_add("piercing", "⚡ Colpo Perforante", "I proiettili trapassano tutti i nemici.", "BALISTICA", "EPIC", 1)
	_add("homing_rounds", "🛰️ Munizioni Smart", "I proiettili inseguono il nemico più vicino.", "BALISTICA", "EPIC", 1)
	_add("giant_shots", "🔵 Proiettili Titanici", "Proiettili più grandi del 25% e +4 danno.", "BALISTICA", "COMMON", 2)
	_add("burst_volley", "☄️ Raffica Sequenziale", "Ogni 4° attacco spara una raffica tripla ultra-rapida!", "BALISTICA", "EPIC", 2)

	# --- POTENZA ---
	_add("attack_speed", "🔥 Overclock Cadenza", "Cadenza di fuoco +20%.", "POTENZA", "COMMON", 4)
	_add("damage_up", "💥 Sovraccarico Plasma", "+8 danno a ogni colpo.", "POTENZA", "COMMON", 5)
	_add("crit_up", "🎲 Bersaglio Critico", "+12% probabilità di colpo critico (danno x2).", "POTENZA", "RARE", 3)
	_add("sniper_caliber", "🔭 Calibro Antimateria", "Velocità proiettili +35%, +6 danno e +15% danno critico.", "POTENZA", "RARE", 3)
	_add("executioner", "💀 Protocollo Esecutore", "Infligge +45% danni ai nemici e Boss sotto il 40% di HP!", "POTENZA", "EPIC", 2)
	_add("berserker", "💢 Furia Cibernetica", "Più bassi sono i tuoi HP, più aumentano Danno e Cadenza (fino a +50%).", "POTENZA", "RARE", 2)
	_add("lucky_overdrive", "🍀 Fortuna Quantistica", "+10% Critico, +8% Schivata e +25% Monete trovate.", "POTENZA", "RARE", 2)

	# --- ELEMENTALI / EFFETTI AL COLPO ---
	_add("explosive", "💣 Testate Esplosive", "I colpi esplodono e danneggiano i nemici vicini.", "ELEMENTALE", "EPIC", 2)
	_add("chain_lightning", "🌩️ Fulmine a Catena", "Ogni colpo folgora 2 nemici vicini (35% danno).", "ELEMENTALE", "EPIC", 2)
	_add("freeze_shot", "❄️ Criogenia", "I colpi rallentano i nemici del 45% per 1,5 s.", "ELEMENTALE", "RARE", 1)
	_add("burn_shot", "🔥 Napalm Neon", "I colpi incendiano: 3 danni bruciatura extra nel tempo.", "ELEMENTALE", "RARE", 2)
	_add("static_field", "⚡ Campo Elettrostatico", "Emette scariche elettriche automatiche sui nemici vicini ogni 1,2 s.", "ELEMENTALE", "EPIC", 3)
	_add("plasma_trail", "☣️ Scia al Plasma", "Mentre corri rilasci impulsi energetici che danneggiano gli inseguitori.", "ELEMENTALE", "RARE", 2)

	# --- SUPPORTO / DIFESA ---
	_add("orbit_blades", "🌀 Lame Orbitali", "Una lama al plasma ruota attorno a te e trancia i nemici.", "SUPPORTO", "LEGENDARY", 3)
	_add("shoulder_missiles", "🚀 Lanciamissili Spalla", "Ogni 2,8 s lancia 2 micro-missili a ricerca verso i nemici!", "SUPPORTO", "LEGENDARY", 3)
	_add("shockwave_nova", "🌊 Supernova Difensiva", "Se vieni colpito (o ogni 9 s) sprigiona un'onda d'urto che spazza i nemici.", "SUPPORTO", "EPIC", 2)
	_add("energy_shield", "🛡️ Scudo Energetico", "Blocca 1 colpo; si ricarica ogni 7 secondi.", "DIFESA", "EPIC", 2)
	_add("vampire", "🩸 Nanobot Vampiri", "25% di probabilità di curarti a ogni colpo a segno.", "DIFESA", "RARE", 3)
	_add("dodge", "💨 Riflessi Sintetici", "+12% probabilità di schivare i danni.", "DIFESA", "RARE", 3)
	_add("regen", "💚 Rigenerazione", "Recuperi HP automaticamente ogni 3 secondi.", "DIFESA", "COMMON", 3)
	_add("max_hp_up", "❤️ Telaio Rinforzato", "+30 HP massimi (e curati di 30).", "DIFESA", "COMMON", 4)
	_add("titan_heart", "💎 Cuore di Titanio", "+60 HP massimi immediati e riduzione danni subiti del 12%.", "DIFESA", "EPIC", 2)
	_add("move_speed", "👟 Servo-Gambe", "Velocità di movimento +10%.", "DIFESA", "COMMON", 3)
	_add("heal", "➕ Riparazione Nanobot", "Ripristina subito il 35% degli HP massimi.", "DIFESA", "COMMON", 99)

	print("PerkDB inizializzato con ", available_perks.size(), " potenziamenti!")

func get_perk(perk_id: String) -> PerkData:
	for p in available_perks:
		if p.id == perk_id:
			return p
	return null

## Selezione intelligente e pesata:
## - esclude le abilità già al massimo dei livelli
## - propone la cura solo se gli HP sono sotto l'80%
## - evita le stesse carte appena proposte
## - le abilità già possedute hanno peso minore → più varietà di build
func get_random_perks(count: int = 3, player: Node = null) -> Array[PerkData]:
	var stacks: Dictionary = {}
	var hp_ratio: float = 1.0
	if player:
		if "perk_stacks" in player:
			stacks = player.perk_stacks
		if "current_hp" in player and "max_hp" in player and int(player.max_hp) > 0:
			hp_ratio = float(player.current_hp) / float(player.max_hp)

	var pool: Array[PerkData] = []
	for p in available_perks:
		var owned: int = int(stacks.get(p.id, 0))
		if owned >= p.max_stacks:
			continue
		if p.id == "heal" and hp_ratio > 0.80:
			continue
		pool.append(p)

	# Evita di riproporre le stesse carte della scelta precedente (se ne restano abbastanza)
	var fresh: Array[PerkData] = []
	for p in pool:
		if not last_offer_ids.has(p.id):
			fresh.append(p)
	if fresh.size() >= count:
		pool = fresh

	var result: Array[PerkData] = []
	var used_types: Dictionary = {}
	while result.size() < count and not pool.is_empty():
		var total: float = 0.0
		var weights: Array[float] = []
		for p in pool:
			var w: float = float(RARITY_WEIGHT.get(p.rarity, 5.0))
			w *= pow(0.65, float(stacks.get(p.id, 0)))
			if used_types.has(p.perk_type):
				w *= 0.55 # favorisce categorie diverse nella stessa scelta
			weights.append(w)
			total += w
		var roll: float = randf() * total
		var idx: int = 0
		for i in range(weights.size()):
			roll -= weights[i]
			if roll <= 0.0:
				idx = i
				break
		var chosen: PerkData = pool[idx]
		result.append(chosen)
		used_types[chosen.perk_type] = true
		pool.remove_at(idx)

	last_offer_ids.clear()
	for p in result:
		last_offer_ids.append(p.id)
	return result
