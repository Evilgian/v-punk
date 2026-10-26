class_name CyberModels
extends RefCounted

# ==============================================================================
# 1. MODELLO EROE: CYBER-RONIN EXO-SUIT + 8 ARMI DISTINTE
# ==============================================================================
static func draw_hero(c: CanvasItem, weapon_id: String, anim_t: float, is_moving: bool, is_shooting: bool, aim_angle: float) -> void:
	# Ombra morbida a terra
	c.draw_circle(Vector2(0, 10), 20.0, Color(0, 0, 0, 0.45))

	# Anello tattico olografico ai piedi con il colore Aura scelto dal giocatore
	var aura := Global.get_player_accent_color()
	var ring_col := Color(aura.r, aura.g, aura.b, 0.82 if is_shooting else 0.52)
	c.draw_circle(Vector2.ZERO, 24.0, Color(ring_col.r, ring_col.g, ring_col.b, 0.14))
	c.draw_arc(Vector2.ZERO, 25.0, anim_t * 2.2, anim_t * 2.2 + PI * 1.4, 28, ring_col, 2.4)
	c.draw_arc(Vector2.ZERO, 25.0, anim_t * 2.2 + PI, anim_t * 2.2 + PI * 1.6, 16, Color(1.0, 1.0, 1.0, 0.55), 2.0)

	# Rotazione del corpo verso la direzione di mira/movimento
	c.draw_set_transform(Vector2.ZERO, aim_angle, Vector2.ONE)

	var stride := sin(anim_t * 14.0) * 5.0 if is_moving else 0.0
	var breath := sin(anim_t * 4.0) * 1.2

	# Mantello energetico / Scia cyber posteriore
	var cape_sway := sin(anim_t * 10.0) * (4.0 if is_moving else 1.5)
	var cape_pts := PackedVector2Array([
		Vector2(-6, -9),
		Vector2(-22 - (5.0 if is_moving else 0.0), -13 + cape_sway),
		Vector2(-26 - (6.0 if is_moving else 0.0), cape_sway * 0.6),
		Vector2(-22 - (5.0 if is_moving else 0.0), 13 + cape_sway),
		Vector2(-6, 9)
	])
	c.draw_colored_polygon(cape_pts, Color(aura.r * 0.55, aura.g * 0.35, aura.b * 0.75, 0.58))
	c.draw_polyline(cape_pts, aura, 1.8)

	# Stivali Cyber-Jet (animati durante la corsa)
	c.draw_rect(Rect2(Vector2(-6 + stride, -13), Vector2(12, 7)), Color(0.12, 0.15, 0.22, 1.0), true)
	c.draw_rect(Rect2(Vector2(-6 - stride, 6), Vector2(12, 7)), Color(0.12, 0.15, 0.22, 1.0), true)
	if is_moving:
		c.draw_circle(Vector2(-10, -10), 4.0, Color(0.0, 0.94, 1.0, 0.75))
		c.draw_circle(Vector2(-10, 10), 4.0, Color(0.0, 0.94, 1.0, 0.75))

	# Spallacci Corazzati Esoscheletro (Pauldrons)
	var sh_l := PackedVector2Array([Vector2(-8, -19), Vector2(8, -17), Vector2(10, -8), Vector2(-6, -8)])
	var sh_r := PackedVector2Array([Vector2(-8, 19), Vector2(8, 17), Vector2(10, 8), Vector2(-6, 8)])
	c.draw_colored_polygon(sh_l, Color(0.14, 0.18, 0.28, 1.0))
	c.draw_colored_polygon(sh_r, Color(0.14, 0.18, 0.28, 1.0))
	c.draw_polyline(sh_l, Color(0.0, 0.94, 1.0, 0.9), 1.8)
	c.draw_polyline(sh_r, Color(0.0, 0.94, 1.0, 0.9), 1.8)

	# Torso Corazzato + Reattore Petto
	c.draw_circle(Vector2(0, 0), 12.0, Color(0.10, 0.12, 0.18, 1.0))
	c.draw_arc(Vector2(0, 0), 12.0, 0, TAU, 20, Color(0.25, 0.35, 0.55, 1.0), 2.0)
	c.draw_circle(Vector2(3, 0), 4.5, Color(0.0, 0.95, 1.0, 0.95))

	# Casco Cyber-Ronin con Visiera al Neon a "V"
	c.draw_circle(Vector2(1 + breath * 0.3, 0), 9.5, Color(0.16, 0.20, 0.30, 1.0))
	c.draw_arc(Vector2(1 + breath * 0.3, 0), 9.5, 0, TAU, 20, Color(0.0, 0.94, 1.0, 0.85), 1.6)
	# Visiera luminosa frontale
	var visor := PackedVector2Array([
		Vector2(5, -6),
		Vector2(10, 0),
		Vector2(5, 6),
		Vector2(8, 0)
	])
	c.draw_colored_polygon(visor, Color(0.0, 1.0, 0.95, 1.0))

	# Sovrapposizione Modello 3D-Shaded Eroe (Carbon/Metallic Normal-Lit Texture)
	var hero_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_hero.png")
	if hero_tex:
		c.draw_texture_rect(hero_tex, Rect2(Vector2(-24, -24), Vector2(48, 48)), false)

	# Arma Equipaggiata in Mano (Modello 3D-Shaded + Rinculo + Mirino Laser)
	_draw_hero_weapon(c, weapon_id, anim_t, is_shooting)

	# Ripristina transform per disegni successivi (es. Droni Pet in coordinate locali)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func _draw_hero_weapon(c: CanvasItem, weapon_id: String, anim_t: float, is_shooting: bool) -> void:
	var recoil := -3.5 if (is_shooting and int(anim_t * 22.0) % 2 == 0) else 0.0
	var wep_tex := CyberTheme.get_item_model_texture(weapon_id, "ARMA")
	if wep_tex:
		c.draw_texture_rect(wep_tex, Rect2(Vector2(0 + recoil, -6), Vector2(36, 36)), false)
	if is_shooting:
		c.draw_circle(Vector2(30 + recoil, 10), 5.0, Color(0.0, 0.98, 1.0, 0.85))
		c.draw_circle(Vector2(30 + recoil, 10), 2.5, Color.WHITE)


