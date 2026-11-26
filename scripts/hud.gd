extends CanvasLayer

@onready var hp_bar: ProgressBar = $TopContainer/HPBar
@onready var exp_bar: ProgressBar = $TopContainer/EXPBar
@onready var level_label: Label = $TopContainer/EXPBar/LevelLabel
@onready var room_label: Label = $TopContainer/RoomLabel
@onready var btn_pause: TextureButton = $TopContainer/BtnPause
@onready var pause_overlay: Panel = $PauseOverlay
@onready var btn_resume: Button = $PauseOverlay/VBoxContainer/BtnResume
@onready var btn_main_menu: Button = $PauseOverlay/VBoxContainer/BtnMainMenu

var boss_container: Control = null
var boss_hp_bar: ProgressBar = null
var boss_hp_label: Label = null
var boss_base_title: String = ""

var run_coins_lbl: Label = null
var run_cores_lbl: Label = null
var cur_shields: int = 0
var max_shields: int = 0
var last_hp: int = 100
var last_max_hp: int = 100

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("hud")

	boss_container = find_child("BossContainer", true, false) as Control
	boss_hp_bar = find_child("BossHPBar", true, false) as ProgressBar
	boss_hp_label = find_child("BossHPLabel", true, false) as Label

	var vig := get_node_or_null("VignetteOverlay") as CanvasItem
	if vig:
		vig.visible = false
	if boss_container: boss_container.hide()
	if pause_overlay: pause_overlay.hide()

	_apply_cyber_hud_styles()
	_build_live_loot_bar()

	if btn_pause:
		btn_pause.pressed.connect(_on_btn_pause_pressed)
	if btn_resume:
		btn_resume.pressed.connect(_on_btn_resume_pressed)
	if btn_main_menu:
		btn_main_menu.pressed.connect(_on_btn_main_menu_pressed)

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		setup(players[0])

func _process(_delta: float) -> void:
	if run_coins_lbl:
		run_coins_lbl.text = "+" + str(Global.run_coins)
	if run_cores_lbl:
		run_cores_lbl.text = "+" + str(Global.run_scrolls)

func setup(player: Node) -> void:
	if not player: return
	if player.has_signal("hp_changed") and not player.hp_changed.is_connected(_on_player_hp_changed):
		player.hp_changed.connect(_on_player_hp_changed)
	if player.has_signal("shield_changed") and not player.shield_changed.is_connected(_on_player_shield_changed):
		player.shield_changed.connect(_on_player_shield_changed)
	if player.has_signal("exp_changed") and not player.exp_changed.is_connected(_on_player_exp_changed):
		player.exp_changed.connect(_on_player_exp_changed)
	if player.has_signal("leveled_up") and not player.leveled_up.is_connected(_on_player_leveled_up):
		player.leveled_up.connect(_on_player_leveled_up)
	if "shield_charges" in player and "shield_max" in player:
		_on_player_shield_changed(player.shield_charges, player.shield_max)
	if "current_hp" in player and "max_hp" in player:
		_on_player_hp_changed(player.current_hp, player.max_hp)
	if "current_exp" in player and "exp_to_next_level" in player:
		_on_player_exp_changed(player.current_exp, player.exp_to_next_level)
	if "level" in player and level_label:
		level_label.text = "NEURAL LV. " + str(player.level)

func _build_live_loot_bar() -> void:
	var top_c := get_node_or_null("TopContainer") as Control
	if not top_c or top_c.get_node_or_null("RunLootPill") != null:
		return

	# Sfondo semitrasparente dietro la barra superiore HUD per massima leggibilità
	var hud_plate := PanelContainer.new()
	hud_plate.name = "TopHudBackdrop"
	hud_plate.position = Vector2(8, 6)
	hud_plate.size = Vector2(704, 72)
	hud_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_plate.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(8, 6, Color(0.92, 0.96, 1.0, 0.90)))
	top_c.add_child(hud_plate)
	top_c.move_child(hud_plate, 0)

	var loot_pill := PanelContainer.new()
	loot_pill.name = "RunLootPill"
	loot_pill.position = Vector2(326, 44)
	loot_pill.size = Vector2(286, 28)
	loot_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := CyberTheme.make_cyber_box(Color(0.05, 0.08, 0.16, 0.94), Color(0.20, 0.45, 0.68, 0.85), 0.0, 1, 2, 0)
	sb.content_margin_top = 2; sb.content_margin_bottom = 2
	sb.content_margin_left = 8; sb.content_margin_right = 8
	loot_pill.add_theme_stylebox_override("panel", sb)

	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 14)
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loot_pill.add_child(hb)

	var c_row := HBoxContainer.new()
	c_row.add_theme_constant_override("separation", 4)
	var c_ico := TextureRect.new()
	c_ico.custom_minimum_size = Vector2(20, 20)
	c_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	c_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	c_ico.texture = CyberTheme.get_ui_icon("coin")
	c_row.add_child(c_ico)
	run_coins_lbl = Label.new()
	run_coins_lbl.text = "+0"
	run_coins_lbl.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(run_coins_lbl, CyberTheme.COL_YELLOW, 3)
	c_row.add_child(run_coins_lbl)
	hb.add_child(c_row)

	var s_row := HBoxContainer.new()
	s_row.add_theme_constant_override("separation", 4)
	var s_ico := TextureRect.new()
	s_ico.custom_minimum_size = Vector2(20, 20)
	s_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	s_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	s_ico.texture = CyberTheme.get_ui_icon("core")
	s_row.add_child(s_ico)
	run_cores_lbl = Label.new()
	run_cores_lbl.text = "+0"
	run_cores_lbl.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(run_cores_lbl, CyberTheme.COL_GREEN, 3)
	s_row.add_child(run_cores_lbl)
	hb.add_child(s_row)

	top_c.add_child(loot_pill)

