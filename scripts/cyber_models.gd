class_name CyberModels
extends RefCounted

# ==============================================================================
# RENDERING 2.5D "ARCHERO-STYLE" v2: modelli 3D pre-renderizzati ad alto dettaglio
# (Cyber-Ronin Exo-Slayer, Robo-Titan, Mantis Stalker, Hover-Wasp, Goliath) con contorno
# scuro solido, animazione procedurale (falcata gambe, inclinazione busto, rinculo,
# respirazione) e ombre a terra. Nessuna trasparenza sui corpi: massima leggibilità.
# ==============================================================================

const PERSPECTIVE_Y: float = 0.42 # Schiacciamento verticale degli elementi a terra (camera inclinata ~65°)
const HERO_LEG_SPLIT: float = 0.54 # Frazione di altezza dove il busto si separa dalle gambe (vita)

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
	c.draw_arc(Vector2.ZERO, radius, anim_t * 2.2, anim_t * 2.2 + PI * 1.35, 32, Color(col.r, col.g, col.b, 0.90), width)
	c.draw_arc(Vector2.ZERO, radius, anim_t * 2.2 + PI * 1.5, anim_t * 2.2 + PI * 1.85, 12, Color(1, 1, 1, 0.7), width * 0.8)
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

## Sprite con "piedi" come perno: squash & stretch, inclinazione e specchiatura
static func _draw_grounded_sprite(c: CanvasItem, tex: Texture2D, feet: Vector2, height: float, rot: float, flip_h: bool, squash: Vector2 = Vector2.ONE, modulate: Color = Color.WHITE) -> void:
	if not tex:
		return
	var w: float = height * float(tex.get_width()) / float(tex.get_height())
	var sx: float = -squash.x if flip_h else squash.x
	c.draw_set_transform_matrix(Transform2D(rot, Vector2(sx, squash.y), 0.0, feet))
	c.draw_texture_rect(tex, Rect2(Vector2(-w * 0.5, -height), Vector2(w, height)), false, modulate)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ==============================================================================
