class_name CyberTheme
extends RefCounted

# Palette Iconica Cyberpunk High-Contrast Moderna
const COL_BG_DEEP := Color(0.035, 0.055, 0.115, 1.0)
const COL_PANEL := Color(0.06, 0.095, 0.185, 0.96)
const COL_CYAN := Color(0.0, 0.92, 1.0, 1.0)
const COL_MAGENTA := Color(1.0, 0.16, 0.56, 1.0)
const COL_YELLOW := Color(1.0, 0.86, 0.12, 1.0)
const COL_GREEN := Color(0.12, 0.96, 0.58, 1.0)

# Palette Rarità Equipaggiamento — Universale e Inconfondibile
const COL_RARITY_COMMON := Color(0.74, 0.81, 0.90, 1.0)
const COL_RARITY_RARE := Color(0.18, 0.68, 1.0, 1.0)
const COL_RARITY_EPIC := Color(0.78, 0.28, 1.0, 1.0)
const COL_RARITY_LEGENDARY := Color(1.0, 0.80, 0.10, 1.0)

# Colore dedicato ESCLUSIVAMENTE allo stato "INDOSSATO / ATTIVO" (Verde Smeraldo)
const COL_EQUIPPED := Color(0.12, 0.96, 0.58, 1.0)

static var _tex_cache: Dictionary = {}

static func get_model_texture(res_path: String) -> Texture2D:
	if _tex_cache.has(res_path):
		return _tex_cache[res_path]
	if FileAccess.file_exists(res_path):
		var bytes := FileAccess.get_file_as_bytes(res_path)
		if not bytes.is_empty():
			var img := Image.new()
			if img.load_png_from_buffer(bytes) == OK and not img.is_empty():
				var tex := ImageTexture.create_from_image(img)
				tex.resource_name = res_path
				_tex_cache[res_path] = tex
				return tex
	var abs_path := ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(abs_path):
		var img2 := Image.load_from_file(abs_path)
		if img2 and not img2.is_empty():
			var tex2 := ImageTexture.create_from_image(img2)
			_tex_cache[res_path] = tex2
			return tex2
	if ResourceLoader.exists(res_path):
		var res_tex := load(res_path) as Texture2D
		if res_tex:
			_tex_cache[res_path] = res_tex
			return res_tex
	return null

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

## Restituisce l'icona UI 3D (core, coin, gem, gift, settings, pause, shield, merge, nav_shop, nav_equip, nav_play, nav_talents, nav_quests)
static func get_ui_icon(icon_name: String) -> Texture2D:
	return get_model_texture("res://assets/cyber_models/icon_" + icon_name + "_3d.png")

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

## Pannello 3D High-DPI Vetro Scuro + Titanio Smussato (256x256, 9-slice margin=36)
static func make_3d_panel_box(pad_h: int = 14, pad_v: int = 11, tint: Color = Color.WHITE) -> StyleBox:
	return _make_9slice_box("res://assets/cyber_models/ui_panel_cyber_3d.png", 36, pad_h, pad_h, pad_v, pad_v + 4, tint)

## Cornice Card 3D High-DPI specifica per ogni Rarità (Argento / Blu / Viola / Oro)
static func make_rarity_card_box(rarity_str: String, pad_h: int = 12, pad_v: int = 10) -> StyleBox:
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
	return _make_9slice_box("res://assets/cyber_models/" + file_name, 36, pad_h, pad_h, pad_v, pad_v + 4)

static func make_equipped_badge_box() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.36, 0.22, 0.98)
	sb.border_color = COL_EQUIPPED
	sb.border_width_left = 2
	sb.border_width_top = 1
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	return sb

static func make_rarity_pill_box(rarity_str: String) -> StyleBoxFlat:
	var rc := get_rarity_color(rarity_str)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(rc.r * 0.20, rc.g * 0.20, rc.b * 0.28, 0.96)
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