func _apply_cyber_hud_styles() -> void:
	if hp_bar:
		var sb_bg := CyberTheme.make_cyber_box(Color(0.04, 0.07, 0.14, 0.96), CyberTheme.COL_GREEN, 0.0, 2, 3, 2)
		sb_bg.content_margin_top = 0; sb_bg.content_margin_bottom = 0
		var sb_fill := StyleBoxFlat.new()
		sb_fill.bg_color = Color(0.10, 0.88, 0.48, 0.98)
		sb_fill.border_width_top = 2
		sb_fill.border_color = Color(0.65, 1.0, 0.85, 0.75)
		sb_fill.corner_radius_top_left = 10; sb_fill.corner_radius_top_right = 10
		sb_fill.corner_radius_bottom_left = 10; sb_fill.corner_radius_bottom_right = 10
		hp_bar.add_theme_stylebox_override("background", sb_bg)
		hp_bar.add_theme_stylebox_override("fill", sb_fill)
		hp_bar.show_percentage = false
		var hp_lbl := hp_bar.get_node_or_null("HPLabel") as Label
		if hp_lbl:
			hp_lbl.add_theme_font_size_override("font_size", 15)
			CyberTheme.style_label(hp_lbl, Color.WHITE, 4)

	if exp_bar:
		var sb_bg := CyberTheme.make_cyber_box(Color(0.04, 0.07, 0.14, 0.96), CyberTheme.COL_CYAN, 0.0, 2, 3, 2)
		sb_bg.content_margin_top = 0; sb_bg.content_margin_bottom = 0
		var sb_fill := StyleBoxFlat.new()
		sb_fill.bg_color = Color(0.0, 0.78, 0.96, 0.98)
		sb_fill.border_width_top = 2
		sb_fill.border_color = Color(0.75, 0.98, 1.0, 0.80)
		sb_fill.corner_radius_top_left = 10; sb_fill.corner_radius_top_right = 10
		sb_fill.corner_radius_bottom_left = 10; sb_fill.corner_radius_bottom_right = 10
		exp_bar.add_theme_stylebox_override("background", sb_bg)
		exp_bar.add_theme_stylebox_override("fill", sb_fill)
		if level_label:
			level_label.add_theme_font_size_override("font_size", 14)
			CyberTheme.style_label(level_label, CyberTheme.COL_YELLOW, 4)

	if boss_hp_bar:
		var sb_bg := CyberTheme.make_cyber_box(Color(0.10, 0.03, 0.09, 0.97), CyberTheme.COL_MAGENTA, 0.0, 2, 4, 6)
		sb_bg.content_margin_top = 0; sb_bg.content_margin_bottom = 0
		var sb_fill := StyleBoxFlat.new()
		sb_fill.bg_color = CyberTheme.COL_MAGENTA
		sb_fill.border_width_top = 2
		sb_fill.border_color = Color(1.0, 0.72, 0.88, 0.85)
		sb_fill.corner_radius_top_left = 10; sb_fill.corner_radius_top_right = 10
		sb_fill.corner_radius_bottom_left = 10; sb_fill.corner_radius_bottom_right = 10
		boss_hp_bar.add_theme_stylebox_override("background", sb_bg)
		boss_hp_bar.add_theme_stylebox_override("fill", sb_fill)
		if boss_hp_label:
			boss_hp_label.add_theme_font_size_override("font_size", 15)
			CyberTheme.style_label(boss_hp_label, CyberTheme.COL_YELLOW, 4)

	if room_label:
		room_label.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(room_label, CyberTheme.COL_YELLOW, 4)

	if btn_pause:
		btn_pause.texture_normal = CyberTheme.get_model_texture("res://assets/cyber_models/ui_btn_gold_3d.png")
		btn_pause.texture_pressed = CyberTheme.get_model_texture("res://assets/cyber_models/ui_btn_gold_pressed_3d.png")
		var p_lbl := btn_pause.get_node_or_null("Label") as Label
		if p_lbl:
			p_lbl.text = ""
		if not btn_pause.get_node_or_null("PauseIcon3D"):
			var p_ico := TextureRect.new()
			p_ico.name = "PauseIcon3D"
			p_ico.texture = CyberTheme.get_ui_icon("pause")
			p_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			p_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			p_ico.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn_pause.add_child(p_ico)
			p_ico.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			p_ico.offset_left = 14; p_ico.offset_right = -14
			p_ico.offset_top = 8; p_ico.offset_bottom = -10

	if pause_overlay:
		pause_overlay.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(18, 16))
		var p_vbox := pause_overlay.get_node_or_null("VBoxContainer") as VBoxContainer
		if p_vbox and not p_vbox.get_node_or_null("BtnPauseSettings"):
			var btn_ps := Button.new()
			btn_ps.name = "BtnPauseSettings"
			btn_ps.custom_minimum_size = Vector2(280, 58)
			btn_ps.icon = CyberTheme.get_ui_icon("settings")
			btn_ps.expand_icon = true
			btn_ps.text = "IMPOSTAZIONI & AUDIO"
			CyberTheme.style_button(btn_ps, CyberTheme.COL_YELLOW, false)
			btn_ps.pressed.connect(func():
				SoundFX.play_click()
				var sm_script := load("res://scripts/settings_modal.gd")
				if sm_script:
					var sm = sm_script.new()
					sm.show_char_creator_btn = false
					add_child(sm)
			)
			p_vbox.add_child(btn_ps)
			if btn_main_menu:
				p_vbox.move_child(btn_ps, btn_main_menu.get_index())
		CyberTheme.apply_recursive_cyber_style(pause_overlay)

