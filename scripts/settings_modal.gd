extends CanvasLayer

signal settings_closed()
signal open_character_creator_requested()

var show_char_creator_btn: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30
	_build_ui()

func _build_ui() -> void:
	for c in get_children():
		c.queue_free()

	var root_ctrl := Control.new()
	add_child(root_ctrl)
	root_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var overlay := ColorRect.new()
	overlay.color = Color(0.015, 0.02, 0.05, 0.94)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ctrl.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	root_ctrl.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.04, 0.06, 0.13, 0.98), CyberTheme.COL_CYAN, 0.02, 2, 10, 16))
	margin.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Header
	var lbl_title := Label.new()
	lbl_title.text = "// ⚙️ IMPOSTAZIONI DI SISTEMA [" + Global.GAME_VERSION + "] //"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 21)
	CyberTheme.style_label(lbl_title, CyberTheme.COL_YELLOW, 4)
	vbox.add_child(lbl_title)

	var lbl_sub := Label.new()
	lbl_sub.text = "Configura Audio, Cloud Save Google Play e Telemetria Operativo"
	lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_sub.add_theme_font_size_override("font_size", 13)
	CyberTheme.style_label(lbl_sub, CyberTheme.COL_CYAN, 2)
	vbox.add_child(lbl_sub)

	# --- SEZIONE 1: AUDIO (SFX & MUSICA) ---
	var audio_card := PanelContainer.new()
	audio_card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.06, 0.09, 0.18, 0.95), CyberTheme.COL_CYAN, 0.03, 2, 6, 8))
	vbox.add_child(audio_card)

	var audio_vbox := VBoxContainer.new()
	audio_vbox.add_theme_constant_override("separation", 12)
	audio_card.add_child(audio_vbox)

	var lbl_audio_hdr := Label.new()
	lbl_audio_hdr.text = "🔊 MIXER AUDIO CYBERDECK"
	lbl_audio_hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_audio_hdr.add_theme_font_size_override("font_size", 16)
	CyberTheme.style_label(lbl_audio_hdr, CyberTheme.COL_YELLOW, 3)
	audio_vbox.add_child(lbl_audio_hdr)

	# Controllo Volume SFX
	audio_vbox.add_child(_create_volume_row(
		"EFFETTI SONORI (SFX)",
		Global.sfx_volume,
		CyberTheme.COL_CYAN,
		func(new_val: float):
			Global.sfx_volume = clampf(new_val, 0.0, 1.0)
			if SoundFX and SoundFX.has_method("apply_volume_settings"):
				SoundFX.apply_volume_settings()
			SoundFX.play_click()
			Global.save_data()
			_build_ui()
	))

	# Controllo Volume Musica Synth
	audio_vbox.add_child(_create_volume_row(
		"MUSICA SYNTH AMBIENTALE",
		Global.music_volume,
		CyberTheme.COL_MAGENTA,
		func(new_val: float):
			Global.music_volume = clampf(new_val, 0.0, 1.0)
			if SoundFX and SoundFX.has_method("apply_volume_settings"):
				SoundFX.apply_volume_settings()
			SoundFX.play_click()
			Global.save_data()
			_build_ui()
	))

	# --- SEZIONE 2: GOOGLE PLAY GAMES & CLOUD ---
	var google_card := PanelContainer.new()
	google_card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.05, 0.10, 0.16, 0.96), CyberTheme.COL_GREEN if Global.google_account_linked else CyberTheme.COL_YELLOW, 0.03, 2, 6, 8))
	vbox.add_child(google_card)

	var g_vbox := VBoxContainer.new()
	g_vbox.add_theme_constant_override("separation", 10)
	google_card.add_child(g_vbox)

	var lbl_g_hdr := Label.new()
	lbl_g_hdr.text = "🎮 GOOGLE PLAY GAMES & SALVATAGGIO CLOUD"
	lbl_g_hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_g_hdr.add_theme_font_size_override("font_size", 16)
	CyberTheme.style_label(lbl_g_hdr, CyberTheme.COL_GREEN if Global.google_account_linked else CyberTheme.COL_YELLOW, 3)
	g_vbox.add_child(lbl_g_hdr)

	var lbl_g_status := Label.new()
	if Global.google_account_linked:
		var acc_name := Global.google_account_name if not Global.google_account_name.is_empty() else (Global.player_name + "@playgames")
		lbl_g_status.text = "✅ STATO: COLLEGATO (" + acc_name + ")\nSincronizzazione automatica dei progressi attiva."
		CyberTheme.style_label(lbl_g_status, CyberTheme.COL_GREEN, 2)
	else:
		lbl_g_status.text = "⚪ STATO: ACCOUNT GOOGLE NON COLLEGATO\nI tuoi progressi sono salvati nella memoria locale del dispositivo."
		CyberTheme.style_label(lbl_g_status, Color(0.85, 0.92, 1.0, 1.0), 2)
	lbl_g_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_g_status.add_theme_font_size_override("font_size", 13)
	g_vbox.add_child(lbl_g_status)

	var btn_google := Button.new()
	btn_google.custom_minimum_size = Vector2(460, 54)
	btn_google.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_google.add_theme_font_size_override("font_size", 15)
	if Global.google_account_linked:
		btn_google.text = "☁️ SINCRONIZZA ORA / SCOLLEGA GOOGLE PLAY"
		CyberTheme.style_button(btn_google, CyberTheme.COL_CYAN, false)
	else:
		btn_google.text = "🔗 COLLEGA ACCOUNT GOOGLE PLAY GAMES"
		CyberTheme.style_button(btn_google, CyberTheme.COL_GREEN, true)

	btn_google.pressed.connect(func():
		SoundFX.play_pickup()
		Global.google_account_linked = not Global.google_account_linked
		if Global.google_account_linked:
			var p_call := Global.player_name if not Global.player_name.is_empty() else "Operativo"
			Global.google_account_name = p_call + " (Google Play ID #" + str(1000 + randi() % 8999) + ")"
		else:
			Global.google_account_name = ""
		Global.save_data()
		_build_ui()
	)
	g_vbox.add_child(btn_google)

	# --- SEZIONE 3: OPZIONI GIOCO & PROFILO ---
	var opt_card := PanelContainer.new()
	opt_card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.06, 0.08, 0.16, 0.95), CyberTheme.COL_MAGENTA, 0.03, 2, 6, 8))
	vbox.add_child(opt_card)

	var opt_vbox := VBoxContainer.new()
	opt_vbox.add_theme_constant_override("separation", 10)
	opt_card.add_child(opt_vbox)

	var btn_shake := Button.new()
	btn_shake.custom_minimum_size = Vector2(460, 50)
	btn_shake.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_shake.add_theme_font_size_override("font_size", 15)
	btn_shake.text = "📳 VIBRAZIONE & SCREEN SHAKE: " + ("ATTIVO (ON)" if Global.screen_shake_enabled else "DISATTIVATO (OFF)")
	CyberTheme.style_button(btn_shake, CyberTheme.COL_CYAN if Global.screen_shake_enabled else CyberTheme.COL_MAGENTA, false)
	btn_shake.pressed.connect(func():
		SoundFX.play_click()
		Global.screen_shake_enabled = not Global.screen_shake_enabled
		Global.save_data()
		_build_ui()
	)
	opt_vbox.add_child(btn_shake)

	if show_char_creator_btn:
		var btn_char := Button.new()
		btn_char.custom_minimum_size = Vector2(460, 50)
		btn_char.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn_char.add_theme_font_size_override("font_size", 15)
		btn_char.text = "👤 CAMBIA NOME / RICREA OPERATIVO (" + Global.player_name + ")"
		CyberTheme.style_button(btn_char, CyberTheme.COL_YELLOW, false)
		btn_char.pressed.connect(func():
			SoundFX.play_click()
			open_character_creator_requested.emit()
			queue_free()
		)
		opt_vbox.add_child(btn_char)

	# Pulsante Chiudi
	var btn_close := Button.new()
	btn_close.custom_minimum_size = Vector2(360, 58)
	btn_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_close.add_theme_font_size_override("font_size", 18)
	btn_close.text = "✓ SALVA E TORNA AL GIOCO"
	CyberTheme.style_button(btn_close, CyberTheme.COL_YELLOW, true)
	btn_close.pressed.connect(func():
		SoundFX.play_click()
		Global.save_data()
		settings_closed.emit()
		queue_free()
	)
	vbox.add_child(btn_close)

