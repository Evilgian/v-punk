extends CharacterBody2D

@export var hp: int = 500
@export var speed: float = 60.0
@export var enemy_projectile_scene: PackedScene = preload("res://scenes/EnemyProjectile.tscn")
@export var ranged_enemy_scene: PackedScene = preload("res://scenes/RangedEnemy.tscn")
@export var victory_scene: PackedScene = preload("res://scenes/Victory.tscn")
@export var drop_scene: PackedScene = preload("res://scenes/Drop.tscn")

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var shadow: Sprite2D = get_node_or_null("Shadow") as Sprite2D

var max_hp: int = 500
var is_final_boss: bool = true
var is_attacking: bool = false
var is_dying: bool = false
var death_anim_t: float = 0.0
var hide_boss_mesh: bool = false
var in_phase_2: bool = false
var spawned_minions_75: bool = false
var spawned_minions_50: bool = false
var attack_timer: Timer
var anim_t: float = 0.0
var aim_angle: float = PI * 0.5
var world_id: String = "world_1"
var boss_col: Color = Color(1.0, 0.25, 0.55, 1.0)
var contact_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	max_hp = hp
	if sprite: sprite.visible = false
	if shadow: shadow.visible = false

	var w: WorldData = WorldDB.get_selected_world()
	if w:
		world_id = w.id
		boss_col = w.boss_color

	attack_timer = Timer.new()
	attack_timer.wait_time = 2.0
	attack_timer.one_shot = false
	attack_timer.autostart = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

	call_deferred("_connect_to_hud")

func _connect_to_hud() -> void:
	max_hp = max(max_hp, hp)
	var world: WorldData = WorldDB.get_selected_world()
	var b_name: String = world.boss_name if world else "ROBO-TITAN"
	var prefix: String = "⚠️ BOSS FINALE: " if is_final_boss else "⚠️ GUARDIANO DI SETTORE: "
	var huds := get_tree().get_nodes_in_group("hud")
	if not huds.is_empty():
		var hud := huds[0]
		if hud.has_method("show_boss_bar"):
			hud.show_boss_bar(prefix + b_name.to_upper() + " ⚠️", max_hp)

func _physics_process(delta: float) -> void:
	anim_t += delta
	if is_dying:
		death_anim_t += delta
		velocity = Vector2.ZERO
		queue_redraw()
		return

	if contact_cooldown > 0.0:
		contact_cooldown -= delta
	queue_redraw()

	if is_attacking:
		velocity = Vector2.ZERO
		return

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is Node2D:
		var player := players[0] as Node2D
		var distance := global_position.distance_to(player.global_position)

		if distance < 55.0 and contact_cooldown <= 0.0:
			if player.has_method("take_damage"):
				player.take_damage(25)
				contact_cooldown = 0.8

		var move_speed := speed * (1.55 if in_phase_2 else 1.0)
		var dir := (player.global_position - global_position).normalized()
		aim_angle = dir.angle()
		velocity = dir * move_speed
		move_and_slide()

func _draw() -> void:
	if hide_boss_mesh:
		# Onda d'urto supernova finale in espansione sul ponte 3D
		var ring_r: float = clampf((death_anim_t - 1.8) * 320.0, 20.0, 420.0)
		var ring_a: float = clampf(1.0 - (ring_r / 420.0), 0.0, 1.0)
		draw_circle(Vector2(0, -18), ring_r * 0.45, Color(1.0, 0.88, 0.30, 0.25 * ring_a))
		draw_arc(Vector2(0, -18), ring_r, 0.0, TAU, 64, Color(0.15, 0.96, 1.0, 0.85 * ring_a), 6.0)
		draw_arc(Vector2(0, -18), ring_r * 0.72, 0.0, TAU, 48, Color(1.0, 0.82, 0.15, 0.90 * ring_a), 4.0)
		return

	if is_dying:
		var shake := Vector2(sin(death_anim_t * 62.0), cos(death_anim_t * 49.0)) * (7.0 + death_anim_t * 5.5)
		draw_set_transform(shake, sin(death_anim_t * 30.0) * 0.09, Vector2.ONE)
		CyberModels.draw_boss(self, world_id, anim_t, Color(1.0, 0.32, 0.18, 1.0), true, aim_angle)
		var flash_a: float = 0.30 + 0.28 * absf(sin(death_anim_t * 24.0))
		draw_circle(Vector2(0, -22), 54.0 + death_anim_t * 14.0, Color(1.0, 0.86, 0.35, flash_a))
		draw_arc(Vector2(0, -22), 62.0 + fmod(death_anim_t * 120.0, 55.0), 0.0, TAU, 36, Color(1.0, 0.95, 0.75, 0.85), 3.2)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return

	CyberModels.draw_boss(self, world_id, anim_t, boss_col, in_phase_2, aim_angle)