static func make_cyber_box(
	bg: Color = COL_PANEL,
	border: Color = COL_CYAN,
	_skew_x: float = 0.0,
	border_w: int = 2,
	left_accent_w: int = 3,
	glow_size: int = 6
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg.lightened(0.04)
	sb.skew = Vector2.ZERO
	sb.border_width_left = maxi(border_w, left_accent_w)
	sb.border_width_top = border_w
	sb.border_width_right = border_w
	sb.border_width_bottom = border_w + 3
	sb.border_color = border
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 9
	if glow_size > 0:
		sb.shadow_color = Color(0.0, 0.02, 0.07, 0.52)
		sb.shadow_size = maxi(4, glow_size)
		sb.shadow_offset = Vector2(0, 3)
	return sb

## Pulsante 3D High-DPI Tattile Moderno (320x128 4x-supersampled)
static func style_button(btn: Button, accent: Color = COL_CYAN, is_primary_yellow: bool = false) -> void:
	if not btn:
		return

	if not btn.has_theme_font_size_override("font_size"):
		btn.add_theme_font_size_override("font_size", 18)

	if btn.custom_minimum_size.y > 0 and btn.custom_minimum_size.y < 36:
		var mini_norm := make_cyber_box(Color(0.08, 0.14, 0.25, 0.96), accent, 0.0, 2, 2, 3)
		mini_norm.content_margin_top = 2
		mini_norm.content_margin_bottom = 3
		mini_norm.content_margin_left = 8
		mini_norm.content_margin_right = 8
		btn.add_theme_stylebox_override("normal", mini_norm)
		btn.add_theme_stylebox_override("hover", mini_norm)
		btn.add_theme_stylebox_override("pressed", mini_norm)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.96))
		btn.add_theme_constant_override("outline_size", 3)
		return

	var base_name := "ui_btn_cyan_3d"
	if is_primary_yellow:
		base_name = "ui_btn_gold_3d"
	elif accent.g > 0.80 and accent.r < 0.45:
		base_name = "ui_btn_green_3d"
	elif accent.r > 0.78 and accent.b > 0.30:
		base_name = "ui_btn_magenta_3d"

	var tex_norm := get_model_texture("res://assets/cyber_models/" + base_name + ".png")
	var tex_prs := get_model_texture("res://assets/cyber_models/" + base_name.replace("_3d", "_pressed_3d") + ".png")
	if not tex_prs:
		tex_prs = get_model_texture("res://assets/cyber_models/" + base_name + "_pressed.png")
	var tex_dis := get_model_texture("res://assets/cyber_models/ui_btn_disabled_3d.png")

	if tex_norm and tex_prs and tex_dis:
		var sb_n := StyleBoxTexture.new()
		sb_n.texture = tex_norm
		sb_n.texture_margin_left = 28; sb_n.texture_margin_right = 28
		sb_n.texture_margin_top = 24; sb_n.texture_margin_bottom = 28
		sb_n.content_margin_left = 10; sb_n.content_margin_right = 10
		sb_n.content_margin_top = 6; sb_n.content_margin_bottom = 9

		var sb_h := sb_n.duplicate() as StyleBoxTexture
		sb_h.modulate_color = Color(1.10, 1.10, 1.14, 1.0)

		var sb_p := StyleBoxTexture.new()
		sb_p.texture = tex_prs
		sb_p.texture_margin_left = 28; sb_p.texture_margin_right = 28
		sb_p.texture_margin_top = 26; sb_p.texture_margin_bottom = 22
		sb_p.content_margin_left = 10; sb_p.texture_margin_right = 10
		sb_p.content_margin_top = 8; sb_p.content_margin_bottom = 6

		var sb_d := StyleBoxTexture.new()
		sb_d.texture = tex_dis
		sb_d.texture_margin_left = 28; sb_d.texture_margin_right = 28
		sb_d.texture_margin_top = 25; sb_d.texture_margin_bottom = 25
		sb_d.content_margin_left = 10; sb_d.content_margin_right = 10
		sb_d.content_margin_top = 7; sb_d.content_margin_bottom = 7

		btn.add_theme_stylebox_override("normal", sb_n)
		btn.add_theme_stylebox_override("hover", sb_h)
		btn.add_theme_stylebox_override("pressed", sb_p)
		btn.add_theme_stylebox_override("disabled", sb_d)
	else:
		btn.add_theme_stylebox_override("normal", make_cyber_box(COL_YELLOW if is_primary_yellow else COL_PANEL, accent, 0.0, 2, 4, 8))

	if is_primary_yellow:
		btn.add_theme_color_override("font_color", Color(1.0, 0.99, 0.92, 1.0))
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.92, 0.60, 1.0))
		btn.add_theme_color_override("font_disabled_color", Color(0.58, 0.62, 0.70, 0.80))
		btn.add_theme_color_override("font_outline_color", Color(0.10, 0.05, 0.01, 0.98))
		btn.add_theme_constant_override("outline_size", 4)
	else:
		btn.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0, 1.0))
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", accent.lightened(0.45))
		btn.add_theme_color_override("font_disabled_color", Color(0.55, 0.60, 0.68, 0.80))
		btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.09, 0.98))
		btn.add_theme_constant_override("outline_size", 4)

