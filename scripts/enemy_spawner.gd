extends Node

@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var ranged_enemy_scene: PackedScene = preload("res://scenes/RangedEnemy.tscn")
@export var heavy_enemy_scene: PackedScene = preload("res://scenes/HeavyEnemy.tscn")
@export var special_enemy_scene: PackedScene = preload("res://scenes/SpecialEnemy.tscn")
@export var boss_scene: PackedScene = preload("res://scenes/BossEnemy.tscn")
@export var door_scene: PackedScene = preload("res://scenes/Door.tscn")
@export var obstacle_scene: PackedScene = preload("res://scenes/Obstacle.tscn")
@export var loot_crate_scene: PackedScene = preload("res://scenes/LootCrate.tscn")
@export var trap_scene: PackedScene = preload("res://scenes/Trap.tscn")

var current_room: int = 1
var room_cleared: bool = false
var sanctuary_pending: bool = false
var current_world: WorldData
var total_room_enemies: int = 0
var spawn_grace_frames: int = 2

func _spawn_into_arena(node: Node) -> void:
	var target: Node = get_parent() if get_parent() != null else get_tree().current_scene
	if target:
		target.add_child.call_deferred(node)

func _ready() -> void:
	add_to_group("spawner")
	Global.run_coins = 0
	Global.run_scrolls = 0
	current_world = WorldDB.get_selected_world()
	print("Caricato ", current_world.display_name, " | Stanze Totali: ", current_world.total_rooms, " | Trappola: ", current_world.trap_type)
	start_room()

