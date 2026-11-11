class_name CyberModels
extends RefCounted

# ==============================================================================
# RENDERING 2.5D "ARCHERO-STYLE" v6.0:
# - Eroe 3D Articolato a 2 Snodi per Gamba (Coscia + Stinco/Stivale 3D senza
#   cosce statiche dietro) + Busto 3D tagliato in vita + Braccia Corazzate 3D
#   con Impugnatura Tattica Naturale (calcio al petto/spalla, mani sul grip)
# - Locomozione Bipede Articolata per Nemici Melee, Heavy e Boss (gambe
#   indipendenti animate con draw_texture_rect_region + oscillazione busto)
# - 8 Varianti Bioma per Nemici Melee, Ranged, Heavy, Ostacoli e 8 Boss 3D Unici
# - Supporto Campioni Élite (Corona Dorata + Aura Esagonale)
# ==============================================================================

const PERSPECTIVE_Y: float = 0.42


static func draw_ground_shadow(c: CanvasItem, center: Vector2, radius: float, strength: float = 0.5) -> void:
	c.draw_set_transform(center, 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_circle(Vector2.ZERO, radius * 1.25, Color(0, 0, 0, strength * 0.25))
	c.draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, strength * 0.45))
	c.draw_circle(Vector2.ZERO, radius * 0.65, Color(0, 0, 0, strength * 0.55))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func draw_ground_ring(c: CanvasItem, center: Vector2, radius: float, col: Color, anim_t: float, width: float = 2.4) -> void:
	c.draw_set_transform(center, 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_circle(Vector2.ZERO, radius, Color(col.r, col.g, col.b, 0.10))
	c.draw_arc(Vector2.ZERO, radius, anim_t * 2.2, anim_t * 2.2 + PI * 1.35, 32, Color(col.r, col.g, col.b, 0.90), width)
	c.draw_arc(Vector2.ZERO, radius, anim_t * 2.2 + PI * 1.5, anim_t * 2.2 + PI * 1.85, 12, Color(1, 1, 1, 0.7), width * 0.8)
	c.draw_arc(Vector2.ZERO, radius * 0.72, -anim_t * 1.6, -anim_t * 1.6 + PI, 20, Color(col.r, col.g, col.b, 0.45), 1.4)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _draw_part(c: CanvasItem, tex: Texture2D, pivot: Vector2, rot: float, local_rect: Rect2, flip_h: bool = false, modulate: Color = Color.WHITE) -> void:
	if not tex:
		return
	var sx: float = -1.0 if flip_h else 1.0
	c.draw_set_transform(pivot, rot, Vector2(sx, 1.0))
	c.draw_texture_rect(tex, local_rect, false, modulate)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _draw_grounded_sprite(c: CanvasItem, tex: Texture2D, feet: Vector2, height: float, rot: float, flip_h: bool, squash: Vector2 = Vector2.ONE, modulate: Color = Color.WHITE) -> void:
	if not tex:
		return
	var w: float = height * float(tex.get_width()) / float(tex.get_height())
	var sx: float = -squash.x if flip_h else squash.x
	c.draw_set_transform_matrix(Transform2D(rot, Vector2(sx, squash.y), 0.0, feet))
	c.draw_texture_rect(tex, Rect2(Vector2(-w * 0.5, -height), Vector2(w, height)), false, modulate)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _draw_biped_animated_sprite(
	c: CanvasItem,
	tex: Texture2D,
	feet: Vector2,
	height: float,
	stride_phase: float,
	stride_amp: float,
	lift_amp: float,
	torso_rot: float,
	flip_h: bool,
	modulate: Color = Color.WHITE
) -> void:
	if not tex:
		return
	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())
	if tw <= 1.0 or th <= 1.0:
		return
	var w: float = height * (tw / th)
	var sx: float = -1.0 if flip_h else 1.0
	var s_wave: float = sin(stride_phase)
	var c_wave: float = absf(cos(stride_phase))
	var hip_y: float = feet.y - height * 0.45 - c_wave * lift_amp * 0.35

	# Regioni UV dello sprite 3D: Gamba Sinistra, Gamba Destra e Busto Superiore
	var src_l_leg := Rect2(0.0, th * 0.52, tw * 0.50, th * 0.48)
	var src_r_leg := Rect2(tw * 0.50, th * 0.52, tw * 0.50, th * 0.48)
	var src_upper := Rect2(0.0, 0.0, tw, th * 0.58)

	var leg_w: float = w * 0.50
	var leg_h: float = height * 0.48
	var upper_h: float = height * 0.58

	var l_lift: float = -maxf(0.0, s_wave) * lift_amp
	var r_lift: float = -maxf(0.0, -s_wave) * lift_amp
	var l_rot: float = s_wave * stride_amp
	var r_rot: float = -s_wave * stride_amp

	var l_hip := Vector2(feet.x - sx * w * 0.16, hip_y + l_lift)
	var r_hip := Vector2(feet.x + sx * w * 0.16, hip_y + r_lift)
	var l_mod := modulate if s_wave >= 0.0 else Color(modulate.r * 0.82, modulate.g * 0.84, modulate.b * 0.88, modulate.a)
	var r_mod := modulate if s_wave <= 0.0 else Color(modulate.r * 0.82, modulate.g * 0.84, modulate.b * 0.88, modulate.a)

	# Disegna prima la gamba arretrata e poi quella avanzata per corretta profondità
	if s_wave >= 0.0:
		c.draw_set_transform(r_hip, r_rot, Vector2(sx, 1.0))
		c.draw_texture_rect_region(tex, Rect2(Vector2(-leg_w * 0.35, -leg_h * 0.08), Vector2(leg_w, leg_h)), src_r_leg, r_mod)
		c.draw_set_transform(l_hip, l_rot, Vector2(sx, 1.0))
		c.draw_texture_rect_region(tex, Rect2(Vector2(-leg_w * 0.65, -leg_h * 0.08), Vector2(leg_w, leg_h)), src_l_leg, l_mod)
	else:
		c.draw_set_transform(l_hip, l_rot, Vector2(sx, 1.0))
		c.draw_texture_rect_region(tex, Rect2(Vector2(-leg_w * 0.65, -leg_h * 0.08), Vector2(leg_w, leg_h)), src_l_leg, l_mod)
		c.draw_set_transform(r_hip, r_rot, Vector2(sx, 1.0))
		c.draw_texture_rect_region(tex, Rect2(Vector2(-leg_w * 0.35, -leg_h * 0.08), Vector2(leg_w, leg_h)), src_r_leg, r_mod)

	# Busto + Testa con oscillazione dinamica e respirazione corazzata
	var waist_pos := Vector2(feet.x, hip_y + height * 0.05)
	c.draw_set_transform(waist_pos, torso_rot, Vector2(sx, 1.0))
	c.draw_texture_rect_region(tex, Rect2(Vector2(-w * 0.50, -upper_h * 0.92), Vector2(w, upper_h)), src_upper, modulate)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _get_world_profile(world_id: String) -> Dictionary:
	match world_id:
		"world_1":
			return {"armor": Color(0.84, 1.08, 0.90), "glow": Color(0.12, 1.0, 0.56), "sec": Color(0.08, 0.48, 0.28), "style": "bio"}
		"world_2":
			return {"armor": Color(1.10, 0.94, 0.70), "glow": Color(1.0, 0.76, 0.14), "sec": Color(0.60, 0.38, 0.10), "style": "desert"}
		"world_3":
			return {"armor": Color(0.96, 0.84, 1.12), "glow": Color(1.0, 0.16, 0.70), "sec": Color(0.0, 0.94, 1.0), "style": "neon"}
		"world_4":
			return {"armor": Color(0.80, 0.98, 1.14), "glow": Color(0.25, 0.94, 1.0), "sec": Color(0.68, 0.96, 1.0), "style": "cryo"}
		"world_5":
			return {"armor": Color(1.12, 0.80, 0.70), "glow": Color(1.0, 0.40, 0.08), "sec": Color(1.0, 0.80, 0.16), "style": "magma"}
		"world_6":
			return {"armor": Color(0.86, 1.12, 0.70), "glow": Color(0.58, 1.0, 0.14), "sec": Color(0.24, 0.58, 0.14), "style": "toxic"}
		"world_7":
			return {"armor": Color(1.10, 0.98, 0.82), "glow": Color(1.0, 0.86, 0.28), "sec": Color(0.74, 0.34, 1.0), "style": "astral"}
		"world_8":
			return {"armor": Color(0.88, 0.76, 1.14), "glow": Color(1.0, 0.14, 0.48), "sec": Color(0.58, 0.16, 1.0), "style": "void"}
	return {"armor": Color.WHITE, "glow": Color(1.0, 0.22, 0.32), "sec": Color(0.0, 0.92, 1.0), "style": "default"}


