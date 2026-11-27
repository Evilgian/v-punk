class_name CyberModels
extends RefCounted

# ==============================================================================
# RENDERING 2.5D "ARCHERO-STYLE" v7.0:
# - Eroe 3D con Proporzioni Anatomiche Reali (1:1 aspect ratio dalle texture),
#   Spallacci Samurai integri + Cintura/Bacino corazzato, Gambe a 2 snodi con
#   passo reversibile in Kiting (zero moonwalk) e Posa da Parata nei Menu
# - Impugnatura Armi 3D calibrata sul vero asse della canna (zero pallini neon)
# - 7 Archetipi di Nemici Distinti (Mantis, Wasp Drone, Goliath Mech con arti
#   separati, Ticker Kamikaze, Aegis Shielder, Cyber-Wraith Assassin, Spitter Turret
#   con torretta rotante indipendente)
# - 8 Veri Boss 3D Unici per Mondo con anatomia dedicata (Bipede, Aracnide,
#   Corazzata Volante, Valchiria/Serafino Alato, Idra a 3 Teste)
# ==============================================================================

const PERSPECTIVE_Y: float = 0.42


static func draw_ground_shadow(c: CanvasItem, center: Vector2, radius: float, strength: float = 0.5) -> void:
	c.draw_set_transform(center, 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_circle(Vector2.ZERO, radius * 1.25, Color(0, 0, 0, strength * 0.24))
	c.draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, strength * 0.44))
	c.draw_circle(Vector2.ZERO, radius * 0.65, Color(0, 0, 0, strength * 0.54))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func draw_ground_ring(c: CanvasItem, center: Vector2, radius: float, col: Color, anim_t: float, width: float = 2.4) -> void:
	c.draw_set_transform(center, 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_circle(Vector2.ZERO, radius, Color(col.r, col.g, col.b, 0.10))
	c.draw_arc(Vector2.ZERO, radius, anim_t * 2.2, anim_t * 2.2 + PI * 1.35, 32, Color(col.r, col.g, col.b, 0.90), width)
	c.draw_arc(Vector2.ZERO, radius, anim_t * 2.2 + PI * 1.5, anim_t * 2.2 + PI * 1.85, 12, Color(1, 1, 1, 0.72), width * 0.8)
	c.draw_arc(Vector2.ZERO, radius * 0.72, -anim_t * 1.6, -anim_t * 1.6 + PI, 20, Color(col.r, col.g, col.b, 0.42), 1.4)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func draw_spawn_telegraph(c: CanvasItem, center: Vector2, radius: float, col: Color, prog: float) -> void:
	var p: float = clampf(prog, 0.0, 1.0)
	c.draw_set_transform(center, 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_circle(Vector2.ZERO, radius * p, Color(col.r, col.g, col.b, 0.22 * (1.0 - p * 0.4)))
	c.draw_arc(Vector2.ZERO, radius, 0.0, TAU * p, 28, Color(1.0, 0.92, 0.45, 0.92), 3.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _draw_part(c: CanvasItem, tex: Texture2D, pivot: Vector2, rot: float, local_rect: Rect2, flip_h: bool = false, modulate: Color = Color.WHITE) -> void:
	if not tex:
		return
	var sx: float = -1.0 if flip_h else 1.0
	c.draw_set_transform(pivot, rot, Vector2(sx, 1.0))
	c.draw_texture_rect(tex, local_rect, false, modulate)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _aspect(tex: Texture2D, fallback: float = 0.75) -> float:
	if not tex or tex.get_height() <= 0:
		return fallback
	return float(tex.get_width()) / float(tex.get_height())


static func _draw_segmented_mech_walker(
	c: CanvasItem,
	torso_tex: Texture2D,
	leg_l_tex: Texture2D,
	leg_r_tex: Texture2D,
	feet: Vector2,
	total_h: float,
	stride_phase: float,
	stride_amp: float,
	lift_amp: float,
	torso_sway: float,
	flip_h: bool,
	modulate: Color = Color.WHITE
) -> void:
	if not torso_tex:
		return
	var sx: float = -1.0 if flip_h else 1.0
	var s_wave: float = sin(stride_phase)
	var c_wave: float = absf(cos(stride_phase))
	var stomp_bob: float = -c_wave * lift_amp * 0.35

	var leg_h: float = total_h * 0.44
	var hip_y: float = feet.y - leg_h * 0.86 + stomp_bob
	var torso_h: float = total_h * 0.76
	var torso_w: float = torso_h * _aspect(torso_tex, 0.95)

	var l_lift: float = -maxf(0.0, s_wave) * lift_amp
	var r_lift: float = -maxf(0.0, -s_wave) * lift_amp
	var l_rot: float = s_wave * stride_amp
	var r_rot: float = -s_wave * stride_amp
	var l_mod := modulate if s_wave >= 0.0 else Color(modulate.r * 0.80, modulate.g * 0.82, modulate.b * 0.88, modulate.a)
	var r_mod := modulate if s_wave <= 0.0 else Color(modulate.r * 0.80, modulate.g * 0.82, modulate.b * 0.88, modulate.a)

	var hip_spread: float = torso_w * 0.16
	var l_hip := Vector2(feet.x - sx * hip_spread, hip_y + l_lift)
	var r_hip := Vector2(feet.x + sx * hip_spread, hip_y + r_lift)

	var lw_l: float = leg_h * _aspect(leg_l_tex, 0.55)
	var lw_r: float = leg_h * _aspect(leg_r_tex, 0.55)

	# Disegna prima la gamba arretrata, poi quella avanzata, poi il torso+braccia integro sopra!
	if s_wave >= 0.0:
		_draw_part(c, leg_r_tex, r_hip, r_rot, Rect2(Vector2(-lw_r * 0.48, -leg_h * 0.12), Vector2(lw_r, leg_h)), flip_h, r_mod)
		_draw_part(c, leg_l_tex, l_hip, l_rot, Rect2(Vector2(-lw_l * 0.52, -leg_h * 0.12), Vector2(lw_l, leg_h)), flip_h, l_mod)
	else:
		_draw_part(c, leg_l_tex, l_hip, l_rot, Rect2(Vector2(-lw_l * 0.52, -leg_h * 0.12), Vector2(lw_l, leg_h)), flip_h, l_mod)
		_draw_part(c, leg_r_tex, r_hip, r_rot, Rect2(Vector2(-lw_r * 0.48, -leg_h * 0.12), Vector2(lw_r, leg_h)), flip_h, r_mod)

	var waist_pivot := Vector2(feet.x, feet.y - total_h * 0.22 + stomp_bob * 1.15)
	_draw_part(c, torso_tex, waist_pivot, torso_sway, Rect2(Vector2(-torso_w * 0.50, -torso_h * 0.78), Vector2(torso_w, torso_h)), flip_h, modulate)


static func _draw_arachnid_unit(
	c: CanvasItem,
	tex: Texture2D,
	feet: Vector2,
	height: float,
	anim_t: float,
	speed_freq: float,
	lunge_pitch: float,
	flip_h: bool,
	modulate: Color = Color.WHITE
) -> void:
	if not tex:
		return
	var w: float = height * _aspect(tex, 1.0)
	var sx: float = -1.0 if flip_h else 1.0
	var scuttle_bob: float = -absf(sin(anim_t * speed_freq)) * (height * 0.048)
	var gait_shear: float = sin(anim_t * speed_freq) * 0.065
	var squash_y: float = 1.0 + cos(anim_t * speed_freq * 2.0) * 0.032
	var squash_x: float = 1.0 - cos(anim_t * speed_freq * 2.0) * 0.024
	var rot: float = lunge_pitch * sx + sin(anim_t * speed_freq * 0.5) * 0.035

	var xform := Transform2D(rot, Vector2(sx * squash_x, squash_y), gait_shear, feet + Vector2(0.0, scuttle_bob))
	c.draw_set_transform_matrix(xform)
	c.draw_texture_rect(tex, Rect2(Vector2(-w * 0.5, -height), Vector2(w, height)), false, modulate)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _get_world_profile(world_id: String) -> Dictionary:
	match world_id:
		"world_1":
			return {"armor": Color(0.92, 1.05, 0.94), "glow": Color(0.14, 1.0, 0.56), "sec": Color(0.08, 0.48, 0.28)}
		"world_2":
			return {"armor": Color(1.08, 0.96, 0.80), "glow": Color(1.0, 0.76, 0.16), "sec": Color(0.62, 0.38, 0.10)}
		"world_3":
			return {"armor": Color(0.96, 0.90, 1.08), "glow": Color(1.0, 0.18, 0.72), "sec": Color(0.0, 0.94, 1.0)}
		"world_4":
			return {"armor": Color(0.86, 0.98, 1.12), "glow": Color(0.28, 0.94, 1.0), "sec": Color(0.68, 0.96, 1.0)}
		"world_5":
			return {"armor": Color(1.10, 0.86, 0.78), "glow": Color(1.0, 0.42, 0.10), "sec": Color(1.0, 0.80, 0.16)}
		"world_6":
			return {"armor": Color(0.90, 1.08, 0.80), "glow": Color(0.58, 1.0, 0.16), "sec": Color(0.24, 0.58, 0.14)}
		"world_7":
			return {"armor": Color(1.08, 0.98, 0.88), "glow": Color(1.0, 0.86, 0.28), "sec": Color(0.74, 0.34, 1.0)}
		"world_8":
			return {"armor": Color(1.06, 0.80, 0.90), "glow": Color(1.0, 0.06, 0.38), "sec": Color(0.65, 0.12, 0.95)}
		"world_9":
			return {"armor": Color(1.08, 0.84, 0.82), "glow": Color(1.0, 0.18, 0.22), "sec": Color(1.0, 0.72, 0.12)}
		"world_10":
			return {"armor": Color(0.80, 1.08, 1.04), "glow": Color(0.0, 0.95, 0.82), "sec": Color(0.10, 0.55, 1.0)}
		"world_11":
			return {"armor": Color(0.96, 1.02, 1.12), "glow": Color(0.78, 0.92, 1.0), "sec": Color(1.0, 0.86, 0.25)}
		"world_12":
			return {"armor": Color(0.92, 0.80, 1.08), "glow": Color(1.0, 0.04, 0.34), "sec": Color(0.62, 0.14, 1.0)}
	return {"armor": Color.WHITE, "glow": Color(1.0, 0.22, 0.32), "sec": Color(0.0, 0.92, 1.0)}


static func _draw_elite_crown(c: CanvasItem, feet: Vector2, top_y: float, radius: float, anim_t: float) -> void:
	var pulse: float = 0.78 + 0.22 * sin(anim_t * 6.5)
	draw_ground_ring(c, feet, radius * 1.14, Color(1.0, 0.84, 0.14, 0.95 * pulse), -anim_t * 1.4, 3.0)
	var cy: float = top_y - 11.0 + sin(anim_t * 5.0) * 2.2
	var crown := PackedVector2Array([
		Vector2(-10.0, cy + 4.5),
		Vector2(-12.0, cy - 4.5),
		Vector2(-4.5, cy + 0.8),
		Vector2(0.0, cy - 8.0),
		Vector2(4.5, cy + 0.8),
		Vector2(12.0, cy - 4.5),
		Vector2(10.0, cy + 4.5)
	])
	c.draw_colored_polygon(crown, Color(1.0, 0.82, 0.12, 0.96))
	c.draw_polyline(crown, Color(1.0, 0.98, 0.75, 1.0), 1.5)


# ==============================================================================
# 1. EROE: CYBER-RONIN 3D CON LOCOMOZIONE BIOMECCANICA REALE E POSA ARMI CALIBRATA
# ==============================================================================
static func draw_hero(
	c: CanvasItem,
	weapon_id: String,
	anim_t: float,
	is_moving: bool,
	is_shooting: bool,
	aim_angle: float,
	move_vec: Vector2 = Vector2.ZERO,
	body_h: float = 68.0,
	parade_mode: bool = false,
	skin_override: String = ""
) -> void:
	var skin_id: String = skin_override if not skin_override.is_empty() else Global.equipped_skin_id
	if skin_id.is_empty():
		skin_id = "v_runner"
	var aura := Global.get_player_accent_color()
	var k: float = body_h / 68.0

	# Nei podi del Menu / Creazione Personaggio usa automaticamente la Posa Eroica da Parata
	var use_parade: bool = parade_mode or (not is_moving and not is_shooting and body_h <= 72.0 and sin(aim_angle) > 0.35)
	var sin_a: float = sin(aim_angle)
	var cos_a: float = cos(aim_angle)

	var pose: String = "side"
	var face_left: bool = cos_a < -0.05
	if use_parade:
		pose = "front"
		face_left = false
	elif sin_a < -0.68:
		pose = "back"
	elif sin_a > 0.68:
		pose = "front"

	var mv: Vector2 = move_vec.limit_length(1.0) if is_moving else Vector2.ZERO
	if is_moving and mv.length_squared() < 0.01:
		mv = Vector2(cos_a, sin_a)
	var move_ratio: float = clampf(mv.length(), 0.0, 1.0) if is_moving else 0.0

	# Calcolo direzione relativa (Avanti vs Retromarcia/Kiting) per eliminare il moonwalk!
	var stride_dir: float = 1.0
	if move_ratio > 0.05:
		var look_vec := Vector2(-1.0 if face_left else 1.0, 0.0) if pose == "side" else Vector2(cos_a, sin_a)
		if mv.normalized().dot(look_vec) < -0.15:
			stride_dir = -1.0

	var stride_phase: float = anim_t * 14.8 * stride_dir
	var stride_c: float = absf(cos(stride_phase)) * move_ratio
	# Rimbalzo atletico netto a ogni passo (2 impulsi per ciclo completo di corsa!)
	var bob: float = (-stride_c * 6.2 + sin(anim_t * 2.8) * (1.0 - move_ratio) * 1.1) * k
	var recoil_phase: float = fmod(anim_t * 11.5, 1.0) if is_shooting else 1.0
	var recoil_kick: float = clampf(1.0 - recoil_phase * 2.6, 0.0, 1.0) if is_shooting else 0.0
	var lateral_sway: float = (sin(stride_phase) * 3.4 * move_ratio * k) if pose != "side" else 0.0
	var body_shift := Vector2(mv.x * 2.8 * k + lateral_sway, 0.0) - Vector2(cos_a, 0.0) * (1.5 * recoil_kick * k)
	var feet := Vector2(body_shift.x, 18.0 * k)

	# Ombra dinamica che si comprime/espande col salto della corsa + anello tattico sul pavimento
	var shadow_scale: float = 1.0 - stride_c * 0.16
	draw_ground_shadow(c, Vector2(body_shift.x * 0.45, feet.y), 18.5 * k * shadow_scale, 0.58)
	if not use_parade:
		draw_ground_ring(c, Vector2(0, feet.y), 26.0 * k, aura, anim_t, (2.8 if is_shooting else 2.2))
		var dir_2d := Vector2(cos_a, sin_a * PERSPECTIVE_Y)
		var tip_p := Vector2(0, feet.y) + dir_2d * 33.0 * k
		var side_p := Vector2(-sin_a, cos_a * PERSPECTIVE_Y) * 5.5 * k
		c.draw_colored_polygon(PackedVector2Array([
			tip_p,
			Vector2(0, feet.y) + dir_2d * 23.5 * k + side_p,
			Vector2(0, feet.y) + dir_2d * 23.5 * k - side_p
		]), Color(aura.r, aura.g, aura.b, 0.92))

	if is_moving:
		for t_i in range(4):
			var phase_p: float = fmod(anim_t * 4.5 + float(t_i) * 0.25, 1.0)
			var trail_off := -Vector2(mv.x, mv.y * 0.65) * (9.0 + phase_p * 26.0) * k + Vector2(sin(float(t_i) * 2.4) * 4.0 * k, 0.0)
			c.draw_circle(Vector2(0, feet.y - 2.0) + trail_off, (4.4 * (1.0 - phase_p)) * k, Color(aura.r, aura.g, aura.b, 0.42 * (1.0 - phase_p)))

	if pose == "back":
		_draw_hero_weapon_and_arms(c, weapon_id, anim_t, is_shooting, recoil_kick, aim_angle, pose, face_left, feet, bob, k, aura, false, stride_phase, move_ratio, skin_id)

	_draw_hero_articulated_body(c, pose, face_left, feet, bob, stride_phase, move_ratio, mv, k, aura, anim_t, skin_id)

	if pose != "back":
		_draw_hero_weapon_and_arms(c, weapon_id, anim_t, is_shooting, recoil_kick, aim_angle, pose, face_left, feet, bob, k, aura, use_parade, stride_phase, move_ratio, skin_id)


static func _draw_hero_2joint_leg(
	c: CanvasItem,
	thigh_tex: Texture2D,
	shin_tex: Texture2D,
	hip_pos: Vector2,
	thigh_rot: float,
	shin_rot: float,
	thigh_h: float,
	shin_h: float,
	flip_h: bool,
	modulate: Color
) -> void:
	var thigh_w: float = thigh_h * _aspect(thigh_tex, 0.56)
	var shin_w: float = shin_h * _aspect(shin_tex, 0.48)
	_draw_part(c, thigh_tex, hip_pos, thigh_rot, Rect2(Vector2(-thigh_w * 0.50, -thigh_h * 0.22), Vector2(thigh_w, thigh_h)), flip_h, modulate)
	var knee_pos: Vector2 = hip_pos + Vector2(0.0, thigh_h * 0.66).rotated(thigh_rot)
	_draw_part(c, shin_tex, knee_pos, shin_rot, Rect2(Vector2(-shin_w * 0.50, -shin_h * 0.16), Vector2(shin_w, shin_h)), flip_h, modulate)


static func _draw_hero_articulated_body(
	c: CanvasItem,
	pose: String,
	face_left: bool,
	feet: Vector2,
	bob: float,
	stride_phase: float,
	move_ratio: float,
	mv: Vector2,
	k: float,
	aura: Color,
	anim_t: float,
	skin_id: String = "v_runner"
) -> void:
	var upper_tex := CyberTheme.get_model_texture("res://assets/cyber_models/skin_" + skin_id + "_upper_" + pose + ".png")
	if not upper_tex:
		upper_tex = CyberTheme.get_model_texture("res://assets/cyber_models/hero_upper_" + pose + ".png")
	var thigh_tex := CyberTheme.get_model_texture("res://assets/cyber_models/skin_" + skin_id + "_thigh_" + pose + ".png")
	if not thigh_tex:
		thigh_tex = CyberTheme.get_model_texture("res://assets/cyber_models/hero_thigh_" + pose + ".png")
	var shin_tex := CyberTheme.get_model_texture("res://assets/cyber_models/skin_" + skin_id + "_shin_" + pose + ".png")
	if not shin_tex:
		shin_tex = CyberTheme.get_model_texture("res://assets/cyber_models/hero_shin_" + pose + ".png")
	if not upper_tex or not thigh_tex or not shin_tex:
		return

	var hip_y: float = feet.y - 29.2 * k + bob
	var face_sign: float = -1.0 if face_left else 1.0

	if pose == "side":
		var thigh_h: float = 18.2 * k
		var shin_h: float = 19.6 * k

		var f_sin: float = sin(stride_phase) * move_ratio
		var f_cos: float = cos(stride_phase) * move_ratio
		var r_sin: float = -f_sin
		var r_cos: float = -f_cos

		# Falcata atletica ampia e connessa al bacino (±40° sull'anca + flessione profonda del ginocchio!)
		var f_thigh_rot: float = -f_sin * 0.68 * face_sign
		var f_knee_bend: float = (0.08 + maxf(0.0, -f_cos) * 1.12 + maxf(0.0, -f_sin) * 0.30) * move_ratio
		var f_shin_rot: float = f_thigh_rot + f_knee_bend * face_sign

		var r_thigh_rot: float = -r_sin * 0.68 * face_sign
		var r_knee_bend: float = (0.08 + maxf(0.0, -r_cos) * 1.12 + maxf(0.0, -r_sin) * 0.30) * move_ratio
		var r_shin_rot: float = r_thigh_rot + r_knee_bend * face_sign

		var rear_hip := Vector2(feet.x + (-1.4 + r_sin * 2.6) * face_sign * k, hip_y + 1.4 * k - maxf(0.0, r_sin) * 2.8 * k)
		var front_hip := Vector2(feet.x + (1.4 + f_sin * 2.6) * face_sign * k, hip_y + 1.4 * k - maxf(0.0, f_sin) * 2.8 * k)

		_draw_hero_2joint_leg(c, thigh_tex, shin_tex, rear_hip, r_thigh_rot, r_shin_rot, thigh_h, shin_h, face_left, Color(0.66, 0.72, 0.84, 1.0))
		_draw_hero_2joint_leg(c, thigh_tex, shin_tex, front_hip, f_thigh_rot, f_shin_rot, thigh_h, shin_h, face_left, Color.WHITE)

		# Busto + Spallacci Samurai con inclinazione dinamica in avanti durante lo scatto!
		var uh: float = 44.5 * k
		var uw: float = uh * _aspect(upper_tex, 0.72)
		var lean_rot: float = (face_sign * 0.19 * move_ratio + sin(stride_phase * 2.0) * 0.045 * move_ratio) if move_ratio > 0.05 else sin(anim_t * 2.4) * 0.016
		var waist_pivot := Vector2(feet.x + face_sign * 1.8 * move_ratio * k, hip_y + 4.4 * k)
		_draw_part(c, upper_tex, waist_pivot, lean_rot, Rect2(Vector2(-uw * 0.50, -uh * 0.90), Vector2(uw, uh)), face_left, Color.WHITE)
	else:
		# Vista Frontale e Posteriore: corsa 2.5D ad alta escursione (ginocchio alto, stinco scorciato, suola stivale in spinta!)
		var base_thigh_h: float = 18.0 * k
		var base_shin_h: float = 19.4 * k

		var l_wave: float = sin(stride_phase) * move_ratio
		var r_wave: float = -l_wave

		var l_tuck: float = maxf(0.0, l_wave)
		var r_tuck: float = maxf(0.0, r_wave)
		var l_ext: float = maxf(0.0, -l_wave)
		var r_ext: float = maxf(0.0, -r_wave)

		var l_hip := Vector2(feet.x - 6.4 * k, hip_y - l_tuck * 9.5 * k + l_ext * 3.2 * k)
		var r_hip := Vector2(feet.x + 6.4 * k, hip_y - r_tuck * 9.5 * k + r_ext * 3.2 * k)

		var l_th: float = base_thigh_h * (1.0 - l_tuck * 0.24 + l_ext * 0.12)
		var l_sh: float = base_shin_h * (1.0 - l_tuck * 0.42 + l_ext * 0.12)
		var r_th: float = base_thigh_h * (1.0 - r_tuck * 0.24 + r_ext * 0.12)
		var r_sh: float = base_shin_h * (1.0 - r_tuck * 0.42 + r_ext * 0.12)

		var l_rot: float = -0.04 + l_wave * 0.14
		var r_rot: float = 0.04 - r_wave * 0.14

		var l_mod := Color.WHITE if l_wave <= 0.0 else Color(0.70, 0.76, 0.88, 1.0)
		var r_mod := Color.WHITE if r_wave <= 0.0 else Color(0.70, 0.76, 0.88, 1.0)

		_draw_hero_2joint_leg(c, thigh_tex, shin_tex, l_hip, l_rot, l_rot * 0.6, l_th, l_sh, false, l_mod)
		_draw_hero_2joint_leg(c, thigh_tex, shin_tex, r_hip, r_rot, r_rot * 0.6, r_th, r_sh, true, r_mod)

		# Dettaglio biomeccanico chiave in corsa verticale: suola corazzata alzata dietro (back) o ginocchiera in luce (front)
		if move_ratio > 0.15:
			if pose == "back":
				if l_tuck > 0.25:
					var sole_l := l_hip + Vector2(0.0, (l_th + l_sh) * 0.70)
					c.draw_circle(sole_l, 4.2 * k * l_tuck, Color(0.08, 0.11, 0.18, 0.95))
					c.draw_circle(sole_l, 2.2 * k * l_tuck, Color(aura.r, aura.g, aura.b, 0.78))
				if r_tuck > 0.25:
					var sole_r := r_hip + Vector2(0.0, (r_th + r_sh) * 0.70)
					c.draw_circle(sole_r, 4.2 * k * r_tuck, Color(0.08, 0.11, 0.18, 0.95))
					c.draw_circle(sole_r, 2.2 * k * r_tuck, Color(aura.r, aura.g, aura.b, 0.78))
			elif pose == "front":
				if l_tuck > 0.25:
					c.draw_circle(l_hip + Vector2(0.0, l_th * 0.65), 3.4 * k * l_tuck, Color(0.82, 0.92, 1.0, 0.55 * l_tuck))
				if r_tuck > 0.25:
					c.draw_circle(r_hip + Vector2(0.0, r_th * 0.65), 3.4 * k * r_tuck, Color(0.82, 0.92, 1.0, 0.55 * r_tuck))

		var uh: float = 45.0 * k
		var uw: float = uh * _aspect(upper_tex, 0.84)
		var sway_rot: float = clampf(mv.x * 0.08, -0.09, 0.09) - l_wave * 0.125
		var waist_pivot := Vector2(feet.x, hip_y + 4.5 * k)
		_draw_part(c, upper_tex, waist_pivot, sway_rot, Rect2(Vector2(-uw * 0.50, -uh * 0.90), Vector2(uw, uh)), false, Color.WHITE)

	# Reattori dorsali vibranti quando scatta verso Nord
	if pose == "back" and move_ratio > 0.1:
		var back_p := Vector2(feet.x, hip_y - 16.5 * k)
		var jet_r: float = (3.4 + sin(anim_t * 28.0) * 1.1) * k
		c.draw_circle(back_p + Vector2(-5.0 * k, 0), jet_r * 1.6, Color(aura.r, aura.g, aura.b, 0.28))
		c.draw_circle(back_p + Vector2(5.0 * k, 0), jet_r * 1.6, Color(aura.r, aura.g, aura_b_safe(aura), 0.28))
		c.draw_circle(back_p + Vector2(-5.0 * k, 0), jet_r, Color(0.85, 0.98, 1.0, 0.90))
		c.draw_circle(back_p + Vector2(5.0 * k, 0), jet_r, Color(0.85, 0.98, 1.0, 0.90))


static func aura_b_safe(c: Color) -> float:
	return c.b


static func _draw_arm_limb(c: CanvasItem, shoulder: Vector2, elbow: Vector2, hand: Vector2, k: float, is_rear: bool, skin_id: String = "v_runner") -> void:
	var shade: float = 0.72 if is_rear else 0.96
	var mod := Color(shade, shade, minf(1.0, shade * 1.05), 1.0)
	var u_tex := CyberTheme.get_model_texture("res://assets/cyber_models/skin_" + skin_id + "_arm_upper.png")
	if not u_tex:
		u_tex = CyberTheme.get_model_texture("res://assets/cyber_models/hero_arm_upper.png")
	var f_tex := CyberTheme.get_model_texture("res://assets/cyber_models/skin_" + skin_id + "_arm_forearm.png")
	if not f_tex:
		f_tex = CyberTheme.get_model_texture("res://assets/cyber_models/hero_arm_forearm.png")

	var u_vec: Vector2 = elbow - shoulder
	var u_len: float = maxf(4.0 * k, u_vec.length())
	var u_rot: float = u_vec.angle() - PI * 0.5
	if u_tex:
		var uw: float = 8.4 * k
		_draw_part(c, u_tex, shoulder, u_rot, Rect2(Vector2(-uw * 0.5, -1.2 * k), Vector2(uw, u_len + 2.4 * k)), false, mod)

	var f_vec: Vector2 = hand - elbow
	var f_len: float = maxf(4.0 * k, f_vec.length())
	var f_rot: float = f_vec.angle() - PI * 0.5
	if f_tex:
		var fw: float = 7.8 * k
		_draw_part(c, f_tex, elbow, f_rot, Rect2(Vector2(-fw * 0.5, -1.2 * k), Vector2(fw, f_len + 2.0 * k)), false, mod)


static func _draw_arm_gauntlet_grip(c: CanvasItem, hand: Vector2, weapon_angle: float, k: float, is_rear: bool) -> void:
	# Piccolo guanto corazzato metallico scuro che avvolge l'impugnatura (ZERO pallini rosa/neon!)
	var shade: float = 0.72 if is_rear else 0.96
	c.draw_set_transform(hand, weapon_angle, Vector2.ONE)
	c.draw_rect(Rect2(Vector2(-2.8 * k, -2.4 * k), Vector2(5.6 * k, 4.8 * k)), Color(0.08, 0.11, 0.17, 0.98), true)
	c.draw_rect(Rect2(Vector2(-2.1 * k, -1.7 * k), Vector2(4.2 * k, 3.4 * k)), Color(0.32 * shade, 0.39 * shade, 0.50 * shade, 1.0), true)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
	aura: Color,
	parade_mode: bool = false,
	stride_phase: float = 0.0,
	move_ratio: float = 0.0,
	skin_id: String = "v_runner"
) -> void:
	var is_melee: bool = (weapon_id == "katana" or weapon_id == "scythe")
	var is_one_handed: bool = (weapon_id == "pistol_base")
	var hip_y: float = feet.y - 29.2 * k + bob
	var shoulder_y: float = hip_y - 17.5 * k
	var face_sign: float = -1.0 if face_left else 1.0
	var is_sprinting: bool = (move_ratio > 0.10 and not is_shooting and not parade_mode)
	var arm_swing: float = sin(stride_phase) * move_ratio if is_sprinting else 0.0

	var eff_angle: float = aim_angle
	var push_back: float = recoil_kick * 4.2 * k

	if parade_mode:
		# Posa eroica da parata nei Menu: arma tenuta in diagonale tattica davanti al busto
		face_sign = 1.0
		eff_angle = (-0.58 if is_melee else -0.26) + sin(anim_t * 2.2) * 0.03
		push_back = 0.0
	elif is_sprinting:
		# Durante la corsa: oscillazione atletica di braccia e arma al ritmo dei passi!
		if pose == "side":
			var run_base: float = (PI + 0.22) if face_left else -0.22
			if is_melee:
				run_base = (PI + 0.55) if face_left else -0.55
			eff_angle = run_base + arm_swing * 0.30 * face_sign
		else:
			eff_angle = (-0.42 if pose == "back" else 0.48) + arm_swing * 0.24
	elif is_melee:
		if is_shooting:
			var slash_wave: float = sin(anim_t * 16.0)
			eff_angle = aim_angle + slash_wave * 1.12 * face_sign
			push_back = -absf(slash_wave) * 4.5 * k
		else:
			eff_angle = aim_angle - 0.54 * face_sign + sin(anim_t * 3.0) * 0.04

	var w_dir := Vector2.from_angle(eff_angle)
	var flip_wep_y: bool = (not parade_mode) and (cos(eff_angle) < -0.05)

	var front_shoulder := Vector2(feet.x - face_sign * 4.8 * k, shoulder_y)
	var rear_shoulder := Vector2(feet.x + face_sign * 5.8 * k, shoulder_y - 0.5 * k)
	if pose == "front" or pose == "back":
		var s_sign: float = 1.0 if cos(eff_angle) >= 0.0 else -1.0
		front_shoulder = Vector2(feet.x - s_sign * 9.8 * k, shoulder_y - arm_swing * 1.8 * k)
		rear_shoulder = Vector2(feet.x + s_sign * 9.8 * k, shoulder_y + arm_swing * 1.8 * k)

	var grip_pos: Vector2
	if parade_mode:
		grip_pos = Vector2(feet.x - 4.5 * k, hip_y - 6.5 * k)
	elif is_sprinting:
		var pump_off := Vector2(arm_swing * 4.6 * face_sign * k, -absf(arm_swing) * 3.2 * k)
		grip_pos = Vector2(feet.x + face_sign * 2.5 * k, hip_y - 9.5 * k) + w_dir * (5.5 * k) + pump_off
	else:
		var grip_dist: float = (8.8 if is_one_handed else (7.5 if is_melee else 5.8)) * k
		grip_pos = Vector2(feet.x + face_sign * 2.8 * k, hip_y - 10.5 * k) + w_dir * (grip_dist - push_back)

	var foregrip_dist: float = (6.2 if is_melee else 10.8) * k
	var foregrip_pos: Vector2 = grip_pos + w_dir * foregrip_dist

	var gravity_down := Vector2(0.0, 1.0)
	var rear_elbow: Vector2 = rear_shoulder.lerp(foregrip_pos, 0.52) + gravity_down * (6.0 * k)
	var front_elbow: Vector2 = front_shoulder.lerp(grip_pos, 0.50) + gravity_down * (7.2 * k) - Vector2(face_sign * 2.2 * k, 0.0)

	# 1. Braccia 3D della Skin attiva disegnate sotto/dietro l'arma
	if not is_one_handed:
		_draw_arm_limb(c, rear_shoulder, rear_elbow, foregrip_pos, k, true, skin_id)
	elif is_sprinting or pose == "front" or pose == "back":
		var off_side: float = (1.0 if cos(eff_angle) >= 0.0 else -1.0) if pose != "side" else -face_sign
		var off_hand := rear_shoulder + Vector2(off_side * (3.2 - arm_swing * 4.5) * k, (11.0 - arm_swing * 6.5) * k)
		var off_elbow := rear_shoulder.lerp(off_hand, 0.5) + Vector2(off_side * 2.5 * k, 3.0 * k)
		_draw_arm_limb(c, rear_shoulder, off_elbow, off_hand, k, true, skin_id)

	_draw_arm_limb(c, front_shoulder, front_elbow, grip_pos, k, false, skin_id)

	# 2. Modello 3D dell'arma allineato al millimetro su calcio (grip_uv) e asse canna (barrel_uv_y)
	var wep_tex := CyberTheme.get_item_model_texture(weapon_id, "ARMA")
	if wep_tex:
		var draw_len: float = 48.0 * k
		var grip_uv := Vector2(0.26, 0.54)
		var barrel_uv_y: float = 0.47
		match weapon_id:
			"pistol_base":
				draw_len = 26.0 * k
				grip_uv = Vector2(0.24, 0.64)
				barrel_uv_y = 0.39
			"smg":
				draw_len = 36.0 * k
				grip_uv = Vector2(0.32, 0.58)
				barrel_uv_y = 0.44
			"shotgun":
				draw_len = 48.0 * k
				grip_uv = Vector2(0.24, 0.54)
				barrel_uv_y = 0.47
			"laser_rifle":
				draw_len = 52.0 * k
				grip_uv = Vector2(0.26, 0.55)
				barrel_uv_y = 0.47
			"plasma_cannon":
				draw_len = 48.0 * k
				grip_uv = Vector2(0.28, 0.55)
				barrel_uv_y = 0.46
			"homing_wand":
				draw_len = 48.0 * k
				grip_uv = Vector2(0.27, 0.55)
				barrel_uv_y = 0.48
			"katana":
				draw_len = 56.0 * k
				grip_uv = Vector2(0.20, 0.50)
				barrel_uv_y = 0.50
			"scythe":
				draw_len = 58.0 * k
				grip_uv = Vector2(0.28, 0.50)
				barrel_uv_y = 0.50

		var sy: float = -1.0 if flip_wep_y else 1.0
		var muz_local_y: float = (barrel_uv_y - grip_uv.y) * draw_len
		var muz_local_x: float = (0.95 - grip_uv.x) * draw_len

		c.draw_set_transform_matrix(Transform2D(eff_angle, Vector2(1.0, sy), 0.0, grip_pos))
		if is_shooting and not is_melee and not parade_mode:
			c.draw_line(Vector2(muz_local_x, muz_local_y), Vector2(muz_local_x + 56.0 * k, muz_local_y), Color(aura.r, aura.g, aura.b, 0.38), 1.4)

		var w_rect := Rect2(-Vector2(draw_len * grip_uv.x, draw_len * grip_uv.y), Vector2(draw_len, draw_len))
		c.draw_texture_rect(wep_tex, w_rect, false, Color.WHITE)

		if is_shooting and recoil_kick > 0.22 and not parade_mode:
			if is_melee:
				c.draw_arc(Vector2(draw_len * 0.18, 0.0), draw_len * 0.66, -0.68, 0.68, 18, Color(aura.r, aura.g, aura.b, 0.72 * recoil_kick), 4.0 * k)
			else:
				var muz := Vector2(muz_local_x + 2.0 * k, muz_local_y)
				c.draw_circle(muz, 5.8 * k * recoil_kick, Color(aura.r, aura.g, aura.b, 0.85))
				c.draw_circle(muz, 2.6 * k * recoil_kick, Color.WHITE)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 3. Guanti metallici corazzati stretti esattamente sul grip
	if not is_one_handed:
		_draw_arm_gauntlet_grip(c, foregrip_pos, eff_angle, k * 0.90, true)
	_draw_arm_gauntlet_grip(c, grip_pos, eff_angle, k, false)


# ==============================================================================
# 2. NEMICO BASE 1: MANTIS STALKER (ARACNIDE AGILE CON ZAMPE ARTICOLATE)
# ==============================================================================
static func draw_melee_enemy(c: CanvasItem, world_id: String, anim_t: float, accent: Color, aim_angle: float, is_elite: bool = false, lunge_ratio: float = 0.0) -> void:
	var face_left := cos(aim_angle) < 0.0
	var prof := _get_world_profile(world_id)
	var glow: Color = prof.get("glow", accent)
	var armor_mod: Color = prof.get("armor", Color.WHITE)

	draw_ground_shadow(c, Vector2(0, 14), 20.0, 0.58)
	draw_ground_ring(c, Vector2(0, 14), 23.0, glow, anim_t * 0.7, 2.2)
	if is_elite:
		_draw_elite_crown(c, Vector2(0, 14), -38.0, 24.0, anim_t)

	# Preavviso luminoso quando sta caricando lo scatto (lunge_ratio > 0)
	if lunge_ratio > 0.05:
		var dir_v := Vector2.from_angle(aim_angle)
		c.draw_line(Vector2(0, 8), dir_v * (48.0 * lunge_ratio), Color(1.0, 0.28, 0.22, 0.65 * lunge_ratio), 3.0)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_melee_v2.png")
	if tex:
		var mod := armor_mod.lerp(Color(1.22, 1.10, 0.80), 0.30) if is_elite else armor_mod
		var pitch: float = 0.14 * lunge_ratio
		_draw_arachnid_unit(c, tex, Vector2(0, 16.0), 54.0, anim_t, 16.0, pitch, not face_left, mod)


# ==============================================================================
# 3. NEMICO BASE 2: HOVER-WASP SNIPER DRONE
# ==============================================================================
static func draw_ranged_enemy(c: CanvasItem, anim_t: float, _accent: Color, aim_angle: float, is_charging: bool, world_id: String = "world_1", is_elite: bool = false) -> void:
	var face_left := cos(aim_angle) < 0.0
	var hover := sin(anim_t * 4.6) * 4.5
	var wing_buzz := sin(anim_t * 24.0) * 0.035
	var bank_rot := cos(aim_angle) * 0.10 + sin(anim_t * 3.2) * 0.05 + wing_buzz
	var prof := _get_world_profile(world_id)
	var glow: Color = prof.get("glow", _accent)
	var armor_mod: Color = prof.get("armor", Color.WHITE)

	draw_ground_shadow(c, Vector2(0, 16), 16.5 - hover * 0.45, 0.46)
	draw_ground_ring(c, Vector2(0, 16), 22.0, glow, -anim_t * 0.85, 2.0)
	if is_elite:
		_draw_elite_crown(c, Vector2(0, 16), -42.0 + hover, 23.0, anim_t)

	var body_c := Vector2(0, -16.0 + hover)
	for s: float in [-1.0, 1.0]:
		var jet_p := body_c + Vector2(s * 9.0, 11.0)
		var flame_len: float = 6.0 + absf(sin(anim_t * 28.0 + s)) * 4.2
		c.draw_line(jet_p, jet_p + Vector2(-cos(aim_angle) * 2.2, flame_len), Color(glow.r, glow.g, glow.b, 0.72), 3.4)
		c.draw_circle(jet_p, 2.0, Color.WHITE)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_ranged_v2.png")
	if tex:
		var w: float = 58.0 * (1.0 + absf(wing_buzz) * 0.35)
		var h: float = w / maxf(0.2, _aspect(tex, 1.25))
		var mod := armor_mod.lerp(Color(1.22, 1.10, 0.80), 0.30) if is_elite else armor_mod
		_draw_part(c, tex, body_c, bank_rot, Rect2(Vector2(-w * 0.5, -h * 0.5), Vector2(w, h)), not face_left, mod)

	if is_charging:
		var eye := body_c + Vector2(cos(aim_angle) * 7.0, 7.0 + sin(aim_angle) * 3.0)
		c.draw_circle(eye, 5.5 + sin(anim_t * 28.0) * 1.6, Color(glow.r, glow.g, glow.b, 0.90))
		c.draw_circle(eye, 2.2, Color.WHITE)


# ==============================================================================
# 4. NEMICO BASE 3: GOLIATH MORTAR MECH (CON BUSTO+BRACCIA SEPARATI DALLE GAMBE!)
# ==============================================================================
static func draw_heavy_enemy(c: CanvasItem, anim_t: float, charge_ratio: float, aim_angle: float, world_id: String = "world_1", is_elite: bool = false) -> void:
	var face_left := cos(aim_angle) < 0.0
	var stride_phase: float = anim_t * 7.2
	var sway := sin(stride_phase) * 0.048
	var prof := _get_world_profile(world_id)
	var glow: Color = prof.get("glow", Color(1.0, 0.52, 0.12))
	var armor_mod: Color = prof.get("armor", Color.WHITE)

	draw_ground_shadow(c, Vector2(0, 20), 27.0, 0.62)
	draw_ground_ring(c, Vector2(0, 20), 30.0, glow, anim_t * 0.45, 2.4)
	if is_elite:
		_draw_elite_crown(c, Vector2(0, 20), -56.0, 31.0, anim_t)

	c.draw_set_transform(Vector2(0, 20), 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_arc(Vector2.ZERO, 34.0, -PI * 0.5, -PI * 0.5 + TAU * charge_ratio, 32, glow, 3.2)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var t_torso := CyberTheme.get_model_texture("res://assets/cyber_models/unit_heavy_torso.png")
	var t_ll := CyberTheme.get_model_texture("res://assets/cyber_models/unit_heavy_leg_l.png")
	var t_lr := CyberTheme.get_model_texture("res://assets/cyber_models/unit_heavy_leg_r.png")
	var heat := Color(armor_mod.r + charge_ratio * 0.22, armor_mod.g, armor_mod.b - charge_ratio * 0.12, 1.0)
	if t_torso and t_ll and t_lr:
		_draw_segmented_mech_walker(c, t_torso, t_ll, t_lr, Vector2(0, 22.0), 74.0, stride_phase, 0.22, 4.2, sway, not face_left, heat)
	else:
		var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_heavy_v2.png")
		if tex:
			_draw_arachnid_unit(c, tex, Vector2(0, 22.0), 72.0, anim_t, 7.2, 0.0, not face_left, heat)

	if charge_ratio > 0.62:
		var mortar := Vector2((-8.0 if face_left else 8.0), -47.0)
		c.draw_circle(mortar, 5.0 + charge_ratio * 5.5, Color(glow.r, glow.g, glow.b, 0.52))
		c.draw_circle(mortar, 2.2 + charge_ratio * 1.8, Color(1.0, 0.95, 0.65, 0.92))


# ==============================================================================
# 5. NUOVI 4 ARCHETIPI SPECIALI DI NEMICI (KAMIKAZE, SHIELDER, ASSASSIN, SPITTER)
# ==============================================================================
static func draw_special_enemy(
	c: CanvasItem,
	archetype: String,
	world_id: String,
	anim_t: float,
	aim_angle: float,
	action_ratio: float = 0.0,
	is_elite: bool = false,
	vel: Vector2 = Vector2.ZERO
) -> void:
	var face_left := cos(aim_angle) < 0.0
	var prof := _get_world_profile(world_id)
	var armor_mod: Color = prof.get("armor", Color.WHITE)

	match archetype:
		"KAMIKAZE":
			# Ticker Kamikaze Bot: ragno-bomba instabile con anello esplosivo d'innesco!
			var warn_col := Color(1.0, 0.32, 0.08, 1.0).lerp(Color(1.0, 0.08, 0.18, 1.0), action_ratio)
			draw_ground_shadow(c, Vector2(0, 14), 18.0, 0.55)
			if action_ratio > 0.02:
				# Raggio di detonazione imminente chiaramente telegrafato sul ponte!
				c.draw_set_transform(Vector2(0, 14), 0.0, Vector2(1.0, PERSPECTIVE_Y))
				c.draw_circle(Vector2.ZERO, 92.0 * action_ratio, Color(1.0, 0.18, 0.08, 0.24 * action_ratio))
				c.draw_arc(Vector2.ZERO, 92.0, 0.0, TAU, 36, Color(1.0, 0.32, 0.12, 0.85), 2.8)
				c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			else:
				draw_ground_ring(c, Vector2(0, 14), 21.0, warn_col, anim_t * 1.4, 2.2)

			if is_elite:
				_draw_elite_crown(c, Vector2(0, 14), -36.0, 22.0, anim_t)

			var k_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_kamikaze.png")
			if k_tex:
				var pulse_scale: float = 1.0 + action_ratio * absf(sin(anim_t * 28.0)) * 0.16
				var flash_mod := armor_mod.lerp(Color(1.8, 0.65, 0.35, 1.0), action_ratio * (0.5 + 0.5 * sin(anim_t * 32.0)))
				_draw_arachnid_unit(c, k_tex, Vector2(0, 15.0), 50.0 * pulse_scale, anim_t, 20.0, 0.08, face_left, flash_mod)

		"SHIELDER":
			# Aegis Riot Enforcer: soldato corazzato con barriera frontale direzionale!
			var sh_col := Color(0.08, 0.88, 1.0, 1.0)
			draw_ground_shadow(c, Vector2(0, 18), 23.0, 0.60)
			draw_ground_ring(c, Vector2(0, 18), 26.0, sh_col, anim_t * 0.55, 2.4)
			if is_elite:
				_draw_elite_crown(c, Vector2(0, 18), -50.0, 27.0, anim_t)

			var s_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_shielder.png")
			if s_tex:
				var walk_bob: float = -absf(cos(anim_t * 8.2)) * 2.6
				var walk_sway: float = sin(anim_t * 8.2) * 0.045
				var h: float = 68.0
				var w: float = h * _aspect(s_tex, 0.82)
				_draw_part(c, s_tex, Vector2(0, 19.0 + walk_bob), walk_sway, Rect2(Vector2(-w * 0.5, -h), Vector2(w, h)), face_left, armor_mod)

			# Arco di Barriera Olografica Frontale (mostra chiaramente l'angolo protetto davanti a lui!)
			var sh_flash: float = clampf(action_ratio, 0.0, 1.0)
			c.draw_set_transform(Vector2(0, 12), 0.0, Vector2(1.0, 0.62))
			c.draw_arc(Vector2.ZERO, 34.0, aim_angle - 0.95, aim_angle + 0.95, 20, Color(0.15, 0.94, 1.0, 0.62 + sh_flash * 0.35), 4.0 + sh_flash * 3.0)
			c.draw_arc(Vector2.ZERO, 34.0, aim_angle - 0.75, aim_angle + 0.75, 16, Color(1.0, 1.0, 1.0, 0.45 + sh_flash * 0.50), 1.8)
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		"ASSASSIN":
			# Cyber-Wraith Assassin: ninja stealth con scie olografiche durante il blink/scatto!
			var w_col := Color(0.86, 0.22, 1.0, 1.0)
			draw_ground_shadow(c, Vector2(0, 16), 19.0, 0.52)
			draw_ground_ring(c, Vector2(0, 16), 22.0, w_col, anim_t * 1.8, 2.0)
			if is_elite:
				_draw_elite_crown(c, Vector2(0, 16), -46.0, 23.0, anim_t)

			var a_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_assassin.png")
			if a_tex:
				var h: float = 62.0
				var w: float = h * _aspect(a_tex, 0.83)
				var dash_lean: float = clampf(vel.x * 0.0006, -0.18, 0.18) + sin(anim_t * 14.0) * 0.04
				var run_bob: float = -absf(sin(anim_t * 14.0)) * 3.2
				# Scie olografiche violette durante lo scatto
				if action_ratio > 0.1 or vel.length() > 170.0:
					var back_v: Vector2 = -vel.normalized() if vel.length() > 10.0 else -Vector2.from_angle(aim_angle)
					for g_i in range(1, 3):
						var g_pos := Vector2(0, 17.0 + run_bob) + back_v * (float(g_i) * 14.0)
						_draw_part(c, a_tex, g_pos, dash_lean, Rect2(Vector2(-w * 0.5, -h), Vector2(w, h)), face_left, Color(0.78, 0.22, 1.0, 0.36 - float(g_i) * 0.12))
				_draw_part(c, a_tex, Vector2(0, 17.0 + run_bob), dash_lean, Rect2(Vector2(-w * 0.5, -h), Vector2(w, h)), face_left, armor_mod)

		"SPITTER":
			# Bio-Cryo Spitter Turret: base quadrupede + testa cannone rotante indipendente!
			var sp_col: Color = prof.get("glow", Color(0.22, 1.0, 0.62))
			draw_ground_shadow(c, Vector2(0, 17), 24.0, 0.58)
			draw_ground_ring(c, Vector2(0, 17), 26.0, sp_col, -anim_t * 0.6, 2.2)
			if is_elite:
				_draw_elite_crown(c, Vector2(0, 17), -46.0, 27.0, anim_t)

			var b_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_spitter_base.png")
			var h_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_spitter_head.png")
			if b_tex and h_tex:
				var susp_bob: float = sin(anim_t * 5.5) * 1.4
				var bw: float = 56.0
				var bh: float = bw / maxf(0.2, _aspect(b_tex, 1.35))
				_draw_part(c, b_tex, Vector2(0, 18.0 + susp_bob * 0.4), 0.0, Rect2(Vector2(-bw * 0.5, -bh), Vector2(bw, bh)), false, armor_mod)

				# La torretta superiore ruota e rincula verso il giocatore!
				var hw: float = 48.0
				var hh: float = hw / maxf(0.2, _aspect(h_tex, 1.65))
				var recoil_off := -Vector2.from_angle(aim_angle) * (action_ratio * 4.5)
				var turret_pivot := Vector2(0, 18.0 - bh * 0.86 + susp_bob) + recoil_off
				var head_rot: float = clampf(sin(aim_angle) * 0.28, -0.28, 0.28)
				_draw_part(c, h_tex, turret_pivot, head_rot, Rect2(Vector2(-hw * 0.46, -hh * 0.55), Vector2(hw, hh)), face_left, armor_mod)
				if action_ratio > 0.35:
					var muz := turret_pivot + Vector2((-1.0 if face_left else 1.0) * hw * 0.48, 0.0).rotated(head_rot)
					c.draw_circle(muz, 5.5 * action_ratio, Color(sp_col.r, sp_col.g, sp_col.b, 0.85))
					c.draw_circle(muz, 2.4 * action_ratio, Color.WHITE)
			else:
				var full_t := CyberTheme.get_model_texture("res://assets/cyber_models/unit_spitter.png")
				if full_t:
					_draw_arachnid_unit(c, full_t, Vector2(0, 18.0), 56.0, anim_t, 8.0, 0.0, face_left, armor_mod)


# ==============================================================================
# 6. 8 VERI BOSS 3D UNICI PER OGNI MONDO CON ANATOMIA DEDICATA
# ==============================================================================
static func draw_boss(c: CanvasItem, world_id: String, anim_t: float, boss_col: Color, in_phase_2: bool, aim_angle: float, attack_telegraph: float = 0.0) -> void:
	var prof := _get_world_profile(world_id)
	var active_col: Color = Color(1.0, 0.16, 0.24, 1.0) if in_phase_2 else prof.get("glow", boss_col)
	var face_left := cos(aim_angle) < 0.0
	var stride_phase: float = anim_t * (6.4 if in_phase_2 else 4.6)

	draw_ground_shadow(c, Vector2(0, 44), 54.0, 0.68)
	draw_ground_ring(c, Vector2(0, 44), 62.0, active_col, anim_t, 3.4)

	# Preavviso olografico a terra prima della raffica del Boss!
	if attack_telegraph > 0.05:
		c.draw_set_transform(Vector2(0, 44), 0.0, Vector2(1.0, PERSPECTIVE_Y))
		c.draw_circle(Vector2.ZERO, 76.0 * attack_telegraph, Color(active_col.r, active_col.g, active_col.b, 0.22 * attack_telegraph))
		c.draw_arc(Vector2.ZERO, 76.0, 0.0, TAU * attack_telegraph, 40, Color(1.0, 0.92, 0.38, 0.92), 4.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if in_phase_2:
		c.draw_set_transform(Vector2(0, 44), 0.0, Vector2(1.0, PERSPECTIVE_Y))
		var shock_r: float = 52.0 + fmod(anim_t * 85.0, 38.0)
		c.draw_arc(Vector2.ZERO, shock_r, 0.0, TAU, 40, Color(1.0, 0.22, 0.22, 0.55 * (1.0 - (shock_r - 52.0) / 38.0)), 2.8)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var tint: Color = Color(1.16, 0.90, 0.90, 1.0) if in_phase_2 else prof.get("armor", Color.WHITE)

	# Mappa 12 Settori -> Rig Anatomico 3D ad Alta Definizione (con armatura/energia unica per distretto!)
	var rig_id: String = world_id
	match world_id:
		"world_8": rig_id = "titan"    # Kuro-Shinobi / Mecha-Oni Kabuki
		"world_9": rig_id = "world_5"  # Ares Dreadnought Militech
		"world_10": rig_id = "world_6" # Leviathan Cryo Abissale
		"world_11": rig_id = "world_4" # Celestial Valkyrie Lunare
		"world_12": rig_id = "world_8" # Omega Protocol A.R.G.O.N.

	# 1. Boss Bipedi Giganti -> Gambe separate senza tagliare le armi!
	if rig_id in ["world_1", "world_5", "world_8"]:
		var b_torso := CyberTheme.get_model_texture("res://assets/cyber_models/boss_" + rig_id + "_torso.png")
		var b_ll := CyberTheme.get_model_texture("res://assets/cyber_models/boss_" + rig_id + "_leg_l.png")
		var b_lr := CyberTheme.get_model_texture("res://assets/cyber_models/boss_" + rig_id + "_leg_r.png")
		if b_torso and b_ll and b_lr:
			var sway: float = sin(stride_phase) * 0.042
			_draw_segmented_mech_walker(c, b_torso, b_ll, b_lr, Vector2(0, 46.0), 148.0, stride_phase, 0.18, 6.2, sway, face_left, tint)
			return

	var tex: Texture2D = null
	if rig_id == "titan":
		tex = CyberTheme.get_model_texture("res://assets/cyber_models/unit_boss_titan.png")
	else:
		tex = CyberTheme.get_model_texture("res://assets/cyber_models/boss_" + rig_id + ".png")
	if not tex:
		tex = CyberTheme.get_model_texture("res://assets/cyber_models/unit_boss_titan.png")
	if not tex:
		return

	# 2. Boss Aracnide / Quadrupede / Mecha-Titan
	if rig_id in ["world_2", "world_6", "titan"]:
		var beast_h: float = 148.0 if rig_id != "world_2" else 142.0
		var strike_pitch: float = attack_telegraph * 0.10
		_draw_arachnid_unit(c, tex, Vector2(0, 46.0), beast_h, anim_t, 9.5 if in_phase_2 else 6.8, strike_pitch, not face_left, tint)
		return

	# 3. Boss Volanti / Alati
	var hover_y: float = sin(anim_t * 3.2) * 7.5
	var wing_breath: float = 1.0 + sin(anim_t * 5.6) * 0.035
	var bank: float = cos(aim_angle) * 0.06 + sin(anim_t * 2.4) * 0.035
	var fly_h: float = 128.0 if rig_id == "world_3" else 152.0
	var fly_w: float = fly_h * _aspect(tex, 1.0) * wing_breath
	var center_p := Vector2(0, -24.0 + hover_y)
	c.draw_circle(center_p + Vector2(0, fly_h * 0.28), 18.0 + sin(anim_t * 14.0) * 3.0, Color(active_col.r, active_col.g, active_col.b, 0.20))
	_draw_part(c, tex, center_p, bank, Rect2(Vector2(-fly_w * 0.5, -fly_h * 0.5), Vector2(fly_w, fly_h)), face_left and rig_id == "world_3", tint)


# ==============================================================================
# 7. OSTACOLO E CASSA RIFORNIMENTI 3D CON DETTAGLI BIOMA
# ==============================================================================
static func draw_obstacle(c: CanvasItem, accent_col: Color, world_id: String = "world_1", variant_idx: int = 0) -> void:
	var prof := _get_world_profile(world_id)
	var glow: Color = prof.get("glow", accent_col)
	var armor_mod: Color = prof.get("armor", Color.WHITE)

	# Sceglie prop urbani 3D HD coerenti col mondo in cui si combatte!
	var prop_pool: Array[String] = ["prop_barricade", "prop_vending", "prop_cybercar"]
	match world_id:
		"world_1", "world_6", "world_10":
			prop_pool = ["prop_biopod", "prop_barricade", "prop_biopod"]
		"world_2", "world_5", "world_9":
			prop_pool = ["prop_barricade", "prop_cybercar", "prop_barricade"]
		"world_4", "world_7", "world_12":
			prop_pool = ["prop_biopod", "prop_barricade", "prop_vending"]
		_: # Night City / Eliporto Arasaka / Vicolo Kabuki / Selene
			prop_pool = ["prop_vending", "prop_cybercar", "prop_barricade"]

	var chosen_prop: String = prop_pool[posmod(variant_idx, prop_pool.size())]
	draw_ground_shadow(c, Vector2(0, 22), 36.0, 0.55)
	c.draw_set_transform(Vector2(0, 22), 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_circle(Vector2.ZERO, 36.0, Color(glow.r, glow.g, glow.b, 0.10))
	c.draw_arc(Vector2.ZERO, 36.0, 0.0, TAU, 28, Color(glow.r, glow.g, glow.b, 0.52), 1.8)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var obs_tex := CyberTheme.get_model_texture("res://assets/cyber_models/" + chosen_prop + ".png")
	if not obs_tex:
		obs_tex = CyberTheme.get_model_texture("res://assets/cyber_models/prop_obstacle.png")
	if obs_tex:
		var draw_sz := Vector2(88, 88) if chosen_prop == "prop_cybercar" else Vector2(80, 84)
		c.draw_texture_rect(obs_tex, Rect2(Vector2(-draw_sz.x * 0.5, -draw_sz.y + 28.0), draw_sz), false, armor_mod)
	else:
		c.draw_rect(Rect2(Vector2(-24, -40), Vector2(48, 64)), Color(0.12, 0.15, 0.22, 1.0), true)


static func draw_loot_crate(c: CanvasItem, anim_t: float, hp_ratio: float) -> void:
	var pulse := 0.75 + sin(anim_t * 6.0) * 0.25
	var hover := sin(anim_t * 2.5) * 1.5
	draw_ground_shadow(c, Vector2(0, 18), 22.0, 0.52)
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
