extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var background: Control = $Background as Control
@onready var dark_bg: ColorRect = get_node_or_null("CanvasLayerBG/DarkBG") as ColorRect

var arena_accent: Color = Color(0.0, 0.94, 1.0, 1.0)
var floor_base: Color = Color(0.03, 0.04, 0.08, 1.0)
var world_id: String = "world_1"
var world_title: String = "SETTORE 01"
var arena_bg_key: String = "arena_bg_street"
var arena_tint: Color = Color.WHITE
var pulse_t: float = 0.0
var ambient_motes: Array[Dictionary] = []

func _ready() -> void:
	if background:
		background.visible = false

	CyberTheme.attach_cyber_bloom(self, true)

	var current_world: WorldData = WorldDB.get_selected_world()
	if current_world:
		world_id = current_world.id
		arena_accent = current_world.accent_color
		floor_base = current_world.biome_color
		world_title = current_world.display_name.to_upper()
		_configure_world_arena_theme(world_id)
		if dark_bg:
			dark_bg.color = Color(0.02, 0.025, 0.045, 1.0)

	if hud and player and hud.has_method("setup"):
		hud.setup(player)

	y_sort_enabled = true

	_init_ambient_motes()
	_setup_perimeter_walls()

	if WorldDB.selected_world_id == "world_1":
		var tut_script := load("res://scripts/tutorial_overlay.gd")
		if tut_script:
			var tut_node: Node2D = tut_script.new()
			tut_node.name = "TutorialOverlay"
			add_child.call_deferred(tut_node)

func _configure_world_arena_theme(wid: String) -> void:
	match wid:
		"world_1": # Serra Bio-Synth
			arena_bg_key = "arena_bg_bio"
			arena_tint = Color(0.95, 1.08, 0.96, 1.0)
		"world_2": # Autostrada Badlands
			arena_bg_key = "arena_bg_foundry"
			arena_tint = Color(1.08, 0.96, 0.82, 1.0)
		"world_3": # Eliporto Arasaka Night City
			arena_bg_key = "arena_bg_street"
			arena_tint = Color(1.02, 1.0, 1.08, 1.0)
		"world_4": # Cripta Criogenica
			arena_bg_key = "arena_bg_vault"
			arena_tint = Color(0.84, 1.04, 1.14, 1.0)
		"world_5": # Fonderia Magmatica
			arena_bg_key = "arena_bg_foundry"
			arena_tint = Color(1.14, 0.84, 0.74, 1.0)
		"world_6": # Condotti Chimici
			arena_bg_key = "arena_bg_bio"
			arena_tint = Color(1.06, 1.12, 0.78, 1.0)
		"world_7": # Hangar Orbitale
			arena_bg_key = "arena_bg_vault"
			arena_tint = Color(1.08, 1.02, 0.90, 1.0)
		"world_8": # Vicolo Kabuki
			arena_bg_key = "arena_bg_street"
			arena_tint = Color(1.14, 0.82, 0.96, 1.0)
		"world_9": # Bastione Militech
			arena_bg_key = "arena_bg_foundry"
			arena_tint = Color(1.12, 0.82, 0.84, 1.0)
		"world_10": # Reattore Abissale
			arena_bg_key = "arena_bg_bio"
			arena_tint = Color(0.76, 1.06, 1.12, 1.0)
		"world_11": # Cupola Selene
			arena_bg_key = "arena_bg_street"
			arena_tint = Color(0.92, 0.98, 1.14, 1.0)
		_: # Mondo 12 Nucleo A.R.G.O.N.
			arena_bg_key = "arena_bg_vault"
			arena_tint = Color(1.12, 0.78, 1.04, 1.0)

func _init_ambient_motes() -> void:
	ambient_motes.clear()
	for i in range(30):
		ambient_motes.append({
			"pos": Vector2(randf_range(44.0, 676.0), randf_range(90.0, 1240.0)),
			"vel": Vector2(randf_range(-16.0, 16.0), randf_range(-34.0, -12.0)),
			"radius": randf_range(1.6, 3.4),
			"phase": randf() * TAU
		})

func _process(delta: float) -> void:
	pulse_t += delta
	for m in ambient_motes:
		var p: Vector2 = m["pos"] + m["vel"] * delta
		if p.y < 90.0:
			p.y = 1240.0
			p.x = randf_range(44.0, 676.0)
		if p.x < 42.0: p.x = 678.0
		elif p.x > 678.0: p.x = 42.0
		m["pos"] = p
	queue_redraw()