func _pick_world_enemy_spec(room: int, idx: int) -> Dictionary:
	var wid: String = current_world.id if current_world else "world_1"
	var roll := randf()

	# Tutorial Mondo 1: introduzione progressiva chiara dei diversi tipi di nemici!
	if wid == "world_1":
		if room == 1:
			return {"scene": enemy_scene, "arch": ""}
		elif room == 2:
			return {"scene": ranged_enemy_scene if idx < 2 else enemy_scene, "arch": ""}
		elif room == 3:
			if idx == 0:
				return {"scene": heavy_enemy_scene, "arch": ""}
			return {"scene": ranged_enemy_scene if idx == 1 else enemy_scene, "arch": ""}
		elif room == 4:
			if idx == 0:
				return {"scene": special_enemy_scene, "arch": "SPITTER"}
			return {"scene": ranged_enemy_scene if roll < 0.45 else enemy_scene, "arch": ""}
		else:
			if roll < 0.20:
				return {"scene": special_enemy_scene, "arch": "SPITTER"}
			elif roll < 0.36:
				return {"scene": special_enemy_scene, "arch": "KAMIKAZE"}
			elif roll < 0.54:
				return {"scene": heavy_enemy_scene, "arch": ""}
			elif roll < 0.78:
				return {"scene": ranged_enemy_scene, "arch": ""}
			return {"scene": enemy_scene, "arch": ""}

	# Ecosistemi specifici per ciascuno dei Mondi 2..8 (7 Archetipi combinati per identità bioma!)
	match wid:
		"world_2": # Deserto: Kamikaze Ticker + Spitter + Mantis + Goliath
			if roll < 0.28: return {"scene": special_enemy_scene, "arch": "KAMIKAZE"}
			elif roll < 0.46: return {"scene": special_enemy_scene, "arch": "SPITTER"}
			elif roll < 0.64: return {"scene": heavy_enemy_scene, "arch": ""}
			elif roll < 0.80: return {"scene": ranged_enemy_scene, "arch": ""}
			else: return {"scene": enemy_scene, "arch": ""}
		"world_3": # Stazione Arasaka: Scudieri Aegis + Assassini Cyber-Wraith + Droni
			if roll < 0.28: return {"scene": special_enemy_scene, "arch": "SHIELDER"}
			elif roll < 0.54: return {"scene": special_enemy_scene, "arch": "ASSASSIN"}
			elif roll < 0.80: return {"scene": ranged_enemy_scene, "arch": ""}
			else: return {"scene": heavy_enemy_scene, "arch": ""}
		"world_4": # Lab Criogenico: Spitter Crio + Scudieri Aegis + Droni + Mantis
			if roll < 0.30: return {"scene": special_enemy_scene, "arch": "SPITTER"}
			elif roll < 0.52: return {"scene": special_enemy_scene, "arch": "SHIELDER"}
			elif roll < 0.76: return {"scene": ranged_enemy_scene, "arch": ""}
			else: return {"scene": enemy_scene, "arch": ""}
		"world_5": # Fonderia Magmatica: Kamikaze Esplosivi + Goliath Mech + Scudieri
			if roll < 0.32: return {"scene": special_enemy_scene, "arch": "KAMIKAZE"}
			elif roll < 0.60: return {"scene": heavy_enemy_scene, "arch": ""}
			elif roll < 0.80: return {"scene": special_enemy_scene, "arch": "SHIELDER"}
			else: return {"scene": enemy_scene, "arch": ""}
		"world_6": # Raffineria Bio-Tossica: Spitter Acidi + Kamikaze + Assassini Wraith
			if roll < 0.32: return {"scene": special_enemy_scene, "arch": "SPITTER"}
			elif roll < 0.56: return {"scene": special_enemy_scene, "arch": "KAMIKAZE"}
			elif roll < 0.78: return {"scene": special_enemy_scene, "arch": "ASSASSIN"}
			else: return {"scene": enemy_scene, "arch": ""}
		"world_7": # Hangar Orbitale: Assassini Wraith + Scudieri Aegis + Droni + Goliath
			if roll < 0.30: return {"scene": special_enemy_scene, "arch": "ASSASSIN"}
			elif roll < 0.56: return {"scene": special_enemy_scene, "arch": "SHIELDER"}
			elif roll < 0.78: return {"scene": ranged_enemy_scene, "arch": ""}
			else: return {"scene": heavy_enemy_scene, "arch": ""}
		"world_8": # Vicolo Kabuki: Sicari Cyber-Wraith + Kamikaze + Lame Mantis
			if roll < 0.36: return {"scene": special_enemy_scene, "arch": "ASSASSIN"}
			elif roll < 0.60: return {"scene": special_enemy_scene, "arch": "KAMIKAZE"}
			elif roll < 0.80: return {"scene": ranged_enemy_scene, "arch": ""}
			else: return {"scene": enemy_scene, "arch": ""}
		"world_9": # Bastione Militech: Falangi Aegis + Mech Goliath + Tiratori Scelti
			if roll < 0.32: return {"scene": special_enemy_scene, "arch": "SHIELDER"}
			elif roll < 0.60: return {"scene": heavy_enemy_scene, "arch": ""}
			elif roll < 0.84: return {"scene": ranged_enemy_scene, "arch": ""}
			else: return {"scene": special_enemy_scene, "arch": "KAMIKAZE"}
		"world_10": # Reattore Abissale: Torrette Crio-Spitter + Aegis + Goliath
			if roll < 0.34: return {"scene": special_enemy_scene, "arch": "SPITTER"}
			elif roll < 0.58: return {"scene": special_enemy_scene, "arch": "SHIELDER"}
			elif roll < 0.80: return {"scene": heavy_enemy_scene, "arch": ""}
			else: return {"scene": ranged_enemy_scene, "arch": ""}
		"world_11": # Cupola Selene: Wraith Lunari + Droni Orbitali + Aegis
			if roll < 0.34: return {"scene": special_enemy_scene, "arch": "ASSASSIN"}
			elif roll < 0.60: return {"scene": ranged_enemy_scene, "arch": ""}
			elif roll < 0.82: return {"scene": special_enemy_scene, "arch": "SHIELDER"}
			else: return {"scene": special_enemy_scene, "arch": "SPITTER"}
		_: # Mondo 12 Nucleo A.R.G.O.N.: Tutti i 7 archetipi d'élite al completo!
			if roll < 0.18: return {"scene": special_enemy_scene, "arch": "SHIELDER"}
			elif roll < 0.36: return {"scene": special_enemy_scene, "arch": "ASSASSIN"}
			elif roll < 0.52: return {"scene": special_enemy_scene, "arch": "KAMIKAZE"}
			elif roll < 0.68: return {"scene": special_enemy_scene, "arch": "SPITTER"}
			elif roll < 0.82: return {"scene": heavy_enemy_scene, "arch": ""}
			elif roll < 0.92: return {"scene": ranged_enemy_scene, "arch": ""}
			else: return {"scene": enemy_scene, "arch": ""}

