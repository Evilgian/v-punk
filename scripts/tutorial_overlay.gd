extends Node2D

# ==============================================================================
# SISTEMA TUTORIAL INTERATTIVO GUIDATO — SETTORE 01 (MONDO 1)
# Guida passo-passo il giocatore sul funzionamento completo di V-Punk:
# 1. Movimento col Joystick vs Fermarsi per il Fuoco Automatico (Stile Archero)
# 2. Aspirazione magnetica del bottino + frecce 3D luminose verso il Portale Stargate
# 3. Uso delle Coperture 3D contro i Cecchini + distruzione Casse Rifornimento
# 4. Lettura delle Trappole a Pavimento (segnale ⚠️ prima degli spuntoni)
# 5. Abilità Neurali in-run vs Officina EQUIP (Tab Potenzia Lv. & Tab Fusione 3-in-1)
# 6. Santuario Cyber-Valchiria (Livello 5) & Boss Finale (Livello 10) per sbloccare Mondo 2
# ==============================================================================

var anim_t: float = 0.0
var last_state_key: String = ""
var is_collapsed: bool = false

var ui_layer: CanvasLayer = null
var card_panel: PanelContainer = null
var step_badge_lbl: Label = null
var title_lbl: Label = null
var body_lbl: Label = null
var toggle_btn: Button = null

func _ready() -> void:
	# Disegna gli indicatori olografici 2.5D direttamente sul pavimento (sotto i personaggi grazie a z_index = -1)
	z_index = -1
	_build_hud_banner()

func _build_hud_banner() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "TutorialHUDLayer"
	ui_layer.layer = 2
	add_child(ui_layer)

	var root_ctrl := Control.new()
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(root_ctrl)
	root_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	card_panel = PanelContainer.new()
	card_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_panel.anchor_left = 0.0
	card_panel.anchor_right = 1.0
	card_panel.anchor_top = 0.0
	card_panel.anchor_bottom = 0.0
	card_panel.offset_left = 20.0
	card_panel.offset_right = -20.0
	card_panel.offset_top = 104.0
	card_panel.offset_bottom = 208.0
	card_panel.add_theme_stylebox_override(
		"panel",
		CyberTheme.make_3d_panel_box(10, 8)
	)
	root_ctrl.add_child(card_panel)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var top_row := HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_theme_constant_override("separation", 8)
	vbox.add_child(top_row)

	step_badge_lbl = Label.new()
	step_badge_lbl.text = "🎓 GUIDA OPERATIVA [1/6]"
	step_badge_lbl.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(step_badge_lbl, CyberTheme.COL_YELLOW, 3)
	top_row.add_child(step_badge_lbl)

	title_lbl = Label.new()
	title_lbl.text = "MOVIMENTO & FUOCO AUTOMATICO"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_lbl.add_theme_font_size_override("font_size", 17)
	CyberTheme.style_label(title_lbl, CyberTheme.COL_CYAN, 3)
	top_row.add_child(title_lbl)

	toggle_btn = Button.new()
	toggle_btn.custom_minimum_size = Vector2(88, 30)
	toggle_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	toggle_btn.text = "RIDUCI ▲"
	toggle_btn.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_button(toggle_btn, CyberTheme.COL_CYAN, false)
	toggle_btn.pressed.connect(func():
		SoundFX.play_click()
		is_collapsed = not is_collapsed
		if body_lbl:
			body_lbl.visible = not is_collapsed
		toggle_btn.text = "APRI ▼" if is_collapsed else "RIDUCI ▲"
		card_panel.offset_bottom = 148.0 if is_collapsed else 224.0
	)
	top_row.add_child(toggle_btn)

	body_lbl = Label.new()
	body_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_lbl.add_theme_font_size_override("font_size", 16)
	CyberTheme.style_label(body_lbl, Color(0.92, 0.96, 1.0, 1.0), 2)
	vbox.add_child(body_lbl)

func _process(delta: float) -> void:
	anim_t += delta
	_refresh_tutorial_step()
	queue_redraw()

func _get_spawner() -> Node:
	var spawners := get_tree().get_nodes_in_group("spawner")
	return spawners[0] if not spawners.is_empty() else null

