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
var current_equip_tab: String = "ARSENAL" # "ARSENAL", "UPGRADE", "MERGE"

var equip_sub_nav: HBoxContainer = null
var btn_equip_tab_arsenal: Button = null
var btn_equip_tab_upgrade: Button = null
var btn_equip_tab_merge: Button = null
var hero_section_panel: Control = null
var forge_section_panel: Control = null
var inventory_title_lbl: Label = null
var upgrade_workshop_box: VBoxContainer = null
var merge_workshop_box: VBoxContainer = null
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
	if preview_icon: preview_icon.pressed.connect(func(): _cycle_world(1))

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
			current_equip_tab = "UPGRADE"
			_on_nav_equip_pressed()
		)
	var pill_coins: Control = find_child("PillCoins", true, false) as Control
	if pill_coins:
		_connect_button(pill_coins, _on_btn_upgrades_pressed)
	var pill_gems: Control = find_child("PillGems", true, false) as Control
	if pill_gems:
		_connect_button(pill_gems, _on_nav_shop_pressed)

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
		central.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(12, 10, Color(0.95, 0.98, 1.0, 0.96)))

	var world_card: PanelContainer = find_child("WorldCard", true, false) as PanelContainer
	if world_card:
		world_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(14, 12))

	var summary_card: PanelContainer = find_child("EquippedSummaryCard", true, false) as PanelContainer
	if summary_card:
		summary_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(12, 10))

	var profile_card: PanelContainer = find_child("ProfileCard", true, false) as PanelContainer
	if profile_card:
		profile_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(10, 6))

	var pill_scrolls: PanelContainer = find_child("PillScrolls", true, false) as PanelContainer
	if pill_scrolls:
		pill_scrolls.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("EPIC", 8, 4))

	var pill_coins: PanelContainer = find_child("PillCoins", true, false) as PanelContainer
	if pill_coins:
		pill_coins.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("LEGENDARY", 8, 4))

	var pill_gems: PanelContainer = find_child("PillGems", true, false) as PanelContainer
	if pill_gems:
		pill_gems.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("RARE", 8, 4))

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
		btn_checkin_top.custom_minimum_size = Vector2(142, 56)
		btn_checkin_top.icon = CyberTheme.get_ui_icon("gift")
		btn_checkin_top.expand_icon = true

	var btn_set: Button = find_child("BtnSettingsTop", true, false) as Button
	if btn_set:
		btn_set.custom_minimum_size = Vector2(60, 56)
		btn_set.text = ""
		btn_set.icon = CyberTheme.get_ui_icon("settings")
		btn_set.expand_icon = true
		btn_set.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if btn_watch_ad:
		btn_watch_ad.icon = CyberTheme.get_ui_icon("gem")
		btn_watch_ad.expand_icon = true

	_setup_footer_tab_3d_icon(btn_nav_shop, "nav_shop", "NEGOZIO")
	_setup_footer_tab_3d_icon(btn_nav_equip, "nav_equip", "EQUIP")
	_setup_footer_tab_3d_icon(btn_nav_home, "nav_play", "GIOCA")
	_setup_footer_tab_3d_icon(btn_upgrades, "nav_talents", "TALENTI")
	_setup_footer_tab_3d_icon(btn_nav_quests, "nav_quests", "MISSIONI")

var menu_anim_t: float = 0.0
var cyber_bg_canvas: Control = null
var boss_holo_node: Node2D = null
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
	if is_instance_valid(hero_holo_node): hero_holo_node.queue_redraw()
	if is_instance_valid(top_avatar_holo): top_avatar_holo.queue_redraw()
	if is_instance_valid(welcome_holo): welcome_holo.queue_redraw()
	if is_instance_valid(welcome_fx_ctrl): welcome_fx_ctrl.queue_redraw()
	if is_instance_valid(char_fx_ctrl): char_fx_ctrl.queue_redraw()
	if is_instance_valid(char_preview_holo): char_preview_holo.queue_redraw()