func start_room() -> void:
	room_cleared = false
	sanctuary_pending = false
	spawn_grace_frames = 2
	if current_world and Global.has_method("record_world_progress"):
		# Ogni stanza superata registra il progresso per i Premi Intermedi a Soglie!
		var cleared_so_far: int = maxi(0, current_room - 1)
		if cleared_so_far > 0:
			Global.record_world_progress(current_world.id, cleared_so_far)
	print("Avvio Stanza ", current_room, "/", current_world.total_rooms, " in ", current_world.display_name)

	# 1. Stanza del Boss (Ogni 10 Livelli e all'Ultimo Livello del Mondo)
	var w_idx_cur: int = maxi(1, WorldDB.world_order.find(current_world.id) + 1) if current_world else 1
	var p_nodes_ref := get_tree().get_nodes_in_group("player")
	var player_atk_cur: int = 18
	var player_hp_cur: int = 120
	if not p_nodes_ref.is_empty():
		var pl_ref: Node = p_nodes_ref[0]
		if "weapon_base_damage" in pl_ref and "bonus_damage" in pl_ref:
			player_atk_cur = maxi(16, int(pl_ref.weapon_base_damage) + int(pl_ref.bonus_damage))
		if "max_hp" in pl_ref:
			player_hp_cur = maxi(100, int(pl_ref.max_hp))

	var is_boss_stage: bool = (current_room == current_world.total_rooms) or (current_room % 10 == 0)
	if is_boss_stage:
		total_room_enemies = 1
		var is_final: bool = (current_room == current_world.total_rooms)
		if boss_scene:
			var boss := boss_scene.instantiate() as Node2D
			if boss:
				boss.global_position = Vector2(360, 360)
				if "is_final_boss" in boss:
					boss.is_final_boss = is_final
				var progress_ratio: float = clampf(float(current_room) / float(maxi(1, current_world.total_rooms)), 0.76, 1.0)
				var boss_stage_bonus: float = 1.0 + float(maxi(0, current_room - 10)) * 0.025
				var base_boss_hp: float = 3000.0 if is_final else 2000.0
				var calc_hp: int = int(round(base_boss_hp * current_world.enemy_hp_multiplier * progress_ratio * boss_stage_bonus))
				# Adattamento anti-oneshot rispetto all'ATK attuale dell'eroe: ogni Boss richiede sempre un vero scontro!
				var min_hits: int = 65 if is_final else 44
				calc_hp = maxi(calc_hp, player_atk_cur * min_hits)
				if "hp" in boss:
					boss.hp = calc_hp
				if "max_hp" in boss:
					boss.max_hp = calc_hp
				if "speed" in boss:
					boss.speed = float(boss.speed) * minf(1.48, 1.05 + float(current_room) * 0.009)
				_spawn_into_arena(boss)
		_update_hud_counter()
		return

	# 2. Stanza Santuario / Cyber-Valchiria (Ogni 5 Livelli nel mezzo: 5, 15, 25, 35, 45)
	var is_sanctuary_stage: bool = (current_room % 10 == 5) and (current_room < current_world.total_rooms)
	if is_sanctuary_stage:
		total_room_enemies = 0
		sanctuary_pending = true
		room_cleared = false
		var sanct_script := load("res://scripts/sanctuary_node.gd")
		if sanct_script:
			var sanct: Node2D = sanct_script.new()
			sanct.global_position = Vector2(360, 560)
			_spawn_into_arena(sanct)
		_update_hud_counter()
		return

	var is_tutorial_world: bool = (current_world.id == "world_1")
	var chosen_obstacles: Array[Vector2] = []
	if obstacle_scene:
		var obstacle_positions: Array[Vector2] = [
			Vector2(175, 360), Vector2(545, 360),
			Vector2(155, 650), Vector2(565, 650),
			Vector2(175, 900), Vector2(545, 900)
		]
		if is_tutorial_world and current_room == 1:
			chosen_obstacles = [Vector2(175, 520), Vector2(545, 520)]
		elif is_tutorial_world and current_room == 2:
			chosen_obstacles = [Vector2(210, 480), Vector2(510, 480)]
		else:
			obstacle_positions.shuffle()
			var count: int = randi_range(3, 4)
			for i in range(count):
				chosen_obstacles.append(obstacle_positions[i])

		for pos in chosen_obstacles:
			var obstacle := obstacle_scene.instantiate() as Node2D
			if obstacle:
				obstacle.global_position = pos
				_spawn_into_arena(obstacle)

	if trap_scene and (not is_tutorial_world or current_room >= 3):
		var trap_positions := [Vector2(230, 500), Vector2(490, 500), Vector2(360, 820)]
		var trap_count: int = 2 if (is_tutorial_world and current_room == 3) else randi_range(1, 2)
		for i in range(trap_count):
			var trap := trap_scene.instantiate() as Node2D
			if trap:
				trap.global_position = trap_positions[i]
				if "trap_type" in trap:
					trap.trap_type = current_world.trap_type
				if "damage" in trap:
					trap.damage = 10.0 * current_world.enemy_dmg_multiplier
				_spawn_into_arena(trap)

	if loot_crate_scene and (not is_tutorial_world or current_room >= 2):
		var crate_pos := Vector2(360, 285) if (is_tutorial_world and current_room == 2) else Vector2(randf_range(260, 460), 280)
		var crate := loot_crate_scene.instantiate() as Node2D
		if crate:
			crate.global_position = crate_pos
			_spawn_into_arena(crate)

	# Progressione tattica intensa (con pressione adattiva morbida se il giocatore ha già equipaggiamento fuori scala!)
	total_room_enemies = 3 if (is_tutorial_world and current_room == 1) else clampi(4 + int(floor(float(current_room) * 0.45)) + int(w_idx_cur / 3), 4, 13)
	var r_step: float = float(maxi(0, current_room - 1))
	var room_hp_scale: float = 1.0 + r_step * 0.075 + pow(r_step, 1.24) * 0.014
	var room_dmg_scale: float = 1.0 + r_step * 0.052 + pow(r_step, 1.14) * 0.009
	var room_spd_scale: float = minf(1.48, 1.0 + float(w_idx_cur - 1) * 0.025 + r_step * 0.012)
	var elite_chance: float = clampf(0.16 + float(current_room - 3) * 0.018 + float(w_idx_cur - 1) * 0.02, 0.16, 0.46) if (current_room >= 3 or w_idx_cur >= 3) else 0.0
	var max_elites: int = 1 if (current_room < 7 and w_idx_cur < 3) else (2 if current_room < 16 else 4)
	var elites_spawned: int = 0

	# Se il giocatore entra con ATK molto superiore alla baseline del settore (es. armi Leggendarie/Epiche già potenziate),
	# i nemici assorbono parzialmente il surplus così i combattimenti richiedono sempre più colpi e movimento tattico!
	var expected_sector_atk: float = 18.0 * pow(1.36, float(w_idx_cur - 1))
	var overgear_hp_mult: float = 1.0
	if float(player_atk_cur) > expected_sector_atk * 1.25:
		overgear_hp_mult = pow(float(player_atk_cur) / (expected_sector_atk * 1.25), 0.72)

	for i in range(total_room_enemies):
		var spawn_pos := _get_safe_spawn_pos(chosen_obstacles)
		var spec: Dictionary = _pick_world_enemy_spec(current_room, i)
		var scene_to_spawn: PackedScene = spec.get("scene", enemy_scene) as PackedScene
		var arch_id: String = str(spec.get("arch", ""))

		if scene_to_spawn:
			var enemy := scene_to_spawn.instantiate() as Node2D
			if enemy:
				enemy.global_position = spawn_pos
				if not arch_id.is_empty() and "archetype" in enemy:
					enemy.archetype = arch_id
				var make_elite: bool = (elites_spawned < max_elites) and (randf() < elite_chance)
				if make_elite:
					elites_spawned += 1
					if "is_elite" in enemy:
						enemy.is_elite = true
					enemy.scale *= 1.16
				var e_hp_mult: float = room_hp_scale * overgear_hp_mult * (1.85 if make_elite else 1.0)
				var e_dmg_mult: float = room_dmg_scale * (1.35 if make_elite else 1.0)
				var e_spd_mult: float = room_spd_scale * (1.14 if make_elite else 1.0)
				if "hp" in enemy:
					var scaled_hp: int = int(round(float(enemy.hp) * current_world.enemy_hp_multiplier * e_hp_mult))
					var min_mob_hits: int = (6 if make_elite else 3) if w_idx_cur >= 3 else (4 if make_elite else 2)
					enemy.hp = maxi(scaled_hp, player_atk_cur * min_mob_hits)
				if "max_hp" in enemy and "hp" in enemy:
					enemy.max_hp = enemy.hp
				if "damage" in enemy:
					var scaled_dmg: int = int(round(float(enemy.damage) * current_world.enemy_dmg_multiplier * e_dmg_mult))
					if w_idx_cur >= 3:
						var min_threat_dmg: int = int(round(float(player_hp_cur) * (0.085 + float(w_idx_cur - 3) * 0.012) * (1.25 if make_elite else 1.0)))
						scaled_dmg = maxi(scaled_dmg, min_threat_dmg)
					enemy.damage = scaled_dmg
				if "speed" in enemy:
					enemy.speed = float(enemy.speed) * e_spd_mult
				if "fire_rate" in enemy:
					enemy.fire_rate = maxf(0.75, float(enemy.fire_rate) / (1.0 + float(w_idx_cur - 1) * 0.06 + r_step * 0.016))
				_spawn_into_arena(enemy)

	_update_hud_counter()