# 1. EROE: CYBER-RONIN EXO-SLAYER (FRONTE / PROFILO / SPALLE) + RIG BUSTO/GAMBE ANIMATO
# ==============================================================================
static func draw_hero(c: CanvasItem, weapon_id: String, anim_t: float, is_moving: bool, is_shooting: bool, aim_angle: float, move_vec: Vector2 = Vector2.ZERO, body_h: float = 68.0) -> void:
	var aura := Global.get_player_accent_color()
	var sin_a: float = sin(aim_angle)
	var cos_a: float = cos(aim_angle)
	var k: float = body_h / 68.0 # fattore di scala per effetti accessori

	# Posa 3D in base alla direzione del bersaglio: di SPALLE verso i nemici a Nord,
	# di PROFILO verso Est/Ovest, FRONTALE verso Sud (e sul podio del menu).
	var pose: String = "SIDE"
	if sin_a < -0.45:
		pose = "BACK"
	elif sin_a > 0.55:
		pose = "FRONT"
	var face_left: bool = cos_a < -0.05

	var mv: Vector2 = move_vec.limit_length(1.0) if is_moving else Vector2.ZERO
	if is_moving and mv.length_squared() < 0.01:
		mv = Vector2(cos_a, sin_a)

	# Fisica di locomozione: falcata, rimbalzo, inclinazione nella corsa, rinculo e respirazione
	var stride_phase: float = anim_t * 14.5
	var stride_s: float = sin(stride_phase)
	var stride_c: float = cos(stride_phase)
	var bob: float = (absf(stride_s) * 3.6 if is_moving else sin(anim_t * 3.0) * 0.9) * k
	var lean_rot: float = clampf(mv.x * 0.16, -0.18, 0.18) if is_moving else 0.0
	var recoil_kick: float = 1.0 if (is_shooting and fmod(anim_t * 14.0, 1.0) < 0.30) else 0.0
	var body_shift: Vector2 = Vector2(mv.x * 2.4 * k, 0.0) - Vector2(cos_a, 0.0) * (2.2 * recoil_kick * k)
	var breathe: float = 1.0 + (sin(anim_t * 3.0) * 0.012 if not is_moving else 0.0)

	var feet := Vector2(body_shift.x, 18.0 * k)

	# Ombra dinamica, anello direzionale a terra e freccia di mira
	draw_ground_shadow(c, Vector2(body_shift.x * 0.4, feet.y), 19.0 * k - (bob * 0.3), 0.62)
	draw_ground_ring(c, Vector2(0, feet.y), 27.0 * k, aura, anim_t, (3.0 if is_shooting else 2.4))
	var dir_2d := Vector2(cos_a, sin_a * PERSPECTIVE_Y)
	var tip_p := Vector2(0, feet.y) + dir_2d * 34.0 * k
	var side_p := Vector2(-sin_a, cos_a * PERSPECTIVE_Y) * 6.0 * k
	c.draw_colored_polygon(PackedVector2Array([
		tip_p,
		Vector2(0, feet.y) + dir_2d * 24.0 * k + side_p,
		Vector2(0, feet.y) + dir_2d * 24.0 * k - side_p
	]), Color(aura.r, aura.g, aura.b, 0.95))

	# Scie energetiche (dash dei propulsori) durante la corsa
	if is_moving:
		for t_i in range(3):
			var trail_off := -Vector2(mv.x, mv.y * 0.65) * (10.0 + float(t_i) * 8.0) * k
			c.draw_circle(Vector2(0, feet.y - 3.0) + trail_off, (5.0 - float(t_i) * 1.4) * k, Color(aura.r, aura.g, aura.b, 0.40 - float(t_i) * 0.10))

	var tex_name := "hero_full_side.png"
	if pose == "BACK":
		tex_name = "hero_full_back.png"
	elif pose == "FRONT":
		tex_name = "hero_full_front.png"
	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/" + tex_name)

	var hand := Vector2(body_shift.x + (-1.0 if face_left else 1.0) * body_h * 0.20, feet.y - body_h * 0.50 - bob)

	# Mirando a Nord l'arma è davanti all'eroe → dietro la schiena rispetto alla camera
	if pose == "BACK":
		_draw_hero_weapon(c, weapon_id, anim_t, is_shooting, aim_angle, face_left, hand, k)

	if tex:
		_draw_hero_rig(c, tex, feet, body_h * breathe, bob, lean_rot, stride_s if is_moving else 0.0, stride_c if is_moving else 0.0, face_left)
	else:
		c.draw_circle(Vector2(feet.x, feet.y - body_h * 0.5), body_h * 0.3, aura)

	# Bagliore neon della visiera (colore Aura scelto) sopra al casco
	if pose != "BACK":
		var head_p := Vector2(feet.x + (-1.0 if face_left else 1.0) * (body_h * 0.03 if pose == "SIDE" else 0.0), feet.y - body_h * 0.84 - bob)
		c.draw_circle(head_p, 6.5 * k, Color(aura.r, aura.g, aura.b, 0.28))
		c.draw_circle(head_p, 2.4 * k, Color(1, 1, 1, 0.55))
	else:
		# Ugelli jetpack accesi sulla schiena mentre corre
		var back_p := Vector2(feet.x, feet.y - body_h * 0.62 - bob)
		var jet_r: float = ((4.0 + sin(anim_t * 28.0) * 1.2) if is_moving else 2.2) * k
		c.draw_circle(back_p + Vector2(-5.0 * k, 0), jet_r, Color(aura.r, aura.g, aura.b, 0.8))
		c.draw_circle(back_p + Vector2(5.0 * k, 0), jet_r, Color(aura.r, aura.g, aura.b, 0.8))

	if pose != "BACK":
		_draw_hero_weapon(c, weapon_id, anim_t, is_shooting, aim_angle, face_left, hand, k)

