class_name CyberModels
extends RefCounted

# ==============================================================================
# RENDERING 2.5D "ARCHERO-STYLE": i personaggi sono modelli 3D-shaded (PBR pre-renderizzati)
# disegnati IN PIEDI (non ruotati dall'alto), con ombra ellittica a terra, anello olografico
# in prospettiva, rimbalzo di camminata, specchiatura verso il bersaglio e arma che ruota
# attorno alla mano. Il giocatore percepisce volume e profondità invece di sagome piatte.
# ==============================================================================

const PERSPECTIVE_Y: float = 0.42 # Schiacciamento verticale degli elementi a terra (camera inclinata ~65°)

## Ombra morbida ellittica a terra (3 strati sfumati = ambient occlusion)
static func draw_ground_shadow(c: CanvasItem, center: Vector2, radius: float, strength: float = 0.5) -> void:
	c.draw_set_transform(center, 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_circle(Vector2.ZERO, radius * 1.25, Color(0, 0, 0, strength * 0.25))
	c.draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, strength * 0.45))
	c.draw_circle(Vector2.ZERO, radius * 0.65, Color(0, 0, 0, strength * 0.55))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

## Anello olografico a terra in prospettiva (selezione / aura)
static func draw_ground_ring(c: CanvasItem, center: Vector2, radius: float, col: Color, anim_t: float, width: float = 2.4) -> void:
	c.draw_set_transform(center, 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_circle(Vector2.ZERO, radius, Color(col.r, col.g, col.b, 0.10))
	c.draw_arc(Vector2.ZERO, radius, anim_t * 2.2, anim_t * 2.2 + PI * 1.35, 32, Color(col.r, col.g, col.b, 0.85), width)
	c.draw_arc(Vector2.ZERO, radius, anim_t * 2.2 + PI * 1.5, anim_t * 2.2 + PI * 1.85, 12, Color(1, 1, 1, 0.6), width * 0.8)
	c.draw_arc(Vector2.ZERO, radius * 0.72, -anim_t * 1.6, -anim_t * 1.6 + PI, 20, Color(col.r, col.g, col.b, 0.45), 1.4)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

## Disegna una texture 3D in piedi, specchiata se guarda a sinistra
static func _draw_upright(c: CanvasItem, tex: Texture2D, rect: Rect2, face_left: bool, modulate: Color = Color.WHITE) -> void:
	if not tex: return
	if face_left:
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))
		c.draw_texture_rect(tex, Rect2(Vector2(-rect.position.x - rect.size.x, rect.position.y), rect.size), false, modulate)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		c.draw_texture_rect(tex, rect, false, modulate)

## Disegna una texture 3D con punto di perno, rotazione dinamica e specchiatura
static func _draw_part(c: CanvasItem, tex: Texture2D, pivot: Vector2, rot: float, local_rect: Rect2, flip_h: bool = false, modulate: Color = Color.WHITE) -> void:
	if not tex:
		return
	var sx: float = -1.0 if flip_h else 1.0
	c.draw_set_transform(pivot, rot, Vector2(sx, 1.0))
	c.draw_texture_rect(tex, local_rect, false, modulate)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ==============================================================================