func _setup_procedural_menu_models() -> void:
	if preview_icon:
		preview_icon.texture_normal = null
		boss_holo_node = Node2D.new()
		boss_holo_node.position = Vector2(248, 102)
		boss_holo_node.scale = Vector2(1.0, 1.0)
		boss_holo_node.draw.connect(func():
			var w: WorldData = WorldDB.get_selected_world()
			var wid: String = w.id if w else "world_1"
			var bcol: Color = w.boss_color if w else Color(0, 0.94, 1, 1)
			var acc: Color = w.accent_color if w else Color(0, 0.94, 1, 1)
			var banner_tex := CyberTheme.get_model_texture("res://assets/cyber_models/banner_" + wid + ".png")
			var rect := Rect2(Vector2(-248, -102), Vector2(496, 204))
			if banner_tex:
				boss_holo_node.draw_texture_rect(banner_tex, rect, false)
			else:
				boss_holo_node.draw_rect(rect, Color(0.03, 0.05, 0.12, 0.95), true)
			boss_holo_node.draw_rect(rect, acc, false, 2.5)
			boss_holo_node.draw_set_transform(Vector2(0, 6), 0.0, Vector2(1.34, 1.34))
			CyberModels.draw_boss(boss_holo_node, wid, menu_anim_t, bcol, false, PI * 0.5 + sin(menu_anim_t * 1.5) * 0.25)
			boss_holo_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		)
		preview_icon.add_child(boss_holo_node)

	var hero_center: TextureRect = find_child("HeroCenter", true, false) as TextureRect
	if hero_center:
		hero_center.texture = null
		hero_holo_node = Node2D.new()
		hero_holo_node.position = Vector2(90, 118)
		hero_holo_node.scale = Vector2(2.30, 2.30)
		hero_holo_node.draw.connect(func():
			var aura_c := Global.get_player_accent_color()
			# Camera Olografica 3D: disco proiettore metallico + colonna di luce volumetrica
			hero_holo_node.draw_set_transform(Vector2(0, 20.0), 0.0, Vector2(1.0, 0.38))
			hero_holo_node.draw_circle(Vector2.ZERO, 33.0, Color(0.05, 0.09, 0.18, 0.96))
			hero_holo_node.draw_arc(Vector2.ZERO, 33.0, 0.0, TAU, 32, aura_c, 2.2)
			hero_holo_node.draw_arc(Vector2.ZERO, 25.0, menu_anim_t * 1.4, menu_anim_t * 1.4 + PI * 1.4, 24, Color.WHITE, 1.4)
			hero_holo_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			hero_holo_node.draw_polygon(
				PackedVector2Array([Vector2(-26, 20), Vector2(26, 20), Vector2(32, -46), Vector2(-32, -46)]),
				PackedColorArray([
					Color(aura_c.r, aura_c.g, aura_c.b, 0.22),
					Color(aura_c.r, aura_c.g, aura_c.b, 0.22),
					Color(aura_c.r, aura_c.g, aura_c.b, 0.0),
					Color(aura_c.r, aura_c.g, aura_c.b, 0.0)
				])
			)
			# Sul podio menu l'eroe è rivolto frontalmente / 3-4 verso il giocatore per mostrare visiera, armatura e arma
			CyberModels.draw_hero(hero_holo_node, WeaponDB.equipped_weapon_id, menu_anim_t, false, false, PI * 0.5 + sin(menu_anim_t * 1.35) * 0.45)
		)
		hero_center.add_child(hero_holo_node)

	var top_avatar: TextureRect = find_child("Avatar", true, false) as TextureRect
	if top_avatar:
		top_avatar.texture = null
		top_avatar_holo = Node2D.new()
		top_avatar_holo.position = Vector2(24, 28)
		top_avatar_holo.scale = Vector2(0.76, 0.76)
		top_avatar_holo.draw.connect(func():
			CyberModels.draw_hero(top_avatar_holo, WeaponDB.equipped_weapon_id, menu_anim_t, false, false, PI * 0.5)
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

func _connect_button(node: Control, method: Callable) -> void:
	if not node:
		return
	if node is TextureButton:
		(node as TextureButton).pressed.connect(method)
	elif node is Button:
		(node as Button).pressed.connect(method)
	elif node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_STOP
		for child in node.get_children():
			if child is Control:
				(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.gui_input.connect(func(event: InputEvent):
			if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
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
	var callsign := Global.player_name if not Global.player_name.is_empty() else "OPERATIVO"
	if profile_level_label:
		profile_level_label.text = callsign + " • " + Global.get_class_display_name() + " Lv." + str(total_lvl)
	if energy_label: energy_label.text = "Nuclei: " + str(Global.upgrade_scrolls)
	if coins_label: coins_label.text = str(Global.total_coins)
	if gems_label: gems_label.text = str(Global.total_credits)

	if btn_checkin_top:
		var has_gift := not Global.checkin_claimed
		btn_checkin_top.icon = CyberTheme.get_ui_icon("gift")
		btn_checkin_top.expand_icon = true
		btn_checkin_top.text = "PREMI !" if has_gift else "PREMI"
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

	_set_nav_label_text(btn_nav_shop, "NEGOZIO", shop_alert)
	_set_nav_label_text(btn_nav_equip, "EQUIP", equip_alert)
	_set_nav_label_text(btn_nav_home, "GIOCA", false)
	_set_nav_label_text(btn_upgrades, "TALENTI", talent_alert)
	_set_nav_label_text(btn_nav_quests, "MISSIONI", quest_alert)

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
		label.add_theme_color_override("font_color", Color(1.0, 0.98, 0.88, 1.0) if is_active else Color(0.90, 0.95, 1.0, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.01, 0.98) if is_active else Color(0.02, 0.03, 0.08, 0.95))
		label.add_theme_constant_override("outline_size", 4 if is_active else 3)

	var nav_tex := CyberTheme.get_model_texture("res://assets/cyber_models/ui_btn_gold_3d.png" if is_active else "res://assets/cyber_models/ui_btn_cyan_3d.png")
	if nav_tex:
		var sbt := StyleBoxTexture.new()
		sbt.texture = nav_tex
		sbt.texture_margin_left = 18; sbt.texture_margin_right = 18
		sbt.texture_margin_top = 14; sbt.texture_margin_bottom = 18
		sbt.content_margin_left = 4; sbt.content_margin_right = 4
		sbt.content_margin_top = 4; sbt.content_margin_bottom = 8
		if not is_active:
			sbt.modulate_color = Color(0.88, 0.92, 0.98, 0.96)
		btn.add_theme_stylebox_override("panel", sbt)
	else:
		btn.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box())

	var target_scale := Vector2(1.06, 1.06) if is_active else Vector2(1.0, 1.0)
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", target_scale, 0.18)

func _get_rarity_color(rarity_str: String) -> Color:
	return CyberTheme.get_rarity_color(rarity_str)

func _cycle_world(direction: int) -> void:
	var keys: Array = WorldDB.world_order if ("world_order" in WorldDB and not WorldDB.world_order.is_empty()) else WorldDB.worlds.keys()
	if keys.is_empty(): return
	var current_idx: int = keys.find(WorldDB.selected_world_id)
	if current_idx == -1: current_idx = 0
	var new_idx: int = (current_idx + direction + keys.size()) % keys.size()
	WorldDB.selected_world_id = str(keys[new_idx])
	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()
	SoundFX.play_click()
	_show_home_view()

# --- VIEW NAVIGATION METHODS ---

func _hide_all_views() -> void:
	if home_view: home_view.visible = false
	if inventory_view: inventory_view.visible = false
	if upgrades_view: upgrades_view.visible = false
	if quests_view: quests_view.visible = false
	if checkin_view: checkin_view.visible = false
	if shop_view: shop_view.visible = false

func _fade_in_view(view_node: Control) -> void:
	if not view_node: return
	view_node.visible = true
	view_node.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(view_node, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _show_home_view() -> void:
	current_view = ViewMode.HOME
	_update_nav_styles()
	if section_title: section_title.text = "SETTORE OPERATIVO — SELEZIONA MONDO"
	_hide_all_views()
	_fade_in_view(home_view)

	var world: WorldData = WorldDB.get_selected_world()
	if world:
		var world_num: int = WorldDB.world_order.find(world.id) + 1
		if world_num <= 0: world_num = 1
		var is_locked: bool = (world_num > Global.max_unlocked_world)

		if world_card_name:
			world_card_name.text = world.display_name + (" [BLOCCATO]" if is_locked else "")
			world_card_name.add_theme_color_override("font_color", Color(0.75, 0.38, 0.48, 1.0) if is_locked else world.accent_color)
		if world_card_info:
			world_card_info.text = "★ " + str(world.total_rooms) + " Livelli  •  Boss: " + world.boss_name + "  •  Bottino x" + str(world.reward_multiplier)
		if world_card_desc:
			if is_locked:
				world_card_desc.text = "Completa prima il Mondo 0" + str(world_num - 1) + " per sbloccare questo settore."
			else:
				world_card_desc.text = world.description
		if btn_play_home:
			btn_play_home.disabled = is_locked
			if is_locked:
				btn_play_home.text = "BLOCCATO — COMPLETA MONDO 0" + str(world_num - 1)
				CyberTheme.style_button(btn_play_home, CyberTheme.COL_MAGENTA, false)
			else:
				btn_play_home.text = "⚡ GIOCA ORA (" + str(world.total_rooms) + " LIVELLI) ▶"
				CyberTheme.style_button(btn_play_home, CyberTheme.COL_YELLOW, true)
		if is_instance_valid(boss_holo_node):
			boss_holo_node.queue_redraw()

	_rebuild_home_loadout_dashboard()

func _rebuild_home_loadout_dashboard() -> void:
	var summary_card: PanelContainer = find_child("EquippedSummaryCard", true, false) as PanelContainer
	if not summary_card: return
	if equipped_summary_label:
		equipped_summary_label.visible = false

	var old_dash := summary_card.get_node_or_null("HomeLoadoutDash")
	if old_dash:
		old_dash.queue_free()

	var dash := VBoxContainer.new()
	dash.name = "HomeLoadoutDash"
	dash.add_theme_constant_override("separation", 10)
	dash.alignment = BoxContainer.ALIGNMENT_CENTER

	var im: Node = get_node_or_null("/root/InventoryManager")
	var can_auto_eq: bool = (im != null and im.has_method("can_improve_loadout") and im.can_improve_loadout())
	var fusible_cnt: int = im.get_fusible_items().size() if (im and im.has_method("get_fusible_items")) else 0

	# Banner contestuale intelligente 1-Tocco se c'è un'azione immediata utile!
	if can_auto_eq:
		var btn_alert := Button.new()
		btn_alert.custom_minimum_size = Vector2(0, 50)
		btn_alert.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_alert.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_alert.text = "⚡ NUOVO EQUIPAGGIAMENTO TROVATO: TOCCA PER INDOSSARLO SUBITO!"
		btn_alert.add_theme_font_size_override("font_size", 17)
		CyberTheme.style_button(btn_alert, CyberTheme.COL_YELLOW, true)
		btn_alert.pressed.connect(func():
			if im and im.has_method("auto_equip_best"):
				var n_ch: int = im.auto_equip_best()
				if n_ch > 0:
					SoundFX.play_win()
					_update_top_bar()
					_show_home_view()
		)
		dash.add_child(btn_alert)
	elif fusible_cnt > 0:
		var btn_f_alert := Button.new()
		btn_f_alert.custom_minimum_size = Vector2(0, 48)
		btn_f_alert.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_f_alert.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_f_alert.text = "▲ FUSIONE 3-IN-1 PRONTA (" + str(fusible_cnt) + ") — TOCCA PER EVOLVERE!"
		btn_f_alert.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_button(btn_f_alert, CyberTheme.COL_MAGENTA, true)
		btn_f_alert.pressed.connect(func():
			current_equip_tab = "MERGE"
			_on_nav_equip_pressed()
		)
		dash.add_child(btn_f_alert)

	var hdr := Label.new()
	hdr.text = "⚡ DOTAZIONE ATTIVA EROE (TOCCA PER GESTIRE)"
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hdr.add_theme_font_size_override("font_size", 18)
	CyberTheme.style_label(hdr, CyberTheme.COL_YELLOW, 3)
	dash.add_child(hdr)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var wep_slot_item: Dictionary = im.get_equipped_item_in_slot("ARMA") if (im and im.has_method("get_equipped_item_in_slot")) else {}
	var wep_rar: String = str(wep_slot_item.get("rarity", "COMMON")) if not wep_slot_item.is_empty() else "COMMON"
	var eq_weapon: WeaponStats = WeaponDB.get_equipped_weapon()
	var wep_id: String = WeaponDB.equipped_weapon_id
	var wep_name: String = eq_weapon.display_name if eq_weapon else "Pistola Base"
	var wep_lvl: int = im.get_item_level(wep_id) if (im and im.has_method("get_item_level")) else 1
	var wep_dmg: int = (eq_weapon.get_final_damage() if eq_weapon else 15) + (wep_lvl - 1) * 3

	var arm_slot_item: Dictionary = im.get_equipped_item_in_slot("CORAZZA") if (im and im.has_method("get_equipped_item_in_slot")) else {}
	var arm_rar: String = str(arm_slot_item.get("rarity", "COMMON")) if not arm_slot_item.is_empty() else "COMMON"
	var arm_id: String = WeaponDB.equipped_armor_id
	var eq_armor: Dictionary = WeaponDB.armors.get(arm_id, {}) as Dictionary
	var has_armor: bool = not arm_id.is_empty() and not eq_armor.is_empty()
	var arm_name: String = str(eq_armor.get("name", "Corazza")) if has_armor else "Slot Libero"
	var arm_lvl: int = im.get_item_level(arm_id) if (im and has_armor and im.has_method("get_item_level")) else 1
	var arm_hp: int = WeaponDB.get_equipped_armor_hp_bonus() + ((arm_lvl - 1) * 18 if has_armor else 0)

	var pet_item: Dictionary = im.get_equipped_item_in_slot("PET 1") if (im and im.has_method("get_equipped_item_in_slot")) else {}
	var has_pet: bool = not pet_item.is_empty() and not str(pet_item.get("id", "")).is_empty()
	var pet_rar: String = str(pet_item.get("rarity", "COMMON")) if has_pet else "COMMON"
	var pet_id: String = str(pet_item.get("id", "drone_laser")) if has_pet else "drone_laser"
	var pet_name: String = str(pet_item.get("name", "Drone Laser")) if has_pet else "Slot Libero"

	var showcase_items := [
		{"id": wep_id, "slot": "ARMA", "title": wep_name, "stat": "★ " + str(wep_dmg) + " ATK • " + CyberTheme.get_rarity_label_it(wep_rar), "rar": wep_rar, "active": true},
		{"id": arm_id if has_armor else "kevlar", "slot": "CORAZZA", "title": arm_name, "stat": ("✦ +" + str(arm_hp) + " HP • " + CyberTheme.get_rarity_label_it(arm_rar)) if has_armor else "Corazza vuota", "rar": arm_rar, "active": has_armor},
		{"id": pet_id, "slot": "PET 1", "title": pet_name, "stat": ("◆ " + CyberTheme.get_rarity_label_it(pet_rar)) if has_pet else "Drone vuoto", "rar": pet_rar, "active": has_pet}
	]

	for s_info in showcase_items:
		var p := PanelContainer.new()
		p.custom_minimum_size = Vector2(200, 154)
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var s_active: bool = bool(s_info["active"])
		var s_rar: String = str(s_info["rar"])
		var c_acc: Color = CyberTheme.get_rarity_color(s_rar) if s_active else Color(0.45, 0.52, 0.64, 0.80)
		p.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(s_rar, 8, 6) if s_active else CyberTheme.make_3d_panel_box(8, 6, Color(0.75, 0.82, 0.92, 0.88)))

		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_END
		vb.add_theme_constant_override("separation", 2)

		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 80)
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sid: String = s_info["id"]
		var sslot: String = s_info["slot"]
		spacer.draw.connect(func():
			CyberTheme.draw_item_icon(spacer, Vector2(spacer.size.x * 0.5, 42.0), sid, sslot, c_acc, 72.0, s_active)
		)
		vb.add_child(spacer)

		var l_name := Label.new()
		l_name.text = s_info["title"]
		l_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		l_name.add_theme_font_size_override("font_size", 17)
		CyberTheme.style_label(l_name, Color.WHITE if s_active else Color(0.68, 0.75, 0.85, 0.88), 3)
		vb.add_child(l_name)

		var l_st := Label.new()
		l_st.text = s_info["stat"]
		l_st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l_st.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(l_st, c_acc.lightened(0.18), 2)
		vb.add_child(l_st)

		p.add_child(vb)
		_connect_button(p, func():
			current_equip_tab = "ARSENAL"
			_on_nav_equip_pressed()
		)
		hbox.add_child(p)

	dash.add_child(hbox)

	var quick_row := HBoxContainer.new()
	quick_row.alignment = BoxContainer.ALIGNMENT_CENTER
	quick_row.add_theme_constant_override("separation", 8)

	var btn_quick_equip := Button.new()
	btn_quick_equip.custom_minimum_size = Vector2(0, 52)
	btn_quick_equip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_quick_equip.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_quick_equip.icon = CyberTheme.get_ui_icon("nav_equip")
	btn_quick_equip.expand_icon = true
	btn_quick_equip.text = "EQUIP"
	btn_quick_equip.add_theme_font_size_override("font_size", 16)
	CyberTheme.style_button(btn_quick_equip, CyberTheme.COL_CYAN, false)
	btn_quick_equip.pressed.connect(func():
		current_equip_tab = "ARSENAL"
		_on_nav_equip_pressed()
	)
	quick_row.add_child(btn_quick_equip)

	var btn_quick_upg := Button.new()
	btn_quick_upg.custom_minimum_size = Vector2(0, 52)
	btn_quick_upg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_quick_upg.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_quick_upg.icon = CyberTheme.get_ui_icon("core")
	btn_quick_upg.expand_icon = true
	btn_quick_upg.text = "POTENZIA"
	btn_quick_upg.add_theme_font_size_override("font_size", 16)
	CyberTheme.style_button(btn_quick_upg, CyberTheme.COL_YELLOW, false)
	btn_quick_upg.pressed.connect(func():
		current_equip_tab = "UPGRADE"
		_on_nav_equip_pressed()
	)
	quick_row.add_child(btn_quick_upg)

	var btn_quick_mrg := Button.new()
	btn_quick_mrg.custom_minimum_size = Vector2(0, 52)
	btn_quick_mrg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_quick_mrg.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_quick_mrg.text = "▲ FUSIONE"
	btn_quick_mrg.add_theme_font_size_override("font_size", 16)
	CyberTheme.style_button(btn_quick_mrg, CyberTheme.COL_MAGENTA, fusible_cnt > 0)
	btn_quick_mrg.pressed.connect(func():
		current_equip_tab = "MERGE"
		_on_nav_equip_pressed()
	)
	quick_row.add_child(btn_quick_mrg)

	dash.add_child(quick_row)

	summary_card.add_child(dash)

func _show_inventory_view() -> void:
	current_view = ViewMode.INVENTORY
	_update_nav_styles()
	if section_title: section_title.text = "EQUIPAGGIAMENTO (6 SLOT) & FUSIONE"
	_hide_all_views()
	_fade_in_view(inventory_view)
	_populate_inventory()

func _show_upgrades_view() -> void:
	current_view = ViewMode.UPGRADES
	_update_nav_styles()
	if section_title: section_title.text = "ALBERO TALENTI PERMANENTI (14)"
	_hide_all_views()
	_fade_in_view(upgrades_view)
	_populate_upgrades()

func _show_quests_view() -> void:
	current_view = ViewMode.QUESTS
	_update_nav_styles()
	if section_title: section_title.text = "MISSIONI E OBIETTIVI"
	_hide_all_views()
	_fade_in_view(quests_view)
	_populate_quests()

func _show_checkin_view() -> void:
	current_view = ViewMode.CHECKIN
	_update_nav_styles()
	if section_title: section_title.text = "PREMI DI ACCESSO SETTIMANALE"
	_hide_all_views()
	_fade_in_view(checkin_view)
	_populate_checkin()

func _show_shop_view() -> void:
	current_view = ViewMode.SHOP
	_update_nav_styles()
	if section_title: section_title.text = "NEGOZIO & MONETIZZAZIONE"
	_hide_all_views()
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

func _update_active_slot_ui(slot_node_name: String, slot_type: String) -> void:
	var slot_panel: PanelContainer = find_child(slot_node_name, true, false) as PanelContainer
	if not slot_panel: return

	var im: Node = get_node_or_null("/root/InventoryManager")
	var eq_item: Dictionary = im.get_equipped_item_in_slot(slot_type) if (im and im.has_method("get_equipped_item_in_slot")) else {}

	var lbl: Label = slot_panel.get_node_or_null("Lbl") as Label
	var is_empty: bool = eq_item.is_empty() or eq_item.get("id", "").is_empty()
	var item_id: String = str(eq_item.get("id", ""))
	var item_lvl: int = im.get_item_level(item_id) if (im and not is_empty and im.has_method("get_item_level")) else 1
	var rar_str: String = str(eq_item.get("rarity", "COMMON")) if not is_empty else "COMMON"
	var rar_col: Color = CyberTheme.get_rarity_color(rar_str) if not is_empty else Color(0.52, 0.62, 0.76, 0.72)

	if lbl:
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl.add_theme_font_size_override("font_size", 15)
		if is_empty:
			lbl.text = slot_type + "\n[VUOTO]"
			lbl.modulate = Color(0.68, 0.76, 0.88, 0.85)
		else:
			lbl.text = slot_type + " • Lv." + str(item_lvl) + "\n" + str(eq_item.get("name", slot_type)) + "\n" + CyberTheme.get_rarity_badge_text(rar_str)
			lbl.modulate = Color.WHITE

	if is_empty:
		slot_panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(8, 6, Color(0.75, 0.82, 0.92, 0.85)))
	else:
		slot_panel.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(rar_str, 8, 6))

	var old_icon := slot_panel.get_node_or_null("Slot3DModel")
	if old_icon:
		old_icon.queue_free()

	var model_ctrl := Control.new()
	model_ctrl.name = "Slot3DModel"
	model_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	model_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	var fallback_id := "pistol_base"
	if "CORAZZA" in slot_type: fallback_id = "kevlar"
	elif "ANELLO" in slot_type: fallback_id = "ring_crit"
	elif "PET" in slot_type: fallback_id = "drone_laser"
	var draw_id := item_id if not is_empty else fallback_id
	model_ctrl.draw.connect(func():
		CyberTheme.draw_item_icon(model_ctrl, Vector2(44.0, slot_panel.size.y * 0.5), draw_id, slot_type, rar_col, 66.0, not is_empty)
	)
	slot_panel.add_child(model_ctrl)