## Rig a due segmenti: gambe con falcata (taglio obliquo alternato) + busto con inclinazione e rimbalzo
static func _draw_hero_rig(c: CanvasItem, tex: Texture2D, feet: Vector2, h: float, bob: float, lean: float, stride_s: float, stride_c: float, flip_h: bool) -> void:
	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())
	var w: float = h * tw / th
	var sx: float = -1.0 if flip_h else 1.0
	var split_src: float = th * HERO_LEG_SPLIT
	var leg_h: float = h * (1.0 - HERO_LEG_SPLIT)
	var top_h: float = h * HERO_LEG_SPLIT
	var hip := Vector2(feet.x, feet.y - leg_h - bob * 0.6)

	# Gambe: perno all'anca, il taglio obliquo alterna la falcata avanti/indietro
	var leg_skew: float = stride_s * 0.30
	var leg_sy: float = 1.0 - absf(stride_c) * 0.05
	c.draw_set_transform_matrix(Transform2D(lean * 0.4, Vector2(sx, leg_sy), leg_skew * sx, hip))
	c.draw_texture_rect_region(tex, Rect2(Vector2(-w * 0.5, -1.0), Vector2(w, leg_h + 1.0)), Rect2(Vector2(0, split_src - 1.0), Vector2(tw, th - split_src + 1.0)))

	# Busto + testa: perno all'anca con inclinazione e torsione nella corsa
	var twist: float = stride_c * 0.035
	c.draw_set_transform_matrix(Transform2D(lean + twist, Vector2(sx, 1.0), 0.0, hip - Vector2(0, bob * 0.4)))
	c.draw_texture_rect_region(tex, Rect2(Vector2(-w * 0.5, -top_h), Vector2(w, top_h + 1.0)), Rect2(Vector2.ZERO, Vector2(tw, split_src + 1.0)))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func _draw_hero_weapon(c: CanvasItem, weapon_id: String, anim_t: float, is_shooting: bool, aim_angle: float, face_left: bool, hand: Vector2, k: float = 1.0) -> void:
	var recoil: float = -5.0 * k if (is_shooting and fmod(anim_t * 14.0, 1.0) < 0.30) else 0.0
	var flip_y: float = -1.0 if face_left else 1.0
	var wsz: float = 40.0 * k

	c.draw_set_transform(hand, aim_angle, Vector2(1.0, flip_y))
	# Mirino laser tattico verso il nemico quando ingaggia il bersaglio
	if is_shooting:
		c.draw_line(Vector2(wsz * 0.65 + recoil, 0.0), Vector2(wsz * 2.0, 0.0), Color(1.0, 0.15, 0.25, 0.45), 1.6)
	var wep_tex := CyberTheme.get_item_model_texture(weapon_id, "ARMA")
	if wep_tex:
		c.draw_texture_rect(wep_tex, Rect2(Vector2(-wsz * 0.10 + recoil, -wsz * 0.48), Vector2(wsz, wsz)), false)
	# Guanto corazzato che impugna l'arma
	c.draw_circle(Vector2(recoil + 2.0 * k, 2.0 * k), 4.2 * k, Color(0.16, 0.19, 0.26, 1.0))
	c.draw_circle(Vector2(recoil + 2.0 * k, 2.0 * k), 4.2 * k - 1.2, Color(0.42, 0.48, 0.58, 1.0))
	if is_shooting and recoil < -1.0:
		c.draw_circle(Vector2(wsz * 0.85 + recoil, 0.0), 7.0 * k, Color(0.0, 0.98, 1.0, 0.85))
		c.draw_circle(Vector2(wsz * 0.85 + recoil, 0.0), 3.2 * k, Color.WHITE)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ==============================================================================
# 2. NEMICO MELEE: MANTIS STALKER 3D (zampettata rapida + affondo delle lame)
# ==============================================================================
static func draw_melee_enemy(c: CanvasItem, world_id: String, anim_t: float, accent: Color, aim_angle: float) -> void:
	var face_left := cos(aim_angle) < 0.0
	var scuttle := absf(sin(anim_t * 16.0)) * 2.6
	var tilt := cos(aim_angle) * 0.08 + sin(anim_t * 16.0) * 0.04
	draw_ground_shadow(c, Vector2(0, 14), 22.0, 0.60)
	draw_ground_ring(c, Vector2(0, 14), 25.0, Color(1.0, 0.22, 0.32, 1.0), anim_t * 0.65, 2.4)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_melee_v2.png")
	if tex:
		var squash := Vector2(1.0 + scuttle * 0.012, 1.0 - scuttle * 0.012)
		_draw_grounded_sprite(c, tex, Vector2(cos(aim_angle) * 2.0, 16.0 - scuttle), 50.0, tilt, not face_left, squash)
	else:
		c.draw_circle(Vector2(0, -8), 14.0, accent)

	match world_id:
		"world_2", "world_5":
			c.draw_circle(Vector2(0, -30 - scuttle), 4.0, Color(1.0, 0.55, 0.1, 0.95))
		"world_4", "world_8":
			for i in range(3):
				var a := anim_t * 4.0 + i * TAU / 3.0
				c.draw_circle(Vector2(cos(a) * 22.0, -12 + sin(a) * 8.0 - scuttle), 2.6, Color(accent.r, accent.g, accent.b, 0.95))
		_:
			pass

