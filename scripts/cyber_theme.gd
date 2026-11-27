class_name CyberTheme
extends RefCounted

# Palette Autentica Cyberpunk 2077 / Ghostrunner (Ossidiana, Giallo Acido #FCEE0A, Cremisi #FF003C, Ciano Ghiaccio #00F0FF)
const COL_BG_DEEP := Color(0.035, 0.045, 0.075, 1.0)
const COL_PANEL := Color(0.055, 0.075, 0.125, 0.96)
const COL_CYAN := Color(0.0, 0.941, 1.0, 1.0)
const COL_MAGENTA := Color(1.0, 0.0, 0.235, 1.0)
const COL_YELLOW := Color(0.988, 0.933, 0.039, 1.0)
const COL_GREEN := Color(0.0, 0.96, 0.55, 1.0)

# Palette Rarità Equipaggiamento — Tecnica e Coerente
const COL_RARITY_COMMON := Color(0.68, 0.75, 0.85, 1.0)
const COL_RARITY_RARE := Color(0.0, 0.74, 1.0, 1.0)
const COL_RARITY_EPIC := Color(0.76, 0.22, 1.0, 1.0)
const COL_RARITY_LEGENDARY := Color(0.988, 0.933, 0.039, 1.0)

# Colore dedicato ESCLUSIVAMENTE allo stato "ATTIVO / INNESTATO" (Verde Bio-Smeraldo)
const COL_EQUIPPED := Color(0.0, 0.96, 0.55, 1.0)

static var _tex_cache: Dictionary = {}
static var _font_bold: Font = null
static var _font_semi: Font = null

static func get_cyber_font(bold: bool = true) -> Font:
	if bold and _font_bold != null:
		return _font_bold
	if not bold and _font_semi != null:
		return _font_semi
	var path := "res://assets/fonts/ChakraPetch-Bold.ttf" if bold else "res://assets/fonts/ChakraPetch-SemiBold.ttf"
	var ff: FontFile = null
	if ResourceLoader.exists(path):
		ff = load(path) as FontFile
	if ff == null and FileAccess.file_exists(path):
		var f2 := FontFile.new()
		var bytes := FileAccess.get_file_as_bytes(path)
		if not bytes.is_empty():
			f2.data = bytes
			ff = f2
	if ff != null:
		var fb := ThemeDB.fallback_font
		if fb != null and not ff.fallbacks.has(fb):
			ff.fallbacks = [fb]
		if bold:
			_font_bold = ff
		else:
			_font_semi = ff
		return ff
	return ThemeDB.fallback_font

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
	return get_rarity_label_it(rarity_str)

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

## Pannello Cyberpunk 2077 Ossidiana Opaca + Taglio Chirurgico 45° (256x256, 9-slice margin=26)
static func make_3d_panel_box(pad_h: int = 16, pad_v: int = 14, tint: Color = Color.WHITE) -> StyleBox:
	return _make_9slice_box("res://assets/cyber_models/ui_panel_cyber_3d.png", 26, pad_h, pad_h, pad_v, pad_v + 2, tint)

## Cornice Card Asimmetrica Cyberpunk 2077 per ogni Rarità (MK.I..MK.IV)
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
	return _make_9slice_box("res://assets/cyber_models/" + file_name, 22, pad_h, pad_h, pad_v, pad_v + 2)

## Contatore Telemetrico HUD Ossidiana + Barra Laterale Neon
static func make_glass_counter_box(accent: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.035, 0.045, 0.075, 0.95)
	sb.border_color = Color(accent.r, accent.g, accent.b, 0.82)
	sb.border_width_left = 4
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb

