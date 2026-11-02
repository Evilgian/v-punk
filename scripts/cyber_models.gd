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

# ==============================================================================
# 1. EROE: CYBER-EXO-SUIT 3D + ARMA ORIENTATA VERSO IL BERSAGLIO
# ==============================================================================
static func draw_hero(c: CanvasItem, weapon_id: String, anim_t: float, is_moving: bool, is_shooting: bool, aim_angle: float) -> void:
	var aura := Global.get_player_accent_color()
	var face_left := cos(aim_angle) < -0.05
	var bob := absf(sin(anim_t * 12.0)) * 3.2 if is_moving else sin(anim_t * 3.0) * 1.0
	var aim_up := sin(aim_angle) < -0.35

	draw_ground_shadow(c, Vector2(0, 16), 20.0, 0.62)
	draw_ground_ring(c, Vector2(0, 16), 26.0, aura, anim_t, 2.6 if is_shooting else 2.0)

	# Scie dei propulsori quando corre
	if is_moving:
		for k in range(3):
			var tp := Vector2(-cos(aim_angle) * (10.0 + k * 7.0), 14.0 - sin(aim_angle) * (k * 4.0))
			c.draw_circle(tp, 5.0 - k * 1.4, Color(aura.r, aura.g, aura.b, 0.35 - k * 0.1))

	if aim_up:
		_draw_hero_weapon(c, weapon_id, anim_t, is_shooting, aim_angle, face_left, -bob)

	var body_rect := Rect2(Vector2(-32, -40 - bob), Vector2(64, 64))
	var hero_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_hero.png")
	if hero_tex:
		var tint := Color(0.86 + aura.r * 0.14, 0.86 + aura.g * 0.14, 0.86 + aura.b * 0.14, 1.0)
		_draw_upright(c, hero_tex, body_rect, face_left, tint)
	else:
		c.draw_circle(Vector2(0, -10 - bob), 16.0, Color(0.3, 0.38, 0.55, 1.0))

	# Visiera, reattore pettorale e bordo casco con il colore AURA scelto (sopra il modello 3D)
	var vy := -23.0 - bob
	c.draw_line(Vector2(-7, vy - 1), Vector2(0, vy + 2), aura, 3.6)
	c.draw_line(Vector2(7, vy - 1), Vector2(0, vy + 2), aura, 3.6)
	c.draw_line(Vector2(-6, vy - 1), Vector2(0, vy + 1.5), Color(1, 1, 1, 0.85), 1.2)
	c.draw_line(Vector2(6, vy - 1), Vector2(0, vy + 1.5), Color(1, 1, 1, 0.85), 1.2)
	var ry := -10.0 - bob
	c.draw_circle(Vector2(0, ry), 7.5, Color(aura.r, aura.g, aura.b, 0.30))
	c.draw_circle(Vector2(0, ry), 4.2, aura)
	c.draw_circle(Vector2(-1, ry - 1), 1.8, Color.WHITE)

	if not aim_up:
		_draw_hero_weapon(c, weapon_id, anim_t, is_shooting, aim_angle, face_left, -bob)

static func _draw_hero_weapon(c: CanvasItem, weapon_id: String, anim_t: float, is_shooting: bool, aim_angle: float, face_left: bool, y_off: float) -> void:
	var recoil := -3.5 if (is_shooting and int(anim_t * 22.0) % 2 == 0) else 0.0
	var hand := Vector2(-6.0 if face_left else 6.0, -6.0 + y_off)
	var flip_y := -1.0 if face_left else 1.0
	c.draw_set_transform(hand, aim_angle, Vector2(1.0, flip_y))
	var wep_tex := CyberTheme.get_item_model_texture(weapon_id, "ARMA")
	if wep_tex:
		c.draw_texture_rect(wep_tex, Rect2(Vector2(-4 + recoil, -15), Vector2(32, 32)), false)
	if is_shooting:
		c.draw_circle(Vector2(28 + recoil, 0), 5.0, Color(0.0, 0.98, 1.0, 0.75))
		c.draw_circle(Vector2(28 + recoil, 0), 2.4, Color.WHITE)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ==============================================================================