# 1. EROE: RIG 3D ARTICOLATO MULTI-ANGOLO (FRONTE / PROFILO / SPALLE) + CORSA REALE
# ==============================================================================
static func draw_hero(c: CanvasItem, weapon_id: String, anim_t: float, is_moving: bool, is_shooting: bool, aim_angle: float, move_vec: Vector2 = Vector2.ZERO) -> void:
	var aura := Global.get_player_accent_color()
	var sin_a: float = sin(aim_angle)
	var cos_a: float = cos(aim_angle)

	# Determina posa 3D in base alla direzione del nemico:
	# - Nord / NE / NW (sin_a < -0.30): visto di SPALLE / 3-4 SPALLE verso i nemici!
	# - Est / Ovest (abs(sin_a) <= 0.38): visto di PROFILO 3/4 verso il bersaglio!
	# - Sud / Menu Podium (sin_a > 0.38): visto FRONTALE / 3-4 FRONTE!
	var pose: String = "SIDE"
	if sin_a < -0.30:
		pose = "BACK"
	elif sin_a > 0.38:
		pose = "FRONT"

	var face_left: bool = cos_a < -0.05
	var turn_x: float = cos_a * 4.5 # Parallasse 3D testa/spalle quando mira in diagonale

	var mv: Vector2 = move_vec.limit_length(1.0) if is_moving else Vector2.ZERO
	if is_moving and mv.length_squared() < 0.01:
		mv = Vector2(cos_a, sin_a)

	# Fisica di locomozione: falcata gambe, sollevamento ginocchia, inclinazione busto e rinculo
	var stride_phase: float = anim_t * 15.5
	var stride_s: float = sin(stride_phase)
	var stride_c: float = cos(stride_phase)
	var bob: float = absf(stride_s) * 4.2 if is_moving else sin(anim_t * 3.2) * 1.1
	var lean_rot: float = clampf(mv.x * 0.19, -0.20, 0.20) if is_moving else 0.0
	var recoil_kick: float = 1.0 if (is_shooting and fmod(anim_t * 14.0, 1.0) < 0.30) else 0.0
	var body_shift: Vector2 = (Vector2(mv.x * 3.2, mv.y * 1.8) if is_moving else Vector2.ZERO) - Vector2(cos_a, sin_a * 0.5) * (2.6 * recoil_kick)

	# Ombra dinamica e anello olografico direzionale a terra
	draw_ground_shadow(c, Vector2(body_shift.x * 0.4, 17.0), 20.0 - (bob * 0.35 if is_moving else 0.0), 0.62)
	draw_ground_ring(c, Vector2(0, 17.0), 26.0, aura, anim_t, 2.6 if is_shooting else 2.0)

	# Indicatore direzionale di mira a terra (freccia olografica verso il bersaglio attivo)
	var dir_2d := Vector2(cos_a, sin_a * PERSPECTIVE_Y)
	var tip_p := Vector2(0, 17.0) + dir_2d * 31.0
	var side_p := Vector2(-sin_a, cos_a * PERSPECTIVE_Y) * 5.0
	c.draw_colored_polygon(PackedVector2Array([
		tip_p,
		Vector2(0, 17.0) + dir_2d * 23.0 + side_p,
		Vector2(0, 17.0) + dir_2d * 23.0 - side_p
	]), Color(aura.r, aura.g, aura.b, 0.85))

	# Scie energetiche e anelli di passo durante la corsa
	if is_moving:
		for k in range(3):
			var trail_off := -Vector2(mv.x, mv.y * 0.65) * (10.0 + float(k) * 8.0)
			c.draw_circle(Vector2(0, 14.0) + trail_off, 5.2 - float(k) * 1.4, Color(aura.r, aura.g, aura.b, 0.34 - float(k) * 0.09))

	var tint := Color(0.88 + aura.r * 0.12, 0.88 + aura.g * 0.12, 0.88 + aura.b * 0.12, 1.0)
	var boot_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_boot.png")
	var pauldron_tex := CyberTheme.get_model_texture("res://assets/cyber_models/hero_pauldron.png")

	# Se mira verso Nord ("BACK"), l'arma è davanti al petto dell'eroe (quindi dietro la schiena rispetto alla camera)
	if pose == "BACK":
		_draw_hero_weapon(c, weapon_id, anim_t, is_shooting, aim_angle, face_left, -bob + body_shift.y, body_shift.x + turn_x * 0.6)

	# Mantello energetico dietro al corpo nelle viste FRONT e SIDE
	if pose != "BACK":
		_draw_hero_cape(c, Vector2(body_shift.x - cos_a * 3.0, -14.0 - bob + body_shift.y), mv, anim_t, aura, 0.82)

	# --- GAMBE 3D ARTICOLATE INDIPENDENTI (FALCTA REALE + SOLLEVAMENTO GINOCCHIA) ---
	var hip_sep: float = 3.2 if pose == "SIDE" else 7.2
	var hip_y: float = 1.0 - bob * 0.55 + body_shift.y
	var hip_l := Vector2(-hip_sep + body_shift.x, hip_y)
	var hip_r := Vector2(hip_sep + body_shift.x, hip_y)

	var swing_vec := Vector2(mv.x * 10.5, mv.y * 5.2)
	if is_moving and absf(mv.x) < 0.22:
		swing_vec.x = 2.4 # Leggera apertura naturale durante lo sprint verticale
	var lift_l: float = maxf(0.0, -stride_c) * 6.8 if is_moving else 0.0
	var lift_r: float = maxf(0.0, stride_c) * 6.8 if is_moving else 0.0

	var foot_l: Vector2 = Vector2(-hip_sep, 14.5) + (swing_vec * stride_s if is_moving else Vector2.ZERO) + Vector2(0.0, -lift_l)
	var foot_r: Vector2 = Vector2(hip_sep, 14.5) - (swing_vec * stride_s if is_moving else Vector2.ZERO) + Vector2(0.0, -lift_r)
	var rot_l: float = (-stride_s * 0.34 * signf(mv.x if absf(mv.x) > 0.1 else 1.0)) if is_moving else 0.0
	var rot_r: float = (stride_s * 0.34 * signf(mv.x if absf(mv.x) > 0.1 else 1.0)) if is_moving else 0.0

	# Ordina il disegno delle gambe in base alla profondità Y
	var draw_left_first: bool = foot_l.y <= foot_r.y
	for step_i in range(2):
		var is_l: bool = (step_i == 0) if draw_left_first else (step_i == 1)
		var hp_p: Vector2 = hip_l if is_l else hip_r
		var ft_p: Vector2 = foot_l if is_l else foot_r
		var ft_r: float = rot_l if is_l else rot_r
		var knee_p: Vector2 = hp_p.lerp(ft_p, 0.5) + Vector2(mv.x * 2.5, -2.5)
		c.draw_line(hp_p, knee_p, Color(0.14, 0.18, 0.28, 1.0), 5.2)
		c.draw_line(knee_p, ft_p, Color(0.22, 0.28, 0.42, 1.0), 4.4)
		c.draw_circle(knee_p, 2.5, Color(aura.r, aura.g, aura.b, 0.75))
		if boot_tex:
			_draw_part(c, boot_tex, ft_p, ft_r, Rect2(Vector2(-9, -11), Vector2(18, 18)), face_left, tint)
		else:
			c.draw_circle(ft_p, 5.0, Color(0.2, 0.25, 0.36, 1.0))

	# --- BUSTO, SPALLACCI E CASCO 3D ORIENTATI VERSO I NEMICI ---
	var torso_pivot := Vector2(body_shift.x, -11.0 - bob + body_shift.y)
	var head_pivot := Vector2(body_shift.x + turn_x * 0.75, -26.5 - bob + body_shift.y + sin_a * 1.4)

	if pose == "BACK":
		var torso_back := CyberTheme.get_model_texture("res://assets/cyber_models/hero_torso_back.png")
		_draw_part(c, torso_back, torso_pivot, lean_rot, Rect2(Vector2(-24, -21), Vector2(48, 42)), face_left, tint)

		# Spina neurale luminosa e ugelli jetpack attivi sulla schiena!
		var jet_l := torso_pivot + Vector2(-6.5, 2.0).rotated(lean_rot)
		var jet_r := torso_pivot + Vector2(6.5, 2.0).rotated(lean_rot)
		var jet_rad: float = (4.8 + sin(anim_t * 28.0) * 1.4) if is_moving else 2.8
		c.draw_circle(torso_pivot + Vector2(0, -4.0), 3.0, aura)
		c.draw_circle(jet_l, jet_rad, Color(aura.r, aura.g, aura.b, 0.85))
		c.draw_circle(jet_r, jet_rad, Color(aura.r, aura.g, aura.b, 0.85))
		c.draw_circle(jet_l, jet_rad * 0.45, Color.WHITE)
		c.draw_circle(jet_r, jet_rad * 0.45, Color.WHITE)

		# Mantello olografico fluente visto da dietro mentre corre/spara
		_draw_hero_cape(c, torso_pivot + Vector2(0, -5.0), mv, anim_t, aura, 0.72)

		# Spallacci 3D sinistro e destro con parallasse
		_draw_part(c, pauldron_tex, torso_pivot + Vector2(-15.0 + turn_x * 0.25, -8.5), lean_rot - 0.08, Rect2(Vector2(-11, -11), Vector2(22, 22)), true, tint)
		_draw_part(c, pauldron_tex, torso_pivot + Vector2(15.0 + turn_x * 0.25, -8.5), lean_rot + 0.08, Rect2(Vector2(-11, -11), Vector2(22, 22)), false, tint)

		# Casco 3D visto da DIETRO (calotta corazzata + porta neurale nucale, NON la faccia!)
		var head_back := CyberTheme.get_model_texture("res://assets/cyber_models/hero_head_back.png")
		_draw_part(c, head_back, head_pivot, lean_rot * 0.6 + cos_a * 0.10, Rect2(Vector2(-19, -19), Vector2(38, 38)), face_left, tint)
		c.draw_circle(head_pivot + Vector2(cos_a * 2.0, 2.0), 3.2, aura)
		c.draw_circle(head_pivot + Vector2(cos_a * 2.0, 2.0), 1.4, Color.WHITE)

	elif pose == "SIDE":
		var dir_sign: float = -1.0 if face_left else 1.0
		# Spallaccio lontano dietro il busto
		_draw_part(c, pauldron_tex, torso_pivot + Vector2(dir_sign * 7.0, -9.0), lean_rot, Rect2(Vector2(-10, -10), Vector2(20, 20)), face_left, tint.darkened(0.18))

		var torso_side := CyberTheme.get_model_texture("res://assets/cyber_models/hero_torso_side.png")
		_draw_part(c, torso_side, torso_pivot, lean_rot, Rect2(Vector2(-23, -21), Vector2(46, 42)), face_left, tint)

		# Fiamma jetpack laterale in corsa
		if is_moving:
			var side_jet := torso_pivot + Vector2(-dir_sign * 10.5, 1.5)
			c.draw_circle(side_jet, 4.4 + sin(anim_t * 26.0) * 1.2, Color(aura.r, aura.g, aura.b, 0.85))
			c.draw_circle(side_jet, 2.0, Color.WHITE)

		# Casco 3D di PROFILO con visiera avvolgente puntata verso il nemico!
		var head_side := CyberTheme.get_model_texture("res://assets/cyber_models/hero_head_side.png")
		var head_pitch: float = clampf(sin_a * 0.22, -0.20, 0.20) * dir_sign
		_draw_part(c, head_side, head_pivot, lean_rot * 0.5 + head_pitch, Rect2(Vector2(-19, -19), Vector2(38, 38)), face_left, tint)
		var visor_a := head_pivot + Vector2(dir_sign * 2.0, -1.5)
		var visor_b := head_pivot + Vector2(dir_sign * 11.5, 0.5 + sin_a * 1.5)
		c.draw_line(visor_a, visor_b, aura, 3.8)
		c.draw_line(visor_a, visor_b, Color(1, 1, 1, 0.88), 1.3)

		# Arma e spallaccio primo piano
		_draw_hero_weapon(c, weapon_id, anim_t, is_shooting, aim_angle, face_left, -bob + body_shift.y, body_shift.x)
		_draw_part(c, pauldron_tex, torso_pivot + Vector2(-dir_sign * 7.5, -7.5), lean_rot, Rect2(Vector2(-11, -11), Vector2(22, 22)), face_left, tint)

	else: # "FRONT" (mira a Sud oppure vetrina Podio Menu!)
		var torso_front := CyberTheme.get_model_texture("res://assets/cyber_models/hero_torso_front.png")
		_draw_part(c, torso_front, torso_pivot, lean_rot, Rect2(Vector2(-24, -21), Vector2(48, 42)), face_left, tint)

		# Reattore Arc pettorale con il colore Aura scelto
		var core_p := torso_pivot + Vector2(turn_x * 0.35, -2.5)
		c.draw_circle(core_p, 6.8, Color(aura.r, aura.g, aura.b, 0.30))
		c.draw_circle(core_p, 3.8, aura)
		c.draw_circle(core_p + Vector2(-1, -1), 1.6, Color.WHITE)

		# Spallacci 3D
		_draw_part(c, pauldron_tex, torso_pivot + Vector2(-15.0 + turn_x * 0.25, -8.5), lean_rot - 0.08, Rect2(Vector2(-11, -11), Vector2(22, 22)), true, tint)
		_draw_part(c, pauldron_tex, torso_pivot + Vector2(15.0 + turn_x * 0.25, -8.5), lean_rot + 0.08, Rect2(Vector2(-11, -11), Vector2(22, 22)), false, tint)

		# Casco 3D Frontale + Visiera a V luminosa
		var head_front := CyberTheme.get_model_texture("res://assets/cyber_models/hero_head_front.png")
		_draw_part(c, head_front, head_pivot, lean_rot * 0.5 + cos_a * 0.08, Rect2(Vector2(-19, -19), Vector2(38, 38)), face_left, tint)
		var v_mid := head_pivot + Vector2(cos_a * 2.2, 2.2)
		c.draw_line(v_mid + Vector2(-7.0, -2.5), v_mid, aura, 3.6)
		c.draw_line(v_mid + Vector2(7.0, -2.5), v_mid, aura, 3.6)
		c.draw_line(v_mid + Vector2(-6.0, -2.2), v_mid, Color(1, 1, 1, 0.88), 1.2)
		c.draw_line(v_mid + Vector2(6.0, -2.2), v_mid, Color(1, 1, 1, 0.88), 1.2)

		_draw_hero_weapon(c, weapon_id, anim_t, is_shooting, aim_angle, face_left, -bob + body_shift.y, body_shift.x)