func _setup_equip_subtabs() -> void:
	if not inventory_view:
		return
	hero_section_panel = inventory_view.get_node_or_null("HeroSection") as Control
	forge_section_panel = inventory_view.get_node_or_null("ForgeSection") as Control
	inventory_title_lbl = inventory_view.get_node_or_null("InventoryTitle") as Label
	if inventory_grid:
		inventory_grid.columns = 2

	# Barra Sub-Tab Scheda EQUIP con pulsanti grandi e leggibili (15px)
	if not inventory_view.get_node_or_null("EquipSubNav"):
		equip_sub_nav = HBoxContainer.new()
		equip_sub_nav.name = "EquipSubNav"
		equip_sub_nav.custom_minimum_size = Vector2(0, 50)
		equip_sub_nav.add_theme_constant_override("separation", 8)
		equip_sub_nav.alignment = BoxContainer.ALIGNMENT_CENTER

		btn_equip_tab_arsenal = Button.new()
		btn_equip_tab_arsenal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_equip_tab_arsenal.custom_minimum_size = Vector2(0, 52)
		btn_equip_tab_arsenal.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_equip_tab_arsenal.icon = CyberTheme.get_ui_icon("nav_equip")
		btn_equip_tab_arsenal.expand_icon = true
		btn_equip_tab_arsenal.text = "ARSENALE"
		btn_equip_tab_arsenal.add_theme_font_size_override("font_size", 16)
		btn_equip_tab_arsenal.pressed.connect(func(): _switch_equip_tab("ARSENAL"))
		equip_sub_nav.add_child(btn_equip_tab_arsenal)

		btn_equip_tab_upgrade = Button.new()
		btn_equip_tab_upgrade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_equip_tab_upgrade.custom_minimum_size = Vector2(0, 52)
		btn_equip_tab_upgrade.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_equip_tab_upgrade.icon = CyberTheme.get_ui_icon("core")
		btn_equip_tab_upgrade.expand_icon = true
		btn_equip_tab_upgrade.text = "POTENZIA"
		btn_equip_tab_upgrade.add_theme_font_size_override("font_size", 16)
		btn_equip_tab_upgrade.pressed.connect(func(): _switch_equip_tab("UPGRADE"))
		equip_sub_nav.add_child(btn_equip_tab_upgrade)

		btn_equip_tab_merge = Button.new()
		btn_equip_tab_merge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_equip_tab_merge.custom_minimum_size = Vector2(0, 52)
		btn_equip_tab_merge.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_equip_tab_merge.text = "▲ FUSIONE"
		btn_equip_tab_merge.add_theme_font_size_override("font_size", 16)
		btn_equip_tab_merge.pressed.connect(func(): _switch_equip_tab("MERGE"))
		equip_sub_nav.add_child(btn_equip_tab_merge)

		inventory_view.add_child(equip_sub_nav)
		inventory_view.move_child(equip_sub_nav, 0)

	# Pulsante 1-Tocco "⚡ EQUIPAGGIA MIGLIORI" sotto le statistiche dell'Eroe
	if hero_section_panel:
		var hero_vb := hero_section_panel.get_node_or_null("VBox") as VBoxContainer
		if hero_vb and not hero_vb.get_node_or_null("BtnAutoEquipBest"):
			btn_auto_equip_best = Button.new()
			btn_auto_equip_best.name = "BtnAutoEquipBest"
			btn_auto_equip_best.custom_minimum_size = Vector2(440, 52)
			btn_auto_equip_best.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			btn_auto_equip_best.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
			btn_auto_equip_best.add_theme_font_size_override("font_size", 18)
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
			hero_vb.add_child(btn_auto_equip_best)

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

	# Aggiorna stile e badge delle 3 Sub-Tab EQUIP
	if btn_equip_tab_arsenal:
		btn_equip_tab_arsenal.icon = CyberTheme.get_ui_icon("nav_equip")
		btn_equip_tab_arsenal.expand_icon = true
		btn_equip_tab_arsenal.text = "ARSENALE !" if can_improve else "ARSENALE"
		CyberTheme.style_button(btn_equip_tab_arsenal, CyberTheme.COL_YELLOW if current_equip_tab == "ARSENAL" else CyberTheme.COL_CYAN, current_equip_tab == "ARSENAL")
	if btn_equip_tab_upgrade:
		btn_equip_tab_upgrade.icon = CyberTheme.get_ui_icon("core")
		btn_equip_tab_upgrade.expand_icon = true
		btn_equip_tab_upgrade.text = "POTENZIA (" + str(Global.upgrade_scrolls) + ")"
		CyberTheme.style_button(btn_equip_tab_upgrade, CyberTheme.COL_YELLOW if current_equip_tab == "UPGRADE" else CyberTheme.COL_CYAN, current_equip_tab == "UPGRADE")
	if btn_equip_tab_merge:
		btn_equip_tab_merge.text = ("▲ FUSIONE (" + str(fusible.size()) + ")") if not fusible.is_empty() else "▲ FUSIONE"
		CyberTheme.style_button(btn_equip_tab_merge, CyberTheme.COL_YELLOW if current_equip_tab == "MERGE" else CyberTheme.COL_MAGENTA, current_equip_tab == "MERGE")

	if btn_auto_equip_best:
		if can_improve:
			btn_auto_equip_best.text = "⚡ EQUIPAGGIA DOTAZIONE MIGLIORE ⚡"
			CyberTheme.style_button(btn_auto_equip_best, CyberTheme.COL_YELLOW, true)
		else:
			btn_auto_equip_best.text = "✓ DOTAZIONE MIGLIORE ATTIVA"
			CyberTheme.style_button(btn_auto_equip_best, CyberTheme.COL_CYAN, false)

	var show_arsenal: bool = (current_equip_tab == "ARSENAL")
	var show_upgrade: bool = (current_equip_tab == "UPGRADE")
	var show_merge: bool = (current_equip_tab == "MERGE")

	if section_title and current_view == ViewMode.INVENTORY:
		if show_arsenal:
			section_title.text = "EQUIPAGGIAMENTO — ARSENALE EROE"
		elif show_upgrade:
			section_title.text = "OFFICINA — POTENZIAMENTO LIVELLI"
		else:
			section_title.text = "FUCINA RIPPERDOC — FUSIONE 3-IN-1"

	if hero_section_panel: hero_section_panel.visible = show_arsenal
	if inventory_title_lbl: inventory_title_lbl.visible = show_arsenal
	if inventory_grid: inventory_grid.visible = show_arsenal
	if upgrade_workshop_box: upgrade_workshop_box.visible = show_upgrade
	if forge_section_panel: forge_section_panel.visible = show_merge
	if merge_workshop_box: merge_workshop_box.visible = show_merge

	# Legenda Colori Rarità chiara e immediata sopra la griglia Arsenale
	if inventory_view:
		var leg_bar := inventory_view.get_node_or_null("RarityLegendBar") as PanelContainer
		if not leg_bar:
			leg_bar = PanelContainer.new()
			leg_bar.name = "RarityLegendBar"
			leg_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			leg_bar.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(10, 6))
			var leg_row := HBoxContainer.new()
			leg_row.alignment = BoxContainer.ALIGNMENT_CENTER
			leg_row.add_theme_constant_override("separation", 8)
			leg_bar.add_child(leg_row)

			for r_key in ["COMMON", "RARE", "EPIC", "LEGENDARY"]:
				var r_pill := PanelContainer.new()
				r_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box(r_key))
				var r_lbl := Label.new()
				r_lbl.text = CyberTheme.get_rarity_badge_text(r_key)
				r_lbl.add_theme_font_size_override("font_size", 14)
				CyberTheme.style_label(r_lbl, CyberTheme.get_rarity_color(r_key).lightened(0.20), 2)
				r_pill.add_child(r_lbl)
				leg_row.add_child(r_pill)

			var eq_pill := PanelContainer.new()
			eq_pill.add_theme_stylebox_override("panel", CyberTheme.make_equipped_badge_box())
			var eq_lbl := Label.new()
			eq_lbl.text = "✓ INDOSSATO"
			eq_lbl.add_theme_font_size_override("font_size", 14)
			CyberTheme.style_label(eq_lbl, Color(0.88, 1.0, 0.94, 1.0), 2)
			eq_pill.add_child(eq_lbl)
			leg_row.add_child(eq_pill)

			inventory_view.add_child(leg_bar)
			if inventory_grid:
				inventory_view.move_child(leg_bar, inventory_grid.get_index())
		leg_bar.visible = show_arsenal

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

	var wep_lvl: int = im.get_item_level(WeaponDB.equipped_weapon_id) if (im and im.has_method("get_item_level")) else 1
	var arm_lvl: int = im.get_item_level(WeaponDB.equipped_armor_id) if (im and not WeaponDB.equipped_armor_id.is_empty() and im.has_method("get_item_level")) else 1

	var eq_weapon: WeaponStats = WeaponDB.get_equipped_weapon()
	var base_atk: int = eq_weapon.get_final_damage() if eq_weapon else 10
	var total_atk: int = base_atk + atk_bonus + (wep_lvl - 1) * 3

	var armor_bonus: int = WeaponDB.get_equipped_armor_hp_bonus() + ((arm_lvl - 1) * 18 if not WeaponDB.equipped_armor_id.is_empty() else 0)
	var total_hp: int = 100 + hp_bonus + armor_bonus
	var total_crit: int = 10 + crit_bonus
	var total_speed: int = 300 + speed_bonus + int(WeaponDB.get_equipped_boots_speed_bonus())

	if hero_atk_label != null: hero_atk_label.text = "★ ATK: " + str(total_atk)
	if hero_hp_label != null: hero_hp_label.text = "✦ HP: " + str(total_hp)
	if hero_crit_label != null: hero_crit_label.text = "◆ CRIT: " + str(total_crit) + "%"
	if hero_speed_label != null: hero_speed_label.text = "⚡ VEL: " + str(total_speed)

	if merge_status_label:
		merge_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if not fusible.is_empty():
			var f_item: Dictionary = fusible[0]
			merge_status_label.text = "★ FUSIONE PRONTA! Unisci 3 copie identiche per salire di rarità: COMUNE ➔ RARO ➔ EPICO ➔ LEGGENDARIO\nPronto ora: 3x " + str(f_item["name"]) + " (" + CyberTheme.get_rarity_label_it(str(f_item["rarity"])) + ")"
		else:
			merge_status_label.text = "Unisci 3 copie dello stesso oggetto e rarità per evolverlo: COMUNE ➔ RARO ➔ EPICO ➔ LEGGENDARIO."

	if show_arsenal and inventory_grid:
		inventory_grid.columns = 2
		for child in inventory_grid.get_children(): child.queue_free()

		var items: Array = []
		if im and "inventory" in im: items = im.inventory

		for item in items:
			var item_id: String = str(item.get("id", ""))
			var cnt: int = int(item.get("count", 1))
			var is_eq: bool = im.is_item_equipped(item_id) if (im and im.has_method("is_item_equipped")) else false
			if cnt <= 0 and not is_eq:
				continue
			var i_lvl: int = im.get_item_level(item_id) if (im and im.has_method("get_item_level")) else 1
			var card := _create_gear_grid_card(item, item_id, str(item["name"]), str(item["slot"]), item.get("rarity", "COMMON"), is_eq, cnt, i_lvl)
			inventory_grid.add_child(card)
	elif show_upgrade:
		_populate_upgrade_workshop(im)
	elif show_merge:
		_populate_merge_workshop(im)