# ==============================================================================
# 3. NEMICO RANGED: HOVER-WASP SNIPER DRONE 3D (volo, rollio e carica laser)
# ==============================================================================
static func draw_ranged_enemy(c: CanvasItem, anim_t: float, _accent: Color, aim_angle: float, is_charging: bool) -> void:
	var face_left := cos(aim_angle) < 0.0
	var hover := sin(anim_t * 3.8) * 4.5
	var bank_rot := cos(aim_angle) * 0.10 + sin(anim_t * 2.6) * 0.06
	draw_ground_shadow(c, Vector2(0, 16), 17.0 - hover * 0.5, 0.48)
	draw_ground_ring(c, Vector2(0, 16), 23.0, Color(0.95, 0.28, 1.0, 1.0), -anim_t * 0.8, 2.2)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_ranged_v2.png")
	var body_c := Vector2(0, -16.0 + hover)
	if tex:
		var w: float = 60.0
		var h: float = w * float(tex.get_height()) / float(tex.get_width())
		_draw_part(c, tex, body_c, bank_rot, Rect2(Vector2(-w * 0.5, -h * 0.5), Vector2(w, h)), not face_left)
	else:
		c.draw_circle(body_c, 14.0, Color(0.6, 0.3, 1.0, 1.0))

	# Lente rossa di puntamento + raggio laser durante la carica
	var eye := body_c + Vector2(cos(aim_angle) * 6.0, 8.0 + sin(aim_angle) * 3.0)
	if is_charging:
		var tip := eye + Vector2.RIGHT.rotated(aim_angle) * 135.0
		c.draw_line(eye, tip, Color(1.0, 0.18, 0.30, 0.55 + 0.28 * sin(anim_t * 30.0)), 2.4)
		c.draw_circle(eye, 6.5 + sin(anim_t * 30.0) * 2.0, Color(1.0, 0.25, 0.35, 0.92))
		c.draw_circle(eye, 2.4, Color.WHITE)