static func style_label(lbl: Label, col: Color = Color.WHITE, outline_size: int = 4) -> void:
	if not lbl: return
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.96))
	lbl.add_theme_constant_override("outline_size", outline_size)
	if not lbl.has_theme_font_size_override("font_size"):
		lbl.add_theme_font_size_override("font_size", 18)

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
		l.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.95))
		if not l.has_theme_constant_override("outline_size"):
			l.add_theme_constant_override("outline_size", 4)
		if not l.has_theme_font_size_override("font_size"):
			l.add_theme_font_size_override("font_size", 18)

	for child in root.get_children():
		apply_recursive_cyber_style(child)

static func attach_cyber_bloom(parent: Node, in_game: bool = false) -> void:
	if not parent: return
	if parent.get_node_or_null("CyberWorldEnv") != null: return

	var we := WorldEnvironment.new()
	we.name = "CyberWorldEnv"
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	if in_game:
		env.glow_intensity = 0.28
		env.glow_strength = 0.78
		env.glow_bloom = 0.0
		env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
		env.glow_hdr_threshold = 1.15
	else:
		env.glow_intensity = 0.45
		env.glow_strength = 0.85
		env.glow_bloom = 0.06
		env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
		env.glow_hdr_threshold = 0.95
	we.environment = env
	parent.add_child(we)