func _create_volume_row(label_text: String, cur_val: float, accent: Color, on_change: Callable) -> VBoxContainer:
	var row_vbox := VBoxContainer.new()
	row_vbox.add_theme_constant_override("separation", 6)

	var pct := int(round(cur_val * 100.0))
	var lbl := Label.new()
	lbl.text = label_text + ":  " + ("MUTO (0%)" if pct == 0 else (str(pct) + "%"))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(lbl, accent, 3)
	row_vbox.add_child(lbl)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)
	row_vbox.add_child(hbox)

	var btn_mute := Button.new()
	btn_mute.custom_minimum_size = Vector2(68, 44)
	btn_mute.text = "🔇" if pct > 0 else "🔊"
	CyberTheme.style_button(btn_mute, CyberTheme.COL_MAGENTA if pct == 0 else accent, false)
	btn_mute.pressed.connect(func():
		on_change.call(0.0 if pct > 0 else 0.75)
	)
	hbox.add_child(btn_mute)

	var btn_minus := Button.new()
	btn_minus.custom_minimum_size = Vector2(68, 44)
	btn_minus.text = "➖"
	CyberTheme.style_button(btn_minus, accent, false)
	btn_minus.pressed.connect(func():
		on_change.call(max(0.0, cur_val - 0.15))
	)
	hbox.add_child(btn_minus)

	var pbar := ProgressBar.new()
	pbar.custom_minimum_size = Vector2(230, 28)
	pbar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pbar.max_value = 100
	pbar.value = pct
	pbar.show_percentage = false
	var sb_bg := CyberTheme.make_cyber_box(Color(0.02, 0.03, 0.07, 0.95), accent, 0.08, 1, 4, 2)
	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = accent
	sb_fill.skew = Vector2(0.08, 0.0)
	pbar.add_theme_stylebox_override("background", sb_bg)
	pbar.add_theme_stylebox_override("fill", sb_fill)
	hbox.add_child(pbar)

	var btn_plus := Button.new()
	btn_plus.custom_minimum_size = Vector2(68, 44)
	btn_plus.text = "➕"
	CyberTheme.style_button(btn_plus, accent, false)
	btn_plus.pressed.connect(func():
		on_change.call(min(1.0, cur_val + 0.15))
	)
	hbox.add_child(btn_plus)

	return row_vbox