# ==============================================================================
# 4. NEMICO PESANTE: GOLIATH SIEGE JUGGERNAUT 3D (passo pesante + mortai in carica)
# ==============================================================================
static func draw_heavy_enemy(c: CanvasItem, anim_t: float, charge_ratio: float, aim_angle: float) -> void:
	var face_left := cos(aim_angle) < 0.0
	var stomp := absf(sin(anim_t * 5.5)) * 2.6
	var sway := sin(anim_t * 5.5) * 0.05
	draw_ground_shadow(c, Vector2(0, 20), 28.0, 0.62)
	draw_ground_ring(c, Vector2(0, 20), 31.0, Color(1.0, 0.52, 0.12, 1.0), anim_t * 0.45, 2.4)
	c.draw_set_transform(Vector2(0, 20), 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_arc(Vector2.ZERO, 35.0, -PI * 0.5, -PI * 0.5 + TAU * charge_ratio, 32, Color(1.0, 0.35, 0.1, 0.96), 3.4)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_heavy_v2.png")
	if tex:
		var heat := Color(1.0 + charge_ratio * 0.25, 1.0, 1.0 - charge_ratio * 0.15, 1.0)
		_draw_grounded_sprite(c, tex, Vector2(0, 22.0), 74.0 - stomp, sway, face_left, Vector2(1.0 + stomp * 0.01, 1.0), heat)
	else:
		c.draw_circle(Vector2(0, -16), 22.0, Color(0.8, 0.45, 0.2, 1.0))
	if charge_ratio > 0.6:
		var mortar := Vector2((-8.0 if face_left else 8.0), -46.0)
		c.draw_circle(mortar, 5.0 + charge_ratio * 6.0, Color(1.0, 0.50, 0.12, 0.55))
		c.draw_circle(mortar, 2.5 + charge_ratio * 2.0, Color(1.0, 0.95, 0.6, 0.9))

# ==============================================================================
# 5. BOSS ROBO-TITAN DREADNOUGHT 3D (passo pesante, fornace pulsante, fase 2 furiosa)
# ==============================================================================
static func draw_boss(c: CanvasItem, world_id: String, anim_t: float, boss_col: Color, in_phase_2: bool, aim_angle: float) -> void:
	var active_col := Color(1.0, 0.15, 0.22, 1.0) if in_phase_2 else boss_col
	var face_left := cos(aim_angle) < 0.0
	var stomp := absf(sin(anim_t * (4.2 if in_phase_2 else 2.8))) * 3.0
	var sway := sin(anim_t * (4.2 if in_phase_2 else 2.8)) * 0.04

	draw_ground_shadow(c, Vector2(0, 44), 54.0, 0.72)
	draw_ground_ring(c, Vector2(0, 44), 62.0, active_col, anim_t, 3.6)
	if in_phase_2:
		# Onde d'urto rosse ad ogni passo in fase 2
		c.draw_set_transform(Vector2(0, 44), 0.0, Vector2(1.0, PERSPECTIVE_Y))
		var shock_r: float = 50.0 + fmod(anim_t * 90.0, 40.0)
		c.draw_arc(Vector2.ZERO, shock_r, 0.0, TAU, 40, Color(1.0, 0.2, 0.2, 0.6 * (1.0 - (shock_r - 50.0) / 40.0)), 3.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Satelliti dietro al boss (metà superiore dell'orbita)
	var orb_count := 4 if in_phase_2 else 3
	var orbs_front: Array[Vector2] = []
	for i in range(orb_count):
		var ang := anim_t * 2.2 + i * (TAU / float(orb_count))
		var p := Vector2(cos(ang) * 74.0, -20.0 + sin(ang) * 74.0 * PERSPECTIVE_Y)
		if sin(ang) < 0.0:
			_draw_orb(c, p, active_col, 0.8)
		else:
			orbs_front.append(p)

	# Ali/aura specifiche per alcuni boss
	if world_id == "world_4" or world_id == "world_7":
		var flap := sin(anim_t * 5.0) * 6.0
		for side: float in [-1.0, 1.0]:
			var wing := PackedVector2Array([
				Vector2(side * 24, -70), Vector2(side * (84 + flap), -120), Vector2(side * (92 + flap), -60), Vector2(side * 34, -30)
			])
			c.draw_colored_polygon(wing, Color(active_col.r, active_col.g, active_col.b, 0.40))
			c.draw_polyline(wing, Color(1, 1, 1, 0.6), 2.0)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_boss_titan.png")
	if tex:
		var tint := Color(1.0 + active_col.r * 0.10, 1.0 + active_col.g * 0.06, 1.0 + active_col.b * 0.06, 1.0)
		if in_phase_2:
			tint = Color(1.25, 0.92, 0.92, 1.0)
		_draw_grounded_sprite(c, tex, Vector2(0, 46.0), 142.0 - stomp, sway, face_left, Vector2(1.0 + stomp * 0.006, 1.0), tint)
	else:
		c.draw_circle(Vector2(0, -20), 40.0, active_col)

	# Fornace toracica pulsante (si accende di più in fase 2)
	var core_p := Vector2((3.0 if face_left else -3.0), -48.0 - stomp * 0.5)
	var pulse: float = 0.5 + 0.5 * sin(anim_t * (9.0 if in_phase_2 else 5.0))
	c.draw_circle(core_p, 13.0 + pulse * 4.0, Color(1.0, 0.45, 0.10, 0.22 + pulse * 0.18))
	c.draw_circle(core_p, 4.5 + pulse * 1.5, Color(1.0, 0.92, 0.55, 0.85))

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