static func draw_cyberpunk_backdrop(c: CanvasItem, size: Vector2, t: float, accent: Color = COL_CYAN) -> void:
	var horizon_y := size.y * 0.55
	c.draw_polygon(
		PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, horizon_y), Vector2(0, horizon_y)]),
		PackedColorArray([
			Color(0.025, 0.04, 0.10, 1.0),
			Color(0.035, 0.05, 0.13, 1.0),
			Color(0.08, 0.12, 0.25, 1.0),
			Color(0.07, 0.10, 0.22, 1.0)
		])
	)
	for b_i in range(3):
		var bx := size.x * (0.20 + float(b_i) * 0.30) + sin(t * 0.4 + float(b_i)) * 28.0
		c.draw_colored_polygon(PackedVector2Array([
			Vector2(bx - 35, 0), Vector2(bx + 35, 0),
			Vector2(bx + 120, horizon_y), Vector2(bx - 120, horizon_y)
		]), Color(accent.r, accent.g, accent.b, 0.04))

	var sun_center := Vector2(size.x * 0.5, horizon_y - 54.0)
	c.draw_circle(sun_center, 114.0, Color(accent.r, accent.g, accent.b, 0.11))
	c.draw_circle(sun_center, 82.0, Color(1.0, 0.18, 0.58, 0.14))
	c.draw_arc(sun_center, 92.0, PI, TAU, 42, Color(accent.r, accent.g, accent.b, 0.50), 2.5)

	var bld_widths := [68.0, 86.0, 58.0, 96.0, 72.0, 92.0, 62.0, 82.0, 76.0, 68.0]
	var bld_heights := [200.0, 285.0, 170.0, 320.0, 230.0, 300.0, 190.0, 270.0, 225.0, 195.0]
	var cur_x := -8.0
	for i in range(bld_widths.size()):
		var bw: float = bld_widths[i]
		var bh: float = bld_heights[i]
		var by: float = horizon_y - bh
		c.draw_colored_polygon(PackedVector2Array([
			Vector2(cur_x + bw, by), Vector2(cur_x + bw + 12, by + 10),
			Vector2(cur_x + bw + 12, horizon_y), Vector2(cur_x + bw, horizon_y)
		]), Color(0.025, 0.04, 0.09, 0.96))
		var b_rect := Rect2(Vector2(cur_x, by), Vector2(bw, bh))
		c.draw_rect(b_rect, Color(0.05, 0.08, 0.15, 0.96), true)
		var edge_col := accent if (i % 2 == 0) else COL_MAGENTA
		c.draw_line(Vector2(cur_x, by), Vector2(cur_x + bw, by), Color(edge_col.r, edge_col.g, edge_col.b, 0.65), 2.0)
		for wy in range(int(by + 16), int(horizon_y - 16), 24):
			if ((wy + i * 7) % 3) != 0:
				var win_col := Color(edge_col.r, edge_col.g, edge_col.b, 0.22 + sin(t * 2.0 + float(i + wy)) * 0.07)
				c.draw_rect(Rect2(Vector2(cur_x + 10, wy), Vector2(bw - 20, 4)), win_col, true)
		cur_x += bw + 2.0

	c.draw_polygon(
		PackedVector2Array([Vector2(0, horizon_y), Vector2(size.x, horizon_y), Vector2(size.x, size.y), Vector2(0, size.y)]),
		PackedColorArray([
			Color(0.06, 0.09, 0.18, 0.98),
			Color(0.06, 0.09, 0.18, 0.98),
			Color(0.025, 0.04, 0.09, 1.0),
			Color(0.025, 0.04, 0.09, 1.0)
		])
	)
	c.draw_line(Vector2(0, horizon_y), Vector2(size.x, horizon_y), Color(accent.r, accent.g, accent.b, 0.75), 2.4)

	var vanish := Vector2(size.x * 0.5, horizon_y)
	for i in range(-8, 9):
		var bottom_x := size.x * 0.5 + float(i) * 95.0
		c.draw_line(vanish, Vector2(bottom_x, size.y), Color(accent.r, accent.g, accent.b, 0.18), 1.3)

	var scroll := fmod(t * 0.55, 1.0)
	for j in range(1, 10):
		var norm := (float(j) + scroll) / 10.0
		var y_pos := horizon_y + pow(norm, 2.1) * (size.y - horizon_y)
		if y_pos <= size.y:
			c.draw_line(Vector2(0, y_pos), Vector2(size.x, y_pos), Color(accent.r, accent.g, accent.b, 0.12 + norm * 0.20), 1.4)

