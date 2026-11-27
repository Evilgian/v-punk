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
# 1. EROE: OPERATIVI CYBERPUNK 3D STILIZZATI CON CICLO DI CORSA REALE A SPRITE-SHEET
# ==============================================================================
const HERO_RUN_SEQ: Array[int] = [1, 2, 3, 2]


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
	skin_override: String = "",
	shot_kick_override: float = -1.0
) -> void:
	var gl: Node = null
	var ml := Engine.get_main_loop()
	if ml is SceneTree:
		gl = (ml as SceneTree).root.get_node_or_null("Global")
	var skin_id: String = skin_override
	if skin_id.is_empty() and gl and "equipped_skin_id" in gl:
		skin_id = str(gl.equipped_skin_id)
	if skin_id.is_empty():
		skin_id = "v_runner"
	var aura: Color = Color(0.0, 0.94, 1.0, 1.0)
	if gl and gl.has_method("get_player_accent_color"):
		aura = gl.get_player_accent_color()

	var k: float = body_h / 68.0
	var use_parade: bool = parade_mode or (not is_moving and not is_shooting and body_h <= 72.0 and sin(aim_angle) > 0.35)
	var sin_a: float = sin(aim_angle)
	var cos_a: float = cos(aim_angle)

	var mv: Vector2 = move_vec.limit_length(1.0) if is_moving else Vector2.ZERO
	if is_moving and mv.length_squared() < 0.01:
		mv = Vector2(cos_a, sin_a)
	var move_ratio: float = clampf(mv.length(), 0.0, 1.0) if (is_moving and not use_parade) else 0.0

	# Direzione dello sguardo 3/4: in parata guarda a destra; se spara punta il bersaglio; se corre guarda dove va!
	var face_left: bool = false
	if not use_parade:
		if is_shooting:
			face_left = cos_a < -0.05
		elif move_ratio > 0.08 and absf(mv.x) > 0.08:
			face_left = mv.x < 0.0
		else:
			face_left = cos_a < -0.05
	var face_sign: float = -1.0 if face_left else 1.0

	# Se arretra sparando (kiting), inverte la sequenza dei frame così fa veri passi all'indietro senza moonwalk!
	var stride_dir: int = 1
	if move_ratio > 0.08 and is_shooting:
		if mv.x * face_sign < -0.15:
			stride_dir = -1

	var recoil_phase: float = fmod(anim_t * 11.5, 1.0) if is_shooting else 1.0
	var recoil_kick: float = clampf(shot_kick_override, 0.0, 1.0) if shot_kick_override >= 0.0 else (clampf(1.0 - recoil_phase * 2.6, 0.0, 1.0) if is_shooting else 0.0)

	# Selezione frame sprite-sheet: f0 = Idle pronto, [f1, f2, f3, f2] = Ciclo di corsa reale a 4 tempi!
	var frame_idx: int = 0
	var run_fps: float = 10.4
	var step_wave: float = sin(anim_t * run_fps * PI * 0.5)
	if move_ratio > 0.08:
		var seq_step: int = posmod(int(floor(anim_t * run_fps)) * stride_dir, 4)
		frame_idx = HERO_RUN_SEQ[seq_step]

	var idle_amt: float = 1.0 - move_ratio
	var idle_breath: float = sin(anim_t * 4.0) * idle_amt
	var run_hop: float = -absf(step_wave) * 2.8 * move_ratio
	var bob: float = (run_hop + idle_breath * 1.4 - recoil_kick * 1.3) * k

	# Squash & stretch elastico da vero action-game 3D stilizzato (stile Brawl Stars / Archero 2)
	var squash_y: float = 1.0 + idle_breath * 0.022 + (absf(step_wave) - 0.5) * 0.036 * move_ratio
	var squash_x: float = 1.0 - idle_breath * 0.012 - (absf(step_wave) - 0.5) * 0.024 * move_ratio
	var lean_rot: float = clampf(mv.x * 0.085, -0.09, 0.09) * move_ratio - face_sign * recoil_kick * 0.055

	var recoil_shift := -Vector2(cos_a, sin_a * 0.30) * (3.4 * recoil_kick * k)
	var feet := Vector2(recoil_shift.x, 19.0 * k)

	# 1. Ombra morbida dinamica + anello tattico luminoso sul pavimento
	var shadow_scale: float = 1.0 - absf(step_wave) * 0.12 * move_ratio
	draw_ground_shadow(c, Vector2(feet.x * 0.5, feet.y), 20.5 * k * shadow_scale, 0.60)
	if not use_parade:
		draw_ground_ring(c, Vector2(0, feet.y), 26.5 * k, aura, anim_t, (2.8 if is_shooting else 2.2))
		var dir_2d := Vector2(cos_a, sin_a * PERSPECTIVE_Y)
		var tip_p := Vector2(0, feet.y) + dir_2d * 33.5 * k
		var side_p := Vector2(-sin_a, cos_a * PERSPECTIVE_Y) * 5.5 * k
		c.draw_colored_polygon(PackedVector2Array([
			tip_p,
			Vector2(0, feet.y) + dir_2d * 24.0 * k + side_p,
			Vector2(0, feet.y) + dir_2d * 24.0 * k - side_p
		]), Color(aura.r, aura.g, aura.b, 0.92))

	# Scia di passetti neon sul terreno durante la corsa
	if move_ratio > 0.08:
		for t_i in range(3):
			var phase_p: float = fmod(anim_t * 3.8 + float(t_i) * 0.33, 1.0)
			var trail_off := -Vector2(mv.x, mv.y * 0.65) * (8.0 + phase_p * 22.0) * k + Vector2(sin(float(t_i) * 2.3) * 3.2 * k, 0.0)
			c.draw_circle(Vector2(0, feet.y - 1.5) + trail_off, (4.2 * (1.0 - phase_p)) * k, Color(aura.r, aura.g, aura.b, 0.38 * (1.0 - phase_p)))

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/skin_" + skin_id + "_f" + str(frame_idx) + ".png")
	if not tex:
		tex = CyberTheme.get_model_texture("res://assets/cyber_models/skin_v_runner_f" + str(frame_idx) + ".png")
	if not tex:
		tex = CyberTheme.get_model_texture("res://assets/cyber_models/unit_hero.png")

	var sprite_sz: float = 78.0 * k
	# Nelle texture 256x256 la suola degli scarponi appoggia a y = 242/256 (0.9453)
	var foot_pad_bottom: float = sprite_sz * (1.0 - 242.0 / 256.0)

	if tex:
		var pivot := Vector2(feet.x, feet.y + bob)
		c.draw_set_transform(pivot, lean_rot, Vector2(face_sign * squash_x, squash_y))
		c.draw_texture_rect(tex, Rect2(Vector2(-sprite_sz * 0.5, -sprite_sz + foot_pad_bottom), Vector2(sprite_sz, sprite_sz)), false, Color.WHITE)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# L'arma 3D è SEMPRE disegnata in primo piano davanti/a lato dell'operativo (MAI nascosta dietro il corpo!)
	_draw_stylized_hero_weapon(c, weapon_id, anim_t, is_shooting, recoil_kick, aim_angle, face_left, feet, bob, sprite_sz, k, aura, use_parade, move_ratio)


