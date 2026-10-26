extends Area2D

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
var anim_t: float = 0.0
var portal_color: Color = Color(0.0, 0.94, 1.0, 1.0)

func _ready() -> void:
	if sprite: sprite.visible = false
	body_entered.connect(_on_body_entered)
	var w: WorldData = WorldDB.get_selected_world()
	if w:
		portal_color = w.accent_color
	scale = Vector2.ZERO
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.35)

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

func _draw() -> void:
	# Arco Stargate Metallico + Vortice Dimensionale Olografico
	var pulse := 0.75 + sin(anim_t * 6.0) * 0.2
	draw_circle(Vector2.ZERO, 42.0, Color(0.08, 0.10, 0.16, 0.95))
	draw_arc(Vector2.ZERO, 42.0, 0.0, TAU, 32, Color(0.25, 0.32, 0.45, 1.0), 5.0)
	draw_circle(Vector2.ZERO, 36.0, Color(portal_color.r, portal_color.g, portal_color.b, 0.25 * pulse))
	draw_arc(Vector2.ZERO, 34.0, anim_t * 2.5, anim_t * 2.5 + PI * 1.5, 32, Color(portal_color.r, portal_color.g, portal_color.b, 0.95), 3.5)
	draw_arc(Vector2.ZERO, 24.0, -anim_t * 3.5, -anim_t * 3.5 + PI * 1.3, 28, Color(1.0, 1.0, 1.0, 0.85), 2.5)
	draw_circle(Vector2.ZERO, 12.0, Color(1.0, 1.0, 1.0, 0.85 * pulse))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("🚪 Giocatore entra nel portale! Transizione alla stanza successiva...")
		var spawners := get_tree().get_nodes_in_group("spawner")
		if not spawners.is_empty() and spawners[0].has_method("next_room"):
			spawners[0].next_room()
		queue_free()
