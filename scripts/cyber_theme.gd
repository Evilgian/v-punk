class_name CyberTheme
extends RefCounted

# Palette Iconica Cyberpunk (Night City Yellow, Cyber Cyan, Neon Magenta, Obsidian Dark)
const COL_BG_DEEP := Color(0.03, 0.04, 0.08, 1.0)
const COL_PANEL := Color(0.06, 0.08, 0.14, 0.94)
const COL_CYAN := Color(0.0, 0.95, 1.0, 1.0)
const COL_MAGENTA := Color(1.0, 0.08, 0.45, 1.0)
const COL_YELLOW := Color(0.99, 0.93, 0.04, 1.0)
const COL_GREEN := Color(0.1, 1.0, 0.55, 1.0)

static var _tex_cache: Dictionary = {}

## Carica in modo istantaneo (e mette in cache) i modelli 3D-shaded PNG sia su PC/Editor sia dentro l'APK Android
static func get_model_texture(res_path: String) -> Texture2D:
	if _tex_cache.has(res_path):
		return _tex_cache[res_path]
	# 1. Lettura diretta buffer PNG da res:// (funziona sia nell'Editor sia dentro il file .apk / .pck su Android!)
	if FileAccess.file_exists(res_path):
		var bytes := FileAccess.get_file_as_bytes(res_path)
		if not bytes.is_empty():
			var img := Image.new()
			if img.load_png_from_buffer(bytes) == OK and not img.is_empty():
				var tex := ImageTexture.create_from_image(img)
				_tex_cache[res_path] = tex
				return tex
	# 2. Fallback da filesystem globale
	var abs_path := ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(abs_path):
		var img2 := Image.load_from_file(abs_path)
		if img2 and not img2.is_empty():
			var tex2 := ImageTexture.create_from_image(img2)
			_tex_cache[res_path] = tex2
			return tex2
	# 3. Fallback ResourceLoader standard
	if ResourceLoader.exists(res_path):
		var res_tex := load(res_path) as Texture2D
		if res_tex:
			_tex_cache[res_path] = res_tex
			return res_tex
	return null

## Restituisce la texture 3D-shaded corrispondente a un ID arma/corazza/anello/drone
static func get_item_model_texture(item_id: String, slot_name: String = "") -> Texture2D:
	var id_low := item_id.to_lower()
	var slot_up := slot_name.to_upper()
	var file_name := "weapon_pistol_base.png"

	if "katana" in id_low:
		file_name = "weapon_katana.png"
	elif "scythe" in id_low:
		file_name = "weapon_scythe.png"
	elif "plasma" in id_low:
		file_name = "weapon_plasma_cannon.png"
	elif "laser" in id_low and ("rifle" in id_low or "arma" in slot_up or "weapon" in slot_up):
		file_name = "weapon_laser_rifle.png"
	elif "shotgun" in id_low:
		file_name = "weapon_shotgun.png"
	elif "smg" in id_low:
		file_name = "weapon_smg.png"
	elif "wand" in id_low or "homing" in id_low:
		file_name = "weapon_homing_wand.png"
	elif "pistol" in id_low:
		file_name = "weapon_pistol_base.png"
	elif "nano" in id_low:
		file_name = "armor_nano_armor.png"
	elif "kevlar" in id_low or "armor" in id_low or "corazza" in slot_up:
		file_name = "armor_kevlar.png"
	elif "speed" in id_low:
		file_name = "ring_speed.png"
	elif "crit" in id_low or "ring" in id_low or "anello" in slot_up:
		file_name = "ring_crit.png"
	elif "shield" in id_low:
		file_name = "drone_shield.png"
	elif "drone" in id_low or "pet" in slot_up:
		file_name = "drone_laser.png"

	return get_model_texture("res://assets/cyber_models/" + file_name)

