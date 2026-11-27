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

	# --- BALISTICA: pattern di fuoco (testi corti e immediati stile Archero!) ---
	_add("front_arrow", "MULTISHOT", "+1 Colpo Frontale", "BALISTICA", "RARE", 3)
	_add("twin_shot", "DOPPIO COLPO", "2 Colpi Paralleli", "BALISTICA", "RARE", 2)
	_add("diagonal_arrow", "DIAGONALI", "+2 Colpi a ±45°", "BALISTICA", "RARE", 1)
	_add("spread_shot", "VENTAGLIO", "+2 Colpi a ±18°", "BALISTICA", "COMMON", 1)
	_add("rear_arrow", "RETRO-FUOCO", "+1 Colpo Dietro", "BALISTICA", "COMMON", 1)
	_add("side_arrows", "LATERALI", "+2 Colpi ai Fianchi", "BALISTICA", "COMMON", 1)
	_add("bouncy_wall", "RIMBALZO MURI", "2 Rimbalzi su Pareti", "BALISTICA", "COMMON", 1)
	_add("ricochet", "RICOCHET", "Rimbalza tra i Nemici", "BALISTICA", "EPIC", 2)
	_add("piercing", "PERFORANTE", "Trapassa i Nemici", "BALISTICA", "EPIC", 1)
	_add("homing_rounds", "RICERCA SMART", "Colpi Autoguidati", "BALISTICA", "EPIC", 1)
	_add("giant_shots", "MAXI CALIBRO", "Colpi +25% • +4 ATK", "BALISTICA", "COMMON", 2)
	_add("burst_volley", "RAFFICA X3", "Ogni 4° Colpo: Salva x3", "BALISTICA", "EPIC", 2)

	# --- POTENZA ---
	_add("attack_speed", "CADENZA +", "Velocità Sparo +20%", "POTENZA", "COMMON", 4)
	_add("damage_up", "DANNO +", "+8 Danno Base", "POTENZA", "COMMON", 5)
	_add("crit_up", "CRITICO +", "+12% Prob. Critico", "POTENZA", "RARE", 3)
	_add("sniper_caliber", "CECCHINO", "+6 ATK • +15% Danno Crit", "POTENZA", "RARE", 3)
	_add("executioner", "ESECUTORE", "+45% Danno sotto 40% HP", "POTENZA", "EPIC", 2)
	_add("berserker", "FURIA", "Più Danno a Vita Bassa", "POTENZA", "RARE", 2)
	_add("lucky_overdrive", "FORTUNA", "+10% Crit • +8% Schivata", "POTENZA", "RARE", 2)

	# --- ELEMENTALI / EFFETTI AL COLPO ---
	_add("explosive", "ESPLOSIVO", "Colpi con Danno ad Area", "ELEMENTALE", "EPIC", 2)
	_add("chain_lightning", "FULMINE", "Folgora 2 Nemici Vicini", "ELEMENTALE", "EPIC", 2)
	_add("freeze_shot", "CRIOGENIA", "Rallenta Nemici -45%", "ELEMENTALE", "RARE", 1)
	_add("burn_shot", "INCENDIARIO", "Brucia i Nemici nel Tempo", "ELEMENTALE", "RARE", 2)
	_add("static_field", "AURA TESLA", "Scariche Automatiche Vicini", "ELEMENTALE", "EPIC", 3)
	_add("plasma_trail", "SCIA PLASMA", "Scia Dannosa Mentre Corri", "ELEMENTALE", "RARE", 2)

	# --- SUPPORTO / DIFESA ---
	_add("orbit_blades", "LAME ORBITALI", "Lame Rotanti Attorno a Te", "SUPPORTO", "LEGENDARY", 3)
	_add("shoulder_missiles", "MICRO-MISSILI", "2 Missili Smart ogni 2,8s", "SUPPORTO", "LEGENDARY", 3)
	_add("shockwave_nova", "ONDA D'URTO", "Esplosione Difensiva Nova", "SUPPORTO", "EPIC", 2)
	_add("energy_shield", "SCUDO AEGIS", "Blocca 1 Colpo (Ricarica 7s)", "DIFESA", "EPIC", 2)
	_add("vampire", "VAMPIRISMO", "25% Cura a Ogni Colpo", "DIFESA", "RARE", 3)
	_add("dodge", "SCHIVATA +", "+12% Schivata Colpi", "DIFESA", "RARE", 3)
	_add("regen", "RIGENERA HP", "Cura Automatica ogni 3s", "DIFESA", "COMMON", 3)
	_add("max_hp_up", "VITA MAX +", "+30 HP Massimi Subito", "DIFESA", "COMMON", 4)
	_add("titan_heart", "CUORE TITANIO", "+60 HP • -12% Danni Subiti", "DIFESA", "EPIC", 2)
	_add("move_speed", "VELOCITÀ +", "+10% Velocità Corsa", "DIFESA", "COMMON", 3)
	_add("heal", "CURA SUBITO", "Ripristina +35% HP Ora", "DIFESA", "COMMON", 99)

	print("PerkDB inizializzato con ", available_perks.size(), " potenziamenti!")

func get_perk(perk_id: String) -> PerkData:
	for p in available_perks:
		if p.id == perk_id:
			return p
	return null

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
				w *= 0.55
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