## Mantello Cyber-Tessuto dinamico che ondeggia in direzione opposta alla corsa
static func _draw_hero_cape(c: CanvasItem, anchor: Vector2, mv: Vector2, anim_t: float, aura: Color, alpha_mul: float) -> void:
	var wave1: float = sin(anim_t * 10.5) * 3.5
	var wave2: float = cos(anim_t * 12.0) * 5.0
	var drag := Vector2(-mv.x * 16.0 + wave1, 20.0 - mv.y * 6.0 + absf(mv.x) * 3.0)
	var p_tl := anchor + Vector2(-9.5, 0.0)
	var p_tr := anchor + Vector2(9.5, 0.0)
	var p_br := anchor + drag + Vector2(13.0 + wave2 * 0.4, 2.0)
	var p_bm := anchor + drag + Vector2(wave2 * 0.6, 6.0)
	var p_bl := anchor + drag + Vector2(-13.0 + wave2 * 0.4, 2.0)
	c.draw_colored_polygon(PackedVector2Array([p_tl, p_tr, p_br, p_bm, p_bl]), Color(0.06, 0.09, 0.18, 0.88 * alpha_mul))
	c.draw_polyline(PackedVector2Array([p_tl, p_bl, p_bm, p_br, p_tr]), Color(aura.r, aura.g, aura.b, 0.72 * alpha_mul), 1.8)