static func _draw_elite_crown(c: CanvasItem, feet: Vector2, top_y: float, radius: float, anim_t: float) -> void:
	var pulse: float = 0.75 + 0.25 * sin(anim_t * 6.5)
	draw_ground_ring(c, feet, radius * 1.15, Color(1.0, 0.84, 0.14, 0.95 * pulse), -anim_t * 1.4, 3.0)
	var cy: float = top_y - 12.0 + sin(anim_t * 5.0) * 2.5
	var crown := PackedVector2Array([
		Vector2(-11.0, cy + 5.0),
		Vector2(-13.0, cy - 5.0),
		Vector2(-5.0, cy + 1.0),
		Vector2(0.0, cy - 8.5),
		Vector2(5.0, cy + 1.0),
		Vector2(13.0, cy - 5.0),
		Vector2(11.0, cy + 5.0)
	])
	c.draw_colored_polygon(crown, Color(1.0, 0.82, 0.12, 0.96))
	c.draw_polyline(crown, Color(1.0, 0.98, 0.75, 1.0), 1.6)


# ==============================================================================
# 1. EROE: CYBER-RONIN EXO-SLAYER 3D CON GAMBE A 2 SNODI E IMPUGNATURA REALISTICA
# ==============================================================================
static func draw_hero(c: CanvasItem, weapon_id: String, anim_t: float, is_moving: bool, is_shooting: bool, aim_angle: float, move_vec: Vector2 = Vector2.ZERO, body_h: float = 68.0) -> void:
	var aura := Global.get_player_accent_color()
	var sin_a: float = sin(aim_angle)
	var cos_a: float = cos(aim_angle)
	var k: float = body_h / 68.0

	var pose: String = "side"
	if sin_a < -0.48:
		pose = "back"
	elif sin_a > 0.58:
		pose = "front"
	var face_left: bool = cos_a < -0.05

	var mv: Vector2 = move_vec.limit_length(1.0) if is_moving else Vector2.ZERO
	if is_moving and mv.length_squared() < 0.01:
		mv = Vector2(cos_a, sin_a)
	var move_ratio: float = clampf(mv.length(), 0.0, 1.0) if is_moving else 0.0

	# Ciclo di corsa biomeccanico a 2 fasi (anca + ginocchio)
	var stride_phase: float = anim_t * 12.8
	var stride_s: float = sin(stride_phase) * move_ratio
	var stride_c: float = absf(cos(stride_phase)) * move_ratio
	var bob: float = (-stride_c * 2.8 + sin(anim_t * 3.0) * (1.0 - move_ratio) * 1.0) * k
	var recoil_phase: float = fmod(anim_t * 11.5, 1.0) if is_shooting else 1.0
	var recoil_kick: float = clampf(1.0 - recoil_phase * 2.6, 0.0, 1.0) if is_shooting else 0.0
	var body_shift := Vector2(mv.x * 1.8 * k, 0.0) - Vector2(cos_a, 0.0) * (1.6 * recoil_kick * k)
	var feet := Vector2(body_shift.x, 18.0 * k)

	# Ombra dinamica, anello direzionale a terra e freccia di mira
	draw_ground_shadow(c, Vector2(body_shift.x * 0.4, feet.y), 19.0 * k, 0.62)
	draw_ground_ring(c, Vector2(0, feet.y), 27.0 * k, aura, anim_t, (3.0 if is_shooting else 2.4))
	var dir_2d := Vector2(cos_a, sin_a * PERSPECTIVE_Y)
	var tip_p := Vector2(0, feet.y) + dir_2d * 34.0 * k
	var side_p := Vector2(-sin_a, cos_a * PERSPECTIVE_Y) * 6.0 * k
	c.draw_colored_polygon(PackedVector2Array([
		tip_p,
		Vector2(0, feet.y) + dir_2d * 24.0 * k + side_p,
		Vector2(0, feet.y) + dir_2d * 24.0 * k - side_p
	]), Color(aura.r, aura.g, aura.b, 0.95))

	if is_moving:
		for t_i in range(3):
			var trail_off := -Vector2(mv.x, mv.y * 0.65) * (10.0 + float(t_i) * 8.0) * k
			c.draw_circle(Vector2(0, feet.y - 3.0) + trail_off, (4.4 - float(t_i) * 1.2) * k, Color(aura.r, aura.g, aura.b, 0.35 - float(t_i) * 0.09))

	# Mirando a Nord l'arma è impugnata davanti al petto -> dietro la schiena rispetto alla camera
	if pose == "back":
		_draw_hero_weapon_and_arms(c, weapon_id, anim_t, is_shooting, recoil_kick, aim_angle, pose, face_left, feet, bob, k, aura)

	_draw_hero_articulated_body(c, pose, face_left, feet, body_h, bob, stride_phase, stride_s, move_ratio, mv, k, aura, anim_t)

	if pose != "back":
		_draw_hero_weapon_and_arms(c, weapon_id, anim_t, is_shooting, recoil_kick, aim_angle, pose, face_left, feet, bob, k, aura)