## Crea uno StyleBoxFlat con taglio obliquo Cyberpunk (skew), bordo al neon e ombra luminosa
static func make_cyber_box(
	bg: Color = COL_PANEL,
	border: Color = COL_CYAN,
	skew_x: float = 0.08,
	border_w: int = 2,
	left_accent_w: int = 6,
	glow_size: int = 6
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.skew = Vector2(skew_x, 0.0)
	sb.border_width_left = max(border_w, left_accent_w)
	sb.border_width_top = border_w
	sb.border_width_right = border_w
	sb.border_width_bottom = border_w
	sb.border_color = border
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 2
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	if glow_size > 0:
		sb.shadow_color = Color(border.r, border.g, border.b, 0.25)
		sb.shadow_size = glow_size
	return sb

## Applica uno stile pulsante Cyberpunk (es. Giallo CP2077, Ciano Olografico o Magenta)
static func style_button(btn: Button, accent: Color = COL_CYAN, is_primary_yellow: bool = false) -> void:
	if not btn: return
	if is_primary_yellow:
		var sb_norm := make_cyber_box(COL_YELLOW, Color.WHITE, 0.12, 2, 10, 10)
		var sb_hov := make_cyber_box(Color(1.0, 0.97, 0.35, 1.0), COL_CYAN, 0.12, 2, 10, 14)
		var sb_prs := make_cyber_box(COL_CYAN, Color.WHITE, 0.12, 2, 10, 12)
		btn.add_theme_stylebox_override("normal", sb_norm)
		btn.add_theme_stylebox_override("hover", sb_hov)
		btn.add_theme_stylebox_override("pressed", sb_prs)
		btn.add_theme_color_override("font_color", Color(0.04, 0.05, 0.08, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(0.02, 0.02, 0.05, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(0.02, 0.02, 0.05, 1.0))
		btn.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 1.0, 0.4))
		btn.add_theme_constant_override("outline_size", 1)
	else:
		var bg_norm := Color(0.07, 0.10, 0.18, 0.95)
		var bg_hov := Color(accent.r * 0.28, accent.g * 0.28, accent.b * 0.28, 0.98)
		var bg_dis := Color(0.06, 0.07, 0.10, 0.70)
		btn.add_theme_stylebox_override("normal", make_cyber_box(bg_norm, accent, 0.10, 2, 6, 5))
		btn.add_theme_stylebox_override("hover", make_cyber_box(bg_hov, accent.lightened(0.35), 0.10, 2, 8, 9))
		btn.add_theme_stylebox_override("pressed", make_cyber_box(accent * 0.45, Color.WHITE, 0.10, 2, 8, 10))
		btn.add_theme_stylebox_override("disabled", make_cyber_box(bg_dis, Color(0.25, 0.28, 0.35, 0.5), 0.10, 1, 3, 0))
		btn.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
		btn.add_theme_color_override("font_hover_color", accent.lightened(0.4))
		btn.add_theme_color_override("font_disabled_color", Color(0.45, 0.48, 0.55, 0.7))
		btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.06, 0.95))
		btn.add_theme_constant_override("outline_size", 3)

## Stilizza un Label con outline profondo e leggibilità Cyberpunk
static func style_label(lbl: Label, col: Color = Color.WHITE, outline_size: int = 3) -> void:
	if not lbl: return
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.95))
	lbl.add_theme_constant_override("outline_size", outline_size)

## Percorre ricorsivamente un albero UI per applicare il look Cyberpunk a tutti i Button e Label
static func apply_recursive_cyber_style(root: Node) -> void:
	if not root: return
	if root is Button:
		var b := root as Button
		var txt := b.text.to_upper()
		var is_yellow := ("START" in txt or "GIOCA" in txt or "RIPRENDI" in txt or "RISCATTA" in txt)
		var col := COL_MAGENTA if ("EPIC" in txt or "FUSIONE" in txt or "MENU" in txt) else COL_CYAN
		style_button(b, col, is_yellow)
	elif root is Label:
		var l := root as Label
		l.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.92))
		if not l.has_theme_constant_override("outline_size"):
			l.add_theme_constant_override("outline_size", 3)

	for child in root.get_children():
		apply_recursive_cyber_style(child)

