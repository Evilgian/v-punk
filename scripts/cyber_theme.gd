class_name CyberTheme
extends RefCounted

# Palette Iconica Cyberpunk Moderna
const COL_BG_DEEP := Color(0.04, 0.06, 0.12, 1.0)
const COL_PANEL := Color(0.07, 0.10, 0.19, 0.96)
const COL_CYAN := Color(0.0, 0.92, 1.0, 1.0)
const COL_MAGENTA := Color(1.0, 0.14, 0.54, 1.0)
const COL_YELLOW := Color(1.0, 0.86, 0.10, 1.0)
const COL_GREEN := Color(0.10, 0.96, 0.58, 1.0)

# Palette Rarità Equipaggiamento — Chiara, Universale e Inconfondibile:
# Grigio-Argento (Comune) | Blu Zaffiro (Raro) | Viola Ametista (Epico) | Oro Solare (Leggendario)
const COL_RARITY_COMMON := Color(0.72, 0.79, 0.88, 1.0)
const COL_RARITY_RARE := Color(0.14, 0.64, 1.0, 1.0)
const COL_RARITY_EPIC := Color(0.76, 0.24, 1.0, 1.0)
const COL_RARITY_LEGENDARY := Color(1.0, 0.78, 0.08, 1.0)

# Colore dedicato ESCLUSIVAMENTE al badge "INDOSSATO / ATTIVO" (Verde Smeraldo Cyber, mai Oro!)
const COL_EQUIPPED := Color(0.10, 0.96, 0.58, 1.0)

static var _tex_cache: Dictionary = {}

## Carica in modo istantaneo (e mette in cache) i modelli e le texture UI 3D sia su PC sia dentro l'APK Android
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
				tex.resource_name = res_path
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

## Restituisce il colore ufficiale della rarità (senza mai mescolarlo allo stato Equipaggiato)
static func get_rarity_color(rarity_str: String) -> Color:
	match rarity_str.to_upper():
		"COMMON", "0", "COMUNE":
			return COL_RARITY_COMMON
		"RARE", "1", "BLUE", "GREEN", "RARO":
			return COL_RARITY_RARE
		"EPIC", "2", "PURPLE", "EPICO":
			return COL_RARITY_EPIC
		"LEGENDARY", "3", "GOLD", "LEGGENDARIO":
			return COL_RARITY_LEGENDARY
		_:
			return COL_RARITY_COMMON

## Nome italiano leggibile della rarità
static func get_rarity_label_it(rarity_str: String) -> String:
	match rarity_str.to_upper():
		"COMMON", "0", "COMUNE":
			return "COMUNE"
		"RARE", "1", "BLUE", "GREEN", "RARO":
			return "RARO"
		"EPIC", "2", "PURPLE", "EPICO":
			return "EPICO"
		"LEGENDARY", "3", "GOLD", "LEGGENDARIO":
			return "LEGGENDARIO"
		_:
			return "COMUNE"

## Etichetta con stelle + nome rarità
static func get_rarity_badge_text(rarity_str: String) -> String:
	match rarity_str.to_upper():
		"COMMON", "0", "COMUNE":
			return "★ COMUNE"
		"RARE", "1", "BLUE", "GREEN", "RARO":
			return "★★ RARO"
		"EPIC", "2", "PURPLE", "EPICO":
			return "★★★ EPICO"
		"LEGENDARY", "3", "GOLD", "LEGGENDARIO":
			return "★★★★ LEGGENDARIO"
		_:
			return "★ COMUNE"

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

## Helper interno per costruire uno StyleBoxTexture 9-slice 3D scolpito
static func _make_9slice_box(tex_path: String, margin_xy: int, pad_l: int, pad_r: int, pad_t: int, pad_b: int, tint: Color = Color.WHITE) -> StyleBox:
	var tex := get_model_texture(tex_path)
	if tex:
		var sbt := StyleBoxTexture.new()
		sbt.texture = tex
		sbt.texture_margin_left = margin_xy
		sbt.texture_margin_right = margin_xy
		sbt.texture_margin_top = margin_xy
		sbt.texture_margin_bottom = margin_xy
		sbt.content_margin_left = pad_l
		sbt.content_margin_right = pad_r
		sbt.content_margin_top = pad_t
		sbt.content_margin_bottom = pad_b
		sbt.modulate_color = tint
		return sbt
	return make_cyber_box(COL_PANEL, COL_CYAN, 0.0, 2, 4, 8)