static func _draw_hero_2joint_leg(
	c: CanvasItem,
	thigh_tex: Texture2D,
	shin_tex: Texture2D,
	hip_pos: Vector2,
	thigh_rot: float,
	shin_rot: float,
	thigh_w: float,
	thigh_h: float,
	shin_w: float,
	shin_h: float,
	flip_h: bool,
	modulate: Color
) -> void:
	# 1. Coscia (Anca -> Ginocchio)
	_draw_part(c, thigh_tex, hip_pos, thigh_rot, Rect2(Vector2(-thigh_w * 0.50, -thigh_h * 0.14), Vector2(thigh_w, thigh_h)), flip_h, modulate)
	# 2. Posizione del ginocchio articolato e Stinco + Stivale (Ginocchio -> Piede)
	var knee_pos: Vector2 = hip_pos + Vector2(0.0, thigh_h * 0.74).rotated(thigh_rot)
	_draw_part(c, shin_tex, knee_pos, shin_rot, Rect2(Vector2(-shin_w * 0.50, -shin_h * 0.14), Vector2(shin_w, shin_h)), flip_h, modulate)


static func _draw_hero_articulated_body(
	c: CanvasItem,
	pose: String,
	face_left: bool,
	feet: Vector2,
	_body_h: float,
	bob: float,
	stride_phase: float,
	stride_s: float,
	move_ratio: float,
	mv: Vector2,
	k: float,
	aura: Color,
	anim_t: float
) -> void:
	var upper_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_upper_" + pose + ".png")
	var thigh_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_thigh_" + pose + ".png")
	var shin_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_shin_" + pose + ".png")
	if not upper_tex or not thigh_tex or not shin_tex:
		return

	var hip_y: float = feet.y - 28.5 * k + bob
	var face_sign: float = -1.0 if face_left else 1.0

	if pose == "side":
		# Locomozione biomeccanica laterale a 2 snodi (Anca + Ginocchio che flette sempre all'indietro)
		var thigh_w: float = 17.5 * k
		var thigh_h: float = 18.5 * k
		var shin_w: float = 16.5 * k
		var shin_h: float = 19.5 * k

		# Fase gamba anteriore (stride_phase) e gamba posteriore (stride_phase + PI)
		var f_sin: float = sin(stride_phase) * move_ratio
		var f_cos: float = cos(stride_phase) * move_ratio
		var r_sin: float = -f_sin
		var r_cos: float = -f_cos

		# In Godot 2D: Vector2(0, 1).rotated(rot) ha x = -sin(rot).
		# Quindi per portare la coscia in avanti (nella direzione face_sign), thigh_rot ha segno -face_sign * f_sin.
		# Il ginocchio umano si piega SEMPRE all'indietro (+face_sign * knee_bend).
		var f_thigh_rot: float = -f_sin * 0.48 * face_sign
		var f_knee_bend: float = (0.08 + maxf(0.0, -f_cos) * 0.58) * move_ratio
		var f_shin_rot: float = f_thigh_rot + f_knee_bend * face_sign

		var r_thigh_rot: float = -r_sin * 0.48 * face_sign
		var r_knee_bend: float = (0.08 + maxf(0.0, -r_cos) * 0.58) * move_ratio
		var r_shin_rot: float = r_thigh_rot + r_knee_bend * face_sign

		var rear_hip := Vector2(feet.x - face_sign * 2.8 * k, hip_y - maxf(0.0, r_sin) * 2.5 * k)
		var front_hip := Vector2(feet.x + face_sign * 2.2 * k, hip_y - maxf(0.0, f_sin) * 2.5 * k)

		# 1. Gamba posteriore (ombreggiata per profondità 3D)
		_draw_hero_2joint_leg(c, thigh_tex, shin_tex, rear_hip, r_thigh_rot, r_shin_rot, thigh_w, thigh_h, shin_w, shin_h, face_left, Color(0.72, 0.76, 0.86, 1.0))
		# 2. Gamba anteriore
		_draw_hero_2joint_leg(c, thigh_tex, shin_tex, front_hip, f_thigh_rot, f_shin_rot, thigh_w, thigh_h, shin_w, shin_h, face_left, Color.WHITE)

		# 3. Busto + Casco 3D (tagliato esattamente alla cintura, senza cosce statiche dietro)
		var uw: float = 44.0 * k
		var uh: float = 46.0 * k
		var lean_rot: float = clampf(mv.x * 0.11, -0.12, 0.12) if move_ratio > 0.05 else sin(anim_t * 2.5) * 0.015
		var waist_pivot := Vector2(feet.x, hip_y + 3.0 * k)
		_draw_part(c, upper_tex, waist_pivot, lean_rot, Rect2(Vector2(-uw * 0.48, -uh * 0.90), Vector2(uw, uh)), face_left, Color.WHITE)
	else:
		# Vista Frontale / Spalle: 2 gambe a 2 snodi con sollevamento ginocchio e passo prospettico
		var thigh_w: float = 16.5 * k
		var thigh_h: float = 18.0 * k
		var shin_w: float = 15.5 * k
		var shin_h: float = 19.0 * k

		var l_lift: float = -maxf(0.0, stride_s) * 5.5 * k
		var r_lift: float = -maxf(0.0, -stride_s) * 5.5 * k
		var l_scale: float = 1.0 + stride_s * 0.07
		var r_scale: float = 1.0 - stride_s * 0.07
		var l_thigh_rot: float = stride_s * 0.08
		var r_thigh_rot: float = stride_s * 0.08
		var l_shin_rot: float = -stride_s * 0.05
		var r_shin_rot: float = -stride_s * 0.05

		var hip_l := Vector2(feet.x - 8.2 * k, hip_y + l_lift)
		var hip_r := Vector2(feet.x + 8.2 * k, hip_y + r_lift)
		var l_mod := Color.WHITE if stride_s >= 0.0 else Color(0.78, 0.82, 0.90, 1.0)
		var r_mod := Color.WHITE if stride_s <= 0.0 else Color(0.78, 0.82, 0.90, 1.0)

		_draw_hero_2joint_leg(c, thigh_tex, shin_tex, hip_l, l_thigh_rot, l_shin_rot, thigh_w * l_scale, thigh_h * l_scale, shin_w * l_scale, shin_h * l_scale, false, l_mod)
		_draw_hero_2joint_leg(c, thigh_tex, shin_tex, hip_r, r_thigh_rot, r_shin_rot, thigh_w * r_scale, thigh_h * r_scale, shin_w * r_scale, shin_h * r_scale, true, r_mod)

		# Busto + Casco 3D con bilanciamento spalle
		var uw: float = 46.0 * k
		var uh: float = 46.0 * k
		var sway_rot: float = clampf(mv.x * 0.07, -0.08, 0.08) - stride_s * 0.035
		var waist_pivot := Vector2(feet.x, hip_y + 3.0 * k)
		_draw_part(c, upper_tex, waist_pivot, sway_rot, Rect2(Vector2(-uw * 0.50, -uh * 0.90), Vector2(uw, uh)), false, Color.WHITE)

	# Dettaglio visiera luminosa o propulsori dorsali
	if pose != "back":
		var head_p := Vector2(feet.x + face_sign * (2.5 * k if pose == "side" else 0.0), hip_y - 31.0 * k)
		c.draw_circle(head_p, 5.2 * k, Color(aura.r, aura.g, aura.b, 0.24))
		c.draw_circle(head_p, 2.0 * k, Color(1, 1, 1, 0.52))
	else:
		var back_p := Vector2(feet.x, hip_y - 16.0 * k)
		var jet_r: float = ((3.8 + sin(anim_t * 26.0) * 1.1) if move_ratio > 0.1 else 2.2) * k
		c.draw_circle(back_p + Vector2(-5.0 * k, 0), jet_r, Color(aura.r, aura.g, aura.b, 0.82))
		c.draw_circle(back_p + Vector2(5.0 * k, 0), jet_r, Color(aura.r, aura.g, aura.b, 0.82))


