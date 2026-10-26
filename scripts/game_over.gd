extends CanvasLayer

@onready var panel: PanelContainer = get_node_or_null("Control/PanelContainer") as PanelContainer
@onready var btn_retry: Button = $Control/PanelContainer/VBoxContainer/BtnRetry
@onready var btn_menu: Button = $Control/PanelContainer/VBoxContainer/BtnMenu
@onready var stats_label: Label = $Control/PanelContainer/VBoxContainer/StatsLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SoundFX.play_gameover()

	if panel:
		panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.06, 0.02, 0.06, 0.96), CyberTheme.COL_MAGENTA, 0.04, 2, 8, 16))
	CyberTheme.apply_recursive_cyber_style(self)

	Global.quest_runs += 1
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"): ss.save_game()

	if stats_label:
		var current_room: int = 1
		var spawners := get_tree().get_nodes_in_group("spawner")
		if not spawners.is_empty() and "current_room" in spawners[0]:
			current_room = spawners[0].current_room

		stats_label.text = "// SYSTEM FAILURE: FLATLINED //\n\nSettore Raggiunto: Stage " + str(current_room) + "\nCrediti Totali: 🪙 " + str(Global.total_coins) + "\nCyber-Gemme: 💎 " + str(Global.total_credits)

	if btn_retry:
		CyberTheme.style_button(btn_retry, CyberTheme.COL_YELLOW, true)
		btn_retry.pressed.connect(_on_btn_retry_pressed)
	if btn_menu:
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
