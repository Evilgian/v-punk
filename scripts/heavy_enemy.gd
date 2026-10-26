extends CharacterBody2D

@export var speed: float = 50.0
@export var hp: int = 70
var max_hp: int = 70
@export var damage: int = 25
@export var drop_scene: PackedScene = preload("res://scenes/Drop.tscn")
@export var enemy_projectile_scene: PackedScene = preload("res://scenes/EnemyProjectile.tscn")

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var shadow: Sprite2D = get_node_or_null("Shadow") as Sprite2D
var player: Node2D = null
var damage_cooldown: float = 0.0
var bomb_timer: float = 0.0
var anim_t: float = 0.0
var aim_angle: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	max_hp = hp
	if sprite: sprite.visible = false
	if shadow: shadow.visible = false

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0] as Node2D

func _physics_process(delta: float) -> void:
	anim_t += delta
	if damage_cooldown > 0.0:
		damage_cooldown -= delta

	bomb_timer += delta
	if bomb_timer >= 3.5:
		bomb_timer = 0.0
		_launch_parabolic_bomb()

	queue_redraw()

	if not is_instance_valid(player):
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as Node2D
		return

	var dir := (player.global_position - global_position).normalized()
	aim_angle = dir.angle()
	velocity = dir * speed
	move_and_slide()

	var dist := global_position.distance_to(player.global_position)
	if dist <= 50.0 and damage_cooldown <= 0.0:
		if player.has_method("take_damage"):
			player.take_damage(damage)
			damage_cooldown = 1.0

func _draw() -> void:
	var charge_ratio := clampf(bomb_timer / 3.5, 0.0, 1.0)
	CyberModels.draw_heavy_enemy(self, anim_t, charge_ratio, aim_angle)

	if hp < max_hp and max_hp > 0:
		var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
		draw_rect(Rect2(Vector2(-22, -38), Vector2(44, 5)), Color(0.08, 0.08, 0.12, 0.85), true)
		draw_rect(Rect2(Vector2(-22, -38), Vector2(44.0 * ratio, 5)), Color(1.0, 0.55, 0.1, 0.95), true)

func _launch_parabolic_bomb() -> void:
	if not is_instance_valid(player): return
	var scene := get_tree().current_scene
	if not scene: return

	var target_pos := player.global_position
	var bomb_dmg := damage

	var indicator := Node2D.new()
	indicator.global_position = target_pos
	indicator.script = load("res://scripts/bomb_indicator.gd") if ResourceLoader.exists("res://scripts/bomb_indicator.gd") else null
	scene.add_child(indicator)

	# Bomba al plasma procedurale con animazione d'arco parabolico
	var bomb_node := Node2D.new()
	bomb_node.global_position = global_position
	bomb_node.z_index = 12
	bomb_node.draw.connect(func():
		bomb_node.draw_circle(Vector2.ZERO, 14.0, Color(1.0, 0.25, 0.05, 0.35))
		bomb_node.draw_circle(Vector2.ZERO, 9.0, Color(0.2, 0.1, 0.1, 1.0))
		bomb_node.draw_arc(Vector2.ZERO, 9.0, 0, TAU, 16, Color(1.0, 0.35, 0.1, 1.0), 2.5)
		bomb_node.draw_circle(Vector2.ZERO, 4.5, Color(1.0, 0.9, 0.4, 1.0))
	)
	scene.add_child(bomb_node)

	var flight_dur := 0.75
	var tw := scene.create_tween().set_parallel(true)
	tw.tween_property(bomb_node, "global_position", target_pos, flight_dur)

	var tw_arc := scene.create_tween()
	tw_arc.tween_property(bomb_node, "scale", Vector2(1.7, 1.7), flight_dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_arc.tween_property(bomb_node, "scale", Vector2(0.8, 0.8), flight_dur * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tw.finished.connect(func():
		if is_instance_valid(indicator): indicator.queue_free()
		if is_instance_valid(bomb_node): bomb_node.queue_free()

		SoundFX.play_explosion()
		var vfx: Node = scene.get_node_or_null("/root/VFXManager")
		if vfx and vfx.has_method("spawn_explosion"):
			vfx.spawn_explosion(target_pos, Color(1.0, 0.3, 0.1, 1.0))

		var p_nodes := scene.get_tree().get_nodes_in_group("player")
		if not p_nodes.is_empty() and p_nodes[0] is Node2D:
			var p := p_nodes[0] as Node2D
			if p.global_position.distance_to(target_pos) <= 40.0 and p.has_method("take_damage"):
				p.take_damage(bomb_dmg)
	)

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
		die()

func die() -> void:
	Global.total_credits += 25
	Global.quest_kills += 1
	SoundFX.play_explosion()

	var col := get_node_or_null("CollisionShape2D")
	if col: col.set_deferred("disabled", true)

	if enemy_projectile_scene:
		for i in range(8):
			var angle := deg_to_rad(i * 45.0)
			var proj := enemy_projectile_scene.instantiate() as Area2D
			if proj:
				proj.global_position = global_position
				proj.direction = Vector2.RIGHT.rotated(angle)
				proj.rotation = angle
				get_tree().current_scene.add_child.call_deferred(proj)

	if drop_scene:
		for i in range(2):
			var drop := drop_scene.instantiate() as Area2D
			if drop:
				drop.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
				get_tree().current_scene.add_child.call_deferred(drop)

	queue_free()
