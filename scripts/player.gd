extends CharacterBody2D

signal exp_changed(current: int, max_val: int)
signal hp_changed(current: int, max_val: int)
signal leveled_up(new_level: int)

@export var max_hp: int = 100
@export var speed: float = 300.0
@export var joystick_path: NodePath
@export var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
@export var perk_selector_scene: PackedScene = preload("res://scenes/PerkSelector.tscn")
@export var game_over_scene: PackedScene = preload("res://scenes/GameOver.tscn")

var fire_rate: float = 0.3
var weapon_base_damage: int = 10
var bonus_damage: int = 0
var current_hp: int = max_hp
var level: int = 1
var current_exp: int = 0
var exp_to_next_level: int = 5

var has_front_arrow: bool = false
var has_diagonal_arrow: bool = false
var has_bouncy_wall: bool = false
var has_spread_shot: bool = false
var has_piercing: bool = false
var extra_projectiles: int = 0
var speed_modifier: float = 1.0

var has_pet_laser: bool = false
var has_pet_shield: bool = false
var pet_shoot_timer: float = 0.0
var anim_t: float = 0.0
var aim_angle: float = -PI * 0.5

var is_shooting: bool = false
var shoot_timer: Timer
var joystick_node: Control

@onready var camera: Camera2D = $Camera2D
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var shadow: Sprite2D = get_node_or_null("Shadow") as Sprite2D
var shake_intensity: float = 0.0
var shake_decay: float = 12.0
var invulnerable_time: float = 0.0

func _ready() -> void:
	add_to_group("player")
	if sprite: sprite.visible = false
	if shadow: shadow.visible = false

	var current_weapon = WeaponDB.get_equipped_weapon()
	if current_weapon:
		fire_rate = current_weapon.fire_rate * WeaponDB.get_equipped_gloves_firerate_multiplier()
		weapon_base_damage = current_weapon.get_final_damage()

	var tm: Node = get_node_or_null("/root/TalentManager")
	var atk_talent: int = int(tm.get_bonus_value("atk")) if (tm and tm.has_method("get_bonus_value")) else 0
	var hp_talent: int = int(tm.get_bonus_value("hp")) if (tm and tm.has_method("get_bonus_value")) else 0
	var speed_talent: float = tm.get_bonus_value("speed") if (tm and tm.has_method("get_bonus_value")) else 0.0

	var im: Node = get_node_or_null("/root/InventoryManager")
	if im:
		has_pet_laser = (im.equipped_pet1_id == "drone_laser" or im.equipped_pet2_id == "drone_laser")
		has_pet_shield = (im.equipped_pet1_id == "drone_shield" or im.equipped_pet2_id == "drone_shield")
		if im.equipped_ring1_id == "ring_speed" or im.equipped_ring2_id == "ring_speed":
			speed += 25.0
		if im.equipped_ring1_id == "ring_crit" or im.equipped_ring2_id == "ring_crit":
			bonus_damage += 4

	speed += WeaponDB.get_equipped_boots_speed_bonus() + speed_talent
	max_hp += (Global.upgrade_hp_lvl * 20) + WeaponDB.get_equipped_armor_hp_bonus() + hp_talent + (25 if has_pet_shield else 0)
	bonus_damage += (Global.upgrade_dmg_lvl * 2) + atk_talent
	current_hp = max_hp

	shoot_timer = Timer.new()
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = false
	shoot_timer.autostart = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

	if joystick_path:
		joystick_node = get_node_or_null(joystick_path) as Control

	if not joystick_node:
		var nodes := get_tree().get_nodes_in_group("virtual_joystick")
		if nodes.size() > 0:
			joystick_node = nodes[0] as Control

	exp_changed.emit(current_exp, exp_to_next_level)
	hp_changed.emit(current_hp, max_hp)

func add_extra_projectiles(amt: int = 1) -> void:
	extra_projectiles += amt
	print("🔥 Stacking Abilità: extra_projectiles = ", extra_projectiles)

