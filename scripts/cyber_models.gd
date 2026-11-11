class_name CyberModels
extends RefCounted

# ==============================================================================
# RENDERING 2.5D "ARCHERO-STYLE" v5.0:
# - Eroe 3D Articolato (2 Gambe Indipendenti + Busto 3D senza braccia morte +
#   2 Braccia Corazzate IK a 2 snodi + Spallaccio Samurai 3D + Impugnatura Credibile)
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
# 1. EROE: CYBER-RONIN EXO-SLAYER 3D CON GAMBE INDIPENDENTI E BRACCIA IK
# ==============================================================================
static func draw_hero(c: CanvasItem, weapon_id: String, anim_t: float, is_moving: bool, is_shooting: bool, aim_angle: float, move_vec: Vector2 = Vector2.ZERO, body_h: float = 68.0) -> void:
	var aura := Global.get_player_accent_color()
	var sin_a: float = sin(aim_angle)
	var cos_a: float = cos(aim_angle)
	var k: float = body_h / 68.0

	var pose: String = "side"
	if sin_a < -0.45:
		pose = "back"
	elif sin_a > 0.55:
		pose = "front"
	var face_left: bool = cos_a < -0.05

	var mv: Vector2 = move_vec.limit_length(1.0) if is_moving else Vector2.ZERO
	if is_moving and mv.length_squared() < 0.01:
		mv = Vector2(cos_a, sin_a)
	var move_ratio: float = clampf(mv.length(), 0.0, 1.0) if is_moving else 0.0

	# Locomozione naturale a 2 gambe indipendenti (senza shear/skew artificiale)
	var stride_phase: float = anim_t * 13.5
	var stride_s: float = sin(stride_phase) * move_ratio
	var stride_c: float = absf(cos(stride_phase)) * move_ratio
	var bob: float = (-stride_c * 3.2 + sin(anim_t * 3.2) * (1.0 - move_ratio) * 1.1) * k
	var recoil_phase: float = fmod(anim_t * 11.5, 1.0) if is_shooting else 1.0
	var recoil_kick: float = clampf(1.0 - recoil_phase * 2.6, 0.0, 1.0) if is_shooting else 0.0
	var body_shift := Vector2(mv.x * 2.0 * k, 0.0) - Vector2(cos_a, 0.0) * (1.8 * recoil_kick * k)
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
			c.draw_circle(Vector2(0, feet.y - 3.0) + trail_off, (4.8 - float(t_i) * 1.3) * k, Color(aura.r, aura.g, aura.b, 0.38 - float(t_i) * 0.10))

	# Mirando a Nord l'arma è impugnata davanti al petto -> dietro la schiena rispetto alla camera
	if pose == "back":
		_draw_hero_weapon_and_arms(c, weapon_id, anim_t, is_shooting, recoil_kick, aim_angle, pose, face_left, feet, bob, k, aura)

	_draw_hero_articulated_body(c, pose, face_left, feet, body_h, bob, stride_s, move_ratio, mv, k, aura, anim_t)

	if pose != "back":
		_draw_hero_weapon_and_arms(c, weapon_id, anim_t, is_shooting, recoil_kick, aim_angle, pose, face_left, feet, bob, k, aura)