## Pannello 3D Vetro + Titanio smussato per contenitori, barre, popup e sezioni principali
static func make_3d_panel_box(pad_h: int = 14, pad_v: int = 10, tint: Color = Color.WHITE) -> StyleBox:
	return _make_9slice_box("res://assets/cyber_models/ui_panel_cyber_3d.png", 24, pad_h, pad_h, pad_v, pad_v + 3, tint)

## Cornice Card 3D Scolpita specifica per ogni Rarità (Argento / Blu / Viola / Oro)
static func make_rarity_card_box(rarity_str: String, pad_h: int = 10, pad_v: int = 8) -> StyleBox:
	var file_name := "ui_card_common_3d.png"
	match rarity_str.to_upper():
		"RARE", "1", "BLUE", "GREEN", "RARO":
			file_name = "ui_card_rare_3d.png"
		"EPIC", "2", "PURPLE", "EPICO":
			file_name = "ui_card_epic_3d.png"
		"LEGENDARY", "3", "GOLD", "LEGGENDARIO":
			file_name = "ui_card_legendary_3d.png"
		_:
			file_name = "ui_card_common_3d.png"
	return _make_9slice_box("res://assets/cyber_models/" + file_name, 24, pad_h, pad_h, pad_v, pad_v + 4)

## Pillola 3D Smeraldo per indicare chiaramente che un oggetto è INDOSSATO senza alterare la rarità!
static func make_equipped_badge_box() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.34, 0.22, 0.98)
	sb.border_color = COL_EQUIPPED
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 4
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 2
	sb.content_margin_bottom = 3
	sb.shadow_color = Color(0.08, 0.95, 0.55, 0.32)
	sb.shadow_size = 5
	sb.shadow_offset = Vector2(0, 2)
	return sb

## Pillola compatta colorata in base alla Rarità dell'oggetto
static func make_rarity_pill_box(rarity_str: String) -> StyleBoxFlat:
	var rc := get_rarity_color(rarity_str)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(rc.r * 0.20, rc.g * 0.20, rc.b * 0.26, 0.96)
	sb.border_color = rc
	sb.border_width_left = 2
	sb.border_width_top = 1
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.corner_radius_top_left = 7
	sb.corner_radius_top_right = 7
	sb.corner_radius_bottom_left = 7
	sb.corner_radius_bottom_right = 7
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	return sb

