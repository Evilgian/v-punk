extends CanvasLayer

var player_ref: Node2D

@onready var panel: PanelContainer = get_node_or_null("Control/PanelContainer") as PanelContainer
@onready var container: VBoxContainer = $Control/PanelContainer/VBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if panel:
		panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(16, 16))
		panel.offset_left = -346.0
		panel.offset_right = 346.0
		panel.offset_top = -255.0
		panel.offset_bottom = 255.0

	if not player_ref:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player_ref = players[0] as Node2D

	_populate_perks()


func _populate_perks() -> void:
	if not container:
		return

	container.add_theme_constant_override("separation", 12)
	for child in container.get_children().duplicate():
		if child is Label:
			var hdr := child as Label
			hdr.text = "⚡ LEVEL UP // SCEGLI POTERE"
			hdr.add_theme_font_size_override("font_size", 24)
			hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			CyberTheme.style_label(hdr, CyberTheme.COL_YELLOW, 4)
		else:
			container.remove_child(child)
			child.queue_free()

	var sub := Label.new()
	sub.text = "Tocca una carta per innestare subito il potenziamento"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(sub, CyberTheme.COL_CYAN, 2)
	container.add_child(sub)

	# Griglia Orizzontale a 3 Carte Affiancate in stile Archero: Icona Grande + Nome Corto + Effetto Immediato!
	var cards_row := HBoxContainer.new()
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_row.add_theme_constant_override("separation", 10)
	cards_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(cards_row)

	var stacks: Dictionary = player_ref.perk_stacks if (player_ref and "perk_stacks" in player_ref) else {}
	var perks: Array[PerkData] = PerkDB.get_random_perks(3, player_ref)

	for i in range(perks.size()):
		var perk: PerkData = perks[i]
		var rar_col: Color = CyberTheme.get_rarity_color(perk.rarity)
		var owned: int = int(stacks.get(perk.id, 0))

		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(208, 356)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(perk.rarity, 10, 12))

		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		vb.add_theme_constant_override("separation", 8)
		vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(vb)

		# 1. Pillola Rarità + Grado in alto
		var rar_pill := PanelContainer.new()
		rar_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rar_pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		rar_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box(perk.rarity))
		var r_lbl := Label.new()
		var r_txt := CyberTheme.get_rarity_label_it(perk.rarity)
		if owned > 0 and perk.max_stacks > 1 and perk.max_stacks < 99:
			r_txt += " • LV." + str(owned + 1)
		r_lbl.text = r_txt
		r_lbl.add_theme_font_size_override("font_size", 12)
		r_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		CyberTheme.style_label(r_lbl, rar_col.lightened(0.28), 2)
		rar_pill.add_child(r_lbl)
		vb.add_child(rar_pill)

		# 2. Medaglione Icona Grande Stile Archero (124x124) — riconoscibile a colpo d'occhio!
		var icon_box := Control.new()
		icon_box.custom_minimum_size = Vector2(128, 128)
		icon_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pid_cap: String = perk.id
		icon_box.draw.connect(func():
			_draw_archero_perk_icon(icon_box, Vector2(64, 64), pid_cap, rar_col)
		)
		vb.add_child(icon_box)

		# 3. Titolo Breve & Chiaro
		var title_lbl := Label.new()
		title_lbl.text = perk.display_name.to_upper()
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title_lbl.add_theme_font_size_override("font_size", 18)
		CyberTheme.style_label(title_lbl, Color.WHITE, 4)
		vb.add_child(title_lbl)

		# 4. Spiegazione Cortissima (1-2 righe lampo)
		var desc_lbl := Label.new()
		desc_lbl.text = perk.description
		desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		desc_lbl.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(desc_lbl, rar_col.lightened(0.32), 3)
		vb.add_child(desc_lbl)

		# Bottone trasparente su tutta la carta
		var hit_btn := Button.new()
		hit_btn.flat = true
		hit_btn.focus_mode = Control.FOCUS_NONE
		hit_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		var empty_sb := StyleBoxEmpty.new()
		for st_k in ["normal", "hover", "pressed", "disabled", "focus"]:
			hit_btn.add_theme_stylebox_override(st_k, empty_sb)
		hit_btn.pressed.connect(_on_perk_selected.bind(perk.id))
		card.add_child(hit_btn)

		cards_row.add_child(card)
		card.pivot_offset = Vector2(104, 178)
		card.scale = Vector2.ZERO
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(card, "scale", Vector2.ONE, 0.26).set_delay(i * 0.05)


