extends CanvasLayer

@onready var panel: PanelContainer = $Control/PanelContainer
@onready var icon_label: Label = $Control/PanelContainer/VBox/IconLabel
@onready var title_label: Label = $Control/PanelContainer/VBox/TitleLabel
@onready var amount_label: Label = $Control/PanelContainer/VBox/AmountLabel

func show_reward(_icon_str: String, title_text: String, amount_text: String) -> void:
	if panel:
		panel.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("LEGENDARY", 16, 14))
		var vbox := panel.get_node_or_null("VBox") as VBoxContainer
		if vbox and not vbox.get_node_or_null("Reward3DIcon"):
			var tr := TextureRect.new()
			tr.name = "Reward3DIcon"
			tr.custom_minimum_size = Vector2(72, 72)
			tr.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			var ico_key := "gift"
			if "GEMM" in amount_text.to_upper(): ico_key = "gem"
			elif "MONET" in amount_text.to_upper() or "ORO" in amount_text.to_upper(): ico_key = "coin"
			tr.texture = CyberTheme.get_ui_icon(ico_key)
			vbox.add_child(tr)
			vbox.move_child(tr, 0)
	if icon_label:
		icon_label.visible = false
	if title_label:
		title_label.text = "// " + title_text + " //"
		CyberTheme.style_label(title_label, CyberTheme.COL_CYAN, 3)
	if amount_label:
		amount_label.text = amount_text
		CyberTheme.style_label(amount_label, CyberTheme.COL_YELLOW, 3)

	if panel:
		panel.pivot_offset = Vector2(140, 100)
		panel.scale = Vector2.ZERO
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(panel, "scale", Vector2.ONE, 0.35)

	await get_tree().create_timer(1.6).timeout
	if is_instance_valid(self):
		var tw_out := create_tween()
		tw_out.tween_property(panel, "modulate:a", 0.0, 0.3)
		tw_out.tween_callback(queue_free)