static func _draw_arm_limb(c: CanvasItem, shoulder: Vector2, elbow: Vector2, hand: Vector2, k: float, aura: Color, is_rear: bool) -> void:
	var shade: float = 0.74 if is_rear else 1.0
	var mod := Color(shade, shade, minf(1.0, shade * 1.04), 1.0)
	var dark_out := Color(0.05, 0.07, 0.12, 0.96)
	var armor_col := Color(0.24 * shade, 0.29 * shade, 0.38 * shade, 1.0)
	var hi_col := Color(0.48 * shade, 0.56 * shade, 0.68 * shade, 1.0)
	var neon_col := Color(aura.r * shade, aura.g * shade, aura.b * shade, 0.92)

	var u_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_arm_upper.png")
	var f_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_arm_forearm.png")

	# 1. Omero corazzato 3D (Spalla -> Gomito)
	var u_vec: Vector2 = elbow - shoulder
	var u_len: float = maxf(4.0 * k, u_vec.length())
	var u_rot: float = u_vec.angle() - PI * 0.5
	if u_tex:
		var uw: float = 9.5 * k
		_draw_part(c, u_tex, shoulder, u_rot, Rect2(Vector2(-uw * 0.5, -1.5 * k), Vector2(uw, u_len + 3.0 * k)), false, mod)
	else:
		c.draw_line(shoulder, elbow, dark_out, 8.4 * k)
		c.draw_line(shoulder, elbow, armor_col, 5.4 * k)
		c.draw_line(shoulder.lerp(elbow, 0.2), shoulder.lerp(elbow, 0.8), hi_col, 2.2 * k)

	# Snodo cibernetico del gomito
	c.draw_circle(elbow, 3.8 * k, dark_out)
	c.draw_circle(elbow, 2.5 * k, armor_col)
	c.draw_circle(elbow, 1.2 * k, neon_col)

	# 2. Avambraccio corazzato 3D (Gomito -> Mano)
	var f_vec: Vector2 = hand - elbow
	var f_len: float = maxf(4.0 * k, f_vec.length())
	var f_rot: float = f_vec.angle() - PI * 0.5
	if f_tex:
		var fw: float = 8.8 * k
		_draw_part(c, f_tex, elbow, f_rot, Rect2(Vector2(-fw * 0.5, -1.5 * k), Vector2(fw, f_len + 2.5 * k)), false, mod)
	else:
		c.draw_line(elbow, hand, dark_out, 7.8 * k)
		c.draw_line(elbow, hand, armor_col, 4.8 * k)
		c.draw_line(elbow.lerp(hand, 0.2), elbow.lerp(hand, 0.85), neon_col, 1.8 * k)


static func _draw_arm_gauntlet(c: CanvasItem, hand: Vector2, k: float, aura: Color, is_rear: bool) -> void:
	var shade: float = 0.78 if is_rear else 1.0
	c.draw_circle(hand, 4.2 * k, Color(0.05, 0.07, 0.12, 0.98))
	c.draw_circle(hand, 2.9 * k, Color(0.42 * shade, 0.50 * shade, 0.62 * shade, 1.0))
	c.draw_circle(hand, 1.4 * k, Color(aura.r * shade, aura.g * shade, aura.b * shade, 0.95))