func _draw() -> void:
	# 1. Fondale Esterno Full-Bleed con il Vero Panorama HD del Settore (copre schermi 20:9 / 21:9 sopra e sotto!)
	draw_rect(Rect2(Vector2(-200, -460), Vector2(1120, 2240)), Color(0.02, 0.025, 0.045, 1.0), true)

	var sky_tex := CyberTheme.get_model_texture("res://assets/cyber_models/banner_" + world_id + ".png")
	if sky_tex:
		# Panorama Cyberpunk HD del Mondo visibile oltre il varco Nord e riflesso in basso!
		draw_texture_rect(sky_tex, Rect2(Vector2(-40, -340), Vector2(800, 450)), false, Color(0.75, 0.78, 0.86, 0.95))
		draw_texture_rect(sky_tex, Rect2(Vector2(-40, 1246), Vector2(800, 420)), false, Color(0.32, 0.35, 0.44, 0.85))
		draw_polygon(
			PackedVector2Array([Vector2(-60, -40), Vector2(780, -40), Vector2(780, 32), Vector2(-60, 32)]),
			PackedColorArray([Color(0.02, 0.025, 0.045, 0.0), Color(0.02, 0.025, 0.045, 0.0), Color(0.02, 0.025, 0.045, 0.92), Color(0.02, 0.025, 0.045, 0.92)])
		)

	# 2. Arena 2.5D Cyberpunk ad Alta Definizione (Asfalto bagnato, Marciapiedi Neon, Griglie Bio-Tech, Fonderie o Vault Arasaka!)
	var arena_tex := CyberTheme.get_model_texture("res://assets/cyber_models/" + arena_bg_key + ".png")
	if arena_tex:
		draw_texture_rect(arena_tex, Rect2(Vector2(0, 0), Vector2(720, 1272)), false, arena_tint)
	else:
		draw_rect(Rect2(Vector2(42, 112), Vector2(636, 1134)), floor_base, true)

	# Leggero velo di contrasto al centro della carreggiata per garantire leggibilità perfetta di nemici e proiettili
	draw_rect(Rect2(Vector2(46, 116), Vector2(628, 1126)), Color(0.02, 0.03, 0.06, 0.18), true)

	# 3. Dettagli Urbani Cyberpunk Dinamici (Insegne Olografiche Laterali, Riflessi Neon sulle Pozzanghere & Portale Nord)
	var gate_pulse: float = 0.55 + 0.30 * sin(pulse_t * 3.8)
	# Insegna olografica del Settore incastonata sopra il portale Nord (x = 270..450)
	draw_rect(Rect2(Vector2(262, 6), Vector2(196, 22)), Color(0.02, 0.03, 0.06, 0.88), true)
	draw_rect(Rect2(Vector2(262, 6), Vector2(196, 22)), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.72), false, 1.4)
	var fnt: Font = CyberTheme.get_cyber_font(true)
	if fnt:
		draw_string(fnt, Vector2(268, 22), world_title, HORIZONTAL_ALIGNMENT_CENTER, 184.0, 12, arena_accent.lightened(0.25))

	# Luce volumetrica soffusa dal Portale Nord sul manto stradale
	draw_polygon(
		PackedVector2Array([Vector2(292, 112), Vector2(428, 112), Vector2(468, 210), Vector2(252, 210)]),
		PackedColorArray([
			Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.20 * gate_pulse),
			Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.20 * gate_pulse),
			Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.0),
			Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.0)
		])
	)

	# Tubi al neon & proiettori stradali lungo i marciapiedi/muri laterali
	for wy in [240, 480, 720, 960, 1160]:
		var side_glow: float = 0.45 + 0.20 * sin(pulse_t * 3.2 + float(wy) * 0.02)
		draw_line(Vector2(38, wy - 26), Vector2(38, wy + 26), Color(arena_accent.r, arena_accent.g, arena_accent.b, side_glow), 3.0)
		draw_line(Vector2(682, wy - 26), Vector2(682, wy + 26), Color(arena_accent.r, arena_accent.g, arena_accent.b, side_glow), 3.0)

	# Delimitazione perimetrale chirurgica (sottile linea laser di confine calpestabile + zoccolo Sud)
	var deck_rect := Rect2(Vector2(42, 112), Vector2(636, 1134))
	draw_rect(deck_rect, Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.34), false, 1.6)
	draw_rect(Rect2(Vector2(0, 1246), Vector2(720, 28)), Color(0.04, 0.05, 0.09, 0.94), true)
	draw_line(Vector2(24, 1246), Vector2(696, 1246), Color(arena_accent.r, arena_accent.g, arena_accent.b, 0.65), 2.0)

	# 4. Pioggia Cyberpunk / Scintille Ambientali del Mondo
	var is_rainy: bool = world_id in ["world_3", "world_8", "world_10", "world_11"]
	if is_rainy:
		for r_i in range(24):
			var rx: float = fmod(float(r_i) * 79.0 + pulse_t * 36.0, 660.0) + 30.0
			var ry: float = fmod(float(r_i) * 149.0 + pulse_t * (430.0 + float(r_i % 3) * 60.0), 1180.0) + 80.0
			draw_line(Vector2(rx, ry), Vector2(rx - 8.0, ry + 36.0), Color(0.55, 0.88, 1.0, 0.16), 1.3)

	# 5. Riflettori Tattici 2.5D sotto Eroe, Nemici e Proiettili (stacco netto dal manto stradale HD!)
	if is_instance_valid(player):
		var p_col := Global.get_player_accent_color()
		draw_set_transform(player.global_position + Vector2(0, 14), 0.0, Vector2(1.0, 0.48))
		draw_circle(Vector2.ZERO, 82.0, Color(p_col.r, p_col.g, p_col.b, 0.20))
		draw_circle(Vector2.ZERO, 44.0, Color(1.0, 1.0, 1.0, 0.12))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e) and e is Node2D:
			var ep := (e as Node2D).global_position + Vector2(0, 12)
			draw_set_transform(ep, 0.0, Vector2(1.0, 0.48))
			draw_circle(Vector2.ZERO, 54.0, Color(1.0, 0.16, 0.28, 0.22))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for m in ambient_motes:
		var mp: Vector2 = m["pos"]
		var mr: float = m["radius"]
		var ma: float = 0.30 + 0.26 * sin(pulse_t * 3.5 + float(m["phase"]))
		draw_circle(mp, mr * 2.2, Color(arena_accent.r, arena_accent.g, arena_accent.b, ma * 0.24))
		draw_circle(mp, mr, Color(1.0, 0.98, 0.92, ma * 0.78))

func _setup_perimeter_walls() -> void:
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
