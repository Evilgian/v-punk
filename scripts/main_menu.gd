extends Control

# Footer Navbar tabs
var btn_nav_shop: Control = null
var btn_nav_equip: Control = null
var btn_nav_home: Control = null
var btn_upgrades: Control = null
var btn_nav_quests: Control = null

# Top Bar references
var profile_level_label: Label = null
var energy_label: Label = null
var coins_label: Label = null
var gems_label: Label = null
var btn_checkin_top: Button = null

# Section Title
var section_title: Label = null

# View containers
var home_view: VBoxContainer = null
var inventory_view: VBoxContainer = null
var upgrades_view: VBoxContainer = null
var quests_view: VBoxContainer = null
var checkin_view: VBoxContainer = null
var shop_view: VBoxContainer = null

# Home View references
var world_card_name: Label = null
var world_card_info: Label = null
var world_card_desc: Label = null
var equipped_summary_label: Label = null
var btn_play_home: Button = null
var btn_prev_world: Button = null
var btn_next_world: Button = null
var preview_icon: TextureButton = null

# Inventory View references - 6 Slots & Forge
var hero_atk_label: Label = null
var hero_hp_label: Label = null
var hero_crit_label: Label = null
var hero_speed_label: Label = null
var inventory_grid: GridContainer = null
var btn_merge_all: Button = null
var merge_status_label: Label = null

# Upgrades View references - Talent Tree
var talent_grid: GridContainer = null

# Shop View references
var btn_buy_normal_crate: Button = null
var btn_buy_epic_crate: Button = null
var btn_watch_ad: Button = null
var btn_iap_1: Button = null
var btn_iap_2: Button = null
var btn_iap_3: Button = null
var shop_result_label: Label = null
var ad_count_label: Label = null

# Checkin View references
var checkin_grid: GridContainer = null
var btn_claim_checkin: Button = null
var checkin_status_label: Label = null

# Quests View references
var quests_container: VBoxContainer = null
var btn_quest_daily: Button = null
var btn_quest_weekly: Button = null
var btn_quest_monthly: Button = null

enum ViewMode { HOME, INVENTORY, UPGRADES, QUESTS, CHECKIN, SHOP }
var current_view: ViewMode = ViewMode.HOME
var current_quest_tab: String = "DAILY"
var current_equip_tab: String = "ARSENAL" # "ARSENAL", "SKINS", "UPGRADE", "MERGE"
var current_gear_filter: String = "ALL" # "ALL", "ARMA", "CORAZZA", "ANELLO", "PET"

var equip_sub_nav: HBoxContainer = null
var btn_equip_tab_arsenal: Button = null
var btn_equip_tab_skins: Button = null
var btn_equip_tab_upgrade: Button = null
var btn_equip_tab_merge: Button = null
var hero_section_panel: Control = null
var forge_section_panel: Control = null
var inventory_title_lbl: Label = null
var upgrade_workshop_box: VBoxContainer = null
var merge_workshop_box: VBoxContainer = null
var skins_workshop_box: VBoxContainer = null
var btn_hero_skin_badge: Button = null
var upgrade_feedback_msg: String = ""

func _ready() -> void:
	btn_nav_shop = find_child("BtnNavShop", true, false) as Control
	btn_nav_equip = find_child("BtnNavEquip", true, false) as Control
	btn_nav_home = find_child("BtnNavHome", true, false) as Control
	btn_upgrades = find_child("BtnUpgrades", true, false) as Control
	btn_nav_quests = find_child("BtnNavQuests", true, false) as Control

	profile_level_label = find_child("LevelLabel", true, false) as Label
	energy_label = find_child("EnergyLabel", true, false) as Label
	coins_label = find_child("CoinsLabel", true, false) as Label
	gems_label = find_child("GemsLabel", true, false) as Label
	btn_checkin_top = find_child("BtnCheckinTop", true, false) as Button

	section_title = find_child("SectionTitle", true, false) as Label
	home_view = find_child("HomeView", true, false) as VBoxContainer
	inventory_view = find_child("InventoryView", true, false) as VBoxContainer
	upgrades_view = find_child("UpgradesView", true, false) as VBoxContainer
	quests_view = find_child("QuestsView", true, false) as VBoxContainer
	checkin_view = find_child("CheckinView", true, false) as VBoxContainer
	shop_view = find_child("ShopView", true, false) as VBoxContainer

	world_card_name = find_child("WorldName", true, false) as Label
	world_card_info = find_child("WorldInfo", true, false) as Label
	world_card_desc = find_child("WorldDesc", true, false) as Label
	equipped_summary_label = find_child("EquippedSummaryLabel", true, false) as Label
	btn_play_home = find_child("BtnPlayHome", true, false) as Button
	btn_prev_world = find_child("BtnPrevWorld", true, false) as Button
	btn_next_world = find_child("BtnNextWorld", true, false) as Button
	preview_icon = find_child("PreviewIcon", true, false) as TextureButton

	hero_atk_label = find_child("AtkLabel", true, false) as Label
	hero_hp_label = find_child("HpLabel", true, false) as Label
	hero_crit_label = find_child("CritLabel", true, false) as Label
	hero_speed_label = find_child("SpeedLabel", true, false) as Label

	inventory_grid = find_child("InventoryGrid", true, false) as GridContainer
	btn_merge_all = find_child("BtnMergeAll", true, false) as Button
	merge_status_label = find_child("MergeStatusLabel", true, false) as Label
	talent_grid = find_child("TalentGrid", true, false) as GridContainer

	btn_buy_normal_crate = find_child("BtnBuyNormalCrate", true, false) as Button
	btn_buy_epic_crate = find_child("BtnBuyEpicCrate", true, false) as Button
	btn_watch_ad = find_child("BtnWatchAd", true, false) as Button
	btn_iap_1 = find_child("BtnIap1", true, false) as Button
	btn_iap_2 = find_child("BtnIap2", true, false) as Button
	btn_iap_3 = find_child("BtnIap3", true, false) as Button
	shop_result_label = find_child("ShopResultLabel", true, false) as Label
	ad_count_label = find_child("AdCountLabel", true, false) as Label

	checkin_grid = find_child("CheckinGrid", true, false) as GridContainer
	btn_claim_checkin = find_child("BtnClaimCheckin", true, false) as Button
	checkin_status_label = find_child("CheckinStatusLabel", true, false) as Label

	quests_container = find_child("QuestsContainer", true, false) as VBoxContainer
	btn_quest_daily = find_child("BtnQuestDaily", true, false) as Button
	btn_quest_weekly = find_child("BtnQuestWeekly", true, false) as Button
	btn_quest_monthly = find_child("BtnQuestMonthly", true, false) as Button

	_setup_dynamic_styles()

	if btn_nav_shop: _connect_button(btn_nav_shop, _on_nav_shop_pressed)
	if btn_nav_equip: _connect_button(btn_nav_equip, _on_nav_equip_pressed)
	if btn_nav_home: _connect_button(btn_nav_home, _on_nav_home_pressed)
	if btn_upgrades: _connect_button(btn_upgrades, _on_btn_upgrades_pressed)
	if btn_nav_quests: _connect_button(btn_nav_quests, _on_nav_quests_pressed)

	if btn_checkin_top: btn_checkin_top.pressed.connect(_on_btn_checkin_pressed)

	if btn_play_home: btn_play_home.pressed.connect(_on_btn_play_pressed)

	if btn_buy_normal_crate: btn_buy_normal_crate.pressed.connect(func(): _buy_crate(100, "NORMAL"))
	if btn_buy_epic_crate: btn_buy_epic_crate.pressed.connect(func(): _buy_crate(300, "EPIC"))

	if btn_watch_ad: btn_watch_ad.pressed.connect(_on_watch_ad_pressed)
	if btn_iap_1: btn_iap_1.pressed.connect(func(): _buy_iap(100, "$0.99"))
	if btn_iap_2: btn_iap_2.pressed.connect(func(): _buy_iap(500, "$4.99"))
	if btn_iap_3: btn_iap_3.pressed.connect(func(): _buy_iap(1200, "$9.99"))

	if btn_claim_checkin: btn_claim_checkin.pressed.connect(_on_claim_checkin_pressed)

	if btn_quest_daily:
		btn_quest_daily.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_quest_daily.pressed.connect(func(): _switch_quest_tab("DAILY"))
	if btn_quest_weekly:
		btn_quest_weekly.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_quest_weekly.pressed.connect(func(): _switch_quest_tab("WEEKLY"))
	if btn_quest_monthly:
		btn_quest_monthly.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_quest_monthly.pressed.connect(func(): _switch_quest_tab("MONTHLY"))

	_style_subnav_btn(btn_quest_daily, true)
	_style_subnav_btn(btn_quest_weekly, false)
	_style_subnav_btn(btn_quest_monthly, false)

	_setup_equip_subtabs()

	if btn_merge_all: btn_merge_all.pressed.connect(_on_merge_all_pressed)

	if btn_prev_world: btn_prev_world.pressed.connect(func(): _cycle_world(-1))
	if btn_next_world: btn_next_world.pressed.connect(func(): _cycle_world(1))
	if preview_icon:
		preview_icon.gui_input.connect(_on_world_preview_gui_input)

	var prof_card_ctrl: Control = find_child("ProfileCard", true, false) as Control
	if prof_card_ctrl:
		_connect_button(prof_card_ctrl, _open_settings_modal)

	var btn_set: Button = find_child("BtnSettingsTop", true, false) as Button
	if btn_set:
		CyberTheme.style_button(btn_set, CyberTheme.COL_CYAN, false)
		btn_set.pressed.connect(_open_settings_modal)

	# Pillole Risorse Interattive (1 tocco porta direttamente alla sezione corrispondente!)
	var pill_scrolls: Control = find_child("PillScrolls", true, false) as Control
	if pill_scrolls:
		_connect_button(pill_scrolls, func():
			SoundFX.play_click()
			current_equip_tab = "UPGRADE"
			_show_inventory_view()
		)
	var pill_coins: Control = find_child("PillCoins", true, false) as Control
	if pill_coins:
		_connect_button(pill_coins, _on_btn_upgrades_pressed)
	var pill_gems: Control = find_child("PillGems", true, false) as Control
	if pill_gems:
		_connect_button(pill_gems, _on_nav_shop_pressed)

	var main_scroll := find_child("ScrollContainer", true, false) as ScrollContainer
	if main_scroll:
		main_scroll.scroll_deadzone = 10
		main_scroll.follow_focus = false
		_make_subtree_scroll_safe(main_scroll)

	_update_top_bar()
	_show_home_view()

	if not Global.profile_created:
		Global.boot_entrance_shown = true
		call_deferred("_show_character_creation_modal", true)
	elif not Global.boot_entrance_shown:
		Global.boot_entrance_shown = true
		call_deferred("_show_welcome_entrance_screen")

func _setup_dynamic_styles() -> void:
	CyberTheme.attach_cyber_bloom(self)
	CyberTheme.apply_recursive_cyber_style(self)

	# Nascondi il vecchio ColorRect piatto e aggiungi il Canvas Cyberpunk animato (Skyline + SynthGrid + Scanlines)
	var old_bg: ColorRect = find_child("Background", true, false) as ColorRect
	if old_bg:
		old_bg.visible = false

	cyber_bg_canvas = Control.new()
	cyber_bg_canvas.name = "CyberBackdropCanvas"
	cyber_bg_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	cyber_bg_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cyber_bg_canvas.draw.connect(func():
		var w: WorldData = WorldDB.get_selected_world()
		var acc: Color = w.accent_color if w else CyberTheme.COL_CYAN
		CyberTheme.draw_cyberpunk_backdrop(cyber_bg_canvas, size, menu_anim_t, acc)
	)
	add_child(cyber_bg_canvas)
	move_child(cyber_bg_canvas, 0)

	var central: PanelContainer = find_child("CentralContainer", true, false) as PanelContainer
	if central:
		# Layout moderno a schede sospese sopra il fondale 3D Cyberpunk (niente tripli bordi annidati!)
		central.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	var world_card: PanelContainer = find_child("WorldCard", true, false) as PanelContainer
	if world_card:
		world_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(16, 14))

	var summary_card: PanelContainer = find_child("EquippedSummaryCard", true, false) as PanelContainer
	if summary_card:
		summary_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(14, 12))

	var hero_sec: PanelContainer = find_child("HeroSection", true, false) as PanelContainer
	if hero_sec:
		hero_sec.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(12, 12))

	var forge_sec: PanelContainer = find_child("ForgeSection", true, false) as PanelContainer
	if forge_sec:
		forge_sec.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(14, 12))

	var crates_sec: PanelContainer = find_child("CratesSection", true, false) as PanelContainer
	if crates_sec:
		crates_sec.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(14, 12))

	var ads_sec: PanelContainer = find_child("FreeAdsSection", true, false) as PanelContainer
	if ads_sec:
		ads_sec.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(14, 12))

	var iap_sec: PanelContainer = find_child("IapSection", true, false) as PanelContainer
	if iap_sec:
		iap_sec.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(14, 12))

	var profile_card: PanelContainer = find_child("ProfileCard", true, false) as PanelContainer
	if profile_card:
		profile_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(12, 8))

	var pill_scrolls: PanelContainer = find_child("PillScrolls", true, false) as PanelContainer
	if pill_scrolls:
		pill_scrolls.add_theme_stylebox_override("panel", CyberTheme.make_glass_counter_box(CyberTheme.COL_GREEN))

	var pill_coins: PanelContainer = find_child("PillCoins", true, false) as PanelContainer
	if pill_coins:
		pill_coins.add_theme_stylebox_override("panel", CyberTheme.make_glass_counter_box(CyberTheme.COL_YELLOW))

	var pill_gems: PanelContainer = find_child("PillGems", true, false) as PanelContainer
	if pill_gems:
		pill_gems.add_theme_stylebox_override("panel", CyberTheme.make_glass_counter_box(CyberTheme.COL_CYAN))

	var q_sub: Control = find_child("QuestsSubNav", true, false) as Control
	if q_sub and q_sub.get_parent() and not q_sub.get_parent().get_node_or_null("QuestSegHousing"):
		var q_parent := q_sub.get_parent()
		var q_idx := q_sub.get_index()
		var q_house := PanelContainer.new()
		q_house.name = "QuestSegHousing"
		q_house.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.025, 0.04, 0.09, 0.96), Color(0.18, 0.34, 0.56, 0.75), 0.0, 2, 2, 0))
		q_parent.remove_child(q_sub)
		q_house.add_child(q_sub)
		q_parent.add_child(q_house)
		q_parent.move_child(q_house, q_idx)

	var podium: PanelContainer = find_child("HeroPodium", true, false) as PanelContainer
	if podium:
		podium.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(10, 10))

	_setup_top_bar_and_footer_3d_icons()
	_setup_procedural_menu_models()

func _attach_resource_pill_3d_icon(pill: PanelContainer, lbl: Label, icon_key: String) -> void:
	if not pill or not lbl:
		return
	if pill.get_node_or_null("ResHBox") != null:
		return
	var hb := HBoxContainer.new()
	hb.name = "ResHBox"
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 6)
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tr := TextureRect.new()
	tr.name = "Icon3D"
	tr.custom_minimum_size = Vector2(28, 28)
	tr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.texture = CyberTheme.get_ui_icon(icon_key)
	hb.add_child(tr)

	lbl.get_parent().remove_child(lbl)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(lbl)
	pill.add_child(hb)

func _setup_footer_tab_3d_icon(tab_btn: Control, icon_key: String, default_title: String) -> void:
	if not tab_btn:
		return
	if tab_btn.get_node_or_null("NavVBox") != null:
		return
	var lbl := tab_btn.get_node_or_null("Label") as Label
	var vb := VBoxContainer.new()
	vb.name = "NavVBox"
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 2)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var icon_wrap := Control.new()
	icon_wrap.name = "IconWrap"
	icon_wrap.custom_minimum_size = Vector2(42, 38)
	icon_wrap.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(icon_wrap)

	var tr := TextureRect.new()
	tr.name = "NavIcon"
	tr.custom_minimum_size = Vector2(38, 38)
	tr.position = Vector2(2, 0)
	tr.size = Vector2(38, 38)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.texture = CyberTheme.get_ui_icon(icon_key)
	icon_wrap.add_child(tr)

	var dot := Control.new()
	dot.name = "AlertDot"
	dot.custom_minimum_size = Vector2(14, 14)
	dot.position = Vector2(30, -1)
	dot.size = Vector2(14, 14)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.visible = false
	dot.draw.connect(func():
		dot.draw_circle(Vector2(7, 7), 6.5, Color(0.05, 0.02, 0.04, 0.96))
		dot.draw_circle(Vector2(7, 7), 5.0, Color(1.0, 0.16, 0.32, 1.0))
		dot.draw_circle(Vector2(5.5, 5.5), 1.8, Color.WHITE)
	)
	icon_wrap.add_child(dot)

	if lbl:
		lbl.get_parent().remove_child(lbl)
		lbl.text = default_title
		lbl.add_theme_font_size_override("font_size", 15)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(lbl)

	tab_btn.add_child(vb)

func _setup_top_bar_and_footer_3d_icons() -> void:
	var pill_scrolls: PanelContainer = find_child("PillScrolls", true, false) as PanelContainer
	var pill_coins: PanelContainer = find_child("PillCoins", true, false) as PanelContainer
	var pill_gems: PanelContainer = find_child("PillGems", true, false) as PanelContainer
	_attach_resource_pill_3d_icon(pill_scrolls, energy_label, "core")
	_attach_resource_pill_3d_icon(pill_coins, coins_label, "coin")
	_attach_resource_pill_3d_icon(pill_gems, gems_label, "gem")

	if btn_checkin_top:
		btn_checkin_top.custom_minimum_size = Vector2(146, 64)
		btn_checkin_top.icon = CyberTheme.get_ui_icon("gift")
		btn_checkin_top.expand_icon = true

	var btn_set: Button = find_child("BtnSettingsTop", true, false) as Button
	if btn_set:
		btn_set.custom_minimum_size = Vector2(66, 64)
		btn_set.text = ""
		btn_set.icon = CyberTheme.get_ui_icon("settings")
		btn_set.expand_icon = true
		btn_set.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if btn_watch_ad:
		btn_watch_ad.icon = CyberTheme.get_ui_icon("gem")
		btn_watch_ad.expand_icon = true

	_setup_footer_tab_3d_icon(btn_nav_shop, "nav_shop", "MERCATO")
	_setup_footer_tab_3d_icon(btn_nav_equip, "nav_equip", "CROMO")
	_setup_footer_tab_3d_icon(btn_nav_home, "nav_play", "INCURSIONE")
	_setup_footer_tab_3d_icon(btn_upgrades, "nav_talents", "SINAPSI")
	_setup_footer_tab_3d_icon(btn_nav_quests, "nav_quests", "CONTRATTI")

var menu_anim_t: float = 0.0
var world_intel_open: bool = false
var world_swipe_active: bool = false
var world_swipe_start: Vector2 = Vector2.ZERO
var world_swipe_handled: bool = false
var cyber_bg_canvas: Control = null
var boss_holo_node: Node2D = null
var boss_actor_node: Node2D = null
var hero_holo_node: Node2D = null
var top_avatar_holo: Node2D = null
var welcome_layer: CanvasLayer = null
var welcome_holo: Node2D = null
var welcome_fx_ctrl: Control = null
var char_modal_layer: CanvasLayer = null
var char_fx_ctrl: Control = null
var char_preview_holo: Node2D = null
var char_preview_panel: PanelContainer = null
var char_preview_status_lbl: Label = null
var char_name_input: LineEdit = null
var char_selected_class: String = "RONIN"
var char_selected_color: String = "CYAN"
var char_class_btns: Dictionary = {}
var char_color_btns: Dictionary = {}

func _process(delta: float) -> void:
	menu_anim_t += delta
	if is_instance_valid(cyber_bg_canvas): cyber_bg_canvas.queue_redraw()
	if is_instance_valid(boss_holo_node): boss_holo_node.queue_redraw()
	if is_instance_valid(boss_actor_node): boss_actor_node.queue_redraw()
	if is_instance_valid(hero_holo_node): hero_holo_node.queue_redraw()
	if is_instance_valid(top_avatar_holo): top_avatar_holo.queue_redraw()
	if is_instance_valid(welcome_holo): welcome_holo.queue_redraw()
	if is_instance_valid(welcome_fx_ctrl): welcome_fx_ctrl.queue_redraw()
	if is_instance_valid(char_fx_ctrl): char_fx_ctrl.queue_redraw()
	if is_instance_valid(char_preview_holo): char_preview_holo.queue_redraw()