## Disegna il modello 3D su Piedistallo Olografico ad Alto Contrasto (anche per armi lunghe/sottili!)
static func draw_item_icon(c: CanvasItem, center: Vector2, item_id: String, slot_name: String, col: Color, icon_size: float = 74.0, is_equipped: bool = false) -> void:
	var ped_y := center.y + icon_size * 0.34
	var ped_rx := icon_size * 0.42

	# 1. Base cilindrica 3D del proiettore
	c.draw_set_transform(Vector2(center.x, ped_y + 4.0), 0.0, Vector2(1.0, 0.36))
	c.draw_circle(Vector2.ZERO, ped_rx * 1.04, Color(0.02, 0.03, 0.07, 0.92))
	c.draw_arc(Vector2.ZERO, ped_rx * 1.02, 0.0, PI, 20, Color(col.r * 0.55, col.g * 0.55, col.b * 0.65, 0.90), 3.6)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 2. Piatto luminoso della Rarità
	c.draw_set_transform(Vector2(center.x, ped_y), 0.0, Vector2(1.0, 0.36))
	c.draw_circle(Vector2.ZERO, ped_rx, Color(0.07, 0.11, 0.22, 0.96))
	c.draw_circle(Vector2.ZERO, ped_rx * 0.74, Color(col.r, col.g, col.b, 0.34))
	c.draw_arc(Vector2.ZERO, ped_rx, 0.0, TAU, 28, Color(col.r, col.g, col.b, 0.96), 2.6)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 3. Cono olografico + Alone posteriore ad alto contrasto (fa risaltare anche armi scure/sottili!)
	var beam_pts := PackedVector2Array([
		Vector2(center.x - ped_rx * 0.76, ped_y),
		Vector2(center.x + ped_rx * 0.76, ped_y),
		Vector2(center.x + ped_rx * 0.98, center.y - icon_size * 0.38),
		Vector2(center.x - ped_rx * 0.98, center.y - icon_size * 0.38)
	])
	c.draw_polygon(beam_pts, PackedColorArray([
		Color(col.r, col.g, col.b, 0.28),
		Color(col.r, col.g, col.b, 0.28),
		Color(col.r, col.g, col.b, 0.0),
		Color(col.r, col.g, col.b, 0.0)
	]))
	c.draw_circle(center + Vector2(0, -4.0), icon_size * 0.36, Color(col.r, col.g, col.b, 0.26))
	c.draw_circle(center + Vector2(0, -4.0), icon_size * 0.22, Color(1.0, 1.0, 1.0, 0.14))

	# 4. Modello 3D dell'oggetto (armi lunghe scalate di 1.32x sulla diagonale così sono grandi e nitide!)
	var tex := get_item_model_texture(item_id, slot_name)
	if tex:
		var id_low := item_id.to_lower()
		var is_wep: bool = ("ARMA" in slot_name.to_upper() or "WEAPON" in slot_name.to_upper() or "pistol" in id_low or "smg" in id_low or "shotgun" in id_low or "rifle" in id_low or "plasma" in id_low or "katana" in id_low or "wand" in id_low or "scythe" in id_low)
		if is_wep:
			var is_long: bool = ("wand" in id_low or "rifle" in id_low or "katana" in id_low or "shotgun" in id_low or "scythe" in id_low or "plasma" in id_low)
			var w_size: float = icon_size * (1.34 if is_long else 1.12)
			c.draw_set_transform(center + Vector2(0.0, -icon_size * 0.06), -0.40, Vector2.ONE)
			c.draw_texture_rect(tex, Rect2(Vector2(-w_size * 0.5, -w_size * 0.5), Vector2(w_size, w_size)), false, Color(1.12, 1.12, 1.15, 1.0))
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			var rect := Rect2(center - Vector2(icon_size * 0.48, icon_size * 0.52), Vector2(icon_size * 0.96, icon_size * 0.96))
			c.draw_texture_rect(tex, rect, false)
	else:
		c.draw_circle(center, 14.0, col)

	if is_equipped:
		var badge_pos := center + Vector2(icon_size * 0.36, -icon_size * 0.34)
		c.draw_circle(badge_pos, 9.0, Color(0.04, 0.30, 0.18, 0.98))
		c.draw_arc(badge_pos, 9.0, 0.0, TAU, 20, COL_EQUIPPED, 2.0)
		c.draw_polyline(PackedVector2Array([
			badge_pos + Vector2(-4.0, 0.2),
			badge_pos + Vector2(-1.0, 3.4),
			badge_pos + Vector2(4.4, -3.2)
		]), Color.WHITE, 2.2)