## Stile Pulsanti Sub-Tab Alta Visibilità (SKIN | DOTAZIONE | CALIBRA | SINTESI, Filtri, ecc.)
static func style_segmented_tab(btn: Button, is_active: bool, accent: Color = COL_CYAN) -> void:
	if not btn:
		return
	var f_bold := get_cyber_font(true)
	if f_bold:
		btn.add_theme_font_override("font", f_bold)
	var sb := StyleBoxFlat.new()
	var sb_h := StyleBoxFlat.new()
	if is_active:
		# Placca attiva Giallo Cyberpunk / Accento Pieno ad altissimo contrasto!
		sb.bg_color = COL_YELLOW
		sb.border_color = Color.WHITE
		sb.border_width_left = 4
		sb.border_width_top = 2
		sb.border_width_right = 2
		sb.border_width_bottom = 3
		sb.shadow_color = Color(COL_YELLOW.r, COL_YELLOW.g, COL_YELLOW.b, 0.32)
		sb.shadow_size = 5
	else:
		# Pulsante inattivo solido, ben definito e subito riconoscibile come cliccabile!
		sb.bg_color = Color(0.08, 0.13, 0.23, 0.98)
		sb.border_color = Color(accent.r * 0.55 + 0.22, accent.g * 0.55 + 0.30, accent.b * 0.55 + 0.40, 0.92)
		sb.border_width_left = 4
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 2
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	sb_h = sb.duplicate() as StyleBoxFlat
	if not is_active:
		sb_h.bg_color = Color(0.12, 0.19, 0.32, 1.0)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb_h)
	btn.add_theme_stylebox_override("pressed", sb)
	if is_active:
		btn.add_theme_color_override("font_color", Color(0.04, 0.05, 0.09, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(0.04, 0.05, 0.09, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(0.04, 0.05, 0.09, 1.0))
		btn.add_theme_color_override("font_outline_color", Color(1.0, 0.98, 0.65, 0.35))
		btn.add_theme_constant_override("outline_size", 1)
	else:
		btn.add_theme_color_override("font_color", Color(0.93, 0.97, 1.0, 1.0))
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.07, 0.98))
		btn.add_theme_constant_override("outline_size", 3)

static func make_equipped_badge_box() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.02, 0.26, 0.16, 0.98)
	sb.border_color = COL_EQUIPPED
	sb.border_width_left = 3
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 5
	sb.content_margin_left = 7
	sb.content_margin_right = 7
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	return sb

static func make_rarity_pill_box(rarity_str: String) -> StyleBoxFlat:
	var rc := get_rarity_color(rarity_str)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(rc.r * 0.16 + 0.02, rc.g * 0.16 + 0.03, rc.b * 0.18 + 0.05, 0.96)
	sb.border_color = rc
	sb.border_width_left = 3
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 5
	sb.content_margin_left = 7
	sb.content_margin_right = 7
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	return sb