func _setup_procedural_menu_models() -> void:
	if preview_icon:
		preview_icon.texture_normal = null
		preview_icon.clip_contents = true
		boss_holo_node = Node2D.new()
		boss_holo_node.position = Vector2.ZERO
		boss_holo_node.scale = Vector2(1.0, 1.0)
		boss_holo_node.draw.connect(func():
			var p_sz: Vector2 = preview_icon.size
			if p_sz.x < 40.0 or p_sz.y < 40.0:
				p_sz = Vector2(516, 248)
			var w: WorldData = WorldDB.get_selected_world()
			var wid: String = w.id if w else "world_1"
			var w_idx: int = maxi(1, WorldDB.world_order.find(wid) + 1)
			var tot_worlds: int = maxi(12, WorldDB.world_order.size())
			var is_locked: bool = (w_idx > Global.max_unlocked_world)
			var acc: Color = Color(1.0, 0.05, 0.28, 1.0) if is_locked else (w.accent_color if w else CyberTheme.COL_CYAN)
			var banner_tex: Texture2D = CyberTheme.get_model_texture("res://assets/cyber_models/banner_" + wid + ".png")
			var rect := Rect2(Vector2.ZERO, p_sz)
			if banner_tex:
				# Fondale HD 800x450 con leggero effetto parallasse dinamico!
				var tw: float = float(banner_tex.get_width())
				var th: float = float(banner_tex.get_height())
				var sc: float = maxf(p_sz.x / maxf(1.0, tw), p_sz.y / maxf(1.0, th)) * 1.04
				var src_w: float = p_sz.x / sc
				var src_h: float = p_sz.y / sc
				var pan_x: float = sin(menu_anim_t * 0.55) * minf(12.0, maxf(0.0, (tw - src_w) * 0.45))
				var src_rect := Rect2(Vector2((tw - src_w) * 0.5 + pan_x, (th - src_h) * 0.5), Vector2(src_w, src_h))
				var bg_tint := Color(0.38, 0.34, 0.46, 1.0) if is_locked else Color.WHITE
				boss_holo_node.draw_texture_rect_region(banner_tex, rect, src_rect, bg_tint)
			else:
				boss_holo_node.draw_rect(rect, Color(0.03, 0.04, 0.08, 0.98), true)

			# Vignettatura cinematografica inferiore per staccare Boss 3D e telemetria HUD
			boss_holo_node.draw_polygon(
				PackedVector2Array([Vector2(0, p_sz.y * 0.44), Vector2(p_sz.x, p_sz.y * 0.44), Vector2(p_sz.x, p_sz.y), Vector2(0, p_sz.y)]),
				PackedColorArray([Color(0.01, 0.015, 0.04, 0.0), Color(0.01, 0.015, 0.04, 0.0), Color(0.01, 0.015, 0.04, 0.86), Color(0.01, 0.015, 0.04, 0.86)])
			)

			# Cornice chirurgica Cyberpunk 2077 + mirini telemetrici
			boss_holo_node.draw_rect(rect, Color(acc.r, acc.g, acc.b, 0.85), false, 2.0)
			boss_holo_node.draw_rect(Rect2(Vector2(0, 0), Vector2(5, p_sz.y)), acc, true)

			var fnt: Font = CyberTheme.get_cyber_font(true)
			if fnt and w:
				var sec_str := "SETTORE %02d / %02d" % [w_idx, tot_worlds]
				boss_holo_node.draw_rect(Rect2(Vector2(12, 10), Vector2(158, 28)), Color(0.02, 0.03, 0.06, 0.92), true)
				boss_holo_node.draw_rect(Rect2(Vector2(12, 10), Vector2(3, 28)), acc, true)
				boss_holo_node.draw_string(fnt, Vector2(22, 30), sec_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)

				var right_tag := "[ CRIPTATO ]" if is_locked else ("[ CHIUDI INTEL ]" if world_intel_open else "[ INTEL » ]")
				var rt_w: float = 136.0
				boss_holo_node.draw_rect(Rect2(Vector2(p_sz.x - rt_w - 10.0, 10.0), Vector2(rt_w, 28.0)), Color(0.02, 0.03, 0.06, 0.90), true)
				boss_holo_node.draw_rect(Rect2(Vector2(p_sz.x - rt_w - 10.0, 10.0), Vector2(rt_w, 28.0)), Color(acc.r, acc.g, acc.b, 0.72), false, 1.2)
				boss_holo_node.draw_string(fnt, Vector2(p_sz.x - rt_w - 4.0, 30.0), right_tag, HORIZONTAL_ALIGNMENT_CENTER, rt_w - 8.0, 14, CyberTheme.COL_YELLOW if (not is_locked and world_intel_open) else acc)

				# Barra inferiore sintetica (zero spoiler prolissi!)
				var b_tag := ("BERSAGLIO CRIPTATO  //  SBLOCCA SETTORE %02d" % (w_idx - 1)) if is_locked else ("BERSAGLIO: " + w.boss_name + "   •   BOTTINO x" + str(w.reward_multiplier))
				boss_holo_node.draw_string(fnt, Vector2(14, p_sz.y - 11.0), b_tag, HORIZONTAL_ALIGNMENT_LEFT, p_sz.x - 24.0, 14, Color(1.0, 0.42, 0.52, 0.96) if is_locked else Color(0.92, 0.96, 1.0, 0.95))

				if world_intel_open and not is_locked:
					var ir := Rect2(Vector2(12.0, p_sz.y - 98.0), Vector2(p_sz.x - 24.0, 62.0))
					boss_holo_node.draw_rect(ir, Color(0.02, 0.03, 0.06, 0.94), true)
					boss_holo_node.draw_rect(ir, CyberTheme.COL_YELLOW, false, 1.5)
					boss_holo_node.draw_string(fnt, Vector2(22.0, ir.position.y + 22.0), w.description, HORIZONTAL_ALIGNMENT_LEFT, ir.size.x - 18.0, 13, Color.WHITE)
					boss_holo_node.draw_string(fnt, Vector2(22.0, ir.position.y + 46.0), "ZONE: " + str(w.total_rooms) + "   •   MINACCIA OSTILI: x" + str(w.enemy_hp_multiplier) + "   •   ANOMALIA: " + w.trap_type, HORIZONTAL_ALIGNMENT_LEFT, ir.size.x - 18.0, 13, CyberTheme.COL_YELLOW)

			if is_instance_valid(boss_actor_node):
				var dyn_sc: float = clampf(p_sz.y / 205.0, 1.15, 1.48)
				boss_actor_node.position = Vector2(p_sz.x * 0.5, p_sz.y * 0.57)
				boss_actor_node.scale = Vector2(dyn_sc, dyn_sc)
				boss_actor_node.modulate = Color(0.03, 0.04, 0.07, 0.95) if is_locked else Color.WHITE
		)
		preview_icon.add_child(boss_holo_node)

		boss_actor_node = Node2D.new()
		boss_actor_node.position = Vector2(258, 140)
		boss_actor_node.scale = Vector2(1.24, 1.24)
		boss_actor_node.draw.connect(func():
			var w: WorldData = WorldDB.get_selected_world()
			var wid: String = w.id if w else "world_1"
			var bcol: Color = w.boss_color if w else Color(0, 0.94, 1, 1)
			CyberModels.draw_boss(boss_actor_node, wid, menu_anim_t, bcol, false, PI * 0.5 + sin(menu_anim_t * 1.4) * 0.18)
		)
		boss_holo_node.add_child(boss_actor_node)

	var hero_center: TextureRect = find_child("HeroCenter", true, false) as TextureRect
	if hero_center:
		hero_center.texture = null
		hero_holo_node = Node2D.new()
		hero_holo_node.position = Vector2(86, 122)
		hero_holo_node.scale = Vector2(2.24, 2.24)
		hero_holo_node.draw.connect(func():
			var aura_c := Global.get_player_accent_color()
			# Camera Olografica 3D: disco proiettore metallico + colonna di luce volumetrica
			hero_holo_node.draw_set_transform(Vector2(0, 22.0), 0.0, Vector2(1.0, 0.38))
			hero_holo_node.draw_circle(Vector2.ZERO, 33.0, Color(0.05, 0.09, 0.18, 0.96))
			hero_holo_node.draw_arc(Vector2.ZERO, 33.0, 0.0, TAU, 32, aura_c, 2.2)
			hero_holo_node.draw_arc(Vector2.ZERO, 25.0, menu_anim_t * 1.4, menu_anim_t * 1.4 + PI * 1.4, 24, Color.WHITE, 1.4)
			hero_holo_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			hero_holo_node.draw_polygon(
				PackedVector2Array([Vector2(-26, 22), Vector2(26, 22), Vector2(32, -46), Vector2(-32, -46)]),
				PackedColorArray([
					Color(aura_c.r, aura_c.g, aura_c.b, 0.22),
					Color(aura_c.r, aura_c.g, aura_c.b, 0.22),
					Color(aura_c.r, aura_c.g, aura_c.b, 0.0),
					Color(aura_c.r, aura_c.g, aura_c.b, 0.0)
				])
			)
			# Posa Eroica da Parata (parade_mode = true): arma impugnata diagonalmente sul petto!
			CyberModels.draw_hero(hero_holo_node, WeaponDB.equipped_weapon_id, menu_anim_t, false, false, PI * 0.5 + sin(menu_anim_t * 1.25) * 0.32, Vector2.ZERO, 68.0, true)
		)
		hero_center.add_child(hero_holo_node)

	var top_avatar: TextureRect = find_child("Avatar", true, false) as TextureRect
	if top_avatar:
		top_avatar.texture = null
		top_avatar_holo = Node2D.new()
		top_avatar_holo.position = Vector2(24, 28)
		top_avatar_holo.scale = Vector2(0.76, 0.76)
		top_avatar_holo.draw.connect(func():
			CyberModels.draw_hero(top_avatar_holo, WeaponDB.equipped_weapon_id, menu_anim_t, false, false, PI * 0.5, Vector2.ZERO, 68.0, true)
		)
		top_avatar.add_child(top_avatar_holo)

	# Modelli 3D nei Forzieri dello Shop (con i colori ufficiali di Rarità!)
	if btn_buy_normal_crate:
		var nc_vis := Control.new()
		nc_vis.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nc_vis.set_anchors_preset(Control.PRESET_FULL_RECT)
		nc_vis.draw.connect(func():
			var c := Vector2(btn_buy_normal_crate.size.x * 0.5, 68.0)
			var crate_t := CyberTheme.get_model_texture("res://assets/cyber_models/prop_crate.png")
			if crate_t:
				nc_vis.draw_texture_rect(crate_t, Rect2(c - Vector2(44, 34), Vector2(88, 88)), false)
			CyberTheme.draw_item_icon(nc_vis, c + Vector2(-58, -6), "shotgun", "ARMA", CyberTheme.COL_RARITY_RARE, 64.0)
			CyberTheme.draw_item_icon(nc_vis, c + Vector2(58, -6), "kevlar", "CORAZZA", CyberTheme.COL_RARITY_COMMON, 64.0)
		)
		btn_buy_normal_crate.add_child(nc_vis)

	if btn_buy_epic_crate:
		var ec_vis := Control.new()
		ec_vis.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ec_vis.set_anchors_preset(Control.PRESET_FULL_RECT)
		ec_vis.draw.connect(func():
			var c := Vector2(btn_buy_epic_crate.size.x * 0.5, 68.0)
			CyberTheme.draw_item_icon(ec_vis, c + Vector2(-64, 2), "katana", "ARMA", CyberTheme.COL_RARITY_EPIC, 66.0)
			CyberTheme.draw_item_icon(ec_vis, c + Vector2(64, 2), "drone_shield", "PET 2", CyberTheme.COL_RARITY_EPIC, 66.0)
			CyberTheme.draw_item_icon(ec_vis, c + Vector2(0, -8), "plasma_cannon", "ARMA", CyberTheme.COL_RARITY_LEGENDARY, 76.0)
		)
		btn_buy_epic_crate.add_child(ec_vis)

func _is_inside_scroll_container(node: Node) -> bool:
	var cur: Node = node.get_parent()
	while cur != null:
		if cur is ScrollContainer:
			return true
		cur = cur.get_parent()
	return false

## Garantisce che NESSUN contenitore o bottone dentro ScrollContainer blocchi mai il trascinamento verticale touch!
func _make_subtree_scroll_safe(node: Node) -> void:
	if not node:
		return
	if node is ScrollContainer:
		(node as ScrollContainer).mouse_filter = Control.MOUSE_FILTER_STOP
	elif node is BaseButton:
		var bb := node as BaseButton
		bb.mouse_filter = Control.MOUSE_FILTER_PASS
		bb.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		bb.focus_mode = Control.FOCUS_NONE
	elif node is LineEdit:
		pass
	elif node is Label or node is TextureRect or node is ProgressBar or node is ColorRect:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	elif node is Control:
		var ctrl := node as Control
		if ctrl.mouse_filter == Control.MOUSE_FILTER_STOP:
			ctrl.mouse_filter = Control.MOUSE_FILTER_PASS
	for ch in node.get_children():
		_make_subtree_scroll_safe(ch)

func _reset_main_scroll() -> void:
	var sc := find_child("ScrollContainer", true, false) as ScrollContainer
	if sc:
		sc.scroll_vertical = 0

func _set_children_mouse_ignore(parent_node: Node) -> void:
	for child in parent_node.get_children():
		if child.name == "_NativeHitBtn":
			continue
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_ignore(child)

func _connect_button(node: Control, method: Callable) -> void:
	if not node:
		return
	var in_scroll: bool = (not node.is_inside_tree()) or _is_inside_scroll_container(node)
	if node is BaseButton:
		var bb := node as BaseButton
		if in_scroll:
			bb.mouse_filter = Control.MOUSE_FILTER_PASS
			bb.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		else:
			bb.mouse_filter = Control.MOUSE_FILTER_STOP
			bb.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		bb.pressed.connect(method)
		return

	# Se è dentro uno ScrollContainer (o è una card creata dinamicamente per le liste scorrevoli),
	# usa un vero Button C++ di Godot con MOUSE_FILTER_PASS + ACTION_MODE_BUTTON_RELEASE -> scroll fluido e tocco perfetto!
	if in_scroll:
		node.mouse_filter = Control.MOUSE_FILTER_PASS
		_set_children_mouse_ignore(node)
		var old_hit := node.get_node_or_null("_NativeHitBtn")
		if old_hit:
			node.remove_child(old_hit)
			old_hit.queue_free()
		var hit_btn := Button.new()
		hit_btn.name = "_NativeHitBtn"
		hit_btn.flat = true
		hit_btn.focus_mode = Control.FOCUS_NONE
		hit_btn.text = ""
		var empty_sb := StyleBoxEmpty.new()
		for st_k in ["normal", "hover", "pressed", "disabled", "focus"]:
			hit_btn.add_theme_stylebox_override(st_k, empty_sb)
		hit_btn.mouse_filter = Control.MOUSE_FILTER_PASS
		hit_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		hit_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hit_btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		hit_btn.pressed.connect(method)
		node.add_child(hit_btn)
		return

	# Per le Tab fisse in basso (FooterNavBar) e la TopBar/ResourceBar:
	# risposta istantanea al tocco con debounce di 120ms per evitare doppi invii Touch+Mouse su Android!
	node.mouse_filter = Control.MOUSE_FILTER_STOP
	for child in node.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.set_meta("_last_fire_ms", -999)
	node.gui_input.connect(func(event: InputEvent):
		var is_press: bool = false
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			is_press = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
		elif event is InputEventScreenTouch:
			var st := event as InputEventScreenTouch
			is_press = st.pressed
		if is_press:
			var now_ms: int = Time.get_ticks_msec()
			if now_ms - int(node.get_meta("_last_fire_ms", -999)) > 120:
				node.set_meta("_last_fire_ms", now_ms)
				method.call()
	)

func _has_ready_quest() -> bool:
	var rm: Node = get_node_or_null("/root/RewardManager")
	if not rm:
		return false
	var groups := []
	if "DAILY_QUESTS" in rm: groups.append_array(rm.DAILY_QUESTS)
	if "WEEKLY_QUESTS" in rm: groups.append_array(rm.WEEKLY_QUESTS)
	if "MONTHLY_QUESTS" in rm: groups.append_array(rm.MONTHLY_QUESTS)
	for q in groups:
		var q_id: String = str(q.get("id", ""))
		if Global.quests_claimed.get(q_id, false):
			continue
		var st: String = str(q.get("stat", q.get("target_type", "")))
		var cur_v: int = 0
		match st:
			"quest_kills", "kills": cur_v = Global.quest_kills
			"quest_runs", "runs": cur_v = Global.quest_runs
			"quest_talents", "talents": cur_v = Global.quest_talents
			"daily_ads_watched": cur_v = Global.daily_ads_watched
			"checkin_day": cur_v = Global.checkin_day
		var max_v: int = maxi(1, int(q.get("target_amt", q.get("target_amount", q.get("target", 1)))))
		if cur_v >= max_v:
			return true
	return false

func _has_affordable_talent() -> bool:
	var tm: Node = get_node_or_null("/root/TalentManager")
	if not tm or not tm.has_method("get_cost"):
		return false
	var keys: Array = tm.TALENT_ORDER if ("TALENT_ORDER" in tm) else ["atk", "hp", "crit", "recovery", "speed", "gold"]
	for k in keys:
		var c: int = int(tm.get_cost(str(k)))
		if c > 0 and Global.total_coins >= c:
			return true
	return false

func _update_top_bar() -> void:
	var tm: Node = get_node_or_null("/root/TalentManager")
	var total_lvl: int = 1
	if tm and "talent_levels" in tm:
		for k in tm.talent_levels:
			total_lvl += int(tm.talent_levels[k])
	var callsign := Global.player_name if not Global.player_name.is_empty() else "V-77"
	var skin_name: String = str(Global.get_skin_def().get("name", "V-RUNNER"))
	if profile_level_label:
		profile_level_label.text = callsign + " • " + skin_name + " Lv." + str(total_lvl)
	if energy_label: energy_label.text = "Nuclei: " + str(Global.upgrade_scrolls)
	if coins_label: coins_label.text = str(Global.total_coins)
	if gems_label: gems_label.text = str(Global.total_credits)

	if btn_checkin_top:
		var has_gift := not Global.checkin_claimed
		btn_checkin_top.icon = CyberTheme.get_ui_icon("gift")
		btn_checkin_top.expand_icon = true
		btn_checkin_top.text = "DROP !" if has_gift else "DROP"
		CyberTheme.style_button(btn_checkin_top, CyberTheme.COL_YELLOW if has_gift else CyberTheme.COL_CYAN, has_gift)

	_update_nav_badges()

func _update_nav_badges() -> void:
	var im: Node = get_node_or_null("/root/InventoryManager")
	var equip_alert := false
	if im:
		if im.has_method("can_improve_loadout") and im.can_improve_loadout():
			equip_alert = true
		elif im.has_method("get_fusible_items") and not im.get_fusible_items().is_empty():
			equip_alert = true

	var talent_alert := _has_affordable_talent()
	var quest_alert := _has_ready_quest()
	var shop_alert := (Global.total_credits >= 100)
	var home_alert := (WorldDB.count_claimable_milestones() > 0) if WorldDB.has_method("count_claimable_milestones") else false

	_set_nav_label_text(btn_nav_shop, "MERCATO", shop_alert)
	_set_nav_label_text(btn_nav_equip, "CROMO", equip_alert)
	_set_nav_label_text(btn_nav_home, "INCURSIONE", home_alert)
	_set_nav_label_text(btn_upgrades, "SINAPSI", talent_alert)
	_set_nav_label_text(btn_nav_quests, "CONTRATTI", quest_alert)

func _set_nav_label_text(btn: Control, txt: String, has_alert: bool = false) -> void:
	if not btn: return
	var lbl := btn.find_child("Label", true, false) as Label
	if lbl:
		lbl.text = txt
	var dot := btn.find_child("AlertDot", true, false) as Control
	if dot:
		dot.visible = has_alert
		dot.queue_redraw()

func _update_nav_styles() -> void:
	_update_nav_badges()
	_style_nav_btn(btn_nav_shop, current_view == ViewMode.SHOP)
	_style_nav_btn(btn_nav_equip, current_view == ViewMode.INVENTORY)
	_style_nav_btn(btn_nav_home, current_view == ViewMode.HOME)
	_style_nav_btn(btn_upgrades, current_view == ViewMode.UPGRADES)
	_style_nav_btn(btn_nav_quests, current_view == ViewMode.QUESTS)

func _style_nav_btn(btn: Control, is_active: bool) -> void:
	if not btn:
		return
	btn.pivot_offset = btn.size / 2.0
	var label: Label = btn.find_child("Label", true, false) as Label
	if label:
		var f_bold := CyberTheme.get_cyber_font(true)
		if f_bold:
			label.add_theme_font_override("font", f_bold)
		label.add_theme_font_size_override("font_size", 13)
		if is_active:
			# Contrasto altissimo Cyberpunk 2077: testo nero ossidiana su placca Giallo Acido #FCEE0A!
			label.add_theme_color_override("font_color", Color(0.04, 0.05, 0.08, 1.0))
			label.add_theme_constant_override("outline_size", 0)
		else:
			label.add_theme_color_override("font_color", Color(0.88, 0.94, 1.0, 0.96))
			label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.07, 0.96))
			label.add_theme_constant_override("outline_size", 3)

	var nav_tex := CyberTheme.get_model_texture("res://assets/cyber_models/ui_btn_gold_3d.png" if is_active else "res://assets/cyber_models/ui_btn_cyan_3d.png")
	if nav_tex:
		var sbt := StyleBoxTexture.new()
		sbt.texture = nav_tex
		sbt.texture_margin_left = 18; sbt.texture_margin_right = 28
		sbt.texture_margin_top = 14; sbt.texture_margin_bottom = 26
		sbt.content_margin_left = 6; sbt.content_margin_right = 6
		sbt.content_margin_top = 6; sbt.content_margin_bottom = 8
		if not is_active:
			sbt.modulate_color = Color(0.90, 0.94, 1.0, 0.96)
		btn.add_theme_stylebox_override("panel", sbt)
	else:
		btn.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box())

	var target_scale := Vector2(1.05, 1.05) if is_active else Vector2(1.0, 1.0)
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", target_scale, 0.18)

func _get_rarity_color(rarity_str: String) -> Color:
	return CyberTheme.get_rarity_color(rarity_str)

func _on_world_preview_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			world_swipe_active = true
			world_swipe_start = event.position
			world_swipe_handled = false
		else:
			if world_swipe_active and not world_swipe_handled:
				var dx: float = event.position.x - world_swipe_start.x
				if absf(dx) >= 36.0:
					_cycle_world(-1 if dx > 0.0 else 1)
				else:
					var w: WorldData = WorldDB.get_selected_world()
					var w_num: int = WorldDB.world_order.find(w.id) + 1 if w else 1
					if w_num <= Global.max_unlocked_world:
						world_intel_open = not world_intel_open
						SoundFX.play_click()
						if is_instance_valid(boss_holo_node):
							boss_holo_node.queue_redraw()
					else:
						SoundFX.play_hit()
			world_swipe_active = false
	elif event is InputEventMouseMotion and world_swipe_active and not world_swipe_handled:
		var dx_m: float = event.position.x - world_swipe_start.x
		if absf(dx_m) >= 52.0:
			world_swipe_handled = true
			_cycle_world(-1 if dx_m > 0.0 else 1)
	elif event is InputEventScreenTouch:
		if event.pressed:
			world_swipe_active = true
			world_swipe_start = event.position
			world_swipe_handled = false
		else:
			if world_swipe_active and not world_swipe_handled:
				var dx_t: float = event.position.x - world_swipe_start.x
				if absf(dx_t) >= 36.0:
					_cycle_world(-1 if dx_t > 0.0 else 1)
				else:
					var w2: WorldData = WorldDB.get_selected_world()
					var w_num2: int = WorldDB.world_order.find(w2.id) + 1 if w2 else 1
					if w_num2 <= Global.max_unlocked_world:
						world_intel_open = not world_intel_open
						SoundFX.play_click()
						if is_instance_valid(boss_holo_node):
							boss_holo_node.queue_redraw()
			world_swipe_active = false

func _select_world_by_id(target_id: String, anim_dir: int = 1) -> void:
	if WorldDB.selected_world_id == target_id:
		return
	WorldDB.selected_world_id = target_id
	world_intel_open = false
	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()
	SoundFX.play_click()
	_show_home_view()
	if is_instance_valid(boss_holo_node):
		boss_holo_node.position = Vector2(28.0 * float(anim_dir), 0.0)
		boss_holo_node.modulate.a = 0.55
		var tw := create_tween().set_parallel(true)
		tw.tween_property(boss_holo_node, "position:x", 0.0, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(boss_holo_node, "modulate:a", 1.0, 0.18)

func _cycle_world(direction: int) -> void:
	var keys: Array = WorldDB.world_order if ("world_order" in WorldDB and not WorldDB.world_order.is_empty()) else WorldDB.worlds.keys()
	if keys.is_empty(): return
	var current_idx: int = keys.find(WorldDB.selected_world_id)
	if current_idx == -1: current_idx = 0
	var new_idx: int = (current_idx + direction + keys.size()) % keys.size()
	_select_world_by_id(str(keys[new_idx]), direction)

# --- VIEW NAVIGATION METHODS ---

func _hide_all_views() -> void:
	if home_view: home_view.visible = false
	if inventory_view: inventory_view.visible = false
	if upgrades_view: upgrades_view.visible = false
	if quests_view: quests_view.visible = false
	if checkin_view: checkin_view.visible = false
	if shop_view: shop_view.visible = false
	if section_title:
		section_title.visible = (current_view != ViewMode.HOME)

func _fade_in_view(view_node: Control) -> void:
	if not view_node: return
	view_node.visible = true
	view_node.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(view_node, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _show_home_view() -> void:
	current_view = ViewMode.HOME
	_update_nav_styles()
	_hide_all_views()
	_fade_in_view(home_view)

	var world: WorldData = WorldDB.get_selected_world()
	if world:
		var world_num: int = WorldDB.world_order.find(world.id) + 1
		if world_num <= 0: world_num = 1
		var is_locked: bool = (world_num > Global.max_unlocked_world)

		if world_card_name:
			world_card_name.text = ("SETTORE %02d  //  " % world_num) + world.display_name
			world_card_name.add_theme_color_override("font_color", Color(0.95, 0.32, 0.44, 1.0) if is_locked else world.accent_color)
		if world_card_info:
			world_card_info.visible = false
		if world_card_desc:
			world_card_desc.visible = false
		if btn_play_home:
			btn_play_home.custom_minimum_size = Vector2(640, 84)
			btn_play_home.disabled = is_locked
			if is_locked:
				btn_play_home.text = "ACCESSO NEGATO // SBLOCCA SETTORE %02d" % (world_num - 1)
				CyberTheme.style_button(btn_play_home, CyberTheme.COL_MAGENTA, false)
			else:
				btn_play_home.text = "AVVIA INCURSIONE »"
				CyberTheme.style_button(btn_play_home, CyberTheme.COL_YELLOW, true)
		if is_instance_valid(boss_holo_node):
			boss_holo_node.queue_redraw()

		_rebuild_sector_node_strip(world)
		_rebuild_world_milestone_bar(world, is_locked)

	_rebuild_home_loadout_dashboard()
	if home_view:
		_make_subtree_scroll_safe(home_view)

func _rebuild_sector_node_strip(selected_world: WorldData) -> void:
	var world_card: PanelContainer = find_child("WorldCard", true, false) as PanelContainer
	if not world_card:
		return
	var wc_vbox := world_card.get_node_or_null("VBox") as VBoxContainer
	if not wc_vbox:
		return

	var old_strip := wc_vbox.get_node_or_null("SectorNodeStrip")
	if old_strip:
		wc_vbox.remove_child(old_strip)
		old_strip.queue_free()

	var strip_box := VBoxContainer.new()
	strip_box.name = "SectorNodeStrip"
	strip_box.add_theme_constant_override("separation", 5)

	var grid := GridContainer.new()
	grid.columns = 6
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	strip_box.add_child(grid)

	var sel_idx: int = WorldDB.world_order.find(selected_world.id)
	for i in range(WorldDB.world_order.size()):
		var wid: String = WorldDB.world_order[i]
		var w_obj: WorldData = WorldDB.worlds.get(wid, null) as WorldData
		var w_num: int = i + 1
		var is_sel: bool = (wid == selected_world.id)
		var is_unl: bool = (w_num <= Global.max_unlocked_world)
		var best_r: int = Global.get_world_best_room(wid) if Global.has_method("get_world_best_room") else 0
		var is_cleared: bool = (w_obj != null and best_r >= w_obj.total_rooms)
		var has_claim: bool = (WorldDB.count_claimable_milestones(wid) > 0) if WorldDB.has_method("count_claimable_milestones") else false

		var n_btn := Button.new()
		n_btn.custom_minimum_size = Vector2(0, 34)
		n_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		n_btn.mouse_filter = Control.MOUSE_FILTER_PASS
		n_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		n_btn.focus_mode = Control.FOCUS_NONE
		n_btn.add_theme_font_size_override("font_size", 14)
		var f_bold := CyberTheme.get_cyber_font(true)
		if f_bold:
			n_btn.add_theme_font_override("font", f_bold)

		var num_str := "%02d" % w_num
		if has_claim:
			n_btn.text = "★ " + num_str
		elif is_cleared:
			n_btn.text = "✓ " + num_str
		elif not is_unl:
			n_btn.text = "× " + num_str
		else:
			n_btn.text = num_str

		var sb := StyleBoxFlat.new()
		var w_acc: Color = w_obj.accent_color if w_obj else CyberTheme.COL_CYAN
		if is_sel:
			sb.bg_color = CyberTheme.COL_YELLOW if is_unl else Color(0.28, 0.06, 0.12, 0.98)
			sb.border_color = Color.WHITE if is_unl else CyberTheme.COL_MAGENTA
			sb.border_width_left = 3; sb.border_width_top = 1; sb.border_width_right = 1; sb.border_width_bottom = 2
		elif has_claim:
			sb.bg_color = Color(0.22, 0.19, 0.03, 0.96)
			sb.border_color = CyberTheme.COL_YELLOW
			sb.border_width_left = 3; sb.border_width_top = 1; sb.border_width_right = 1; sb.border_width_bottom = 1
		elif is_cleared:
			sb.bg_color = Color(0.03, 0.16, 0.11, 0.94)
			sb.border_color = CyberTheme.COL_GREEN
			sb.border_width_left = 3; sb.border_width_top = 1; sb.border_width_right = 1; sb.border_width_bottom = 1
		elif is_unl:
			sb.bg_color = Color(0.05, 0.08, 0.14, 0.94)
			sb.border_color = w_acc
			sb.border_width_left = 3; sb.border_width_top = 1; sb.border_width_right = 1; sb.border_width_bottom = 1
		else:
			sb.bg_color = Color(0.025, 0.03, 0.055, 0.78)
			sb.border_color = Color(0.18, 0.22, 0.30, 0.45)
			sb.border_width_bottom = 1
		sb.corner_radius_top_left = 2; sb.corner_radius_top_right = 2
		sb.corner_radius_bottom_left = 2; sb.corner_radius_bottom_right = 6
		sb.content_margin_left = 4; sb.content_margin_right = 4
		sb.content_margin_top = 3; sb.content_margin_bottom = 3

		n_btn.add_theme_stylebox_override("normal", sb)
		n_btn.add_theme_stylebox_override("hover", sb)
		n_btn.add_theme_stylebox_override("pressed", sb)
		if is_sel and is_unl:
			n_btn.add_theme_color_override("font_color", Color(0.04, 0.05, 0.08, 1.0))
			n_btn.add_theme_constant_override("outline_size", 0)
		else:
			var fc := CyberTheme.COL_YELLOW if has_claim else (Color.WHITE if is_unl else Color(0.46, 0.52, 0.62, 0.78))
			n_btn.add_theme_color_override("font_color", fc)
			n_btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.06, 0.95))
			n_btn.add_theme_constant_override("outline_size", 2)

		var dir_hint: int = 1 if i >= sel_idx else -1
		n_btn.pressed.connect(func(): _select_world_by_id(wid, dir_hint))
		grid.add_child(n_btn)

	wc_vbox.add_child(strip_box)
	wc_vbox.move_child(strip_box, 0)