static func _draw_hero_articulated_body(
	c: CanvasItem,
	pose: String,
	face_left: bool,
	feet: Vector2,
	body_h: float,
	bob: float,
	stride_s: float,
	move_ratio: float,
	mv: Vector2,
	k: float,
	aura: Color,
	anim_t: float
) -> void:
	var upper_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_upper_" + pose + ".png")
	var leg_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_leg_" + pose + ".png")
	if not upper_tex or not leg_tex:
		return

	var hip_y: float = feet.y - 28.0 * k + bob
	var face_sign: float = -1.0 if face_left else 1.0

	if pose == "side":
		# 2 Gambe 3D indipendenti in vista laterale: oscillazione opposta + sollevamento ginocchio
		var leg_w: float = 21.0 * k
		var leg_h: float = 34.0 * k
		var rear_rot: float = -stride_s * 0.46
		var front_rot: float = stride_s * 0.46
		var rear_lift: float = -maxf(0.0, -stride_s) * 5.8 * k
		var front_lift: float = -maxf(0.0, stride_s) * 5.8 * k

		var rear_hip := Vector2(feet.x - face_sign * 2.5 * k, hip_y + rear_lift)
		var front_hip := Vector2(feet.x + face_sign * 2.0 * k, hip_y + front_lift)

		# Gamba posteriore (leggermente ombreggiata per profondità 3D)
		_draw_part(c, leg_tex, rear_hip, rear_rot, Rect2(Vector2(-leg_w * 0.50, -leg_h * 0.12), Vector2(leg_w, leg_h)), face_left, Color(0.74, 0.78, 0.86, 1.0))
		# Gamba anteriore
		_draw_part(c, leg_tex, front_hip, front_rot, Rect2(Vector2(-leg_w * 0.50, -leg_h * 0.12), Vector2(leg_w, leg_h)), face_left, Color.WHITE)

		# Busto + Casco 3D con inclinazione dinamica in avanti durante la corsa
		var uw: float = 48.0 * k
		var uh: float = 50.0 * k
		var lean_rot: float = clampf(mv.x * 0.13, -0.14, 0.14) if move_ratio > 0.05 else 0.0
		var waist_pivot := Vector2(feet.x, hip_y + 3.5 * k)
		_draw_part(c, upper_tex, waist_pivot, lean_rot, Rect2(Vector2(-uw * 0.48, -uh * 0.86), Vector2(uw, uh)), face_left, Color.WHITE)
	else:
		# Vista Frontale / Spalle: 2 gambe 3D simmetriche che alternano passo verticale e scala prospettica
		var leg_w: float = 19.0 * k
		var leg_h: float = 34.0 * k
		var l_lift: float = -maxf(0.0, stride_s) * 7.5 * k
		var r_lift: float = -maxf(0.0, -stride_s) * 7.5 * k
		var l_scale: float = 1.0 + stride_s * 0.08
		var r_scale: float = 1.0 - stride_s * 0.08
		var l_rot: float = stride_s * 0.08
		var r_rot: float = stride_s * 0.08

		var hip_l := Vector2(feet.x - 8.5 * k, hip_y + l_lift)
		var hip_r := Vector2(feet.x + 8.5 * k, hip_y + r_lift)
		var l_mod := Color.WHITE if stride_s >= 0.0 else Color(0.80, 0.84, 0.90, 1.0)
		var r_mod := Color.WHITE if stride_s <= 0.0 else Color(0.80, 0.84, 0.90, 1.0)

		_draw_part(c, leg_tex, hip_l, l_rot, Rect2(Vector2(-leg_w * 0.52 * l_scale, -leg_h * 0.10 * l_scale), Vector2(leg_w * l_scale, leg_h * l_scale)), false, l_mod)
		_draw_part(c, leg_tex, hip_r, r_rot, Rect2(Vector2(-leg_w * 0.52 * r_scale, -leg_h * 0.10 * r_scale), Vector2(leg_w * r_scale, leg_h * r_scale)), true, r_mod)

		# Busto + Casco 3D con leggero rollio di bilanciamento
		var uw: float = 48.0 * k
		var uh: float = 50.0 * k
		var sway_rot: float = clampf(mv.x * 0.08, -0.09, 0.09) - stride_s * 0.04
		var waist_pivot := Vector2(feet.x, hip_y + 3.5 * k)
		_draw_part(c, upper_tex, waist_pivot, sway_rot, Rect2(Vector2(-uw * 0.50, -uh * 0.86), Vector2(uw, uh)), false, Color.WHITE)

	# Dettaglio visiera luminosa o propulsori dorsali
	if pose != "back":
		var head_p := Vector2(feet.x + (-1.0 if face_left else 1.0) * (2.5 * k if pose == "side" else 0.0), hip_y - 31.0 * k)
		c.draw_circle(head_p, 5.5 * k, Color(aura.r, aura.g, aura.b, 0.26))
		c.draw_circle(head_p, 2.2 * k, Color(1, 1, 1, 0.55))
	else:
		var back_p := Vector2(feet.x, hip_y - 16.0 * k)
		var jet_r: float = ((3.8 + sin(anim_t * 26.0) * 1.1) if move_ratio > 0.1 else 2.2) * k
		c.draw_circle(back_p + Vector2(-5.0 * k, 0), jet_r, Color(aura.r, aura.g, aura.b, 0.82))
		c.draw_circle(back_p + Vector2(5.0 * k, 0), jet_r, Color(aura.r, aura.g, aura.b, 0.82))