static func _get_weapon_visual_spec(weapon_id: String, k: float) -> Dictionary:
	match weapon_id:
		"pistol_base":
			return {"len": 31.0 * k, "grip": Vector2(0.24, 0.64), "barrel_y": 0.39}
		"smg":
			return {"len": 39.0 * k, "grip": Vector2(0.32, 0.58), "barrel_y": 0.44}
		"shotgun":
			return {"len": 48.0 * k, "grip": Vector2(0.24, 0.54), "barrel_y": 0.47}
		"laser_rifle":
			return {"len": 52.0 * k, "grip": Vector2(0.26, 0.55), "barrel_y": 0.47}
		"plasma_cannon":
			return {"len": 50.0 * k, "grip": Vector2(0.28, 0.55), "barrel_y": 0.46}
		"homing_wand":
			return {"len": 47.0 * k, "grip": Vector2(0.27, 0.55), "barrel_y": 0.48}
		"katana":
			return {"len": 54.0 * k, "grip": Vector2(0.20, 0.50), "barrel_y": 0.50}
		"scythe":
			return {"len": 56.0 * k, "grip": Vector2(0.28, 0.50), "barrel_y": 0.50}
	return {"len": 46.0 * k, "grip": Vector2(0.26, 0.54), "barrel_y": 0.47}


static func get_hero_muzzle_offset(weapon_id: String, aim_angle: float, body_h: float = 88.0) -> Vector2:
	var k: float = body_h / 68.0
	var sprite_sz: float = 78.0 * k
	var face_left: bool = cos(aim_angle) < -0.05
	var face_sign: float = -1.0 if face_left else 1.0
	var vert_factor: float = absf(sin(aim_angle))
	var feet := Vector2(0.0, 19.0 * k)
	var hand_anchor := Vector2(
		feet.x + face_sign * (8.5 + vert_factor * 11.5) * k,
		feet.y - sprite_sz * 0.37 - maxf(0.0, -sin(aim_angle)) * 4.5 * k
	)
	var w_dir := Vector2.from_angle(aim_angle)
	var grip_pos: Vector2 = hand_anchor + w_dir * (7.5 * k)
	var spec := _get_weapon_visual_spec(weapon_id, k)
	var draw_len: float = float(spec["len"])
	var grip_uv: Vector2 = spec["grip"]
	var barrel_uv_y: float = float(spec["barrel_y"])
	var sy: float = -1.0 if cos(aim_angle) < -0.05 else 1.0
	var muz_local := Vector2((0.95 - grip_uv.x) * draw_len, (barrel_uv_y - grip_uv.y) * draw_len * sy)
	return grip_pos + muz_local.rotated(aim_angle)