func _rebuild_world_milestone_bar(world: WorldData, is_locked: bool) -> void:
	var world_card: PanelContainer = find_child("WorldCard", true, false) as PanelContainer
	if not world_card:
		return
	var wc_vbox := world_card.get_node_or_null("VBox") as VBoxContainer
	if not wc_vbox:
		return

	var old_ms := wc_vbox.get_node_or_null("MilestoneTrackBox")
	if old_ms:
		wc_vbox.remove_child(old_ms)
		old_ms.queue_free()

	var ms_box := VBoxContainer.new()
	ms_box.name = "MilestoneTrackBox"
	ms_box.add_theme_constant_override("separation", 6)

	var best_r: int = Global.get_world_best_room(world.id) if Global.has_method("get_world_best_room") else 0
	var tot_r: int = maxi(1, world.total_rooms)
	var milestones: Array[Dictionary] = WorldDB.get_world_milestones(world.id) if WorldDB.has_method("get_world_milestones") else []

	var hdr_hb := HBoxContainer.new()
	hdr_hb.add_theme_constant_override("separation", 8)
	ms_box.add_child(hdr_hb)

	var lbl_ms_hdr := Label.new()
	lbl_ms_hdr.text = "SOGLIE RIFORNIMENTO SETTORE"
	lbl_ms_hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_ms_hdr.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(lbl_ms_hdr, CyberTheme.COL_CYAN, 2)
	hdr_hb.add_child(lbl_ms_hdr)

	var lbl_rec := Label.new()
	lbl_rec.text = ("BLOCCATO" if is_locked else ("AVANZAMENTO: ZONA " + str(best_r) + " / " + str(tot_r)))
	lbl_rec.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(lbl_rec, Color(0.65, 0.72, 0.84, 0.9) if is_locked else CyberTheme.COL_YELLOW, 2)
	hdr_hb.add_child(lbl_rec)

	var pbar := ProgressBar.new()
	pbar.custom_minimum_size = Vector2(0, 12)
	pbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pbar.max_value = tot_r
	pbar.value = mini(best_r, tot_r)
	pbar.show_percentage = false
	var pb_bg := CyberTheme.make_cyber_box(Color(0.025, 0.035, 0.065, 0.96), Color(0.18, 0.26, 0.38, 0.85), 0.0, 1, 3, 0)
	pb_bg.content_margin_top = 0; pb_bg.content_margin_bottom = 0
	var pb_fill := StyleBoxFlat.new()
	pb_fill.bg_color = CyberTheme.COL_GREEN if best_r >= tot_r else world.accent_color
	pb_fill.corner_radius_top_left = 1; pb_fill.corner_radius_bottom_right = 4
	pbar.add_theme_stylebox_override("background", pb_bg)
	pbar.add_theme_stylebox_override("fill", pb_fill)
	ms_box.add_child(pbar)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	ms_box.add_child(row)

	for m in milestones:
		var m_key: String = str(m.get("key", ""))
		var target_r: int = int(m.get("target_room", 3))
		var tier_idx: int = int(m.get("tier", 1))
		var is_claimed: bool = bool(Global.world_milestones_claimed.get(m_key, false))
		var is_ready: bool = (best_r >= target_r and not is_claimed)

		var m_card := PanelContainer.new()
		m_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		m_card.custom_minimum_size = Vector2(0, 76)
		if is_ready:
			m_card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("LEGENDARY", 8, 6))
		elif is_claimed:
			m_card.add_theme_stylebox_override("panel", CyberTheme.make_equipped_badge_box())
		else:
			m_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(8, 6, Color(0.82, 0.88, 0.96, 0.92)))

		var mv := VBoxContainer.new()
		mv.alignment = BoxContainer.ALIGNMENT_CENTER
		mv.add_theme_constant_override("separation", 2)
		mv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		m_card.add_child(mv)

		var top_hb := HBoxContainer.new()
		top_hb.alignment = BoxContainer.ALIGNMENT_CENTER
		top_hb.add_theme_constant_override("separation", 5)
		top_hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mv.add_child(top_hb)

		var ico := TextureRect.new()
		ico.custom_minimum_size = Vector2(20, 20)
		ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ico.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ico_name := "core" if tier_idx == 1 else ("gem" if tier_idx == 2 else "gift")
		ico.texture = CyberTheme.get_ui_icon(ico_name)
		top_hb.add_child(ico)

		var l_t := Label.new()
		l_t.text = str(m.get("title", "ZONA"))
		l_t.add_theme_font_size_override("font_size", 13)
		l_t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		CyberTheme.style_label(l_t, CyberTheme.COL_YELLOW if is_ready else (CyberTheme.COL_GREEN if is_claimed else Color.WHITE), 2)
		top_hb.add_child(l_t)

		var l_rew := Label.new()
		var c_v: int = int(m.get("coins", 0))
		var g_v: int = int(m.get("gems", 0))
		var s_v: int = int(m.get("scrolls", 0))
		var gr_s: String = str(m.get("gear_rarity", ""))
		var short_parts: Array[String] = []
		if g_v > 0: short_parts.append("+" + str(g_v) + " Gemme")
		if c_v > 0: short_parts.append("+" + str(c_v) + "¢")
		if s_v > 0 and gr_s.is_empty(): short_parts.append("+" + str(s_v) + " Nuclei")
		if not gr_s.is_empty(): short_parts.append("Cromo " + ("MK.III" if gr_s == "EPIC" else "MK.II"))
		l_rew.text = " • ".join(short_parts)
		l_rew.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l_rew.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		l_rew.add_theme_font_size_override("font_size", 12)
		l_rew.mouse_filter = Control.MOUSE_FILTER_IGNORE
		CyberTheme.style_label(l_rew, Color(0.86, 0.94, 1.0, 0.96), 2)
		mv.add_child(l_rew)

		var l_st := Label.new()
		l_st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l_st.add_theme_font_size_override("font_size", 12)
		l_st.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if is_ready:
			l_st.text = "★ TOCCA E RISCATTA"
			CyberTheme.style_label(l_st, CyberTheme.COL_YELLOW, 2)
		elif is_claimed:
			l_st.text = "✓ ACQUISITO"
			CyberTheme.style_label(l_st, Color(0.82, 1.0, 0.92, 1.0), 2)
		else:
			l_st.text = "SOGLIA " + str(int(round(float(target_r) / float(tot_r) * 100.0))) + "%"
			CyberTheme.style_label(l_st, Color(0.58, 0.68, 0.82, 0.85), 2)
		mv.add_child(l_st)

		if is_ready:
			var captured_m: Dictionary = m.duplicate()
			var captured_wid: String = world.id
			_connect_button(m_card, func(): _claim_world_milestone(captured_wid, captured_m))
		row.add_child(m_card)

	wc_vbox.add_child(ms_box)

func _claim_world_milestone(world_id: String, m: Dictionary) -> void:
	var m_key: String = str(m.get("key", ""))
	if m_key.is_empty() or bool(Global.world_milestones_claimed.get(m_key, false)):
		return
	var best_r: int = Global.get_world_best_room(world_id)
	if best_r < int(m.get("target_room", 999)):
		SoundFX.play_hit()
		return

	Global.world_milestones_claimed[m_key] = true
	var c_add: int = int(m.get("coins", 0))
	var g_add: int = int(m.get("gems", 0))
	var s_add: int = int(m.get("scrolls", 0))
	var gr_rar: String = str(m.get("gear_rarity", ""))
	Global.total_coins += c_add
	Global.total_credits += g_add
	Global.upgrade_scrolls += s_add

	var reward_parts: Array[String] = []
	if c_add > 0: reward_parts.append("+" + str(c_add) + " Crediti")
	if g_add > 0: reward_parts.append("+" + str(g_add) + " Gemme")
	if s_add > 0: reward_parts.append("+" + str(s_add) + " Nuclei")

	if not gr_rar.is_empty():
		var im: Node = get_node_or_null("/root/InventoryManager")
		var pool_m := [
			{"id": "katana", "name": "Katana Termica", "slot": "ARMA"},
			{"id": "laser_rifle", "name": "Fucile Laser", "slot": "ARMA"},
			{"id": "nano_armor", "name": "Corazza Nano-Tech", "slot": "CORAZZA"},
			{"id": "drone_shield", "name": "Drone Scudo", "slot": "PET 2"},
			{"id": "smg", "name": "Mitraglietta Cyber", "slot": "ARMA"},
			{"id": "ring_speed", "name": "Anello Velocità", "slot": "ANELLO 2"}
		]
		var pick_g: Dictionary = pool_m[randi() % pool_m.size()]
		if im and im.has_method("add_item"):
			im.add_item(str(pick_g["id"]), str(pick_g["name"]), str(pick_g["slot"]), gr_rar)
		reward_parts.append(str(pick_g["name"]) + " (" + CyberTheme.get_rarity_badge_text(gr_rar) + ")")

	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()
	SoundFX.play_win()
	_trigger_rewards_popup("★", "TRAGUARDO SETTORE ACQUISITO", "  •  ".join(reward_parts))
	_update_top_bar()
	_show_home_view()

func _rebuild_home_loadout_dashboard() -> void:
	var summary_card: PanelContainer = find_child("EquippedSummaryCard", true, false) as PanelContainer
	if not summary_card: return
	if equipped_summary_label:
		equipped_summary_label.visible = false

	var old_dash := summary_card.get_node_or_null("HomeLoadoutDash")
	if old_dash:
		summary_card.remove_child(old_dash)
		old_dash.queue_free()

	var dash := VBoxContainer.new()
	dash.name = "HomeLoadoutDash"
	dash.add_theme_constant_override("separation", 10)
	dash.alignment = BoxContainer.ALIGNMENT_CENTER

	var im: Node = get_node_or_null("/root/InventoryManager")
	var can_auto_eq: bool = (im != null and im.has_method("can_improve_loadout") and im.can_improve_loadout())
	var fusible_cnt: int = im.get_fusible_items().size() if (im and im.has_method("get_fusible_items")) else 0

	# Intestazione pulita senza pulsanti sottili sparsi: badge stato compatto integrato a destra!
	var hdr_row := HBoxContainer.new()
	hdr_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hdr_row.add_theme_constant_override("separation", 10)
	dash.add_child(hdr_row)

	var hdr := Label.new()
	hdr.text = "ASSETTO CROMO // OPERATIVO"
	hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_theme_font_size_override("font_size", 17)
	CyberTheme.style_label(hdr, CyberTheme.COL_CYAN, 3)
	hdr_row.add_child(hdr)

	var status_pill := PanelContainer.new()
	if can_auto_eq:
		status_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box("LEGENDARY"))
		var sl := Label.new()
		sl.text = "▲ INNESTO SUPERIORE"
		sl.add_theme_font_size_override("font_size", 13)
		CyberTheme.style_label(sl, CyberTheme.COL_YELLOW, 2)
		status_pill.add_child(sl)
	elif fusible_cnt > 0:
		status_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box("EPIC"))
		var sl2 := Label.new()
		sl2.text = "▲ SINTESI PRONTA (" + str(fusible_cnt) + ")"
		sl2.add_theme_font_size_override("font_size", 13)
		CyberTheme.style_label(sl2, Color(0.95, 0.72, 1.0, 1.0), 2)
		status_pill.add_child(sl2)
	else:
		status_pill.add_theme_stylebox_override("panel", CyberTheme.make_equipped_badge_box())
		var sl3 := Label.new()
		sl3.text = "CONFIGURA »"
		sl3.add_theme_font_size_override("font_size", 13)
		CyberTheme.style_label(sl3, Color(0.88, 1.0, 0.94, 1.0), 2)
		status_pill.add_child(sl3)
	_connect_button(status_pill, func():
		SoundFX.play_click()
		current_equip_tab = "MERGE" if (fusible_cnt > 0 and not can_auto_eq) else "ARSENAL"
		_show_inventory_view()
	)
	hdr_row.add_child(status_pill)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var wep_slot_item: Dictionary = im.get_equipped_item_in_slot("ARMA") if (im and im.has_method("get_equipped_item_in_slot")) else {}
	var wep_rar: String = str(wep_slot_item.get("rarity", "COMMON")) if not wep_slot_item.is_empty() else "COMMON"
	var eq_weapon: WeaponStats = WeaponDB.get_equipped_weapon()
	var wep_id: String = WeaponDB.equipped_weapon_id
	var wep_name: String = eq_weapon.display_name if eq_weapon else "Pistola Cyber"
	var wep_lvl: int = im.get_item_level(wep_id) if (im and im.has_method("get_item_level")) else 1
	var wep_stat_d: Dictionary = im.get_item_primary_stat(wep_id, "ARMA", wep_rar, wep_lvl) if (im and im.has_method("get_item_primary_stat")) else {"value": 14}
	var wep_dmg: int = int(wep_stat_d.get("value", 14))

	var arm_slot_item: Dictionary = im.get_equipped_item_in_slot("CORAZZA") if (im and im.has_method("get_equipped_item_in_slot")) else {}
	var arm_rar: String = str(arm_slot_item.get("rarity", "COMMON")) if not arm_slot_item.is_empty() else "COMMON"
	var arm_id: String = WeaponDB.equipped_armor_id
	var eq_armor: Dictionary = WeaponDB.armors.get(arm_id, {}) as Dictionary
	var has_armor: bool = not arm_id.is_empty() and not eq_armor.is_empty()
	var arm_name: String = str(eq_armor.get("name", "Corazza")) if has_armor else "Slot Libero"
	var arm_lvl: int = im.get_item_level(arm_id) if (im and has_armor and im.has_method("get_item_level")) else 1
	var arm_stat_d: Dictionary = im.get_item_primary_stat(arm_id, "CORAZZA", arm_rar, arm_lvl) if (im and has_armor and im.has_method("get_item_primary_stat")) else {"value": 0}
	var arm_hp: int = int(arm_stat_d.get("value", 0))

	var pet_item: Dictionary = im.get_equipped_item_in_slot("PET 1") if (im and im.has_method("get_equipped_item_in_slot")) else {}
	var has_pet: bool = not pet_item.is_empty() and not str(pet_item.get("id", "")).is_empty()
	var pet_rar: String = str(pet_item.get("rarity", "COMMON")) if has_pet else "COMMON"
	var pet_id: String = str(pet_item.get("id", "drone_laser")) if has_pet else "drone_laser"
	var pet_name: String = str(pet_item.get("name", "Drone Laser")) if has_pet else "Slot Libero"

	var showcase_items := [
		{"id": wep_id, "slot": "ARMA", "title": wep_name, "stat": "★ " + str(wep_dmg) + " ATK", "rar": wep_rar, "active": true},
		{"id": arm_id if has_armor else "kevlar", "slot": "CORAZZA", "title": arm_name, "stat": ("✦ +" + str(arm_hp) + " HP") if has_armor else "Vuoto", "rar": arm_rar, "active": has_armor},
		{"id": pet_id, "slot": "PET 1", "title": pet_name, "stat": CyberTheme.get_rarity_label_it(pet_rar) if has_pet else "Vuoto", "rar": pet_rar, "active": has_pet}
	]

	for s_info in showcase_items:
		var p := PanelContainer.new()
		p.custom_minimum_size = Vector2(198, 162)
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var s_active: bool = bool(s_info["active"])
		var s_rar: String = str(s_info["rar"])
		var c_acc: Color = CyberTheme.get_rarity_color(s_rar) if s_active else Color(0.45, 0.52, 0.64, 0.80)
		p.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(s_rar, 10, 8) if s_active else CyberTheme.make_3d_panel_box(10, 8, Color(0.75, 0.82, 0.92, 0.88)))

		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		vb.add_theme_constant_override("separation", 4)

		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 78)
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sid: String = s_info["id"]
		var sslot: String = s_info["slot"]
		spacer.draw.connect(func():
			CyberTheme.draw_item_icon(spacer, Vector2(spacer.size.x * 0.5, 40.0), sid, sslot, c_acc, 72.0, s_active)
		)
		vb.add_child(spacer)

		var l_name := Label.new()
		l_name.text = s_info["title"]
		l_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		l_name.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(l_name, Color.WHITE if s_active else Color(0.68, 0.75, 0.85, 0.88), 3)
		vb.add_child(l_name)

		var l_st := Label.new()
		l_st.text = s_info["stat"]
		l_st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l_st.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(l_st, c_acc.lightened(0.22), 2)
		vb.add_child(l_st)

		p.add_child(vb)
		_connect_button(p, func():
			current_equip_tab = "ARSENAL"
			_on_nav_equip_pressed()
		)
		hbox.add_child(p)

	dash.add_child(hbox)
	summary_card.add_child(dash)

func _show_inventory_view() -> void:
	current_view = ViewMode.INVENTORY
	_update_nav_styles()
	if section_title: section_title.text = "DOTAZIONE"
	_hide_all_views()
	_reset_main_scroll()
	_fade_in_view(inventory_view)
	_populate_inventory()

func _show_upgrades_view() -> void:
	current_view = ViewMode.UPGRADES
	_update_nav_styles()
	if section_title: section_title.text = "SINAPSI"
	_hide_all_views()
	_reset_main_scroll()
	_fade_in_view(upgrades_view)
	_populate_upgrades()

func _show_quests_view() -> void:
	current_view = ViewMode.QUESTS
	_update_nav_styles()
	if section_title: section_title.text = "CONTRATTI"
	_hide_all_views()
	_reset_main_scroll()
	_fade_in_view(quests_view)
	_populate_quests()

func _show_checkin_view() -> void:
	current_view = ViewMode.CHECKIN
	_update_nav_styles()
	if section_title: section_title.text = "DROP GIORNALIERO"
	_hide_all_views()
	_reset_main_scroll()
	_fade_in_view(checkin_view)
	_populate_checkin()

func _show_shop_view() -> void:
	current_view = ViewMode.SHOP
	_update_nav_styles()
	if section_title: section_title.text = "MERCATO"
	_hide_all_views()
	_reset_main_scroll()
	_fade_in_view(shop_view)
	_populate_shop()

# --- POPULATION & ACTIONS ---

func _open_item_action_modal(item_data: Dictionary) -> void:
	var modal_scene := preload("res://scenes/ItemActionModal.tscn")
	if modal_scene:
		var modal := modal_scene.instantiate()
		add_child(modal)
		if modal.has_method("setup_item"):
			modal.setup_item(item_data)
		if modal.has_signal("action_completed"):
			modal.action_completed.connect(func():
				_update_top_bar()
				_populate_inventory()
			)

var btn_auto_equip_best: Button = null

func _get_slot_visual_meta(slot_type: String) -> Dictionary:
	var s := slot_type.to_upper()
	if "ARMA" in s:
		return {"tag": "⚔ ARMA", "short": "ARMA", "col": Color(1.0, 0.62, 0.14, 1.0), "order": 0}
	elif "CORAZZA" in s:
		return {"tag": "🛡 CORAZZA", "short": "CORAZZA", "col": Color(0.12, 0.96, 0.60, 1.0), "order": 1}
	elif "ANELLO" in s:
		return {"tag": "◎ ANELLO", "short": "ANELLO", "col": Color(0.84, 0.38, 1.0, 1.0), "order": 2}
	else:
		return {"tag": "✦ DRONE", "short": "DRONE", "col": Color(0.0, 0.92, 1.0, 1.0), "order": 3}

func _make_slot_category_pill(slot_type: String) -> PanelContainer:
	var meta := _get_slot_visual_meta(slot_type)
	var col: Color = meta["col"]
	var pill := PanelContainer.new()
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(col.r * 0.22 + 0.03, col.g * 0.22 + 0.04, col.b * 0.22 + 0.06, 0.96)
	sb.border_color = col
	sb.border_width_left = 3
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 2; sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2; sb.corner_radius_bottom_right = 5
	sb.content_margin_left = 6; sb.content_margin_right = 6
	sb.content_margin_top = 1; sb.content_margin_bottom = 1
	pill.add_theme_stylebox_override("panel", sb)
	var lbl := Label.new()
	lbl.text = str(meta["tag"])
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_font_size_override("font_size", 11)
	CyberTheme.style_label(lbl, col.lightened(0.24), 2)
	pill.add_child(lbl)
	return pill

