extends Node2D

var anim_t: float = 0.0
var blessing_claimed: bool = false
var modal_layer: CanvasLayer = null

func _ready() -> void:
	add_to_group("obstacles") # Viene ripulito automaticamente al cambio stanza
	z_index = 5
	# Mostra il terminale di scelta dopo un breve istante dall'ingresso nella stanza
	get_tree().create_timer(0.45).timeout.connect(_open_sanctuary_modal)

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

func _draw() -> void:
	var pulse := 0.75 + 0.25 * sin(anim_t * 4.0)
	var bob := sin(anim_t * 2.8) * 6.0

	# Cerchi olografici sul pavimento del Santuario
	draw_circle(Vector2(0, 34), 68.0, Color(0.0, 0.95, 1.0, 0.10 * pulse))
	draw_arc(Vector2(0, 34), 68.0, anim_t * 0.8, anim_t * 0.8 + PI * 1.6, 36, Color(0.0, 0.95, 1.0, 0.75), 2.5)
	draw_arc(Vector2(0, 34), 52.0, -anim_t * 1.2, -anim_t * 1.2 + PI * 1.4, 32, Color(1.0, 0.88, 0.25, 0.80), 2.0)

	# Modello 3D-Shaded Cyber-Valchiria / Angelo Custode
	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/sanctuary_angel.png")
	if tex:
		var rect := Rect2(Vector2(-68, -82 + bob), Vector2(136, 136))
		draw_texture_rect(tex, rect, false)
	else:
		draw_circle(Vector2(0, bob), 32.0, Color(0.2, 1.0, 0.7, 0.85))

	# Fascio di luce ascensionale
	draw_rect(Rect2(Vector2(-28, -140), Vector2(56, 170)), Color(0.2, 1.0, 0.85, 0.07 * pulse), true)

func _open_sanctuary_modal() -> void:
	if blessing_claimed or not is_inside_tree():
		return

	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty() or not (players[0] is Node2D):
		return
	var player := players[0] as Node2D

	SoundFX.play_pickup()
	get_tree().paused = true

	modal_layer = CanvasLayer.new()
	modal_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	modal_layer.layer = 25
	add_child(modal_layer)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.01, 0.025, 0.06, 0.88)
	modal_layer.add_child(overlay)

	var center_box := CenterContainer.new()
	center_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center_box)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 520)
	panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.03, 0.06, 0.14, 0.98), CyberTheme.COL_CYAN, 0.03, 2, 10, 16))
	center_box.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var lbl_hdr := Label.new()
	lbl_hdr.text = "// 👼 SANTUARIO CYBER-VALCHIRIA //"
	lbl_hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hdr.add_theme_font_size_override("font_size", 22)
	CyberTheme.style_label(lbl_hdr, CyberTheme.COL_YELLOW, 4)
	vbox.add_child(lbl_hdr)

	var lbl_sub := Label.new()
	lbl_sub.text = "Tregua Tattica: Scegli una Riparazione Nanobot oppure un Potenziamento Minore"
	lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_sub.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(lbl_sub, CyberTheme.COL_CYAN, 2)
	vbox.add_child(lbl_sub)

	# Icona 3D Valchiria al centro del modal
	var holo_ctrl := Control.new()
	holo_ctrl.custom_minimum_size = Vector2(0, 130)
	holo_ctrl.draw.connect(func():
		var t := CyberTheme.get_model_texture("res://assets/cyber_models/sanctuary_angel.png")
		if t:
			holo_ctrl.draw_texture_rect(t, Rect2(Vector2(holo_ctrl.size.x * 0.5 - 62, 4), Vector2(124, 124)), false)
	)
	vbox.add_child(holo_ctrl)

	# Estrai un potere minore casuale
	var minor_powers := [
		{"id": "minor_dmg", "title": "⚔️ OVERCLOCK OFFENSIVO", "desc": "+6 Danno d'Attacco Base\nper tutta la partita", "col": CyberTheme.COL_YELLOW},
		{"id": "minor_spd", "title": "⚡ REATTORE CINETICO", "desc": "+12% Velocità di Fuoco\ne +20 Velocità Movimento", "col": CyberTheme.COL_CYAN},
		{"id": "minor_maxhp", "title": "🛡️ CORAZZA BIO-TITANIO", "desc": "+35 HP Massimi Istantanei\n+ Riparazione +35 HP", "col": CyberTheme.COL_MAGENTA}
	]
	var chosen_power: Dictionary = minor_powers[randi() % minor_powers.size()]

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 18)
	vbox.add_child(hbox)

	# Scelta 1: Cura HP (Stile Archero)
	var heal_amt: int = int(max(40.0, float(player.max_hp) * 0.45)) if "max_hp" in player else 50
	var btn_heal := Button.new()
	btn_heal.custom_minimum_size = Vector2(270, 170)
	btn_heal.text = "💚 CURA NANOBOT\n\nRipristina subito\n+" + str(heal_amt) + " HP (45% Max HP)\n[HP Attuali: " + str(player.current_hp) + "/" + str(player.max_hp) + "]"
	btn_heal.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_button(btn_heal, CyberTheme.COL_GREEN, true)
	btn_heal.pressed.connect(func():
		blessing_claimed = true
		if is_instance_valid(player) and "current_hp" in player and "max_hp" in player:
			player.current_hp = min(player.max_hp, player.current_hp + heal_amt)
			if player.has_signal("hp_changed"):
				player.hp_changed.emit(player.current_hp, player.max_hp)
			var vfx: Node = get_node_or_null("/root/VFXManager")
			if vfx and vfx.has_method("spawn_floating_text"):
				vfx.spawn_floating_text(player.global_position, "💚 +" + str(heal_amt) + " HP RIPRISTINATI!", CyberTheme.COL_GREEN)
		SoundFX.play_win()
		get_tree().paused = false
		modal_layer.queue_free()
	)
	hbox.add_child(btn_heal)

	# Scelta 2: Potere Minore
	var btn_pow := Button.new()
	btn_pow.custom_minimum_size = Vector2(270, 170)
	btn_pow.text = str(chosen_power["title"]) + "\n\nPOTERE MINORE:\n" + str(chosen_power["desc"])
	btn_pow.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_button(btn_pow, chosen_power["col"], true)
	btn_pow.pressed.connect(func():
		blessing_claimed = true
		if is_instance_valid(player):
			var pid: String = str(chosen_power["id"])
			if pid == "minor_dmg" and "bonus_damage" in player:
				player.bonus_damage += 6
			elif pid == "minor_spd":
				if "fire_rate" in player:
					player.fire_rate = max(0.08, player.fire_rate * 0.88)
					if "shoot_timer" in player and player.shoot_timer:
						player.shoot_timer.wait_time = player.fire_rate
				if "speed" in player:
					player.speed += 20.0
			elif pid == "minor_maxhp" and "max_hp" in player and "current_hp" in player:
				player.max_hp += 35
				player.current_hp = min(player.max_hp, player.current_hp + 35)
				if player.has_signal("hp_changed"):
					player.hp_changed.emit(player.current_hp, player.max_hp)
			var vfx: Node = get_node_or_null("/root/VFXManager")
			if vfx and vfx.has_method("spawn_floating_text"):
				vfx.spawn_floating_text(player.global_position, "⚡ " + str(chosen_power["title"]) + "!", chosen_power["col"])
		SoundFX.play_win()
		get_tree().paused = false
		modal_layer.queue_free()
	)
	hbox.add_child(btn_pow)
