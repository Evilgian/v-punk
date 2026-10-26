extends Node

func spawn_floating_damage(global_pos: Vector2, amount: int, is_crit: bool = false) -> void:
	var scene := get_tree().current_scene
	if not scene: return

	var lbl := Label.new()
	lbl.text = ("💥 " if is_crit else "") + str(amount)
	lbl.global_position = global_pos + Vector2(randf_range(-16, 16), randf_range(-14, -4))
	lbl.z_index = 20

	if is_crit:
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.25, 0.35, 1.0))
		lbl.add_theme_color_override("font_outline_color", Color(0.15, 0.0, 0.05, 1.0))
		lbl.add_theme_constant_override("outline_size", 4)
	else:
		lbl.add_theme_font_size_override("font_size", 15)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.4, 1.0))
		lbl.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.15, 1.0))
		lbl.add_theme_constant_override("outline_size", 3)

	scene.add_child(lbl)

	lbl.scale = Vector2(0.5, 0.5)
	lbl.pivot_offset = Vector2(20, 10)
	var tw := scene.create_tween().set_parallel(true)
	tw.tween_property(lbl, "global_position", lbl.global_position + Vector2(0, -48), 0.60).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "scale", Vector2(1.25 if is_crit else 1.0, 1.25 if is_crit else 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.60).set_delay(0.18)

	tw.chain().tween_callback(lbl.queue_free)

func flash_hit(node: CanvasItem) -> void:
	if not is_instance_valid(node): return
	var orig_mod: Color = node.get_meta("base_modulate", Color.WHITE)
	node.modulate = Color(3.2, 3.2, 3.2, 1.0)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(node):
		node.modulate = orig_mod

func spawn_burst(global_pos: Vector2, color: Color = Color(0, 0.94, 1, 1)) -> void:
	var scene := get_tree().current_scene
	if not scene: return

	var particles := CPUParticles2D.new()
	particles.global_position = global_pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 16
	particles.lifetime = 0.4
	particles.explosiveness = 0.92
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 65.0
	particles.initial_velocity_max = 150.0
	particles.scale_amount_min = 3.5
	particles.scale_amount_max = 6.5
	particles.color = color

	scene.add_child(particles)
	await get_tree().create_timer(0.48).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func spawn_explosion(global_pos: Vector2, color: Color = Color(1.0, 0.35, 0.1, 1.0)) -> void:
	var scene := get_tree().current_scene
	if not scene: return

	spawn_burst(global_pos, color)

	var ring := Node2D.new()
	ring.global_position = global_pos
	ring.z_index = 15
	ring.set_meta("ring_radius", 6.0)
	ring.set_meta("ring_alpha", 0.95)
	ring.set_meta("ring_color", color)
	ring.draw.connect(func():
		var r: float = float(ring.get_meta("ring_radius", 10.0))
		var a: float = float(ring.get_meta("ring_alpha", 0.5))
		var c: Color = ring.get_meta("ring_color", color)
		ring.draw_circle(Vector2.ZERO, r * 0.7, Color(c.r, c.g, c.b, a * 0.35))
		ring.draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(1.0, 0.9, 0.6, a), 3.5)
	)
	scene.add_child(ring)

	var tw := scene.create_tween()
	tw.tween_method(func(val: float):
		if is_instance_valid(ring):
			ring.set_meta("ring_radius", lerpf(8.0, 44.0, val))
			ring.set_meta("ring_alpha", lerpf(0.95, 0.0, val))
			ring.queue_redraw()
	, 0.0, 1.0, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		if is_instance_valid(ring):
			ring.queue_free()
	)