static func make_cyber_box(
	bg: Color = COL_PANEL,
	border: Color = COL_CYAN,
	_skew_x: float = 0.0,
	border_w: int = 1,
	left_accent_w: int = 4,
	glow_size: int = 4
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.skew = Vector2.ZERO
	sb.border_width_left = maxi(border_w, left_accent_w)
	sb.border_width_top = border_w
	sb.border_width_right = border_w
	sb.border_width_bottom = border_w + 1
	sb.border_color = border
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	if glow_size > 0:
		sb.shadow_color = Color(0.0, 0.01, 0.04, 0.55)
		sb.shadow_size = maxi(3, glow_size)
		sb.shadow_offset = Vector2(0, 3)
	return sb

## Placca Pulsante Asimmetrica Cyberpunk 2077 (384x144: Angoli 90° + Taglio 45° Basso-Destra)
static func style_button(btn: Button, accent: Color = COL_CYAN, is_primary_yellow: bool = false) -> void:
	if not btn:
		return

	var f_bold := get_cyber_font(true)
	if f_bold:
		btn.add_theme_font_override("font", f_bold)

	if not btn.has_theme_font_size_override("font_size"):
		btn.add_theme_font_size_override("font_size", 18)

	if btn.custom_minimum_size.y > 0 and btn.custom_minimum_size.y < 36:
		var mini_norm := make_cyber_box(Color(0.05, 0.08, 0.14, 0.96), accent, 0.0, 1, 3, 2)
		mini_norm.content_margin_top = 2
		mini_norm.content_margin_bottom = 2
		mini_norm.content_margin_left = 8
		mini_norm.content_margin_right = 8
		btn.add_theme_stylebox_override("normal", mini_norm)
		btn.add_theme_stylebox_override("hover", mini_norm)
		btn.add_theme_stylebox_override("pressed", mini_norm)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.06, 0.96))
		btn.add_theme_constant_override("outline_size", 2)
		return

	if btn.custom_minimum_size.y >= 36 and btn.custom_minimum_size.y < 56:
		btn.custom_minimum_size.y = 56

	var base_name := "ui_btn_cyan_3d"
	if is_primary_yellow:
		base_name = "ui_btn_gold_3d"
	elif accent.g > 0.80 and accent.r < 0.45:
		base_name = "ui_btn_green_3d"
	elif accent.r > 0.78 and (accent.b > 0.18 or accent.g < 0.35):
		base_name = "ui_btn_magenta_3d"

	var tex_norm := get_model_texture("res://assets/cyber_models/" + base_name + ".png")
	var tex_prs := get_model_texture("res://assets/cyber_models/" + base_name.replace("_3d", "_pressed_3d") + ".png")
	if not tex_prs:
		tex_prs = get_model_texture("res://assets/cyber_models/" + base_name + "_pressed.png")
	var tex_dis := get_model_texture("res://assets/cyber_models/ui_btn_disabled_3d.png")

	if tex_norm and tex_prs and tex_dis:
		var sb_n := StyleBoxTexture.new()
		sb_n.texture = tex_norm
		sb_n.texture_margin_left = 18; sb_n.texture_margin_right = 28
		sb_n.texture_margin_top = 14; sb_n.texture_margin_bottom = 26
		sb_n.content_margin_left = 16; sb_n.content_margin_right = 18
		sb_n.content_margin_top = 9; sb_n.content_margin_bottom = 10

		var sb_h := sb_n.duplicate() as StyleBoxTexture
		sb_h.modulate_color = Color(1.06, 1.06, 1.10, 1.0)

		var sb_p := StyleBoxTexture.new()
		sb_p.texture = tex_prs
		sb_p.texture_margin_left = 18; sb_p.texture_margin_right = 28
		sb_p.texture_margin_top = 16; sb_p.texture_margin_bottom = 24
		sb_p.content_margin_left = 16; sb_p.content_margin_right = 18
		sb_p.content_margin_top = 11; sb_p.content_margin_bottom = 8

		var sb_d := StyleBoxTexture.new()
		sb_d.texture = tex_dis
		sb_d.texture_margin_left = 18; sb_d.texture_margin_right = 28
		sb_d.texture_margin_top = 14; sb_d.texture_margin_bottom = 26
		sb_d.content_margin_left = 16; sb_d.content_margin_right = 18
		sb_d.content_margin_top = 9; sb_d.content_margin_bottom = 10

		btn.add_theme_stylebox_override("normal", sb_n)
		btn.add_theme_stylebox_override("hover", sb_h)
		btn.add_theme_stylebox_override("pressed", sb_p)
		btn.add_theme_stylebox_override("disabled", sb_d)
	else:
		btn.add_theme_stylebox_override("normal", make_cyber_box(COL_YELLOW if is_primary_yellow else COL_PANEL, accent, 0.0, 1, 4, 6))

	if is_primary_yellow:
		# Stile Iconico Cyberpunk 2077: Placca Giallo Acido #FCEE0A + Testo Nero Ossidiana Nitidissimo!
		btn.add_theme_color_override("font_color", Color(0.04, 0.05, 0.08, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(0.0, 0.0, 0.0, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(0.08, 0.09, 0.12, 1.0))
		btn.add_theme_color_override("font_disabled_color", Color(0.52, 0.56, 0.64, 0.80))
		btn.add_theme_color_override("font_outline_color", Color(1.0, 0.98, 0.55, 0.25))
		btn.add_theme_constant_override("outline_size", 0)
	else:
		btn.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", accent.lightened(0.35))
		btn.add_theme_color_override("font_disabled_color", Color(0.48, 0.54, 0.64, 0.78))
		btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.07, 0.96))
		btn.add_theme_constant_override("outline_size", 3)

