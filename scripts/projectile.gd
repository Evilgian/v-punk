extends Area2D

@export var speed: float = 820.0
@export var damage: int = 10
@export var is_piercing: bool = false
@export var is_homing: bool = false
@export var is_melee_slash: bool = false
@export var bounces_left: int = 0
@export var ricochet_left: int = 0
@export var hit_particles_scene: PackedScene = preload("res://scenes/HitParticles.tscn")

var weapon_type: String = "pistol_base"
var direction: Vector2 = Vector2.UP
var lifetime: float = 0.0
var is_crit: bool = false
var knockback_force: float = 6.0
var hit_enemies: Dictionary = {}

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D

func _ready() -> void:
	add_to_group("projectiles")
	body_entered.connect(_on_body_entered)
	if sprite:
		sprite.visible = false
	if is_melee_slash:
		# Vera Onda Fendente Energetica Katana: ampia (scala 3.4x) e avanza di ~130px davanti all'eroe!
		scale = Vector2(3.4, 3.2)
		speed = 540.0
		is_piercing = true
		knockback_force = 24.0
		monitoring = true
		monitorable = true
		_check_initial_overlap.call_deferred()
	elif weapon_type == "scythe":
		scale *= 1.55
		knockback_force = 18.0
	elif weapon_type == "plasma_cannon":
		scale *= 1.35
		knockback_force = 20.0
	elif weapon_type == "shotgun":
		knockback_force = 16.0
	elif weapon_type == "laser_rifle":
		speed = maxf(speed, 1020.0)

func _check_initial_overlap() -> void:
	var bodies := get_overlapping_bodies()
	for body in bodies:
		if body is Node2D:
			_on_body_entered(body as Node2D)

func _physics_process(delta: float) -> void:
	lifetime += delta
	queue_redraw()
	if is_melee_slash:
		position += direction * speed * delta
		if lifetime >= 0.24:
			queue_free()
		return

	if is_homing:
		var enemies := get_tree().get_nodes_in_group("enemies")
		if not enemies.is_empty():
			var nearest: Node2D = null
			var min_dist: float = 99999.0
			for e in enemies:
				if is_instance_valid(e) and e is Node2D:
					var dist: float = global_position.distance_to((e as Node2D).global_position)
					if dist < min_dist:
						min_dist = dist
						nearest = e as Node2D
			if nearest:
				var target_dir := (nearest.global_position - global_position).normalized()
				direction = direction.slerp(target_dir, 6.8 * delta).normalized()
				rotation = direction.angle()

	position += direction * speed * delta

func _draw() -> void:
	if is_melee_slash:
		var alpha := clampf(1.0 - (lifetime / 0.24), 0.12, 1.0)
		draw_arc(Vector2(-3, 0), 20.0, -PI * 0.46, PI * 0.46, 24, Color(0.0, 0.94, 1.0, 0.45 * alpha), 9.0)
		draw_arc(Vector2(-1, 0), 20.0, -PI * 0.42, PI * 0.42, 22, Color(0.25, 0.98, 1.0, 0.90 * alpha), 4.8)
		draw_arc(Vector2(0, 0), 20.0, -PI * 0.35, PI * 0.35, 18, Color(1.0, 1.0, 1.0, 0.96 * alpha), 2.2)
		return

	var shadow_off := Vector2(0, 18).rotated(-rotation)
	draw_circle(shadow_off, 5.2, Color(0, 0, 0, 0.30))

	if weapon_type == "scythe":
		var spin := lifetime * 18.0
		draw_circle(Vector2.ZERO, 16.0, Color(0.88, 0.16, 1.0, 0.30))
		draw_arc(Vector2.ZERO, 12.5, spin, spin + PI * 1.4, 24, Color(0.96, 0.28, 1.0, 0.98), 4.6)
		draw_arc(Vector2.ZERO, 12.5, spin + PI, spin + PI * 2.4, 24, Color(0.0, 0.95, 1.0, 0.92), 3.6)
		draw_circle(Vector2.ZERO, 4.5, Color.WHITE)
	elif weapon_type == "plasma_cannon":
		draw_line(Vector2(-26, 0), Vector2(0, 0), Color(0.0, 0.86, 1.0, 0.48), 11.0)
		draw_circle(Vector2.ZERO, 16.5, Color(0.0, 0.88, 1.0, 0.36))
		draw_circle(Vector2.ZERO, 10.5, Color(0.25, 0.96, 1.0, 0.96))
		draw_circle(Vector2.ZERO, 5.5, Color.WHITE)
	elif is_homing:
		draw_line(Vector2(-22, 0), Vector2(4, 0), Color(0.85, 0.25, 1.0, 0.40), 8.0)
		draw_circle(Vector2.ZERO, 11.0, Color(0.85, 0.25, 1.0, 0.36))
		draw_line(Vector2(-14, 0), Vector2(7, 0), Color(0.95, 0.42, 1.0, 0.98), 5.0)
		draw_circle(Vector2(5, 0), 4.2, Color.WHITE)
	else:
		draw_line(Vector2(-24, 0), Vector2(6, 0), Color(0.0, 0.94, 1.0, 0.22), 10.5)
		draw_line(Vector2(-14, 0), Vector2(9, 0), Color(0.0, 0.96, 1.0, 0.96), 4.8)
		draw_line(Vector2(-6, 0), Vector2(8, 0), Color(1.0, 1.0, 1.0, 1.0), 2.2)
		draw_circle(Vector2(7, 0), 3.0, Color.WHITE)