func _update_active_slot_ui(slot_node_name: String, slot_type: String) -> void:
	var slot_panel: PanelContainer = find_child(slot_node_name, true, false) as PanelContainer
	if not slot_panel: return

	var im: Node = get_node_or_null("/root/InventoryManager")
	var eq_item: Dictionary = im.get_equipped_item_in_slot(slot_type) if (im and im.has_method("get_equipped_item_in_slot")) else {}

	# Rimuove IMMEDIATAMENTE dal parent tutti i nodi precedenti -> ZERO sovrapposizioni quando cambi arma/equip!
	for ch in slot_panel.get_children().duplicate():
		if ch.name == "Lbl":
			(ch as Control).visible = false
		elif ch.name != "_NativeHitBtn":
			slot_panel.remove_child(ch)
			ch.queue_free()

	var is_empty: bool = eq_item.is_empty() or str(eq_item.get("id", "")).is_empty()
	var item_id: String = str(eq_item.get("id", ""))
	var item_lvl: int = im.get_item_level(item_id) if (im and not is_empty and im.has_method("get_item_level")) else 1
	var rar_str: String = str(eq_item.get("rarity", "COMMON")) if not is_empty else "COMMON"
	var meta := _get_slot_visual_meta(slot_type)
	var cat_col: Color = meta["col"]
	var rar_col: Color = CyberTheme.get_rarity_color(rar_str) if not is_empty else Color(0.45, 0.54, 0.68, 0.65)

	if is_empty:
		slot_panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(8, 6, Color(0.75, 0.82, 0.92, 0.85)))
	else:
		slot_panel.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(rar_str, 8, 6))

	var hb := HBoxContainer.new()
	hb.name = "SlotContentHBox"
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_theme_constant_override("separation", 6)
	hb.alignment = BoxContainer.ALIGNMENT_CENTER

	var model_ctrl := Control.new()
	model_ctrl.custom_minimum_size = Vector2(50, 74)
	model_ctrl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	model_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fallback_id := "pistol_base"
	if "CORAZZA" in slot_type: fallback_id = "kevlar"
	elif "ANELLO" in slot_type: fallback_id = "ring_crit"
	elif "PET" in slot_type: fallback_id = "drone_laser"
	var draw_id := item_id if not is_empty else fallback_id
	model_ctrl.draw.connect(func():
		CyberTheme.draw_item_icon(model_ctrl, Vector2(25.0, 38.0), draw_id, slot_type, rar_col, 48.0, not is_empty)
	)
	hb.add_child(model_ctrl)

	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 2)

	var l_slot := Label.new()
	l_slot.text = str(meta["tag"]) if is_empty else (str(meta["tag"]) + " • Lv." + str(item_lvl))
	l_slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l_slot.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l_slot.add_theme_font_size_override("font_size", 12)
	CyberTheme.style_label(l_slot, cat_col, 2)
	vb.add_child(l_slot)

	var l_name := Label.new()
	l_name.text = "[ VUOTO ]" if is_empty else str(eq_item.get("name", slot_type))
	l_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l_name.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(l_name, Color(0.54, 0.62, 0.74, 0.78) if is_empty else Color.WHITE, 3)
	vb.add_child(l_name)

	if not is_empty and im and im.has_method("get_item_primary_stat"):
		var st_d: Dictionary = im.get_item_primary_stat(item_id, slot_type, rar_str, item_lvl)
		var l_rar := Label.new()
		l_rar.text = "+" + str(st_d.get("value", 0)) + " " + str(st_d.get("unit", "ATK"))
		l_rar.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l_rar.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		l_rar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l_rar.add_theme_font_size_override("font_size", 12)
		CyberTheme.style_label(l_rar, rar_col.lightened(0.24), 2)
		vb.add_child(l_rar)

	hb.add_child(vb)
	slot_panel.add_child(hb)
	var hit_b := slot_panel.get_node_or_null("_NativeHitBtn")
	if hit_b:
		slot_panel.move_child(hit_b, slot_panel.get_child_count() - 1)

func _setup_equip_subtabs() -> void:
	if not inventory_view:
		return
	hero_section_panel = inventory_view.get_node_or_null("HeroSection") as Control
	forge_section_panel = inventory_view.get_node_or_null("ForgeSection") as Control
	inventory_title_lbl = inventory_view.get_node_or_null("InventoryTitle") as Label
	if inventory_grid:
		inventory_grid.columns = 3

	if not inventory_view.get_node_or_null("EquipSegHousing"):
		var seg_house := PanelContainer.new()
		seg_house.name = "EquipSegHousing"
		seg_house.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.03, 0.05, 0.10, 0.98), Color(0.24, 0.48, 0.76, 0.85), 0.0, 2, 4, 3))

		equip_sub_nav = HBoxContainer.new()
		equip_sub_nav.name = "EquipSubNav"
		equip_sub_nav.custom_minimum_size = Vector2(0, 56)
		equip_sub_nav.add_theme_constant_override("separation", 7)
		equip_sub_nav.alignment = BoxContainer.ALIGNMENT_CENTER
		seg_house.add_child(equip_sub_nav)

		# Ordine richiesto: [ SKIN ]  [ DOTAZIONE ]  [ CALIBRA ]  [ SINTESI ] — grandi, visibili e senza numeri!
		btn_equip_tab_skins = Button.new()
		btn_equip_tab_skins.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_equip_tab_skins.custom_minimum_size = Vector2(0, 54)
		btn_equip_tab_skins.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		btn_equip_tab_skins.text = "SKIN"
		btn_equip_tab_skins.add_theme_font_size_override("font_size", 16)
		btn_equip_tab_skins.pressed.connect(func(): _switch_equip_tab("SKINS"))
		equip_sub_nav.add_child(btn_equip_tab_skins)

		btn_equip_tab_arsenal = Button.new()
		btn_equip_tab_arsenal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_equip_tab_arsenal.custom_minimum_size = Vector2(0, 54)
		btn_equip_tab_arsenal.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		btn_equip_tab_arsenal.text = "DOTAZIONE"
		btn_equip_tab_arsenal.add_theme_font_size_override("font_size", 16)
		btn_equip_tab_arsenal.pressed.connect(func(): _switch_equip_tab("ARSENAL"))
		equip_sub_nav.add_child(btn_equip_tab_arsenal)

		btn_equip_tab_upgrade = Button.new()
		btn_equip_tab_upgrade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_equip_tab_upgrade.custom_minimum_size = Vector2(0, 54)
		btn_equip_tab_upgrade.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		btn_equip_tab_upgrade.text = "CALIBRA"
		btn_equip_tab_upgrade.add_theme_font_size_override("font_size", 16)
		btn_equip_tab_upgrade.pressed.connect(func(): _switch_equip_tab("UPGRADE"))
		equip_sub_nav.add_child(btn_equip_tab_upgrade)

		btn_equip_tab_merge = Button.new()
		btn_equip_tab_merge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_equip_tab_merge.custom_minimum_size = Vector2(0, 54)
		btn_equip_tab_merge.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		btn_equip_tab_merge.text = "SINTESI"
		btn_equip_tab_merge.add_theme_font_size_override("font_size", 16)
		btn_equip_tab_merge.pressed.connect(func(): _switch_equip_tab("MERGE"))
		equip_sub_nav.add_child(btn_equip_tab_merge)

		inventory_view.add_child(seg_house)
		inventory_view.move_child(seg_house, 0)

	if hero_section_panel:
		var hero_vb := hero_section_panel.get_node_or_null("VBox") as VBoxContainer
		if hero_vb and not hero_vb.get_node_or_null("HeroActionRow"):
			var act_row := HBoxContainer.new()
			act_row.name = "HeroActionRow"
			act_row.alignment = BoxContainer.ALIGNMENT_CENTER
			act_row.add_theme_constant_override("separation", 8)

			btn_hero_skin_badge = Button.new()
			btn_hero_skin_badge.name = "BtnHeroSkinBadge"
			btn_hero_skin_badge.custom_minimum_size = Vector2(280, 50)
			btn_hero_skin_badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_hero_skin_badge.mouse_filter = Control.MOUSE_FILTER_PASS
			btn_hero_skin_badge.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
			btn_hero_skin_badge.add_theme_font_size_override("font_size", 14)
			btn_hero_skin_badge.pressed.connect(func():
				_switch_equip_tab("SKINS")
			)
			act_row.add_child(btn_hero_skin_badge)

			btn_auto_equip_best = Button.new()
			btn_auto_equip_best.name = "BtnAutoEquipBest"
			btn_auto_equip_best.custom_minimum_size = Vector2(280, 50)
			btn_auto_equip_best.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_auto_equip_best.mouse_filter = Control.MOUSE_FILTER_PASS
			btn_auto_equip_best.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
			btn_auto_equip_best.add_theme_font_size_override("font_size", 15)
			btn_auto_equip_best.pressed.connect(func():
				var im: Node = get_node_or_null("/root/InventoryManager")
				if im and im.has_method("auto_equip_best"):
					var n_ch: int = im.auto_equip_best()
					if n_ch > 0:
						SoundFX.play_win()
					else:
						SoundFX.play_click()
					_update_top_bar()
					_populate_inventory()
			)
			act_row.add_child(btn_auto_equip_best)
			hero_vb.add_child(act_row)

	if not inventory_view.get_node_or_null("SkinsWorkshopBox"):
		skins_workshop_box = VBoxContainer.new()
		skins_workshop_box.name = "SkinsWorkshopBox"
		skins_workshop_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		skins_workshop_box.add_theme_constant_override("separation", 10)
		skins_workshop_box.visible = false
		inventory_view.add_child(skins_workshop_box)

	if not inventory_view.get_node_or_null("UpgradeWorkshopBox"):
		upgrade_workshop_box = VBoxContainer.new()
		upgrade_workshop_box.name = "UpgradeWorkshopBox"
		upgrade_workshop_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		upgrade_workshop_box.add_theme_constant_override("separation", 10)
		upgrade_workshop_box.visible = false
		inventory_view.add_child(upgrade_workshop_box)

	if not inventory_view.get_node_or_null("MergeWorkshopBox"):
		merge_workshop_box = VBoxContainer.new()
		merge_workshop_box.name = "MergeWorkshopBox"
		merge_workshop_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		merge_workshop_box.add_theme_constant_override("separation", 10)
		merge_workshop_box.visible = false
		inventory_view.add_child(merge_workshop_box)

	var active_slots := [
		{"node": "SlotWeapon", "slot": "ARMA"},
		{"node": "SlotArmor", "slot": "CORAZZA"},
		{"node": "SlotRing1", "slot": "ANELLO 1"},
		{"node": "SlotRing2", "slot": "ANELLO 2"},
		{"node": "SlotPet1", "slot": "PET 1"},
		{"node": "SlotPet2", "slot": "PET 2"}
	]
	for s_cfg in active_slots:
		var sp := find_child(str(s_cfg["node"]), true, false) as Control
		var stype := str(s_cfg["slot"])
		if sp:
			_connect_button(sp, func():
				var im: Node = get_node_or_null("/root/InventoryManager")
				if im and im.has_method("get_equipped_item_in_slot"):
					var eq_d: Dictionary = im.get_equipped_item_in_slot(stype)
					if not eq_d.is_empty() and not str(eq_d.get("id", "")).is_empty():
						SoundFX.play_click()
						_open_item_action_modal(eq_d)
			)

func _switch_equip_tab(tab_id: String) -> void:
	SoundFX.play_click()
	current_equip_tab = tab_id
	upgrade_feedback_msg = ""
	_populate_inventory()

func _populate_inventory() -> void:
	var im: Node = get_node_or_null("/root/InventoryManager")
	var fusible: Array = []
	if im and im.has_method("get_fusible_items"):
		fusible = im.get_fusible_items()
	var can_improve: bool = (im != null and im.has_method("can_improve_loadout") and im.can_improve_loadout())

	# Aggiorna stile dei 4 pulsanti CROMO: [ SKIN | DOTAZIONE | CALIBRA | SINTESI ] (senza numeri tra parentesi!)
	if btn_equip_tab_skins:
		btn_equip_tab_skins.text = "SKIN"
		CyberTheme.style_segmented_tab(btn_equip_tab_skins, current_equip_tab == "SKINS", CyberTheme.COL_GREEN)
	if btn_equip_tab_arsenal:
		btn_equip_tab_arsenal.text = "DOTAZIONE"
		CyberTheme.style_segmented_tab(btn_equip_tab_arsenal, current_equip_tab == "ARSENAL", CyberTheme.COL_CYAN)
	if btn_equip_tab_upgrade:
		btn_equip_tab_upgrade.text = "CALIBRA"
		CyberTheme.style_segmented_tab(btn_equip_tab_upgrade, current_equip_tab == "UPGRADE", CyberTheme.COL_YELLOW)
	if btn_equip_tab_merge:
		btn_equip_tab_merge.text = "SINTESI"
		CyberTheme.style_segmented_tab(btn_equip_tab_merge, current_equip_tab == "MERGE", CyberTheme.COL_MAGENTA)

	if btn_hero_skin_badge:
		btn_hero_skin_badge.visible = false

	if btn_auto_equip_best:
		btn_auto_equip_best.visible = can_improve
		if can_improve:
			btn_auto_equip_best.text = "▲ EQUIPAGGIA IL MEGLIO »"
			CyberTheme.style_button(btn_auto_equip_best, CyberTheme.COL_YELLOW, true)

	var show_arsenal: bool = (current_equip_tab == "ARSENAL")
	var show_skins: bool = (current_equip_tab == "SKINS")
	var show_upgrade: bool = (current_equip_tab == "UPGRADE")
	var show_merge: bool = (current_equip_tab == "MERGE")

	if section_title and current_view == ViewMode.INVENTORY:
		if show_arsenal:
			section_title.text = "DOTAZIONE"
		elif show_skins:
			section_title.text = "SKIN OPERATIVO"
		elif show_upgrade:
			section_title.text = "CALIBRA"
		else:
			section_title.text = "SINTESI 3-IN-1"

	if hero_section_panel: hero_section_panel.visible = show_arsenal
	if inventory_title_lbl: inventory_title_lbl.visible = false
	if inventory_grid: inventory_grid.visible = show_arsenal
	if skins_workshop_box: skins_workshop_box.visible = show_skins
	if upgrade_workshop_box: upgrade_workshop_box.visible = show_upgrade
	if forge_section_panel: forge_section_panel.visible = show_merge
	if merge_workshop_box: merge_workshop_box.visible = show_merge

	# Barra Filtro Categorie Equipaggiamento (compatta e visuale, senza sottotitoli prolissi!)
	if inventory_view:
		var old_leg := inventory_view.get_node_or_null("RarityLegendBar")
		if old_leg:
			inventory_view.remove_child(old_leg)
			old_leg.queue_free()

		var old_flt := inventory_view.get_node_or_null("GearFilterBar")
		if old_flt:
			inventory_view.remove_child(old_flt)
			old_flt.queue_free()

		if show_arsenal:
			var flt_bar := PanelContainer.new()
			flt_bar.name = "GearFilterBar"
			flt_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			flt_bar.mouse_filter = Control.MOUSE_FILTER_PASS
			flt_bar.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(8, 6))

			var flt_row := HBoxContainer.new()
			flt_row.alignment = BoxContainer.ALIGNMENT_CENTER
			flt_row.add_theme_constant_override("separation", 5)
			flt_row.mouse_filter = Control.MOUSE_FILTER_PASS
			flt_bar.add_child(flt_row)

			var filters := [
				{"id": "ALL", "txt": "TUTTI", "col": CyberTheme.COL_YELLOW},
				{"id": "ARMA", "txt": "ARMI", "col": Color(1.0, 0.62, 0.14, 1.0)},
				{"id": "CORAZZA", "txt": "CORAZZE", "col": Color(0.12, 0.96, 0.60, 1.0)},
				{"id": "ANELLO", "txt": "ANELLI", "col": Color(0.84, 0.38, 1.0, 1.0)},
				{"id": "DRONE", "txt": "DRONI", "col": Color(0.0, 0.92, 1.0, 1.0)}
			]
			for f_def in filters:
				var fb := Button.new()
				fb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				fb.custom_minimum_size = Vector2(0, 38)
				fb.mouse_filter = Control.MOUSE_FILTER_PASS
				fb.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
				fb.text = str(f_def["txt"])
				fb.add_theme_font_size_override("font_size", 13)
				var fid: String = str(f_def["id"])
				CyberTheme.style_segmented_tab(fb, current_gear_filter == fid, f_def["col"])
				fb.pressed.connect(func():
					SoundFX.play_click()
					current_gear_filter = fid
					_populate_inventory()
				)
				flt_row.add_child(fb)

			inventory_view.add_child(flt_bar)
			if inventory_grid:
				inventory_view.move_child(flt_bar, inventory_grid.get_index())

	# Update 6 Active Slots visuals around hero
	_update_active_slot_ui("SlotWeapon", "ARMA")
	_update_active_slot_ui("SlotArmor", "CORAZZA")
	_update_active_slot_ui("SlotRing1", "ANELLO 1")
	_update_active_slot_ui("SlotRing2", "ANELLO 2")
	_update_active_slot_ui("SlotPet1", "PET 1")
	_update_active_slot_ui("SlotPet2", "PET 2")

	var tm: Node = get_node_or_null("/root/TalentManager")
	var atk_bonus: int = int(tm.get_bonus_value("atk")) if (tm and tm.has_method("get_bonus_value")) else 0
	var hp_bonus: int = int(tm.get_bonus_value("hp")) if (tm and tm.has_method("get_bonus_value")) else 0
	var crit_bonus: int = int(tm.get_bonus_value("crit")) if (tm and tm.has_method("get_bonus_value")) else 0
	var speed_bonus: int = int(tm.get_bonus_value("speed")) if (tm and tm.has_method("get_bonus_value")) else 0

	var wep_slot_eq: Dictionary = im.get_equipped_item_in_slot("ARMA") if (im and im.has_method("get_equipped_item_in_slot")) else {}
	var wep_rar_eq: String = str(wep_slot_eq.get("rarity", "COMMON")) if not wep_slot_eq.is_empty() else "COMMON"
	var wep_lvl: int = im.get_item_level(WeaponDB.equipped_weapon_id) if (im and im.has_method("get_item_level")) else 1
	var wep_st_eq: Dictionary = im.get_item_primary_stat(WeaponDB.equipped_weapon_id, "ARMA", wep_rar_eq, wep_lvl) if (im and im.has_method("get_item_primary_stat")) else {"value": 14}
	var base_atk: int = int(wep_st_eq.get("value", 14))

	var arm_slot_eq: Dictionary = im.get_equipped_item_in_slot("CORAZZA") if (im and im.has_method("get_equipped_item_in_slot")) else {}
	var arm_rar_eq: String = str(arm_slot_eq.get("rarity", "COMMON")) if not arm_slot_eq.is_empty() else "COMMON"
	var arm_lvl: int = im.get_item_level(WeaponDB.equipped_armor_id) if (im and not WeaponDB.equipped_armor_id.is_empty() and im.has_method("get_item_level")) else 1
	var arm_st_eq: Dictionary = im.get_item_primary_stat(WeaponDB.equipped_armor_id, "CORAZZA", arm_rar_eq, arm_lvl) if (im and not WeaponDB.equipped_armor_id.is_empty() and im.has_method("get_item_primary_stat")) else {"value": 0}
	var armor_bonus: int = int(arm_st_eq.get("value", 0))

	var cls_atk: int = 4 if Global.player_class == "NETRUNNER" else 0
	var cls_hp: int = 40 if Global.player_class == "VANGUARD" else 0
	var cls_crit: int = 5 if Global.player_class == "RONIN" else 0
	var cls_spd: int = 30 if Global.player_class == "RONIN" else 0

	var skin_st: Dictionary = Global.get_skin_def()
	var skin_hp: int = int(skin_st.get("hp_flat", 0))
	var skin_crit: int = int(round(float(skin_st.get("crit_pct", 0.0))))
	var skin_atk_pct: float = float(skin_st.get("atk_pct", 0.0))
	var skin_spd_pct: float = float(skin_st.get("spd_pct", 0.0))

	var total_atk: int = base_atk + atk_bonus + cls_atk
	if skin_atk_pct > 0.0:
		total_atk += maxi(3, int(round(float(total_atk) * (skin_atk_pct / 100.0))))
	var total_hp: int = 100 + hp_bonus + armor_bonus + cls_hp + skin_hp
	var total_crit: int = 10 + crit_bonus + cls_crit + skin_crit
	var total_speed: int = int(round(float(300 + speed_bonus + cls_spd + int(WeaponDB.get_equipped_boots_speed_bonus())) * (1.0 + skin_spd_pct / 100.0)))

	if hero_atk_label != null: hero_atk_label.text = "★ ATK: " + str(total_atk)
	if hero_hp_label != null: hero_hp_label.text = "✦ HP: " + str(total_hp)
	if hero_crit_label != null: hero_crit_label.text = "◆ CRIT: " + str(total_crit) + "%"
	if hero_speed_label != null: hero_speed_label.text = "⚡ VEL: " + str(total_speed)

	if merge_status_label:
		merge_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if not fusible.is_empty():
			var f_item: Dictionary = fusible[0]
			merge_status_label.text = "★ Pronto: 3x " + str(f_item["name"]) + " (" + CyberTheme.get_rarity_label_it(str(f_item["rarity"])) + ")"
		else:
			merge_status_label.text = "3 copie uguali ➔ Rarità Superiore"

	if show_arsenal and inventory_grid:
		inventory_grid.columns = 3
		for child in inventory_grid.get_children().duplicate():
			inventory_grid.remove_child(child)
			child.queue_free()

		var raw_items: Array = []
		if im and "inventory" in im: raw_items = im.inventory

		var filtered: Array = []
		for item in raw_items:
			var item_id: String = str(item.get("id", ""))
			var item_rar: String = str(item.get("rarity", "COMMON"))
			var cnt: int = int(item.get("count", 1))
			var is_eq: bool = im.is_item_equipped(item_id, item_rar) if (im and im.has_method("is_item_equipped")) else false
			if cnt <= 0 and not is_eq:
				continue
			var sl_cat: String = str(_get_slot_visual_meta(str(item.get("slot", "ARMA"))).get("short", "ARMA"))
			if current_gear_filter != "ALL" and sl_cat != current_gear_filter:
				continue
			filtered.append(item)

		var rar_rank := {"LEGENDARY": 3, "EPIC": 2, "RARE": 1, "COMMON": 0}
		filtered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var oa: int = int(_get_slot_visual_meta(str(a.get("slot", ""))).get("order", 9))
			var ob: int = int(_get_slot_visual_meta(str(b.get("slot", ""))).get("order", 9))
			if oa != ob:
				return oa < ob
			var ra: int = int(rar_rank.get(str(a.get("rarity", "COMMON")).to_upper(), 0))
			var rb: int = int(rar_rank.get(str(b.get("rarity", "COMMON")).to_upper(), 0))
			return ra > rb
		)

		for item in filtered:
			var item_id: String = str(item.get("id", ""))
			var item_rar: String = str(item.get("rarity", "COMMON"))
			var cnt: int = int(item.get("count", 1))
			var is_eq: bool = im.is_item_equipped(item_id, item_rar) if (im and im.has_method("is_item_equipped")) else false
			var i_lvl: int = im.get_item_level(item_id) if (im and im.has_method("get_item_level")) else 1
			var card := _create_gear_grid_card(item, item_id, str(item["name"]), str(item["slot"]), item.get("rarity", "COMMON"), is_eq, cnt, i_lvl)
			inventory_grid.add_child(card)
	elif show_skins:
		_populate_skins_workshop()
	elif show_upgrade:
		_populate_upgrade_workshop(im)
	elif show_merge:
		_populate_merge_workshop(im)
	if inventory_view:
		_make_subtree_scroll_safe(inventory_view)

