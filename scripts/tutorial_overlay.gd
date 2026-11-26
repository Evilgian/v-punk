extends Node2D

var anim_t: float = 0.0
var step_display_t: float = 0.0
var last_state_key: String = ""
var is_collapsed: bool = false

var ui_layer: CanvasLayer = null
var card_panel: PanelContainer = null
var step_badge_lbl: Label = null
var title_lbl: Label = null
var body_lbl: Label = null
var toggle_btn: Button = null

func _ready() -> void:
	z_index = -1
	_build_hud_banner()

func _build_hud_banner() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "TutorialHUDLayer"
	ui_layer.layer = 2
	add_child(ui_layer)

	var root_ctrl := Control.new()
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(root_ctrl)
	root_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	card_panel = PanelContainer.new()
	card_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_panel.anchor_left = 0.0
	card_panel.anchor_right = 1.0
	card_panel.anchor_top = 0.0
	card_panel.anchor_bottom = 0.0
	card_panel.offset_left = 20.0
	card_panel.offset_right = -20.0
	card_panel.offset_top = 84.0
	card_panel.offset_bottom = 166.0
	card_panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(10, 6))
	root_ctrl.add_child(card_panel)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 2)
	card_panel.add_child(vbox)

	var top_row := HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_theme_constant_override("separation", 8)
	vbox.add_child(top_row)

	step_badge_lbl = Label.new()
	step_badge_lbl.text = "★ GUIDA [1/6]"
	step_badge_lbl.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(step_badge_lbl, CyberTheme.COL_YELLOW, 3)
	top_row.add_child(step_badge_lbl)

	title_lbl = Label.new()
	title_lbl.text = "MOVIMENTO & FUOCO AUTOMATICO"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_lbl.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(title_lbl, CyberTheme.COL_CYAN, 3)
	top_row.add_child(title_lbl)

	toggle_btn = Button.new()
	toggle_btn.custom_minimum_size = Vector2(76, 28)
	toggle_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	toggle_btn.text = "CHIUDI ▲"
	toggle_btn.add_theme_font_size_override("font_size", 12)
	CyberTheme.style_button(toggle_btn, CyberTheme.COL_CYAN, false)
	toggle_btn.pressed.connect(func():
		SoundFX.play_click()
		_set_collapsed(not is_collapsed)
	)
	top_row.add_child(toggle_btn)

	body_lbl = Label.new()
	body_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_lbl.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(body_lbl, Color(0.92, 0.96, 1.0, 1.0), 2)
	vbox.add_child(body_lbl)

func _set_collapsed(collapsed: bool) -> void:
	is_collapsed = collapsed
	if body_lbl:
		body_lbl.visible = not is_collapsed
	if toggle_btn:
		toggle_btn.text = "INFO ▼" if is_collapsed else "CHIUDI ▲"
	if card_panel:
		card_panel.offset_bottom = card_panel.offset_top + (42.0 if is_collapsed else 84.0)

func _process(delta: float) -> void:
	anim_t += delta
	step_display_t += delta
	# Dopo 5.5s di combattimento nella stessa stanza si compatta automaticamente in 1 riga per liberare l'arena!
	if not is_collapsed and step_display_t >= 5.5:
		_set_collapsed(true)
	_refresh_tutorial_step()
	queue_redraw()

func _get_spawner() -> Node:
	var spawners := get_tree().get_nodes_in_group("spawner")
	return spawners[0] if not spawners.is_empty() else null

