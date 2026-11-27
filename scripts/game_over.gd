extends CanvasLayer

@onready var panel: PanelContainer = get_node_or_null("Control/PanelContainer") as PanelContainer
@onready var btn_retry: Button = $Control/PanelContainer/VBoxContainer/BtnRetry
@onready var btn_menu: Button = $Control/PanelContainer/VBoxContainer/BtnMenu
@onready var stats_label: Label = $Control/PanelContainer/VBoxContainer/StatsLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SoundFX.play_gameover()

	if panel:
		panel.custom_minimum_size = Vector2(540, 440)
		panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(20, 18, Color(1.12, 0.86, 0.96, 1.0)))
	CyberTheme.apply_recursive_cyber_style(self)

	Global.quest_runs += 1
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"): ss.save_game()

	if stats_label:
		var current_room: int = 1
		var spawners := get_tree().get_nodes_in_group("spawner")
		if not spawners.is_empty() and "current_room" in spawners[0]:
			current_room = spawners[0].current_room

		stats_label.text = "// NEURAL-LINK INTERROTTO //\n\nZona Raggiunta: " + str(current_room) + "\nCrediti Recuperati: +" + str(Global.run_coins) + "\nNuclei Estratti: +" + str(Global.run_scrolls) + "\n\nSaldo: " + str(Global.total_coins) + "¢  •  " + str(Global.total_credits) + "◆"
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_label.add_theme_font_size_override("font_size", 19)
		CyberTheme.style_label(stats_label, CyberTheme.COL_CYAN, 3)

	if btn_retry:
		btn_retry.custom_minimum_size = Vector2(0, 60)
		btn_retry.text = "RIAVVIA INCURSIONE »"
		CyberTheme.style_button(btn_retry, CyberTheme.COL_YELLOW, true)
		btn_retry.pressed.connect(_on_btn_retry_pressed)
	if btn_menu:
		btn_menu.custom_minimum_size = Vector2(0, 56)
		btn_menu.text = "RIENTRA ALLA BASE"
		CyberTheme.style_button(btn_menu, CyberTheme.COL_CYAN, false)
		btn_menu.pressed.connect(_on_btn_menu_pressed)

func _on_btn_retry_pressed() -> void:
	SoundFX.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_btn_menu_pressed() -> void:
	SoundFX.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
