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
		panel.custom_minimum_size = Vector2(580, 620)
		panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.03, 0.06, 0.12, 0.98), CyberTheme.COL_YELLOW, 0.04, 2, 8, 16))
	CyberTheme.apply_recursive_cyber_style(self)

	var rew: Dictionary = Global.last_run_rewards
	var w_name: String = str(rew.get("world_name", "SETTORE COMPLETATO"))
	var c_amt: int = int(rew.get("coins", 600))
	var g_amt: int = int(rew.get("gems", 200))
	var s_amt: int = int(rew.get("scrolls", 5))
	var unl_w: int = int(rew.get("unlocked_world", 0))
	var items: Array = rew.get("items", []) as Array

	var txt := "// " + w_name.to_upper() + " COMPLETATO! //\n\n"
	txt += "🏆 PREMI DI COMPLETAMENTO MONDO:\n"
	txt += "• +" + str(c_amt) + " 🪙 Crediti Cyber\n"
	txt += "• +" + str(g_amt) + " 💎 Cyber-Gemme\n"
	txt += "• +" + str(s_amt) + " ⚙️ Nuclei Potenziamento\n"

	if not items.is_empty():
		txt += "\n🎁 EQUIPAGGIAMENTO OTTENUTO:\n"
		for it in items:
			if it is Dictionary:
				txt += "★ " + str(it.get("name", "Oggetto")) + " [" + str(it.get("slot", "")) + " - " + str(it.get("rarity", "COMMON")) + "]\n"

	if unl_w > 0:
		txt += "\n🔓 NUOVO SETTORE SBLOCCATO: MONDO 0" + str(unl_w) + "!"

	if reward_label:
		reward_label.text = txt
		CyberTheme.style_label(reward_label, CyberTheme.COL_CYAN, 3)

	# Visualizza i modelli 3D degli equipaggiamenti vinti
	var vbox := panel.get_node_or_null("VBoxContainer") as VBoxContainer if panel else null
	if vbox and not items.is_empty():
		var hbox := HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 20)
		for it in items:
			if it is Dictionary:
				var icon_c := Control.new()
				icon_c.custom_minimum_size = Vector2(110, 110)
				var iid := str(it.get("id", "kevlar"))
				var isl := str(it.get("slot", "CORAZZA"))
				icon_c.draw.connect(func():
					CyberTheme.draw_item_icon(icon_c, Vector2(55, 55), iid, isl, CyberTheme.COL_YELLOW, 96.0)
				)
				hbox.add_child(icon_c)
		vbox.add_child(hbox)
		if reward_label:
			vbox.move_child(hbox, reward_label.get_index() + 1)

	if btn_retry:
		btn_retry.text = "▶ AVVIA PROSSIMO MONDO" if unl_w > 0 else "🔄 RIGIOCA SETTORE"
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