func update_room_status(room: int, total_rooms: int, remaining: int, total_enemies: int, is_boss: bool, is_sanctuary: bool) -> void:
	if not room_label:
		return
	if is_sanctuary:
		room_label.text = "STAGE " + str(room) + "/" + str(total_rooms) + " • ✦ VALCHIRIA"
		CyberTheme.style_label(room_label, CyberTheme.COL_CYAN, 4)
	elif remaining > 0:
		var tag := "★ SCONTRO BOSS" if is_boss else ("OSTILI: " + str(remaining) + "/" + str(total_enemies))
		room_label.text = "STAGE " + str(room) + "/" + str(total_rooms) + " • " + tag
		CyberTheme.style_label(room_label, CyberTheme.COL_MAGENTA if is_boss else CyberTheme.COL_YELLOW, 4)
	else:
		room_label.text = "STAGE " + str(room) + "/" + str(total_rooms) + " • ▶ VAI AL PORTALE"
		CyberTheme.style_label(room_label, CyberTheme.COL_GREEN, 4)

func show_boss_bar(boss_name: String, max_hp: int) -> void:
	boss_base_title = boss_name
	if boss_container: boss_container.show()
	if boss_hp_label: boss_hp_label.text = boss_name + "  [" + str(max_hp) + " HP]"
	if boss_hp_bar:
		boss_hp_bar.max_value = max_hp
		boss_hp_bar.value = max_hp

func update_boss_hp(current: int, max_val: int) -> void:
	if boss_hp_bar:
		boss_hp_bar.max_value = max_val
		boss_hp_bar.value = max(0, current)
	if boss_hp_label and not boss_base_title.is_empty():
		boss_hp_label.text = boss_base_title + "  [" + str(maxi(0, current)) + " / " + str(max_val) + "]"

func hide_boss_bar() -> void:
	if boss_container: boss_container.hide()

func _refresh_hp_text() -> void:
	if not hp_bar: return
	var hp_lbl := hp_bar.get_node_or_null("HPLabel") as Label
	if hp_lbl:
		var sh_txt := ("   ◆ SCUDI x" + str(cur_shields)) if cur_shields > 0 else ""
		hp_lbl.text = "HP  " + str(last_hp) + " / " + str(last_max_hp) + sh_txt

func _on_player_hp_changed(current: int, max_val: int) -> void:
	last_hp = maxi(0, current)
	last_max_hp = maxi(1, max_val)
	if hp_bar:
		hp_bar.max_value = last_max_hp
		hp_bar.value = last_hp
	_refresh_hp_text()

func _on_player_shield_changed(charges: int, max_ch: int) -> void:
	cur_shields = maxi(0, charges)
	max_shields = maxi(0, max_ch)
	_refresh_hp_text()

func _on_player_exp_changed(current: int, max_val: int) -> void:
	if exp_bar:
		exp_bar.max_value = max_val
		exp_bar.value = current

func _on_player_leveled_up(new_level: int) -> void:
	if level_label:
		level_label.text = "NEURAL LV. " + str(new_level)

func _on_btn_pause_pressed() -> void:
	SoundFX.play_click()
	get_tree().paused = true
	if pause_overlay:
		pause_overlay.show()

func _on_btn_resume_pressed() -> void:
	SoundFX.play_click()
	get_tree().paused = false
	if pause_overlay:
		pause_overlay.hide()

func _on_btn_main_menu_pressed() -> void:
	SoundFX.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