static func _draw_hero_weapon_and_arms(
	c: CanvasItem,
	weapon_id: String,
	anim_t: float,
	is_shooting: bool,
	recoil_kick: float,
	aim_angle: float,
	pose: String,
	face_left: bool,
	feet: Vector2,
	bob: float,
	k: float,
	aura: Color
) -> void:
	var dir := Vector2.from_angle(aim_angle)
	var face_sign: float = -1.0 if face_left else 1.0
	var is_melee: bool = (weapon_id == "katana" or weapon_id == "scythe")
	var is_one_handed: bool = (weapon_id == "pistol_base")

	# Posizione naturale delle spalle sotto gli spallacci Samurai del busto 3D
	var chest_center := Vector2(feet.x, feet.y - 44.0 * k + bob)
	var front_shoulder := chest_center + Vector2(-face_sign * 6.5 * k, -1.0 * k)
	var rear_shoulder := chest_center + Vector2(face_sign * 7.5 * k, -1.5 * k)
	if pose == "front" or pose == "back":
		var s_sign: float = 1.0 if dir.x >= 0.0 else -1.0
		front_shoulder = chest_center + Vector2(-s_sign * 11.0 * k, -0.5 * k)
		rear_shoulder = chest_center + Vector2(s_sign * 11.0 * k, -0.5 * k)

	# Orientamento realistico dell'arma:
	# - Armi da fuoco: tenute all'altezza del petto/fianco con calcio appoggiato alla spalla/petto
	# - Katana / Falce: tenute in guardia diagonale pronta al taglio quando non colpiscono,
	#   e animate con un ampio fendente ad arco quando attaccano
	var eff_angle: float = aim_angle
	var push_back: float = recoil_kick * 4.5 * k
	if is_melee:
		if is_shooting:
			var slash_wave: float = sin(anim_t * 15.0)
			eff_angle = aim_angle + slash_wave * 1.18 * face_sign
			push_back = -absf(slash_wave) * 5.0 * k
		else:
			eff_angle = aim_angle - 0.52 * face_sign + sin(anim_t * 3.2) * 0.05

	var w_dir := Vector2.from_angle(eff_angle)
	# Vettore "verso il basso" rispetto alla gravità per piegare i gomiti in modo naturale
	var gravity_down := Vector2(0.0, 1.0)

	# Punto d'impugnatura (grip_pos) raccolto vicino al busto così il calcio resta contro la spalla
	var grip_dist: float = (9.5 if is_one_handed else (8.0 if is_melee else 6.5)) * k
	var grip_pos: Vector2 = chest_center + Vector2(face_sign * 3.0 * k, 5.5 * k) + w_dir * (grip_dist - push_back)
	var foregrip_pos: Vector2 = grip_pos + w_dir * ((6.5 if is_melee else 11.5) * k) + Vector2(0.0, 1.0 * k)

	# I gomiti piegano naturalmente verso il basso/fianco, mai sopra la canna dell'arma
	var rear_elbow: Vector2 = rear_shoulder.lerp(foregrip_pos, 0.50) + gravity_down * (6.5 * k) + Vector2(face_sign * 2.0 * k, 0.0)
	var front_elbow: Vector2 = front_shoulder.lerp(grip_pos, 0.48) + gravity_down * (8.5 * k) - Vector2(face_sign * 3.0 * k, 0.0)

	# 1. Braccio posteriore e Braccio anteriore disegnati PRIMA del corpo dell'arma
	#    così gli avambracci sostengono l'arma da sotto/dietro senza mai coprire la canna!
	if not is_one_handed:
		_draw_arm_limb(c, rear_shoulder, rear_elbow, foregrip_pos, k, aura, true)
	elif pose == "front" or pose == "back":
		var off_hand := rear_shoulder + Vector2((4.0 if dir.x >= 0.0 else -4.0) * k, 11.5 * k)
		var off_elbow := rear_shoulder.lerp(off_hand, 0.5) + Vector2((2.5 if dir.x >= 0.0 else -2.5) * k, 2.5 * k)
		_draw_arm_limb(c, rear_shoulder, off_elbow, off_hand, k, aura, true)

	_draw_arm_limb(c, front_shoulder, front_elbow, grip_pos, k, aura, false)

	# 2. Modello 3D dell'arma ancorato esattamente sul calcio/impugnatura (grip_pos)
	var wep_tex := CyberTheme.get_item_model_texture(weapon_id, "ARMA")
	if wep_tex:
		var draw_len: float = 48.0 * k
		var grip_uv := Vector2(0.24, 0.52)
		match weapon_id:
			"pistol_base":
				draw_len = 32.0 * k
				grip_uv = Vector2(0.24, 0.56)
			"smg":
				draw_len = 40.0 * k
				grip_uv = Vector2(0.30, 0.55)
			"shotgun":
				draw_len = 50.0 * k
				grip_uv = Vector2(0.22, 0.54)
			"laser_rifle":
				draw_len = 52.0 * k
				grip_uv = Vector2(0.28, 0.52)
			"plasma_cannon":
				draw_len = 50.0 * k
				grip_uv = Vector2(0.28, 0.54)
			"homing_wand":
				draw_len = 48.0 * k
				grip_uv = Vector2(0.27, 0.54)
			"katana":
				draw_len = 58.0 * k
				grip_uv = Vector2(0.18, 0.50)
			"scythe":
				draw_len = 60.0 * k
				grip_uv = Vector2(0.24, 0.50)

		var sy: float = -1.0 if face_left else 1.0
		c.draw_set_transform_matrix(Transform2D(eff_angle, Vector2(1.0, sy), 0.0, grip_pos))
		if is_shooting and not is_melee:
			c.draw_line(Vector2(draw_len * 0.65, -1.5 * k), Vector2(draw_len * 1.85, -1.5 * k), Color(1.0, 0.15, 0.25, 0.40), 1.5)
		var w_rect := Rect2(-Vector2(draw_len * grip_uv.x, draw_len * grip_uv.y), Vector2(draw_len, draw_len))
		c.draw_texture_rect(wep_tex, w_rect, false, Color.WHITE)

		if is_shooting and recoil_kick > 0.22:
			if is_melee:
				c.draw_arc(Vector2(draw_len * 0.15, 0.0), draw_len * 0.68, -0.65, 0.65, 16, Color(aura.r, aura.g, aura.b, 0.70 * recoil_kick), 4.2 * k)
			else:
				var muz := Vector2(draw_len * (1.0 - grip_uv.x) + 2.0 * k, -2.0 * k)
				c.draw_circle(muz, 6.5 * k * recoil_kick, Color(aura.r, aura.g, aura.b, 0.82))
				c.draw_circle(muz, 3.0 * k * recoil_kick, Color.WHITE)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 3. Guanti corazzati 3D che stringono visibilmente l'impugnatura e il sottocanna
	if not is_one_handed:
		_draw_arm_gauntlet(c, foregrip_pos, k * 0.92, aura, true)
	_draw_arm_gauntlet(c, grip_pos, k, aura, false)


