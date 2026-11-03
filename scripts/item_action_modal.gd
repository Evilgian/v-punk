extends CanvasLayer

signal action_completed()

@onready var panel: PanelContainer = $Control/PanelContainer
@onready var item_title: Label = $Control/PanelContainer/VBox/ItemTitle
@onready var item_info: Label = $Control/PanelContainer/VBox/ItemInfo
@onready var item_desc: Label = $Control/PanelContainer/VBox/ItemDesc
@onready var btn_action: Button = $Control/PanelContainer/VBox/BtnAction
@onready var btn_close: Button = $Control/PanelContainer/VBox/BtnClose

var current_item: Dictionary = {}

func setup_item(item_data: Dictionary) -> void:
	current_item = item_data
	var im: Node = get_node_or_null("/root/InventoryManager")
	var iid: String = str(item_data.get("id", "pistol_base"))
	var islot: String = str(item_data.get("slot", "ARMA"))
	var rar_str: String = str(item_data.get("rarity", "COMMON"))
	var rar_col: Color = CyberTheme.get_rarity_color(rar_str)
	var is_eq: bool = im.is_item_equipped(iid) if (im and im.has_method("is_item_equipped")) else false
	var cur_lvl: int = im.get_item_level(iid) if (im and im.has_method("get_item_level")) else 1
	var coin_cost: int = im.get_upgrade_coin_cost(iid) if (im and im.has_method("get_upgrade_coin_cost")) else 50
	var scroll_cost: int = im.get_upgrade_scroll_cost(iid) if (im and im.has_method("get_upgrade_scroll_cost")) else 1
	var stat_desc: String = im.get_item_stat_description(iid, islot) if (im and im.has_method("get_item_stat_description")) else "Modulo Cyberware compatibile."

	if panel:
		panel.custom_minimum_size = Vector2(530, 520)
		panel.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(rar_str, 16, 14))
		var vbox := panel.get_node_or_null("VBox") as VBoxContainer
		if vbox:
			var old_m := vbox.get_node_or_null("Modal3DModel")
			if old_m: old_m.queue_free()
			var m_ctrl := Control.new()
			m_ctrl.name = "Modal3DModel"
			m_ctrl.custom_minimum_size = Vector2(0, 152)
			m_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			m_ctrl.draw.connect(func():
				CyberTheme.draw_item_icon(m_ctrl, Vector2(m_ctrl.size.x * 0.5, 74.0), iid, islot, rar_col, 136.0, is_eq)
			)
			vbox.add_child(m_ctrl)
			vbox.move_child(m_ctrl, 1)

			var old_upg := vbox.get_node_or_null("BtnUpgradeItem")
			if old_upg: old_upg.queue_free()
			var btn_upg := Button.new()
			btn_upg.name = "BtnUpgradeItem"
			btn_upg.custom_minimum_size = Vector2(0, 54)
			var can_afford := (Global.total_coins >= coin_cost and Global.upgrade_scrolls >= scroll_cost)
			btn_upg.text = "⬆️ POTENZIA A LV. " + str(cur_lvl + 1) + "  (" + str(coin_cost) + " 🪙 + " + str(scroll_cost) + " ⚙️)"
			CyberTheme.style_button(btn_upg, CyberTheme.COL_GREEN if can_afford else CyberTheme.COL_CYAN, can_afford)
			btn_upg.pressed.connect(func():
				if im and im.has_method("upgrade_item_level"):
					var res: Dictionary = im.upgrade_item_level(iid)
					if res.get("success", false):
						SoundFX.play_win()
						action_completed.emit()
						setup_item(current_item)
					else:
						SoundFX.play_hit()
						if item_desc:
							item_desc.text = str(res.get("message", "Risorse insufficienti!"))
							CyberTheme.style_label(item_desc, CyberTheme.COL_MAGENTA, 2)
			)
			vbox.add_child(btn_upg)
			if btn_action:
				vbox.move_child(btn_upg, btn_action.get_index())

	CyberTheme.apply_recursive_cyber_style(self)

	if item_title:
		item_title.text = str(item_data.get("name", "Oggetto")).to_upper() + "  [LV. " + str(cur_lvl) + "]"
		item_title.add_theme_font_size_override("font_size", 21)
		CyberTheme.style_label(item_title, rar_col, 4)
	if item_info:
		var eq_tag := "  •  ✓ INDOSSATO" if is_eq else ""
		item_info.text = "SLOT: " + islot + "  •  " + CyberTheme.get_rarity_badge_text(rar_str) + eq_tag + "\nRisorse: 🪙 " + str(Global.total_coins) + "   |   ⚙️ Nuclei: " + str(Global.upgrade_scrolls)
		item_info.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(item_info, CyberTheme.COL_EQUIPPED if is_eq else rar_col, 3)
	if item_desc:
		item_desc.text = stat_desc
		item_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_desc.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(item_desc, Color(0.92, 0.97, 1.0, 1.0), 2)

	if btn_action:
		btn_action.custom_minimum_size = Vector2(0, 56)
		btn_action.add_theme_font_size_override("font_size", 17)
		for conn in btn_action.pressed.get_connections():
			btn_action.pressed.disconnect(conn["callable"])
		if is_eq:
			btn_action.text = "✓ IN USO  (TOCCA PER RIMUOVERE)"
			CyberTheme.style_button(btn_action, CyberTheme.COL_EQUIPPED, false)
		else:
			btn_action.text = "⚡ EQUIPAGGIA ORA"
			CyberTheme.style_button(btn_action, CyberTheme.COL_CYAN, true)

		btn_action.pressed.connect(func():
			if im:
				if is_eq:
					im.unequip_item(islot)
				else:
					im.equip_item(iid, islot)
			SoundFX.play_pickup()
			action_completed.emit()
			queue_free()
		)

	if btn_close:
		for conn in btn_close.pressed.get_connections():
			btn_close.pressed.disconnect(conn["callable"])
		CyberTheme.style_button(btn_close, CyberTheme.COL_CYAN, false)
		btn_close.pressed.connect(func():
			SoundFX.play_click()
			queue_free()
		)

	if panel:
		panel.pivot_offset = Vector2(140, 110)
		panel.scale = Vector2.ZERO
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(panel, "scale", Vector2.ONE, 0.28)
