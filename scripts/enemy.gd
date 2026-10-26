extends CharacterBody2D

@export var speed: float = 90.0
@export var hp: int = 30
var max_hp: int = 30
@export var damage: int = 15
@export var drop_scene: PackedScene = preload("res://scenes/Drop.tscn")

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var shadow: Sprite2D = get_node_or_null("Shadow") as Sprite2D
var player: Node2D = null
var damage_cooldown: float = 0.0
var anim_t: float = 0.0
var aim_angle: float = 0.0
var world_id: String = "world_1"
var unit_tint: Color = Color(1.0, 0.35, 0.35, 1.0)

func _ready() -> void:
	add_to_group("enemies")
	max_hp = hp
	anim_t = randf() * TAU
	if sprite: sprite.visible = false
	if shadow: shadow.visible = false

	var w: WorldData = WorldDB.get_selected_world()
	if w:
		world_id = w.id
		unit_tint = w.accent_color.lerp(Color(1.0, 0.22, 0.30, 1.0), 0.35)

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0] as Node2D

func _physics_process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

	if damage_cooldown > 0.0:
		damage_cooldown -= delta

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
	if dist <= 42.0 and damage_cooldown <= 0.0:
		if player.has_method("take_damage"):
			player.take_damage(damage)
			damage_cooldown = 1.0

func _draw() -> void:
	CyberModels.draw_melee_enemy(self, world_id, anim_t, unit_tint, aim_angle)

	if hp < max_hp and max_hp > 0:
		var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
		draw_rect(Rect2(Vector2(-18, -32), Vector2(36, 4)), Color(0.08, 0.08, 0.12, 0.85), true)
		draw_rect(Rect2(Vector2(-18, -32), Vector2(36.0 * ratio, 4)), Color(1.0, 0.25, 0.3, 0.95), true)

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
	Global.quest_kills += 1
	SoundFX.play_explosion()

	var col := get_node_or_null("CollisionShape2D")
	if col: col.set_deferred("disabled", true)

	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx and vfx.has_method("spawn_burst"):
		vfx.spawn_burst(global_position, unit_tint)

	if drop_scene:
		var drop := drop_scene.instantiate() as Area2D
		if drop:
			drop.global_position = global_position
			if "drop_type" in drop:
				var r := randf()
				if r < 0.05:
					drop.drop_type = "gear_drop" # 5% Drop Armatura / Anello / Pet / Arma
				elif r < 0.20:
					drop.drop_type = "upgrade_scroll" # 15% Nucleo Potenziamento ⚙️
				elif r < 0.28:
					drop.drop_type = "heal"
			get_tree().current_scene.add_child.call_deferred(drop)
	queue_free()
