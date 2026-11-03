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
var target_aim_angle: float = -PI * 0.5

# --- Abilità Neurali della run (scelte al Level Up) ---
var perk_stacks: Dictionary = {}
var has_rear_arrow: bool = false
var has_side_arrows: bool = false
var has_homing_rounds: bool = false
var shot_scale: float = 1.0
var crit_chance: float = 0.0
var explosive_stacks: int = 0
var chain_stacks: int = 0
var has_freeze: bool = false
var burn_stacks: int = 0
var vampire_stacks: int = 0
var dodge_chance: float = 0.0
var regen_stacks: int = 0
var regen_timer: float = 0.0
var orbit_blades: int = 0
var orbit_hit_cd: Dictionary = {}
var shield_max: int = 0
var shield_charges: int = 0
var shield_recharge_t: float = 0.0

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
	var pet_laser_lvl: int = 1
	var pet_shield_lvl: int = 1
	if im:
		has_pet_laser = (im.equipped_pet1_id == "drone_laser" or im.equipped_pet2_id == "drone_laser")
		has_pet_shield = (im.equipped_pet1_id == "drone_shield" or im.equipped_pet2_id == "drone_shield")
		if im.has_method("get_item_level"):
			var wep_lvl: int = im.get_item_level(im.equipped_weapon_id)
			weapon_base_damage += (wep_lvl - 1) * 3
			if not im.equipped_armor_id.is_empty():
				var arm_lvl: int = im.get_item_level(im.equipped_armor_id)
				max_hp += (arm_lvl - 1) * 18
			if has_pet_laser:
				pet_laser_lvl = im.get_item_level("drone_laser")
			if has_pet_shield:
				pet_shield_lvl = im.get_item_level("drone_shield")
		if im.equipped_ring1_id == "ring_speed" or im.equipped_ring2_id == "ring_speed":
			var r_spd_lvl: int = im.get_item_level("ring_speed") if im.has_method("get_item_level") else 1
			speed += 25.0 + float(r_spd_lvl - 1) * 6.0
		if im.equipped_ring1_id == "ring_crit" or im.equipped_ring2_id == "ring_crit":
			var r_crt_lvl: int = im.get_item_level("ring_crit") if im.has_method("get_item_level") else 1
			bonus_damage += 4 + (r_crt_lvl - 1) * 2

	# Bonus Archetipo / Classe Scelta dal Giocatore
	match Global.player_class.to_upper():
		"VANGUARD":
			max_hp += 40
		"NETRUNNER":
			bonus_damage += 4
		_: # RONIN
			speed += 30.0
			bonus_damage += 1

	speed += WeaponDB.get_equipped_boots_speed_bonus() + speed_talent
	max_hp += (Global.upgrade_hp_lvl * 20) + WeaponDB.get_equipped_armor_hp_bonus() + hp_talent + ((25 + (pet_shield_lvl - 1) * 12) if has_pet_shield else 0)
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

## Applica un'Abilità Neurale scelta al Level Up (tutte cumulabili fino a max_stacks)
func apply_perk(perk_id: String) -> void:
	perk_stacks[perk_id] = int(perk_stacks.get(perk_id, 0)) + 1
	match perk_id:
		"front_arrow": extra_projectiles += 1
		"diagonal_arrow": has_diagonal_arrow = true
		"spread_shot": has_spread_shot = true
		"rear_arrow": has_rear_arrow = true
		"side_arrows": has_side_arrows = true
		"bouncy_wall": has_bouncy_wall = true
		"piercing": has_piercing = true
		"homing_rounds": has_homing_rounds = true
		"giant_shots":
			shot_scale += 0.25
			bonus_damage += 3
		"attack_speed":
			fire_rate = max(0.08, fire_rate * 0.8)
			if shoot_timer: shoot_timer.wait_time = fire_rate
		"damage_up": bonus_damage += 8
		"crit_up": crit_chance = minf(0.75, crit_chance + 0.12)
		"explosive": explosive_stacks += 1
		"chain_lightning": chain_stacks += 1
		"freeze_shot": has_freeze = true
		"burn_shot": burn_stacks += 1
		"orbit_blades": orbit_blades += 1
		"energy_shield":
			shield_max += 1
			shield_charges = shield_max
		"vampire": vampire_stacks += 1
		"dodge": dodge_chance = minf(0.45, dodge_chance + 0.12)
		"regen": regen_stacks += 1
		"max_hp_up":
			max_hp += 30
			current_hp = min(max_hp, current_hp + 30)
		"move_speed": speed_modifier += 0.10
		"heal":
			current_hp = min(max_hp, current_hp + int(max_hp * 0.35))
	hp_changed.emit(current_hp, max_hp)