func _populate_skins_workshop() -> void:
	if not skins_workshop_box:
		return
	for ch in skins_workshop_box.get_children().duplicate():
		skins_workshop_box.remove_child(ch)
		ch.queue_free()

	var info_card := PanelContainer.new()
	info_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(12, 8))
	var active_d: Dictionary = Global.get_skin_def()
	var i_hdr := Label.new()
	i_hdr.text = "ATTIVA: " + str(active_d.get("name", "V-RUNNER")) + "  •  " + str(active_d.get("perk_desc", ""))
	i_hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	i_hdr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	i_hdr.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(i_hdr, CyberTheme.COL_YELLOW, 3)
	info_card.add_child(i_hdr)
	skins_workshop_box.add_child(info_card)

	var any_locked := false
	for sid in Global.SKIN_ORDER:
		var s_def: Dictionary = Global.get_skin_def(sid)
		var is_unl: bool = Global.is_skin_unlocked(sid)
		if not is_unl:
			any_locked = true
		var is_eq: bool = (Global.equipped_skin_id == sid)
		var rar_s: String = str(s_def.get("rarity", "EPIC"))
		var acc_c: Color = s_def.get("accent", CyberTheme.COL_CYAN)
		var req_w: int = int(s_def.get("unlock_world", 1))
		var g_cost: int = int(s_def.get("gem_cost", 300))

		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(rar_s if is_unl else "COMMON", 12, 10))

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		card.add_child(row)

		# Ritratto 3D HD della Skin su pedana neon
		var p_ctrl := Control.new()
		p_ctrl.custom_minimum_size = Vector2(106, 118)
		p_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var skin_tex := CyberTheme.get_model_texture("res://assets/cyber_models/skin_preview_" + sid + ".png")
		p_ctrl.draw.connect(func():
			p_ctrl.draw_set_transform(Vector2(53, 104), 0.0, Vector2(1.0, 0.36))
			p_ctrl.draw_circle(Vector2.ZERO, 42.0, Color(0.04, 0.07, 0.14, 0.95))
			p_ctrl.draw_arc(Vector2.ZERO, 42.0, 0.0, TAU, 28, acc_c, 2.4)
			p_ctrl.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			if skin_tex:
				var mod_c := Color.WHITE if is_unl else Color(0.55, 0.60, 0.72, 0.92)
				p_ctrl.draw_texture_rect(skin_tex, Rect2(Vector2(3, 2), Vector2(100, 104)), false, mod_c)
		)
		row.add_child(p_ctrl)

		var mid_v := VBoxContainer.new()
		mid_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mid_v.add_theme_constant_override("separation", 4)
		mid_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(mid_v)

		var l_role := Label.new()
		l_role.text = str(s_def.get("role", "OPERATIVO")) + ("  •  ✓ ATTIVO" if is_eq else "")
		l_role.add_theme_font_size_override("font_size", 12)
		CyberTheme.style_label(l_role, CyberTheme.COL_GREEN if is_eq else acc_c, 2)
		mid_v.add_child(l_role)

		var l_nm := Label.new()
		l_nm.text = str(s_def.get("name", sid))
		l_nm.add_theme_font_size_override("font_size", 19)
		CyberTheme.style_label(l_nm, Color.WHITE, 3)
		mid_v.add_child(l_nm)

		var perk_box := PanelContainer.new()
		perk_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		perk_box.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.03, 0.05, 0.10, 0.95), acc_c, 0.0, 1, 3, 0))
		var l_pk := Label.new()
		l_pk.text = "★ " + str(s_def.get("perk_desc", ""))
		l_pk.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l_pk.add_theme_font_size_override("font_size", 13)
		CyberTheme.style_label(l_pk, CyberTheme.COL_YELLOW if is_eq else Color(0.90, 0.96, 1.0, 1.0), 2)
		perk_box.add_child(l_pk)
		mid_v.add_child(perk_box)

		if not is_unl:
			var l_req := Label.new()
			l_req.text = "Gratis al Settore %02d" % req_w
			l_req.add_theme_font_size_override("font_size", 12)
			CyberTheme.style_label(l_req, Color(0.72, 0.82, 0.96, 0.92), 2)
			mid_v.add_child(l_req)

		var right_v := VBoxContainer.new()
		right_v.custom_minimum_size = Vector2(154, 0)
		right_v.alignment = BoxContainer.ALIGNMENT_CENTER
		right_v.add_theme_constant_override("separation", 6)
		row.add_child(right_v)

		var btn_sk := Button.new()
		btn_sk.custom_minimum_size = Vector2(154, 52)
		btn_sk.mouse_filter = Control.MOUSE_FILTER_PASS
		btn_sk.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		btn_sk.add_theme_font_size_override("font_size", 14)

		if is_eq:
			btn_sk.disabled = true
			btn_sk.text = "✓ IN USO"
			CyberTheme.style_button(btn_sk, CyberTheme.COL_GREEN, false)
		elif is_unl:
			btn_sk.text = "EQUIPAGGIA »"
			CyberTheme.style_button(btn_sk, CyberTheme.COL_YELLOW, true)
			btn_sk.pressed.connect(func():
				Global.equipped_skin_id = sid
				Global.save_data()
				SoundFX.play_pickup()
				_update_top_bar()
				_populate_inventory()
			)
		else:
			btn_sk.icon = CyberTheme.get_ui_icon("gem")
			btn_sk.expand_icon = true
			btn_sk.text = str(g_cost) + " GEMME"
			CyberTheme.style_button(btn_sk, CyberTheme.COL_YELLOW if Global.total_credits >= g_cost else CyberTheme.COL_MAGENTA, Global.total_credits >= g_cost)
			btn_sk.pressed.connect(func():
				var res: Dictionary = Global.unlock_skin_with_gems(sid)
				if bool(res.get("success", false)):
					SoundFX.play_win()
					_trigger_rewards_popup("★", "NUOVO OPERATIVO SBLOCCATO!", str(s_def.get("name", sid)) + "\n" + str(s_def.get("perk_desc", "")))
					_update_top_bar()
					_populate_inventory()
				else:
					SoundFX.play_hit()
					_trigger_rewards_popup("!", "GEMME INSUFFICIENTI", "Servono " + str(g_cost) + " Gemme (o raggiungi il Settore %02d)" % req_w)
			)
		right_v.add_child(btn_sk)
		skins_workshop_box.add_child(card)

	if any_locked:
		var vip_btn := Button.new()
		vip_btn.custom_minimum_size = Vector2(0, 62)
		vip_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vip_btn.mouse_filter = Control.MOUSE_FILTER_PASS
		vip_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		vip_btn.text = "★ BUNDLE VIP EDGERUNNERS: SBLOCCA TUTTE LE 5 SKIN [ $3.99 ] »"
		vip_btn.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_button(vip_btn, CyberTheme.COL_YELLOW, true)
		vip_btn.pressed.connect(func():
			Global.unlock_all_skins_vip()
			SoundFX.play_win()
			_trigger_rewards_popup("★", "BUNDLE VIP ATTIVATO!", "Tutti i 5 Operativi Cyberpunk e i loro Perk sono sbloccati!")
			_update_top_bar()
			_populate_inventory()
		)
		skins_workshop_box.add_child(vip_btn)

func _populate_upgrade_workshop(im: Node) -> void:
	if not upgrade_workshop_box:
		return
	for child in upgrade_workshop_box.get_children().duplicate():
		upgrade_workshop_box.remove_child(child)
		child.queue_free()

	if not upgrade_feedback_msg.is_empty():
		var hdr_card := PanelContainer.new()
		hdr_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hdr_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(10, 6))
		var fb_lbl := Label.new()
		fb_lbl.text = upgrade_feedback_msg
		fb_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fb_lbl.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(fb_lbl, CyberTheme.COL_GREEN if "CALIBRATO" in upgrade_feedback_msg else CyberTheme.COL_MAGENTA, 3)
		hdr_card.add_child(fb_lbl)
		upgrade_workshop_box.add_child(hdr_card)

	if not im or not ("inventory" in im):
		return

	var unique_map: Dictionary = {}
	var rar_rank := {"COMMON": 0, "RARE": 1, "EPIC": 2, "LEGENDARY": 3}
	for raw_item in im.inventory:
		if int(raw_item.get("count", 0)) <= 0 and not im.is_item_equipped(str(raw_item.get("id", ""))):
			continue
		var iid: String = str(raw_item.get("id", ""))
		if iid.is_empty():
			continue
		var cur_rar: String = str(raw_item.get("rarity", "COMMON")).to_upper()
		if not unique_map.has(iid) or int(rar_rank.get(cur_rar, 0)) > int(rar_rank.get(str(unique_map[iid].get("rarity", "COMMON")).to_upper(), 0)):
			unique_map[iid] = raw_item

	var sorted_items: Array = []
	for k in unique_map.keys():
		if im.is_item_equipped(str(k)):
			sorted_items.append(unique_map[k])
	for k in unique_map.keys():
		if not im.is_item_equipped(str(k)):
			sorted_items.append(unique_map[k])

	for u_item in sorted_items:
		var item_id: String = str(u_item.get("id", ""))
		var item_name: String = str(u_item.get("name", item_id))
		var slot_name: String = str(u_item.get("slot", "ARMA"))
		var rar_str: String = str(u_item.get("rarity", "COMMON"))
		var rar_col := CyberTheme.get_rarity_color(rar_str)
		var is_eq: bool = im.is_item_equipped(item_id)
		var cur_lvl: int = im.get_item_level(item_id)
		var coin_cost: int = im.get_upgrade_coin_cost(item_id)
		var scroll_cost: int = im.get_upgrade_scroll_cost(item_id)
		var cur_st: Dictionary = im.get_item_primary_stat(item_id, slot_name, rar_str, cur_lvl)
		var nxt_st: Dictionary = im.get_item_primary_stat(item_id, slot_name, rar_str, cur_lvl + 1)
		var is_max_l: bool = (coin_cost < 0)
		var can_afford: bool = (not is_max_l and Global.total_coins >= coin_cost and Global.upgrade_scrolls >= scroll_cost)

		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(rar_str, 10, 8))

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(row)

		var icon_ctrl := Control.new()
		icon_ctrl.custom_minimum_size = Vector2(72, 72)
		icon_ctrl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_ctrl.draw.connect(func():
			CyberTheme.draw_item_icon(icon_ctrl, Vector2(36, 36), item_id, slot_name, rar_col, 64.0, is_eq)
		)
		row.add_child(icon_ctrl)

		var mid_v := VBoxContainer.new()
		mid_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mid_v.add_theme_constant_override("separation", 3)
		row.add_child(mid_v)

		var tags_row := HBoxContainer.new()
		tags_row.add_theme_constant_override("separation", 6)
		mid_v.add_child(tags_row)

		var rar_pill := PanelContainer.new()
		rar_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box(rar_str))
		var rar_lbl := Label.new()
		rar_lbl.text = CyberTheme.get_rarity_badge_text(rar_str)
		rar_lbl.add_theme_font_size_override("font_size", 11)
		CyberTheme.style_label(rar_lbl, rar_col.lightened(0.22), 2)
		rar_pill.add_child(rar_lbl)
		tags_row.add_child(rar_pill)

		if is_eq:
			var eq_pill := PanelContainer.new()
			eq_pill.add_theme_stylebox_override("panel", CyberTheme.make_equipped_badge_box())
			var eq_lbl := Label.new()
			eq_lbl.text = "✓ IN USO"
			eq_lbl.add_theme_font_size_override("font_size", 11)
			CyberTheme.style_label(eq_lbl, Color(0.88, 1.0, 0.94, 1.0), 2)
			eq_pill.add_child(eq_lbl)
			tags_row.add_child(eq_pill)

		var l_title := Label.new()
		l_title.text = item_name
		l_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		l_title.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(l_title, Color.WHITE, 3)
		mid_v.add_child(l_title)

		var l_lvl := Label.new()
		var st_u: String = str(cur_st.get("unit", "ATK"))
		if is_max_l:
			l_lvl.text = "LV.MAX  •  +" + str(cur_st.get("value", 0)) + " " + st_u
		else:
			l_lvl.text = "Lv." + str(cur_lvl) + " ➔ Lv." + str(cur_lvl + 1) + "  •  +" + str(cur_st.get("value", 0)) + " ➔ +" + str(nxt_st.get("value", 0)) + " " + st_u
		l_lvl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_lvl.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_label(l_lvl, CyberTheme.COL_GREEN if can_afford else CyberTheme.COL_CYAN, 2)
		mid_v.add_child(l_lvl)

		var right_v := VBoxContainer.new()
		right_v.custom_minimum_size = Vector2(148, 0)
		right_v.alignment = BoxContainer.ALIGNMENT_CENTER
		right_v.add_theme_constant_override("separation", 4)
		row.add_child(right_v)

		if not is_max_l:
			var cost_lbl := Label.new()
			cost_lbl.text = str(coin_cost) + "¢ • " + str(scroll_cost) + (" Nucleo" if scroll_cost == 1 else " Nuclei")
			cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cost_lbl.add_theme_font_size_override("font_size", 13)
			CyberTheme.style_label(cost_lbl, CyberTheme.COL_YELLOW if can_afford else Color(1.0, 0.48, 0.58, 1.0), 2)
			right_v.add_child(cost_lbl)

		var btn_up := Button.new()
		btn_up.custom_minimum_size = Vector2(148, 46)
		btn_up.mouse_filter = Control.MOUSE_FILTER_PASS
		btn_up.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		btn_up.disabled = is_max_l
		btn_up.text = "MAX" if is_max_l else ("▲ POTENZIA" if can_afford else "MANCANO RIS.")
		btn_up.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_button(btn_up, CyberTheme.COL_YELLOW if is_max_l else (CyberTheme.COL_GREEN if can_afford else CyberTheme.COL_CYAN), can_afford)
		btn_up.pressed.connect(func():
			var res: Dictionary = im.upgrade_item_level(item_id)
			upgrade_feedback_msg = str(res.get("message", ""))
			if res.get("success", false):
				SoundFX.play_pickup()
				_update_top_bar()
				_populate_inventory()
			else:
				SoundFX.play_hit()
				_populate_inventory()
		)
		right_v.add_child(btn_up)

		upgrade_workshop_box.add_child(card)

func _populate_merge_workshop(im: Node) -> void:
	if not merge_workshop_box:
		return
	for child in merge_workshop_box.get_children():
		child.queue_free()

	if not im or not ("inventory" in im):
		return

	var ready_stacks: Array = []
	var partial_stacks: Array = []
	for st in im.inventory:
		var cnt: int = int(st.get("count", 0))
		if cnt <= 0:
			continue
		var r_str: String = str(st.get("rarity", "COMMON")).to_upper()
		if cnt >= 3 and r_str != "LEGENDARY":
			ready_stacks.append(st)
		else:
			partial_stacks.append(st)

	var all_stacks: Array = []
	all_stacks.append_array(ready_stacks)
	all_stacks.append_array(partial_stacks)

	for st_item in all_stacks:
		var item_id: String = str(st_item.get("id", ""))
		var item_name: String = str(st_item.get("name", item_id))
		var slot_name: String = str(st_item.get("slot", "ARMA"))
		var rar_str: String = str(st_item.get("rarity", "COMMON")).to_upper()
		var cnt: int = int(st_item.get("count", 1))
		var is_max_rar: bool = (rar_str == "LEGENDARY")
		var next_rar: String = im.get_next_rarity(rar_str) if im.has_method("get_next_rarity") else rar_str
		var is_ready: bool = (cnt >= 3 and not is_max_rar)
		var rar_col := CyberTheme.get_rarity_color(rar_str)
		var next_col := CyberTheme.get_rarity_color(next_rar)

		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Cornice 3D SEMPRE della Rarità attuale dell'oggetto!
		card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(rar_str, 12, 10))

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(row)

		var icon_ctrl := Control.new()
		icon_ctrl.custom_minimum_size = Vector2(74, 74)
		icon_ctrl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_ctrl.draw.connect(func():
			CyberTheme.draw_item_icon(icon_ctrl, Vector2(37, 37), item_id, slot_name, rar_col, 66.0)
		)
		row.add_child(icon_ctrl)

		var mid_v := VBoxContainer.new()
		mid_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mid_v.add_theme_constant_override("separation", 4)
		row.add_child(mid_v)

		var l_title := Label.new()
		l_title.text = item_name + "  [" + slot_name + "]"
		l_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l_title.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(l_title, Color.WHITE, 3)
		mid_v.add_child(l_title)

		var l_evo := Label.new()
		l_evo.text = "★ RARITÀ MASSIMA (LEGGENDARIO)" if is_max_rar else (CyberTheme.get_rarity_badge_text(rar_str) + "  ➔  " + CyberTheme.get_rarity_badge_text(next_rar))
		l_evo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_evo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l_evo.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_label(l_evo, next_col.lightened(0.18), 2)
		mid_v.add_child(l_evo)

		var pbar := ProgressBar.new()
		pbar.custom_minimum_size = Vector2(0, 18)
		pbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pbar.max_value = 3
		pbar.value = 3 if is_max_rar else mini(cnt, 3)
		pbar.show_percentage = false
		var sb_bg := CyberTheme.make_cyber_box(Color(0.03, 0.04, 0.09, 0.95), Color(0.25, 0.35, 0.50, 0.7), 0.04, 1, 3, 0)
		var sb_fill := StyleBoxFlat.new()
		sb_fill.bg_color = CyberTheme.COL_GREEN if is_ready else rar_col
		sb_fill.corner_radius_top_left = 6; sb_fill.corner_radius_top_right = 6; sb_fill.corner_radius_bottom_left = 6; sb_fill.corner_radius_bottom_right = 6
		pbar.add_theme_stylebox_override("background", sb_bg)
		pbar.add_theme_stylebox_override("fill", sb_fill)
		mid_v.add_child(pbar)

		var right_v := VBoxContainer.new()
		right_v.custom_minimum_size = Vector2(154, 0)
		right_v.alignment = BoxContainer.ALIGNMENT_CENTER
		right_v.add_theme_constant_override("separation", 5)
		row.add_child(right_v)

		var cnt_lbl := Label.new()
		cnt_lbl.text = ("Copie: " + str(cnt)) if is_max_rar else (("✓ PRONTO 3 / 3" if is_ready else ("Copie: " + str(cnt) + " / 3")))
		cnt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cnt_lbl.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_label(cnt_lbl, CyberTheme.COL_GREEN if is_ready else Color(0.84, 0.90, 0.98, 1.0), 2)
		right_v.add_child(cnt_lbl)

		var btn_mrg := Button.new()
		btn_mrg.custom_minimum_size = Vector2(154, 48)
		btn_mrg.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_mrg.disabled = not is_ready
		if is_max_rar:
			btn_mrg.text = "MAX RARITÀ"
		elif is_ready:
			btn_mrg.text = "▲ FONDI 3-IN-1"
		else:
			btn_mrg.text = "MANCANO " + str(3 - cnt)
		btn_mrg.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_button(btn_mrg, CyberTheme.COL_GREEN if is_ready else CyberTheme.COL_MAGENTA, false)
		btn_mrg.pressed.connect(func():
			var res: Dictionary = im.merge_items(item_id, rar_str)
			if res.get("success", false):
				SoundFX.play_win()
				_trigger_rewards_popup("★", "FUSIONE COMPLETATA!", item_name + " ➔ " + CyberTheme.get_rarity_label_it(next_rar))
				_update_top_bar()
				_populate_inventory()
			else:
				SoundFX.play_hit()
		)
		right_v.add_child(btn_mrg)

		merge_workshop_box.add_child(card)

func _create_gear_grid_card(item_data: Dictionary, item_id: String, item_name: String, slot_name: String, rarity_val: Variant, is_eq: bool, count: int = 1, item_lvl: int = 1) -> PanelContainer:
	var rarity_str: String = str(rarity_val).to_upper()
	var rarity_col := CyberTheme.get_rarity_color(rarity_str)

	# Tile Inventario Stile Archero: Pulita, Immediata, Zero Badge "Anello 2" e Vantaggio Rarità Chiaro!
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(208, 214)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(rarity_str, 8, 8))

	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 3)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vb)

	var top_tags := HBoxContainer.new()
	top_tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_tags.add_theme_constant_override("separation", 4)
	vb.add_child(top_tags)

	var cat_pill := _make_slot_category_pill(slot_name)
	top_tags.add_child(cat_pill)

	var tag_spacer := Control.new()
	tag_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_tags.add_child(tag_spacer)

	if is_eq:
		var eq_pill := PanelContainer.new()
		eq_pill.name = "EquippedBadge"
		eq_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		eq_pill.add_theme_stylebox_override("panel", CyberTheme.make_equipped_badge_box())
		var eq_lbl := Label.new()
		eq_lbl.text = "✓ IN USO"
		eq_lbl.add_theme_font_size_override("font_size", 11)
		CyberTheme.style_label(eq_lbl, Color(0.90, 1.0, 0.95, 1.0), 2)
		eq_pill.add_child(eq_lbl)
		top_tags.add_child(eq_pill)
	else:
		var lvl_pill := PanelContainer.new()
		lvl_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lvl_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box(rarity_str))
		var lvl_lbl := Label.new()
		lvl_lbl.text = ("Lv." + str(item_lvl) + " • x" + str(count)) if count > 1 else ("Lv." + str(item_lvl))
		lvl_lbl.add_theme_font_size_override("font_size", 11)
		CyberTheme.style_label(lvl_lbl, rarity_col.lightened(0.28), 2)
		lvl_pill.add_child(lvl_lbl)
		top_tags.add_child(lvl_pill)

	var icon_box := Control.new()
	icon_box.custom_minimum_size = Vector2(0, 86)
	icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_box.draw.connect(func():
		CyberTheme.draw_item_icon(icon_box, Vector2(icon_box.size.x * 0.5, 44.0), item_id, slot_name, rarity_col, 80.0, is_eq)
	)
	vb.add_child(icon_box)

	var lbl_name := Label.new()
	lbl_name.text = item_name
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lbl_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl_name.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(lbl_name, Color.WHITE, 3)
	vb.add_child(lbl_name)

	var im_ref: Node = get_node_or_null("/root/InventoryManager")
	if im_ref and im_ref.has_method("get_comparison_with_equipped"):
		var cmp_d: Dictionary = im_ref.get_comparison_with_equipped(item_data)
		var cmp_txt: String = str(cmp_d.get("text", ""))
		var cmp_better: bool = bool(cmp_d.get("is_better", false))
		var lbl_stat := Label.new()
		lbl_stat.text = cmp_txt
		lbl_stat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_stat.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		lbl_stat.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl_stat.add_theme_font_size_override("font_size", 14)
		var st_col: Color = CyberTheme.COL_GREEN if cmp_better else (CyberTheme.COL_YELLOW if is_eq else Color(0.88, 0.94, 1.0, 0.96))
		CyberTheme.style_label(lbl_stat, st_col, 3)
		vb.add_child(lbl_stat)

	# Riga vantaggio passivo di Rarità (Raro/Epico/Leggendario) al posto del vecchio testo ridondante!
	var perk_short: String = ""
	if im_ref and im_ref.has_method("get_highest_unlocked_perk_short"):
		perk_short = im_ref.get_highest_unlocked_perk_short(item_id, slot_name, rarity_str)
	var lbl_perk := Label.new()
	lbl_perk.text = perk_short if not perk_short.is_empty() else "Comune"
	lbl_perk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_perk.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lbl_perk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl_perk.add_theme_font_size_override("font_size", 12)
	CyberTheme.style_label(lbl_perk, rarity_col.lightened(0.28) if not perk_short.is_empty() else Color(0.55, 0.63, 0.75, 0.80), 2)
	vb.add_child(lbl_perk)

	_connect_button(card, func():
		SoundFX.play_click()
		_open_item_action_modal(item_data)
	)

	return card

func _on_merge_all_pressed() -> void:
	var im: Node = get_node_or_null("/root/InventoryManager")
	if not im: return

	var fusible: Array = im.get_fusible_items()
	if fusible.is_empty():
		SoundFX.play_hit()
		if merge_status_label: merge_status_label.text = "! Nessun oggetto idoneo alla fusione (servono 3 copie identiche)."
		return

	var count_merged: int = 0
	for item in fusible:
		var res: Dictionary = im.merge_items(str(item["id"]), str(item["rarity"]))
		if res.get("success", false):
			count_merged += 1

	if count_merged > 0:
		SoundFX.play_win()
		if merge_status_label: merge_status_label.text = "★ Fusi con successo " + str(count_merged) + " gruppi di oggetti!"
		_populate_inventory()
	else:
		SoundFX.play_hit()

func _draw_talent_medallion(c: CanvasItem, center: Vector2, t_id: String, col: Color, unlocked: bool) -> void:
	var r: float = 28.0
	var oct := PackedVector2Array()
	for i in range(8):
		var a: float = PI * 0.125 + float(i) * TAU / 8.0
		oct.append(center + Vector2(cos(a), sin(a)) * r)
	c.draw_colored_polygon(oct, Color(0.05, 0.08, 0.16, 0.96))
	c.draw_circle(center, r * 0.72, Color(col.r, col.g, col.b, 0.24 if unlocked else 0.10))
	for i in range(8):
		c.draw_line(oct[i], oct[(i + 1) % 8], col if unlocked else Color(col.r * 0.65, col.g * 0.65, col.b * 0.72, 0.78), 2.4)

	var ic: Color = Color.WHITE if unlocked else col.lightened(0.28)
	match t_id:
		"atk":
			c.draw_line(center + Vector2(-11, 11), center + Vector2(12, -12), ic, 3.6)
			c.draw_line(center + Vector2(-8, 2), center + Vector2(-2, 8), col, 3.0)
			c.draw_circle(center + Vector2(11, -11), 3.0, col)
		"hp":
			c.draw_rect(Rect2(center + Vector2(-4, -12), Vector2(8, 24)), ic, true)
			c.draw_rect(Rect2(center + Vector2(-12, -4), Vector2(24, 8)), ic, true)
		"fire_rate":
			for off_y in [-7.0, 0.0, 7.0]:
				c.draw_line(center + Vector2(-11, off_y), center + Vector2(9, off_y), ic, 2.8)
				c.draw_circle(center + Vector2(11, off_y), 2.4, col)
		"crit":
			c.draw_arc(center, 11.0, 0.0, TAU, 20, ic, 2.2)
			c.draw_line(center + Vector2(-15, 0), center + Vector2(15, 0), col, 2.0)
			c.draw_line(center + Vector2(0, -15), center + Vector2(0, 15), col, 2.0)
			c.draw_circle(center, 3.2, col)
		"crit_dmg":
			var star := PackedVector2Array()
			for i in range(8):
				var rad: float = 13.5 if i % 2 == 0 else 5.5
				var sa: float = -PI * 0.5 + float(i) * TAU / 8.0
				star.append(center + Vector2(cos(sa), sin(sa)) * rad)
			c.draw_colored_polygon(star, ic)
		"speed":
			c.draw_polyline(PackedVector2Array([
				center + Vector2(3, -13), center + Vector2(-8, 1),
				center + Vector2(1, 1), center + Vector2(-4, 13),
				center + Vector2(9, -2), center + Vector2(0, -2), center + Vector2(3, -13)
			]), ic, 2.8)
		"dodge":
			c.draw_arc(center + Vector2(-3, 0), 11.0, -PI * 0.65, PI * 0.65, 16, ic, 2.6)
			c.draw_arc(center + Vector2(5, 0), 9.0, -PI * 0.55, PI * 0.55, 14, col, 2.2)
		"aegis":
			var sh := PackedVector2Array([
				center + Vector2(0, -13), center + Vector2(11, -7),
				center + Vector2(9, 6), center + Vector2(0, 14),
				center + Vector2(-9, 6), center + Vector2(-11, -7)
			])
			c.draw_colored_polygon(sh, Color(col.r, col.g, col.b, 0.45))
			for i in range(sh.size()):
				c.draw_line(sh[i], sh[(i + 1) % sh.size()], ic, 2.4)
		"recovery":
			c.draw_arc(center, 11.5, 0.3, TAU - 0.3, 20, col, 2.4)
			c.draw_rect(Rect2(center + Vector2(-2.5, -7), Vector2(5, 14)), ic, true)
			c.draw_rect(Rect2(center + Vector2(-7, -2.5), Vector2(14, 5)), ic, true)
		"vampirism":
			var drp := PackedVector2Array([
				center + Vector2(0, -14), center + Vector2(10, 3),
				center + Vector2(0, 13), center + Vector2(-10, 3)
			])
			c.draw_colored_polygon(drp, col)
			c.draw_circle(center + Vector2(-2, 2), 3.0, ic)
		"armor_pen":
			var tip := PackedVector2Array([
				center + Vector2(0, -14), center + Vector2(10, 8),
				center + Vector2(0, 3), center + Vector2(-10, 8)
			])
			c.draw_colored_polygon(tip, ic)
			c.draw_line(center + Vector2(-11, 11), center + Vector2(11, 11), col, 2.4)
		"drone_tech":
			c.draw_circle(center, 6.0, ic)
			c.draw_arc(center, 12.0, 0.0, TAU, 18, col, 2.0)
			c.draw_circle(center + Vector2(11, -5), 3.0, ic)
		"exp_boost":
			for off_y in [5.0, -3.0]:
				c.draw_polyline(PackedVector2Array([
					center + Vector2(-10, off_y + 5),
					center + Vector2(0, off_y - 5),
					center + Vector2(10, off_y + 5)
				]), ic if off_y < 0 else col, 3.0)
		_: # "gold"
			c.draw_circle(center, 11.5, Color(1.0, 0.84, 0.12, 0.95))
			c.draw_arc(center, 11.5, 0.0, TAU, 20, Color.WHITE, 2.0)
			c.draw_rect(Rect2(center + Vector2(-2, -6), Vector2(4, 12)), Color(0.12, 0.08, 0.02, 0.95), true)