# ==============================================================================
# 2. APPENDICI 3D SPECIFICHE PER OGNI MONDO (MONDI 1..8) SUI NEMICI
# ==============================================================================
static func _draw_world_enemy_addons(c: CanvasItem, style: String, center: Vector2, radius: float, glow: Color, sec: Color, anim_t: float) -> void:
	match style:
		"bio":
			for s: float in [-1.0, 1.0]:
				var base := center + Vector2(s * radius * 0.52, -radius * 0.25)
				var tip := base + Vector2(s * (9.0 + sin(anim_t * 5.0) * 2.5), -12.0)
				c.draw_line(base, tip, sec, 5.0)
				c.draw_line(base, tip, glow, 2.2)
				c.draw_circle(tip, 3.2, glow)
		"desert":
			var tail_tip := center + Vector2(sin(anim_t * 4.5) * 4.0, -radius * 0.98)
			c.draw_line(center + Vector2(0.0, -radius * 0.30), tail_tip, sec, 5.5)
			c.draw_circle(tail_tip, 4.4, glow)
		"neon":
			for s: float in [-1.0, 1.0]:
				var w_pts := PackedVector2Array([
					center + Vector2(s * radius * 0.38, -radius * 0.12),
					center + Vector2(s * radius * 1.15, -radius * 0.65),
					center + Vector2(s * radius * 0.92, radius * 0.06)
				])
				c.draw_colored_polygon(w_pts, Color(glow.r, glow.g, glow.b, 0.38))
				c.draw_polyline(w_pts, sec, 1.8)
		"cryo":
			for s: float in [-1.0, 1.0]:
				var c_pts := PackedVector2Array([
					center + Vector2(s * radius * 0.42, -radius * 0.15),
					center + Vector2(s * radius * 0.96, -radius * 0.78),
					center + Vector2(s * radius * 0.70, -radius * 0.04)
				])
				c.draw_colored_polygon(c_pts, Color(0.55, 0.92, 1.0, 0.85))
				c.draw_polyline(c_pts, Color.WHITE, 1.5)
		"magma":
			for s: float in [-1.0, 1.0]:
				var vent := center + Vector2(s * radius * 0.56, -radius * 0.56)
				c.draw_line(center + Vector2(s * radius * 0.32, -radius * 0.12), vent, Color(0.22, 0.10, 0.08), 6.0)
				c.draw_circle(vent, 4.2 + sin(anim_t * 7.0) * 1.2, glow)
		"toxic":
			for s: float in [-1.0, 1.0]:
				var tank := center + Vector2(s * radius * 0.60, -radius * 0.25)
				c.draw_circle(tank, 5.5, sec)
				c.draw_circle(tank, 3.4, glow)
		"astral":
			c.draw_arc(center + Vector2(0.0, -radius * 0.35), radius * 0.76, 0.0, TAU, 20, glow, 2.2)
		"void":
			for i in range(3):
				var ang: float = anim_t * 3.8 + float(i) * TAU / 3.0
				var orb := center + Vector2(cos(ang) * radius * 0.88, sin(ang) * radius * 0.52 - 4.0)
				c.draw_circle(orb, 3.5, glow)
				c.draw_circle(orb, 1.8, Color.WHITE)


# ==============================================================================
# 3. NEMICO MELEE: MANTIS STALKER 3D CON GAMBE ARTICOLATE E SUPPORTO ÉLITE
# ==============================================================================
static func draw_melee_enemy(c: CanvasItem, world_id: String, anim_t: float, accent: Color, aim_angle: float, is_elite: bool = false) -> void:
	var face_left := cos(aim_angle) < 0.0
	var stride_phase: float = anim_t * 15.0
	var scuttle := absf(cos(stride_phase)) * 2.5
	var tilt := cos(aim_angle) * 0.09 + sin(stride_phase) * 0.05
	var prof := _get_world_profile(world_id)
	var glow: Color = prof.get("glow", accent)
	var sec: Color = prof.get("sec", accent)
	var armor_mod: Color = prof.get("armor", Color.WHITE)
	var style: String = prof.get("style", "default")

	draw_ground_shadow(c, Vector2(0, 14), 22.0, 0.60)
	draw_ground_ring(c, Vector2(0, 14), 25.0, glow, anim_t * 0.65, 2.4)
	if is_elite:
		_draw_elite_crown(c, Vector2(0, 14), -36.0, 26.0, anim_t)

	_draw_world_enemy_addons(c, style, Vector2(0, -10.0 - scuttle), 22.0, glow, sec, anim_t)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_melee_v2.png")
	if tex:
		var mod := armor_mod.lerp(Color(1.25, 1.12, 0.82), 0.30) if is_elite else armor_mod
		_draw_biped_animated_sprite(c, tex, Vector2(cos(aim_angle) * 2.0, 16.0), 52.0, stride_phase, 0.24, 4.5, tilt, not face_left, mod)
	else:
		c.draw_circle(Vector2(0, -8), 14.0, glow)