func _populate_upgrade_workshop(im: Node) -> void:
	if not upgrade_workshop_box:
		return
	for child in upgrade_workshop_box.get_children():
		child.queue_free()

	# Banner superiore con saldo risorse e istruzioni Officina
	var hdr_card := PanelContainer.new()
	hdr_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr_card.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(14, 10))

	var hdr_vbox := VBoxContainer.new()
	hdr_vbox.add_theme_constant_override("separation", 6)
	hdr_card.add_child(hdr_vbox)

	var res_lbl := Label.new()
	res_lbl.text = "▲ OFFICINA LIVELLI  —  Oro: " + str(Global.total_coins) + "   |   Nuclei: " + str(Global.upgrade_scrolls)
	res_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	res_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	res_lbl.add_theme_font_size_override("font_size", 17)
	CyberTheme.style_label(res_lbl, CyberTheme.COL_YELLOW, 3)
	hdr_vbox.add_child(res_lbl)

	var info_lbl := Label.new()
	info_lbl.text = "Potenzia Armi, Corazze, Anelli e Droni per aumentare ATK, HP e Velocità. Trovi i Nuclei nei livelli e dai Boss!"
	info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_lbl.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(info_lbl, Color(0.88, 0.95, 1.0, 1.0), 2)
	hdr_vbox.add_child(info_lbl)

	if not upgrade_feedback_msg.is_empty():
		var fb_lbl := Label.new()
		fb_lbl.text = upgrade_feedback_msg
		fb_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fb_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fb_lbl.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(fb_lbl, CyberTheme.COL_GREEN if "COMPLETATO" in upgrade_feedback_msg else CyberTheme.COL_MAGENTA, 3)
		hdr_vbox.add_child(fb_lbl)

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
		var can_afford: bool = (Global.total_coins >= coin_cost and Global.upgrade_scrolls >= scroll_cost)
		var stat_desc: String = im.get_item_stat_description(item_id, slot_name)

		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Cornice 3D SEMPRE del colore della Rarità (mai alterata in oro se indossato!)
		card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(rar_str, 12, 10))

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(row)

		var icon_ctrl := Control.new()
		icon_ctrl.custom_minimum_size = Vector2(76, 76)
		icon_ctrl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_ctrl.draw.connect(func():
			CyberTheme.draw_item_icon(icon_ctrl, Vector2(38, 38), item_id, slot_name, rar_col, 68.0, is_eq)
		)
		row.add_child(icon_ctrl)

		var mid_v := VBoxContainer.new()
		mid_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mid_v.add_theme_constant_override("separation", 4)
		row.add_child(mid_v)

		var tags_row := HBoxContainer.new()
		tags_row.add_theme_constant_override("separation", 6)
		mid_v.add_child(tags_row)

		var rar_pill := PanelContainer.new()
		rar_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box(rar_str))
		var rar_lbl := Label.new()
		rar_lbl.text = CyberTheme.get_rarity_badge_text(rar_str)
		rar_lbl.add_theme_font_size_override("font_size", 12)
		CyberTheme.style_label(rar_lbl, rar_col.lightened(0.22), 2)
		rar_pill.add_child(rar_lbl)
		tags_row.add_child(rar_pill)

		if is_eq:
			var eq_pill := PanelContainer.new()
			eq_pill.add_theme_stylebox_override("panel", CyberTheme.make_equipped_badge_box())
			var eq_lbl := Label.new()
			eq_lbl.text = "✓ INDOSSATO"
			eq_lbl.add_theme_font_size_override("font_size", 12)
			CyberTheme.style_label(eq_lbl, Color(0.88, 1.0, 0.94, 1.0), 2)
			eq_pill.add_child(eq_lbl)
			tags_row.add_child(eq_pill)

		var l_title := Label.new()
		l_title.text = item_name
		l_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l_title.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(l_title, Color.WHITE, 3)
		mid_v.add_child(l_title)

		var l_lvl := Label.new()
		l_lvl.text = slot_name + "  •  Lv. " + str(cur_lvl) + "  ➔  Lv. " + str(cur_lvl + 1)
		l_lvl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_lvl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l_lvl.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(l_lvl, CyberTheme.COL_CYAN, 2)
		mid_v.add_child(l_lvl)

		var l_stat := Label.new()
		l_stat.text = stat_desc
		l_stat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_stat.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l_stat.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_label(l_stat, Color(0.86, 0.95, 0.92, 1.0), 2)
		mid_v.add_child(l_stat)

		var right_v := VBoxContainer.new()
		right_v.custom_minimum_size = Vector2(154, 0)
		right_v.alignment = BoxContainer.ALIGNMENT_CENTER
		right_v.add_theme_constant_override("separation", 6)
		row.add_child(right_v)

		var cost_lbl := Label.new()
		cost_lbl.text = str(coin_cost) + " Oro • " + str(scroll_cost) + " Nuclei"
		cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_lbl.add_theme_font_size_override("font_size", 13)
		CyberTheme.style_label(cost_lbl, CyberTheme.COL_GREEN if can_afford else Color(1.0, 0.48, 0.58, 1.0), 2)
		right_v.add_child(cost_lbl)

		var btn_up := Button.new()
		btn_up.custom_minimum_size = Vector2(154, 48)
		btn_up.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_up.text = "▲ POTENZIA" if can_afford else "RISORSE INSUFF."
		btn_up.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_button(btn_up, CyberTheme.COL_GREEN if can_afford else CyberTheme.COL_CYAN, false)
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

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(310, 232)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Cornice 3D Scolpita SEMPRE fedele alla Rarità (Argento / Blu / Viola / Oro — mai ingiallita quando indossata!)
	card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box(rarity_str, 10, 8))

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 5)
	vb.alignment = BoxContainer.ALIGNMENT_END
	card.add_child(vb)

	# Riga superiore con Badge Rarità a sinistra e Badge Smeraldo "✓ INDOSSATO" a destra (distinto dall'Oro Leggendario!)
	var top_tags := HBoxContainer.new()
	top_tags.add_theme_constant_override("separation", 4)
	vb.add_child(top_tags)

	var rar_pill := PanelContainer.new()
	rar_pill.name = "RarityBadge"
	rar_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box(rarity_str))
	var rar_lbl := Label.new()
	rar_lbl.text = CyberTheme.get_rarity_badge_text(rarity_str)
	rar_lbl.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(rar_lbl, rarity_col.lightened(0.22), 2)
	rar_pill.add_child(rar_lbl)
	top_tags.add_child(rar_pill)

	var tag_spacer := Control.new()
	tag_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_tags.add_child(tag_spacer)

	if is_eq:
		var eq_pill := PanelContainer.new()
		eq_pill.name = "EquippedBadge"
		eq_pill.add_theme_stylebox_override("panel", CyberTheme.make_equipped_badge_box())
		var eq_lbl := Label.new()
		eq_lbl.text = "✓ INDOSSATO"
		eq_lbl.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_label(eq_lbl, Color(0.88, 1.0, 0.94, 1.0), 2)
		eq_pill.add_child(eq_lbl)
		top_tags.add_child(eq_pill)
	elif count > 1:
		var cnt_pill := PanelContainer.new()
		cnt_pill.add_theme_stylebox_override("panel", CyberTheme.make_rarity_pill_box(rarity_str))
		var cnt_lbl := Label.new()
		cnt_lbl.text = "x" + str(count)
		cnt_lbl.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_label(cnt_lbl, Color.WHITE, 2)
		cnt_pill.add_child(cnt_lbl)
		top_tags.add_child(cnt_pill)

	var icon_box := Control.new()
	icon_box.custom_minimum_size = Vector2(0, 84)
	icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_box.draw.connect(func():
		CyberTheme.draw_item_icon(icon_box, Vector2(icon_box.size.x * 0.5, 42.0), item_id, slot_name, rarity_col, 82.0, is_eq)
	)
	vb.add_child(icon_box)

	var lbl_name := Label.new()
	lbl_name.text = item_name + (" (x" + str(count) + ")" if (count > 1 and is_eq) else "")
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_name.add_theme_font_size_override("font_size", 18)
	CyberTheme.style_label(lbl_name, Color.WHITE, 3)
	vb.add_child(lbl_name)

	var lbl_meta := Label.new()
	lbl_meta.text = "Lv." + str(item_lvl) + "  •  " + slot_name
	lbl_meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_meta.add_theme_font_size_override("font_size", 16)
	CyberTheme.style_label(lbl_meta, rarity_col.lightened(0.24), 2)
	vb.add_child(lbl_meta)

	var act_row := HBoxContainer.new()
	act_row.add_theme_constant_override("separation", 6)
	act_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(act_row)

	var btn_eq := Button.new()
	btn_eq.custom_minimum_size = Vector2(0, 48)
	btn_eq.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_eq.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_eq.add_theme_font_size_override("font_size", 15)
	if is_eq:
		btn_eq.text = "✓ IN USO"
		CyberTheme.style_button(btn_eq, CyberTheme.COL_GREEN, false)
	else:
		btn_eq.text = "▲ EQUIPAGGIA"
		CyberTheme.style_button(btn_eq, CyberTheme.COL_CYAN, false)
	btn_eq.pressed.connect(func():
		var im: Node = get_node_or_null("/root/InventoryManager")
		if im:
			if is_eq and slot_name.to_upper() != "ARMA":
				im.unequip_item(slot_name)
				SoundFX.play_click()
			else:
				im.equip_item(item_id, slot_name)
				SoundFX.play_pickup()
			_update_top_bar()
			_populate_inventory()
	)
	act_row.add_child(btn_eq)

	var btn_info := Button.new()
	btn_info.custom_minimum_size = Vector2(94, 48)
	btn_info.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_info.text = "▲ LV."
	btn_info.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_button(btn_info, CyberTheme.COL_MAGENTA, false)
	btn_info.pressed.connect(func():
		SoundFX.play_click()
		_open_item_action_modal(item_data)
	)
	act_row.add_child(btn_info)

	return card