func heal(amount: int) -> void:
	if amount <= 0 or current_hp <= 0: return
	var before := current_hp
	current_hp = min(max_hp, current_hp + amount)
	if current_hp != before:
		hp_changed.emit(current_hp, max_hp)
		var vfx: Node = get_node_or_null("/root/VFXManager")
		if vfx and vfx.has_method("spawn_floating_text"):
			vfx.spawn_floating_text(global_position + Vector2(60, -40), "+" + str(current_hp - before) + " HP", Color(0.2, 1.0, 0.5, 1.0))

## Effetti delle abilità "al colpo" (chiamato dai proiettili del giocatore)
func on_projectile_hit(body: Node, dmg: int, hit_pos: Vector2) -> void:
	if vampire_stacks > 0 and randf() < 0.25:
		heal(vampire_stacks * 2)

	var enemies := get_tree().get_nodes_in_group("enemies")
	if explosive_stacks > 0:
		var vfx: Node = get_node_or_null("/root/VFXManager")
		if vfx and vfx.has_method("spawn_explosion"):
			vfx.spawn_explosion(hit_pos, Color(1.0, 0.45, 0.1, 1.0))
		var splash := maxi(1, int(dmg * 0.40 * explosive_stacks))
		for e in enemies:
			if e != body and is_instance_valid(e) and e is Node2D and e.has_method("take_damage"):
				if (e as Node2D).global_position.distance_to(hit_pos) <= 62.0:
					e.take_damage(splash)

	if chain_stacks > 0:
		var targets: Array = []
		for e in enemies:
			if e != body and is_instance_valid(e) and e is Node2D and e.has_method("take_damage"):
				var d := (e as Node2D).global_position.distance_to(hit_pos)
				if d <= 190.0:
					targets.append({"n": e, "d": d})
		targets.sort_custom(func(a, b): return a["d"] < b["d"])
		var zap := maxi(1, int(dmg * 0.35 * chain_stacks))
		var prev := hit_pos
		for i in range(mini(2, targets.size())):
			var tn: Node2D = targets[i]["n"]
			_spawn_lightning(prev, tn.global_position)
			prev = tn.global_position
			tn.take_damage(zap)

	if has_freeze and is_instance_valid(body) and "speed" in body:
		if not body.has_meta("base_speed"):
			body.set_meta("base_speed", body.speed)
		var base_spd: float = float(body.get_meta("base_speed"))
		body.speed = base_spd * 0.55
		var until := Time.get_ticks_msec() + 1500
		body.set_meta("slow_until", until)
		get_tree().create_timer(1.55, false).timeout.connect(func():
			if is_instance_valid(body) and int(body.get_meta("slow_until", 0)) <= Time.get_ticks_msec():
				body.speed = float(body.get_meta("base_speed", body.speed))
		)

	if burn_stacks > 0 and is_instance_valid(body):
		var burn_dmg := maxi(1, int(dmg * 0.12 * burn_stacks) + 1)
		for t_i in range(3):
			get_tree().create_timer(0.45 * float(t_i + 1), false).timeout.connect(func():
				if is_instance_valid(body) and body.has_method("take_damage") and "hp" in body and int(body.hp) > 0:
					body.take_damage(burn_dmg)
			)

func _spawn_lightning(a: Vector2, b: Vector2) -> void:
	var scene := get_tree().current_scene
	if not scene: return
	var line := Line2D.new()
	line.width = 4.0
	line.default_color = Color(0.55, 0.9, 1.0, 1.0)
	line.z_index = 18
	var pts := PackedVector2Array([a])
	for s in range(1, 5):
		var p := a.lerp(b, float(s) / 5.0) + Vector2(randf_range(-9, 9), randf_range(-9, 9))
		pts.append(p)
	pts.append(b)
	line.points = pts
	scene.add_child(line)
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.22)
	tw.tween_callback(line.queue_free)