# ==============================================================================
# 4. NEMICO RANGED: HOVER-WASP SNIPER DRONE 3D CON PROPULSORI E ROLLIO DINAMICO
# ==============================================================================
static func draw_ranged_enemy(c: CanvasItem, anim_t: float, _accent: Color, aim_angle: float, is_charging: bool, world_id: String = "world_1", is_elite: bool = false) -> void:
	var face_left := cos(aim_angle) < 0.0
	var hover := sin(anim_t * 4.5) * 4.8
	var wing_buzz := sin(anim_t * 24.0) * 0.04
	var bank_rot := cos(aim_angle) * 0.11 + sin(anim_t * 3.2) * 0.06 + wing_buzz
	var prof := _get_world_profile(world_id)
	var glow: Color = prof.get("glow", _accent)
	var sec: Color = prof.get("sec", _accent)
	var armor_mod: Color = prof.get("armor", Color.WHITE)
	var style: String = prof.get("style", "default")

	draw_ground_shadow(c, Vector2(0, 16), 17.0 - hover * 0.5, 0.48)
	draw_ground_ring(c, Vector2(0, 16), 23.0, glow, -anim_t * 0.8, 2.2)
	if is_elite:
		_draw_elite_crown(c, Vector2(0, 16), -42.0 + hover, 24.0, anim_t)

	var body_c := Vector2(0, -16.0 + hover)
	# Fiamme dei propulsori inferiori del drone
	for s: float in [-1.0, 1.0]:
		var jet_p := body_c + Vector2(s * 9.0, 12.0)
		var flame_len: float = 6.5 + absf(sin(anim_t * 28.0 + s)) * 4.5
		c.draw_line(jet_p, jet_p + Vector2(-cos(aim_angle) * 2.5, flame_len), Color(glow.r, glow.g, glow.b, 0.75), 3.6)
		c.draw_circle(jet_p, 2.4, Color.WHITE)

	_draw_world_enemy_addons(c, style, body_c, 22.0, glow, sec, anim_t)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_ranged_v2.png")
	if tex:
		var w: float = 60.0 * (1.0 + absf(wing_buzz) * 0.4)
		var h: float = w * float(tex.get_height()) / float(tex.get_width())
		var mod := armor_mod.lerp(Color(1.25, 1.12, 0.82), 0.30) if is_elite else armor_mod
		_draw_part(c, tex, body_c, bank_rot, Rect2(Vector2(-w * 0.5, -h * 0.5), Vector2(w, h)), not face_left, mod)
	else:
		c.draw_circle(body_c, 14.0, glow)

	var eye := body_c + Vector2(cos(aim_angle) * 6.0, 8.0 + sin(aim_angle) * 3.0)
	if is_charging:
		var tip := eye + Vector2.RIGHT.rotated(aim_angle) * 135.0
		c.draw_line(eye, tip, Color(glow.r, glow.g, glow.b, 0.55 + 0.28 * sin(anim_t * 30.0)), 2.4)
		c.draw_circle(eye, 6.5 + sin(anim_t * 30.0) * 2.0, Color(glow.r, glow.g, glow.b, 0.92))
		c.draw_circle(eye, 2.4, Color.WHITE)


