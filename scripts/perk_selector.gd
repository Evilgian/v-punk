extends CanvasLayer

var player_ref: Node2D

@onready var panel: PanelContainer = get_node_or_null("Control/PanelContainer") as PanelContainer
@onready var container: VBoxContainer = $Control/PanelContainer/VBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if panel:
		panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.03, 0.05, 0.11, 0.96), CyberTheme.COL_YELLOW, 0.04, 2, 8, 14))

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
			hdr.text = "// INSTALLA CYBERWARE //"
			CyberTheme.style_label(hdr, CyberTheme.COL_YELLOW, 4)
		else:
			child.queue_free()

	var perks: Array[PerkData] = PerkDB.get_random_perks(3)
	var colors := [CyberTheme.COL_CYAN, CyberTheme.COL_MAGENTA, CyberTheme.COL_YELLOW]

	for i in range(perks.size()):
		var perk: PerkData = perks[i]
		var col: Color = colors[i % colors.size()]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 76)
		btn.add_theme_font_size_override("font_size", 15)
		btn.text = perk.display_name + "\n" + perk.description
		CyberTheme.style_button(btn, col, false)
		btn.pressed.connect(_on_perk_selected.bind(perk.id))
		container.add_child(btn)

		btn.pivot_offset = Vector2(160, 38)
		btn.scale = Vector2.ZERO
		btn.rotation_degrees = randf_range(-3.0, 3.0)

		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.32).set_delay(i * 0.06)
		tw.parallel().tween_property(btn, "rotation_degrees", 0.0, 0.32)

func _on_perk_selected(perk_id: String) -> void:
	if player_ref:
		match perk_id:
			"front_arrow":
				if player_ref.has_method("add_extra_projectiles"):
					player_ref.add_extra_projectiles(1)
				elif "has_front_arrow" in player_ref:
					player_ref.has_front_arrow = true
			"diagonal_arrow":
				if "has_diagonal_arrow" in player_ref:
					player_ref.has_diagonal_arrow = true
			"spread_shot":
				if "has_spread_shot" in player_ref:
					player_ref.has_spread_shot = true
			"bouncy_wall":
				if "has_bouncy_wall" in player_ref:
					player_ref.has_bouncy_wall = true
			"piercing":
				if "has_piercing" in player_ref:
					player_ref.has_piercing = true
			"attack_speed":
				if "fire_rate" in player_ref:
					player_ref.fire_rate = max(0.08, player_ref.fire_rate * 0.8)
					if "shoot_timer" in player_ref and player_ref.shoot_timer:
						player_ref.shoot_timer.wait_time = player_ref.fire_rate
			"damage_up":
				if "bonus_damage" in player_ref:
					player_ref.bonus_damage += 8
			"heal":
				if "max_hp" in player_ref and "current_hp" in player_ref:
					player_ref.current_hp = min(player_ref.max_hp, player_ref.current_hp + int(player_ref.max_hp * 0.35))
					if player_ref.has_signal("hp_changed"):
						player_ref.hp_changed.emit(player_ref.current_hp, player_ref.max_hp)

	SoundFX.play_pickup()
	get_tree().paused = false
	queue_free()