func _on_merge_all_pressed() -> void:
	var im: Node = get_node_or_null("/root/InventoryManager")
	if not im: return

	var fusible: Array = im.get_fusible_items()
	if fusible.is_empty():
		SoundFX.play_hit()
		if merge_status_label: merge_status_label.text = "❌ Nessun oggetto idoneo alla fusione."
		return

	var count_merged: int = 0
	for item in fusible:
		var res: Dictionary = im.merge_items(str(item["id"]), str(item["rarity"]))
		if res.get("success", false):
			count_merged += 1

	if count_merged > 0:
		SoundFX.play_win()
		if merge_status_label: merge_status_label.text = "🎉 Fusi " + str(count_merged) + " gruppi di oggetti!"
		_populate_inventory()
	else:
		SoundFX.play_hit()

func _populate_upgrades() -> void:
	if not talent_grid: return
	for child in talent_grid.get_children(): child.queue_free()

	var tm: Node = get_node_or_null("/root/TalentManager")
	var talent_keys: Array[String] = tm.TALENT_ORDER if (tm and "TALENT_ORDER" in tm) else [
		"atk", "hp", "fire_rate", "crit", "crit_dmg", "speed", "dodge",
		"aegis", "recovery", "vampirism", "armor_pen", "drone_tech", "exp_boost", "gold"
	]
	var talent_models := {
		"atk": "weapon_katana",
		"hp": "armor_nano_armor",
		"fire_rate": "weapon_smg",
		"crit": "ring_crit",
		"crit_dmg": "weapon_plasma_cannon",
		"speed": "ring_speed",
		"dodge": "armor_kevlar",
		"aegis": "drone_shield",
		"recovery": "drone_shield",
		"vampirism": "weapon_scythe",
		"armor_pen": "weapon_laser_rifle",
		"drone_tech": "drone_laser",
		"exp_boost": "weapon_homing_wand",
		"gold": "drone_laser"
	}

	for t_id in talent_keys:
		var def: Dictionary = tm.TALENT_DEFS[t_id] if (tm and "TALENT_DEFS" in tm) else {}
		var cur_lvl: int = int(tm.talent_levels.get(t_id, 0)) if (tm and "talent_levels" in tm) else 0
		var max_lvl: int = int(def.get("max_lvl", 5))
		var bonus_val: float = float(def.get("bonus_per_lvl", 1.0)) * float(cur_lvl)
		var cost: int = tm.get_cost(t_id) if (tm and tm.has_method("get_cost")) else 100

		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(315, 286)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var border_c := CyberTheme.COL_CYAN if cur_lvl > 0 else Color(0.55, 0.65, 0.80, 0.90)
		card.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("RARE" if cur_lvl > 0 else "COMMON", 10, 10))

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 5)
		vbox.alignment = BoxContainer.ALIGNMENT_END

		var model_box := Control.new()
		model_box.custom_minimum_size = Vector2(0, 82)
		model_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var m_key: String = str(talent_models.get(t_id, "weapon_pistol_base"))
		model_box.draw.connect(func():
			CyberTheme.draw_item_icon(model_box, Vector2(model_box.size.x * 0.5, 41.0), m_key, "", border_c, 74.0)
		)
		vbox.add_child(model_box)

		var lbl_title := Label.new()
		lbl_title.text = str(def.get("icon", "⭐")) + " " + str(def.get("name", t_id))
		lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_title.add_theme_font_size_override("font_size", 19)
		CyberTheme.style_label(lbl_title, CyberTheme.COL_CYAN, 4)
		vbox.add_child(lbl_title)

		var lbl_lvl := Label.new()
		lbl_lvl.text = "GRADO: Lv. " + str(cur_lvl) + " / " + str(max_lvl)
		lbl_lvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_lvl.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(lbl_lvl, CyberTheme.COL_YELLOW, 3)
		vbox.add_child(lbl_lvl)

		var lbl_info := Label.new()
		lbl_info.text = str(def.get("desc", ""))
		lbl_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_info.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(lbl_info, Color(0.84, 0.92, 1.0, 1.0), 3)
		vbox.add_child(lbl_info)

		var lbl_desc := Label.new()
		lbl_desc.text = "Bonus Attivo: +" + str(int(bonus_val)) + " " + str(def.get("unit", ""))
		lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_desc.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(lbl_desc, CyberTheme.COL_GREEN if cur_lvl > 0 else Color(0.75, 0.84, 0.96, 1.0), 3)
		vbox.add_child(lbl_desc)

		var btn_upg := Button.new()
		btn_upg.custom_minimum_size = Vector2(272, 50)
		btn_upg.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn_upg.add_theme_font_size_override("font_size", 16)
		if cost == -1:
			btn_upg.disabled = true
			btn_upg.text = "LIVELLO MASSIMO"
			CyberTheme.style_button(btn_upg, CyberTheme.COL_YELLOW, false)
		else:
			btn_upg.disabled = (Global.total_coins < cost)
			btn_upg.icon = CyberTheme.get_ui_icon("coin")
			btn_upg.expand_icon = true
			btn_upg.text = "POTENZIA (" + str(cost) + ")"
			CyberTheme.style_button(btn_upg, CyberTheme.COL_CYAN, Global.total_coins >= cost)

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
		card.add_child(vbox)
		talent_grid.add_child(card)