func _physics_process(_delta: float) -> void:
	var move_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var x := 0.0
	var y := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): y += 1.0

	var custom_kb := Vector2(x, y)
	if custom_kb != Vector2.ZERO:
		move_dir = custom_kb.normalized()

	if move_dir == Vector2.ZERO:
		if not is_instance_valid(joystick_node):
			var joysticks := get_tree().get_nodes_in_group("virtual_joystick")
			if not joysticks.is_empty():
				joystick_node = joysticks[0] as Control

		if joystick_node:
			var joy_vec: Vector2 = Vector2.ZERO
			if joystick_node.has_method("get_output"):
				joy_vec = joystick_node.get_output()
			elif "output_vector" in joystick_node:
				joy_vec = joystick_node.output_vector
			if joy_vec != Vector2.ZERO:
				move_dir = joy_vec

	velocity = move_dir * speed * speed_modifier
	move_and_slide()

	# Clamp Eroe tassativo dentro i confini visibili dello schermo 720x1280
	global_position.x = clamp(global_position.x, 32.0, 688.0)
	global_position.y = clamp(global_position.y, 40.0, 1240.0)

	is_shooting = (velocity.length() < 10.0)

	if velocity.length() > 10.0:
		aim_angle = velocity.angle()
	elif is_shooting:
		var closest := get_closest_enemy()
		if closest:
			aim_angle = (closest.global_position - global_position).angle()

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

	if invulnerable_time > 0.0:
		invulnerable_time -= delta

	if has_pet_laser:
		pet_shoot_timer += delta
		if pet_shoot_timer >= 1.3:
			pet_shoot_timer = 0.0
			var target := get_closest_enemy()
			if target:
				var pet_pos := global_position + Vector2.RIGHT.rotated(anim_t * 2.5) * 42.0
				var dir := (target.global_position - pet_pos).normalized()
				_spawn_projectile_from(pet_pos, dir, 0.5)

	var active_cam: Camera2D = get_viewport().get_camera_2d()
	if active_cam and shake_intensity > 0.0:
		active_cam.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = max(0.0, shake_intensity - shake_decay * delta)
	elif active_cam and active_cam.offset != Vector2.ZERO:
		active_cam.offset = Vector2.ZERO

func _draw() -> void:
	# Modello Procedurale Cyber-Ronin Exo-Suit + Arma Equipaggiata
	CyberModels.draw_hero(self, WeaponDB.equipped_weapon_id, anim_t, velocity.length() > 10.0, is_shooting, aim_angle)

	# Droni Compagni Orbitanti (Pet 1 & Pet 2) con Modelli 3D-Shaded
	if has_pet_laser:
		var p1 := Vector2.RIGHT.rotated(anim_t * 2.5) * 42.0
		var dt1 := CyberTheme.get_model_texture("res://assets/cyber_models/drone_laser.png")
		if dt1:
			draw_texture_rect(dt1, Rect2(p1 - Vector2(16, 16), Vector2(32, 32)), false)
		else:
			draw_circle(p1, 9.0, Color(0.0, 0.94, 1.0, 0.25))
			draw_circle(p1, 4.5, Color(0.0, 0.95, 1.0, 0.95))

	if has_pet_shield:
		var p2 := Vector2.RIGHT.rotated(-anim_t * 2.0 + PI) * 42.0
		var dt2 := CyberTheme.get_model_texture("res://assets/cyber_models/drone_shield.png")
		if dt2:
			draw_texture_rect(dt2, Rect2(p2 - Vector2(16, 16), Vector2(32, 32)), false)
		else:
			draw_circle(p2, 9.0, Color(0.75, 0.25, 1.0, 0.25))
			draw_circle(p2, 4.5, Color(0.85, 0.35, 1.0, 0.95))
		draw_arc(Vector2.ZERO, 32.0, -anim_t * 2.0 + PI - 0.5, -anim_t * 2.0 + PI + 0.5, 16, Color(0.75, 0.3, 1.0, 0.65), 2.5)

func apply_shake(intensity: float = 8.0) -> void:
	shake_intensity = max(shake_intensity, intensity)

func take_damage(amount: int) -> void:
	if invulnerable_time > 0.0:
		return
	invulnerable_time = 0.25

	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	apply_shake(10.0)

	var tween := create_tween()
	modulate = Color(3.5, 0.2, 0.2, 1.0)
	tween.tween_property(self, "modulate", Color.WHITE, 0.18)

	if current_hp <= 0:
		die()