## Crea uno StyleBoxFlat 3D smussato (usato per ProgressBar, badge compatti e fallback)
static func make_cyber_box(
	bg: Color = COL_PANEL,
	border: Color = COL_CYAN,
	skew_x: float = 0.04,
	border_w: int = 2,
	left_accent_w: int = 4,
	glow_size: int = 6
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg.lightened(0.05)
	sb.skew = Vector2(skew_x * 0.5, 0.0)
	sb.border_width_left = max(border_w, left_accent_w)
	sb.border_width_top = border_w
	sb.border_width_right = border_w
	sb.border_width_bottom = border_w + 3
	sb.border_color = border
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 9
	if glow_size > 0:
		sb.shadow_color = Color(0.0, 0.02, 0.06, 0.48)
		sb.shadow_size = glow_size
		sb.shadow_offset = Vector2(0, 3)
	return sb

## Applica un vero pulsante 3D fisico tattile (con spessore inferiore 3D ed effetto pressione reale!)
static func style_button(btn: Button, accent: Color = COL_CYAN, is_primary_yellow: bool = false) -> void:
	if not btn:
		return

	# Per micro-pulsanti molto bassi (< 34px, es. RIDUCI nel tutorial) usa stile compatto 3D
	if btn.custom_minimum_size.y > 0 and btn.custom_minimum_size.y < 34:
		var mini_norm := make_cyber_box(Color(0.08, 0.14, 0.25, 0.96), accent, 0.0, 1, 3, 3)
		mini_norm.content_margin_top = 2
		mini_norm.content_margin_bottom = 3
		mini_norm.content_margin_left = 6
		mini_norm.content_margin_right = 6
		btn.add_theme_stylebox_override("normal", mini_norm)
		btn.add_theme_stylebox_override("hover", mini_norm)
		btn.add_theme_stylebox_override("pressed", mini_norm)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.95))
		btn.add_theme_constant_override("outline_size", 2)
		return

	var base_name := "ui_btn_cyan_3d"
	if is_primary_yellow:
		base_name = "ui_btn_gold_3d"
	elif accent.g > 0.80 and accent.r < 0.45:
		base_name = "ui_btn_green_3d"
	elif accent.r > 0.78 and accent.b > 0.30:
		base_name = "ui_btn_magenta_3d"

	var tex_norm := get_model_texture("res://assets/cyber_models/" + base_name + ".png")
	var tex_prs := get_model_texture("res://assets/cyber_models/" + base_name + "_pressed.png")
	var tex_dis := get_model_texture("res://assets/cyber_models/ui_btn_disabled_3d.png")

	if tex_norm and tex_prs and tex_dis:
		var sb_n := StyleBoxTexture.new()
		sb_n.texture = tex_norm
		sb_n.texture_margin_left = 20; sb_n.texture_margin_right = 20
		sb_n.texture_margin_top = 15; sb_n.texture_margin_bottom = 19
		sb_n.content_margin_left = 12; sb_n.content_margin_right = 12
		sb_n.content_margin_top = 6; sb_n.content_margin_bottom = 10

		var sb_h := sb_n.duplicate() as StyleBoxTexture
		sb_h.modulate_color = Color(1.10, 1.10, 1.12, 1.0)

		var sb_p := StyleBoxTexture.new()
		sb_p.texture = tex_prs
		sb_p.texture_margin_left = 20; sb_p.texture_margin_right = 20
		sb_p.texture_margin_top = 17; sb_p.texture_margin_bottom = 15
		sb_p.content_margin_left = 12; sb_p.content_margin_right = 12
		sb_p.content_margin_top = 9; sb_p.content_margin_bottom = 7

		var sb_d := StyleBoxTexture.new()
		sb_d.texture = tex_dis
		sb_d.texture_margin_left = 20; sb_d.texture_margin_right = 20
		sb_d.texture_margin_top = 16; sb_d.texture_margin_bottom = 16
		sb_d.content_margin_left = 12; sb_d.content_margin_right = 12
		sb_d.content_margin_top = 7; sb_d.content_margin_bottom = 8

		btn.add_theme_stylebox_override("normal", sb_n)
		btn.add_theme_stylebox_override("hover", sb_h)
		btn.add_theme_stylebox_override("pressed", sb_p)
		btn.add_theme_stylebox_override("disabled", sb_d)
	else:
		btn.add_theme_stylebox_override("normal", make_cyber_box(COL_YELLOW if is_primary_yellow else COL_PANEL, accent, 0.04, 2, 5, 8))

	if is_primary_yellow:
		btn.add_theme_color_override("font_color", Color(0.05, 0.04, 0.02, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(0.02, 0.02, 0.02, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(0.05, 0.04, 0.02, 1.0))
		btn.add_theme_color_override("font_disabled_color", Color(0.55, 0.58, 0.65, 0.78))
		btn.add_theme_color_override("font_outline_color", Color(1.0, 0.96, 0.72, 0.55))
		btn.add_theme_constant_override("outline_size", 2)
	else:
		btn.add_theme_color_override("font_color", Color(0.97, 0.99, 1.0, 1.0))
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", accent.lightened(0.45))
		btn.add_theme_color_override("font_disabled_color", Color(0.52, 0.57, 0.66, 0.78))
		btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.96))
		btn.add_theme_constant_override("outline_size", 3)

## Stilizza un Label con outline profondo e leggibilità moderna
static func style_label(lbl: Label, col: Color = Color.WHITE, outline_size: int = 3) -> void:
	if not lbl: return
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.95))
	lbl.add_theme_constant_override("outline_size", outline_size)

## Percorre ricorsivamente un albero UI per applicare il look 3D Cyberpunk a Button, PanelContainer e Label
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
	env.glow_intensity = 0.62
	env.glow_strength = 0.92
	env.glow_bloom = 0.14
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	env.glow_hdr_threshold = 0.86
	we.environment = env
	parent.add_child(we)

