extends Area2D

@export var speed: float = 400.0
@export var damage: int = 5
var direction: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D

func _ready() -> void:
	add_to_group("projectiles")
	if sprite:
		sprite.visible = false
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	# Ombra ellittica 2.5D a terra (sotto la sfera al plasma in volo -> vera altezza 3D!)
	var ground_offset := Vector2(0, 18).rotated(-rotation)
	draw_circle(ground_offset, 6.5, Color(0, 0, 0, 0.36))

	# Sfera al plasma 3D nemica con scia energetica e nucleo speculare
	var back_dir := (-direction.normalized()).rotated(-rotation) if direction.length() > 0.01 else Vector2.LEFT
	draw_line(back_dir * 20.0, Vector2.ZERO, Color(1.0, 0.18, 0.25, 0.45), 8.0)
	draw_circle(Vector2.ZERO, 13.0, Color(1.0, 0.12, 0.25, 0.34))
	draw_circle(Vector2.ZERO, 8.0, Color(0.95, 0.20, 0.12, 0.96))
	draw_arc(Vector2.ZERO, 8.0, 0.0, TAU, 16, Color(1.0, 0.65, 0.2, 0.95), 1.8)
	draw_circle(Vector2(-1.5, -1.5).rotated(-rotation), 3.8, Color(1.0, 0.95, 0.72, 1.0))

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(body): return
	if body.is_in_group("enemies"):
		return

	if body.is_in_group("obstacles") or body.is_in_group("walls") or body is StaticBody2D:
		queue_free()
		return

	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif not body.is_in_group("player"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
