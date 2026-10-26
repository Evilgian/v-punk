extends Area2D

@export var speed: float = 400.0
@export var damage: int = 5
var direction: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D

func _ready() -> void:
	add_to_group("projectiles")
	if sprite:
		sprite.visible = false # Usiamo la sfera al plasma brillante in _draw()
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	# Disegna proiettile brillante sferico con alone luminoso (Glow Trail)
	draw_line(-direction.normalized() * 12.0, Vector2.ZERO, Color(1.0, 0.25, 0.15, 0.45), 6.0)
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.2, 0.2, 0.35))
	draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.3, 0.1, 0.88))
	draw_circle(Vector2.ZERO, 3.2, Color(1.0, 0.92, 0.55, 1.0))

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(body): return
	if body.is_in_group("enemies"):
		return

	# Distruzione del proiettile nemico impattando sugli ostacoli o pareti
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