func _physics_process(delta: float) -> void:
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

	# Clamp Eroe tassativo dentro i confini 3D del ponte (con accesso alla nicchia Stargate in alto)
	global_position.x = clampf(global_position.x, 54.0, 666.0)
	var min_y_bound: float = 96.0 if (global_position.x >= 290.0 and global_position.x <= 430.0) else 122.0
	global_position.y = clampf(global_position.y, min_y_bound, 1232.0)

	is_shooting = (velocity.length() < 10.0)

	# L'eroe mantiene SEMPRE lo sguardo e l'arma puntati verso il nemico più vicino
	# (sia mentre spara da fermo, sia mentre corre o schiva!), e a stanza pulita guarda il Portale a Nord.
	var closest := get_closest_enemy()
	if closest:
		target_aim_angle = (closest.global_position - global_position).angle()
	elif velocity.length() > 10.0:
		target_aim_angle = velocity.angle()
	else:
		target_aim_angle = -PI * 0.5

	aim_angle = lerp_angle(aim_angle, target_aim_angle, minf(1.0, delta * 18.0))

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

	if invulnerable_time > 0.0:
		invulnerable_time -= delta

	# Gestione Scudo Energetico (ricarica ogni 7s se sotto il massimo)
	if shield_max > 0 and shield_charges < shield_max:
		shield_recharge_t += delta
		if shield_recharge_t >= 7.0:
			shield_recharge_t = 0.0
			shield_charges += 1
			var vfx: Node = get_node_or_null("/root/VFXManager")
			if vfx and vfx.has_method("spawn_floating_text"):
				vfx.spawn_floating_text(global_position + Vector2(60, -40), "🛡️ SCUDO PRONTO", Color(0.1, 0.9, 1.0, 1.0))

	# Gestione Rigenerazione passiva HP
	if regen_stacks > 0 and current_hp > 0 and current_hp < max_hp:
		regen_timer += delta
		if regen_timer >= 3.0:
			regen_timer = 0.0
			heal(regen_stacks * 3)

	# Gestione Lame Orbitali
	if orbit_blades > 0:
		var cur_msec: int = Time.get_ticks_msec()
		var blade_dmg: int = maxi(5, int((weapon_base_damage + bonus_damage) * 0.75))
		var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
		for b_i in range(orbit_blades):
			var b_ang := anim_t * 3.2 + float(b_i) * (TAU / float(orbit_blades))
			var b_pos := global_position + Vector2(cos(b_ang) * 52.0, sin(b_ang) * 26.0)
			for e in enemies:
				if is_instance_valid(e) and e is Node2D and e.has_method("take_damage"):
					if (e as Node2D).global_position.distance_to(b_pos) <= 28.0:
						var eid := (e as Node2D).get_instance_id()
						if cur_msec - int(orbit_hit_cd.get(eid, 0)) >= 450:
							orbit_hit_cd[eid] = cur_msec
							e.take_damage(blade_dmg)
							SoundFX.play_hit()

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
	# Modello 3D Articolato Cyber-Ronin Exo-Suit + Locomozione e Mira Continua sui Nemici
	var norm_vel: Vector2 = velocity / maxf(1.0, speed * speed_modifier)
	var firing_active: bool = is_shooting and (get_closest_enemy() != null)
	CyberModels.draw_hero(self, WeaponDB.equipped_weapon_id, anim_t, velocity.length() > 10.0, firing_active, aim_angle, norm_vel, 86.0)

	# Disegna Lame Orbitali
	if orbit_blades > 0:
		for b_i in range(orbit_blades):
			var b_ang := anim_t * 3.2 + float(b_i) * (TAU / float(orbit_blades))
			var b_pos := Vector2(cos(b_ang) * 52.0, sin(b_ang) * 26.0)
			draw_circle(b_pos, 7.0, Color(0.1, 0.95, 1.0, 0.35))
			draw_circle(b_pos, 4.0, Color(0.9, 0.98, 1.0, 0.95))
			draw_line(b_pos, b_pos + Vector2(-sin(b_ang), cos(b_ang) * 0.5) * 12.0, Color(0.0, 0.9, 1.0, 0.8), 2.5)

	# Disegna Scudo Energetico attivo attorno all'eroe
	if shield_charges > 0:
		var s_alpha := 0.45 + sin(anim_t * 4.0) * 0.15
		draw_set_transform(Vector2(0, 4), 0.0, Vector2(1.0, 0.65))
		draw_arc(Vector2.ZERO, 36.0, 0.0, TAU, 32, Color(0.1, 0.85, 1.0, s_alpha), 2.8)
		draw_circle(Vector2.ZERO, 34.0, Color(0.05, 0.45, 0.9, 0.08))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Droni Compagni Orbitanti (Pet 1 & Pet 2) in Prospettiva Ellittica 2.5D + Ombra a Terra
	if has_pet_laser:
		var ang1: float = anim_t * 2.5
		var p1 := Vector2(cos(ang1) * 48.0, -18.0 + sin(ang1) * 22.0)
		CyberModels.draw_ground_shadow(self, Vector2(p1.x, p1.y + 34.0), 9.0, 0.38)
		var dt1 := CyberTheme.get_model_texture("res://assets/cyber_models/drone_laser.png")
		if dt1:
			draw_texture_rect(dt1, Rect2(p1 - Vector2(16, 16), Vector2(32, 32)), false)
		else:
			draw_circle(p1, 9.0, Color(0.0, 0.94, 1.0, 0.25))
			draw_circle(p1, 4.5, Color(0.0, 0.95, 1.0, 0.95))

	if has_pet_shield:
		var ang2: float = -anim_t * 2.0 + PI
		var p2 := Vector2(cos(ang2) * 48.0, -18.0 + sin(ang2) * 22.0)
		CyberModels.draw_ground_shadow(self, Vector2(p2.x, p2.y + 34.0), 9.0, 0.38)
		var dt2 := CyberTheme.get_model_texture("res://assets/cyber_models/drone_shield.png")
		if dt2:
			draw_texture_rect(dt2, Rect2(p2 - Vector2(16, 16), Vector2(32, 32)), false)
		else:
			draw_circle(p2, 9.0, Color(0.75, 0.25, 1.0, 0.25))
			draw_circle(p2, 4.5, Color(0.85, 0.35, 1.0, 0.95))
		draw_set_transform(Vector2(0, 14), 0.0, Vector2(1.0, 0.44))
		draw_arc(Vector2.ZERO, 36.0, ang2 - 0.6, ang2 + 0.6, 16, Color(0.75, 0.3, 1.0, 0.70), 2.5)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func apply_shake(intensity: float = 8.0) -> void:
	if not Global.screen_shake_enabled:
		return
	shake_intensity = max(shake_intensity, intensity)

