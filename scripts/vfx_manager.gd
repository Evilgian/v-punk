extends Node

func spawn_floating_damage(global_pos: Vector2, amount: int, is_crit: bool = false) -> void:
	var scene := get_tree().current_scene
	if not scene: return

	var lbl := Label.new()
	lbl.text = ("★ " + str(amount) + "!") if is_crit else str(amount)
	lbl.global_position = global_pos + Vector2(randf_range(-18, 18), randf_range(-20, -8))
	lbl.z_index = 20
	var f_bold := CyberTheme.get_cyber_font(true)
	if f_bold:
		lbl.add_theme_font_override("font", f_bold)

	if is_crit:
		lbl.add_theme_font_size_override("font_size", 23)
		lbl.add_theme_color_override("font_color", CyberTheme.COL_YELLOW)
		lbl.add_theme_color_override("font_outline_color", Color(0.22, 0.02, 0.06, 0.98))
		lbl.add_theme_constant_override("outline_size", 4)
	else:
		lbl.add_theme_font_size_override("font_size", 17)
		lbl.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
		lbl.add_theme_color_override("font_outline_color", Color(0.03, 0.05, 0.10, 0.96))
		lbl.add_theme_constant_override("outline_size", 3)

	scene.add_child(lbl)

	lbl.scale = Vector2(0.55, 0.55)
	lbl.pivot_offset = Vector2(24, 12)
	var tw := scene.create_tween().set_parallel(true)
	tw.tween_property(lbl, "global_position", lbl.global_position + Vector2(0, -46), 0.56).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "scale", Vector2(1.22 if is_crit else 1.0, 1.22 if is_crit else 1.0), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.56).set_delay(0.18)
	tw.chain().tween_callback(lbl.queue_free)

func spawn_floating_text(global_pos: Vector2, text_str: String, col: Color = Color(1.0, 0.88, 0.15, 1.0)) -> void:
	var scene := get_tree().current_scene
	if not scene: return

	var lbl := Label.new()
	lbl.text = text_str
	var f_bold := CyberTheme.get_cyber_font(true)
	if f_bold:
		lbl.add_theme_font_override("font", f_bold)
	var clamped_x: float = clampf(global_pos.x - 110.0, 24.0, 480.0)
	lbl.global_position = Vector2(clamped_x, maxf(90.0, global_pos.y - 28.0))
	lbl.custom_minimum_size = Vector2(220, 0)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.z_index = 25
	lbl.add_theme_font_size_override("font_size", 17)
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_color_override("font_outline_color", Color(0.03, 0.05, 0.12, 0.98))
	lbl.add_theme_constant_override("outline_size", 4)
	scene.add_child(lbl)

	var tw := scene.create_tween().set_parallel(true)
	tw.tween_property(lbl, "global_position", lbl.global_position + Vector2(0, -52), 1.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 1.05).set_delay(0.45)
	tw.chain().tween_callback(lbl.queue_free)

func flash_hit(node: CanvasItem) -> void:
	if not is_instance_valid(node): return
	var orig_mod: Color = node.get_meta("base_modulate", Color.WHITE)
	node.modulate = Color(2.6, 2.6, 2.8, 1.0)
	await get_tree().create_timer(0.07).timeout
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
	particles.lifetime = 0.38
	particles.explosiveness = 0.92
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 65.0
	particles.initial_velocity_max = 150.0
	particles.scale_amount_min = 3.2
	particles.scale_amount_max = 6.2
	particles.color = color

	scene.add_child(particles)
	await get_tree().create_timer(0.45).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func spawn_explosion(global_pos: Vector2, color: Color = Color(1.0, 0.35, 0.1, 1.0)) -> void:
	var scene := get_tree().current_scene
	if not scene: return

	spawn_burst(global_pos, color)

	var ring := Node2D.new()
	ring.global_position = global_pos
	ring.z_index = 15
	ring.set_meta("ring_radius", 8.0)
	ring.set_meta("ring_alpha", 0.95)
	ring.set_meta("ring_color", color)
	ring.draw.connect(func():
		var r: float = float(ring.get_meta("ring_radius", 10.0))
		var a: float = float(ring.get_meta("ring_alpha", 0.5))
		var c: Color = ring.get_meta("ring_color", color)
		ring.draw_circle(Vector2.ZERO, r * 0.72, Color(c.r, c.g, c.b, a * 0.32))
		ring.draw_arc(Vector2.ZERO, r, 0.0, TAU, 36, Color(1.0, 0.92, 0.65, a), 3.6)
	)
	scene.add_child(ring)

	var tw := scene.create_tween()
	tw.tween_method(func(val: float):
		if is_instance_valid(ring):
			ring.set_meta("ring_radius", lerpf(10.0, 62.0, val))
			ring.set_meta("ring_alpha", lerpf(0.95, 0.0, val))
			ring.queue_redraw()
	, 0.0, 1.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		if is_instance_valid(ring):
			ring.queue_free()
	)