# ==============================================================================
# 2. MODELLI NEMICI MELEE (8 BIOMI DISTINTI)
# ==============================================================================
static func draw_melee_enemy(c: CanvasItem, world_id: String, anim_t: float, accent: Color, aim_angle: float) -> void:
	c.draw_circle(Vector2(0, 8), 16.0, Color(0, 0, 0, 0.42))
	c.draw_arc(Vector2.ZERO, 20.0, 0.0, TAU, 24, Color(accent.r, accent.g, accent.b, 0.38), 1.8)

	c.draw_set_transform(Vector2.ZERO, aim_angle, Vector2.ONE)
	var scuttle := sin(anim_t * 16.0) * 4.0

	match world_id:
		"world_1", "world_6":
			# Bio-Mantis / Mutant Crawler (Zampe insettoidi articolate + mandibole al neon)
			for side in [-1.0, 1.0]:
				c.draw_line(Vector2(2, side * 8), Vector2(6 + scuttle * side, side * 19), Color(0.18, 0.25, 0.20, 1.0), 3.0)
				c.draw_line(Vector2(-4, side * 8), Vector2(-8 - scuttle * side, side * 18), Color(0.18, 0.25, 0.20, 1.0), 3.0)
				# Chele / Mandibole frontali
				c.draw_line(Vector2(8, side * 5), Vector2(20, side * (2.0 + abs(scuttle) * 0.4)), accent, 3.0)
			# Carapace segmentato
			c.draw_circle(Vector2(-5, 0), 10.0, Color(0.10, 0.18, 0.12, 1.0))
			c.draw_circle(Vector2(4, 0), 9.0, Color(0.14, 0.24, 0.16, 1.0))
			c.draw_circle(Vector2(2, 0), 4.5, accent)
			c.draw_circle(Vector2(9, -4), 2.2, Color(1.0, 0.2, 0.2, 1.0))
			c.draw_circle(Vector2(9, 4), 2.2, Color(1.0, 0.2, 0.2, 1.0))

		"world_2", "world_5":
			# Scarabeo Corazzato / Golem Magmatico con Lame Rotanti
			var body_pts := PackedVector2Array([
				Vector2(16, 0), Vector2(4, -14), Vector2(-14, -11), Vector2(-16, 0), Vector2(-14, 11), Vector2(4, 14)
			])
			c.draw_colored_polygon(body_pts, Color(0.22, 0.14, 0.08, 1.0))
			c.draw_polyline(body_pts, accent, 2.2)
			# Fessure d'energia / nucleo ardente
			c.draw_circle(Vector2(0, 0), 6.0, accent)
			c.draw_line(Vector2(10, -8), Vector2(20, -3), accent, 3.5)
			c.draw_line(Vector2(10, 8), Vector2(20, 3), accent, 3.5)

		"world_4", "world_8":
			# Spettro Criogenico / Geometria del Vuoto (Lame orbitanti)
			var spin := anim_t * 6.0
			for i in range(4):
				var a := spin + i * (TAU / 4.0)
				var p1 := Vector2.RIGHT.rotated(a) * 8.0
				var p2 := Vector2.RIGHT.rotated(a + 0.35) * 19.0
				var p3 := Vector2.RIGHT.rotated(a - 0.35) * 19.0
				c.draw_colored_polygon(PackedVector2Array([p1, p2, p3]), Color(accent.r, accent.g, accent.b, 0.85))
			c.draw_circle(Vector2.ZERO, 9.0, Color(0.08, 0.10, 0.18, 1.0))
			c.draw_circle(Vector2.ZERO, 5.0, Color.WHITE)

		_:
			# Cyber-Hound / Automaton Assaltatore (Mondo 3, 7)
			var chassis := PackedVector2Array([
				Vector2(18, 0), Vector2(2, -13), Vector2(-15, -9), Vector2(-11, 0), Vector2(-15, 9), Vector2(2, 13)
			])
			c.draw_colored_polygon(chassis, Color(0.12, 0.14, 0.22, 1.0))
			c.draw_polyline(chassis, accent, 2.0)
			# Lame al plasma laterali
			c.draw_line(Vector2(4, -12), Vector2(16, -6), Color(1.0, 0.2, 0.4, 1.0), 3.0)
			c.draw_line(Vector2(4, 12), Vector2(16, 6), Color(1.0, 0.2, 0.4, 1.0), 3.0)
			c.draw_circle(Vector2(6, 0), 4.0, accent)

	var melee_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_melee.png")
	if melee_tex:
		c.draw_texture_rect(melee_tex, Rect2(Vector2(-22, -22), Vector2(44, 44)), false, Color(0.85, 0.9, 1.0, 0.92))

	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ==============================================================================
