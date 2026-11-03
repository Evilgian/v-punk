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
		panel.custom_minimum_size = Vector2(610, 660)
		panel.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("LEGENDARY", 18, 16))
	CyberTheme.apply_recursive_cyber_style(self)

	var rew: Dictionary = Global.last_run_rewards
	var w_name: String = str(rew.get("world_name", "SETTORE COMPLETATO"))
	var c_amt: int = int(rew.get("coins", 600))
	var g_amt: int = int(rew.get("gems", 200))
	var s_amt: int = int(rew.get("scrolls", 5))
	var unl_w: int = int(rew.get("unlocked_world", 0))
	var items: Array = rew.get("items", []) as Array

	var txt := "🏆 " + w_name.to_upper() + " COMPLETATO!\n\n"
	txt += "PREMI DI TRIONFO SETTORE:\n"
	txt += "• +" + str(c_amt) + " 🪙 Crediti Cyber   • +" + str(g_amt) + " 💎 Gemme\n"
	txt += "• +" + str(s_amt) + " ⚙️ Nuclei Potenziamento\n"

	if unl_w > 0:
		txt += "\n🔓 NUOVO SETTORE SBLOCCATO: MONDO 0" + str(unl_w) + "!"

	if reward_label:
		reward_label.text = txt
		reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_label.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(reward_label, CyberTheme.COL_CYAN, 3)

	# Visualizza le Card 3D degli equipaggiamenti vinti con il VERO colore di Rarità!
	var vbox := panel.get_node_or_null("VBoxContainer") as VBoxContainer if panel else null
	if vbox and not items.is_empty():
		var hbox := HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 18)
		var card_idx: int = 0
		for it in items:
			if it is Dictionary:
				var iid := str(it.get("id", "kevlar"))
				var isl := str(it.get("slot", "CORAZZA"))
				var iname := str(it.get("name", "Oggetto"))
				var irar := str(it.get("rarity", "COMMON"))
				var rcol := CyberTheme.get_rarity_color(irar)

				var item_card := PanelContainer.new()
				item_card.custom_minimum_size = Vector2(235, 168)
				item_card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(irar, 10, 8))

				var cv := VBoxContainer.new()
				cv.alignment = BoxContainer.ALIGNMENT_CENTER
				cv.add_theme_constant_override("separation", 4)
				item_card.add_child(cv)

				var r_lbl := Label.new()
				r_lbl.text = CyberTheme.get_rarity_badge_text(irar)
				r_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				r_lbl.add_theme_font_size_override("font_size", 12)
				CyberTheme.style_label(r_lbl, rcol, 3)
				cv.add_child(r_lbl)

				var icon_c := Control.new()
				icon_c.custom_minimum_size = Vector2(96, 86)
				icon_c.draw.connect(func():
					CyberTheme.draw_item_icon(icon_c, Vector2(icon_c.size.x * 0.5, 43), iid, isl, rcol, 80.0)
				)
				cv.add_child(icon_c)

				var n_lbl := Label.new()
				n_lbl.text = iname
				n_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				n_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				n_lbl.add_theme_font_size_override("font_size", 13)
				CyberTheme.style_label(n_lbl, rcol, 3)
				cv.add_child(n_lbl)

				hbox.add_child(item_card)
				item_card.pivot_offset = Vector2(118, 84)
				item_card.scale = Vector2.ZERO
				var tw_c := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tw_c.tween_property(item_card, "scale", Vector2.ONE, 0.36).set_delay(0.24 + float(card_idx) * 0.16)
				card_idx += 1
		vbox.add_child(hbox)
		if reward_label:
			vbox.move_child(hbox, reward_label.get_index() + 1)

	if panel:
		panel.pivot_offset = Vector2(305, 330)
		panel.scale = Vector2(0.76, 0.76)
		panel.modulate = Color(1, 1, 1, 0.0)
		var tw_p := create_tween().set_parallel(true)
		tw_p.tween_property(panel, "scale", Vector2.ONE, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_p.tween_property(panel, "modulate:a", 1.0, 0.28)

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