static func _draw_hero_weapon(c: CanvasItem, weapon_id: String, anim_t: float, is_shooting: bool, aim_angle: float, face_left: bool, y_off: float, x_off: float = 0.0) -> void:
	var recoil: float = -4.5 if (is_shooting and fmod(anim_t * 14.0, 1.0) < 0.30) else 0.0
	var hand := Vector2((-7.5 if face_left else 7.5) + x_off, -9.0 + y_off)
	var flip_y: float = -1.0 if face_left else 1.0

	# Braccio corazzato esteso verso l'impugnatura
	var shoulder := Vector2((-9.0 if face_left else 9.0) + x_off, -15.0 + y_off)
	var grip := hand + Vector2.RIGHT.rotated(aim_angle) * (6.0 + recoil * 0.5)
	c.draw_line(shoulder, grip, Color(0.18, 0.24, 0.36, 1.0), 5.0)

	c.draw_set_transform(hand, aim_angle, Vector2(1.0, flip_y))
	# Mirino laser tattico verso il nemico quando ingaggia il bersaglio
	if is_shooting:
		c.draw_line(Vector2(22.0 + recoil, 0.0), Vector2(68.0, 0.0), Color(0.0, 0.96, 1.0, 0.26), 1.4)
	var wep_tex := CyberTheme.get_item_model_texture(weapon_id, "ARMA")
	if wep_tex:
		c.draw_texture_rect(wep_tex, Rect2(Vector2(-2.0 + recoil, -15.0), Vector2(34.0, 34.0)), false)
	if is_shooting and recoil < -1.0:
		c.draw_circle(Vector2(30.0 + recoil, 0.0), 6.0, Color(0.0, 0.98, 1.0, 0.80))
		c.draw_circle(Vector2(30.0 + recoil, 0.0), 2.8, Color.WHITE)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ==============================================================================
