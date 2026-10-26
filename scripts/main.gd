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
		floor_base = current_world.biome_color.darkened(0.35)
		world_title = current_world.display_name.to_upper()
		if dark_bg:
			dark_bg.color = floor_base

	if hud and player and hud.has_method("setup"):
		hud.setup(player)

	_init_ambient_motes()
	_setup_perimeter_walls()

func _init_ambient_motes() -> void:
	ambient_motes.clear()
	for i in range(28):
		ambient_motes.append({
			"pos": Vector2(randf_range(40.0, 680.0), randf_range(60.0, 1220.0)),
			"vel": Vector2(randf_range(-14.0, 14.0), randf_range(-28.0, -10.0)),
			"radius": randf_range(1.8, 3.8),
			"phase": randf() * TAU
		})

func _process(delta: float) -> void:
	pulse_t += delta
	for m in ambient_motes:
		var p: Vector2 = m["pos"] + m["vel"] * delta
		if p.y < 44.0:
			p.y = 1230.0
			p.x = randf_range(40.0, 680.0)
		if p.x < 36.0: p.x = 684.0
		elif p.x > 684.0: p.x = 36.0
		m["pos"] = p
	queue_redraw()

func _draw() -> void:
	# 1. Sfondo Corazzato Esterno
	draw_rect(Rect2(Vector2(0, 0), Vector2(720, 1280)), Color(0.015, 0.02, 0.04, 1.0), true)

	# 2. Canalizzazioni Energetiche Sub-Pavimento (Fiumi di Plasma Sottostanti)
	var floor_rect := Rect2(Vector2(24, 34), Vector2(672, 1212))
	draw_rect(floor_rect, floor_base.darkened(0.25), true)

	var trench_glow := Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.22 + 0.08 * sin(pulse_t * 3.0))
	for gx in [136, 248, 360, 472, 584]:
		draw_line(Vector2(gx, 34), Vector2(gx, 1246), trench_glow, 6.0)
		var pulse_y := fmod(pulse_t * 180.0 + float(gx) * 1.7, 1212.0) + 34.0
		draw_line(Vector2(gx, max(34.0, pulse_y - 45.0)), Vector2(gx, min(1246.0, pulse_y + 45.0)), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.75), 4.0)

	for gy in [144, 254, 364, 474, 584, 694, 804, 914, 1024, 1134]:
		draw_line(Vector2(24, gy), Vector2(696, gy), trench_glow, 6.0)
		var pulse_x := fmod(pulse_t * 160.0 + float(gy) * 1.3, 672.0) + 24.0
		draw_line(Vector2(max(24.0, pulse_x - 40.0), gy), Vector2(min(696.0, pulse_x + 40.0), gy), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.75), 4.0)

	# 3. Lastre Pavimento 3D-Shaded Cyberpunk (Texture metallica 3D + accenti bioma)
	var floor_tex := CyberTheme.get_model_texture("res://assets/cyber_models/arena_floor_tile.png")
	var tile_w := 112
	var tile_h := 110
	var tile_mod := Color(
		clampf(floor_base.r * 3.2 + 0.55, 0.55, 1.15),
		clampf(floor_base.g * 3.2 + 0.55, 0.55, 1.15),
		clampf(floor_base.b * 3.2 + 0.65, 0.60, 1.20),
		0.92
	)
	for tx in range(24, 696, tile_w):
		for ty in range(34, 1246, tile_h):
			var tr := Rect2(Vector2(tx + 2, ty + 2), Vector2(tile_w - 4, tile_h - 4))
			if floor_tex:
				draw_texture_rect(floor_tex, tr, false, tile_mod)
			else:
				draw_rect(tr, Color(floor_base.r + 0.02, floor_base.g + 0.025, floor_base.b + 0.04, 0.95), true)
			# Micro-LED angolari su ogni piastra
			draw_circle(Vector2(tx + 9, ty + 9), 1.6, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.28))
			draw_circle(Vector2(tx + tile_w - 9, ty + tile_h - 9), 1.6, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.28))

	# 4. Reattore Olografico Tattico Centrale (Multi-anello rotante)
	var center := Vector2(360, 640)
	var ring_alpha := 0.28 + sin(pulse_t * 2.5) * 0.08
	draw_circle(center, 165.0, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.045))
	draw_circle(center, 110.0, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.06))
	draw_arc(center, 165.0, 0.0, TAU, 64, Color(arena_accent.r, arena_accent.g, arena_accent.b, ring_alpha * 0.7), 2.0)
	draw_arc(center, 138.0, pulse_t * 0.45, pulse_t * 0.45 + PI * 1.4, 48, Color(arena_accent.r, arena_accent.g, arena_accent.b, ring_alpha * 1.2), 3.0)
	draw_arc(center, 138.0, pulse_t * 0.45 + PI, pulse_t * 0.45 + PI * 1.6, 32, Color(1.0, 0.9, 0.3, ring_alpha), 2.5)
	draw_arc(center, 92.0, -pulse_t * 0.7, -pulse_t * 0.7 + PI * 1.5, 40, Color(arena_accent.r, arena_accent.g, arena_accent.b, ring_alpha * 1.3), 2.2)

	# Mirino tattico centrale
	for a_idx in range(4):
		var ang := a_idx * PI * 0.5 + pulse_t * 0.2
		var p_in := center + Vector2(cos(ang), sin(ang)) * 55.0
		var p_out := center + Vector2(cos(ang), sin(ang)) * 82.0
		draw_line(p_in, p_out, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.35), 2.0)

	# 5. Illuminazione Dinamica al Suolo sotto Eroe, Nemici e Proiettili (Real-Time Floor Light)
	if is_instance_valid(player):
		var p_col := Global.get_player_accent_color()
		draw_circle(player.global_position, 56.0, Color(p_col.r, p_col.g, p_col.b, 0.11))
		draw_circle(player.global_position, 30.0, Color(p_col.r, p_col.g, p_col.b, 0.16))

	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e) and e is Node2D:
			var ep := (e as Node2D).global_position
			draw_circle(ep, 42.0, Color(1.0, 0.18, 0.28, 0.10))

	for pr in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(pr) and pr is Node2D:
			var pp := (pr as Node2D).global_position
			draw_circle(pp, 24.0, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.12))

	# 6. Particelle Ambientali Fluttuanti del Bioma (Data Motes / Scintille)
	for m in ambient_motes:
		var mp: Vector2 = m["pos"]
		var mr: float = m["radius"]
		var ma := 0.35 + 0.30 * sin(pulse_t * 3.5 + float(m["phase"]))
		draw_circle(mp, mr * 2.4, Color(arena_accent.r, arena_accent.g, arena_accent.b, ma * 0.28))
		draw_circle(mp, mr, Color(1.0, 0.98, 0.9, ma * 0.85))

	# 7. Mura Perimetrali 2.5D Corazzate con Bobine Al Plasma Laterali
	var wall_metal := Color(0.10, 0.13, 0.21, 1.0)
	var wall_bevel := Color(0.18, 0.23, 0.35, 1.0)
	var wall_dark := Color(0.05, 0.07, 0.12, 1.0)

	# Muro Superiore 2.5D + Baia Portale Stargate
	draw_rect(Rect2(Vector2(0, 0), Vector2(720, 34)), wall_metal, true)
	draw_rect(Rect2(Vector2(24, 22), Vector2(672, 12)), wall_dark, true)
	draw_line(Vector2(24, 22), Vector2(696, 22), wall_bevel, 2.0)

	# Baia di Attracco Stargate Superiore
	draw_rect(Rect2(Vector2(256, 2), Vector2(208, 30)), Color(0.03, 0.05, 0.10, 1.0), true)
	draw_rect(Rect2(Vector2(256, 2), Vector2(208, 30)), arena_accent, false, 2.5)
	draw_line(Vector2(272, 17), Vector2(448, 17), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.85), 3.5)

	# Muro Inferiore 2.5D
	draw_rect(Rect2(Vector2(0, 1246), Vector2(720, 34)), wall_metal, true)
	draw_rect(Rect2(Vector2(24, 1246), Vector2(672, 10)), wall_bevel, true)

	# Mura Laterali Sinistra e Destra con Bobine Reattore ogni 220px
	draw_rect(Rect2(Vector2(0, 0), Vector2(24, 1280)), wall_metal, true)
	draw_rect(Rect2(Vector2(696, 0), Vector2(24, 1280)), wall_metal, true)

	for wy in [180, 410, 640, 870, 1100]:
		# Bobina parete sinistra
		draw_rect(Rect2(Vector2(4, wy - 26), Vector2(20, 52)), wall_dark, true)
		draw_rect(Rect2(Vector2(6, wy - 20), Vector2(14, 40)), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.65), true)
		# Bobina parete destra
		draw_rect(Rect2(Vector2(696, wy - 26), Vector2(20, 52)), wall_dark, true)
		draw_rect(Rect2(Vector2(700, wy - 20), Vector2(14, 40)), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.65), true)

	# 8. Strisce Giallo/Nere di Pericolo Industriale lungo il bordo Muro-Pavimento
	for sx in range(32, 680, 32):
		if sx < 250 or sx > 465:
			draw_line(Vector2(sx, 24), Vector2(sx + 12, 33), Color(0.95, 0.75, 0.05, 0.72), 4.0)
		draw_line(Vector2(sx, 1247), Vector2(sx + 12, 1256), Color(0.95, 0.75, 0.05, 0.72), 4.0)

	# 9. Barriera Laser Perimetrale & Torrette Energetiche Angolari
	var border_alpha := 0.78 + sin(pulse_t * 4.0) * 0.16
	draw_rect(floor_rect, Color(arena_accent.r, arena_accent.g, arena_accent.b, border_alpha * 0.30), false, 7.0)
	draw_rect(floor_rect, Color(arena_accent.r, arena_accent.g, arena_accent.b, border_alpha), false, 2.5)

	var corners := [Vector2(24, 34), Vector2(696, 34), Vector2(24, 1246), Vector2(696, 1246)]
	for c in corners:
		draw_circle(c, 16.0, Color(0.05, 0.08, 0.16, 0.98))
		draw_arc(c, 16.0, 0, TAU, 20, arena_accent, 2.5)
		draw_circle(c, 7.0, arena_accent)
		draw_circle(c, 3.5, Color.WHITE)

func _setup_perimeter_walls() -> void:
	var wall_configs := [
		{"pos": Vector2(360, 10), "size": Vector2(740, 20)},
		{"pos": Vector2(360, 1270), "size": Vector2(740, 20)},
		{"pos": Vector2(10, 640), "size": Vector2(20, 1280)},
		{"pos": Vector2(710, 640), "size": Vector2(20, 1280)}
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