static func _draw_arm_limb(c: CanvasItem, shoulder: Vector2, elbow: Vector2, hand: Vector2, k: float, aura: Color, is_rear: bool) -> void:
	var shade: float = 0.72 if is_rear else 1.0
	var dark_out := Color(0.04, 0.05, 0.09, 0.98)
	var armor_col := Color(0.18 * shade, 0.22 * shade, 0.30 * shade, 1.0)
	var hi_col := Color(0.36 * shade, 0.42 * shade, 0.54 * shade, 1.0)
	var neon_col := Color(aura.r * shade, aura.g * shade, aura.b * shade, 0.95)

	# Omero corazzato (Spalla -> Gomito)
	c.draw_line(shoulder, elbow, dark_out, 8.8 * k)
	c.draw_line(shoulder, elbow, armor_col, 5.6 * k)
	c.draw_line(shoulder.lerp(elbow, 0.2), shoulder.lerp(elbow, 0.8), hi_col, 2.2 * k)

	# Snodo cibernetico del gomito
	c.draw_circle(elbow, 4.2 * k, dark_out)
	c.draw_circle(elbow, 2.8 * k, armor_col)
	c.draw_circle(elbow, 1.4 * k, neon_col)

	# Avambraccio corazzato (Gomito -> Mano sull'impugnatura)
	c.draw_line(elbow, hand, dark_out, 8.2 * k)
	c.draw_line(elbow, hand, armor_col, 5.2 * k)
	c.draw_line(elbow.lerp(hand, 0.18), elbow.lerp(hand, 0.85), neon_col, 1.9 * k)

	# Guanto d'arme chiuso sul calcio dell'arma
	c.draw_circle(hand, 4.4 * k, dark_out)
	c.draw_circle(hand, 3.0 * k, hi_col)
	c.draw_circle(hand, 1.5 * k, neon_col)


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
	var down_sign: float = -1.0 if face_left else 1.0
	var is_melee: bool = (weapon_id == "katana" or weapon_id == "scythe")
	var is_one_handed: bool = (weapon_id == "pistol_base" or weapon_id == "homing_wand")

	var chest_center := Vector2(feet.x, feet.y - 45.0 * k + bob)
	var front_shoulder: Vector2 = chest_center + Vector2((-1.0 if not face_left else 1.0) * 3.0 * k, 1.0 * k)
	var rear_shoulder: Vector2 = chest_center + Vector2((1.0 if not face_left else -1.0) * 8.0 * k, -1.0 * k)
	if pose == "front" or pose == "back":
		var s_sign: float = 1.0 if dir.x >= 0.0 else -1.0
		front_shoulder = chest_center + Vector2(-s_sign * 11.5 * k, 1.0 * k)
		rear_shoulder = chest_center + Vector2(s_sign * 11.5 * k, 0.5 * k)

	# Angolo effettivo dell'arma: rinculo balistico o fendente dinamico per Katana/Falce
	var eff_angle: float = aim_angle
	var push_back: float = recoil_kick * 5.2 * k
	if is_melee and is_shooting:
		var slash_wave: float = sin(anim_t * 14.0)
		eff_angle = aim_angle + slash_wave * 1.15 * down_sign
		push_back = -absf(slash_wave) * 6.0 * k

	var w_dir := Vector2.from_angle(eff_angle)
	var w_perp := Vector2(-w_dir.y, w_dir.x) * down_sign

	var grip_dist: float = (13.5 if is_one_handed else (12.5 if is_melee else 13.0)) * k
	var grip_pos: Vector2 = chest_center + w_dir * (grip_dist - push_back) + Vector2(0.0, 2.5 * k)
	var foregrip_pos: Vector2 = grip_pos + w_dir * ((7.5 if is_melee else 10.5) * k) + w_perp * (1.2 * k)

	var rear_elbow: Vector2 = rear_shoulder.lerp(foregrip_pos, 0.52) + w_perp * (5.8 * k)
	var front_elbow: Vector2 = front_shoulder.lerp(grip_pos, 0.50) + w_perp * (7.5 * k)

	# 1. Braccio di supporto posteriore (dietro l'arma)
	if not is_one_handed:
		_draw_arm_limb(c, rear_shoulder, rear_elbow, foregrip_pos, k, aura, true)
	elif pose == "front" or pose == "back":
		var off_hand := rear_shoulder + Vector2((4.0 if dir.x >= 0.0 else -4.0) * k, 12.0 * k)
		var off_elbow := rear_shoulder.lerp(off_hand, 0.5) + Vector2((2.5 if dir.x >= 0.0 else -2.5) * k, 2.0 * k)
		_draw_arm_limb(c, rear_shoulder, off_elbow, off_hand, k, aura, true)

	# 2. Arma 3D ancorata esattamente sul calcio (grip_pos) e orientata verso il bersaglio
	var wep_tex := CyberTheme.get_item_model_texture(weapon_id, "ARMA")
	if wep_tex:
		var draw_len: float = 44.0 * k
		var grip_uv := Vector2(0.28, 0.52)
		match weapon_id:
			"pistol_base":
				draw_len = 34.0 * k
				grip_uv = Vector2(0.26, 0.54)
			"smg":
				draw_len = 40.0 * k
				grip_uv = Vector2(0.32, 0.52)
			"shotgun":
				draw_len = 46.0 * k
				grip_uv = Vector2(0.26, 0.52)
			"laser_rifle":
				draw_len = 50.0 * k
				grip_uv = Vector2(0.28, 0.50)
			"plasma_cannon":
				draw_len = 48.0 * k
				grip_uv = Vector2(0.30, 0.52)
			"homing_wand":
				draw_len = 44.0 * k
				grip_uv = Vector2(0.26, 0.50)
			"katana":
				draw_len = 56.0 * k
				grip_uv = Vector2(0.20, 0.52)
			"scythe":
				draw_len = 58.0 * k
				grip_uv = Vector2(0.24, 0.52)

		var sy: float = -1.0 if face_left else 1.0
		c.draw_set_transform_matrix(Transform2D(eff_angle, Vector2(1.0, sy), 0.0, grip_pos))
		if is_shooting and not is_melee:
			c.draw_line(Vector2(draw_len * 0.65, 0.0), Vector2(draw_len * 1.85, 0.0), Color(1.0, 0.15, 0.25, 0.42), 1.5)
		var w_rect := Rect2(-Vector2(draw_len * grip_uv.x, draw_len * grip_uv.y), Vector2(draw_len, draw_len))
		c.draw_texture_rect(wep_tex, w_rect, false, Color.WHITE)

		if is_shooting and recoil_kick > 0.25:
			if is_melee:
				c.draw_arc(Vector2(draw_len * 0.15, 0.0), draw_len * 0.65, -0.60, 0.60, 14, Color(aura.r, aura.g, aura.b, 0.65 * recoil_kick), 4.0 * k)
			else:
				var muz := Vector2(draw_len * (1.0 - grip_uv.x) + 2.5 * k, -1.5 * k)
				c.draw_circle(muz, 6.8 * k * recoil_kick, Color(aura.r, aura.g, aura.b, 0.80))
				c.draw_circle(muz, 3.2 * k * recoil_kick, Color.WHITE)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 3. Braccio primario anteriore + Spallaccio Samurai 3D sulla spalla
	_draw_arm_limb(c, front_shoulder, front_elbow, grip_pos, k, aura, false)
	var pauldron_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_pauldron_3d.png")
	if pauldron_tex:
		var p_rot: float = clampf((front_elbow - front_shoulder).angle() - PI * 0.5, -0.40, 0.40)
		var pw: float = 18.0 * k
		var ph: float = 20.0 * k
		_draw_part(c, pauldron_tex, front_shoulder + Vector2(0, -1.5 * k), p_rot, Rect2(Vector2(-pw * 0.5, -ph * 0.42), Vector2(pw, ph)), face_left, Color.WHITE)


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
# 3. NEMICO MELEE: MANTIS STALKER 3D CON VARIANTI BIOMA E SUPPORTO ÉLITE
# ==============================================================================
static func draw_melee_enemy(c: CanvasItem, world_id: String, anim_t: float, accent: Color, aim_angle: float, is_elite: bool = false) -> void:
	var face_left := cos(aim_angle) < 0.0
	var scuttle := absf(sin(anim_t * 16.0)) * 2.6
	var tilt := cos(aim_angle) * 0.08 + sin(anim_t * 16.0) * 0.04
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
		var squash := Vector2(1.0 + scuttle * 0.012, 1.0 - scuttle * 0.012)
		var mod := armor_mod.lerp(Color(1.25, 1.12, 0.82), 0.30) if is_elite else armor_mod
		_draw_grounded_sprite(c, tex, Vector2(cos(aim_angle) * 2.0, 16.0 - scuttle), 52.0, tilt, not face_left, squash, mod)
	else:
		c.draw_circle(Vector2(0, -8), 14.0, glow)


