extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var background: Control = $Background as Control
@onready var dark_bg: ColorRect = get_node_or_null("CanvasLayerBG/DarkBG") as ColorRect

var arena_accent: Color = Color(0.0, 0.94, 1.0, 1.0)
var floor_base: Color = Color(0.03, 0.04, 0.08, 1.0)
var pulse_t: float = 0.0

func _ready() -> void:
	if background:
		background.visible = false

	CyberTheme.attach_cyber_bloom(self)

	var current_world: WorldData = WorldDB.get_selected_world()
	if current_world:
		arena_accent = current_world.accent_color
		floor_base = current_world.biome_color.darkened(0.35)
		if dark_bg:
			dark_bg.color = floor_base

	if hud and player and hud.has_method("setup"):
		hud.setup(player)

	_setup_perimeter_walls()

func _process(delta: float) -> void:
	pulse_t += delta
	queue_redraw()

func _draw() -> void:
	# 1. Sfondo Esterno Mura Corazzate Perimetrali
	draw_rect(Rect2(Vector2(0, 0), Vector2(720, 1280)), Color(0.02, 0.025, 0.045, 1.0), true)

	# 2. Area Calpestabile Interna dell'Arena (Pavimento Corazzato a Lastre Metalliche)
	var floor_rect := Rect2(Vector2(24, 34), Vector2(672, 1212))
	draw_rect(floor_rect, floor_base, true)

	# Piastre metalliche del pavimento con fughe scure e rivetti angolari (molto leggibili ma non invasive)
	var seam_col := Color(0.01, 0.015, 0.03, 0.55)
	var highlight_col := Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.07)
	var tile_w := 112
	var tile_h := 110
	for tx in range(24, 696, tile_w):
		for ty in range(34, 1246, tile_h):
			var tr := Rect2(Vector2(tx + 2, ty + 2), Vector2(tile_w - 4, tile_h - 4))
			draw_rect(tr, Color(floor_base.r + 0.018, floor_base.g + 0.022, floor_base.b + 0.035, 0.95), true)
			draw_rect(tr, seam_col, false, 2.0)
			# Piccoli rivetti metallici sugli angoli della lastra
			draw_circle(Vector2(tx + 8, ty + 8), 1.5, highlight_col)
			draw_circle(Vector2(tx + tile_w - 8, ty + 8), 1.5, highlight_col)

	# 3. Condotti Energetici Sub-Pavimento e Piattaforma Tattica Centrale (Zona di Spawn Sicura)
	var center := Vector2(360, 640)
	var conduit_col := Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.16)
	draw_line(Vector2(24, 640), Vector2(210, 640), conduit_col, 3.0)
	draw_line(Vector2(510, 640), Vector2(696, 640), conduit_col, 3.0)
	draw_line(Vector2(360, 34), Vector2(360, 490), conduit_col, 3.0)
	draw_line(Vector2(360, 790), Vector2(360, 1246), conduit_col, 3.0)

	var ring_alpha := 0.18 + sin(pulse_t * 2.5) * 0.04
	draw_circle(center, 145.0, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.04))
	draw_arc(center, 145.0, 0.0, TAU, 48, Color(arena_accent.r, arena_accent.g, arena_accent.b, ring_alpha), 2.2)
	draw_arc(center, 95.0, pulse_t * 0.4, pulse_t * 0.4 + PI * 1.6, 36, Color(arena_accent.r, arena_accent.g, arena_accent.b, ring_alpha * 1.1), 1.8)

	# 4. Mura Perimetrali 2.5D Corazzate (Bordi Solidi dell'Arena)
	var wall_metal := Color(0.11, 0.14, 0.22, 1.0)
	var wall_dark := Color(0.06, 0.08, 0.13, 1.0)
	# Muro Superiore 2.5D con Portale Blindato al centro
	draw_rect(Rect2(Vector2(0, 0), Vector2(720, 34)), wall_metal, true)
	draw_rect(Rect2(Vector2(24, 22), Vector2(672, 12)), wall_dark, true)
	# Portale di Settore Superiore
	draw_rect(Rect2(Vector2(270, 4), Vector2(180, 28)), Color(0.04, 0.06, 0.12, 1.0), true)
	draw_rect(Rect2(Vector2(270, 4), Vector2(180, 28)), arena_accent, false, 2.5)
	draw_line(Vector2(285, 18), Vector2(435, 18), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.75), 3.0)

	# Muro Inferiore 2.5D
	draw_rect(Rect2(Vector2(0, 1246), Vector2(720, 34)), wall_metal, true)
	# Mura Laterali Sinistra e Destra
	draw_rect(Rect2(Vector2(0, 0), Vector2(24, 1280)), wall_metal, true)
	draw_rect(Rect2(Vector2(696, 0), Vector2(24, 1280)), wall_metal, true)

	# 5. Strisce Giallo/Nere di Pericolo Industriale lungo il bordo Muro-Pavimento
	for sx in range(32, 680, 32):
		if sx < 260 or sx > 455:
			draw_line(Vector2(sx, 24), Vector2(sx + 12, 33), Color(0.95, 0.75, 0.05, 0.65), 4.0)
		draw_line(Vector2(sx, 1247), Vector2(sx + 12, 1256), Color(0.95, 0.75, 0.05, 0.65), 4.0)

	# 6. Barriera Laser Perimetrale & Pilastri Angolari (Rimbalzo Proiettili)
	var border_alpha := 0.75 + sin(pulse_t * 4.0) * 0.15
	draw_rect(floor_rect, Color(arena_accent.r, arena_accent.g, arena_accent.b, border_alpha * 0.28), false, 6.0)
	draw_rect(floor_rect, Color(arena_accent.r, arena_accent.g, arena_accent.b, border_alpha), false, 2.5)

	var corners := [Vector2(24, 34), Vector2(696, 34), Vector2(24, 1246), Vector2(696, 1246)]
	for c in corners:
		draw_circle(c, 12.0, Color(0.05, 0.07, 0.14, 0.98))
		draw_arc(c, 12.0, 0, TAU, 16, arena_accent, 2.2)
		draw_circle(c, 5.0, Color.WHITE)

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