# 2. NEMICO MELEE: MECH-RAGNO 3D CON ZAMPE ARTICOLATE IN MOVIMENTO
# ==============================================================================
static func draw_melee_enemy(c: CanvasItem, world_id: String, anim_t: float, accent: Color, aim_angle: float) -> void:
	var face_left := cos(aim_angle) < 0.0
	var scuttle := absf(sin(anim_t * 16.0)) * 3.2
	var tilt := cos(aim_angle) * 0.14
	draw_ground_shadow(c, Vector2(0, 12), 18.0, 0.55)
	draw_ground_ring(c, Vector2(0, 12), 20.0, Color(1.0, 0.2, 0.3, 1.0), anim_t * 0.5, 1.6)

	# Zampe meccaniche articolate che zampettano rapidamente
	for side: float in [-1.0, 1.0]:
		for leg_i: int in range(2):
			var ph: float = anim_t * 18.0 + side * 1.5 + float(leg_i) * PI
			var knee := Vector2(side * (14.0 + float(leg_i) * 4.0), -6.0 - scuttle + sin(ph) * 3.5)
			var foot := Vector2(side * (21.0 + float(leg_i) * 5.0) + cos(ph) * 4.5, 10.0 + float(leg_i) * 3.0 - maxf(0.0, sin(ph)) * 4.0)
			c.draw_line(Vector2(side * 8.0, -8.0 - scuttle), knee, Color(0.18, 0.22, 0.32, 1.0), 3.2)
			c.draw_line(knee, foot, accent.darkened(0.25), 2.6)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_melee.png")
	var tint := Color(0.75 + accent.r * 0.25, 0.75 + accent.g * 0.25, 0.75 + accent.b * 0.25, 1.0)
	if tex:
		_draw_part(c, tex, Vector2(cos(aim_angle) * 2.5, -9.0 - scuttle), tilt, Rect2(Vector2(-25, -25), Vector2(50, 50)), face_left, tint)
	else:
		c.draw_circle(Vector2(0, -8), 14.0, accent)

	# Accessori di bioma (piccoli dettagli luminosi sopra il modello)
	match world_id:
		"world_2", "world_5":
			c.draw_circle(Vector2(0, -24 - scuttle), 4.0, Color(1.0, 0.55, 0.1, 0.9))
		"world_4", "world_8":
			for i in range(3):
				var a := anim_t * 4.0 + i * TAU / 3.0
				c.draw_circle(Vector2(cos(a) * 18.0, -10 + sin(a) * 7.0 - scuttle), 2.6, Color(accent.r, accent.g, accent.b, 0.9))
		_:
			pass
	# Occhio di mira rosso orientato verso l'eroe
	var eye_off := Vector2(cos(aim_angle) * 4.5, sin(aim_angle) * 2.5)
	c.draw_circle(Vector2(0, -12 - scuttle) + eye_off, 3.2 + sin(anim_t * 8.0), Color(1.0, 0.15, 0.25, 0.72))

