extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var background: Control = $Background as Control
@onready var dark_bg: ColorRect = get_node_or_null("CanvasLayerBG/DarkBG") as ColorRect

var arena_accent: Color = Color(0.0, 0.94, 1.0, 1.0)
var floor_base: Color = Color(0.03, 0.04, 0.08, 1.0)
var world_title: String = "SETTORE 01"
var pulse_t: float = 0.0
var ambient_motes: Array[Dictionary] = []

func _ready() -> void:
	if background:
		background.visible = false

	CyberTheme.attach_cyber_bloom(self)

	var current_world: WorldData = WorldDB.get_selected_world()
	if current_world:
		arena_accent = current_world.accent_color
		floor_base = current_world.biome_color.darkened(0.30)
		world_title = current_world.display_name.to_upper()
		if dark_bg:
			dark_bg.color = floor_base.darkened(0.35)

	if hud and player and hud.has_method("setup"):
		hud.setup(player)

	# Ordinamento in profondità (Y-Sort): chi sta più in basso viene disegnato davanti → effetto 2.5D/3D reale
	y_sort_enabled = true

	_init_ambient_motes()
	_setup_perimeter_walls()
	_setup_cinematic_vignette()

	# Nel Mondo 1 attiva automaticamente il Sistema Tutorial Interattivo Guidato
	if WorldDB.selected_world_id == "world_1":
		var tut_script := load("res://scripts/tutorial_overlay.gd")
		if tut_script:
			var tut_node: Node2D = tut_script.new()
			tut_node.name = "TutorialOverlay"
			add_child.call_deferred(tut_node)

