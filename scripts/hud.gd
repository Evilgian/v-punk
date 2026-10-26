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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("hud")

	boss_container = find_child("BossContainer", true, false) as Control
	boss_hp_bar = find_child("BossHPBar", true, false) as ProgressBar
	boss_hp_label = find_child("BossHPLabel", true, false) as Label

	if boss_container: boss_container.hide()
	if pause_overlay: pause_overlay.hide()

	_apply_cyber_hud_styles()

	if btn_pause:
		btn_pause.pressed.connect(_on_btn_pause_pressed)
	if btn_resume:
		btn_resume.pressed.connect(_on_btn_resume_pressed)
	if btn_main_menu:
		btn_main_menu.pressed.connect(_on_btn_main_menu_pressed)

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		setup(players[0])

func setup(player: Node) -> void:
	if not player: return
	if player.has_signal("hp_changed") and not player.hp_changed.is_connected(_on_player_hp_changed):
		player.hp_changed.connect(_on_player_hp_changed)
	if player.has_signal("exp_changed") and not player.exp_changed.is_connected(_on_player_exp_changed):
		player.exp_changed.connect(_on_player_exp_changed)
	if player.has_signal("leveled_up") and not player.leveled_up.is_connected(_on_player_leveled_up):
		player.leveled_up.connect(_on_player_leveled_up)
	if "current_hp" in player and "max_hp" in player:
		_on_player_hp_changed(player.current_hp, player.max_hp)
	if "current_exp" in player and "exp_to_next_level" in player:
		_on_player_exp_changed(player.current_exp, player.exp_to_next_level)
	if "level" in player and level_label:
		level_label.text = "NEURAL Lv. " + str(player.level)

func _apply_cyber_hud_styles() -> void:
	if hp_bar:
		var sb_bg := CyberTheme.make_cyber_box(Color(0.04, 0.06, 0.12, 0.92), CyberTheme.COL_GREEN, 0.16, 2, 5, 4)
		var sb_fill := StyleBoxFlat.new()
		sb_fill.bg_color = Color(0.10, 0.95, 0.50, 0.95)
		sb_fill.skew = Vector2(0.16, 0.0)
		hp_bar.add_theme_stylebox_override("background", sb_bg)
		hp_bar.add_theme_stylebox_override("fill", sb_fill)
		var hp_lbl := hp_bar.get_node_or_null("HPLabel") as Label
		if hp_lbl:
			hp_lbl.text = "SYS.HP //"
			CyberTheme.style_label(hp_lbl, Color.WHITE, 3)

	if exp_bar:
		var sb_bg := CyberTheme.make_cyber_box(Color(0.04, 0.06, 0.12, 0.92), CyberTheme.COL_CYAN, 0.16, 1, 5, 4)
		var sb_fill := StyleBoxFlat.new()
		sb_fill.bg_color = CyberTheme.COL_CYAN
		sb_fill.skew = Vector2(0.16, 0.0)
		exp_bar.add_theme_stylebox_override("background", sb_bg)
		exp_bar.add_theme_stylebox_override("fill", sb_fill)
		if level_label:
			CyberTheme.style_label(level_label, CyberTheme.COL_YELLOW, 3)

	if boss_hp_bar:
		var sb_bg := CyberTheme.make_cyber_box(Color(0.08, 0.03, 0.08, 0.95), CyberTheme.COL_MAGENTA, 0.12, 2, 6, 8)
		var sb_fill := StyleBoxFlat.new()
		sb_fill.bg_color = CyberTheme.COL_MAGENTA
		sb_fill.skew = Vector2(0.12, 0.0)
		boss_hp_bar.add_theme_stylebox_override("background", sb_bg)
		boss_hp_bar.add_theme_stylebox_override("fill", sb_fill)
		if boss_hp_label:
			CyberTheme.style_label(boss_hp_label, CyberTheme.COL_YELLOW, 4)

	if room_label:
		CyberTheme.style_label(room_label, CyberTheme.COL_YELLOW, 3)

	if btn_pause:
		btn_pause.texture_normal = null
		var pause_bg := PanelContainer.new()
		pause_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pause_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		pause_bg.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.06, 0.09, 0.18, 0.95), CyberTheme.COL_YELLOW, -0.10, 2, 6, 6))
		btn_pause.add_child(pause_bg)
		btn_pause.move_child(pause_bg, 0)
		var p_lbl := btn_pause.get_node_or_null("Label") as Label
		if p_lbl:
			p_lbl.text = "// PAUSA"
			CyberTheme.style_label(p_lbl, CyberTheme.COL_YELLOW, 3)

	if pause_overlay:
		pause_overlay.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.02, 0.03, 0.07, 0.94), CyberTheme.COL_CYAN, 0.0, 2, 6, 12))
		CyberTheme.apply_recursive_cyber_style(pause_overlay)

func show_boss_bar(boss_name: String, max_hp: int) -> void:
	if boss_container: boss_container.show()
	if boss_hp_label: boss_hp_label.text = boss_name
	if boss_hp_bar:
		boss_hp_bar.max_value = max_hp
		boss_hp_bar.value = max_hp

func update_boss_hp(current: int, max_val: int) -> void:
	if boss_hp_bar:
		boss_hp_bar.max_value = max_val
		boss_hp_bar.value = max(0, current)

func hide_boss_bar() -> void:
	if boss_container: boss_container.hide()

func _on_player_hp_changed(current: int, max_val: int) -> void:
	if hp_bar:
		hp_bar.max_value = max_val
		hp_bar.value = current

func _on_player_exp_changed(current: int, max_val: int) -> void:
	if exp_bar:
		exp_bar.max_value = max_val
		exp_bar.value = current

func _on_player_leveled_up(new_level: int) -> void:
	if level_label:
		level_label.text = "NEURAL Lv. " + str(new_level)

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