static func _draw_arrow_glyph(c: CanvasItem, from_p: Vector2, to_p: Vector2, col: Color, width: float = 4.5) -> void:
	c.draw_line(from_p, to_p, col, width)
	c.draw_line(from_p, to_p, Color.WHITE, maxf(1.5, width * 0.38))
	var dir := (to_p - from_p).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var head := PackedVector2Array([
		to_p + dir * 6.0,
		to_p - dir * 8.0 + perp * 7.5,
		to_p - dir * 8.0 - perp * 7.5
	])
	c.draw_colored_polygon(head, col)
	c.draw_colored_polygon(PackedVector2Array([
		to_p + dir * 3.5,
		to_p - dir * 5.0 + perp * 4.0,
		to_p - dir * 5.0 - perp * 4.0
	]), Color.WHITE)


static func _draw_archero_perk_icon(c: CanvasItem, center: Vector2, perk_id: String, rar_col: Color) -> void:
	# Medaglione Ottagonale Cyberpunk in stile Archero con bagliore di rarità
	var oct := PackedVector2Array()
	var oct_in := PackedVector2Array()
	for s in range(8):
		var a := float(s) * (TAU / 8.0) + PI / 8.0
		oct.append(center + Vector2(cos(a), sin(a)) * 54.0)
		oct_in.append(center + Vector2(cos(a), sin(a)) * 47.0)
	c.draw_colored_polygon(oct, Color(0.03, 0.05, 0.11, 0.98))
	c.draw_circle(center, 38.0, Color(rar_col.r, rar_col.g, rar_col.b, 0.18))
	for s in range(8):
		c.draw_line(oct[s], oct[(s + 1) % 8], rar_col, 3.0)
		c.draw_line(oct_in[s], oct_in[(s + 1) % 8], Color(rar_col.r, rar_col.g, rar_col.b, 0.35), 1.4)

	var cyan := Color(0.0, 0.95, 1.0, 1.0)
	var gold := Color(1.0, 0.88, 0.12, 1.0)
	var crimson := Color(1.0, 0.20, 0.36, 1.0)
	var green := Color(0.12, 0.98, 0.56, 1.0)
	var violet := Color(0.84, 0.28, 1.0, 1.0)

	match perk_id:
		"front_arrow":
			_draw_arrow_glyph(c, center + Vector2(-11, 24), center + Vector2(-11, -24), cyan, 4.8)
			_draw_arrow_glyph(c, center + Vector2(11, 24), center + Vector2(11, -24), gold, 4.8)
		"twin_shot":
			for ox in [-10.0, 10.0]:
				c.draw_rect(Rect2(center + Vector2(ox - 4, -26), Vector2(8, 52)), cyan, true)
				c.draw_rect(Rect2(center + Vector2(ox - 2, -22), Vector2(4, 44)), Color.WHITE, true)
		"diagonal_arrow":
			_draw_arrow_glyph(c, center + Vector2(0, 22), center + Vector2(0, -26), cyan, 4.2)
			_draw_arrow_glyph(c, center + Vector2(-6, 20), center + Vector2(-28, -18), gold, 4.2)
			_draw_arrow_glyph(c, center + Vector2(6, 20), center + Vector2(28, -18), gold, 4.2)
		"spread_shot":
			for deg in [-34.0, -17.0, 0.0, 17.0, 34.0]:
				var d := Vector2.UP.rotated(deg_to_rad(deg))
				_draw_arrow_glyph(c, center + Vector2(0, 22), center + Vector2(0, 22) + d * 46.0, cyan if absf(deg) < 5.0 else gold, 3.4)
		"rear_arrow":
			_draw_arrow_glyph(c, center + Vector2(0, -4), center + Vector2(0, -28), cyan, 4.6)
			_draw_arrow_glyph(c, center + Vector2(0, 4), center + Vector2(0, 28), gold, 4.6)
		"side_arrows":
			_draw_arrow_glyph(c, center + Vector2(-4, 0), center + Vector2(-30, 0), gold, 4.6)
			_draw_arrow_glyph(c, center + Vector2(4, 0), center + Vector2(30, 0), gold, 4.6)
			c.draw_circle(center, 5.5, cyan)
		"bouncy_wall":
			c.draw_rect(Rect2(center + Vector2(-32, -28), Vector2(7, 56)), Color(0.55, 0.68, 0.85, 1.0), true)
			c.draw_line(center + Vector2(18, 24), center + Vector2(-24, 0), cyan, 4.2)
			_draw_arrow_glyph(c, center + Vector2(-24, 0), center + Vector2(22, -24), gold, 4.2)
			c.draw_circle(center + Vector2(-24, 0), 5.5, Color.WHITE)
		"ricochet":
			var p1 := center + Vector2(-22, 18)
			var p2 := center + Vector2(22, -4)
			var p3 := center + Vector2(-16, -24)
			c.draw_line(p1, p2, violet, 4.2)
			_draw_arrow_glyph(c, p2, p3, cyan, 4.2)
			c.draw_circle(p1, 7.0, crimson)
			c.draw_circle(p2, 7.0, crimson)
		"piercing":
			c.draw_arc(center + Vector2(0, 8), 16.0, 0.0, TAU, 24, crimson, 3.0)
			c.draw_arc(center + Vector2(0, -10), 12.0, 0.0, TAU, 24, crimson, 2.5)
			_draw_arrow_glyph(c, center + Vector2(0, 30), center + Vector2(0, -30), gold, 5.2)
		"homing_rounds":
			c.draw_arc(center + Vector2(10, -12), 15.0, 0.0, TAU, 24, crimson, 2.6)
			c.draw_line(center + Vector2(10, -31), center + Vector2(10, 7), crimson, 2.0)
			c.draw_line(center + Vector2(-9, -12), center + Vector2(29, -12), crimson, 2.0)
			c.draw_arc(center + Vector2(6, 12), 24.0, PI * 0.65, PI * 1.45, 18, violet, 4.2)
			_draw_arrow_glyph(c, center + Vector2(-8, -8), center + Vector2(8, -12), cyan, 4.2)
		"giant_shots":
			c.draw_circle(center + Vector2(-20, 16), 7.5, cyan)
			c.draw_circle(center + Vector2(8, -4), 21.0, Color(gold.r, gold.g, gold.b, 0.35))
			c.draw_circle(center + Vector2(8, -4), 16.0, gold)
			c.draw_circle(center + Vector2(8, -4), 8.0, Color.WHITE)
		"burst_volley":
			for bi in range(3):
				var by := 16.0 - float(bi) * 16.0
				_draw_arrow_glyph(c, center + Vector2(-18, by + 6), center + Vector2(18, by - 6), gold if bi == 2 else cyan, 4.0)
		"attack_speed":
			var bolt := PackedVector2Array([
				center + Vector2(6, -30), center + Vector2(-18, 2), center + Vector2(-1, 2),
				center + Vector2(-8, 30), center + Vector2(20, -4), center + Vector2(3, -4)
			])
			c.draw_colored_polygon(bolt, gold)
			c.draw_polyline(PackedVector2Array([center + Vector2(6, -30), center + Vector2(-18, 2), center + Vector2(-1, 2), center + Vector2(-8, 30)]), Color.WHITE, 2.0)
		"damage_up":
			var blade := PackedVector2Array([
				center + Vector2(0, -32), center + Vector2(13, 8), center + Vector2(5, 14),
				center + Vector2(5, 28), center + Vector2(-5, 28), center + Vector2(-5, 14), center + Vector2(-13, 8)
			])
			c.draw_colored_polygon(blade, crimson)
			c.draw_line(center + Vector2(-18, 12), center + Vector2(18, 12), gold, 4.5)
			c.draw_line(center + Vector2(0, -28), center + Vector2(0, 10), Color.WHITE, 2.6)
		"crit_up", "sniper_caliber":
			c.draw_arc(center, 24.0, 0.0, TAU, 28, gold, 3.4)
			c.draw_arc(center, 11.0, 0.0, TAU, 20, crimson, 2.8)
			c.draw_line(center + Vector2(-32, 0), center + Vector2(32, 0), gold, 2.6)
			c.draw_line(center + Vector2(0, -32), center + Vector2(0, 32), gold, 2.6)
			c.draw_circle(center, 4.0, Color.WHITE)
		"executioner":
			c.draw_circle(center + Vector2(0, -4), 19.0, Color(0.90, 0.94, 1.0, 0.95))
			c.draw_rect(Rect2(center + Vector2(-10, 10), Vector2(20, 12)), Color(0.90, 0.94, 1.0, 0.95), true)
			c.draw_circle(center + Vector2(-7, -5), 4.5, crimson)
			c.draw_circle(center + Vector2(7, -5), 4.5, crimson)
			c.draw_line(center + Vector2(-28, 24), center + Vector2(28, -26), crimson, 5.0)
		"berserker":
			for r_i in range(3):
				c.draw_arc(center + Vector2(0, 10), 14.0 + float(r_i) * 9.0, PI * 1.1, PI * 1.9, 18, crimson if r_i < 2 else gold, 4.0)
			c.draw_circle(center + Vector2(0, 12), 9.0, crimson)
			c.draw_circle(center + Vector2(0, 12), 4.5, Color.WHITE)
		"lucky_overdrive":
			var star := PackedVector2Array()
			for si in range(8):
				var sa := float(si) * (TAU / 8.0) - PI * 0.5
				var sr := 28.0 if (si % 2 == 0) else 11.0
				star.append(center + Vector2(cos(sa), sin(sa)) * sr)
			c.draw_colored_polygon(star, gold)
			c.draw_circle(center, 6.0, Color.WHITE)
		"explosive":
			var boom := PackedVector2Array()
			for bi in range(12):
				var ba := float(bi) * (TAU / 12.0)
				var br := 30.0 if (bi % 2 == 0) else 14.0
				boom.append(center + Vector2(cos(ba), sin(ba)) * br)
			c.draw_colored_polygon(boom, Color(1.0, 0.42, 0.08, 1.0))
			c.draw_circle(center, 11.0, gold)
			c.draw_circle(center, 5.0, Color.WHITE)
		"chain_lightning":
			var pts := PackedVector2Array([center + Vector2(-22, -26), center + Vector2(-2, -6), center + Vector2(-12, 2), center + Vector2(14, 26)])
			c.draw_polyline(pts, cyan, 5.0)
			c.draw_polyline(pts, Color.WHITE, 2.2)
			c.draw_line(center + Vector2(-2, -6), center + Vector2(22, -16), gold, 3.8)
		"freeze_shot":
			for fi in range(6):
				var fa := float(fi) * (TAU / 6.0)
				var fd := Vector2(cos(fa), sin(fa))
				c.draw_line(center, center + fd * 28.0, cyan, 3.6)
				var mid := center + fd * 17.0
				c.draw_line(mid, mid + fd.rotated(0.6) * 8.5, Color.WHITE, 2.4)
				c.draw_line(mid, mid + fd.rotated(-0.6) * 8.5, Color.WHITE, 2.4)
			c.draw_circle(center, 5.0, Color.WHITE)
		"burn_shot":
			var fl := PackedVector2Array([
				center + Vector2(0, -30), center + Vector2(18, -4), center + Vector2(22, 14),
				center + Vector2(10, 28), center + Vector2(-10, 28), center + Vector2(-22, 14), center + Vector2(-16, -6)
			])
			c.draw_colored_polygon(fl, Color(1.0, 0.34, 0.08, 1.0))
			c.draw_circle(center + Vector2(0, 12), 11.0, gold)
			c.draw_circle(center + Vector2(0, 15), 5.5, Color.WHITE)
		"static_field":
			c.draw_arc(center, 28.0, 0.0, TAU, 28, cyan, 3.0)
			c.draw_arc(center, 18.0, 0.4, PI * 1.7, 20, gold, 3.2)
			c.draw_circle(center, 7.0, Color.WHITE)
		"plasma_trail":
			c.draw_circle(center + Vector2(-18, 16), 9.0, Color(green.r, green.g, green.b, 0.55))
			c.draw_circle(center + Vector2(0, 4), 12.0, Color(green.r, green.g, green.b, 0.80))
			c.draw_circle(center + Vector2(16, -12), 15.0, green)
			c.draw_circle(center + Vector2(16, -12), 6.5, Color.WHITE)
		"orbit_blades":
			c.draw_arc(center, 23.0, 0.0, TAU, 28, Color(cyan.r, cyan.g, cyan.b, 0.45), 2.5)
			for oi in range(3):
				var oa := float(oi) * (TAU / 3.0) - 0.4
				var bp := center + Vector2(cos(oa), sin(oa)) * 23.0
				c.draw_circle(bp, 7.5, gold)
				c.draw_circle(bp, 3.8, Color.WHITE)
			c.draw_circle(center, 6.0, cyan)
		"shoulder_missiles":
			for mx in [-13.0, 13.0]:
				c.draw_rect(Rect2(center + Vector2(mx - 5, -14), Vector2(10, 26)), Color(0.88, 0.94, 1.0, 1.0), true)
				c.draw_colored_polygon(PackedVector2Array([
					center + Vector2(mx, -28), center + Vector2(mx + 6, -14), center + Vector2(mx - 6, -14)
				]), crimson)
				c.draw_circle(center + Vector2(mx, 18), 5.5, gold)
		"shockwave_nova":
			c.draw_arc(center, 29.0, 0.0, TAU, 32, cyan, 4.0)
			c.draw_arc(center, 18.0, 0.0, TAU, 24, gold, 3.0)
			c.draw_circle(center, 8.0, Color.WHITE)
		"energy_shield":
			var sh := PackedVector2Array([
				center + Vector2(0, -28), center + Vector2(24, -16), center + Vector2(20, 10),
				center + Vector2(0, 29), center + Vector2(-20, 10), center + Vector2(-24, -16)
			])
			c.draw_colored_polygon(sh, Color(0.06, 0.42, 0.68, 0.85))
			for si in range(sh.size()):
				c.draw_line(sh[si], sh[(si + 1) % sh.size()], cyan, 3.8)
			c.draw_circle(center, 6.5, Color.WHITE)
		"vampire":
			var drop := PackedVector2Array([
				center + Vector2(0, -28), center + Vector2(18, 6), center + Vector2(10, 24),
				center + Vector2(-10, 24), center + Vector2(-18, 6)
			])
			c.draw_colored_polygon(drop, crimson)
			c.draw_rect(Rect2(center + Vector2(-3, 0), Vector2(6, 16)), Color.WHITE, true)
			c.draw_rect(Rect2(center + Vector2(-8, 5), Vector2(16, 6)), Color.WHITE, true)
		"dodge", "move_speed":
			for li in range(3):
				var ly := -14.0 + float(li) * 14.0
				_draw_arrow_glyph(c, center + Vector2(-24, ly), center + Vector2(22, ly), cyan if li == 1 else green, 4.2)
		_: # regen, max_hp_up, titan_heart, heal
			var cross_col := gold if perk_id == "titan_heart" else green
			c.draw_circle(center, 24.0, Color(cross_col.r, cross_col.g, cross_col.b, 0.24))
			c.draw_rect(Rect2(center + Vector2(-7, -23), Vector2(14, 46)), cross_col, true)
			c.draw_rect(Rect2(center + Vector2(-23, -7), Vector2(46, 14)), cross_col, true)
			c.draw_rect(Rect2(center + Vector2(-4, -18), Vector2(8, 36)), Color.WHITE, true)
			c.draw_rect(Rect2(center + Vector2(-18, -4), Vector2(36, 8)), Color.WHITE, true)


func _on_perk_selected(perk_id: String) -> void:
	if player_ref and player_ref.has_method("apply_perk"):
		player_ref.apply_perk(perk_id)

	SoundFX.play_pickup()
	get_tree().paused = false
	queue_free()