## Sfondo 3D Moderno Sci-Fi per il Menu Principale (Skyline luminosa, Fasci Volumetrici e Ponte Olografico 3D)
static func draw_cyberpunk_backdrop(c: CanvasItem, size: Vector2, t: float, accent: Color = COL_CYAN) -> void:
	var horizon_y := size.y * 0.56
	# 1. Cielo profondo sfumato con aurora volumetrica luminosa
	c.draw_polygon(
		PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, horizon_y), Vector2(0, horizon_y)]),
		PackedColorArray([
			Color(0.03, 0.05, 0.12, 1.0),
			Color(0.04, 0.06, 0.15, 1.0),
			Color(0.10, 0.14, 0.28, 1.0),
			Color(0.08, 0.12, 0.25, 1.0)
		])
	)
	# Fasci di luce volumetrica diagonali dall'alto
	for b_i in range(3):
		var bx := size.x * (0.20 + float(b_i) * 0.30) + sin(t * 0.4 + float(b_i)) * 28.0
		c.draw_colored_polygon(PackedVector2Array([
			Vector2(bx - 35, 0), Vector2(bx + 35, 0),
			Vector2(bx + 120, horizon_y), Vector2(bx - 120, horizon_y)
		]), Color(accent.r, accent.g, accent.b, 0.045))

	# 2. Reattore Solare Olografico 3D sull'orizzonte
	var sun_center := Vector2(size.x * 0.5, horizon_y - 54.0)
	c.draw_circle(sun_center, 118.0, Color(accent.r, accent.g, accent.b, 0.12))
	c.draw_circle(sun_center, 86.0, Color(1.0, 0.18, 0.58, 0.16))
	c.draw_arc(sun_center, 96.0, PI, TAU, 42, Color(accent.r, accent.g, accent.b, 0.55), 2.8)
	c.draw_arc(sun_center, 74.0, PI + 0.2, TAU - 0.2, 36, Color(1.0, 0.85, 0.25, 0.42), 2.0)

	# 3. Grattacieli 3D a Doppio Livello di Parallasse (con spessore laterale 3D illuminato!)
	var bld_widths := [68.0, 86.0, 58.0, 96.0, 72.0, 92.0, 62.0, 82.0, 76.0, 68.0]
	var bld_heights := [210.0, 295.0, 175.0, 335.0, 240.0, 315.0, 195.0, 280.0, 235.0, 205.0]
	var cur_x := -8.0
	for i in range(bld_widths.size()):
		var bw: float = bld_widths[i]
		var bh: float = bld_heights[i]
		var by: float = horizon_y - bh
		# Faccia laterale 3D estrusa
		c.draw_colored_polygon(PackedVector2Array([
			Vector2(cur_x + bw, by), Vector2(cur_x + bw + 12, by + 10),
			Vector2(cur_x + bw + 12, horizon_y), Vector2(cur_x + bw, horizon_y)
		]), Color(0.03, 0.05, 0.10, 0.96))
		# Faccia frontale 3D sfumata
		var b_rect := Rect2(Vector2(cur_x, by), Vector2(bw, bh))
		c.draw_rect(b_rect, Color(0.06, 0.09, 0.17, 0.96), true)
		var edge_col := accent if (i % 2 == 0) else COL_MAGENTA
		c.draw_line(Vector2(cur_x, by), Vector2(cur_x + bw, by), Color(edge_col.r, edge_col.g, edge_col.b, 0.72), 2.2)
		c.draw_line(Vector2(cur_x, by), Vector2(cur_x, horizon_y), Color(1.0, 1.0, 1.0, 0.10), 1.5)
		for wy in range(int(by + 16), int(horizon_y - 16), 22):
			if ((wy + i * 7) % 3) != 0:
				var win_col := Color(edge_col.r, edge_col.g, edge_col.b, 0.26 + sin(t * 2.0 + float(i + wy)) * 0.08)
				c.draw_rect(Rect2(Vector2(cur_x + 10, wy), Vector2(bw - 20, 5)), win_col, true)
		cur_x += bw + 2.0

	# 4. Ponte Olografico 3D in Prospettiva sotto l'orizzonte
	c.draw_polygon(
		PackedVector2Array([Vector2(0, horizon_y), Vector2(size.x, horizon_y), Vector2(size.x, size.y), Vector2(0, size.y)]),
		PackedColorArray([
			Color(0.07, 0.10, 0.20, 0.98),
			Color(0.07, 0.10, 0.20, 0.98),
			Color(0.03, 0.05, 0.11, 1.0),
			Color(0.03, 0.05, 0.11, 1.0)
		])
	)
	c.draw_line(Vector2(0, horizon_y), Vector2(size.x, horizon_y), Color(accent.r, accent.g, accent.b, 0.82), 2.8)

	var vanish := Vector2(size.x * 0.5, horizon_y)
	for i in range(-8, 9):
		var bottom_x := size.x * 0.5 + float(i) * 95.0
		c.draw_line(vanish, Vector2(bottom_x, size.y), Color(accent.r, accent.g, accent.b, 0.22), 1.4)

	var scroll := fmod(t * 0.60, 1.0)
	for j in range(1, 10):
		var norm := (float(j) + scroll) / 10.0
		var y_pos := horizon_y + pow(norm, 2.1) * (size.y - horizon_y)
		if y_pos <= size.y:
			c.draw_line(Vector2(0, y_pos), Vector2(size.x, y_pos), Color(accent.r, accent.g, accent.b, 0.14 + norm * 0.24), 1.5)

	# 5. Particelle Olografiche Ascendenti
	for k in range(14):
		var dx := fmod(float(k * 53 + 25), size.x)
		var speed_k := 55.0 + float(k % 5) * 22.0
		var dy := horizon_y - fmod(t * speed_k + float(k * 97), horizon_y - 30.0)
		c.draw_circle(Vector2(dx, dy), 2.4, Color(accent.r, accent.g, accent.b, 0.45))
		c.draw_circle(Vector2(dx, dy), 1.2, Color(1.0, 1.0, 1.0, 0.75))