func die() -> void:
	SoundFX.play_explosion()
	get_tree().paused = true
	hide()
	if game_over_scene:
		var game_over := game_over_scene.instantiate() as CanvasLayer
		if game_over:
			get_tree().current_scene.add_child(game_over)

func add_exp(amount: int) -> void:
	current_exp += amount

	while current_exp >= exp_to_next_level:
		current_exp -= exp_to_next_level
		level += 1
		exp_to_next_level = int(exp_to_next_level * 1.5)
		leveled_up.emit(level)
		trigger_level_up()

	exp_changed.emit(current_exp, exp_to_next_level)

func trigger_level_up() -> void:
	get_tree().paused = true
	if perk_selector_scene:
		var selector := perk_selector_scene.instantiate() as CanvasLayer
		if selector:
			get_tree().current_scene.add_child(selector)

func get_closest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var closest_enemy: Node2D = null
	var min_distance := INF

	for enemy in enemies:
		if is_instance_valid(enemy) and enemy is Node2D:
			var dist := global_position.distance_squared_to(enemy.global_position)
			if dist < min_distance:
				min_distance = dist
				closest_enemy = enemy

	return closest_enemy

func _spawn_projectile(dir: Vector2) -> void:
	_spawn_projectile_from(global_position, dir, 1.0)

func _spawn_projectile_from(origin: Vector2, dir: Vector2, dmg_mult: float = 1.0) -> void:
	if not projectile_scene:
		return

	var projectile := projectile_scene.instantiate() as Area2D
	if projectile:
		projectile.global_position = origin
		projectile.direction = dir
		projectile.rotation = dir.angle()

		var eq_w: String = WeaponDB.equipped_weapon_id
		if "weapon_type" in projectile:
			projectile.weapon_type = eq_w

		if eq_w == "homing_wand" and "is_homing" in projectile:
			projectile.is_homing = true
		elif eq_w == "katana" and "is_melee_slash" in projectile and dmg_mult >= 1.0:
			projectile.is_melee_slash = true
		elif eq_w == "scythe" and "is_piercing" in projectile:
			projectile.is_piercing = true
			if "speed" in projectile: projectile.speed = 480.0

		if "is_piercing" in projectile and has_piercing:
			projectile.is_piercing = true

		if "bounces_left" in projectile and has_bouncy_wall:
			projectile.bounces_left = 2

		if "damage" in projectile:
			var base_dmg: int = weapon_base_damage + bonus_damage
			var raw_dmg: float = (base_dmg * 1.5 if eq_w == "katana" else float(base_dmg)) * dmg_mult
			projectile.damage = max(1, int(raw_dmg))

		get_tree().current_scene.add_child(projectile)
		if dmg_mult >= 1.0:
			SoundFX.play_shoot()

func _on_shoot_timer_timeout() -> void:
	if not is_shooting:
		return

	var target_enemy := get_closest_enemy()
	if target_enemy:
		var base_dir := (target_enemy.global_position - global_position).normalized()
		aim_angle = base_dir.angle()

		_spawn_projectile(base_dir)

		if WeaponDB.equipped_weapon_id == "shotgun":
			_spawn_projectile(base_dir.rotated(deg_to_rad(10.0)))
			_spawn_projectile(base_dir.rotated(deg_to_rad(-10.0)))

		if extra_projectiles > 0:
			var step_angle := 12.0
			var start_angle := - (extra_projectiles * step_angle) / 2.0
			for i in range(extra_projectiles):
				var angle := start_angle + (i + 0.5) * step_angle
				if abs(angle) < 0.1:
					angle = 6.0
				_spawn_projectile(base_dir.rotated(deg_to_rad(angle)))

		if has_front_arrow:
			_spawn_projectile(base_dir.rotated(deg_to_rad(6.0)))

		if has_diagonal_arrow:
			_spawn_projectile(base_dir.rotated(deg_to_rad(45.0)))
			_spawn_projectile(base_dir.rotated(deg_to_rad(-45.0)))

		if has_spread_shot:
			_spawn_projectile(base_dir.rotated(deg_to_rad(18.0)))
			_spawn_projectile(base_dir.rotated(deg_to_rad(-18.0)))