func _get_safe_spawn_pos(obstacles: Array[Vector2]) -> Vector2:
	# Garantisce sempre distanza sicura sia dagli ostacoli sia dalla posizione iniziale dell'eroe (360, 1100)
	for _attempt in range(18):
		var candidate := Vector2(randf_range(105.0, 615.0), randf_range(210.0, 760.0))
		var safe := candidate.distance_to(Vector2(360.0, 1100.0)) >= 270.0
		if safe:
			for obs_pos in obstacles:
				if candidate.distance_to(obs_pos) < 78.0:
					safe = false
					break
		if safe:
			return candidate
	return Vector2(360.0 + randf_range(-110.0, 110.0), randf_range(240.0, 560.0))

func _process(_delta: float) -> void:
	if spawn_grace_frames > 0:
		spawn_grace_frames -= 1
		return

	var remaining_enemies := get_tree().get_nodes_in_group("enemies").size()
	_update_hud_counter()

	if not sanctuary_pending and not room_cleared and remaining_enemies == 0:
		room_cleared = true
		_clear_all_projectiles()
		_vacuum_room_xp()
		spawn_door()

func complete_sanctuary() -> void:
	if not sanctuary_pending:
		return
	sanctuary_pending = false
	if not room_cleared:
		room_cleared = true
		spawn_door()
	_update_hud_counter()