# ==============================================================================
# 3. NEMICO RANGED: DRONE CECCHINO 3D FLUTTUANTE CON ROLLIO DINAMICO
# ==============================================================================
static func draw_ranged_enemy(c: CanvasItem, anim_t: float, _accent: Color, aim_angle: float, is_charging: bool) -> void:
	var face_left := cos(aim_angle) < 0.0
	var hover := sin(anim_t * 3.8) * 4.5
	var bank_rot := cos(aim_angle) * 0.12 + sin(anim_t * 2.6) * 0.05
	draw_ground_shadow(c, Vector2(0, 16), 15.0 - hover * 0.6, 0.45)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_ranged.png")
	if tex:
		_draw_part(c, tex, Vector2(0, -18.0 + hover), bank_rot, Rect2(Vector2(-26, -26), Vector2(52, 52)), face_left)
	else:
		c.draw_circle(Vector2(0, -18 + hover), 14.0, Color(0.6, 0.3, 1.0, 1.0))

	# Raggio laser di puntamento durante la carica
	var eye := Vector2(cos(aim_angle) * 5.0, -16.0 + hover + sin(aim_angle) * 2.5)
	c.draw_circle(eye, 3.2, Color(1.0, 0.22, 0.35, 0.90))
	if is_charging:
		var tip := eye + Vector2.RIGHT.rotated(aim_angle) * 120.0
		c.draw_line(eye, tip, Color(1.0, 0.15, 0.25, 0.35 + 0.25 * sin(anim_t * 30.0)), 2.0)
		c.draw_circle(eye, 6.0 + sin(anim_t * 30.0) * 2.0, Color(1.0, 0.2, 0.3, 0.85))