func _refresh_tutorial_step() -> void:
	var sp := _get_spawner()
	if not sp:
		return
	var room: int = int(sp.current_room) if "current_room" in sp else 1
	var cleared: bool = bool(sp.room_cleared) if "room_cleared" in sp else false

	var state_key := str(room) + ("_CLEAR" if cleared else "_FIGHT")
	if state_key == last_state_key:
		return
	last_state_key = state_key
	step_display_t = 0.0

	# Nella stanza del Boss parte subito sotto la BossHPBar (y=114) e compatto!
	var top_y: float = 114.0 if (room == 10 and not cleared) else 84.0
	if card_panel:
		card_panel.offset_top = top_y
	_set_collapsed(room > 5 and room != 10 and not cleared)

	var badge_txt := "★ GUIDA"
	var head_txt := ""
	var desc_txt := ""
	var border_col := CyberTheme.COL_CYAN

	if room == 1 and not cleared:
		badge_txt = "★ PASSO 1/6"
		head_txt = "MUOVITI PER SCHIVARE • FERMATI PER SPARARE"
		desc_txt = "Trascina il pollice in basso per muoverti; rilascia e resta fermo per sparare in automatico!"
		border_col = CyberTheme.COL_YELLOW
	elif room == 1 and cleared:
		badge_txt = "★ PASSO 2/6"
		head_txt = "BOTTINO MAGNETICO & PORTALE A NORD"
		desc_txt = "Stanza pulita! Il bottino viene aspirato automaticamente: segui le frecce fino al Portale in alto."
		border_col = CyberTheme.COL_GREEN
	elif room == 2 and not cleared:
		badge_txt = "★ PASSO 3/6"
		head_txt = "COPERTURE 3D & CASSE RIFORNIMENTO"
		desc_txt = "Usa le Torri-Server per parare i colpi dei Droni e distruggi la Cassa Dorata per ottenere Cure o Nuclei!"
		border_col = CyberTheme.COL_CYAN
	elif room == 3 and not cleared:
		badge_txt = "★ PASSO 4/6"
		head_txt = "TRAPPOLE A PAVIMENTO & MECH MORTAIO"
		desc_txt = "Spostati subito quando le botole a terra lampeggiano in giallo o vedi il cerchio rosso dei mortai!"
		border_col = CyberTheme.COL_YELLOW
	elif room == 4 and not cleared:
		badge_txt = "★ PASSO 5/6"
		head_txt = "TORRETTE SPITTER & POTENZIAMENTI"
		desc_txt = "Raccogli XP per scegliere Cyberware cumulabili; nel menu EQUIP potenzia e fondi 3 copie identiche!"
		border_col = CyberTheme.COL_MAGENTA
	elif room == 5 and not cleared:
		badge_txt = "★ PASSO 6/6"
		head_txt = "SANTUARIO CYBER-VALCHIRIA"
		desc_txt = "Avvicinati al cerchio luminoso della Valchiria al centro per scegliere Cura HP o un Potere Minore!"
		border_col = CyberTheme.COL_GREEN
	elif room == 10 and not cleared:
		badge_txt = "★ BOSS FINALE"
		head_txt = "SCONFIGGI IL GOLEM SILVANO MK-I"
		desc_txt = "Osserva l'anello di carica del Boss, schiva le raffiche e colpisci per sbloccare il Mondo 2!"
		border_col = CyberTheme.COL_MAGENTA
	elif cleared:
		badge_txt = "✓ PULITA"
		head_txt = "ENTRA NEL PORTALE STARGATE IN ALTO"
		desc_txt = "Cammina nell'arco luminoso a Nord per avanzare allo Stage successivo."
		border_col = CyberTheme.COL_GREEN
	else:
		badge_txt = "◆ STAGE " + str(room) + "/10"
		head_txt = "AVANZA FINO AL BOSS DELLO STAGE 10"
		desc_txt = "Sfrutta le coperture e raccogli Nuclei ed equipaggiamenti."
		border_col = CyberTheme.COL_CYAN

	if step_badge_lbl:
		step_badge_lbl.text = badge_txt
	if title_lbl:
		title_lbl.text = head_txt
		CyberTheme.style_label(title_lbl, border_col, 3)
	if body_lbl:
		body_lbl.text = desc_txt

func _draw() -> void:
	var sp := _get_spawner()
	if not sp:
		return
	var room: int = int(sp.current_room) if "current_room" in sp else 1
	var cleared: bool = bool(sp.room_cleared) if "room_cleared" in sp else false

	var players := get_tree().get_nodes_in_group("player")
	var player: Node2D = players[0] as Node2D if (not players.is_empty() and players[0] is Node2D) else null

	if cleared and is_instance_valid(player):
		var start_p := player.global_position + Vector2(0, -24)
		var end_p := Vector2(360, 134)
		var dist: float = start_p.distance_to(end_p)
		if dist > 70.0:
			var dir := (end_p - start_p).normalized()
			var perp := Vector2(-dir.y, dir.x)
			var steps: int = clampi(int(dist / 68.0), 2, 12)
			for i in range(steps):
				var wave: float = fmod(anim_t * 3.0 - float(i) * 0.35, 1.0)
				if wave < 0.0: wave += 1.0
				var alpha: float = 0.25 + 0.70 * sin(wave * PI)
				var cp := start_p.lerp(end_p, float(i + 1) / float(steps + 1))
				var tip := cp + dir * 14.0
				var left_w := cp - dir * 8.0 + perp * 16.0
				var right_w := cp - dir * 8.0 - perp * 16.0
				draw_polyline(PackedVector2Array([left_w, tip, right_w]), Color(0.2, 1.0, 0.65, alpha), 4.0)
				draw_polyline(PackedVector2Array([left_w, tip, right_w]), Color(1.0, 1.0, 1.0, alpha * 0.75), 1.6)

	if room == 1 and not cleared and is_instance_valid(player):
		var is_shoot: bool = bool(player.is_shooting) if "is_shooting" in player else false
		var ring_col := Color(0.2, 1.0, 0.55, 0.85) if is_shoot else Color(1.0, 0.84, 0.15, 0.75)
		var p_pos := player.global_position + Vector2(0, 16)
		draw_set_transform(p_pos, 0.0, Vector2(1.0, 0.44))
		draw_arc(Vector2.ZERO, 44.0 + sin(anim_t * 6.0) * 3.0, 0.0, TAU, 36, ring_col, 2.8)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
