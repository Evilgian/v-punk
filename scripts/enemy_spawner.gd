extends Node

@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var ranged_enemy_scene: PackedScene = preload("res://scenes/RangedEnemy.tscn")
@export var heavy_enemy_scene: PackedScene = preload("res://scenes/HeavyEnemy.tscn")
@export var boss_scene: PackedScene = preload("res://scenes/BossEnemy.tscn")
@export var door_scene: PackedScene = preload("res://scenes/Door.tscn")
@export var obstacle_scene: PackedScene = preload("res://scenes/Obstacle.tscn")
@export var loot_crate_scene: PackedScene = preload("res://scenes/LootCrate.tscn")
@export var trap_scene: PackedScene = preload("res://scenes/Trap.tscn")

var current_room: int = 1
var room_cleared: bool = false
var current_world: WorldData
var total_room_enemies: int = 0

func _ready() -> void:
	add_to_group("spawner")
	current_world = WorldDB.get_selected_world()
	print("🌍 Caricato ", current_world.display_name, " | Stanze Totali: ", current_world.total_rooms, " | Trappola: ", current_world.trap_type)
	start_room()

func start_room() -> void:
	room_cleared = false
	print("🏁 Avvio Stanza ", current_room, "/", current_world.total_rooms, " in ", current_world.display_name)

	# 1. Stanza del Boss (Ogni 10 Livelli: 10, 20, 30, 40, 50 e sempre all'Ultimo Livello del Mondo)
	var is_boss_stage: bool = (current_room == current_world.total_rooms) or (current_room % 10 == 0)
	if is_boss_stage:
		total_room_enemies = 1
		var is_final: bool = (current_room == current_world.total_rooms)
		print("⚠️ BOSS SPAWN: ", current_world.boss_name, " nella Stanza ", current_room, " (Finale: ", is_final, ")")
		if boss_scene:
			var boss := boss_scene.instantiate() as Node2D
			if boss:
				boss.global_position = Vector2(360, 360)
				if "is_final_boss" in boss:
					boss.is_final_boss = is_final
				var progress_ratio: float = clampf(float(current_room) / float(max(1, current_world.total_rooms)), 0.55, 1.0)
				if "hp" in boss:
					boss.hp = int(float(boss.hp) * current_world.enemy_hp_multiplier * progress_ratio)
				if "max_hp" in boss:
					boss.max_hp = boss.hp
				get_tree().current_scene.add_child.call_deferred(boss)
		_update_hud_counter()
		return

	# 2. Stanza Santuario / Cyber-Valchiria (Ogni 5 Livelli nel mezzo: 5, 15, 25, 35, 45)
	var is_sanctuary_stage: bool = (current_room % 10 == 5) and (current_room < current_world.total_rooms)
	if is_sanctuary_stage:
		total_room_enemies = 0
		room_cleared = true
		print("👼 SANTUARIO CYBER-VALCHIRIA nella Stanza ", current_room)
		var sanct_script := load("res://scripts/sanctuary_node.gd")
		if sanct_script:
			var sanct: Node2D = sanct_script.new()
			sanct.global_position = Vector2(360, 540)
			get_tree().current_scene.add_child.call_deferred(sanct)
		spawn_door()
		_update_hud_counter()
		return

	# Level Design Strutturato (Ostacoli Perimetrali Simmetrici, Area Centrale Sgombra)
	var chosen_obstacles: Array[Vector2] = []
	if obstacle_scene:
		var obstacle_positions: Array[Vector2] = [
			Vector2(160, 340), Vector2(560, 340), # 2 Pilastri Angoli Superiori
			Vector2(140, 640), Vector2(580, 640), # 2 Blocchi di Copertura Laterali
			Vector2(160, 920), Vector2(560, 920)  # 2 Pilastri Angoli Inferiori
		]
		obstacle_positions.shuffle()
		var count := randi_range(3, 4)
		for i in range(count):
			var pos: Vector2 = obstacle_positions[i]
			chosen_obstacles.append(pos)
			var obstacle := obstacle_scene.instantiate() as Node2D
			if obstacle:
				obstacle.global_position = pos
				get_tree().current_scene.add_child.call_deferred(obstacle)

	# Generazione procedurale trappole ambientali bioma ai bordi
	if trap_scene:
		var trap_positions := [Vector2(220, 480), Vector2(500, 480), Vector2(360, 860)]
		var trap_count := randi_range(1, 2)
		for i in range(trap_count):
			var trap := trap_scene.instantiate() as Node2D
			if trap:
				trap.global_position = trap_positions[i]
				if "trap_type" in trap:
					trap.trap_type = current_world.trap_type
				if "damage" in trap:
					trap.damage = 10.0 * current_world.enemy_dmg_multiplier
				get_tree().current_scene.add_child.call_deferred(trap)

	# Generazione procedurale Casse di Rifornimento (LootCrate)
	if loot_crate_scene:
		var crate_pos := Vector2(randf_range(260, 460), 260)
		var crate := loot_crate_scene.instantiate() as Node2D
		if crate:
			crate.global_position = crate_pos
			get_tree().current_scene.add_child.call_deferred(crate)

	# Stanze Standard: Nemici con moltiplicatori HP e Danno bioma + progressione graduale stanza per stanza
	total_room_enemies = 3 + min(int(current_room / 2), 9)
	var room_hp_scale: float = 1.0 + float(current_room - 1) * 0.04
	var room_dmg_scale: float = 1.0 + float(current_room - 1) * 0.025
	print("Generazione di ", total_room_enemies, " nemici nella Stanza ", current_room)

	for i in range(total_room_enemies):
		var spawn_pos := _get_safe_spawn_pos(chosen_obstacles)
		var scene_to_spawn: PackedScene = enemy_scene

		var roll := randf()
		if current_room >= 3 and roll <= 0.25 and heavy_enemy_scene:
			scene_to_spawn = heavy_enemy_scene
		elif current_room >= 2 and roll <= 0.50 and ranged_enemy_scene:
			scene_to_spawn = ranged_enemy_scene
		else:
			scene_to_spawn = enemy_scene

		if scene_to_spawn:
			var enemy := scene_to_spawn.instantiate() as Node2D
			if enemy:
				enemy.global_position = spawn_pos
				if "hp" in enemy:
					enemy.hp = int(float(enemy.hp) * current_world.enemy_hp_multiplier * room_hp_scale)
				if "max_hp" in enemy and "hp" in enemy:
					enemy.max_hp = enemy.hp
				if "damage" in enemy:
					enemy.damage = int(float(enemy.damage) * current_world.enemy_dmg_multiplier * room_dmg_scale)
				get_tree().current_scene.add_child.call_deferred(enemy)

	_update_hud_counter()