func _format_talent_num(v: float) -> String:
	if absf(v - roundf(v)) < 0.05:
		return str(int(roundf(v)))
	return "%.1f" % v

func _populate_upgrades() -> void:
	if not talent_grid:
		return
	talent_grid.columns = 3
	talent_grid.add_theme_constant_override("h_separation", 8)
	talent_grid.add_theme_constant_override("v_separation", 10)
	for child in talent_grid.get_children().duplicate():
		talent_grid.remove_child(child)
		child.queue_free()

	var tm: Node = get_node_or_null("/root/TalentManager")
	var talent_keys: Array[String] = tm.TALENT_ORDER if (tm and "TALENT_ORDER" in tm) else [
		"atk", "hp", "fire_rate", "crit", "crit_dmg", "speed", "dodge",
		"aegis", "recovery", "vampirism", "armor_pen", "drone_tech", "exp_boost", "gold"
	]
	var talent_colors := {
		"atk": Color(1.0, 0.44, 0.18, 1.0),
		"hp": Color(0.18, 0.98, 0.56, 1.0),
		"fire_rate": Color(1.0, 0.76, 0.14, 1.0),
		"crit": Color(1.0, 0.24, 0.58, 1.0),
		"crit_dmg": Color(1.0, 0.32, 0.24, 1.0),
		"speed": Color(0.0, 0.94, 1.0, 1.0),
		"dodge": Color(0.36, 0.88, 1.0, 1.0),
		"aegis": Color(0.24, 0.78, 1.0, 1.0),
		"recovery": Color(0.25, 1.0, 0.68, 1.0),
		"vampirism": Color(1.0, 0.18, 0.42, 1.0),
		"armor_pen": Color(1.0, 0.62, 0.16, 1.0),
		"drone_tech": Color(0.78, 0.38, 1.0, 1.0),
		"exp_boost": Color(0.56, 0.82, 1.0, 1.0),
		"gold": Color(1.0, 0.86, 0.14, 1.0)
	}

	for t_id in talent_keys:
		var def: Dictionary = tm.TALENT_DEFS[t_id] if (tm and "TALENT_DEFS" in tm) else {}
		var cur_lvl: int = int(tm.talent_levels.get(t_id, 0)) if (tm and "talent_levels" in tm) else 0
		var max_lvl: int = int(def.get("max_lvl", 10))
		var step_val: float = float(def.get("bonus_per_lvl", 1.0))
		var bonus_val: float = step_val * float(cur_lvl)
		var cost: int = tm.get_cost(t_id) if (tm and tm.has_method("get_cost")) else 200
		var is_max: bool = (cost == -1 or cur_lvl >= max_lvl)
		var can_buy: bool = (not is_max and Global.total_coins >= cost)
		var t_col: Color = talent_colors.get(t_id, CyberTheme.COL_CYAN)

		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(196, 194)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		var card_rar := "LEGENDARY" if is_max else ("EPIC" if cur_lvl >= 5 else ("RARE" if cur_lvl > 0 else "COMMON"))
		card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(card_rar, 8, 8))

		var vbox := VBoxContainer.new()
		vbox.mouse_filter = Control.MOUSE_FILTER_PASS
		vbox.add_theme_constant_override("separation", 3)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(vbox)

		var lvl_pill := PanelContainer.new()
		lvl_pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		lvl_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lvl_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box("LEGENDARY" if is_max else ("RARE" if cur_lvl > 0 else "COMMON")))
		var lbl_lvl := Label.new()
		lbl_lvl.text = "MAX" if is_max else ("Lv." + str(cur_lvl) + "/" + str(max_lvl))
		lbl_lvl.add_theme_font_size_override("font_size", 11)
		CyberTheme.style_label(lbl_lvl, CyberTheme.COL_YELLOW if is_max else (CyberTheme.COL_CYAN if cur_lvl > 0 else Color(0.75, 0.84, 0.96, 0.9)), 2)
		lvl_pill.add_child(lbl_lvl)
		vbox.add_child(lvl_pill)

		var model_box := Control.new()
		model_box.custom_minimum_size = Vector2(0, 64)
		model_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var unlocked_flag: bool = (cur_lvl > 0)
		model_box.draw.connect(func():
			_draw_talent_medallion(model_box, Vector2(model_box.size.x * 0.5, 32.0), t_id, t_col, unlocked_flag)
		)
		vbox.add_child(model_box)

		var lbl_title := Label.new()
		lbl_title.text = str(def.get("name", t_id)).to_upper()
		lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		lbl_title.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_label(lbl_title, Color.WHITE, 3)
		vbox.add_child(lbl_title)

		var unit_s: String = str(def.get("unit", ""))
		var sep_u: String = "" if unit_s == "%" else " "
		var stat_txt: String = ("+" + _format_talent_num(bonus_val) + sep_u + unit_s) if cur_lvl > 0 else ("+" + _format_talent_num(step_val) + sep_u + unit_s + "/lv")
		var lbl_stat := Label.new()
		lbl_stat.text = stat_txt
		lbl_stat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_stat.add_theme_font_size_override("font_size", 13)
		CyberTheme.style_label(lbl_stat, CyberTheme.COL_GREEN if cur_lvl > 0 else t_col.lightened(0.25), 2)
		vbox.add_child(lbl_stat)

		var btn_upg := Button.new()
		btn_upg.custom_minimum_size = Vector2(0, 42)
		btn_upg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_upg.mouse_filter = Control.MOUSE_FILTER_PASS
		btn_upg.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		btn_upg.focus_mode = Control.FOCUS_NONE
		btn_upg.add_theme_font_size_override("font_size", 14)
		if is_max:
			btn_upg.disabled = true
			btn_upg.text = "★ MAX"
			CyberTheme.style_button(btn_upg, CyberTheme.COL_YELLOW, false)
		else:
			btn_upg.disabled = not can_buy
			btn_upg.icon = CyberTheme.get_ui_icon("coin")
			btn_upg.expand_icon = true
			btn_upg.text = str(cost)
			CyberTheme.style_button(btn_upg, CyberTheme.COL_YELLOW if can_buy else CyberTheme.COL_CYAN, can_buy)

		btn_upg.pressed.connect(func():
			if tm and tm.has_method("upgrade_talent"):
				var res: Dictionary = tm.upgrade_talent(t_id)
				if res.get("success", false):
					SoundFX.play_pickup()
					_update_top_bar()
					_populate_upgrades()
				else:
					SoundFX.play_hit()
		)
		vbox.add_child(btn_upg)
		talent_grid.add_child(card)

	if upgrades_view:
		_make_subtree_scroll_safe(upgrades_view)

# --- SHOP & MONETIZATION (MERCATO VISUALE COMPATTO) ---

func _draw_gem_cluster(c: CanvasItem, center: Vector2, tier: int, col: Color) -> void:
	c.draw_circle(center, 34.0, Color(col.r, col.g, col.b, 0.20))
	var offsets: Array[Vector2] = [Vector2.ZERO]
	if tier == 2:
		offsets = [Vector2(-14, 6), Vector2(14, 6), Vector2(0, -6)]
	elif tier >= 3:
		offsets = [Vector2(-18, 10), Vector2(18, 10), Vector2(-10, -4), Vector2(10, -4), Vector2(0, 8), Vector2(0, -12)]
	for i in range(offsets.size()):
		var p: Vector2 = center + offsets[i]
		var sc: float = 1.15 if (tier == 1 or i == offsets.size() - 1) else 0.88
		var pts := PackedVector2Array([
			p + Vector2(0, -16) * sc,
			p + Vector2(12, -4) * sc,
			p + Vector2(8, 14) * sc,
			p + Vector2(-8, 14) * sc,
			p + Vector2(-12, -4) * sc
		])
		c.draw_colored_polygon(pts, col)
		c.draw_colored_polygon(PackedVector2Array([
			p + Vector2(0, -16) * sc,
			p + Vector2(12, -4) * sc,
			p + Vector2(0, 3) * sc,
			p + Vector2(-5, -6) * sc
		]), Color.WHITE.lerp(col, 0.35))
		for k in range(pts.size()):
			c.draw_line(pts[k], pts[(k + 1) % pts.size()], Color.WHITE, 1.6)

func _populate_shop() -> void:
	if not shop_view:
		return

	# Nasconde i vecchi pannelli verbosi della scena statica e costruisce una vetrina 100% visuale!
	for legacy_name in ["CratesSection", "FreeAdsSection", "IapSection", "ShopSkinsPromoCard"]:
		var ln := shop_view.get_node_or_null(legacy_name)
		if ln:
			if legacy_name == "ShopSkinsPromoCard":
				shop_view.remove_child(ln)
				ln.queue_free()
			elif ln is Control:
				(ln as Control).visible = false

	var old_root := shop_view.get_node_or_null("ShopVisualRoot")
	if old_root:
		shop_view.remove_child(old_root)
		old_root.queue_free()

	var root_vb := VBoxContainer.new()
	root_vb.name = "ShopVisualRoot"
	root_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vb.add_theme_constant_override("separation", 12)
	shop_view.add_child(root_vb)
	shop_view.move_child(root_vb, 0)

	# 1. CASSE CROMO: 2 Grandi Card Visuali Affiancate (zero paragrafi!)
	var crates_hb := HBoxContainer.new()
	crates_hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crates_hb.add_theme_constant_override("separation", 10)
	root_vb.add_child(crates_hb)

	var crate_defs := [
		{"type": "NORMAL", "title": "CASSA STANDARD", "tag": "Comune • Raro", "cost": 100, "rar": "RARE", "col": CyberTheme.COL_CYAN},
		{"type": "EPIC", "title": "CASSA OSSIDIANA", "tag": "Raro+ • Epico • Legg.", "cost": 300, "rar": "LEGENDARY", "col": CyberTheme.COL_YELLOW}
	]
	for cd in crate_defs:
		var c_card := PanelContainer.new()
		c_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c_card.custom_minimum_size = Vector2(0, 236)
		c_card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(str(cd["rar"]), 12, 10))

		var cv := VBoxContainer.new()
		cv.alignment = BoxContainer.ALIGNMENT_CENTER
		cv.add_theme_constant_override("separation", 6)
		c_card.add_child(cv)

		var tag_p := PanelContainer.new()
		tag_p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tag_p.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box(str(cd["rar"])))
		var tag_l := Label.new()
		tag_l.text = str(cd["tag"])
		tag_l.add_theme_font_size_override("font_size", 11)
		CyberTheme.style_label(tag_l, (cd["col"] as Color).lightened(0.2), 2)
		tag_p.add_child(tag_l)
		cv.add_child(tag_p)

		var art_ctrl := Control.new()
		art_ctrl.custom_minimum_size = Vector2(0, 98)
		var is_epic_c: bool = (str(cd["type"]) == "EPIC")
		art_ctrl.draw.connect(func():
			var c := Vector2(art_ctrl.size.x * 0.5, 52.0)
			var crate_t := CyberTheme.get_model_texture("res://assets/cyber_models/prop_crate.png")
			if is_epic_c:
				CyberTheme.draw_item_icon(art_ctrl, c + Vector2(-56, 4), "katana", "ARMA", CyberTheme.COL_RARITY_EPIC, 58.0)
				CyberTheme.draw_item_icon(art_ctrl, c + Vector2(56, 4), "drone_shield", "PET 2", CyberTheme.COL_RARITY_EPIC, 58.0)
				CyberTheme.draw_item_icon(art_ctrl, c + Vector2(0, -4), "plasma_cannon", "ARMA", CyberTheme.COL_RARITY_LEGENDARY, 72.0)
			else:
				if crate_t:
					art_ctrl.draw_texture_rect(crate_t, Rect2(c - Vector2(40, 34), Vector2(80, 80)), false)
				CyberTheme.draw_item_icon(art_ctrl, c + Vector2(-54, 0), "shotgun", "ARMA", CyberTheme.COL_RARITY_RARE, 56.0)
				CyberTheme.draw_item_icon(art_ctrl, c + Vector2(54, 0), "kevlar", "CORAZZA", CyberTheme.COL_RARITY_COMMON, 56.0)
		)
		cv.add_child(art_ctrl)

		var c_lbl := Label.new()
		c_lbl.text = str(cd["title"])
		c_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		c_lbl.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(c_lbl, Color.WHITE, 3)
		cv.add_child(c_lbl)

		var c_cost: int = int(cd["cost"])
		var c_type: String = str(cd["type"])
		var c_btn := Button.new()
		c_btn.name = "BtnCrate_" + c_type
		c_btn.custom_minimum_size = Vector2(0, 48)
		c_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c_btn.icon = CyberTheme.get_ui_icon("gem")
		c_btn.expand_icon = true
		c_btn.text = str(c_cost)
		c_btn.add_theme_font_size_override("font_size", 17)
		CyberTheme.style_button(c_btn, cd["col"], is_epic_c and Global.total_credits >= c_cost)
		c_btn.pressed.connect(func(): _buy_crate(c_cost, c_type))
		cv.add_child(c_btn)
		crates_hb.add_child(c_card)

	# 2. SCORTA GIORNALIERA GRATIS: Barra Orizzontale Pulita
	var rem_ads: int = maxi(0, 3 - Global.daily_ads_watched)
	var free_card := PanelContainer.new()
	free_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	free_card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("RARE" if rem_ads > 0 else "COMMON", 12, 10))
	var free_hb := HBoxContainer.new()
	free_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	free_hb.add_theme_constant_override("separation", 12)
	free_card.add_child(free_hb)

	var free_ico := Control.new()
	free_ico.custom_minimum_size = Vector2(58, 56)
	free_ico.draw.connect(func():
		_draw_gem_cluster(free_ico, Vector2(29, 28), 2, CyberTheme.COL_CYAN)
	)
	free_hb.add_child(free_ico)

	var free_vb := VBoxContainer.new()
	free_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	free_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	free_vb.add_theme_constant_override("separation", 2)
	free_hb.add_child(free_vb)

	var f_t := Label.new()
	f_t.text = "+20 GEMME GRATIS"
	f_t.add_theme_font_size_override("font_size", 17)
	CyberTheme.style_label(f_t, CyberTheme.COL_YELLOW if rem_ads > 0 else Color(0.65, 0.72, 0.84, 0.9), 3)
	free_vb.add_child(f_t)

	var f_s := Label.new()
	f_s.text = "Disponibili: " + str(rem_ads) + " / 3"
	f_s.add_theme_font_size_override("font_size", 13)
	CyberTheme.style_label(f_s, CyberTheme.COL_CYAN, 2)
	free_vb.add_child(f_s)

	var btn_free := Button.new()
	btn_free.custom_minimum_size = Vector2(156, 48)
	btn_free.disabled = (rem_ads <= 0)
	btn_free.text = "RISCATTA" if rem_ads > 0 else "ESAURITO"
	btn_free.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_button(btn_free, CyberTheme.COL_YELLOW if rem_ads > 0 else CyberTheme.COL_CYAN, rem_ads > 0)
	btn_free.pressed.connect(_on_watch_ad_pressed)
	free_hb.add_child(btn_free)
	root_vb.add_child(free_card)

	# 3. BANNER SKIN OPERATIVI: Ritratti 3D + 1 Bottone (zero muri di testo!)
	var any_skin_locked := false
	for sid_chk in Global.SKIN_ORDER:
		if not Global.is_skin_unlocked(sid_chk):
			any_skin_locked = true
			break

	var sp_card := PanelContainer.new()
	sp_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("EPIC", 12, 10))
	var sp_hb := HBoxContainer.new()
	sp_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	sp_hb.add_theme_constant_override("separation", 10)
	sp_card.add_child(sp_hb)

	var portraits_ctrl := Control.new()
	portraits_ctrl.custom_minimum_size = Vector2(148, 72)
	portraits_ctrl.draw.connect(func():
		var demo_ids := ["net_ghost", "neon_rebel", "chrome_overlord"]
		for i in range(demo_ids.size()):
			var stx := CyberTheme.get_model_texture("res://assets/cyber_models/skin_preview_" + demo_ids[i] + ".png")
			if stx:
				portraits_ctrl.draw_texture_rect(stx, Rect2(Vector2(float(i) * 42.0, 2.0), Vector2(64, 68)), false)
	)
	sp_hb.add_child(portraits_ctrl)

	var sp_vb := VBoxContainer.new()
	sp_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	sp_vb.add_theme_constant_override("separation", 3)
	sp_hb.add_child(sp_vb)

	var sp_t := Label.new()
	sp_t.text = "5 SKIN & PERK"
	sp_t.add_theme_font_size_override("font_size", 17)
	CyberTheme.style_label(sp_t, Color.WHITE, 3)
	sp_vb.add_child(sp_t)

	var btn_open_sk := Button.new()
	btn_open_sk.custom_minimum_size = Vector2(0, 34)
	btn_open_sk.text = "VEDI OPERATIVI »"
	btn_open_sk.add_theme_font_size_override("font_size", 12)
	CyberTheme.style_button(btn_open_sk, CyberTheme.COL_CYAN, false)
	btn_open_sk.pressed.connect(func():
		SoundFX.play_click()
		current_equip_tab = "SKINS"
		_show_inventory_view()
	)
	sp_vb.add_child(btn_open_sk)

	if any_skin_locked:
		var btn_vip_all := Button.new()
		btn_vip_all.custom_minimum_size = Vector2(142, 52)
		btn_vip_all.text = "TUTTE\n€3,99"
		btn_vip_all.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_button(btn_vip_all, CyberTheme.COL_YELLOW, true)
		btn_vip_all.pressed.connect(func():
			Global.unlock_all_skins_vip()
			SoundFX.play_win()
			_trigger_rewards_popup("★", "BUNDLE VIP ATTIVATO!", "Tutte le 5 Skin Operativo sono sbloccate!")
			_update_top_bar()
			_populate_shop()
		)
		sp_hb.add_child(btn_vip_all)
	root_vb.add_child(sp_card)

	# 4. GEMME: 3 Tile Visuali Affiancate (Cristalli + Valore + Prezzo)
	var gems_hb := HBoxContainer.new()
	gems_hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gems_hb.add_theme_constant_override("separation", 10)
	root_vb.add_child(gems_hb)

	var iap_defs := [
		{"amt": 100, "price": "€0,99", "tier": 1, "rar": "RARE", "col": CyberTheme.COL_CYAN},
		{"amt": 500, "price": "€4,99", "tier": 2, "rar": "EPIC", "col": Color(0.82, 0.36, 1.0, 1.0)},
		{"amt": 1200, "price": "€9,99", "tier": 3, "rar": "LEGENDARY", "col": CyberTheme.COL_YELLOW}
	]
	for gd in iap_defs:
		var g_card := PanelContainer.new()
		g_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		g_card.custom_minimum_size = Vector2(0, 182)
		g_card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(str(gd["rar"]), 8, 8))

		var gv := VBoxContainer.new()
		gv.alignment = BoxContainer.ALIGNMENT_CENTER
		gv.add_theme_constant_override("separation", 5)
		g_card.add_child(gv)

		var g_art := Control.new()
		g_art.custom_minimum_size = Vector2(0, 68)
		var g_tier: int = int(gd["tier"])
		var g_col: Color = gd["col"]
		g_art.draw.connect(func():
			_draw_gem_cluster(g_art, Vector2(g_art.size.x * 0.5, 36.0), g_tier, g_col)
		)
		gv.add_child(g_art)

		var g_amt: int = int(gd["amt"])
		var g_price: String = str(gd["price"])
		var g_lbl := Label.new()
		g_lbl.text = "◆ +" + str(g_amt)
		g_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		g_lbl.add_theme_font_size_override("font_size", 18)
		CyberTheme.style_label(g_lbl, Color.WHITE, 3)
		gv.add_child(g_lbl)

		var g_btn := Button.new()
		g_btn.custom_minimum_size = Vector2(0, 42)
		g_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		g_btn.text = g_price
		g_btn.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_button(g_btn, g_col, g_tier == 3)
		g_btn.pressed.connect(func(): _buy_iap(g_amt, g_price))
		gv.add_child(g_btn)
		gems_hb.add_child(g_card)

	_make_subtree_scroll_safe(shop_view)

func _trigger_rewards_popup(icon_str: String, title_text: String, amount_text: String) -> void:
	var popup_scene := preload("res://scenes/RewardsPopup.tscn")
	if popup_scene:
		var popup := popup_scene.instantiate()
		add_child(popup)
		if popup.has_method("show_reward"):
			popup.show_reward(icon_str, title_text, amount_text)

func _on_watch_ad_pressed() -> void:
	if Global.daily_ads_watched < 3:
		Global.daily_ads_watched += 1
		Global.total_credits += 20
		SoundFX.play_pickup()
		var sys_save: Node = get_node_or_null("/root/SaveSystem")
		if sys_save and sys_save.has_method("save_game"): sys_save.save_game()
		_update_top_bar()
		_populate_shop()
		_trigger_rewards_popup("▶", "SINCRONIZZAZIONE COMPLETATA!", "+20 ◆ Gemme")
		if shop_result_label: shop_result_label.text = "✓ Sincronizzazione completata! +20 ◆ Gemme accreditate!"
	else:
		SoundFX.play_hit()
		if shop_result_label: shop_result_label.text = "! Limite sincronizzazioni giornaliere raggiunto (3/3)."

func _buy_iap(gems_amount: int, price_str: String) -> void:
	Global.total_credits += gems_amount
	SoundFX.play_pickup()
	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()
	_update_top_bar()
	if shop_result_label: shop_result_label.text = "✓ Acquisto " + price_str + " riuscito! +" + str(gems_amount) + " ◆ Gemme!"

func _buy_crate(cost: int, crate_type: String) -> void:
	if Global.total_credits >= cost:
		Global.total_credits -= cost
		SoundFX.play_pickup()

		var im: Node = get_node_or_null("/root/InventoryManager")
		var chosen: Dictionary = {}
		if im and im.has_method("roll_random_in_run_gear_drop"):
			var src_tag := "CRATE_NORMAL" if crate_type == "NORMAL" else "CRATE_EPIC"
			chosen = im.roll_random_in_run_gear_drop(maxi(1, Global.max_unlocked_world), src_tag)
		else:
			chosen = {"id": "pistol_base", "name": "Pistola Cyber", "slot": "ARMA", "rarity": "RARE"}
		var item_name: String = str(chosen.get("name", "Modulo"))
		var rarity: String = str(chosen.get("rarity", "COMMON"))

		var sys_save: Node = get_node_or_null("/root/SaveSystem")
		if sys_save and sys_save.has_method("save_game"): sys_save.save_game()

		var reward_display: String = item_name + " (" + CyberTheme.get_rarity_badge_text(rarity) + ")"
		_trigger_rewards_popup("★", "CASSA APERTA!", reward_display)
		if shop_result_label:
			shop_result_label.text = "★ TROVATO: " + reward_display
			CyberTheme.style_label(shop_result_label, CyberTheme.get_rarity_color(rarity).lightened(0.20), 3)
		_update_top_bar()
	else:
		SoundFX.play_hit()
		if shop_result_label: shop_result_label.text = "! Gemme insufficienti! Servono " + str(cost) + " ◆ Gemme."

