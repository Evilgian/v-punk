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
	CyberModels.draw_boss(self, world_id, anim_t, boss_col, in_phase_2, aim_angle)

func _on_attack_timer_timeout() -> void:
	is_attacking = true

	if in_phase_2:
		_fire_radial_pattern(12)
	else:
		_fire_fan_pattern()

	await get_tree().create_timer(0.6).timeout
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
	SoundFX.play_explosion()
	SoundFX.play_win()

	var col := get_node_or_null("CollisionShape2D")
	if col: col.set_deferred("disabled", true)

	# Svanimento immediato di tutti i proiettili alla morte del Boss
	for proj in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(proj):
			proj.queue_free()

	var huds := get_tree().get_nodes_in_group("hud")
	if not huds.is_empty():
		var hud := huds[0]
		if hud.has_method("hide_boss_bar"):
			hud.hide_boss_bar()

	var w: WorldData = WorldDB.get_selected_world()
	var mult: float = w.reward_multiplier if w else 1.0
	var world_num: int = WorldDB.world_order.find(w.id if w else "world_1") + 1
	if world_num <= 0: world_num = 1

	Global.quest_kills += 1

	# Caso 1: Boss Intermedio (Livello 10, 20, 30, 40) -> Rilascia ricco bottino a terra e apre il Portale per continuare!
	if not is_final_boss:
		Global.total_coins += int(150.0 * mult)
		Global.total_credits += int(35.0 * mult)
		var vfx: Node = get_node_or_null("/root/VFXManager")
		if vfx and vfx.has_method("spawn_explosion"):
			vfx.spawn_explosion(global_position, boss_col)
		if vfx and vfx.has_method("spawn_floating_text"):
			vfx.spawn_floating_text(global_position, "🏆 GUARDIANO SCONFITTO! +BOTTINO BOSS!", CyberTheme.COL_YELLOW)

		if drop_scene:
			var mid_drops := ["gear_drop", "upgrade_scroll", "heal"]
			for i in range(mid_drops.size()):
				var d := drop_scene.instantiate() as Area2D
				if d:
					d.global_position = global_position + Vector2((i - 1) * 42.0, randf_range(-12.0, 12.0))
					if "drop_type" in d:
						d.drop_type = mid_drops[i]
					get_tree().current_scene.add_child.call_deferred(d)
		queue_free()
		return

	# Caso 2: Boss Finale (Ultimo Livello del Mondo) -> Premi Completamento Mondo e Vittoria!
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

	get_tree().paused = true
	if victory_scene:
		var victory := victory_scene.instantiate() as CanvasLayer
		if victory:
			get_tree().current_scene.add_child(victory)

	queue_free()
