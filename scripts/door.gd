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
	tw.tween_property(self, "scale", Vector2.ONE, 0.38)

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

func _draw() -> void:
	# Portale Stargate 3D Verticale incastonato nella Parete Nord!
	var pulse: float = 0.78 + sin(anim_t * 6.0) * 0.22

	# 1. Tappeto Luminoso / Pedana 3D Ellittica a Pavimento
	draw_set_transform(Vector2(0, 10), 0.0, Vector2(1.0, 0.44))
	draw_circle(Vector2.ZERO, 68.0, Color(portal_color.r, portal_color.g, portal_color.b, 0.18 * pulse))
	draw_circle(Vector2.ZERO, 52.0, Color(0.08, 0.11, 0.20, 0.95))
	draw_arc(Vector2.ZERO, 52.0, 0.0, TAU, 36, Color(0.32, 0.40, 0.58, 1.0), 5.0)
	draw_arc(Vector2.ZERO, 44.0, anim_t * 2.5, anim_t * 2.5 + PI * 1.6, 32, portal_color, 3.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 2. Vortice Dimensionale Verticale 3D dentro l'Arco (Ellissi verticali concentriche)
	draw_set_transform(Vector2(0, -30), 0.0, Vector2(0.86, 1.08))
	draw_circle(Vector2.ZERO, 42.0, Color(0.02, 0.05, 0.12, 0.92))
	draw_circle(Vector2.ZERO, 38.0, Color(portal_color.r, portal_color.g, portal_color.b, 0.34 * pulse))
	draw_arc(Vector2.ZERO, 36.0, anim_t * 3.0, anim_t * 3.0 + PI * 1.5, 32, portal_color, 4.2)
	draw_arc(Vector2.ZERO, 25.0, -anim_t * 4.2, -anim_t * 4.2 + PI * 1.4, 28, Color(1.0, 1.0, 1.0, 0.92), 3.0)
	draw_circle(Vector2.ZERO, 13.0, Color(1.0, 1.0, 1.0, 0.90 * pulse))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 3. Colonne Corazzate 3D Sinistra e Destra + Architrave Superiore Stargate
	for side in [-1.0, 1.0]:
		var px: float = side * 44.0
		draw_rect(Rect2(Vector2(px - 9.0, -72.0), Vector2(18.0, 82.0)), Color(0.16, 0.22, 0.36, 1.0), true)
		draw_rect(Rect2(Vector2(px - 9.0, -72.0), Vector2(18.0, 82.0)), Color(0.32, 0.42, 0.62, 1.0), false, 2.0)
		draw_line(Vector2(px, -66.0), Vector2(px, 4.0), portal_color, 3.5)
		draw_circle(Vector2(px, -68.0), 5.0, Color.WHITE)

	# Architrave 3D Superiore con Chiave di Volta Luminosa
	draw_colored_polygon(PackedVector2Array([
		Vector2(-56, -70), Vector2(-38, -86), Vector2(38, -86), Vector2(56, -70)
	]), Color(0.20, 0.27, 0.44, 1.0))
	draw_polyline(PackedVector2Array([
		Vector2(-56, -70), Vector2(-38, -86), Vector2(38, -86), Vector2(56, -70), Vector2(-56, -70)
	]), portal_color, 2.5)
	draw_circle(Vector2(0, -78), 7.5, portal_color)
	draw_circle(Vector2(0, -78), 3.8, Color.WHITE)

	# 4. Fascio Volumetrico d'Ingresso sul Pavimento + Freccia Invito
	var arrow_bob: float = sin(anim_t * 7.0) * 4.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(-34, 8), Vector2(34, 8), Vector2(54, 48), Vector2(-54, 48)
	]), Color(portal_color.r, portal_color.g, portal_color.b, 0.14 * pulse))
	draw_polyline(PackedVector2Array([
		Vector2(-12, 32 + arrow_bob), Vector2(0, 20 + arrow_bob), Vector2(12, 32 + arrow_bob)
	]), Color(1.0, 1.0, 1.0, 0.90), 3.0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("🚪 Giocatore entra nel portale! Transizione alla stanza successiva...")
		var spawners := get_tree().get_nodes_in_group("spawner")
		if not spawners.is_empty() and spawners[0].has_method("next_room"):
			spawners[0].next_room()
		queue_free()
