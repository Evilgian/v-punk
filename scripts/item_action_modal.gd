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
	var is_eq: bool = im.is_item_equipped(str(item_data.get("id", ""))) if (im and im.has_method("is_item_equipped")) else false

	if panel:
		panel.custom_minimum_size = Vector2(460, 420)
		panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.04, 0.06, 0.13, 0.98), CyberTheme.COL_CYAN, 0.05, 2, 8, 14))
		var vbox := panel.get_node_or_null("VBox") as VBoxContainer
		if vbox:
			var old_m := vbox.get_node_or_null("Modal3DModel")
			if old_m: old_m.queue_free()
			var m_ctrl := Control.new()
			m_ctrl.name = "Modal3DModel"
			m_ctrl.custom_minimum_size = Vector2(0, 150)
			m_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var iid: String = str(item_data.get("id", "pistol_base"))
			var islot: String = str(item_data.get("slot", "ARMA"))
			m_ctrl.draw.connect(func():
				CyberTheme.draw_item_icon(m_ctrl, Vector2(m_ctrl.size.x * 0.5, 75.0), iid, islot, CyberTheme.COL_CYAN, 136.0)
			)
			vbox.add_child(m_ctrl)
			vbox.move_child(m_ctrl, 1)
	CyberTheme.apply_recursive_cyber_style(self)

	if item_title:
		item_title.text = "// " + str(item_data.get("name", "Oggetto")).to_upper() + " //"
		CyberTheme.style_label(item_title, CyberTheme.COL_YELLOW, 3)
	if item_info:
		item_info.text = "SLOT: " + str(item_data.get("slot", "ARMA")) + " | RARITÀ: " + str(item_data.get("rarity", "COMMON"))
		CyberTheme.style_label(item_info, CyberTheme.COL_CYAN, 3)
	if item_desc:
		item_desc.text = "Modulo Cyberware compatibile con l'esoscheletro V-Punk."

	if btn_action:
		if is_eq:
			btn_action.text = "DISEQUIPAGGIA"
			CyberTheme.style_button(btn_action, CyberTheme.COL_MAGENTA, false)
		else:
			btn_action.text = "EQUIPAGGIA"
			CyberTheme.style_button(btn_action, CyberTheme.COL_YELLOW, true)

		btn_action.pressed.connect(func():
			if im:
				if is_eq:
					im.unequip_item(str(item_data.get("slot", "ARMA")))
				else:
					im.equip_item(str(item_data.get("id", "")), str(item_data.get("slot", "ARMA")))
			SoundFX.play_pickup()
			action_completed.emit()
			queue_free()
		)

	if btn_close:
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