# --- SHOP & MONETIZATION ---

func _populate_shop() -> void:
	if ad_count_label: ad_count_label.text = "Rimasti oggi: " + str(3 - Global.daily_ads_watched) + " / 3"
	if btn_watch_ad: btn_watch_ad.disabled = (Global.daily_ads_watched >= 3)

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
		_trigger_rewards_popup("🎬", "VIDEO COMPLETATO!", "+20 💎 Gemme")
		if shop_result_label: shop_result_label.text = "🎬 Video completato! +20 💎 accreditate!"
	else:
		SoundFX.play_hit()
		if shop_result_label: shop_result_label.text = "❌ Limite video giornalieri raggiunto (3/3)."

func _buy_iap(gems_amount: int, price_str: String) -> void:
	Global.total_credits += gems_amount
	SoundFX.play_pickup()
	var sys_save: Node = get_node_or_null("/root/SaveSystem")
	if sys_save and sys_save.has_method("save_game"): sys_save.save_game()
	_update_top_bar()
	if shop_result_label: shop_result_label.text = "🛒 Acquisto " + price_str + " riuscito! +" + str(gems_amount) + " 💎!"

func _buy_crate(cost: int, crate_type: String) -> void:
	if Global.total_credits >= cost:
		Global.total_credits -= cost
		SoundFX.play_pickup()

		var normal_pool := [
			{"id": "shotgun", "name": "Fucile a Pompa", "slot": "ARMA", "rarity": "RARE"},
			{"id": "homing_wand", "name": "Conduttore Psionico", "slot": "ARMA", "rarity": "RARE"},
			{"id": "smg", "name": "Mitraglietta Cyber", "slot": "ARMA", "rarity": "RARE"},
			{"id": "kevlar", "name": "Giubbotto Kevlar", "slot": "CORAZZA", "rarity": "COMMON"},
			{"id": "ring_crit", "name": "Anello Critico", "slot": "ANELLO 1", "rarity": "COMMON"},
			{"id": "ring_speed", "name": "Anello Velocità", "slot": "ANELLO 2", "rarity": "RARE"},
			{"id": "drone_laser", "name": "Drone Laser", "slot": "PET 1", "rarity": "RARE"}
		]
		var epic_pool := [
			{"id": "katana", "name": "Katana Lame Veloci", "slot": "ARMA", "rarity": "EPIC"},
			{"id": "laser_rifle", "name": "Fucile Laser High-Tech", "slot": "ARMA", "rarity": "EPIC"},
			{"id": "nano_armor", "name": "Armatura Nano-Tech", "slot": "CORAZZA", "rarity": "EPIC"},
			{"id": "drone_shield", "name": "Drone Scudo", "slot": "PET 2", "rarity": "EPIC"},
			{"id": "scythe", "name": "Falce Pesante Perforante", "slot": "ARMA", "rarity": "LEGENDARY"},
			{"id": "plasma_cannon", "name": "Cannone al Plasma", "slot": "ARMA", "rarity": "LEGENDARY"}
		]

		var chosen: Dictionary = normal_pool[randi() % normal_pool.size()] if crate_type == "NORMAL" else epic_pool[randi() % epic_pool.size()]
		var item_id: String = str(chosen["id"])
		var item_name: String = str(chosen["name"])
		var slot_type: String = str(chosen["slot"])
		var rarity: String = str(chosen["rarity"])

		var im: Node = get_node_or_null("/root/InventoryManager")
		if im and im.has_method("add_item"):
			im.add_item(item_id, item_name, slot_type, rarity)

		var sys_save: Node = get_node_or_null("/root/SaveSystem")
		if sys_save and sys_save.has_method("save_game"): sys_save.save_game()

		var reward_display: String = item_name + " (" + CyberTheme.get_rarity_badge_text(rarity) + ")"
		_trigger_rewards_popup("🎁", "CASSA APERTA!", reward_display)
		if shop_result_label:
			shop_result_label.text = "🎉 TROVATO: " + reward_display
			CyberTheme.style_label(shop_result_label, CyberTheme.get_rarity_color(rarity).lightened(0.20), 3)
		_update_top_bar()
	else:
		SoundFX.play_hit()
		if shop_result_label: shop_result_label.text = "❌ Gemme insufficienti! Servono " + str(cost) + " 💎"

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
		btn_claim_checkin.text = "✅ PREMIO ODIERNO GIÀ RISCATTATO" if Global.checkin_claimed else "⚡ RISCATTA RIFORNIMENTO GIORNO " + str(Global.checkin_day) + " ⚡"

	if checkin_status_label:
		if Global.checkin_claimed:
			checkin_status_label.text = "✅ Rifornimento giornaliero acquisito. Torna domani per il prossimo Drop!"
		else:
			checkin_status_label.text = "🎁 Il Drop Corporativo del Giorno " + str(Global.checkin_day) + " è pronto per il prelievo!"