func _refresh_tutorial_step() -> void:
	var sp := _get_spawner()
	if not sp:
		return
	var room: int = int(sp.current_room) if "current_room" in sp else 1
	var cleared: bool = bool(sp.room_cleared) if "room_cleared" in sp else false

	var state_key := str(room) + ("_CLEAR" if cleared else "_FIGHT")
	if state_key == last_state_key:
		return
	last_state_key = state_key

	var badge_txt := "🎓 TUTORIAL SETTORE 01"
	var head_txt := ""
	var desc_txt := ""
	var border_col := CyberTheme.COL_CYAN

	if room == 1 and not cleared:
		badge_txt = "🎓 PASSO 1/6"
		head_txt = "🕹️ MUOVITI PER SCHIVARE • FERMATI PER SPARARE!"
		desc_txt = "Trascina il dito nella metà bassa dello schermo per muoverti. Rilascia il dito e RESTA FERMO: l'eroe mirerà e sparerà in automatico al nemico più vicino!"
		border_col = CyberTheme.COL_YELLOW
	elif room == 1 and cleared:
		badge_txt = "🎓 PASSO 2/6"
		head_txt = "🧲 BOTTINO AUTOMATICO & PORTALE STARGATE"
		desc_txt = "Stanza pulita! Monete, XP e Drop vengono aspirati verso di te. Segui le frecce luminose sul pavimento fino al Portale Stargate in alto per avanzare!"
		border_col = CyberTheme.COL_GREEN
	elif room == 2 and not cleared:
		badge_txt = "🎓 PASSO 3/6"
		head_txt = "🧱 COPERTURE 3D & CASSE RIFORNIMENTO"
		desc_txt = "Riparati dietro le Torri-Server 3D per bloccare i colpi dei Droni Cecchini! Distruggi la Cassa Dorata al centro per trovare Cure, ⚙️ Nuclei o Equipaggiamenti."
		border_col = CyberTheme.COL_CYAN
	elif room == 3 and not cleared:
		badge_txt = "🎓 PASSO 4/6"
		head_txt = "⚠️ TRAPPOLE A PAVIMENTO & MECH PESANTI"
		desc_txt = "Attenzione alle botole sul ponte: quando lampeggia l'avviso giallo ⚠️ hai mezzo secondo per spostarti prima che escano gli spuntoni 3D!"
		border_col = CyberTheme.COL_YELLOW
	elif room == 4 and not cleared:
		badge_txt = "🎓 PASSO 5/6"
		head_txt = "🧬 ABILITÀ IN PARTITA & SCHEDA EQUIP"
		desc_txt = "Raccogli XP per sbloccare Abilità Neurali cumulative. Nel Menu EQUIP usa le nuove tab '⬆️ POTENZIA LV.' (con ⚙️ Nuclei) e '🔨 FUSIONE' (unisci 3 copie per alzare la rarità)!"
		border_col = CyberTheme.COL_MAGENTA
	elif room == 5 and not cleared:
		badge_txt = "🎓 PASSO 6/6"
		head_txt = "👼 AVVICINATI ALLA CYBER-VALCHIRIA (OGNI 5 STANZE)"
		desc_txt = "Cammina fino al cerchio luminoso della Valchiria al centro della stanza per scegliere tra Cura HP o Potere Minore! Poi si aprirà il Portale Stargate."
		border_col = CyberTheme.COL_GREEN
	elif room == 5 and cleared:
		badge_txt = "✅ SANTUARIO COMPLETATO"
		head_txt = "🚪 BENEDIZIONE RICEVUTA — ENTRA NEL PORTALE"
		desc_txt = "Ottima scelta! Ora raggiungi il Portale Stargate illuminato in alto. Ricorda: ogni 10 livelli affronterai un Guardiano Boss!"
		border_col = CyberTheme.COL_GREEN
	elif room == 10 and not cleared:
		badge_txt = "⚠️ PROVA FINALE"
		head_txt = "💀 BOSS GUARDIANO — SBLOCCA IL MONDO 2!"
		desc_txt = "Alterna movimento (schiva i ventagli al plasma) e soste brevi per colpire! Sconfiggilo per ottenere Equipaggiamento Garantito, ⚙️ Nuclei e sbloccare il Mondo 2!"
		border_col = CyberTheme.COL_MAGENTA
	elif cleared:
		badge_txt = "✅ STANZA " + str(room) + "/10 PULITA"
		head_txt = "🚪 ENTRA NEL PORTALE STARGATE IN ALTO"
		desc_txt = "Tutti gli ostili neutralizzati e proiettili dissolti. Cammina nell'arco luminoso a Nord per passare allo Stage " + str(mini(room + 1, 10)) + "/10!"
		border_col = CyberTheme.COL_GREEN
	else:
		badge_txt = "🎯 STAGE " + str(room) + "/10"
		head_txt = "⚡ RAGGIUNGI E SCONFIGGI IL BOSS ALLO STAGE 10"
		desc_txt = "Combina coperture 3D e Abilità Neurali. Raccogli ⚙️ Nuclei e copie di equipaggiamento da potenziare e fondere nella scheda EQUIP!"
		border_col = CyberTheme.COL_CYAN

	if step_badge_lbl:
		step_badge_lbl.text = badge_txt
	if title_lbl:
		title_lbl.text = head_txt
		CyberTheme.style_label(title_lbl, border_col, 3)
	if body_lbl:
		body_lbl.text = desc_txt
	if card_panel:
		card_panel.add_theme_stylebox_override(
			"panel",
			CyberTheme.make_3d_panel_box(10, 8)
		)
		# Piccola animazione d'attenzione al cambio passo
		card_panel.modulate = Color(1.25, 1.25, 1.25, 1.0)
		var tw := create_tween()
		tw.tween_property(card_panel, "modulate", Color.WHITE, 0.28)