# 3. MODELLO NEMICO RANGED: DRONE CECCHINO TRI-ALA
# ==============================================================================
static func draw_ranged_enemy(c: CanvasItem, anim_t: float, accent: Color, aim_angle: float, is_charging: bool) -> void:
	c.draw_circle(Vector2(0, 9), 16.0, Color(0, 0, 0, 0.40))
	c.draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 24, Color(0.85, 0.25, 1.0, 0.45), 1.8)

	c.draw_set_transform(Vector2.ZERO, aim_angle, Vector2.ONE)

	# Ali aerodinamiche swept-back
	var wing_l := PackedVector2Array([Vector2(4, -6), Vector2(-14, -20), Vector2(-18, -12), Vector2(-6, -4)])
	var wing_r := PackedVector2Array([Vector2(4, 6), Vector2(-14, 20), Vector2(-18, 12), Vector2(-6, 4)])
	c.draw_colored_polygon(wing_l, Color(0.16, 0.12, 0.26, 1.0))
	c.draw_colored_polygon(wing_r, Color(0.16, 0.12, 0.26, 1.0))
	c.draw_polyline(wing_l, Color(0.85, 0.3, 1.0, 0.9), 1.8)
	c.draw_polyline(wing_r, Color(0.85, 0.3, 1.0, 0.9), 1.8)

	# Doppia Canna Railgun frontale
	c.draw_rect(Rect2(Vector2(4, -6), Vector2(18, 3)), Color(0.25, 0.28, 0.38, 1.0), true)
	c.draw_rect(Rect2(Vector2(4, 3), Vector2(18, 3)), Color(0.25, 0.28, 0.38, 1.0), true)

	# Scocca centrale + Occhio Ottico Cecchino
	c.draw_circle(Vector2(-2, 0), 10.0, Color(0.12, 0.10, 0.20, 1.0))
	c.draw_arc(Vector2(-2, 0), 10.0, 0, TAU, 20, accent, 2.0)
	var eye_col := Color(1.0, 0.15, 0.2, 1.0) if is_charging else Color(0.95, 0.35, 1.0, 1.0)
	c.draw_circle(Vector2(3, 0), 5.0, eye_col)
	c.draw_circle(Vector2(4, 0), 2.2, Color.WHITE)

	var ranged_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_ranged.png")
	if ranged_tex:
		c.draw_texture_rect(ranged_tex, Rect2(Vector2(-23, -23), Vector2(46, 46)), false)

	if is_charging:
		c.draw_circle(Vector2(22, 0), 4.0 + sin(anim_t * 30.0) * 2.0, Color(1.0, 0.2, 0.2, 0.9))

	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ==============================================================================