## Vignettatura cinematografica + luce volumetrica dall'alto: dà profondità 3D all'arena
func _setup_cinematic_vignette() -> void:
	var layer := CanvasLayer.new()
	layer.name = "VignetteLayer"
	layer.layer = 1
	add_child(layer)
	if hud:
		move_child(layer, hud.get_index())

	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0.0))
	grad.set_color(1, Color(0.0, 0.01, 0.04, 0.60))
	grad.add_point(0.64, Color(0, 0, 0, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.48)
	tex.fill_to = Vector2(1.05, 1.05)
	tex.width = 256
	tex.height = 256

	var rect := TextureRect.new()
	rect.texture = tex
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	layer.add_child(rect)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _init_ambient_motes() -> void:
	ambient_motes.clear()
	for i in range(28):
		ambient_motes.append({
			"pos": Vector2(randf_range(52.0, 668.0), randf_range(125.0, 1220.0)),
			"vel": Vector2(randf_range(-14.0, 14.0), randf_range(-28.0, -10.0)),
			"radius": randf_range(1.8, 3.8),
			"phase": randf() * TAU
		})

func _process(delta: float) -> void:
	pulse_t += delta
	for m in ambient_motes:
		var p: Vector2 = m["pos"] + m["vel"] * delta
		if p.y < 120.0:
			p.y = 1230.0
			p.x = randf_range(52.0, 668.0)
		if p.x < 48.0: p.x = 672.0
		elif p.x > 672.0: p.x = 48.0
		m["pos"] = p
	queue_redraw()

func _draw() -> void:
	# 1. Vuoto Abissale Esterno
	draw_rect(Rect2(Vector2(0, 0), Vector2(720, 1280)), Color(0.012, 0.016, 0.032, 1.0), true)

	# 2. Ponte Arena 3D con Gradiente di Profondità Prospettica (più scuro in lontananza a Nord, più vivo al centro)
	var deck_rect := Rect2(Vector2(42, 112), Vector2(636, 1134))
	draw_rect(deck_rect, floor_base.darkened(0.32), true)

	# Canalizzazioni Energetiche Sub-Pavimento (Fiumi di Plasma Sottostanti visibili tra le piastre 3D)
	var trench_glow := Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.24 + 0.08 * sin(pulse_t * 3.0))
	for gx in [148, 254, 360, 466, 572]:
		draw_line(Vector2(gx, 112), Vector2(gx, 1246), trench_glow, 6.0)
		var pulse_y: float = fmod(pulse_t * 175.0 + float(gx) * 1.7, 1134.0) + 112.0
		draw_line(
			Vector2(gx, maxf(112.0, pulse_y - 46.0)),
			Vector2(gx, minf(1246.0, pulse_y + 46.0)),
			Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.80),
			4.0
		)

	for gy in [215, 318, 421, 524, 627, 730, 833, 936, 1039, 1142]:
		draw_line(Vector2(42, gy), Vector2(678, gy), trench_glow, 6.0)
		var pulse_x: float = fmod(pulse_t * 155.0 + float(gy) * 1.3, 636.0) + 42.0
		draw_line(
			Vector2(maxf(42.0, pulse_x - 42.0), gy),
			Vector2(minf(678.0, pulse_x + 42.0), gy),
			Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.80),
			4.0
		)

	# 3. Piastre Metallica 3D PBR in Prospettiva (con shading progressivo Nord -> Sud)
	var floor_tex := CyberTheme.get_model_texture("res://assets/cyber_models/arena_floor_tile.png")
	var tile_w: int = 106
	var tile_h: int = 103
	for col_i in range(6):
		var tx: int = 42 + col_i * tile_w
		for row_i in range(11):
			var ty: int = 112 + row_i * tile_h
			var depth_f: float = 0.78 + 0.26 * (float(row_i) / 10.0)
			var tile_mod := Color(
				clampf((floor_base.r * 3.0 + 0.62) * depth_f, 0.48, 1.18),
				clampf((floor_base.g * 3.0 + 0.62) * depth_f, 0.48, 1.18),
				clampf((floor_base.b * 3.0 + 0.72) * depth_f, 0.54, 1.24),
				0.94
			)
			var tr := Rect2(Vector2(tx + 2, ty + 2), Vector2(tile_w - 4, tile_h - 4))
			if floor_tex:
				draw_texture_rect(floor_tex, tr, false, tile_mod)
			else:
				draw_rect(tr, Color(floor_base.r + 0.03, floor_base.g + 0.035, floor_base.b + 0.05, 0.95), true)
			# Micro-LED angolari incastonati nelle piastre
			draw_circle(Vector2(tx + 10, ty + 10), 1.5, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.30 * depth_f))
			draw_circle(Vector2(tx + tile_w - 10, ty + tile_h - 10), 1.5, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.30 * depth_f))

	# 4. Reattore Centrale Incassato in Prospettiva 2.5D Ellittica (Camera ~65°)
	var center := Vector2(360, 665)
	var ring_alpha: float = 0.30 + sin(pulse_t * 2.5) * 0.08
	draw_set_transform(center, 0.0, Vector2(1.0, 0.56))
	draw_circle(Vector2.ZERO, 178.0, Color(0.01, 0.015, 0.03, 0.55))
	draw_arc(Vector2.ZERO, 178.0, 0.0, TAU, 64, Color(0.22, 0.28, 0.42, 0.75), 5.0)
	draw_circle(Vector2.ZERO, 155.0, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.055))
	draw_circle(Vector2.ZERO, 102.0, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.075))
	draw_arc(Vector2.ZERO, 158.0, 0.0, TAU, 64, Color(arena_accent.r, arena_accent.g, arena_accent.b, ring_alpha * 0.75), 2.4)
	draw_arc(Vector2.ZERO, 132.0, pulse_t * 0.45, pulse_t * 0.45 + PI * 1.4, 48, Color(arena_accent.r, arena_accent.g, arena_accent.b, ring_alpha * 1.25), 3.4)
	draw_arc(Vector2.ZERO, 132.0, pulse_t * 0.45 + PI, pulse_t * 0.45 + PI * 1.6, 32, Color(1.0, 0.9, 0.3, ring_alpha), 2.8)
	draw_arc(Vector2.ZERO, 86.0, -pulse_t * 0.7, -pulse_t * 0.7 + PI * 1.5, 40, Color(arena_accent.r, arena_accent.g, arena_accent.b, ring_alpha * 1.35), 2.5)
	for a_idx in range(4):
		var ang: float = float(a_idx) * PI * 0.5 + pulse_t * 0.2
		draw_line(Vector2(cos(ang), sin(ang)) * 48.0, Vector2(cos(ang), sin(ang)) * 78.0, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.40), 2.2)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 5. ARCHITETTURA MURARIA 3D IN PROSPETTIVA (Parete Nord Alta + Contrafforti 3D + Pareti Laterali Inclinate)
	_draw_3d_arena_architecture()

	# 6. Illuminazione Dinamica Ellittica 2.5D al Suolo sotto Eroe, Nemici e Proiettili
	if is_instance_valid(player):
		var p_col := Global.get_player_accent_color()
		draw_set_transform(player.global_position + Vector2(0, 14), 0.0, Vector2(1.0, 0.48))
		draw_circle(Vector2.ZERO, 68.0, Color(p_col.r, p_col.g, p_col.b, 0.12))
		draw_circle(Vector2.ZERO, 36.0, Color(p_col.r, p_col.g, p_col.b, 0.18))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e) and e is Node2D:
			var ep := (e as Node2D).global_position + Vector2(0, 12)
			draw_set_transform(ep, 0.0, Vector2(1.0, 0.48))
			draw_circle(Vector2.ZERO, 46.0, Color(1.0, 0.16, 0.28, 0.11))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for pr in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(pr) and pr is Node2D:
			var pp := (pr as Node2D).global_position + Vector2(0, 14)
			draw_set_transform(pp, 0.0, Vector2(1.0, 0.48))
			draw_circle(Vector2.ZERO, 26.0, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.14))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 7. Particelle Volumetriche Fluttuanti del Bioma
	for m in ambient_motes:
		var mp: Vector2 = m["pos"]
		var mr: float = m["radius"]
		var ma: float = 0.35 + 0.30 * sin(pulse_t * 3.5 + float(m["phase"]))
		draw_circle(mp, mr * 2.4, Color(arena_accent.r, arena_accent.g, arena_accent.b, ma * 0.28))
		draw_circle(mp, mr, Color(1.0, 0.98, 0.9, ma * 0.85))