## Aggiunge il post-processing HDR Glow/Bloom Cyberpunk alla scena corrente
static func attach_cyber_bloom(parent: Node) -> void:
	if not parent: return
	if parent.get_node_or_null("CyberWorldEnv") != null: return

	var we := WorldEnvironment.new()
	we.name = "CyberWorldEnv"
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.65
	env.glow_strength = 0.95
	env.glow_bloom = 0.15
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	env.glow_hdr_threshold = 0.85
	we.environment = env
	parent.add_child(we)

## Disegna uno sfondo Cyberpunk animato (Skyline Night City, Griglia Synthwave in prospettiva, Digital Rain e Scanlines)
static func draw_cyberpunk_backdrop(c: CanvasItem, size: Vector2, t: float, accent: Color = COL_CYAN) -> void:
	# 1. Cielo notturno abissale + Orizzonte magenta/ciano
	c.draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.025, 0.055, 1.0), true)
	var horizon_y := size.y * 0.58
	c.draw_rect(Rect2(Vector2(0, horizon_y - 160), Vector2(size.x, 160)), Color(0.18, 0.03, 0.22, 0.25), true)
	c.draw_rect(Rect2(Vector2(0, horizon_y - 70), Vector2(size.x, 70)), Color(accent.r * 0.3, accent.g * 0.3, accent.b * 0.3, 0.28), true)

	# 2. Sole Olografico Retrowave / Nucleo Orbitale sull'orizzonte
	var sun_center := Vector2(size.x * 0.5, horizon_y - 50.0)
	c.draw_circle(sun_center, 95.0, Color(1.0, 0.08, 0.45, 0.16))
	c.draw_arc(sun_center, 95.0, PI, TAU, 36, Color(1.0, 0.15, 0.55, 0.45), 2.5)
	c.draw_arc(sun_center, 72.0, PI, TAU, 32, Color(0.0, 0.95, 1.0, 0.35), 1.8)

	# 3. Silhouette Grattacieli Megacorp (Night City Skyline)
	var bld_widths := [65.0, 85.0, 55.0, 95.0, 70.0, 90.0, 60.0, 80.0, 75.0, 65.0]
	var bld_heights := [220.0, 310.0, 180.0, 350.0, 250.0, 330.0, 200.0, 290.0, 240.0, 210.0]
	var cur_x := -10.0
	for i in range(bld_widths.size()):
		var bw: float = bld_widths[i]
		var bh: float = bld_heights[i]
		var by: float = horizon_y - bh
		var b_rect := Rect2(Vector2(cur_x, by), Vector2(bw + 4.0, bh))
		c.draw_rect(b_rect, Color(0.035, 0.045, 0.09, 0.96), true)
		var edge_col := COL_CYAN if (i % 2 == 0) else COL_MAGENTA
		c.draw_line(Vector2(cur_x, by), Vector2(cur_x + bw, by), Color(edge_col.r, edge_col.g, edge_col.b, 0.55), 2.0)
		c.draw_line(Vector2(cur_x + bw * 0.5, by), Vector2(cur_x + bw * 0.5, by - 28.0), Color(edge_col.r, edge_col.g, edge_col.b, 0.45), 1.5)
		# Finestre al neon sui grattacieli
		for wy in range(int(by + 16), int(horizon_y - 16), 22):
			if (( wy + i * 7) % 3) != 0:
				var win_col := Color(edge_col.r, edge_col.g, edge_col.b, 0.22 + sin(t * 2.0 + float(i + wy)) * 0.08)
				c.draw_rect(Rect2(Vector2(cur_x + 10, wy), Vector2(bw - 20, 5)), win_col, true)
		cur_x += bw

	# 4. Griglia Prospettica 3D Synth-Cyber sotto l'orizzonte
	c.draw_rect(Rect2(Vector2(0, horizon_y), Vector2(size.x, size.y - horizon_y)), Color(0.025, 0.03, 0.065, 0.98), true)
	c.draw_line(Vector2(0, horizon_y), Vector2(size.x, horizon_y), Color(1.0, 0.1, 0.5, 0.75), 2.5)

	var vanish := Vector2(size.x * 0.5, horizon_y)
	for i in range(-8, 9):
		var bottom_x := size.x * 0.5 + float(i) * 95.0
		c.draw_line(vanish, Vector2(bottom_x, size.y), Color(accent.r, accent.g, accent.b, 0.18), 1.3)

	var scroll := fmod(t * 0.65, 1.0)
	for j in range(1, 10):
		var norm := (float(j) + scroll) / 10.0
		var y_pos := horizon_y + pow(norm, 2.1) * (size.y - horizon_y)
		if y_pos <= size.y:
			c.draw_line(Vector2(0, y_pos), Vector2(size.x, y_pos), Color(1.0, 0.1, 0.55, 0.12 + norm * 0.22), 1.4)

	# 5. Flussi Dati Digitali (Matrix / Netrunner Data Streams in alto)
	for k in range(14):
		var dx := fmod(float(k * 53 + 25), size.x)
		var speed_k := 70.0 + float(k % 5) * 28.0
		var dy := fmod(t * speed_k + float(k * 97), horizon_y - 40.0)
		c.draw_line(Vector2(dx, dy - 28.0), Vector2(dx, dy), Color(0.0, 0.95, 1.0, 0.22), 2.0)
		c.draw_circle(Vector2(dx, dy), 2.0, Color(0.7, 1.0, 1.0, 0.55))

	# 6. Scanlines CRT sottili + Cornice HUD Telemetry
	for sy in range(0, int(size.y), 6):
		c.draw_line(Vector2(0, sy), Vector2(size.x, sy), Color(0, 0, 0, 0.16), 1.0)

	# Brackets angolari HUD Cyberpunk
	var brk := Color(0.0, 0.95, 1.0, 0.55)
	c.draw_line(Vector2(6, 6), Vector2(42, 6), brk, 2.0)
	c.draw_line(Vector2(6, 6), Vector2(6, 42), brk, 2.0)
	c.draw_line(Vector2(size.x - 6, 6), Vector2(size.x - 42, 6), brk, 2.0)
	c.draw_line(Vector2(size.x - 6, 6), Vector2(size.x - 6, 42), brk, 2.0)
	c.draw_line(Vector2(6, size.y - 6), Vector2(42, size.y - 6), brk, 2.0)
	c.draw_line(Vector2(6, size.y - 6), Vector2(6, size.y - 42), brk, 2.0)
	c.draw_line(Vector2(size.x - 6, size.y - 6), Vector2(size.x - 42, size.y - 6), brk, 2.0)
	c.draw_line(Vector2(size.x - 6, size.y - 6), Vector2(size.x - 6, size.y - 42), brk, 2.0)

## Disegna i modelli 3D-shaded Cyberpunk per le carte equipaggiamento, gli slot attivi e i bauli dello Shop
static func draw_item_icon(c: CanvasItem, center: Vector2, item_id: String, slot_name: String, col: Color, icon_size: float = 74.0) -> void:
	var rad := icon_size * 0.46
	# Piedistallo esagonale olografico + bagliore rarità
	c.draw_circle(center, rad, Color(0.03, 0.05, 0.10, 0.85))
	c.draw_circle(center, rad * 0.78, Color(col.r, col.g, col.b, 0.22))
	c.draw_arc(center, rad, 0.0, TAU, 6, Color(col.r, col.g, col.b, 0.85), 2.2)
	c.draw_arc(center, rad * 0.82, 0.0, TAU, 24, Color(1.0, 1.0, 1.0, 0.18), 1.2)

	var tex := get_item_model_texture(item_id, slot_name)
	if tex:
		var rect := Rect2(center - Vector2(icon_size * 0.5, icon_size * 0.5), Vector2(icon_size, icon_size))
		c.draw_texture_rect(tex, rect, false)
	else:
		c.draw_circle(center, 12.0, col)