# 4. MODELLO NEMICO PESANTE: GOLIATH MORTAR MECH
# ==============================================================================
static func draw_heavy_enemy(c: CanvasItem, anim_t: float, charge_ratio: float, aim_angle: float) -> void:
	c.draw_circle(Vector2(0, 10), 24.0, Color(0, 0, 0, 0.50))

	# Esagono di forza & indicatore carica mortaio
	c.draw_arc(Vector2.ZERO, 28.0, 0.0, TAU, 8, Color(1.0, 0.55, 0.1, 0.50), 2.5)
	c.draw_arc(Vector2.ZERO, 32.0, -PI * 0.5, -PI * 0.5 + TAU * charge_ratio, 24, Color(1.0, 0.2, 0.1, 0.85), 2.5)

	c.draw_set_transform(Vector2.ZERO, aim_angle, Vector2.ONE)

	# Cingoli / Piedi Meccanici Corazzati
	c.draw_rect(Rect2(Vector2(-18, -22), Vector2(34, 8)), Color(0.14, 0.14, 0.18, 1.0), true)
	c.draw_rect(Rect2(Vector2(-18, 14), Vector2(34, 8)), Color(0.14, 0.14, 0.18, 1.0), true)

	# Scocca Corazzata Ottagonale Pesante
	var hull := PackedVector2Array([
		Vector2(18, -12), Vector2(22, 0), Vector2(18, 12),
		Vector2(-14, 16), Vector2(-20, 0), Vector2(-14, -16)
	])
	c.draw_colored_polygon(hull, Color(0.22, 0.18, 0.14, 1.0))
	c.draw_polyline(hull, Color(1.0, 0.6, 0.15, 0.95), 2.5)

	# Pod Lanciamissili / Mortai sulle Spalle
	c.draw_rect(Rect2(Vector2(-10, -18), Vector2(16, 7)), Color(0.30, 0.22, 0.16, 1.0), true)
	c.draw_rect(Rect2(Vector2(-10, 11), Vector2(16, 7)), Color(0.30, 0.22, 0.16, 1.0), true)
	c.draw_circle(Vector2(-2, -14.5), 2.8, Color(1.0, 0.25, 0.1, 1.0))
	c.draw_circle(Vector2(-2, 14.5), 2.8, Color(1.0, 0.25, 0.1, 1.0))

	# Bocca da fuoco Mortaio Centrale + Nucleo Reattore
	c.draw_circle(Vector2(-2, 0), 10.0, Color(0.12, 0.10, 0.10, 1.0))
	c.draw_circle(Vector2(-2, 0), 5.0 + charge_ratio * 3.5, Color(1.0, 0.35, 0.05, 0.95))
	c.draw_circle(Vector2(-2, 0), 2.5, Color(1.0, 0.9, 0.5, 1.0))

	var heavy_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_heavy.png")
	if heavy_tex:
		c.draw_texture_rect(heavy_tex, Rect2(Vector2(-28, -28), Vector2(56, 56)), false)

	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ==============================================================================