# ==============================================================================
# 5. NEMICO PESANTE: GOLIATH SIEGE JUGGERNAUT 3D CON PASSO PESANTE ARTICOLATO
# ==============================================================================
static func draw_heavy_enemy(c: CanvasItem, anim_t: float, charge_ratio: float, aim_angle: float, world_id: String = "world_1", is_elite: bool = false) -> void:
	var face_left := cos(aim_angle) < 0.0
	var stride_phase: float = anim_t * 7.5
	var stomp := absf(cos(stride_phase)) * 2.8
	var sway := sin(stride_phase) * 0.055
	var prof := _get_world_profile(world_id)
	var glow: Color = prof.get("glow", Color(1.0, 0.52, 0.12))
	var sec: Color = prof.get("sec", Color(1.0, 0.35, 0.10))
	var armor_mod: Color = prof.get("armor", Color.WHITE)
	var style: String = prof.get("style", "default")

	draw_ground_shadow(c, Vector2(0, 20), 28.0, 0.62)
	draw_ground_ring(c, Vector2(0, 20), 31.0, glow, anim_t * 0.45, 2.4)
	if is_elite:
		_draw_elite_crown(c, Vector2(0, 20), -54.0, 32.0, anim_t)

	c.draw_set_transform(Vector2(0, 20), 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_arc(Vector2.ZERO, 35.0, -PI * 0.5, -PI * 0.5 + TAU * charge_ratio, 32, glow, 3.4)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	_draw_world_enemy_addons(c, style, Vector2(0, -18.0 - stomp), 30.0, glow, sec, anim_t)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_heavy_v2.png")
	if tex:
		var heat := Color(armor_mod.r + charge_ratio * 0.25, armor_mod.g, armor_mod.b - charge_ratio * 0.15, 1.0)
		_draw_biped_animated_sprite(c, tex, Vector2(0, 22.0), 74.0, stride_phase, 0.18, 4.2, sway, face_left, heat)
	else:
		c.draw_circle(Vector2(0, -16), 22.0, glow)
	if charge_ratio > 0.6:
		var mortar := Vector2((-8.0 if face_left else 8.0), -46.0)
		c.draw_circle(mortar, 5.0 + charge_ratio * 6.0, Color(glow.r, glow.g, glow.b, 0.55))
		c.draw_circle(mortar, 2.5 + charge_ratio * 2.0, Color(1.0, 0.95, 0.6, 0.9))


# ==============================================================================
# 6. BOSS UNICI PER OGNI MONDO (boss_world_1.png .. boss_world_8.png) ARTICOLATI
# ==============================================================================
static func draw_boss(c: CanvasItem, world_id: String, anim_t: float, boss_col: Color, in_phase_2: bool, aim_angle: float) -> void:
	var prof := _get_world_profile(world_id)
	var active_col: Color = Color(1.0, 0.15, 0.22, 1.0) if in_phase_2 else prof.get("glow", boss_col)
	var face_left := cos(aim_angle) < 0.0
	var stride_phase: float = anim_t * (6.8 if in_phase_2 else 4.8)
	var stomp := absf(cos(stride_phase)) * 3.2
	var sway := sin(stride_phase) * 0.045

	draw_ground_shadow(c, Vector2(0, 44), 54.0, 0.72)
	draw_ground_ring(c, Vector2(0, 44), 62.0, active_col, anim_t, 3.6)
	if in_phase_2:
		c.draw_set_transform(Vector2(0, 44), 0.0, Vector2(1.0, PERSPECTIVE_Y))
		var shock_r: float = 50.0 + fmod(anim_t * 90.0, 40.0)
		c.draw_arc(Vector2.ZERO, shock_r, 0.0, TAU, 40, Color(1.0, 0.2, 0.2, 0.6 * (1.0 - (shock_r - 50.0) / 40.0)), 3.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var orb_count := 4 if in_phase_2 else 3
	var orbs_front: Array[Vector2] = []
	for i in range(orb_count):
		var ang := anim_t * 2.2 + i * (TAU / float(orb_count))
		var p := Vector2(cos(ang) * 76.0, -20.0 + sin(ang) * 76.0 * PERSPECTIVE_Y)
		if sin(ang) < 0.0:
			_draw_orb(c, p, active_col, 0.8)
		else:
			orbs_front.append(p)

	# Carica il modello 3D specifico del Boss del Mondo (boss_world_1..8.png)
	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/boss_" + world_id + ".png")
	if not tex:
		tex = CyberTheme.get_model_texture("res://assets/cyber_models/unit_boss_titan.png")
	if tex:
		var tint := Color.WHITE
		if in_phase_2:
			tint = Color(1.25, 0.88, 0.88, 1.0)
		_draw_biped_animated_sprite(c, tex, Vector2(0, 46.0), 146.0, stride_phase, 0.16, 6.5, sway, face_left, tint)
	else:
		c.draw_circle(Vector2(0, -20), 40.0, active_col)

	var core_p := Vector2((3.0 if face_left else -3.0), -48.0 - stomp * 0.5)
	var pulse: float = 0.5 + 0.5 * sin(anim_t * (9.0 if in_phase_2 else 5.0))
	c.draw_circle(core_p, 12.0 + pulse * 4.0, Color(active_col.r, active_col.g, active_col.b, 0.22 + pulse * 0.18))
	c.draw_circle(core_p, 4.2 + pulse * 1.5, Color(1.0, 0.96, 0.80, 0.85))

	for p in orbs_front:
		_draw_orb(c, p, active_col, 1.0)


static func _draw_orb(c: CanvasItem, p: Vector2, col: Color, a: float) -> void:
	c.draw_circle(p, 9.0, Color(col.r, col.g, col.b, 0.25 * a))
	c.draw_circle(p, 6.5, Color(0.12, 0.14, 0.22, a))
	c.draw_circle(p, 4.5, Color(col.r, col.g, col.b, a))
	c.draw_circle(p + Vector2(-1.5, -1.5), 1.8, Color(1, 1, 1, a))


# ==============================================================================
# 7. OSTACOLO E CASSA RIFORNIMENTI 3D CON DETTAGLI BIOMA
# ==============================================================================
static func draw_obstacle(c: CanvasItem, accent_col: Color, world_id: String = "world_1") -> void:
	var prof := _get_world_profile(world_id)
	var glow: Color = prof.get("glow", accent_col)
	var armor_mod: Color = prof.get("armor", Color.WHITE)
	var style: String = prof.get("style", "default")

	c.draw_colored_polygon(PackedVector2Array([
		Vector2(-26, 24), Vector2(28, 24), Vector2(44, 34), Vector2(-10, 34)
	]), Color(0, 0, 0, 0.45))
	draw_ground_shadow(c, Vector2(2, 22), 32.0, 0.45)
	var obs_tex := CyberTheme.get_model_texture("res://assets/cyber_models/prop_obstacle.png")
	if obs_tex:
		c.draw_texture_rect(obs_tex, Rect2(Vector2(-32, -48), Vector2(64, 72)), false, armor_mod)
	else:
		c.draw_rect(Rect2(Vector2(-24, -40), Vector2(48, 64)), Color(0.12, 0.15, 0.22, 1.0), true)

	# Dettaglio superiore specifico del Mondo sull'ostacolo 3D
	match style:
		"bio":
			c.draw_circle(Vector2(0, -34), 7.0, Color(0.08, 0.45, 0.25))
			c.draw_circle(Vector2(0, -34), 4.0, glow)
		"desert":
			c.draw_line(Vector2(-16, -34), Vector2(16, -34), glow, 3.0)
		"neon":
			c.draw_rect(Rect2(Vector2(-16, -38), Vector2(32, 6)), glow, true)
		"cryo":
			c.draw_colored_polygon(PackedVector2Array([Vector2(0, -52), Vector2(9, -36), Vector2(0, -24), Vector2(-9, -36)]), Color(0.65, 0.96, 1.0, 0.85))
		"magma":
			c.draw_circle(Vector2(0, -32), 7.5, Color(0.22, 0.08, 0.05))
			c.draw_circle(Vector2(0, -32), 4.5, glow)
		"toxic":
			c.draw_arc(Vector2(0, -32), 8.0, 0.0, TAU, 16, glow, 2.4)
		"astral":
			c.draw_polyline(PackedVector2Array([Vector2(0, -44), Vector2(9, -34), Vector2(0, -24), Vector2(-9, -34), Vector2(0, -44)]), glow, 2.2)
		"void":
			c.draw_circle(Vector2(0, -34), 7.0, Color(0.05, 0.01, 0.10))
			c.draw_arc(Vector2(0, -34), 8.0, 0.0, PI * 1.5, 16, glow, 2.4)

	c.draw_set_transform(Vector2(0, 22), 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 28, Color(glow.r, glow.g, glow.b, 0.65), 2.2)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func draw_loot_crate(c: CanvasItem, anim_t: float, hp_ratio: float) -> void:
	var pulse := 0.75 + sin(anim_t * 6.0) * 0.25
	var hover := sin(anim_t * 2.5) * 1.5
	draw_ground_shadow(c, Vector2(0, 18), 22.0, 0.55)
	c.draw_set_transform(Vector2(0, 18), 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_arc(Vector2.ZERO, 26.0, 0.0, TAU, 28, Color(1.0, 0.84, 0.1, 0.5 * pulse), 2.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var crate_tex := CyberTheme.get_model_texture("res://assets/cyber_models/prop_crate.png")
	if crate_tex:
		c.draw_texture_rect(crate_tex, Rect2(Vector2(-26, -32 + hover), Vector2(52, 52)), false)
	else:
		c.draw_rect(Rect2(Vector2(-20, -20), Vector2(40, 40)), Color(0.14, 0.16, 0.24, 1.0), true)

	if hp_ratio < 1.0:
		c.draw_rect(Rect2(Vector2(-20, -40), Vector2(40, 5)), Color(0.08, 0.08, 0.12, 0.9), true)
		c.draw_rect(Rect2(Vector2(-20, -40), Vector2(40.0 * hp_ratio, 5)), Color(1.0, 0.84, 0.0, 1.0), true)