func _on_claim_checkin_pressed() -> void:
	var rm: Node = get_node_or_null("/root/RewardManager")
	if rm and rm.has_method("claim_daily_reward"):
		var res: Dictionary = rm.claim_daily_reward()
		if res.get("success", false):
			SoundFX.play_win()
			var rew_data: Dictionary = res.get("reward", {})
			_trigger_rewards_popup(str(rew_data.get("icon", "🎁")), "PREMIO GIORNALIERO!", str(rew_data.get("label", "Ricompensa")))
			_update_top_bar()
			_populate_checkin()
		else:
			SoundFX.play_hit()
			if checkin_status_label: checkin_status_label.text = str(res.get("message", "Impossibile riscattare"))

# --- QUEST SYSTEM ---

func _switch_quest_tab(tab_name: String) -> void:
	current_quest_tab = tab_name
	_style_subnav_btn(btn_quest_daily, current_quest_tab == "DAILY")
	_style_subnav_btn(btn_quest_weekly, current_quest_tab == "WEEKLY")
	_style_subnav_btn(btn_quest_monthly, current_quest_tab == "MONTHLY")
	_populate_quests()

func _style_subnav_btn(btn: Button, is_active: bool) -> void:
	if not btn: return
	CyberTheme.style_button(btn, CyberTheme.COL_YELLOW if is_active else CyberTheme.COL_CYAN, is_active)

func _populate_quests() -> void:
	if not quests_container: return
	quests_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for child in quests_container.get_children(): child.queue_free()

	var rm: Node = get_node_or_null("/root/RewardManager")
	if not rm: return

	var pool: Array = []
	match current_quest_tab:
		"DAILY": if "DAILY_QUESTS" in rm: pool = rm.DAILY_QUESTS
		"WEEKLY": if "WEEKLY_QUESTS" in rm: pool = rm.WEEKLY_QUESTS
		"MONTHLY": if "MONTHLY_QUESTS" in rm: pool = rm.MONTHLY_QUESTS

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
		lbl_title.add_theme_font_size_override("font_size", 18)
		CyberTheme.style_label(lbl_title, CyberTheme.COL_YELLOW if (is_ready and not is_claimed) else CyberTheme.COL_CYAN, 3)
		vbox.add_child(lbl_title)

		var lbl_desc := Label.new()
		lbl_desc.text = q_desc
		lbl_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_desc.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(lbl_desc, Color(0.90, 0.95, 1.0, 1.0), 2)
		vbox.add_child(lbl_desc)

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

# --- NAV BUTTON HANDLERS ---

func _on_nav_shop_pressed() -> void:
	SoundFX.play_click()
	_show_shop_view()

func _on_nav_equip_pressed() -> void:
	SoundFX.play_click()
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
	{"id": "RONIN", "title": "⚡ CYBER-RONIN", "wep": "pistol_base", "wep_name": "Pistola Cyber", "bonus": "+30 VEL • +5% CRIT", "stats": "ATK 12 • HP 100 • VEL 330", "rar": "RARE", "col": Color(0.0, 0.95, 1.0, 1.0)},
	{"id": "VANGUARD", "title": "★ VANGUARD", "wep": "shotgun", "wep_name": "Fucile a Pompa", "bonus": "+40 HP CORAZZA", "stats": "ATK 18 • HP 140 • VEL 295", "rar": "LEGENDARY", "col": Color(1.0, 0.84, 0.10, 1.0)},
	{"id": "NETRUNNER", "title": "◆ NETRUNNER", "wep": "homing_wand", "wep_name": "Conduttore Psion", "bonus": "+4 ATK GUIDATO", "stats": "ATK 15 • HP 105 • VEL 310", "rar": "EPIC", "col": Color(0.84, 0.28, 1.0, 1.0)}
]

const CHAR_COLOR_DEFS := [
	{"id": "CYAN", "label": "◆ CIANO", "col": Color(0.0, 0.95, 1.0, 1.0)},
	{"id": "MAGENTA", "label": "◆ MAGENTA", "col": Color(1.0, 0.12, 0.52, 1.0)},
	{"id": "GOLD", "label": "★ ORO", "col": Color(1.0, 0.86, 0.08, 1.0)},
	{"id": "GREEN", "label": "✦ BIO-VERDE", "col": Color(0.12, 1.0, 0.52, 1.0)}
]