func _get_safe_spawn_pos(obstacles: Array[Vector2]) -> Vector2:
	for attempt in range(15):
		var candidate := Vector2(randf_range(90.0, 630.0), randf_range(160.0, 720.0))
		var safe := true
		for obs_pos in obstacles:
			if candidate.distance_to(obs_pos) < 75.0:
				safe = false
				break
		if safe:
			return candidate
	return Vector2(360.0 + randf_range(-100.0, 100.0), randf_range(220.0, 520.0))

func _process(_delta: float) -> void:
	var remaining_enemies := get_tree().get_nodes_in_group("enemies").size()
	_update_hud_counter()

	if not room_cleared and remaining_enemies == 0:
		room_cleared = true
		_clear_all_projectiles()
		_vacuum_room_xp()
		spawn_door()

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
	print("🧲 Magnete XP attivato: Aspirando ", drops.size(), " oggetti XP/monete verso l'eroe.")
	for drop in drops:
		if drop.has_method("magnetize_to_player"):
			drop.magnetize_to_player(player)

func _update_hud_counter() -> void:
	var remaining := get_tree().get_nodes_in_group("enemies").size()
	var is_boss_st: bool = (current_room == current_world.total_rooms) or (current_room % 10 == 0)
	var is_sanct_st: bool = (current_room % 10 == 5) and (current_room < current_world.total_rooms)
	var huds := get_tree().get_nodes_in_group("hud")
	for h in huds:
		if "room_label" in h and h.room_label:
			if is_sanct_st:
				h.room_label.text = "Stage " + str(current_room) + "/" + str(current_world.total_rooms) + " | 👼 SANTUARIO RIFORNIMENTO"
			elif remaining > 0:
				var tag := "⚠️ BOSS" if is_boss_st else ("Nemici: " + str(remaining) + "/" + str(total_room_enemies))
				h.room_label.text = "Stage " + str(current_room) + "/" + str(current_world.total_rooms) + " | " + tag
			else:
				h.room_label.text = "Stage " + str(current_room) + "/" + str(current_world.total_rooms) + " | 🚪 PORTALE APERTO!"

func spawn_door() -> void:
	print("🚪 Stanza ", current_room, " pulita! Portale apparso in alto al centro.")
	if door_scene:
		var door := door_scene.instantiate() as Node2D
		if door:
			door.global_position = Vector2(360, 100)
			get_tree().current_scene.add_child.call_deferred(door)

func next_room() -> void:
	# Ripulitura ostacoli, casse, trappole e proiettili residui (eccetto le 4 pareti perimetrali)
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
	print("➡️ Passaggio alla Stanza ", current_room)

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is Node2D:
		var player := players[0] as Node2D
		player.global_position = Vector2(360, 1100)

		var tm: Node = get_node_or_null("/root/TalentManager")
		if tm and tm.has_method("get_bonus_value"):
			var rec_pct: float = tm.get_bonus_value("recovery")
			if rec_pct > 0.0 and "current_hp" in player and "max_hp" in player:
				var heal_amt: int = int(float(player.max_hp) * (rec_pct / 100.0))
				player.current_hp = min(player.max_hp, player.current_hp + heal_amt)
				if player.has_signal("hp_changed"): player.hp_changed.emit(player.current_hp, player.max_hp)

	start_room()