static func style_label(lbl: Label, col: Color = Color.WHITE, outline_size: int = 3) -> void:
	if not lbl: return
	var f_bold := get_cyber_font(true)
	if f_bold:
		lbl.add_theme_font_override("font", f_bold)
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.07, 0.96))
	lbl.add_theme_constant_override("outline_size", outline_size)
	if not lbl.has_theme_font_size_override("font_size"):
		lbl.add_theme_font_size_override("font_size", 18)

static func apply_recursive_cyber_style(root: Node) -> void:
	if not root: return
	if root is Button:
		var b := root as Button
		var txt := b.text.to_upper()
		var is_yellow := ("START" in txt or "INCURSIONE" in txt or "GIOCA" in txt or "RIPRENDI" in txt or "RISCATTA" in txt or "ACQUISISCI" in txt)
		var col := COL_MAGENTA if ("EPIC" in txt or "ARASAKA" in txt or "SINTESI" in txt or "FUSIONE" in txt or "MENU" in txt) else COL_CYAN
		style_button(b, col, is_yellow)
	elif root is Label:
		var l := root as Label
		var f_bold := get_cyber_font(true)
		if f_bold:
			l.add_theme_font_override("font", f_bold)
		l.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.07, 0.96))
		if not l.has_theme_constant_override("outline_size"):
			l.add_theme_constant_override("outline_size", 3)
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
	# Vero Sfondo HD Dark-Cyberpunk Night City (ZERO griglie wireframe anni '80!)
	var bg_tex := get_model_texture("res://assets/cyber_models/ui_menu_bg_hd.png")
	if bg_tex:
		var tw: float = float(bg_tex.get_width())
		var th: float = float(bg_tex.get_height())
		var sc: float = maxf(size.x / maxf(1.0, tw), size.y / maxf(1.0, th))
		var sw: float = size.x / sc
		var sh: float = size.y / sc
		c.draw_texture_rect_region(bg_tex, Rect2(Vector2.ZERO, size), Rect2(Vector2((tw - sw) * 0.5, (th - sh) * 0.5), Vector2(sw, sh)), Color.WHITE)
	else:
		c.draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.045, 0.075, 1.0), true)

	# Leggero alone atmosferico del Settore attivo + pioggia obliqua sottile
	c.draw_circle(Vector2(size.x * 0.5, size.y * 0.36), size.x * 0.55, Color(accent.r, accent.g, accent.b, 0.055 + 0.015 * sin(t * 1.6)))
	for i in range(18):
		var rx: float = fmod(float(i) * 97.0 + t * 28.0, size.x + 60.0) - 30.0
		var ry: float = fmod(float(i) * 151.0 + t * (310.0 + float(i % 3) * 55.0), size.y + 80.0) - 40.0
		c.draw_line(Vector2(rx, ry), Vector2(rx - 7.0, ry + 34.0), Color(0.55, 0.85, 1.0, 0.08), 1.2)

	# Mirini telemetrici chirurgici agli angoli (estetica HUD Cyberpunk 2077)
	var hud_c := Color(accent.r, accent.g, accent.b, 0.22)
	c.draw_line(Vector2(8, 8), Vector2(36, 8), hud_c, 1.5)
	c.draw_line(Vector2(8, 8), Vector2(8, 36), hud_c, 1.5)
	c.draw_line(Vector2(size.x - 36, size.y - 8), Vector2(size.x - 8, size.y - 8), hud_c, 1.5)
	c.draw_line(Vector2(size.x - 8, size.y - 36), Vector2(size.x - 8, size.y - 8), hud_c, 1.5)

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