func _draw() -> void:
	var sp := _get_spawner()
	if not sp:
		return
	var room: int = int(sp.current_room) if "current_room" in sp else 1
	var cleared: bool = bool(sp.room_cleared) if "room_cleared" in sp else false

	var players := get_tree().get_nodes_in_group("player")
	var player: Node2D = players[0] as Node2D if (not players.is_empty() and players[0] is Node2D) else null

	# 1. Quando la stanza è pulita: disegna frecce 3D al neon sul pavimento dall'Eroe al Portale Stargate!
	if cleared and is_instance_valid(player):
		var start_p := player.global_position + Vector2(0, -24)
		var end_p := Vector2(360, 134)
		var dist: float = start_p.distance_to(end_p)
		if dist > 70.0:
			var dir := (end_p - start_p).normalized()
			var perp := Vector2(-dir.y, dir.x)
			var steps: int = clampi(int(dist / 68.0), 2, 12)
			for i in range(steps):
				var wave: float = fmod(anim_t * 3.0 - float(i) * 0.35, 1.0)
				if wave < 0.0: wave += 1.0
				var alpha: float = 0.25 + 0.70 * sin(wave * PI)
				var cp := start_p.lerp(end_p, float(i + 1) / float(steps + 1))
				var tip := cp + dir * 14.0
				var left_w := cp - dir * 8.0 + perp * 16.0
				var right_w := cp - dir * 8.0 - perp * 16.0
				draw_polyline(PackedVector2Array([left_w, tip, right_w]), Color(0.2, 1.0, 0.65, alpha), 4.0)
				draw_polyline(PackedVector2Array([left_w, tip, right_w]), Color(1.0, 1.0, 1.0, alpha * 0.75), 1.6)

	# 2. Stanza 1: anello tattico sotto l'eroe che mostra chiaramente STATO MOVIMENTO vs FUOCO AUTO
	if room == 1 and not cleared and is_instance_valid(player):
		var is_shoot: bool = bool(player.is_shooting) if "is_shooting" in player else false
		var ring_col := Color(0.2, 1.0, 0.55, 0.85) if is_shoot else Color(1.0, 0.84, 0.15, 0.75)
		var p_pos := player.global_position + Vector2(0, 16)
		draw_set_transform(p_pos, 0.0, Vector2(1.0, 0.44))
		draw_arc(Vector2.ZERO, 44.0 + sin(anim_t * 6.0) * 3.0, 0.0, TAU, 36, ring_col, 2.8)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		var font := ThemeDB.fallback_font
		if font:
			var status_txt := "⚡ FERMO: FUOCO AUTO!" if is_shoot else "🏃 IN MOVIMENTO (RILASCIA PER SPARARE)"
			draw_string(
				font,
				player.global_position + Vector2(-115.0 if not is_shoot else -72.0, 46.0),
				status_txt,
				HORIZONTAL_ALIGNMENT_CENTER,
				-1,
				13,
				ring_col
			)

	# 3. Stanza 2: evidenzia la Cassa Rifornimenti Dorata con un indicatore olografico 2.5D
	if room == 2:
		for crate in get_tree().get_nodes_in_group("loot_crates"):
			if is_instance_valid(crate) and crate is Node2D:
				var cpos := (crate as Node2D).global_position
				draw_set_transform(cpos + Vector2(0, 18), 0.0, Vector2(1.0, 0.44))
				draw_arc(Vector2.ZERO, 40.0 + sin(anim_t * 5.0) * 4.0, 0.0, TAU, 28, Color(1.0, 0.88, 0.2, 0.85), 2.5)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				var font := ThemeDB.fallback_font
				if font:
					draw_string(font, cpos + Vector2(-62, -42 + sin(anim_t * 5.0) * 3.0), "🎯 COLPISCI CASSA!", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.90, 0.25, 0.95))

	# 4. Stanza 3: evidenzia le Trappole a pavimento per insegnare il tempismo del preavviso
	if room == 3 and not cleared:
		for tr in get_tree().get_nodes_in_group("traps"):
			if is_instance_valid(tr) and tr is Node2D:
				var tpos := (tr as Node2D).global_position
				draw_arc(tpos, 44.0, anim_t * 2.0, anim_t * 2.0 + PI * 1.4, 24, Color(1.0, 0.65, 0.1, 0.65), 2.0)
