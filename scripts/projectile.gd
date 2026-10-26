extends Area2D

@export var speed: float = 800.0
@export var damage: int = 10
@export var is_piercing: bool = false
@export var is_homing: bool = false
@export var is_melee_slash: bool = false
@export var bounces_left: int = 0
@export var hit_particles_scene: PackedScene = preload("res://scenes/HitParticles.tscn")

var weapon_type: String = "pistol_base"
var direction: Vector2 = Vector2.UP
var lifetime: float = 0.0
var hit_enemies: Dictionary = {}

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D

func _ready() -> void:
	add_to_group("projectiles")
	body_entered.connect(_on_body_entered)
	if sprite:
		sprite.visible = false # Usiamo il rendering neon ad alto contrasto in _draw()
	if is_melee_slash:
		scale = Vector2(2.8, 2.2)
		monitoring = true
		monitorable = true
		_check_initial_overlap.call_deferred()

func _check_initial_overlap() -> void:
	var bodies := get_overlapping_bodies()
	for body in bodies:
		if body is Node2D:
			_on_body_entered(body as Node2D)

func _physics_process(delta: float) -> void:
	lifetime += delta
	queue_redraw()
	if is_melee_slash:
		if lifetime >= 0.18:
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
				direction = direction.slerp(target_dir, 6.0 * delta).normalized()
				rotation = direction.angle()

	position += direction * speed * delta

func _draw() -> void:
	if is_melee_slash:
		var alpha := clampf(1.0 - (lifetime / 0.18), 0.1, 1.0)
		draw_arc(Vector2(-4, 0), 22.0, -PI * 0.42, PI * 0.42, 24, Color(0.0, 0.95, 1.0, 0.85 * alpha), 6.0)
		draw_arc(Vector2(-2, 0), 22.0, -PI * 0.36, PI * 0.36, 20, Color(1.0, 1.0, 1.0, 0.95 * alpha), 2.5)
		return

	if weapon_type == "scythe":
		var spin := lifetime * 18.0
		draw_circle(Vector2.ZERO, 12.0, Color(0.8, 0.1, 1.0, 0.28))
		draw_arc(Vector2.ZERO, 10.0, spin, spin + PI * 1.25, 20, Color(0.9, 0.2, 1.0, 0.95), 4.0)
		draw_arc(Vector2.ZERO, 10.0, spin, spin + PI * 1.1, 16, Color.WHITE, 1.5)
	elif weapon_type == "plasma_cannon":
		draw_circle(Vector2.ZERO, 14.0, Color(0.0, 0.85, 1.0, 0.32))
		draw_circle(Vector2.ZERO, 9.0, Color(0.2, 0.95, 1.0, 0.9))
		draw_circle(Vector2.ZERO, 5.0, Color.WHITE)
	elif is_homing:
		draw_circle(Vector2.ZERO, 9.0, Color(0.75, 0.25, 1.0, 0.35))
		draw_line(Vector2(-12, 0), Vector2(6, 0), Color(0.85, 0.35, 1.0, 0.95), 5.0)
		draw_circle(Vector2(4, 0), 4.0, Color.WHITE)
	else:
		# Dardo laser/plasma ad alta visibilità
		draw_line(Vector2(-12, 0), Vector2(8, 0), Color(0.0, 0.94, 1.0, 0.38), 8.0)
		draw_line(Vector2(-10, 0), Vector2(8, 0), Color(0.0, 0.95, 1.0, 0.95), 4.5)
		draw_line(Vector2(-6, 0), Vector2(7, 0), Color(1.0, 1.0, 1.0, 1.0), 2.0)

func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(body): return

	if is_melee_slash and hit_enemies.has(body.get_instance_id()):
		return

	if body.is_in_group("enemies"):
		if is_melee_slash:
			hit_enemies[body.get_instance_id()] = true

		if body.has_method("take_damage"):
			body.take_damage(damage)
			SoundFX.play_hit()

			if hit_particles_scene:
				var hit_fx := hit_particles_scene.instantiate() as Node2D
				if hit_fx:
					hit_fx.global_position = global_position
					get_tree().current_scene.add_child.call_deferred(hit_fx)

		if not is_piercing and not is_melee_slash:
			queue_free()
	elif body.is_in_group("obstacles") or body.is_in_group("loot_crates") or body.is_in_group("walls") or body is StaticBody2D:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			SoundFX.play_hit()

		if hit_particles_scene:
			var hit_fx := hit_particles_scene.instantiate() as Node2D
			if hit_fx:
				hit_fx.global_position = global_position
				get_tree().current_scene.add_child.call_deferred(hit_fx)

		if bounces_left > 0:
			bounces_left -= 1
			direction = -direction.rotated(randf_range(-0.3, 0.3))
			rotation = direction.angle()
		elif not is_piercing and not is_melee_slash:
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
