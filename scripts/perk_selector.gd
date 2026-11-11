extends CanvasLayer

var player_ref: Node2D

@onready var panel: PanelContainer = get_node_or_null("Control/PanelContainer") as PanelContainer
@onready var container: VBoxContainer = $Control/PanelContainer/VBoxContainer

const TYPE_LABELS := {
	"BALISTICA": "🔫 BALISTICA",
	"POTENZA": "💥 POTENZA",
	"ELEMENTALE": "🌩️ ELEMENTALE",
	"SUPPORTO": "🌀 SUPPORTO",
	"DIFESA": "🛡️ DIFESA"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if panel:
		panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(16, 14))
		# Pannello più largo e alto: 3 card grandi e leggibili
		panel.offset_left = -325.0
		panel.offset_right = 325.0
		panel.offset_top = -345.0
		panel.offset_bottom = 345.0

	if not player_ref:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player_ref = players[0] as Node2D

	_populate_perks()

func _populate_perks() -> void:
	if not container:
		return

	for child in container.get_children():
		if child is Label:
			var hdr := child as Label
			hdr.text = "⚡ LIVELLO SUPERIORE! INSTALLA CYBERWARE ⚡"
			hdr.add_theme_font_size_override("font_size", 25)
			hdr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			CyberTheme.style_label(hdr, CyberTheme.COL_YELLOW, 4)
		else:
			child.queue_free()

	var stacks: Dictionary = player_ref.perk_stacks if (player_ref and "perk_stacks" in player_ref) else {}
	var perks: Array[PerkData] = PerkDB.get_random_perks(3, player_ref)

	for i in range(perks.size()):
		var perk: PerkData = perks[i]
		var rar_col: Color = CyberTheme.get_rarity_color(perk.rarity)
		var owned: int = int(stacks.get(perk.id, 0))

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 146)
		btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_font_size_override("font_size", 19)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		var lvl_txt := ""
		if perk.max_stacks > 1 and perk.max_stacks < 99:
			lvl_txt = "   •   Lv. " + str(owned) + " ➜ " + str(owned + 1) + " / " + str(perk.max_stacks)
		elif owned == 0 and perk.max_stacks == 1:
			lvl_txt = "   •   NUOVA"
		var type_txt: String = str(TYPE_LABELS.get(perk.perk_type, perk.perk_type))
		btn.text = CyberTheme.get_rarity_badge_text(perk.rarity) + "  |  " + type_txt + lvl_txt + "\n" + perk.display_name.to_upper() + "\n" + perk.description

		var sb := CyberTheme.make_rarity_card_box(perk.rarity, 14, 10)
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", rar_col.lightened(0.4))
		btn.add_theme_color_override("font_pressed_color", rar_col.lightened(0.5))
		btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.96))
		btn.add_theme_constant_override("outline_size", 4)
		btn.pressed.connect(_on_perk_selected.bind(perk.id))
		container.add_child(btn)

		btn.pivot_offset = Vector2(300, 69)
		btn.scale = Vector2.ZERO
		btn.rotation_degrees = randf_range(-3.0, 3.0)

		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.32).set_delay(i * 0.07)
		tw.parallel().tween_property(btn, "rotation_degrees", 0.0, 0.32)

func _on_perk_selected(perk_id: String) -> void:
	if player_ref and player_ref.has_method("apply_perk"):
		player_ref.apply_perk(perk_id)

	SoundFX.play_pickup()
	get_tree().paused = false
	queue_free()