func _on_attack_timer_timeout() -> void:
	if is_dying:
		return
	is_attacking = true

	if in_phase_2:
		_fire_radial_pattern(12)
	else:
		_fire_fan_pattern()

	await get_tree().create_timer(0.6).timeout
	if is_dying:
		return
	is_attacking = false

func _fire_fan_pattern() -> void:
	if not enemy_projectile_scene:
		return

	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty() or not (players[0] is Node2D):
		return
	var player := players[0] as Node2D
	var base_dir := (player.global_position - global_position).normalized()
	aim_angle = base_dir.angle()

	for angle in [-30.0, -15.0, 0.0, 15.0, 30.0]:
		var proj := enemy_projectile_scene.instantiate() as Area2D
		if proj:
			proj.global_position = global_position
			var dir := base_dir.rotated(deg_to_rad(angle))
			proj.direction = dir
			proj.rotation = dir.angle()
			get_tree().current_scene.add_child.call_deferred(proj)

func _fire_radial_pattern(count: int = 8) -> void:
	if not enemy_projectile_scene:
		return

	for i in range(count):
		var dir := Vector2.RIGHT.rotated(i * TAU / float(count))
		var proj := enemy_projectile_scene.instantiate() as Area2D
		if proj:
			proj.global_position = global_position
			proj.direction = dir
			proj.rotation = dir.angle()
			get_tree().current_scene.add_child.call_deferred(proj)

func take_damage(amount: int) -> void:
	if is_dying:
		return
	if max_hp < hp: max_hp = hp
	hp -= amount
	var is_crit: bool = (randf() <= 0.2)
	var final_damage: int = amount * (2 if is_crit else 1)

	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx:
		if vfx.has_method("spawn_floating_damage"): vfx.spawn_floating_damage(global_position, final_damage, is_crit)
		if vfx.has_method("flash_hit"): vfx.flash_hit(self)

	var huds := get_tree().get_nodes_in_group("hud")
	if not huds.is_empty():
		var hud := huds[0]
		if hud.has_method("update_boss_hp"):
			hud.update_boss_hp(hp, max_hp)

	var hp_ratio := float(hp) / float(max_hp)

	if hp_ratio <= 0.75 and not spawned_minions_75:
		spawned_minions_75 = true
		_spawn_minions(2)

	if hp_ratio <= 0.50 and not in_phase_2:
		in_phase_2 = true
		spawned_minions_50 = true
		attack_timer.wait_time = 1.3
		_spawn_minions(2)

	queue_redraw()
	if hp <= 0:
		_die()

func _spawn_minions(count: int) -> void:
	if not ranged_enemy_scene:
		return
	for i in range(count):
		var drone := ranged_enemy_scene.instantiate() as Node2D
		if drone:
			drone.global_position = global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60))
			get_tree().current_scene.add_child.call_deferred(drone)