# ==============================================================================
# 4. NEMICO PESANTE: GOLIATH MORTAR MECH 3D CON PASSO PESANTE
# ==============================================================================
static func draw_heavy_enemy(c: CanvasItem, anim_t: float, charge_ratio: float, aim_angle: float) -> void:
	var face_left := cos(aim_angle) < 0.0
	var stomp := absf(sin(anim_t * 5.5)) * 2.8
	var sway := sin(anim_t * 5.5) * 0.06
	draw_ground_shadow(c, Vector2(0, 18), 26.0, 0.65)
	c.draw_set_transform(Vector2(0, 18), 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_arc(Vector2.ZERO, 32.0, -PI * 0.5, -PI * 0.5 + TAU * charge_ratio, 32, Color(1.0, 0.35, 0.1, 0.9), 3.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_heavy.png")
	if tex:
		var heat := Color(1.0, 1.0 - charge_ratio * 0.25, 1.0 - charge_ratio * 0.4, 1.0)
		_draw_part(c, tex, Vector2(0, -16.0 - stomp), sway, Rect2(Vector2(-34, -34), Vector2(68, 68)), face_left, heat)
	else:
		c.draw_circle(Vector2(0, -16), 22.0, Color(0.8, 0.45, 0.2, 1.0))
	if charge_ratio > 0.6:
		c.draw_circle(Vector2(0, -16 - stomp), 6.0 + charge_ratio * 6.0, Color(1.0, 0.45, 0.1, 0.35))

# ==============================================================================
# 5. BOSS OVERLORD 3D (aura di fase, satelliti orbitanti in prospettiva)
# ==============================================================================
static func draw_boss(c: CanvasItem, world_id: String, anim_t: float, boss_col: Color, in_phase_2: bool, aim_angle: float) -> void:
	var active_col := Color(1.0, 0.15, 0.22, 1.0) if in_phase_2 else boss_col
	var face_left := cos(aim_angle) < 0.0
	var breath := sin(anim_t * 2.4) * 2.0

	draw_ground_shadow(c, Vector2(0, 40), 46.0, 0.7)
	draw_ground_ring(c, Vector2(0, 40), 56.0, active_col, anim_t, 3.4)

	# Satelliti dietro al boss (metà superiore dell'orbita)
	var orb_count := 4 if in_phase_2 else 3
	var orbs_front: Array[Vector2] = []
	for i in range(orb_count):
		var ang := anim_t * 2.2 + i * (TAU / float(orb_count))
		var p := Vector2(cos(ang) * 66.0, -6.0 + sin(ang) * 66.0 * PERSPECTIVE_Y)
		if sin(ang) < 0.0:
			_draw_orb(c, p, active_col, 0.8)
		else:
			orbs_front.append(p)

	# Ali/aura specifiche per alcuni boss
	if world_id == "world_4" or world_id == "world_7":
		var flap := sin(anim_t * 5.0) * 6.0
		for side: float in [-1.0, 1.0]:
			var wing := PackedVector2Array([
				Vector2(side * 20, -40), Vector2(side * (70 + flap), -86), Vector2(side * (78 + flap), -40), Vector2(side * 30, -14)
			])
			c.draw_colored_polygon(wing, Color(active_col.r, active_col.g, active_col.b, 0.35))
			c.draw_polyline(wing, Color(1, 1, 1, 0.55), 2.0)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_boss.png")
	if tex:
		var tint := Color(0.7 + active_col.r * 0.3, 0.7 + active_col.g * 0.3, 0.7 + active_col.b * 0.3, 1.0)
		_draw_upright(c, tex, Rect2(Vector2(-60, -80 - breath), Vector2(120, 120)), face_left, tint)
	else:
		c.draw_circle(Vector2(0, -20), 40.0, active_col)

	# Nucleo reattore pulsante colorato
	c.draw_circle(Vector2(0, -18 - breath), 14.0 + sin(anim_t * 5.0) * 2.0, Color(active_col.r, active_col.g, active_col.b, 0.30))
	c.draw_circle(Vector2(0, -18 - breath), 6.0, active_col)

	for p in orbs_front:
		_draw_orb(c, p, active_col, 1.0)

static func _draw_orb(c: CanvasItem, p: Vector2, col: Color, a: float) -> void:
	c.draw_circle(p, 9.0, Color(col.r, col.g, col.b, 0.25 * a))
	c.draw_circle(p, 6.5, Color(0.12, 0.14, 0.22, a))
	c.draw_circle(p, 4.5, Color(col.r, col.g, col.b, a))
	c.draw_circle(p + Vector2(-1.5, -1.5), 1.8, Color(1, 1, 1, a))

# ==============================================================================
# 6. OSTACOLO: TORRE-SERVER 3D (blocca colpi e movimento)
# ==============================================================================
static func draw_obstacle(c: CanvasItem, accent_col: Color) -> void:
	# Ombra proiettata a terra verso il basso-destra (luce da alto-sinistra)
	c.draw_colored_polygon(PackedVector2Array([
		Vector2(-26, 24), Vector2(28, 24), Vector2(44, 34), Vector2(-10, 34)
	]), Color(0, 0, 0, 0.45))
	draw_ground_shadow(c, Vector2(2, 22), 32.0, 0.45)
	var obs_tex := CyberTheme.get_model_texture("res://assets/cyber_models/prop_obstacle.png")
	if obs_tex:
		c.draw_texture_rect(obs_tex, Rect2(Vector2(-32, -48), Vector2(64, 72)), false, Color(0.85 + accent_col.r * 0.15, 0.85 + accent_col.g * 0.15, 0.85 + accent_col.b * 0.15, 1.0))
	else:
		c.draw_rect(Rect2(Vector2(-24, -40), Vector2(48, 64)), Color(0.12, 0.15, 0.22, 1.0), true)
	# Cornice luminosa alla base = "muro solido"
	c.draw_set_transform(Vector2(0, 22), 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 28, Color(accent_col.r, accent_col.g, accent_col.b, 0.55), 2.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ==============================================================================
# 7. CASSA RIFORNIMENTI: FORZIERE 3D
# ==============================================================================
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