func take_damage(amount: int) -> void:
	if invulnerable_time > 0.0:
		return

	# Schivata Cybernetica
	if dodge_chance > 0.0 and randf() < dodge_chance:
		invulnerable_time = 0.20
		var vfx: Node = get_node_or_null("/root/VFXManager")
		if vfx and vfx.has_method("spawn_floating_text"):
			vfx.spawn_floating_text(global_position + Vector2(40, -30), "💨 SCHIVATO!", Color(0.3, 0.95, 1.0, 1.0))
		return

	# Scudo Energetico Assorbe il Colpo
	if shield_charges > 0:
		shield_charges -= 1
		invulnerable_time = 0.40
		SoundFX.play_hit()
		var vfx: Node = get_node_or_null("/root/VFXManager")
		if vfx and vfx.has_method("spawn_floating_text"):
			vfx.spawn_floating_text(global_position + Vector2(40, -30), "🛡️ ASSORBITO!", Color(0.2, 0.85, 1.0, 1.0))
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

		if has_homing_rounds and "is_homing" in projectile:
			projectile.is_homing = true

		if shot_scale != 1.0:
			projectile.scale *= shot_scale

		if "bounces_left" in projectile and has_bouncy_wall:
			projectile.bounces_left = 2

		if "damage" in projectile:
			var base_dmg: int = weapon_base_damage + bonus_damage
			var raw_dmg: float = (base_dmg * 1.5 if eq_w == "katana" else float(base_dmg)) * dmg_mult
			# Calcolo critico con perk crit_up
			var is_crit: bool = (randf() <= (0.15 + crit_chance))
			if is_crit: raw_dmg *= 2.0
			projectile.damage = max(1, int(raw_dmg))
			if projectile.has_meta("is_crit"): projectile.set_meta("is_crit", is_crit)

		if projectile.has_signal("body_entered"):
			projectile.body_entered.connect(func(hit_b):
				if is_instance_valid(hit_b) and hit_b.is_in_group("enemies"):
					on_projectile_hit(hit_b, projectile.damage, projectile.global_position)
			)

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

		if has_rear_arrow:
			_spawn_projectile(base_dir.rotated(PI))

		if has_side_arrows:
			_spawn_projectile(base_dir.rotated(PI * 0.5))
			_spawn_projectile(base_dir.rotated(-PI * 0.5))