func _trigger_plasma_aoe(hit_pos: Vector2, direct_target: Node) -> void:
	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx and vfx.has_method("spawn_explosion"):
		vfx.spawn_explosion(hit_pos, Color(0.12, 0.92, 1.0, 1.0))
	var splash_dmg: int = maxi(4, int(round(float(damage) * 0.58)))
	for e in get_tree().get_nodes_in_group("enemies"):
		if e != direct_target and is_instance_valid(e) and e is Node2D and e.has_method("take_damage"):
			var en := e as Node2D
			if en.global_position.distance_to(hit_pos) <= 84.0:
				en.set_meta("last_hit_crit", false)
				en.set_meta("last_hit_dir", (en.global_position - hit_pos).normalized())
				en.take_damage(splash_dmg)

func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(body):
		return

	if body.is_in_group("enemies"):
		if (is_melee_slash or is_piercing or ricochet_left > 0) and hit_enemies.has(body.get_instance_id()):
			return
		hit_enemies[body.get_instance_id()] = true

		if body.has_method("take_damage"):
			body.set_meta("last_hit_crit", is_crit)
			body.set_meta("last_hit_dir", direction)
			body.take_damage(damage)
			if body.has_method("apply_knockback") and knockback_force > 0.0:
				body.apply_knockback(direction.normalized() * knockback_force)
			SoundFX.play_hit()

			if hit_particles_scene:
				var hit_fx := hit_particles_scene.instantiate() as Node2D
				var p_sc: Node = get_tree().current_scene if get_tree().current_scene else get_parent()
				if hit_fx and p_sc:
					hit_fx.global_position = global_position
					p_sc.add_child.call_deferred(hit_fx)

		if weapon_type == "plasma_cannon":
			_trigger_plasma_aoe(global_position, body)

		if ricochet_left > 0 and not is_melee_slash:
			var next_target: Node2D = null
			var best_d: float = 290.0
			for e in get_tree().get_nodes_in_group("enemies"):
				if is_instance_valid(e) and e != body and e is Node2D and not hit_enemies.has(e.get_instance_id()):
					var d := global_position.distance_to((e as Node2D).global_position)
					if d < best_d:
						best_d = d
						next_target = e as Node2D
			if next_target:
				ricochet_left -= 1
				direction = (next_target.global_position - global_position).normalized()
				rotation = direction.angle()
				return

		if not is_piercing and not is_melee_slash:
			queue_free()
	elif body.is_in_group("obstacles") or body.is_in_group("loot_crates") or body.is_in_group("walls") or body is StaticBody2D:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			SoundFX.play_hit()

		# L'onda energetica ravvicinata della Katana attraversa i bordi delle coperture senza bloccarsi subito
		if is_melee_slash and not body.is_in_group("walls"):
			return

		if weapon_type == "plasma_cannon":
			_trigger_plasma_aoe(global_position, null)

		if hit_particles_scene:
			var hit_fx := hit_particles_scene.instantiate() as Node2D
			var p_sc2: Node = get_tree().current_scene if get_tree().current_scene else get_parent()
			if hit_fx and p_sc2:
				hit_fx.global_position = global_position
				p_sc2.add_child.call_deferred(hit_fx)

		if bounces_left > 0:
			bounces_left -= 1
			direction = -direction.rotated(randf_range(-0.3, 0.3))
			rotation = direction.angle()
		elif not is_piercing and not is_melee_slash:
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
