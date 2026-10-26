extends CanvasLayer

@onready var panel: PanelContainer = get_node_or_null("Control/PanelContainer") as PanelContainer
@onready var btn_retry: Button = $Control/PanelContainer/VBoxContainer/BtnRetry
@onready var btn_menu: Button = $Control/PanelContainer/VBoxContainer/BtnMenu
@onready var reward_label: Label = $Control/PanelContainer/VBoxContainer/RewardLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	SoundFX.play_win()

	if panel:
		panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.03, 0.06, 0.12, 0.96), CyberTheme.COL_YELLOW, 0.04, 2, 8, 16))
	CyberTheme.apply_recursive_cyber_style(self)

	Global.total_credits += 150
	Global.total_coins += 500
	Global.quest_runs += 1
	var ss: Node = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("save_game"): ss.save_game()

	if reward_label:
		reward_label.text = "// PROTOCOLLO COMPLETATO //\n\nRICOMPENSA SETTORE:\n+150 💎 Cyber-Gemme\n+500 🪙 Crediti"

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