# 5. MODELLI BOSS OVERLORD (8 BOSS ARTICOLATI PER I MONDI)
# ==============================================================================
static func draw_boss(c: CanvasItem, world_id: String, anim_t: float, boss_col: Color, in_phase_2: bool, aim_angle: float) -> void:
	var active_col := Color(1.0, 0.15, 0.22, 1.0) if in_phase_2 else boss_col

	# Ombra gigante ed anelli olografici controrotanti
	c.draw_circle(Vector2(0, 16), 46.0, Color(0, 0, 0, 0.52))
	c.draw_circle(Vector2.ZERO, 54.0, Color(active_col.r, active_col.g, active_col.b, 0.15))
	c.draw_arc(Vector2.ZERO, 56.0, anim_t * 1.8, anim_t * 1.8 + PI * 1.4, 36, active_col, 3.5)
	c.draw_arc(Vector2.ZERO, 46.0, -anim_t * 2.4, -anim_t * 2.4 + PI * 1.2, 32, Color(1.0, 1.0, 1.0, 0.75), 2.2)

	# Satelliti Difensivi Orbitanti
	var orb_count := 4 if in_phase_2 else 3
	for i in range(orb_count):
		var ang := anim_t * 2.8 + i * (TAU / float(orb_count))
		var orb_pos := Vector2.RIGHT.rotated(ang) * 60.0
		c.draw_circle(orb_pos, 7.0, Color(0.1, 0.12, 0.18, 1.0))
		c.draw_circle(orb_pos, 5.0, active_col)
		c.draw_circle(orb_pos, 2.5, Color.WHITE)

	c.draw_set_transform(Vector2.ZERO, aim_angle, Vector2.ONE)
	var pulse := sin(anim_t * 5.0) * 3.0

	match world_id:
		"world_2":
			# SCORPIONE MECCANICO IMPERIALE (Chele giganti + Coda artigliata al plasma)
			for side in [-1.0, 1.0]:
				var claw := PackedVector2Array([
					Vector2(10, side * 18), Vector2(34, side * 28), Vector2(46, side * (16 - pulse * 0.5)), Vector2(28, side * 12)
				])
				c.draw_colored_polygon(claw, Color(0.24, 0.18, 0.06, 1.0))
				c.draw_polyline(claw, active_col, 2.5)
			# Segmenti coda posteriore con pungiglione laser
			var tail_sway := sin(anim_t * 4.0) * 8.0
			c.draw_circle(Vector2(-24, tail_sway * 0.4), 12.0, Color(0.20, 0.15, 0.05, 1.0))
			c.draw_circle(Vector2(-38, tail_sway), 9.0, active_col)

		"world_4", "world_7":
			# CRYO-VALKYRIE / ARCHON SERAPHIM (Grandi Ali di Energia + Lancia Solare/Ghiaccio)
			var wing_flap := sin(anim_t * 6.0) * 5.0
			for side in [-1.0, 1.0]:
				var wing := PackedVector2Array([
					Vector2(0, side * 14),
					Vector2(-18, side * (52 + wing_flap)),
					Vector2(-36, side * (42 + wing_flap)),
					Vector2(-22, side * 12)
				])
				c.draw_colored_polygon(wing, Color(active_col.r, active_col.g, active_col.b, 0.65))
				c.draw_polyline(wing, Color.WHITE, 2.0)

		"world_8":
			# OMEGA PROTOCOL: A.R.G.O.N. (Ipercubo della Singolarità + 6 Lame del Vuoto)
			for i in range(6):
				var a := anim_t * 1.5 + i * (TAU / 6.0)
				var blade_p1 := Vector2.RIGHT.rotated(a) * 22.0
				var blade_p2 := Vector2.RIGHT.rotated(a + 0.25) * 48.0
				var blade_p3 := Vector2.RIGHT.rotated(a - 0.25) * 48.0
				c.draw_colored_polygon(PackedVector2Array([blade_p1, blade_p2, blade_p3]), Color(active_col.r, active_col.g, active_col.b, 0.75))

		_:
			# TITANO CORAZZATO / DRON-CORE / VULCAN / HYDRA (Spallacci Giganti + Cannoni)
			for side in [-1.0, 1.0]:
				var arm := PackedVector2Array([
					Vector2(-12, side * 22), Vector2(24, side * 34), Vector2(36, side * 20), Vector2(10, side * 14)
				])
				c.draw_colored_polygon(arm, Color(0.16, 0.18, 0.26, 1.0))
				c.draw_polyline(arm, active_col, 2.8)

	# Corpo Centrale Corazzato del Boss + Modello 3D-Shaded Overlord
	var boss_tex := CyberTheme.get_model_texture("res://assets/cyber_models/unit_boss.png")
	if boss_tex:
		c.draw_texture_rect(boss_tex, Rect2(Vector2(-46, -46), Vector2(92, 92)), false, active_col.lightened(0.35))

	# Nucleo Reattore Pulsante + Visiera Ottica Boss
	c.draw_circle(Vector2(0, 0), 15.0 + pulse * 0.5, Color(active_col.r, active_col.g, active_col.b, 0.35))
	c.draw_circle(Vector2(0, 0), 10.0, active_col)
	c.draw_circle(Vector2(0, 0), 5.0, Color.WHITE)
	c.draw_line(Vector2(16, -10), Vector2(24, 0), Color.WHITE, 3.0)
	c.draw_line(Vector2(16, 10), Vector2(24, 0), Color.WHITE, 3.0)

	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ==============================================================================