func _draw_3d_arena_architecture() -> void:
	var roof_top := Color(0.16, 0.20, 0.31, 1.0)
	var roof_edge := Color(0.28, 0.35, 0.50, 1.0)
	var wall_upper := Color(0.11, 0.14, 0.23, 1.0)
	var wall_lower := Color(0.05, 0.07, 0.13, 1.0)
	var wall_side_face := Color(0.08, 0.10, 0.18, 1.0)

	# --- OMBRE AMBIENT OCCLUSION PROIETTATE SUL PAVIMENTO DALLE PARETI 3D ---
	draw_rect(Rect2(Vector2(42, 112), Vector2(636, 36)), Color(0, 0, 0, 0.48), true)
	draw_rect(Rect2(Vector2(42, 112), Vector2(636, 18)), Color(0, 0, 0, 0.35), true)
	draw_rect(Rect2(Vector2(42, 112), Vector2(22, 1134)), Color(0, 0, 0, 0.42), true)
	draw_rect(Rect2(Vector2(656, 112), Vector2(22, 1134)), Color(0, 0, 0, 0.42), true)

	# --- PARETE NORD 3D IN PROSPETTIVA (Altezza y = 0..112: Tetto Superiore + Facciata Verticale 3D) ---
	# Facciata verticale 3D (y = 28..112) sfumata dall'alto verso il basso
	draw_polygon(
		PackedVector2Array([Vector2(20, 28), Vector2(700, 28), Vector2(678, 112), Vector2(42, 112)]),
		PackedColorArray([wall_upper, wall_upper, wall_lower, wall_lower])
	)
	# Zoccolo corazzato alla base del muro Nord + strisce industriali giallo/nere
	draw_rect(Rect2(Vector2(42, 100), Vector2(636, 12)), Color(0.04, 0.05, 0.09, 1.0), true)
	for sx in range(48, 668, 28):
		if sx < 268 or sx > 446:
			draw_line(Vector2(sx, 102), Vector2(sx + 10, 111), Color(0.95, 0.76, 0.06, 0.78), 3.5)

	# Pannelli Reattore Luminosi Incassati nella Parete Nord
	for wx in [132, 224, 496, 588]:
		draw_rect(Rect2(Vector2(wx - 28, 48), Vector2(56, 36)), Color(0.03, 0.04, 0.08, 0.96), true)
		draw_rect(Rect2(Vector2(wx - 28, 48), Vector2(56, 36)), Color(0.20, 0.26, 0.40, 0.9), false, 2.0)
		var w_glow: float = 0.55 + 0.25 * sin(pulse_t * 3.2 + float(wx) * 0.05)
		draw_rect(Rect2(Vector2(wx - 22, 56), Vector2(44, 7)), Color(arena_accent.r, arena_accent.g, arena_accent.b, w_glow), true)
		draw_rect(Rect2(Vector2(wx - 22, 69), Vector2(44, 7)), Color(arena_accent.r, arena_accent.g, arena_accent.b, w_glow * 0.75), true)
		# Fascio di luce soffusa proiettato sul pavimento dai reattori a muro
		draw_colored_polygon(PackedVector2Array([
			Vector2(wx - 24, 112), Vector2(wx + 24, 112), Vector2(wx + 38, 156), Vector2(wx - 38, 156)
		]), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.06 * w_glow))

	# Contrafforti / Colonne Corazzate 3D Sporgenti lungo la Parete Nord
	for px in [82, 178, 542, 638]:
		# Faccia laterale scura (spessore 3D)
		draw_rect(Rect2(Vector2(px + 10, 28), Vector2(6, 86)), Color(0.04, 0.05, 0.10, 1.0), true)
		# Faccia frontale illuminata della colonna
		draw_rect(Rect2(Vector2(px - 12, 26), Vector2(22, 88)), Color(0.16, 0.21, 0.33, 1.0), true)
		draw_line(Vector2(px - 11, 26), Vector2(px - 11, 114), roof_edge, 2.0)
		draw_line(Vector2(px - 1, 36), Vector2(px - 1, 98), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.70), 2.5)

	# NICCHIA 3D DEL PORTALE STARGATE AL CENTRO DELLA PARETE NORD (x = 278..442)
	draw_rect(Rect2(Vector2(278, 22), Vector2(164, 92)), Color(0.02, 0.03, 0.07, 1.0), true)
	# Stipiti 3D obliqui dell'arco Stargate
	draw_colored_polygon(PackedVector2Array([
		Vector2(266, 20), Vector2(286, 20), Vector2(292, 114), Vector2(272, 114)
	]), Color(0.18, 0.23, 0.36, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(434, 20), Vector2(454, 20), Vector2(448, 114), Vector2(428, 114)
	]), Color(0.14, 0.18, 0.29, 1.0))
	draw_rect(Rect2(Vector2(266, 14), Vector2(188, 16)), Color(0.20, 0.26, 0.40, 1.0), true)
	draw_rect(Rect2(Vector2(266, 14), Vector2(188, 16)), arena_accent, false, 2.0)
	# Bagliore interno Stargate dormiente/attivo
	var gate_pulse: float = 0.35 + 0.15 * sin(pulse_t * 4.0)
	draw_rect(Rect2(Vector2(292, 32), Vector2(136, 80)), Color(arena_accent.r, arena_accent.g, arena_accent.b, gate_pulse * 0.28), true)
	draw_line(Vector2(292, 112), Vector2(428, 112), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.90), 3.0)

	# Tetto / Parapetto Superiore 3D della Parete Nord (y = 0..28)
	draw_rect(Rect2(Vector2(0, 0), Vector2(266, 28)), roof_top, true)
	draw_rect(Rect2(Vector2(454, 0), Vector2(266, 28)), roof_top, true)
	draw_line(Vector2(20, 28), Vector2(266, 28), roof_edge, 3.0)
	draw_line(Vector2(454, 28), Vector2(700, 28), roof_edge, 3.0)

	# --- PARETI LATERALI SINISTRA E DESTRA IN PROSPETTIVA 3D ---
	# Facciata interna inclinata visibile (mostra lo spessore 3D delle mura laterali!)
	draw_colored_polygon(PackedVector2Array([
		Vector2(20, 28), Vector2(42, 112), Vector2(42, 1246), Vector2(20, 1262)
	]), wall_side_face.lightened(0.06))
	draw_colored_polygon(PackedVector2Array([
		Vector2(700, 28), Vector2(678, 112), Vector2(678, 1246), Vector2(700, 1262)
	]), wall_side_face.darkened(0.12))

	# Parapetto superiore delle mura laterali
	draw_rect(Rect2(Vector2(0, 0), Vector2(20, 1280)), roof_top, true)
	draw_rect(Rect2(Vector2(700, 0), Vector2(20, 1280)), roof_top, true)
	draw_line(Vector2(20, 28), Vector2(20, 1262), roof_edge, 2.5)
	draw_line(Vector2(700, 28), Vector2(700, 1262), roof_edge, 2.5)

	# Bobine al Plasma 3D incastonate sulle pareti laterali inclinate + luce sul pavimento
	for wy in [230, 450, 670, 890, 1110]:
		# Parete Sinistra (3D)
		draw_colored_polygon(PackedVector2Array([
			Vector2(22, wy - 28), Vector2(42, wy - 20), Vector2(42, wy + 28), Vector2(22, wy + 20)
		]), Color(0.04, 0.06, 0.11, 1.0))
		draw_line(Vector2(32, wy - 18), Vector2(32, wy + 18), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.85), 5.0)
		draw_line(Vector2(32, wy - 14), Vector2(32, wy + 14), Color.WHITE, 1.8)
		# Parete Destra (3D)
		draw_colored_polygon(PackedVector2Array([
			Vector2(698, wy - 28), Vector2(678, wy - 20), Vector2(678, wy + 28), Vector2(698, wy + 20)
		]), Color(0.04, 0.06, 0.11, 1.0))
		draw_line(Vector2(688, wy - 18), Vector2(688, wy + 18), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.85), 5.0)
		draw_line(Vector2(688, wy - 14), Vector2(688, wy + 14), Color.WHITE, 1.8)

	# --- MURO INFERIORE / PARAPETTO SUD 3D (y = 1246..1280) ---
	draw_rect(Rect2(Vector2(0, 1246), Vector2(720, 34)), roof_top, true)
	draw_rect(Rect2(Vector2(20, 1246), Vector2(680, 8)), roof_edge, true)
	for sx in range(48, 668, 32):
		draw_line(Vector2(sx, 1247), Vector2(sx + 12, 1255), Color(0.95, 0.76, 0.06, 0.72), 3.5)

	# Cornice Laser Perimetrale sul Ponte + 4 Piloni Angolari 3D
	var border_alpha: float = 0.76 + sin(pulse_t * 4.0) * 0.16
	var deck_rect := Rect2(Vector2(42, 112), Vector2(636, 1134))
	draw_rect(deck_rect, Color(arena_accent.r, arena_accent.g, arena_accent.b, border_alpha * 0.25), false, 6.0)
	draw_rect(deck_rect, Color(arena_accent.r, arena_accent.g, arena_accent.b, border_alpha), false, 2.0)

	var corners := [Vector2(42, 112), Vector2(678, 112), Vector2(42, 1246), Vector2(678, 1246)]
	for c in corners:
		draw_circle(c, 13.0, Color(0.05, 0.08, 0.16, 0.98))
		draw_arc(c, 13.0, 0, TAU, 20, arena_accent, 2.2)
		draw_circle(c, 5.5, arena_accent)
		draw_circle(c, 2.5, Color.WHITE)

func _setup_perimeter_walls() -> void:
	# Il muro superiore segue esattamente la base della Parete Nord 3D (y = 104), lasciando la nicchia Stargate accessibile
	var wall_configs := [
		{"pos": Vector2(150, 52), "size": Vector2(300, 104)},
		{"pos": Vector2(570, 52), "size": Vector2(300, 104)},
		{"pos": Vector2(360, 18), "size": Vector2(200, 36)},
		{"pos": Vector2(360, 1266), "size": Vector2(740, 36)},
		{"pos": Vector2(21, 640), "size": Vector2(42, 1280)},
		{"pos": Vector2(699, 640), "size": Vector2(42, 1280)}
	]

	for cfg in wall_configs:
		var wall := StaticBody2D.new()
		wall.position = cfg["pos"]
		wall.add_to_group("walls")
		wall.add_to_group("obstacles")

		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = cfg["size"]
		shape.shape = box
		wall.add_child(shape)

		add_child.call_deferred(wall)