## Disegna l'oggetto 3D sopra un vero Piedistallo Proiettore Olografico 3D Isometrico colorato per Rarità!
## NOTA: `col` è SEMPRE il colore della Rarità (mai alterato in giallo se indossato!).
static func draw_item_icon(c: CanvasItem, center: Vector2, item_id: String, slot_name: String, col: Color, icon_size: float = 74.0, is_equipped: bool = false) -> void:
	var ped_y := center.y + icon_size * 0.34
	var ped_rx := icon_size * 0.44

	# 1. Spessore cilindrico 3D della base metallica del proiettore
	c.draw_set_transform(Vector2(center.x, ped_y + 5.0), 0.0, Vector2(1.0, 0.38))
	c.draw_circle(Vector2.ZERO, ped_rx * 1.04, Color(0.02, 0.03, 0.07, 0.92))
	c.draw_arc(Vector2.ZERO, ped_rx * 1.02, 0.0, PI, 20, Color(col.r * 0.55, col.g * 0.55, col.b * 0.65, 0.90), 4.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 2. Piatto superiore 3D del piedistallo + anello luminoso della Rarità
	c.draw_set_transform(Vector2(center.x, ped_y), 0.0, Vector2(1.0, 0.38))
	c.draw_circle(Vector2.ZERO, ped_rx, Color(0.08, 0.12, 0.22, 0.96))
	c.draw_circle(Vector2.ZERO, ped_rx * 0.76, Color(col.r, col.g, col.b, 0.30))
	c.draw_arc(Vector2.ZERO, ped_rx, 0.0, TAU, 28, Color(col.r, col.g, col.b, 0.96), 2.8)
	c.draw_arc(Vector2.ZERO, ped_rx * 0.70, 0.0, TAU, 24, Color(1.0, 1.0, 1.0, 0.42), 1.4)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 3. Cono di luce olografica 3D che sale dal piedistallo (sempre del colore della Rarità!)
	var beam_pts := PackedVector2Array([
		Vector2(center.x - ped_rx * 0.78, ped_y),
		Vector2(center.x + ped_rx * 0.78, ped_y),
		Vector2(center.x + ped_rx * 1.02, center.y - icon_size * 0.38),
		Vector2(center.x - ped_rx * 1.02, center.y - icon_size * 0.38)
	])
	var beam_cols := PackedColorArray([
		Color(col.r, col.g, col.b, 0.26),
		Color(col.r, col.g, col.b, 0.26),
		Color(col.r, col.g, col.b, 0.0),
		Color(col.r, col.g, col.b, 0.0)
	])
	c.draw_polygon(beam_pts, beam_cols)

	# 4. Alone speculare dietro al modello 3D per staccarlo con profondità
	c.draw_circle(center + Vector2(0, -3.0), icon_size * 0.34, Color(col.r, col.g, col.b, 0.20))

	# 5. Modello 3D dell'oggetto sospeso sopra il piedistallo
	var tex := get_item_model_texture(item_id, slot_name)
	if tex:
		var rect := Rect2(center - Vector2(icon_size * 0.5, icon_size * 0.54), Vector2(icon_size, icon_size))
		c.draw_texture_rect(tex, rect, false)
	else:
		c.draw_circle(center, 14.0, col)

	# 6. Se equipaggiato, piccolo indicatore olografico verde smeraldo (distinto dall'Oro Leggendario!)
	if is_equipped:
		var badge_pos := center + Vector2(icon_size * 0.36, -icon_size * 0.34)
		c.draw_circle(badge_pos, 9.0, Color(0.04, 0.28, 0.18, 0.96))
		c.draw_arc(badge_pos, 9.0, 0.0, TAU, 20, COL_EQUIPPED, 2.0)
		c.draw_polyline(PackedVector2Array([
			badge_pos + Vector2(-4.0, 0.2),
			badge_pos + Vector2(-1.0, 3.4),
			badge_pos + Vector2(4.4, -3.2)
		]), Color.WHITE, 2.2)