# 2. NEMICO MELEE: MECH-RAGNO 3D (tinta e accessori diversi per bioma)
# ==============================================================================
static func draw_melee_enemy(c: CanvasItem, world_id: String, anim_t: float, accent: Color, aim_angle: float) -> void:
	var face_left := cos(aim_angle) < 0.0
	var scuttle := absf(sin(anim_t * 14.0)) * 2.5
	draw_ground_shadow(c, Vector2(0, 12), 18.0, 0.55)
	draw_ground_ring(c, Vector2(0, 12), 20.0, Color(1.0, 0.2, 0.3, 1.0), anim_t * 0.5, 1.6)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_melee.png")
	var tint := Color(0.75 + accent.r * 0.25, 0.75 + accent.g * 0.25, 0.75 + accent.b * 0.25, 1.0)
	if tex:
		_draw_upright(c, tex, Rect2(Vector2(-25, -34 - scuttle), Vector2(50, 50)), face_left, tint)
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
	# Occhio di mira rosso pulsante
	c.draw_circle(Vector2(0, -12 - scuttle), 3.0 + sin(anim_t * 8.0), Color(1.0, 0.15, 0.25, 0.55))

# ==============================================================================
# 3. NEMICO RANGED: DRONE CECCHINO 3D FLUTTUANTE
# ==============================================================================
static func draw_ranged_enemy(c: CanvasItem, anim_t: float, accent: Color, aim_angle: float, is_charging: bool) -> void:
	var face_left := cos(aim_angle) < 0.0
	var hover := sin(anim_t * 3.2) * 4.0
	# L'ombra si restringe quando il drone sale
	draw_ground_shadow(c, Vector2(0, 16), 15.0 - hover * 0.6, 0.45)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_ranged.png")
	if tex:
		_draw_upright(c, tex, Rect2(Vector2(-26, -44 + hover), Vector2(52, 52)), face_left)
	else:
		c.draw_circle(Vector2(0, -18 + hover), 14.0, Color(0.6, 0.3, 1.0, 1.0))

	# Raggio laser di puntamento durante la carica
	if is_charging:
		var eye := Vector2(0, -16 + hover)
		var tip := eye + Vector2.RIGHT.rotated(aim_angle) * 120.0
		c.draw_line(eye, tip, Color(1.0, 0.15, 0.25, 0.35 + 0.25 * sin(anim_t * 30.0)), 2.0)
		c.draw_circle(eye, 6.0 + sin(anim_t * 30.0) * 2.0, Color(1.0, 0.2, 0.3, 0.85))

# ==============================================================================
# 4. NEMICO PESANTE: GOLIATH MORTAR MECH 3D
# ==============================================================================
static func draw_heavy_enemy(c: CanvasItem, anim_t: float, charge_ratio: float, aim_angle: float) -> void:
	var face_left := cos(aim_angle) < 0.0
	var stomp := absf(sin(anim_t * 5.0)) * 2.0
	draw_ground_shadow(c, Vector2(0, 18), 26.0, 0.65)
	# Indicatore carica mortaio a terra
	c.draw_set_transform(Vector2(0, 18), 0.0, Vector2(1.0, PERSPECTIVE_Y))
	c.draw_arc(Vector2.ZERO, 32.0, -PI * 0.5, -PI * 0.5 + TAU * charge_ratio, 32, Color(1.0, 0.35, 0.1, 0.9), 3.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_heavy.png")
	if tex:
		var heat := Color(1.0, 1.0 - charge_ratio * 0.25, 1.0 - charge_ratio * 0.4, 1.0)
		_draw_upright(c, tex, Rect2(Vector2(-34, -50 - stomp), Vector2(68, 68)), face_left, heat)
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
		for side in [-1.0, 1.0]:
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