# --- CHECK-IN REWARDS ---

func _populate_checkin() -> void:
	if checkin_grid:
		for child in checkin_grid.get_children(): child.queue_free()

		var rm: Node = get_node_or_null("/root/RewardManager")
		var rewards: Array = []
		if rm and "CHECKIN_REWARDS" in rm:
			rewards = rm.CHECKIN_REWARDS

		for idx in range(rewards.size()):
			var r: Dictionary = rewards[idx]
			var day_num := idx + 1

			var card := PanelContainer.new()
			card.custom_minimum_size = Vector2(154, 185)
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			var border_c := CyberTheme.COL_RARITY_COMMON
			var c_rar := "COMMON"
			if day_num < Global.checkin_day:
				border_c = CyberTheme.COL_GREEN
				c_rar = "RARE"
			elif day_num == Global.checkin_day:
				border_c = CyberTheme.COL_YELLOW
				c_rar = "LEGENDARY"
			elif day_num == 7:
				border_c = CyberTheme.COL_RARITY_EPIC
				c_rar = "EPIC"
			card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(c_rar, 8, 8))

			var vbox := VBoxContainer.new()
			vbox.alignment = BoxContainer.ALIGNMENT_END
			vbox.add_theme_constant_override("separation", 4)

			var icon_box := Control.new()
			icon_box.custom_minimum_size = Vector2(0, 86)
			icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var m_id := "weapon_katana" if day_num == 7 else ("drone_laser" if day_num % 2 == 0 else "ring_crit")
			icon_box.draw.connect(func():
				CyberTheme.draw_item_icon(icon_box, Vector2(icon_box.size.x * 0.5, 44.0), m_id, "", border_c, 74.0)
			)
			vbox.add_child(icon_box)

			var lbl_day := Label.new()
			lbl_day.text = "GIORNO 0" + str(day_num)
			lbl_day.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl_day.add_theme_font_size_override("font_size", 16)
			CyberTheme.style_label(lbl_day, CyberTheme.COL_YELLOW if day_num == Global.checkin_day else Color(0.88, 0.94, 1.0, 1.0), 3)
			vbox.add_child(lbl_day)

			var lbl_rew := Label.new()
			lbl_rew.text = str(r["icon"]) + " " + str(r["amt"])
			lbl_rew.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl_rew.add_theme_font_size_override("font_size", 17)
			CyberTheme.style_label(lbl_rew, CyberTheme.COL_CYAN, 3)
			vbox.add_child(lbl_rew)

			card.add_child(vbox)
			checkin_grid.add_child(card)

	if btn_claim_checkin:
		btn_claim_checkin.custom_minimum_size = Vector2(420, 62)
		btn_claim_checkin.disabled = Global.checkin_claimed
		btn_claim_checkin.text = "✓ PREMIO ODIERNO GIÀ RISCATTATO" if Global.checkin_claimed else "⚡ RISCATTA RIFORNIMENTO GIORNO " + str(Global.checkin_day) + " ⚡"

	if checkin_status_label:
		checkin_status_label.text = "✓ Riscattato oggi" if Global.checkin_claimed else ("★ Giorno " + str(Global.checkin_day) + " pronto")
	if checkin_view:
		_make_subtree_scroll_safe(checkin_view)

func _on_claim_checkin_pressed() -> void:
	var rm: Node = get_node_or_null("/root/RewardManager")
	if rm and rm.has_method("claim_daily_reward"):
		var res: Dictionary = rm.claim_daily_reward()
		if res.get("success", false):
			SoundFX.play_win()
			var rew_data: Dictionary = res.get("reward", {})
			_trigger_rewards_popup(str(rew_data.get("icon", "★")), "PREMIO GIORNALIERO!", str(rew_data.get("label", "Ricompensa")))
			_update_top_bar()
			_populate_checkin()
		else:
			SoundFX.play_hit()
			if checkin_status_label: checkin_status_label.text = str(res.get("message", "Impossibile riscattare"))

# --- QUEST SYSTEM ---

func _get_quest_current_val(q: Dictionary) -> int:
	var stat_type: String = str(q.get("stat", q.get("target_type", "")))
	match stat_type:
		"quest_kills", "kills": return Global.quest_kills
		"quest_runs", "runs": return Global.quest_runs
		"quest_talents", "talents": return Global.quest_talents
		"daily_ads_watched": return Global.daily_ads_watched
		"checkin_day": return Global.checkin_day
	return int(q.get("current_amt", q.get("current_amount", q.get("progress", 0))))

func _count_ready_in_pool(pool: Array) -> int:
	var cnt: int = 0
	for q in pool:
		var q_id: String = str(q.get("id", ""))
		if Global.quests_claimed.get(q_id, false):
			continue
		var max_v: int = maxi(1, int(q.get("target_amt", q.get("target_amount", q.get("target", q.get("max", 1))))))
		if _get_quest_current_val(q) >= max_v:
			cnt += 1
	return cnt

func _switch_quest_tab(tab_name: String) -> void:
	SoundFX.play_click()
	current_quest_tab = tab_name
	_populate_quests()

func _style_subnav_btn(btn: Button, is_active: bool) -> void:
	if not btn: return
	CyberTheme.style_segmented_tab(btn, is_active, CyberTheme.COL_YELLOW if is_active else CyberTheme.COL_CYAN)

func _populate_quests() -> void:
	if not quests_container: return
	quests_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for child in quests_container.get_children(): child.queue_free()

	var rm: Node = get_node_or_null("/root/RewardManager")
	if not rm: return

	var d_pool: Array = rm.DAILY_QUESTS if ("DAILY_QUESTS" in rm) else []
	var w_pool: Array = rm.WEEKLY_QUESTS if ("WEEKLY_QUESTS" in rm) else []
	var m_pool: Array = rm.MONTHLY_QUESTS if ("MONTHLY_QUESTS" in rm) else []

	var d_rdy: int = _count_ready_in_pool(d_pool)
	var w_rdy: int = _count_ready_in_pool(w_pool)
	var m_rdy: int = _count_ready_in_pool(m_pool)

	if btn_quest_daily:
		btn_quest_daily.text = ("GIORNALIERI (" + str(d_rdy) + ")") if d_rdy > 0 else "GIORNALIERI"
		_style_subnav_btn(btn_quest_daily, current_quest_tab == "DAILY")
	if btn_quest_weekly:
		btn_quest_weekly.text = ("SETTIMANALI (" + str(w_rdy) + ")") if w_rdy > 0 else "SETTIMANALI"
		_style_subnav_btn(btn_quest_weekly, current_quest_tab == "WEEKLY")
	if btn_quest_monthly:
		btn_quest_monthly.text = ("MENSILI (" + str(m_rdy) + ")") if m_rdy > 0 else "MENSILI"
		_style_subnav_btn(btn_quest_monthly, current_quest_tab == "MONTHLY")

	var all_pools: Array = []
	all_pools.append_array(d_pool)
	all_pools.append_array(w_pool)
	all_pools.append_array(m_pool)

	var claimable_all: Array = []
	for q_item in all_pools:
		var qid_c: String = str(q_item.get("id", ""))
		if Global.quests_claimed.get(qid_c, false):
			continue
		var max_c: int = maxi(1, int(q_item.get("target_amt", q_item.get("target_amount", q_item.get("target", q_item.get("max", 1))))))
		if _get_quest_current_val(q_item) >= max_c:
			claimable_all.append(q_item)

	# Pulsante Rapido 1-Tocco "★ RISCATTA TUTTE" quando almeno una missione è completata!
	if not claimable_all.is_empty():
		var btn_claim_all := Button.new()
		btn_claim_all.custom_minimum_size = Vector2(0, 56)
		btn_claim_all.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_claim_all.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_claim_all.text = "★ RISCATTA CONTRATTI PRONTI (" + str(claimable_all.size()) + ") »"
		btn_claim_all.add_theme_font_size_override("font_size", 17)
		CyberTheme.style_button(btn_claim_all, CyberTheme.COL_YELLOW, true)
		btn_claim_all.pressed.connect(func():
			var tot_c: int = 0
			var tot_g: int = 0
			for cq in claimable_all:
				var c_id: String = str(cq.get("id", ""))
				Global.quests_claimed[c_id] = true
				if str(cq.get("reward_type", "coins")) == "coins":
					tot_c += int(cq.get("reward_amt", 0))
				else:
					tot_g += int(cq.get("reward_amt", 0))
			Global.total_coins += tot_c
			Global.total_credits += tot_g
			SoundFX.play_win()
			var parts: Array[String] = []
			if tot_c > 0: parts.append("+" + str(tot_c) + " Oro")
			if tot_g > 0: parts.append("+" + str(tot_g) + " Gemme")
			_trigger_rewards_popup("★", "MISSIONI RISCATTATE!", "  •  ".join(parts))
			var sys_save: Node = get_node_or_null("/root/SaveSystem")
			if sys_save and sys_save.has_method("save_game"): sys_save.save_game()
			_update_top_bar()
			_populate_quests()
		)
		quests_container.add_child(btn_claim_all)

	var pool: Array = []
	match current_quest_tab:
		"DAILY": pool = d_pool
		"WEEKLY": pool = w_pool
		"MONTHLY": pool = m_pool

	for q in pool:
		var q_id: String = str(q.get("id", "q_unk"))
		var stat_type: String = str(q.get("stat", q.get("target_type", "")))
		var current_val: int = 0

		match stat_type:
			"quest_kills", "kills": current_val = Global.quest_kills
			"quest_runs", "runs": current_val = Global.quest_runs
			"quest_talents", "talents": current_val = Global.quest_talents
			"daily_ads_watched": current_val = Global.daily_ads_watched
			"checkin_day": current_val = Global.checkin_day
			_: current_val = int(q.get("current_amt", q.get("current_amount", q.get("progress", 0))))

		var max_val: int = maxi(1, int(q.get("target_amt", q.get("target_amount", q.get("target", q.get("max", 1))))))
		var clamped_val: int = mini(current_val, max_val)
		var is_claimed: bool = Global.quests_claimed.get(q_id, false)
		var is_ready: bool = (current_val >= max_val)
		var q_title: String = str(q.get("title", "Missione"))
		var q_desc: String = str(q.get("desc", q.get("description", q_title)))

		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(0, 130)
		var q_col := CyberTheme.COL_YELLOW if (is_ready and not is_claimed) else (CyberTheme.COL_CYAN if not is_claimed else Color(0.45, 0.52, 0.65, 0.85))
		var q_box_style := CyberTheme.make_rarity_card_box("LEGENDARY", 10, 8) if (is_ready and not is_claimed) else (CyberTheme.make_3d_panel_box(10, 8) if not is_claimed else CyberTheme.make_rarity_card_box("COMMON", 10, 8))
		card.add_theme_stylebox_override("panel", q_box_style)

		var margin := MarginContainer.new()
		margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_bottom", 8)
		card.add_child(margin)

		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_theme_constant_override("separation", 10)
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		margin.add_child(hbox)

		# 1. Icona Modello 3D compatta a sinistra
		var q_icon_ctrl := Control.new()
		q_icon_ctrl.custom_minimum_size = Vector2(64, 64)
		q_icon_ctrl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		q_icon_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var q_m_id := "weapon_plasma_cannon" if "kills" in stat_type else ("armor_nano_armor" if "runs" in stat_type else "drone_laser")
		q_icon_ctrl.draw.connect(func():
			CyberTheme.draw_item_icon(q_icon_ctrl, Vector2(32, 32), q_m_id, "", q_col, 58.0)
		)
		hbox.add_child(q_icon_ctrl)

		# 2. Colonna Centrale Espandibile con Testo a Capo Automatico (Zero Overflow!)
		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 4)

		var lbl_title := Label.new()
		lbl_title.text = q_title
		lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_title.add_theme_font_size_override("font_size", 17)
		CyberTheme.style_label(lbl_title, CyberTheme.COL_YELLOW if (is_ready and not is_claimed) else CyberTheme.COL_CYAN, 3)
		vbox.add_child(lbl_title)

		var pbar := ProgressBar.new()
		pbar.custom_minimum_size = Vector2(0, 24)
		pbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pbar.max_value = max_val
		pbar.value = clamped_val
		pbar.show_percentage = false
		var pb_bg := CyberTheme.make_cyber_box(Color(0.03, 0.05, 0.10, 0.95), Color(0.22, 0.34, 0.50, 0.8), 0.0, 1, 3, 0)
		var pb_fill := StyleBoxFlat.new()
		pb_fill.bg_color = CyberTheme.COL_GREEN if is_ready else CyberTheme.COL_CYAN
		pb_fill.corner_radius_top_left = 6; pb_fill.corner_radius_top_right = 6; pb_fill.corner_radius_bottom_left = 6; pb_fill.corner_radius_bottom_right = 6
		pbar.add_theme_stylebox_override("background", pb_bg)
		pbar.add_theme_stylebox_override("fill", pb_fill)

		var pbar_lbl := Label.new()
		pbar_lbl.text = str(clamped_val) + " / " + str(max_val)
		pbar_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pbar_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pbar_lbl.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(pbar_lbl, Color.WHITE, 3)
		pbar.add_child(pbar_lbl)
		pbar_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vbox.add_child(pbar)

		hbox.add_child(vbox)

		# 3. Colonna Destra Compatta Impilata (Badge Ricompensa + Pulsante Azione -> rientra sempre nei 720px!)
		var right_col := VBoxContainer.new()
		right_col.custom_minimum_size = Vector2(142, 0)
		right_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		right_col.alignment = BoxContainer.ALIGNMENT_CENTER
		right_col.add_theme_constant_override("separation", 6)

		var badge := PanelContainer.new()
		badge.custom_minimum_size = Vector2(142, 34)
		badge.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.09, 0.12, 0.22, 0.95), CyberTheme.COL_MAGENTA, 0.0, 1, 4, 2))

		var b_hb := HBoxContainer.new()
		b_hb.alignment = BoxContainer.ALIGNMENT_CENTER
		b_hb.add_theme_constant_override("separation", 5)
		var b_ico := TextureRect.new()
		b_ico.custom_minimum_size = Vector2(22, 22)
		b_ico.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		b_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		b_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		b_ico.texture = CyberTheme.get_ui_icon("coin" if q["reward_type"] == "coins" else "gem")
		b_hb.add_child(b_ico)

		var badge_lbl := Label.new()
		badge_lbl.text = "+" + str(q["reward_amt"])
		badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_lbl.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(badge_lbl, CyberTheme.COL_YELLOW if q["reward_type"] == "coins" else CyberTheme.COL_CYAN, 3)
		b_hb.add_child(badge_lbl)
		badge.add_child(b_hb)
		right_col.add_child(badge)

		var btn_claim := Button.new()
		btn_claim.custom_minimum_size = Vector2(142, 48)
		btn_claim.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_claim.add_theme_font_size_override("font_size", 15)

		if is_claimed:
			btn_claim.disabled = true
			btn_claim.text = "✓ PRESA"
			CyberTheme.style_button(btn_claim, CyberTheme.COL_CYAN, false)
		elif is_ready:
			btn_claim.disabled = false
			btn_claim.text = "★ RISCATTA"
			CyberTheme.style_button(btn_claim, CyberTheme.COL_YELLOW, true)
		else:
			btn_claim.disabled = true
			btn_claim.text = "IN CORSO"
			CyberTheme.style_button(btn_claim, CyberTheme.COL_CYAN, false)

		btn_claim.pressed.connect(func():
			if not is_claimed and is_ready:
				Global.quests_claimed[q_id] = true
				var rew_str: String = ("+" + str(q["reward_amt"]) + " Monete Oro") if q["reward_type"] == "coins" else ("+" + str(q["reward_amt"]) + " Gemme")
				if q["reward_type"] == "coins": Global.total_coins += int(q["reward_amt"])
				else: Global.total_credits += int(q["reward_amt"])
				SoundFX.play_pickup()
				_trigger_rewards_popup("★", "MISSIONE RISCATTATA!", rew_str)
				var sys_save: Node = get_node_or_null("/root/SaveSystem")
				if sys_save and sys_save.has_method("save_game"): sys_save.save_game()
				_update_top_bar()
				_populate_quests()
		)

		right_col.add_child(btn_claim)
		hbox.add_child(right_col)
		quests_container.add_child(card)

	if quests_view:
		_make_subtree_scroll_safe(quests_view)

# --- NAV BUTTON HANDLERS ---

func _on_nav_shop_pressed() -> void:
	SoundFX.play_click()
	_show_shop_view()

func _on_nav_equip_pressed() -> void:
	SoundFX.play_click()
	current_equip_tab = "ARSENAL"
	_show_inventory_view()

func _on_nav_home_pressed() -> void:
	SoundFX.play_click()
	_show_home_view()

func _on_btn_upgrades_pressed() -> void:
	SoundFX.play_click()
	_show_upgrades_view()

func _on_nav_quests_pressed() -> void:
	SoundFX.play_click()
	_show_quests_view()

func _on_btn_checkin_pressed() -> void:
	SoundFX.play_click()
	_show_checkin_view()

func _open_settings_modal() -> void:
	SoundFX.play_click()
	var sm_script := load("res://scripts/settings_modal.gd")
	if sm_script:
		var sm = sm_script.new()
		sm.show_char_creator_btn = true
		sm.open_character_creator_requested.connect(func():
			_show_character_creation_modal(false)
		)
		add_child(sm)

func _on_btn_play_pressed() -> void:
	var world: WorldData = WorldDB.get_selected_world()
	if world:
		var world_num: int = WorldDB.world_order.find(world.id) + 1
		if world_num > Global.max_unlocked_world:
			SoundFX.play_hit()
			return
	SoundFX.play_click()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

# ==============================================================================
# TERMINALE IDENTITÀ NEURALE: CREAZIONE PERSONAGGIO (NOME, CLASSE, COLORE AURA)
# ==============================================================================
const CHAR_CLASS_DEFS := [
	{"id": "RONIN", "title": "⚡ CYBER-RONIN", "wep": "pistol_base", "wep_name": "Pistola Cyber", "bonus": "+30 VEL • +5% CRIT", "stats": "ATK 14 • HP 100 • VEL 330", "rar": "RARE", "col": Color(0.0, 0.95, 1.0, 1.0)},
	{"id": "VANGUARD", "title": "★ VANGUARD", "wep": "shotgun", "wep_name": "Fucile a Pompa", "bonus": "+40 HP CORAZZA", "stats": "ATK 22x3 • HP 140 • VEL 300", "rar": "LEGENDARY", "col": Color(1.0, 0.84, 0.10, 1.0)},
	{"id": "NETRUNNER", "title": "◆ NETRUNNER", "wep": "homing_wand", "wep_name": "Conduttore Psionico", "bonus": "+4 ATK GUIDATO", "stats": "ATK 31 • HP 100 • VEL 300", "rar": "EPIC", "col": Color(0.84, 0.28, 1.0, 1.0)}
]

const CHAR_COLOR_DEFS := [
	{"id": "CYAN", "label": "◆ CIANO", "col": Color(0.0, 0.95, 1.0, 1.0)},
	{"id": "MAGENTA", "label": "◆ MAGENTA", "col": Color(1.0, 0.12, 0.52, 1.0)},
	{"id": "GOLD", "label": "★ ORO", "col": Color(1.0, 0.86, 0.08, 1.0)},
	{"id": "GREEN", "label": "✦ BIO-VERDE", "col": Color(0.12, 1.0, 0.52, 1.0)}
]

## Schermata d'Entrata Cinematografica 3D Full-Screen (100% Edge-to-Edge su 16:9, 20:9 e 21:9, zero bande nere!)
func _show_welcome_entrance_screen() -> void:
	if is_instance_valid(welcome_layer):
		welcome_layer.queue_free()
		welcome_layer = null

	welcome_layer = CanvasLayer.new()
	welcome_layer.name = "WelcomeEntranceLayer"
	welcome_layer.layer = 34
	add_child(welcome_layer)

	var root_ctrl := Control.new()
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	welcome_layer.add_child(root_ctrl)

	# 1. Canvas Full-Bleed Garantito (usa get_viewport_rect().size + aspect-cover matematico + pioggia neon + Logo 3D!)
	welcome_fx_ctrl = Control.new()
	welcome_fx_ctrl.mouse_filter = Control.MOUSE_FILTER_STOP
	welcome_fx_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.add_child(welcome_fx_ctrl)

	welcome_fx_ctrl.draw.connect(func():
		var vp_sz: Vector2 = welcome_fx_ctrl.get_viewport_rect().size
		var sz := Vector2(maxf(vp_sz.x, welcome_fx_ctrl.size.x), maxf(vp_sz.y, welcome_fx_ctrl.size.y))
		var bg_t: Texture2D = CyberTheme.get_model_texture("res://assets/cyber_models/ui_entrance_keyart.png")
		if bg_t:
			var tw: float = float(bg_t.get_width())
			var th: float = float(bg_t.get_height())
			var sc: float = maxf(sz.x / maxf(1.0, tw), sz.y / maxf(1.0, th))
			var sw: float = sz.x / sc
			var sh: float = sz.y / sc
			var src_r := Rect2(Vector2((tw - sw) * 0.5, (th - sh) * 0.5), Vector2(sw, sh))
			welcome_fx_ctrl.draw_texture_rect_region(bg_t, Rect2(Vector2.ZERO, sz), src_r, Color.WHITE)
		else:
			welcome_fx_ctrl.draw_rect(Rect2(Vector2.ZERO, sz), Color(0.03, 0.05, 0.12, 1.0), true)

		# Pioggia neon diagonale e scintille olografiche ascendenti su TUTTO lo schermo (niente blocchi neri opachi!)
		for r_i in range(28):
			var rx: float = fmod(float(r_i) * 89.0 + menu_anim_t * 42.0, sz.x + 80.0) - 40.0
			var ry: float = fmod(float(r_i) * 137.0 + menu_anim_t * (420.0 + float(r_i % 4) * 65.0), sz.y + 120.0) - 60.0
			welcome_fx_ctrl.draw_line(Vector2(rx, ry), Vector2(rx - 10.0, ry + 48.0), Color(0.25, 0.92, 1.0, 0.22), 1.6)

		for i in range(22):
			var px := fmod(float(i) * 97.0 + sin(menu_anim_t * 0.9 + float(i)) * 28.0, maxf(100.0, sz.x))
			var py := sz.y - fmod(menu_anim_t * (34.0 + float(i % 5) * 9.0) + float(i) * 83.0, maxf(200.0, sz.y))
			var pa := 0.30 + 0.38 * sin(menu_anim_t * 3.0 + float(i))
			var p_col := Color(0.15, 0.95, 1.0, pa) if (i % 2 == 0) else Color(1.0, 0.28, 0.72, pa)
			welcome_fx_ctrl.draw_circle(Vector2(px, py), 2.6, p_col)

		# Sfumatura morbida e trasparente solo negli ultimi 260px per far risaltare i pulsanti senza coprire la piazza neon
		welcome_fx_ctrl.draw_polygon(
			PackedVector2Array([Vector2(0, sz.y - 300.0), Vector2(sz.x, sz.y - 300.0), Vector2(sz.x, sz.y), Vector2(0, sz.y)]),
			PackedColorArray([Color(0.02, 0.03, 0.08, 0.0), Color(0.02, 0.03, 0.08, 0.0), Color(0.02, 0.03, 0.08, 0.72), Color(0.02, 0.03, 0.08, 0.72)])
		)

		# Emblema 3D Ufficiale Alato "V-PUNK: ROGUE PROTOCOL" fluttuante in trasparenza nel cielo di Night City!
		var logo_t: Texture2D = CyberTheme.get_model_texture("res://assets/cyber_models/ui_logo_header_3d.png")
		if logo_t:
			var lw: float = minf(sz.x * 0.88, 630.0)
			var lh: float = lw * (float(logo_t.get_height()) / maxf(1.0, float(logo_t.get_width())))
			var ly: float = sz.y * 0.06 + sin(menu_anim_t * 1.8) * 5.0
			welcome_fx_ctrl.draw_texture_rect(logo_t, Rect2(Vector2((sz.x - lw) * 0.5, ly), Vector2(lw, lh)), false)
	)

	# 2. Palco Centrale 3D dell'Operativo in piedi sulla Piazza Neon Bagnata!
	var center_stage := Control.new()
	center_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.add_child(center_stage)

	welcome_holo = Node2D.new()
	welcome_holo.scale = Vector2(2.65, 2.65)
	welcome_holo.draw.connect(func():
		var vp_sz: Vector2 = center_stage.get_viewport_rect().size
		welcome_holo.position = Vector2(vp_sz.x * 0.5, vp_sz.y * 0.64)
		var aura_c := Global.get_player_accent_color()
		welcome_holo.draw_set_transform(Vector2(0, 20), 0.0, Vector2(1.0, 0.38))
		welcome_holo.draw_circle(Vector2.ZERO, 34.0, Color(0.03, 0.08, 0.18, 0.72))
		welcome_holo.draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 36, aura_c, 2.4)
		welcome_holo.draw_arc(Vector2.ZERO, 26.0, menu_anim_t * 1.5, menu_anim_t * 1.5 + PI * 1.35, 24, Color.WHITE, 1.5)
		welcome_holo.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		CyberModels.draw_hero(welcome_holo, WeaponDB.equipped_weapon_id, menu_anim_t, false, false, PI * 0.5 + sin(menu_anim_t * 1.35) * 0.28, Vector2.ZERO, 68.0, true)
	)
	center_stage.add_child(welcome_holo)

	# 3. Dock Inferiore Compatto in Vetro Scuro + Pulsante Principale 3D Spesso "ENTRA A NIGHT CITY"
	var dock_margin := MarginContainer.new()
	dock_margin.anchor_left = 0.0
	dock_margin.anchor_right = 1.0
	dock_margin.anchor_top = 1.0
	dock_margin.anchor_bottom = 1.0
	dock_margin.offset_left = 24.0
	dock_margin.offset_right = -24.0
	dock_margin.offset_top = -275.0
	dock_margin.offset_bottom = -28.0
	root_ctrl.add_child(dock_margin)

	var dv := VBoxContainer.new()
	dv.alignment = BoxContainer.ALIGNMENT_END
	dv.add_theme_constant_override("separation", 12)
	dock_margin.add_child(dv)

	var dossier_pill := PanelContainer.new()
	dossier_pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	dossier_pill.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(18, 10, Color(1, 1, 1, 0.94)))
	var op_call := Global.player_name if not Global.player_name.is_empty() else "V-77"
	var d_lbl := Label.new()
	d_lbl.text = op_call + "  //  " + Global.get_class_display_name() + "  //  SETTORE " + ("%02d" % Global.max_unlocked_world) + "/12"
	d_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d_lbl.add_theme_font_size_override("font_size", 16)
	CyberTheme.style_label(d_lbl, CyberTheme.COL_CYAN, 3)
	dossier_pill.add_child(d_lbl)
	dv.add_child(dossier_pill)

	var btn_enter := Button.new()
	btn_enter.custom_minimum_size = Vector2(0, 84)
	btn_enter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_enter.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_enter.text = "CONNETTI NEURAL-LINK »"
	btn_enter.add_theme_font_size_override("font_size", 24)
	CyberTheme.style_button(btn_enter, CyberTheme.COL_YELLOW, true)
	btn_enter.pressed.connect(func():
		SoundFX.play_win()
		var tw := create_tween().set_parallel(true)
		tw.tween_property(root_ctrl, "modulate:a", 0.0, 0.24)
		tw.chain().tween_callback(func():
			if is_instance_valid(welcome_layer):
				welcome_layer.queue_free()
				welcome_layer = null
		)
	)
	dv.add_child(btn_enter)

	var btn_customize := Button.new()
	btn_customize.custom_minimum_size = Vector2(340, 58)
	btn_customize.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_customize.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_customize.text = "MODIFICA IDENTITÀ"
	btn_customize.add_theme_font_size_override("font_size", 16)
	CyberTheme.style_button(btn_customize, CyberTheme.COL_CYAN, false)
	btn_customize.pressed.connect(func():
		SoundFX.play_click()
		if is_instance_valid(welcome_layer):
			welcome_layer.queue_free()
			welcome_layer = null
		_show_character_creation_modal(false)
	)
	dv.add_child(btn_customize)

	dv.modulate = Color(1, 1, 1, 0.0)
	var tw_open := create_tween()
	tw_open.tween_property(dv, "modulate:a", 1.0, 0.28)