func _die() -> void:
	if is_dying:
		return
	is_dying = true
	death_anim_t = 0.0
	velocity = Vector2.ZERO
	if attack_timer:
		attack_timer.stop()

	var col := get_node_or_null("CollisionShape2D")
	if col: col.set_deferred("disabled", true)

	# Svanimento immediato di tutti i proiettili ostili (e droni minion se Boss Finale)
	for proj in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(proj):
			proj.queue_free()
	if is_final_boss:
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en != self:
				en.queue_free()

	var huds := get_tree().get_nodes_in_group("hud")
	if not huds.is_empty():
		var hud := huds[0]
		if hud.has_method("update_boss_hp"):
			hud.update_boss_hp(0, max_hp)

	var w: WorldData = WorldDB.get_selected_world()
	var mult: float = w.reward_multiplier if w else 1.0
	var world_num: int = WorldDB.world_order.find(w.id if w else "world_1") + 1
	if world_num <= 0: world_num = 1

	Global.quest_kills += 1
	var vfx: Node = get_node_or_null("/root/VFXManager")

	# Caso 1: Boss Intermedio (Livello 10, 20, 30, 40) -> Sequenza esplosiva a catena (~1.5s) e apertura Portale!
	if not is_final_boss:
		Global.total_coins += int(150.0 * mult)
		Global.total_credits += int(35.0 * mult)
		var ss_mid: Node = get_node_or_null("/root/SaveSystem")
		if ss_mid and ss_mid.has_method("save_game"): ss_mid.save_game()

		if vfx and vfx.has_method("spawn_floating_text"):
			vfx.spawn_floating_text(global_position + Vector2(0, -64), "⚠️ GUARDIANO IN SOVRACCARICO!", CyberTheme.COL_YELLOW)

		for step_i in range(5):
			if not is_inside_tree():
				return
			SoundFX.play_explosion()
			var boom_off := Vector2(randf_range(-46.0, 46.0), randf_range(-62.0, 24.0))
			if vfx and vfx.has_method("spawn_explosion"):
				vfx.spawn_explosion(global_position + boom_off, boss_col if step_i % 2 == 0 else CyberTheme.COL_YELLOW)
			await get_tree().create_timer(0.24).timeout

		if not is_inside_tree():
			return
		hide_boss_mesh = true
		queue_redraw()
		SoundFX.play_explosion()
		SoundFX.play_win()
		if vfx and vfx.has_method("spawn_explosion"):
			vfx.spawn_explosion(global_position, CyberTheme.COL_YELLOW)
		if vfx and vfx.has_method("spawn_floating_text"):
			vfx.spawn_floating_text(global_position, "🏆 GUARDIANO SCONFITTO! +BOTTINO BOSS!", CyberTheme.COL_YELLOW)

		for h in get_tree().get_nodes_in_group("hud"):
			if h.has_method("hide_boss_bar"):
				h.hide_boss_bar()

		if drop_scene:
			var mid_drops := ["gear_drop", "upgrade_scroll", "heal"]
			for i in range(mid_drops.size()):
				var d := drop_scene.instantiate() as Area2D
				if d:
					d.global_position = global_position + Vector2((i - 1) * 44.0, randf_range(-12.0, 12.0))
					if "drop_type" in d:
						d.drop_type = mid_drops[i]
					get_tree().current_scene.add_child.call_deferred(d)

		await get_tree().create_timer(0.32).timeout
		if is_inside_tree():
			queue_free()
		return

	# Caso 2: Boss Finale (Ultimo Livello del Mondo) -> Salva subito i premi, poi Coreografia Epica di Vittoria (~3.3s)!
	var reward_coins: int = int(600.0 * mult)
	var reward_gems: int = int(200.0 * mult)
	var reward_scrolls: int = 3 + world_num * 2

	Global.total_coins += reward_coins
	Global.total_credits += reward_gems
	Global.upgrade_scrolls += reward_scrolls
	Global.quest_runs += 1

	# 2 Drop Equipaggiamento Garantiti al Completamento del Mondo!
	var dropped_items: Array = []
	var im: Node = get_node_or_null("/root/InventoryManager")
	if im and im.has_method("roll_random_in_run_gear_drop"):
		dropped_items.append(im.roll_random_in_run_gear_drop(world_num))
		dropped_items.append(im.roll_random_in_run_gear_drop(world_num))

	# Sblocco Sequenziale del Mondo Successivo
	var newly_unlocked_world: int = 0
	if world_num >= Global.max_unlocked_world and world_num < 8:
		Global.max_unlocked_world = world_num + 1
		newly_unlocked_world = Global.max_unlocked_world
		WorldDB.selected_world_id = "world_" + str(Global.max_unlocked_world)

	Global.last_run_rewards = {
		"world_name": w.display_name if w else "SETTORE 01",
		"world_num": world_num,
		"coins": reward_coins,
		"gems": reward_gems,
		"scrolls": reward_scrolls,
		"items": dropped_items,
		"unlocked_world": newly_unlocked_world
	}

	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"): ss.save_game()

	# FASE A: Impatto fatale in Slow-Motion Cinematografico (0.35s reali)
	SoundFX.play_explosion()
	if vfx and vfx.has_method("spawn_floating_text"):
		vfx.spawn_floating_text(global_position + Vector2(0, -72), "💥 COLLASSO NUCLEO BOSS! 💥", CyberTheme.COL_YELLOW)
	Engine.time_scale = 0.42
	await get_tree().create_timer(0.35, true, false, true).timeout
	Engine.time_scale = 1.0
	if not is_inside_tree():
		return

	# FASE B: 7 Esplosioni a Catena sul Corpo 3D del Boss in Sovraccarico (1.75s)
	var blast_colors := [boss_col, CyberTheme.COL_YELLOW, CyberTheme.COL_CYAN, CyberTheme.COL_MAGENTA]
	for b_idx in range(7):
		if not is_inside_tree():
			Engine.time_scale = 1.0
			return
		SoundFX.play_explosion()
		var off := Vector2(randf_range(-56.0, 56.0), randf_range(-74.0, 28.0))
		var b_col: Color = blast_colors[b_idx % blast_colors.size()]
		if vfx and vfx.has_method("spawn_explosion"):
			vfx.spawn_explosion(global_position + off, b_col)
		for p_drop in get_tree().get_nodes_in_group("projectiles"):
			if is_instance_valid(p_drop): p_drop.queue_free()
		await get_tree().create_timer(0.25, true, false, true).timeout

	if not is_inside_tree():
		Engine.time_scale = 1.0
		return

	# FASE C: Detonazione Supernova Finale + Celebrazione Vittoria in Arena (1.20s)
	hide_boss_mesh = true
	death_anim_t = 1.85
	queue_redraw()
	SoundFX.play_explosion()
	SoundFX.play_win()

	for h in get_tree().get_nodes_in_group("hud"):
		if h.has_method("hide_boss_bar"):
			h.hide_boss_bar()
		if "room_label" in h and h.room_label:
			h.room_label.text = "🏆 " + (w.display_name.to_upper() if w else "SETTORE") + " COMPLETATO! 🏆"

	if vfx and vfx.has_method("spawn_explosion"):
		vfx.spawn_explosion(global_position, CyberTheme.COL_YELLOW)
		vfx.spawn_explosion(global_position + Vector2(-38, -20), CyberTheme.COL_CYAN)
		vfx.spawn_explosion(global_position + Vector2(38, -20), CyberTheme.COL_MAGENTA)
	if vfx and vfx.has_method("spawn_floating_text"):
		vfx.spawn_floating_text(global_position + Vector2(0, -30), "🏆 SETTORE LIBERATO — VITTORIA! 🏆", CyberTheme.COL_YELLOW)

	await get_tree().create_timer(1.20, true, false, true).timeout
	Engine.time_scale = 1.0
	if not is_inside_tree():
		return

	# FASE D: Apertura morbida della Schermata Trionfale 3D con il Bottino!
	get_tree().paused = true
	if victory_scene:
		var victory := victory_scene.instantiate() as CanvasLayer
		if victory:
			get_tree().current_scene.add_child(victory)

	queue_free()