# ==============================================================================
# 4. NEMICO RANGED: HOVER-WASP SNIPER DRONE 3D CON VARIANTI BIOMA E ÉLITE
# ==============================================================================
static func draw_ranged_enemy(c: CanvasItem, anim_t: float, _accent: Color, aim_angle: float, is_charging: bool, world_id: String = "world_1", is_elite: bool = false) -> void:
	var face_left := cos(aim_angle) < 0.0
	var hover := sin(anim_t * 3.8) * 4.5
	var bank_rot := cos(aim_angle) * 0.10 + sin(anim_t * 2.6) * 0.06
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
	_draw_world_enemy_addons(c, style, body_c, 22.0, glow, sec, anim_t)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_ranged_v2.png")
	if tex:
		var w: float = 60.0
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
# 5. NEMICO PESANTE: GOLIATH SIEGE JUGGERNAUT 3D CON VARIANTI BIOMA E ÉLITE
# ==============================================================================
static func draw_heavy_enemy(c: CanvasItem, anim_t: float, charge_ratio: float, aim_angle: float, world_id: String = "world_1", is_elite: bool = false) -> void:
	var face_left := cos(aim_angle) < 0.0
	var stomp := absf(sin(anim_t * 5.5)) * 2.6
	var sway := sin(anim_t * 5.5) * 0.05
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
		_draw_grounded_sprite(c, tex, Vector2(0, 22.0), 74.0 - stomp, sway, face_left, Vector2(1.0 + stomp * 0.01, 1.0), heat)
	else:
		c.draw_circle(Vector2(0, -16), 22.0, glow)
	if charge_ratio > 0.6:
		var mortar := Vector2((-8.0 if face_left else 8.0), -46.0)
		c.draw_circle(mortar, 5.0 + charge_ratio * 6.0, Color(glow.r, glow.g, glow.b, 0.55))
		c.draw_circle(mortar, 2.5 + charge_ratio * 2.0, Color(1.0, 0.95, 0.6, 0.9))


# ==============================================================================
# 6. BOSS UNICI PER OGNI MONDO (boss_world_1.png .. boss_world_8.png)
# ==============================================================================
static func draw_boss(c: CanvasItem, world_id: String, anim_t: float, boss_col: Color, in_phase_2: bool, aim_angle: float) -> void:
	var prof := _get_world_profile(world_id)
	var active_col: Color = Color(1.0, 0.15, 0.22, 1.0) if in_phase_2 else prof.get("glow", boss_col)
	var face_left := cos(aim_angle) < 0.0
	var stomp := absf(sin(anim_t * (4.2 if in_phase_2 else 2.8))) * 3.0
	var sway := sin(anim_t * (4.2 if in_phase_2 else 2.8)) * 0.04

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
		_draw_grounded_sprite(c, tex, Vector2(0, 46.0), 146.0 - stomp, sway, face_left, Vector2(1.0 + stomp * 0.006, 1.0), tint)
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