## Vera Schermata d'Entrata 3D per la Creazione del Personaggio (con Logo Alta Risoluzione + Titolo + Studio Olografico!)
func _show_character_creation_modal(is_first_time: bool = true) -> void:
	if is_instance_valid(char_modal_layer):
		char_modal_layer.queue_free()
		char_modal_layer = null

	char_selected_class = Global.player_class if not Global.player_class.is_empty() else "RONIN"
	char_selected_color = Global.player_color_id if not Global.player_color_id.is_empty() else "CYAN"
	Global.player_color_id = char_selected_color
	char_class_btns.clear()
	char_color_btns.clear()

	char_modal_layer = CanvasLayer.new()
	char_modal_layer.name = "CharCreationModalLayer"
	char_modal_layer.layer = 35
	char_modal_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(char_modal_layer)

	var root_ctrl := Control.new()
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	char_modal_layer.add_child(root_ctrl)

	# 1. Sfondo Key-Art 3D Full-Bleed Garantito su qualsiasi formato smartphone (16:9 - 21:9)
	char_fx_ctrl = Control.new()
	char_fx_ctrl.mouse_filter = Control.MOUSE_FILTER_STOP
	char_fx_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.add_child(char_fx_ctrl)
	char_fx_ctrl.draw.connect(func():
		var vp_sz: Vector2 = char_fx_ctrl.get_viewport_rect().size
		var sz := Vector2(maxf(vp_sz.x, char_fx_ctrl.size.x), maxf(vp_sz.y, char_fx_ctrl.size.y))
		var bg_t: Texture2D = CyberTheme.get_model_texture("res://assets/cyber_models/ui_entrance_keyart.png")
		if bg_t:
			var tw: float = float(bg_t.get_width())
			var th: float = float(bg_t.get_height())
			var sc: float = maxf(sz.x / maxf(1.0, tw), sz.y / maxf(1.0, th))
			var sw: float = sz.x / sc
			var sh: float = sz.y / sc
			char_fx_ctrl.draw_texture_rect_region(bg_t, Rect2(Vector2.ZERO, sz), Rect2(Vector2((tw - sw) * 0.5, (th - sh) * 0.5), Vector2(sw, sh)), Color.WHITE)
		char_fx_ctrl.draw_rect(Rect2(Vector2.ZERO, sz), Color(0.02, 0.035, 0.085, 0.52), true)
		for i in range(18):
			var px := fmod(float(i) * 103.0 + cos(menu_anim_t * 0.8 + float(i)) * 24.0, maxf(100.0, sz.x))
			var py := sz.y - fmod(menu_anim_t * (28.0 + float(i % 4) * 8.0) + float(i) * 91.0, maxf(200.0, sz.y))
			char_fx_ctrl.draw_circle(Vector2(px, py), 2.4, Color(0.15, 0.95, 1.0, 0.34))
	)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	root_ctrl.add_child(margin)

	var outer_vbox := VBoxContainer.new()
	outer_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	outer_vbox.add_theme_constant_override("separation", 12)
	margin.add_child(outer_vbox)

	# 2. HERO HEADER: Logo 3D con Titolo Sotto ("V-PUNK / ROGUE PROTOCOL") + Camera Olografica 3D dell'Operativo!
	var showcase_row := HBoxContainer.new()
	showcase_row.alignment = BoxContainer.ALIGNMENT_CENTER
	showcase_row.add_theme_constant_override("separation", 12)
	outer_vbox.add_child(showcase_row)

	# Card Sinistra: Nuovo Logo Ufficiale 3D ad Alta Risoluzione con Titolo Sotto!
	var logo_card := PanelContainer.new()
	logo_card.custom_minimum_size = Vector2(280, 232)
	logo_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(6, 6))
	showcase_row.add_child(logo_card)

	var logo_tex_rect := TextureRect.new()
	logo_tex_rect.name = "BrandLogoHeader"
	logo_tex_rect.texture = CyberTheme.get_model_texture("res://assets/cyber_models/ui_logo_header_3d.png")
	logo_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_tex_rect.custom_minimum_size = Vector2(266, 218)
	logo_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_card.add_child(logo_tex_rect)

	# Card Destra: Podio Olografico 3D Anteprima in Tempo Reale dell'Operativo
	char_preview_panel = PanelContainer.new()
	char_preview_panel.custom_minimum_size = Vector2(396, 232)
	char_preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	char_preview_panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(10, 8))
	showcase_row.add_child(char_preview_panel)

	var preview_vbox := VBoxContainer.new()
	preview_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	preview_vbox.add_theme_constant_override("separation", 4)
	preview_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	char_preview_panel.add_child(preview_vbox)

	var lbl_stage_top := Label.new()
	lbl_stage_top.text = "✦ ANTEPRIMA OLOGRAFICA 3D"
	lbl_stage_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_stage_top.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(lbl_stage_top, CyberTheme.COL_CYAN, 2)
	preview_vbox.add_child(lbl_stage_top)

	var preview_ctrl := Control.new()
	preview_ctrl.custom_minimum_size = Vector2(360, 148)
	preview_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_vbox.add_child(preview_ctrl)

	char_preview_holo = Node2D.new()
	char_preview_holo.position = Vector2(180, 102)
	char_preview_holo.scale = Vector2(1.96, 1.96)
	char_preview_holo.draw.connect(_on_draw_char_preview_holo)
	preview_ctrl.add_child(char_preview_holo)

	char_preview_status_lbl = Label.new()
	char_preview_status_lbl.text = _get_char_preview_summary_text()
	char_preview_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_preview_status_lbl.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(char_preview_status_lbl, CyberTheme.COL_YELLOW, 3)
	preview_vbox.add_child(char_preview_status_lbl)

	# 3. PANNELLO PRINCIPALE 3D SCOLPITO: STUDIO DI CREAZIONE OPERATIVO
	var main_panel := PanelContainer.new()
	main_panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(16, 14))
	outer_vbox.add_child(main_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_panel.add_child(vbox)

	var lbl_hdr := Label.new()
	lbl_hdr.text = "⚡ FORGIA IL TUO CYBER-OPERATIVO ⚡" if is_first_time else "⚡ PERSONALIZZA / RICREA OPERATIVO ⚡"
	lbl_hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hdr.add_theme_font_size_override("font_size", 21)
	CyberTheme.style_label(lbl_hdr, CyberTheme.COL_YELLOW, 4)
	vbox.add_child(lbl_hdr)

	var lbl_sub := Label.new()
	lbl_sub.text = "Scegli Nome in Codice, Classe da Combattimento e Aura Neon per scendere a Night City"
	lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_sub.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(lbl_sub, Color(0.88, 0.95, 1.0, 1.0), 2)
	vbox.add_child(lbl_sub)

	# STEP 1: Inserimento Nome Operativo (Callsign)
	var lbl_name_prompt := Label.new()
	lbl_name_prompt.text = "1. NOME OPERATIVO / CALLSIGN"
	lbl_name_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name_prompt.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(lbl_name_prompt, CyberTheme.COL_CYAN, 3)
	vbox.add_child(lbl_name_prompt)

	var name_hbox := HBoxContainer.new()
	name_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	name_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(name_hbox)

	char_name_input = LineEdit.new()
	char_name_input.custom_minimum_size = Vector2(440, 54)
	char_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	char_name_input.placeholder_text = "Inserisci nome (es. V-RONIN)..."
	char_name_input.text = Global.player_name if not Global.player_name.is_empty() else "V-77"
	char_name_input.max_length = 14
	char_name_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_name_input.add_theme_font_size_override("font_size", 19)
	char_name_input.add_theme_stylebox_override("normal", CyberTheme.make_cyber_box(Color(0.03, 0.06, 0.13, 0.98), CyberTheme.COL_CYAN, 0.02, 2, 6, 4))
	char_name_input.add_theme_stylebox_override("focus", CyberTheme.make_cyber_box(Color(0.05, 0.09, 0.18, 1.0), CyberTheme.COL_YELLOW, 0.02, 2, 8, 6))
	char_name_input.text_submitted.connect(func(_t: String):
		char_name_input.release_focus()
		DisplayServer.virtual_keyboard_hide()
	)
	name_hbox.add_child(char_name_input)

	var btn_rand_name := Button.new()
	btn_rand_name.custom_minimum_size = Vector2(162, 54)
	btn_rand_name.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_rand_name.focus_mode = Control.FOCUS_NONE
	btn_rand_name.text = "★ CASUALE"
	btn_rand_name.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_button(btn_rand_name, CyberTheme.COL_MAGENTA, false)
	btn_rand_name.pressed.connect(_on_char_rand_name_pressed)
	name_hbox.add_child(btn_rand_name)

	# STEP 2: Selezione Archetipo / Classe (3 Card 3D Scolpite con Piedistallo Arma Olografico)
	var lbl_class_prompt := Label.new()
	lbl_class_prompt.text = "2. SCEGLI ARCHETIPO & ARMA 3D INIZIALE"
	lbl_class_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_class_prompt.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(lbl_class_prompt, CyberTheme.COL_CYAN, 3)
	vbox.add_child(lbl_class_prompt)

	var class_hbox := HBoxContainer.new()
	class_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	class_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(class_hbox)

	for c_def in CHAR_CLASS_DEFS:
		var cb := Button.new()
		cb.custom_minimum_size = Vector2(198, 204)
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		cb.focus_mode = Control.FOCUS_NONE
		var cid: String = str(c_def["id"])
		var cwep: String = str(c_def["wep"])
		var ccol: Color = c_def["col"]
		_style_archetype_card_btn(cb, c_def, char_selected_class == cid)
		class_hbox.add_child(cb)

		var w_icon := Control.new()
		w_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cb.add_child(w_icon)
		w_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		w_icon.draw.connect(func():
			CyberTheme.draw_item_icon(w_icon, Vector2(cb.size.x * 0.5, 52.0), cwep, "ARMA", ccol, 78.0, char_selected_class == cid)
		)

		cb.pressed.connect(_on_char_class_selected.bind(cid))
		char_class_btns[cid] = cb

	# STEP 3: Selezione Colore Visiera / Aura Neon
	var lbl_col_prompt := Label.new()
	lbl_col_prompt.text = "3. COLORE VISIERA & AURA NEON"
	lbl_col_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_col_prompt.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(lbl_col_prompt, CyberTheme.COL_CYAN, 3)
	vbox.add_child(lbl_col_prompt)

	var col_hbox := HBoxContainer.new()
	col_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	col_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(col_hbox)

	for col_def in CHAR_COLOR_DEFS:
		var col_btn := Button.new()
		col_btn.custom_minimum_size = Vector2(148, 54)
		col_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		col_btn.focus_mode = Control.FOCUS_NONE
		var col_id: String = str(col_def["id"])
		var col_val: Color = col_def["col"]
		var col_lbl: String = str(col_def["label"])
		col_btn.add_theme_font_size_override("font_size", 14)
		_style_color_choice_btn(col_btn, col_val, col_lbl, char_selected_color == col_id)
		col_btn.pressed.connect(_on_char_color_selected.bind(col_id))
		col_hbox.add_child(col_btn)
		char_color_btns[col_id] = col_btn

	# STEP 4: Pulsante 3D d'Ingresso Principale
	var action_hbox := HBoxContainer.new()
	action_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	action_hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(action_hbox)

	var btn_confirm := Button.new()
	btn_confirm.custom_minimum_size = Vector2(460 if is_first_time else 380, 68)
	btn_confirm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_confirm.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_confirm.focus_mode = Control.FOCUS_NONE
	btn_confirm.text = "INIZIALIZZA OPERATIVO »" if is_first_time else "APPLICA IDENTITÀ »"
	btn_confirm.add_theme_font_size_override("font_size", 19)
	CyberTheme.style_button(btn_confirm, CyberTheme.COL_YELLOW, true)
	btn_confirm.pressed.connect(_on_char_confirm_pressed.bind(is_first_time))
	action_hbox.add_child(btn_confirm)

	if not is_first_time:
		var btn_cancel := Button.new()
		btn_cancel.custom_minimum_size = Vector2(170, 68)
		btn_cancel.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_cancel.focus_mode = Control.FOCUS_NONE
		btn_cancel.text = "ANNULLA"
		btn_cancel.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_button(btn_cancel, CyberTheme.COL_CYAN, false)
		btn_cancel.pressed.connect(_on_char_cancel_pressed)
		action_hbox.add_child(btn_cancel)

	# Animazione d'ingresso cinematografica
	outer_vbox.modulate = Color(1, 1, 1, 0.0)
	var tw_enter := create_tween()
	tw_enter.tween_property(outer_vbox, "modulate:a", 1.0, 0.30)

func _get_char_preview_summary_text() -> String:
	for c_def in CHAR_CLASS_DEFS:
		if str(c_def["id"]) == char_selected_class:
			return str(c_def["title"]) + "  •  " + str(c_def["stats"])
	return "CLASSE: " + char_selected_class + " | AURA: " + char_selected_color

func _style_archetype_card_btn(btn: Button, c_def: Dictionary, is_selected: bool) -> void:
	if not btn: return
	var rar_key: String = str(c_def.get("rar", "RARE"))
	var ccol: Color = c_def["col"]
	var sel_prefix := "✓ " if is_selected else ""
	btn.text = "\n\n\n\n" + sel_prefix + str(c_def["title"]) + "\n" + str(c_def["wep_name"]) + "\n" + str(c_def["bonus"]) + "\n" + str(c_def["stats"])
	btn.add_theme_font_size_override("font_size", 15)

	var sb_card := CyberTheme.make_rarity_card_box("LEGENDARY" if is_selected else rar_key, 8, 8)
	if sb_card is StyleBoxTexture:
		(sb_card as StyleBoxTexture).modulate_color = Color(1.12, 1.12, 1.15, 1.0) if is_selected else Color(0.88, 0.90, 0.96, 0.94)
	btn.add_theme_stylebox_override("normal", sb_card)
	btn.add_theme_stylebox_override("hover", sb_card)
	btn.add_theme_stylebox_override("pressed", sb_card)
	btn.add_theme_color_override("font_color", Color.WHITE if is_selected else ccol.lightened(0.28))
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.96))
	btn.add_theme_constant_override("outline_size", 3)

func _style_color_choice_btn(btn: Button, col_val: Color, label_str: String, is_selected: bool) -> void:
	if not btn: return
	btn.text = ("✓ " if is_selected else "") + label_str
	var bg := Color(col_val.r * 0.42, col_val.g * 0.42, col_val.b * 0.42, 0.98) if is_selected else Color(0.07, 0.10, 0.18, 0.96)
	var border := Color.WHITE if is_selected else col_val
	var sb := CyberTheme.make_cyber_box(bg, border, 0.04, 3 if is_selected else 2, 8 if is_selected else 5, 12 if is_selected else 4)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_color_override("font_color", Color.WHITE if is_selected else col_val.lightened(0.25))
	btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.95))
	btn.add_theme_constant_override("outline_size", 3)

func _on_draw_char_preview_holo() -> void:
	if not is_instance_valid(char_preview_holo): return
	var w_preview := "pistol_base"
	if char_selected_class == "VANGUARD": w_preview = "shotgun"
	elif char_selected_class == "NETRUNNER": w_preview = "homing_wand"
	Global.player_color_id = char_selected_color
	var aura_col := Global.get_player_accent_color()

	# Pedana proiettore 3D isometrica + cono di luce volumetrica sotto l'operativo
	char_preview_holo.draw_set_transform(Vector2(0, 18.0), 0.0, Vector2(1.0, 0.38))
	char_preview_holo.draw_circle(Vector2.ZERO, 34.0, Color(0.05, 0.09, 0.18, 0.95))
	char_preview_holo.draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 32, aura_col, 2.4)
	char_preview_holo.draw_arc(Vector2.ZERO, 25.0, menu_anim_t * 1.6, menu_anim_t * 1.6 + PI * 1.4, 24, Color.WHITE, 1.5)
	char_preview_holo.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	char_preview_holo.draw_polygon(
		PackedVector2Array([Vector2(-26, 18), Vector2(26, 18), Vector2(32, -44), Vector2(-32, -44)]),
		PackedColorArray([
			Color(aura_col.r, aura_col.g, aura_col.b, 0.24),
			Color(aura_col.r, aura_col.g, aura_col.b, 0.24),
			Color(aura_col.r, aura_col.g, aura_col.b, 0.0),
			Color(aura_col.r, aura_col.g, aura_col.b, 0.0)
		])
	)

	var preview_ang: float = PI * 0.5 + sin(menu_anim_t * 1.45) * 0.42
	CyberModels.draw_hero(char_preview_holo, w_preview, menu_anim_t, false, false, preview_ang, Vector2.ZERO, 68.0, true)

func _on_char_rand_name_pressed() -> void:
	if is_instance_valid(char_name_input):
		char_name_input.release_focus()
	DisplayServer.virtual_keyboard_hide()
	SoundFX.play_click()
	var random_names := ["V-77", "AKIRA-9", "KIRA-X", "ZERO-V", "NYX-2077", "RAVEN", "GHOST-X", "SILVERHAND"]
	if is_instance_valid(char_name_input):
		char_name_input.text = random_names[randi() % random_names.size()]

func _on_char_class_selected(cid: String) -> void:
	if is_instance_valid(char_name_input):
		char_name_input.release_focus()
	DisplayServer.virtual_keyboard_hide()
	SoundFX.play_click()
	char_selected_class = cid
	for c_def in CHAR_CLASS_DEFS:
		var id_k: String = str(c_def["id"])
		if char_class_btns.has(id_k) and is_instance_valid(char_class_btns[id_k]):
			_style_archetype_card_btn(char_class_btns[id_k], c_def, id_k == cid)
			for ch in char_class_btns[id_k].get_children():
				if ch is Control:
					(ch as Control).queue_redraw()
	if is_instance_valid(char_preview_status_lbl):
		char_preview_status_lbl.text = _get_char_preview_summary_text()
		CyberTheme.style_label(char_preview_status_lbl, CyberTheme.COL_YELLOW, 3)
	if is_instance_valid(char_preview_holo):
		char_preview_holo.queue_redraw()

func _on_char_color_selected(col_id: String) -> void:
	if is_instance_valid(char_name_input):
		char_name_input.release_focus()
	DisplayServer.virtual_keyboard_hide()
	SoundFX.play_click()
	char_selected_color = col_id
	Global.player_color_id = col_id
	for col_def in CHAR_COLOR_DEFS:
		var id_k: String = str(col_def["id"])
		if char_color_btns.has(id_k) and is_instance_valid(char_color_btns[id_k]):
			_style_color_choice_btn(char_color_btns[id_k], col_def["col"], str(col_def["label"]), id_k == col_id)
	if is_instance_valid(char_preview_status_lbl):
		char_preview_status_lbl.text = _get_char_preview_summary_text()
		CyberTheme.style_label(char_preview_status_lbl, CyberTheme.COL_YELLOW, 3)
	if is_instance_valid(char_preview_holo):
		char_preview_holo.queue_redraw()

func _on_char_confirm_pressed(is_first_time: bool = true) -> void:
	if is_instance_valid(char_name_input):
		char_name_input.release_focus()
	DisplayServer.virtual_keyboard_hide()
	SoundFX.play_win()
	var final_name := "V-77"
	if is_instance_valid(char_name_input):
		final_name = char_name_input.text.strip_edges()
	if final_name.is_empty():
		final_name = "V-77"

	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	var im: Node = get_node_or_null("/root/InventoryManager")

	if is_first_time:
		if sys_save and sys_save.has_method("reset_save"):
			sys_save.reset_save()
		Global.profile_created = true
		Global.player_name = final_name
		Global.player_class = char_selected_class
		Global.player_color_id = char_selected_color
		if im and im.has_method("init_starter_loadout"):
			im.init_starter_loadout(Global.player_class)
	else:
		Global.profile_created = true
		Global.player_name = final_name
		Global.player_class = char_selected_class
		Global.player_color_id = char_selected_color
		var class_wep := "pistol_base"
		var class_wep_name := "Pistola Base"
		if char_selected_class == "VANGUARD":
			class_wep = "shotgun"
			class_wep_name = "Fucile a Pompa"
		elif char_selected_class == "NETRUNNER":
			class_wep = "homing_wand"
			class_wep_name = "Conduttore Psionico"
		if im:
			var owns_wep := false
			if "inventory" in im:
				for it in im.inventory:
					if str(it.get("id", "")) == class_wep:
						owns_wep = true
						break
			if not owns_wep and im.has_method("add_item"):
				im.add_item(class_wep, class_wep_name, "ARMA", "COMMON")
			if im.has_method("equip_item"):
				im.equip_item(class_wep, "ARMA")

	if sys_save and sys_save.has_method("save_game"):
		sys_save.save_game()

	if is_instance_valid(char_modal_layer):
		char_modal_layer.queue_free()
		char_modal_layer = null

	_update_top_bar()
	_show_home_view()

func _on_char_cancel_pressed() -> void:
	if is_instance_valid(char_name_input):
		char_name_input.release_focus()
	DisplayServer.virtual_keyboard_hide()
	SoundFX.play_click()
	if is_instance_valid(char_modal_layer):
		char_modal_layer.queue_free()
		char_modal_layer = null