static func _draw_stylized_hero_weapon(
	c: CanvasItem,
	weapon_id: String,
	anim_t: float,
	is_shooting: bool,
	recoil_kick: float,
	aim_angle: float,
	face_left: bool,
	feet: Vector2,
	bob: float,
	sprite_sz: float,
	k: float,
	aura: Color,
	parade_mode: bool,
	move_ratio: float
) -> void:
	var wep_tex := CyberTheme.get_item_model_texture(weapon_id, "ARMA")
	if not wep_tex:
		return

	var is_melee: bool = (weapon_id == "katana" or weapon_id == "scythe")
	var face_sign: float = -1.0 if face_left else 1.0
	var is_sprinting: bool = (move_ratio > 0.10 and not is_shooting and not parade_mode)

	var eff_angle: float = aim_angle
	var push_back: float = recoil_kick * 6.2 * k
	if parade_mode:
		face_sign = 1.0
		eff_angle = (-0.42 if is_melee else -0.18) + sin(anim_t * 2.6) * 0.065
		push_back = 0.0
	elif is_sprinting:
		var run_sway: float = sin(anim_t * 10.4 * PI * 0.5) * 0.12 * face_sign
		var base_a: float = (PI + 0.16) if face_left else -0.16
		if is_melee:
			base_a = (PI + 0.42) if face_left else -0.42
		eff_angle = base_a + run_sway
	elif is_melee:
		if is_shooting:
			var slash_wave: float = sin(anim_t * 16.0)
			eff_angle = aim_angle + slash_wave * 1.15 * face_sign
			push_back = -absf(slash_wave) * 5.0 * k
		else:
			eff_angle = aim_angle - 0.48 * face_sign + sin(anim_t * 3.4) * 0.06
	else:
		eff_angle = aim_angle - recoil_kick * 0.12 * face_sign + sin(anim_t * 3.8) * 0.030 * (1.0 - move_ratio)

	var flip_wep_y: bool = (not parade_mode) and (cos(eff_angle) < -0.05)
	var w_dir := Vector2.from_angle(eff_angle)
	var vert_factor: float = 0.0 if parade_mode else absf(sin(eff_angle))

	# Quando mira in alto/basso sposta lateralmente il braccio armato così l'arma è SEMPRE 100% visibile di fianco al visore!
	var hand_anchor := Vector2(
		feet.x + face_sign * (8.5 + vert_factor * 11.5) * k,
		feet.y - sprite_sz * 0.37 + bob - maxf(0.0, -sin(eff_angle)) * (0.0 if parade_mode else 4.5 * k)
	)
	if parade_mode:
		hand_anchor = Vector2(feet.x + 5.5 * k, feet.y - sprite_sz * 0.35 + bob)
	var grip_pos: Vector2 = hand_anchor + w_dir * ((3.5 if parade_mode else 7.5) * k - push_back)

	var spec := _get_weapon_visual_spec(weapon_id, k)
	var draw_len: float = float(spec["len"])
	var grip_uv: Vector2 = spec["grip"]
	var barrel_uv_y: float = float(spec["barrel_y"])

	var sy: float = -1.0 if flip_wep_y else 1.0
	var muz_local_x: float = (0.95 - grip_uv.x) * draw_len
	var muz_local_y: float = (barrel_uv_y - grip_uv.y) * draw_len

	c.draw_set_transform_matrix(Transform2D(eff_angle, Vector2(1.0, sy), 0.0, grip_pos))
	if is_shooting and not is_melee and not parade_mode:
		c.draw_line(Vector2(muz_local_x, muz_local_y), Vector2(muz_local_x + 58.0 * k, muz_local_y), Color(aura.r, aura.g, aura.b, 0.44), 1.8)

	var w_rect := Rect2(-Vector2(draw_len * grip_uv.x, draw_len * grip_uv.y), Vector2(draw_len, draw_len))
	c.draw_texture_rect(wep_tex, w_rect, false, Color.WHITE)

	# Guanto corazzato stilizzato sul calcio dell'arma
	c.draw_circle(Vector2.ZERO, 3.8 * k, Color(0.06, 0.09, 0.15, 0.98))
	c.draw_circle(Vector2.ZERO, 2.6 * k, Color(0.28, 0.35, 0.48, 1.0))

	if is_shooting and recoil_kick > 0.18 and not parade_mode:
		if is_melee:
			c.draw_arc(Vector2(draw_len * 0.18, 0.0), draw_len * 0.66, -0.72, 0.72, 18, Color(aura.r, aura.g, aura.b, 0.78 * recoil_kick), 4.2 * k)
		else:
			var muz := Vector2(muz_local_x + 2.5 * k, muz_local_y)
			c.draw_circle(muz, 7.2 * k * recoil_kick, Color(aura.r, aura.g, aura.b, 0.88))
			c.draw_circle(muz, 3.4 * k * recoil_kick, Color.WHITE)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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

			var use_run_sh: bool = (int(floor(anim_t * 5.8)) % 2) == 1
			var s_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_shielder_run.png" if use_run_sh else "res://assets/cyber_models/unit_shielder.png")
			if not s_tex:
				s_tex = CyberTheme.get_model_texture("res://assets/cyber_models/unit_shielder.png")
			if s_tex:
				var walk_bob: float = -absf(sin(anim_t * 5.8 * PI * 0.5)) * 2.4
				var walk_sway: float = sin(anim_t * 5.8 * PI * 0.5) * 0.035
				var sh_sz: float = 76.0
				var pad_b: float = sh_sz * (1.0 - 242.0 / 256.0)
				_draw_part(c, s_tex, Vector2(0, 19.0 + walk_bob), walk_sway, Rect2(Vector2(-sh_sz * 0.5, -sh_sz + pad_b), Vector2(sh_sz, sh_sz)), face_left, armor_mod)

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
				var as_sz: float = 72.0
				var pad_b: float = as_sz * (1.0 - 242.0 / 256.0)
				var dash_lean: float = clampf(vel.x * 0.00045, -0.13, 0.13) + sin(anim_t * 11.0) * 0.032
				var run_bob: float = -absf(sin(anim_t * 11.0)) * 2.8
				var sq_y: float = 1.0 + (absf(sin(anim_t * 11.0)) - 0.5) * 0.04
				var sq_x: float = 1.0 - (absf(sin(anim_t * 11.0)) - 0.5) * 0.03
				var sx_a: float = -1.0 if face_left else 1.0
				# Scie olografiche violette durante lo scatto
				if action_ratio > 0.1 or vel.length() > 170.0:
					var back_v: Vector2 = -vel.normalized() if vel.length() > 10.0 else -Vector2.from_angle(aim_angle)
					for g_i in range(1, 3):
						var g_pos := Vector2(0, 17.0 + run_bob) + back_v * (float(g_i) * 14.0)
						c.draw_set_transform(g_pos, dash_lean, Vector2(sx_a * sq_x, sq_y))
						c.draw_texture_rect(a_tex, Rect2(Vector2(-as_sz * 0.5, -as_sz + pad_b), Vector2(as_sz, as_sz)), false, Color(0.78, 0.22, 1.0, 0.36 - float(g_i) * 0.12))
				c.draw_set_transform(Vector2(0, 17.0 + run_bob), dash_lean, Vector2(sx_a * sq_x, sq_y))
				c.draw_texture_rect(a_tex, Rect2(Vector2(-as_sz * 0.5, -as_sz + pad_b), Vector2(as_sz, as_sz)), false, armor_mod)
				c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		"SPITTER":
			# Bio-Cryo Spitter Turret: modello 3D integro (zero giunture tagliate!) + rinculo dinamico!
			var sp_col: Color = prof.get("glow", Color(0.22, 1.0, 0.62))
			draw_ground_shadow(c, Vector2(0, 17), 24.0, 0.58)
			draw_ground_ring(c, Vector2(0, 17), 26.0, sp_col, -anim_t * 0.6, 2.2)
			if is_elite:
				_draw_elite_crown(c, Vector2(0, 17), -46.0, 27.0, anim_t)

			var full_t := CyberTheme.get_model_texture("res://assets/cyber_models/unit_spitter.png")
			if full_t:
				var recoil_pitch: float = -action_ratio * 0.14
				_draw_arachnid_unit(c, full_t, Vector2(0, 18.0), 58.0, anim_t, 9.5, recoil_pitch, face_left, armor_mod)
				if action_ratio > 0.30:
					var muz := Vector2((-1.0 if face_left else 1.0) * 24.0, -24.0)
					c.draw_circle(muz, 5.5 * action_ratio, Color(sp_col.r, sp_col.g, sp_col.b, 0.85))
					c.draw_circle(muz, 2.4 * action_ratio, Color.WHITE)


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
		var side_px := 106.0 if chosen_prop == "prop_cybercar" else 92.0
		var draw_sz := Vector2(side_px, side_px)
		c.draw_texture_rect(obs_tex, Rect2(Vector2(-draw_sz.x * 0.5, -draw_sz.y + 32.0), draw_sz), false, armor_mod)
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