# 6. MODELLO OSTACOLO: BARRICATA CORAZZATA 2.5D SOLIDA (BLOCCA COLPI E MOVIMENTO)
# ==============================================================================
static func draw_obstacle(c: CanvasItem, accent_col: Color) -> void:
	# Ombra pesante a terra per staccare il pilastro 3D dal pavimento
	c.draw_rect(Rect2(Vector2(-28, -16), Vector2(58, 50)), Color(0, 0, 0, 0.62), true)
	var obs_tex := CyberTheme.get_model_texture("res://assets/cyber_models/prop_obstacle.png")
	if obs_tex:
		c.draw_texture_rect(obs_tex, Rect2(Vector2(-32, -34), Vector2(64, 66)), false)
		c.draw_rect(Rect2(Vector2(-26, -28), Vector2(52, 34)), Color(accent_col.r, accent_col.g, accent_col.b, 0.85), false, 2.0)
	else:
		var base_rect := Rect2(Vector2(-24, -24), Vector2(48, 48))
		c.draw_rect(base_rect, Color(0.08, 0.10, 0.16, 1.0), true)
		c.draw_rect(base_rect, Color(accent_col.r, accent_col.g, accent_col.b, 0.85), false, 2.2)


# ==============================================================================
# 7. MODELLO CASSA RIFORNIMENTI: FORZIERE OLOGRAFICO CYBER
# ==============================================================================
static func draw_loot_crate(c: CanvasItem, anim_t: float, hp_ratio: float) -> void:
	var pulse := 0.75 + sin(anim_t * 6.0) * 0.25
	c.draw_rect(Rect2(Vector2(-20, -14), Vector2(44, 38)), Color(0, 0, 0, 0.42), true)
	var crate_tex := CyberTheme.get_model_texture("res://assets/cyber_models/prop_crate.png")
	if crate_tex:
		c.draw_texture_rect(crate_tex, Rect2(Vector2(-24, -24), Vector2(48, 48)), false, Color(1.0, 1.0, 1.0, 0.92 + pulse * 0.08))
	else:
		var box := Rect2(Vector2(-20, -20), Vector2(40, 40))
		c.draw_rect(box, Color(0.14, 0.16, 0.24, 1.0), true)
		c.draw_rect(box, Color(1.0, 0.84, 0.1, 0.9 * pulse), false, 2.5)

	if hp_ratio < 1.0:
		c.draw_rect(Rect2(Vector2(-20, -30), Vector2(40, 5)), Color(0.08, 0.08, 0.12, 0.9), true)
		c.draw_rect(Rect2(Vector2(-20, -30), Vector2(40.0 * hp_ratio, 5)), Color(1.0, 0.84, 0.0, 1.0), true)
