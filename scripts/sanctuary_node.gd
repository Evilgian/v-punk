extends Node2D

const TRIGGER_RADIUS: float = 122.0

var anim_t: float = 0.0
var blessing_claimed: bool = false
var modal_layer: CanvasLayer = null

func _ready() -> void:
	add_to_group("obstacles") # Viene ripulito automaticamente al cambio stanza
	z_index = 5

func _process(delta: float) -> void:
	anim_t += delta
	if not blessing_claimed and modal_layer == null and not get_tree().paused:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty() and players[0] is Node2D:
			var p := players[0] as Node2D
			if p.global_position.distance_to(global_position + Vector2(0, 22)) <= TRIGGER_RADIUS:
				_open_sanctuary_modal()
	queue_redraw()

func _draw() -> void:
	var pulse := 0.75 + 0.25 * sin(anim_t * 4.0)
	var bob := sin(anim_t * 2.8) * 6.0

	# Frecce guida olografiche sul pavimento dall'Eroe fino all'Altare della Valchiria (finché non viene attivata)
	if not blessing_claimed:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty() and players[0] is Node2D:
			var p_local := to_local((players[0] as Node2D).global_position) + Vector2(0, -16)
			var target_local := Vector2(0, 34)
			var dist := p_local.distance_to(target_local)
			if dist > TRIGGER_RADIUS * 0.9:
				var dir := (target_local - p_local).normalized()
				var perp := Vector2(-dir.y, dir.x)
				var steps: int = clampi(int(dist / 64.0), 2, 10)
				for i in range(steps):
					var wave: float = fmod(anim_t * 2.8 - float(i) * 0.32, 1.0)
					if wave < 0.0: wave += 1.0
					var a_ch: float = 0.22 + 0.68 * sin(wave * PI)
					var cp := p_local.lerp(target_local, float(i + 1) / float(steps + 1))
					var tip := cp + dir * 13.0
					var lw := cp - dir * 8.0 + perp * 15.0
					var rw := cp - dir * 8.0 - perp * 15.0
					draw_polyline(PackedVector2Array([lw, tip, rw]), Color(0.15, 0.96, 1.0, a_ch), 3.8)
					draw_polyline(PackedVector2Array([lw, tip, rw]), Color(1.0, 1.0, 1.0, a_ch * 0.75), 1.4)

	# Pedana Altare 3D in prospettiva + Zona di Attivazione Prossimità
	draw_set_transform(Vector2(0, 30), 0.0, Vector2(1.0, 0.48))
	if not blessing_claimed:
		draw_circle(Vector2.ZERO, TRIGGER_RADIUS, Color(0.0, 0.94, 1.0, 0.09 * pulse))
		draw_arc(Vector2.ZERO, TRIGGER_RADIUS, 0.0, TAU, 48, Color(0.25, 0.96, 1.0, 0.55 * pulse), 2.6)
	draw_circle(Vector2.ZERO, 76.0, Color(0.08, 0.14, 0.26, 0.92))
	draw_arc(Vector2.ZERO, 76.0, anim_t * 0.8, anim_t * 0.8 + PI * 1.6, 36, Color(0.0, 0.95, 1.0, 0.90), 3.2)
	draw_arc(Vector2.ZERO, 56.0, -anim_t * 1.2, -anim_t * 1.2 + PI * 1.4, 32, Color(1.0, 0.88, 0.25, 0.90), 2.4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Fascio di luce volumetrica ascensionale 3D
	draw_colored_polygon(PackedVector2Array([
		Vector2(-52, 30), Vector2(52, 30), Vector2(34, -155), Vector2(-34, -155)
	]), Color(0.18, 0.96, 1.0, (0.14 if not blessing_claimed else 0.05) * pulse))

	# Modello 3D-Shaded Cyber-Valchiria / Angelo Custode
	var tex := CyberTheme.get_model_texture("res://assets/cyber_models/sanctuary_angel.png")
	if tex:
		var rect := Rect2(Vector2(-70, -86 + bob), Vector2(140, 140))
		draw_texture_rect(tex, rect, false, Color(1.08, 1.08, 1.12, 1.0))
	else:
		draw_circle(Vector2(0, bob), 32.0, Color(0.2, 1.0, 0.7, 0.85))

	# Scritta olografica sopra la Valchiria
	var font := ThemeDB.fallback_font
	if font:
		var prompt_txt := "👼 AVVICINATI ALLA VALCHIRIA" if not blessing_claimed else "✨ BENEDIZIONE ATTIVA ✨"
		var prompt_col := CyberTheme.COL_YELLOW if not blessing_claimed else CyberTheme.COL_EQUIPPED
		draw_string(font, Vector2(-115, -96 + bob * 0.5), prompt_txt, HORIZONTAL_ALIGNMENT_CENTER, 230, 14, prompt_col)

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

	var root_ctrl := Control.new()
	modal_layer.add_child(root_ctrl)
	root_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var overlay := ColorRect.new()
	overlay.color = Color(0.01, 0.025, 0.06, 0.88)
	root_ctrl.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center_box := CenterContainer.new()
	root_ctrl.add_child(center_box)
	center_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(630, 535)
	panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(18, 16))
	center_box.add_child(panel)
	panel.pivot_offset = Vector2(315, 268)
	panel.scale = Vector2(0.82, 0.82)
	var tw_in := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_in.tween_property(panel, "scale", Vector2.ONE, 0.30)

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
		_notify_spawner_completed()
		modal_layer.queue_free()
		modal_layer = null
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
		_notify_spawner_completed()
		modal_layer.queue_free()
		modal_layer = null
	)
	hbox.add_child(btn_pow)

func _notify_spawner_completed() -> void:
	var spawners := get_tree().get_nodes_in_group("spawner")
	for sp in spawners:
		if sp.has_method("complete_sanctuary"):
			sp.complete_sanctuary()
