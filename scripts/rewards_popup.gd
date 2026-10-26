extends CanvasLayer

@onready var panel: PanelContainer = $Control/PanelContainer
@onready var icon_label: Label = $Control/PanelContainer/VBox/IconLabel
@onready var title_label: Label = $Control/PanelContainer/VBox/TitleLabel
@onready var amount_label: Label = $Control/PanelContainer/VBox/AmountLabel

func show_reward(icon_str: String, title_text: String, amount_text: String) -> void:
	if panel:
		panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.04, 0.07, 0.15, 0.98), CyberTheme.COL_YELLOW, 0.06, 2, 8, 16))
	if icon_label: icon_label.text = icon_str
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
