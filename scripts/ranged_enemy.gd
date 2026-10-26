extends CharacterBody2D

@export var hp: int = 25
var max_hp: int = 25
@export var speed: float = 105.0
@export var attack_range: float = 340.0
@export var fire_rate: float = 2.0
@export var drop_scene: PackedScene = preload("res://scenes/Drop.tscn")
@export var enemy_projectile_scene: PackedScene = preload("res://scenes/EnemyProjectile.tscn")

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
var is_shooting: bool = false
var shoot_timer: Timer
var aim_dir: Vector2 = Vector2.DOWN
var anim_t: float = 0.0
var accent_col: Color = Color(0.85, 0.30, 1.0, 1.0)

func _ready() -> void:
	add_to_group("enemies")
	max_hp = hp
	if sprite: sprite.visible = false

	var w: WorldData = WorldDB.get_selected_world()
	if w:
		accent_col = w.accent_color

	shoot_timer = Timer.new()
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = false
	shoot_timer.autostart = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

func _physics_process(delta: float) -> void:
	anim_t += delta
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty() or not (players[0] is Node2D):
		return

	var player := players[0] as Node2D
	var distance := global_position.distance_to(player.global_position)
	aim_dir = (player.global_position - global_position).normalized()

	if distance > attack_range:
		velocity = aim_dir * speed
		is_shooting = false
		move_and_slide()
	elif distance < attack_range * 0.45:
		velocity = -aim_dir * (speed * 0.75)
		is_shooting = true
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		is_shooting = true

	queue_redraw()

func _draw() -> void:
	var is_charging := (is_shooting and shoot_timer != null and shoot_timer.time_left <= 0.45)
	if is_charging:
		draw_line(Vector2.ZERO, aim_dir * 180.0, Color(1.0, 0.15, 0.25, 0.50), 1.5)

	CyberModels.draw_ranged_enemy(self, anim_t, accent_col, aim_dir.angle(), is_charging)

	if hp < max_hp and max_hp > 0:
		var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
		draw_rect(Rect2(Vector2(-18, -32), Vector2(36, 4)), Color(0.08, 0.08, 0.12, 0.85), true)
		draw_rect(Rect2(Vector2(-18, -32), Vector2(36.0 * ratio, 4)), Color(0.9, 0.3, 1.0, 0.95), true)

func _on_shoot_timer_timeout() -> void:
	if not is_shooting:
		return

	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty() or not (players[0] is Node2D):
		return

	var player := players[0] as Node2D
	if enemy_projectile_scene:
		var projectile := enemy_projectile_scene.instantiate() as Area2D
		if projectile:
			projectile.global_position = global_position
			var dir := (player.global_position - global_position).normalized()
			projectile.direction = dir
			projectile.look_at(player.global_position)
			get_tree().current_scene.add_child.call_deferred(projectile)

func take_damage(amount: int) -> void:
	if max_hp < hp: max_hp = hp
	hp -= amount
	var is_crit: bool = (randf() <= 0.2)
	var final_damage: int = amount * (2 if is_crit else 1)

	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx:
		if vfx.has_method("spawn_floating_damage"): vfx.spawn_floating_damage(global_position, final_damage, is_crit)
		if vfx.has_method("flash_hit"): vfx.flash_hit(self)

	queue_redraw()
	if hp <= 0:
		_die()

func _die() -> void:
	Global.total_credits += 10
	Global.quest_kills += 1
	SoundFX.play_explosion()

	var col := get_node_or_null("CollisionShape2D")
	if col: col.set_deferred("disabled", true)

	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx and vfx.has_method("spawn_burst"):
		vfx.spawn_burst(global_position, Color(0.85, 0.25, 1.0, 1.0))

	if drop_scene:
		var drop := drop_scene.instantiate() as Node2D
		if drop:
			drop.global_position = global_position
			get_tree().current_scene.add_child.call_deferred(drop)
	queue_free()