## Schermata d'Entrata Cinematografica 3D all'apertura dell'App (per chi ha già un Operativo salvato)
func _show_welcome_entrance_screen() -> void:
	if is_instance_valid(welcome_layer):
		welcome_layer.queue_free()
		welcome_layer = null

	welcome_layer = CanvasLayer.new()
	welcome_layer.name = "WelcomeEntranceLayer"
	welcome_layer.layer = 34
	add_child(welcome_layer)

	var root_ctrl := Control.new()
	welcome_layer.add_child(root_ctrl)
	root_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# 1. Poster Key-Art 3D Full-Screen (con Logo Alato + "V-PUNK: ROGUE PROTOCOL" in alta definizione!)
	var bg_tex_rect := TextureRect.new()
	bg_tex_rect.texture = CyberTheme.get_model_texture("res://assets/cyber_models/ui_entrance_keyart.png")
	bg_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ctrl.add_child(bg_tex_rect)
	bg_tex_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Effetti particellari olografici + sfumatura inferiore per far risaltare il dock 3D
	welcome_fx_ctrl = Control.new()
	welcome_fx_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(welcome_fx_ctrl)
	welcome_fx_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	welcome_fx_ctrl.draw.connect(func():
		var sz := welcome_fx_ctrl.size
		welcome_fx_ctrl.draw_polygon(
			PackedVector2Array([Vector2(0, sz.y * 0.52), Vector2(sz.x, sz.y * 0.52), Vector2(sz.x, sz.y), Vector2(0, sz.y)]),
			PackedColorArray([Color(0.02, 0.03, 0.08, 0.0), Color(0.02, 0.03, 0.08, 0.0), Color(0.02, 0.03, 0.08, 0.94), Color(0.02, 0.03, 0.08, 0.94)])
		)
		for i in range(18):
			var px := fmod(float(i) * 97.0 + sin(menu_anim_t * 0.9 + float(i)) * 28.0, maxf(100.0, sz.x))
			var py := sz.y - fmod(menu_anim_t * (28.0 + float(i % 5) * 9.0) + float(i) * 83.0, maxf(200.0, sz.y))
			var pa := 0.25 + 0.35 * sin(menu_anim_t * 3.0 + float(i))
			welcome_fx_ctrl.draw_circle(Vector2(px, py), 2.4, Color(0.1, 0.95, 1.0, pa))
	)

	# 2. Dock d'Ingresso 3D Scolpito in basso con Anteprima Operativo + Pulsanti Gioca / Crea Operativo
	var dock_margin := MarginContainer.new()
	dock_margin.anchor_left = 0.0
	dock_margin.anchor_right = 1.0
	dock_margin.anchor_top = 1.0
	dock_margin.anchor_bottom = 1.0
	dock_margin.offset_left = 20.0
	dock_margin.offset_right = -20.0
	dock_margin.offset_top = -420.0
	dock_margin.offset_bottom = -24.0
	root_ctrl.add_child(dock_margin)

	var dock_panel := PanelContainer.new()
	dock_panel.add_theme_stylebox_override("panel", CyberTheme.make_3d_panel_box(18, 16))
	dock_margin.add_child(dock_panel)

	var dv := VBoxContainer.new()
	dv.alignment = BoxContainer.ALIGNMENT_CENTER
	dv.add_theme_constant_override("separation", 12)
	dock_panel.add_child(dv)

	# Riga Dossier Operativo Attivo + Modello 3D Olografico
	var hero_row := HBoxContainer.new()
	hero_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hero_row.add_theme_constant_override("separation", 16)
	dv.add_child(hero_row)

	var holo_stage := PanelContainer.new()
	holo_stage.custom_minimum_size = Vector2(150, 148)
	holo_stage.add_theme_stylebox_override("panel", CyberTheme.make_rarity_card_box("RARE", 8, 8))
	hero_row.add_child(holo_stage)

	var holo_ctrl := Control.new()
	holo_ctrl.custom_minimum_size = Vector2(134, 132)
	holo_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holo_stage.add_child(holo_ctrl)

	welcome_holo = Node2D.new()
	welcome_holo.position = Vector2(67, 88)
	welcome_holo.scale = Vector2(1.6, 1.6)
	welcome_holo.draw.connect(func():
		var aura_c := Global.get_player_accent_color()
		welcome_holo.draw_set_transform(Vector2(0, 18), 0.0, Vector2(1.0, 0.40))
		welcome_holo.draw_circle(Vector2.ZERO, 28.0, Color(0.05, 0.10, 0.20, 0.95))
		welcome_holo.draw_arc(Vector2.ZERO, 28.0, 0.0, TAU, 28, aura_c, 2.2)
		welcome_holo.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		CyberModels.draw_hero(welcome_holo, WeaponDB.equipped_weapon_id, menu_anim_t, false, false, PI * 0.5 + sin(menu_anim_t * 1.5) * 0.45)
	)
	holo_ctrl.add_child(welcome_holo)

	var info_v := VBoxContainer.new()
	info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_v.alignment = BoxContainer.ALIGNMENT_CENTER
	info_v.add_theme_constant_override("separation", 6)
	hero_row.add_child(info_v)

	var w_tag := Label.new()
	w_tag.text = "⚡ SISTEMA PRONTO • OPERATIVO ATTIVO"
	w_tag.add_theme_font_size_override("font_size", 13)
	CyberTheme.style_label(w_tag, CyberTheme.COL_CYAN, 3)
	info_v.add_child(w_tag)

	var w_name := Label.new()
	var op_call := Global.player_name if not Global.player_name.is_empty() else "V-77"
	w_name.text = op_call + "  [" + Global.get_class_display_name() + "]"
	w_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	w_name.add_theme_font_size_override("font_size", 22)
	CyberTheme.style_label(w_name, CyberTheme.COL_YELLOW, 4)
	info_v.add_child(w_name)

	var w_prog := Label.new()
	w_prog.text = "Mondo Sbloccato: 0" + str(Global.max_unlocked_world) + "/08\nOro: " + str(Global.total_coins) + "   •   Gemme: " + str(Global.total_credits) + "   •   Nuclei: " + str(Global.upgrade_scrolls)
	w_prog.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(w_prog, Color(0.90, 0.96, 1.0, 1.0), 2)
	info_v.add_child(w_prog)

	# Pulsante Primario 3D Oro: Entra nel Gioco
	var btn_enter := Button.new()
	btn_enter.custom_minimum_size = Vector2(0, 68)
	btn_enter.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_enter.text = "⚡ ENTRA A NIGHT CITY  (CONTINUA) ⚡"
	btn_enter.add_theme_font_size_override("font_size", 19)
	CyberTheme.style_button(btn_enter, CyberTheme.COL_YELLOW, true)
	btn_enter.pressed.connect(func():
		SoundFX.play_win()
		var tw := create_tween().set_parallel(true)
		tw.tween_property(root_ctrl, "modulate:a", 0.0, 0.26)
		tw.tween_property(dock_panel, "scale", Vector2(1.04, 1.04), 0.26)
		tw.chain().tween_callback(func():
			if is_instance_valid(welcome_layer):
				welcome_layer.queue_free()
				welcome_layer = null
		)
	)
	dv.add_child(btn_enter)

	# Pulsante Secondario 3D Ciano: Apri Creazione / Personalizzazione Operativo
	var btn_customize := Button.new()
	btn_customize.custom_minimum_size = Vector2(0, 52)
	btn_customize.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_customize.text = "★ CAMBIA / RICREA OPERATIVO"
	btn_customize.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_button(btn_customize, CyberTheme.COL_CYAN, false)
	btn_customize.pressed.connect(func():
		SoundFX.play_click()
		if is_instance_valid(welcome_layer):
			welcome_layer.queue_free()
			welcome_layer = null
		_show_character_creation_modal(false)
	)
	dv.add_child(btn_customize)

	dock_panel.pivot_offset = Vector2(340, 190)
	dock_panel.scale = Vector2(0.90, 0.90)
	dock_panel.modulate = Color(1, 1, 1, 0.0)
	var tw_open := create_tween().set_parallel(true)
	tw_open.tween_property(dock_panel, "scale", Vector2.ONE, 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_open.tween_property(dock_panel, "modulate:a", 1.0, 0.26)

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
	char_modal_layer.add_child(root_ctrl)
	root_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# 1. Sfondo Key-Art 3D ad Alta Risoluzione di Night City + Particelle Olografiche (NON più schermo piatto nero!)
	var keyart_bg := TextureRect.new()
	keyart_bg.texture = CyberTheme.get_model_texture("res://assets/cyber_models/ui_entrance_keyart.png")
	keyart_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	keyart_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	keyart_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ctrl.add_child(keyart_bg)
	keyart_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var glass_tint := ColorRect.new()
	glass_tint.color = Color(0.02, 0.035, 0.085, 0.78)
	glass_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(glass_tint)
	glass_tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	char_fx_ctrl = Control.new()
	char_fx_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(char_fx_ctrl)
	char_fx_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	char_fx_ctrl.draw.connect(func():
		var sz := char_fx_ctrl.size
		for i in range(16):
			var px := fmod(float(i) * 103.0 + cos(menu_anim_t * 0.8 + float(i)) * 24.0, maxf(100.0, sz.x))
			var py := sz.y - fmod(menu_anim_t * (25.0 + float(i % 4) * 8.0) + float(i) * 91.0, maxf(200.0, sz.y))
			char_fx_ctrl.draw_circle(Vector2(px, py), 2.2, Color(0.15, 0.95, 1.0, 0.28))
	)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	root_ctrl.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

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
	lbl_stage_top.text = "✨ ANTEPRIMA OLOGRAFICA 3D"
	lbl_stage_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_stage_top.add_theme_font_size_override("font_size", 13)
	CyberTheme.style_label(lbl_stage_top, CyberTheme.COL_CYAN, 2)
	preview_vbox.add_child(lbl_stage_top)

	var preview_ctrl := Control.new()
	preview_ctrl.custom_minimum_size = Vector2(360, 152)
	preview_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_vbox.add_child(preview_ctrl)

	char_preview_holo = Node2D.new()
	char_preview_holo.position = Vector2(180, 104)
	char_preview_holo.scale = Vector2(2.0, 2.0)
	char_preview_holo.draw.connect(_on_draw_char_preview_holo)
	preview_ctrl.add_child(char_preview_holo)

	char_preview_status_lbl = Label.new()
	char_preview_status_lbl.text = _get_char_preview_summary_text()
	char_preview_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_preview_status_lbl.add_theme_font_size_override("font_size", 13)
	CyberTheme.style_label(char_preview_status_lbl, Global.get_player_accent_color(), 3)
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
	btn_confirm.text = "⚡ ENTRA A NIGHT CITY — INIZIA ORA ⚡" if is_first_time else "⚡ SALVA E APPLICA OPERATIVO ⚡"
	btn_confirm.add_theme_font_size_override("font_size", 18)
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

	var preview_ang: float = PI * 0.5 + sin(menu_anim_t * 1.65) * 0.65
	var preview_mv := Vector2(sin(menu_anim_t * 1.65) * 0.55, 0.35)
	CyberModels.draw_hero(char_preview_holo, w_preview, menu_anim_t, true, false, preview_ang, preview_mv)

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
		CyberTheme.style_label(char_preview_status_lbl, Global.get_player_accent_color(), 3)
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
		CyberTheme.style_label(char_preview_status_lbl, Global.get_player_accent_color(), 3)
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