func _clear_all_projectiles() -> void:
	var vfx: Node = get_node_or_null("/root/VFXManager")
	for proj in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(proj):
			if proj is Node2D and vfx and vfx.has_method("spawn_burst"):
				vfx.spawn_burst((proj as Node2D).global_position, Color(0.0, 0.95, 1.0, 0.7))
			proj.queue_free()

func _vacuum_room_xp() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty() or not (players[0] is Node2D): return
	var player := players[0] as Node2D

	var drops := get_tree().get_nodes_in_group("drops")
	for drop in drops:
		if drop.has_method("magnetize_to_player"):
			drop.magnetize_to_player(player)

func _update_hud_counter() -> void:
	var remaining := get_tree().get_nodes_in_group("enemies").size()
	if remaining > total_room_enemies:
		total_room_enemies = remaining
	var is_boss_st: bool = (current_room == current_world.total_rooms) or (current_room % 10 == 0)
	var is_sanct_st: bool = (current_room % 10 == 5) and (current_room < current_world.total_rooms)
	var huds := get_tree().get_nodes_in_group("hud")
	for h in huds:
		if h.has_method("update_room_status"):
			h.update_room_status(current_room, current_world.total_rooms, remaining, total_room_enemies, is_boss_st, is_sanct_st and sanctuary_pending)
		elif "room_label" in h and h.room_label:
			if is_sanct_st and sanctuary_pending:
				h.room_label.text = "STAGE " + str(current_room) + "/" + str(current_world.total_rooms) + "  •  ✦ SANTUARIO VALCHIRIA"
			elif remaining > 0:
				var tag := "★ SCONTRO BOSS" if is_boss_st else ("OSTILI: " + str(remaining) + "/" + str(total_room_enemies))
				h.room_label.text = "STAGE " + str(current_room) + "/" + str(current_world.total_rooms) + "  •  " + tag
			else:
				h.room_label.text = "STAGE " + str(current_room) + "/" + str(current_world.total_rooms) + "  •  ▶ PORTALE APERTO"

func spawn_door() -> void:
	if door_scene:
		var door := door_scene.instantiate() as Node2D
		if door:
			door.global_position = Vector2(360, 118)
			_spawn_into_arena(door)

func next_room() -> void:
	for obs in get_tree().get_nodes_in_group("obstacles"):
		if obs is Node and not obs.is_in_group("walls"):
			obs.queue_free()

	for trap in get_tree().get_nodes_in_group("traps"):
		if trap is Node:
			trap.queue_free()

	for proj in get_tree().get_nodes_in_group("projectiles"):
		if proj is Node:
			proj.queue_free()

	current_room += 1

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is Node2D:
		var player := players[0] as Node2D
		player.global_position = Vector2(360, 1100)
		if "invulnerable_time" in player:
			player.invulnerable_time = maxf(float(player.invulnerable_time), 0.65)
		if player.has_method("clear_env_slow"):
			player.clear_env_slow()

		var tm: Node = get_node_or_null("/root/TalentManager")
		if tm and tm.has_method("get_bonus_value"):
			var rec_pct: float = tm.get_bonus_value("recovery")
			if rec_pct > 0.0 and "current_hp" in player and "max_hp" in player:
				var heal_amt: int = int(float(player.max_hp) * (rec_pct / 100.0))
				player.current_hp = min(player.max_hp, player.current_hp + heal_amt)
				if player.has_signal("hp_changed"): player.hp_changed.emit(player.current_hp, player.max_hp)

	start_room()
