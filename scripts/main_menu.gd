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

	if btn_quest_daily: btn_quest_daily.pressed.connect(func(): _switch_quest_tab("DAILY"))
	if btn_quest_weekly: btn_quest_weekly.pressed.connect(func(): _switch_quest_tab("WEEKLY"))
	if btn_quest_monthly: btn_quest_monthly.pressed.connect(func(): _switch_quest_tab("MONTHLY"))

	if btn_merge_all: btn_merge_all.pressed.connect(_on_merge_all_pressed)

	if btn_prev_world: btn_prev_world.pressed.connect(func(): _cycle_world(-1))
	if btn_next_world: btn_next_world.pressed.connect(func(): _cycle_world(1))
	if preview_icon: preview_icon.pressed.connect(func(): _cycle_world(1))

	var prof_card_ctrl: Control = find_child("ProfileCard", true, false) as Control
	if prof_card_ctrl:
		_connect_button(prof_card_ctrl, _open_settings_modal)

	var top_bar_hbox: HBoxContainer = find_child("TopBar", true, false) as HBoxContainer
	if top_bar_hbox and not top_bar_hbox.get_node_or_null("BtnSettingsTop"):
		var btn_set := Button.new()
		btn_set.name = "BtnSettingsTop"
		btn_set.custom_minimum_size = Vector2(56, 54)
		btn_set.text = "⚙️"
		btn_set.add_theme_font_size_override("font_size", 22)
		CyberTheme.style_button(btn_set, CyberTheme.COL_CYAN, false)
		btn_set.pressed.connect(_open_settings_modal)
		top_bar_hbox.add_child(btn_set)

	_update_top_bar()
	_show_home_view()

	if not Global.profile_created:
		call_deferred("_show_character_creation_modal", true)

	# Title Logo floating animation
	var title_lbl: Label = find_child("TitleLabel", true, false) as Label
	if title_lbl:
		var start_y: float = title_lbl.position.y
		var tw := create_tween().set_loops()
		tw.tween_property(title_lbl, "position:y", start_y - 4.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(title_lbl, "position:y", start_y + 4.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

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
		central.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.04, 0.055, 0.10, 0.86), Color(0, 0.95, 1, 0.45), 0.0, 2, 4, 8))

	var world_card: PanelContainer = find_child("WorldCard", true, false) as PanelContainer
	if world_card:
		world_card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.05, 0.07, 0.13, 0.92), CyberTheme.COL_CYAN, 0.04, 2, 8, 10))

	var summary_card: PanelContainer = find_child("EquippedSummaryCard", true, false) as PanelContainer
	if summary_card:
		summary_card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.06, 0.08, 0.15, 0.94), CyberTheme.COL_MAGENTA, 0.06, 2, 6, 6))

	var profile_card: PanelContainer = find_child("ProfileCard", true, false) as PanelContainer
	var currencies_card: PanelContainer = find_child("CurrenciesCard", true, false) as PanelContainer
	if profile_card:
		profile_card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.05, 0.07, 0.14, 0.95), CyberTheme.COL_CYAN, 0.08, 2, 5, 4))

	if currencies_card:
		currencies_card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.05, 0.07, 0.14, 0.95), CyberTheme.COL_YELLOW, -0.08, 2, 5, 4))

	var podium: PanelContainer = find_child("HeroPodium", true, false) as PanelContainer
	if podium:
		var sb_podium := StyleBoxFlat.new()
		sb_podium.bg_color = Color(0.04, 0.10, 0.20, 0.95)
		sb_podium.border_width_left = 3; sb_podium.border_width_top = 3; sb_podium.border_width_right = 3; sb_podium.border_width_bottom = 3
		sb_podium.border_color = Color(0, 0.95, 1, 0.95)
		sb_podium.shadow_color = Color(0, 0.95, 1, 0.35)
		sb_podium.shadow_size = 10
		sb_podium.corner_radius_top_left = 48; sb_podium.corner_radius_top_right = 48; sb_podium.corner_radius_bottom_left = 48; sb_podium.corner_radius_bottom_right = 48
		podium.add_theme_stylebox_override("panel", sb_podium)

	var title_lbl: Label = find_child("TitleLabel", true, false) as Label
	if title_lbl:
		title_lbl.text = "// V-PUNK : ROGUE PROTOCOL [" + Global.GAME_VERSION + "] //"
		title_lbl.add_theme_color_override("font_color", CyberTheme.COL_YELLOW)
		title_lbl.add_theme_color_override("font_outline_color", Color(0.95, 0.05, 0.45, 0.95))
		title_lbl.add_theme_constant_override("outline_size", 5)

	_setup_procedural_menu_models()

var menu_anim_t: float = 0.0
var cyber_bg_canvas: Control = null
var boss_holo_node: Node2D = null
var hero_holo_node: Node2D = null
var top_avatar_holo: Node2D = null
var char_modal_layer: CanvasLayer = null
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
	if is_instance_valid(char_preview_holo): char_preview_holo.queue_redraw()

func _setup_procedural_menu_models() -> void:
	if preview_icon:
		preview_icon.texture_normal = null
		boss_holo_node = Node2D.new()
		boss_holo_node.position = Vector2(255, 110)
		boss_holo_node.scale = Vector2(1.0, 1.0)
		boss_holo_node.draw.connect(func():
			var w: WorldData = WorldDB.get_selected_world()
			var wid: String = w.id if w else "world_1"
			var bcol: Color = w.boss_color if w else Color(0, 0.94, 1, 1)
			var acc: Color = w.accent_color if w else Color(0, 0.94, 1, 1)
			var banner_tex := CyberTheme.get_model_texture("res://assets/cyber_models/banner_" + wid + ".png")
			var rect := Rect2(Vector2(-255, -110), Vector2(510, 220))
			if banner_tex:
				boss_holo_node.draw_texture_rect(banner_tex, rect, false)
			else:
				boss_holo_node.draw_rect(rect, Color(0.03, 0.05, 0.12, 0.95), true)
			boss_holo_node.draw_rect(rect, acc, false, 2.5)
			boss_holo_node.draw_set_transform(Vector2(0, 6), 0.0, Vector2(1.38, 1.38))
			CyberModels.draw_boss(boss_holo_node, wid, menu_anim_t, bcol, false, -PI * 0.5 + sin(menu_anim_t * 1.5) * 0.25)
			boss_holo_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		)
		preview_icon.add_child(boss_holo_node)

	var hero_center: TextureRect = find_child("HeroCenter", true, false) as TextureRect
	if hero_center:
		hero_center.texture = null
		hero_holo_node = Node2D.new()
		hero_holo_node.position = Vector2(95, 115)
		hero_holo_node.scale = Vector2(2.35, 2.35)
		hero_holo_node.draw.connect(func():
			CyberModels.draw_hero(hero_holo_node, WeaponDB.equipped_weapon_id, menu_anim_t, false, true, -PI * 0.5 + sin(menu_anim_t * 2.0) * 0.2)
		)
		hero_center.add_child(hero_holo_node)

	var top_avatar: TextureRect = find_child("Avatar", true, false) as TextureRect
	if top_avatar:
		top_avatar.texture = null
		top_avatar_holo = Node2D.new()
		top_avatar_holo.position = Vector2(16, 16)
		top_avatar_holo.scale = Vector2(0.55, 0.55)
		top_avatar_holo.draw.connect(func():
			CyberModels.draw_hero(top_avatar_holo, WeaponDB.equipped_weapon_id, menu_anim_t, false, true, -PI * 0.5)
		)
		top_avatar.add_child(top_avatar_holo)

	# Modelli 3D nei Forzieri dello Shop
	if btn_buy_normal_crate:
		var nc_vis := Control.new()
		nc_vis.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nc_vis.set_anchors_preset(Control.PRESET_FULL_RECT)
		nc_vis.draw.connect(func():
			var c := Vector2(btn_buy_normal_crate.size.x * 0.5, 68.0)
			var crate_t := CyberTheme.get_model_texture("res://assets/cyber_models/prop_crate.png")
			if crate_t:
				nc_vis.draw_texture_rect(crate_t, Rect2(c - Vector2(44, 34), Vector2(88, 88)), false)
			CyberTheme.draw_item_icon(nc_vis, c + Vector2(-56, -6), "shotgun", "ARMA", Color(0.1, 0.6, 1.0, 1.0), 66.0)
			CyberTheme.draw_item_icon(nc_vis, c + Vector2(56, -6), "kevlar", "CORAZZA", Color(0.2, 0.9, 0.5, 1.0), 66.0)
		)
		btn_buy_normal_crate.add_child(nc_vis)

	if btn_buy_epic_crate:
		var ec_vis := Control.new()
		ec_vis.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ec_vis.set_anchors_preset(Control.PRESET_FULL_RECT)
		ec_vis.draw.connect(func():
			var c := Vector2(btn_buy_epic_crate.size.x * 0.5, 68.0)
			CyberTheme.draw_item_icon(ec_vis, c + Vector2(-62, 2), "katana", "ARMA", Color(0.8, 0.2, 1.0, 1.0), 68.0)
			CyberTheme.draw_item_icon(ec_vis, c + Vector2(62, 2), "scythe", "ARMA", Color(1.0, 0.2, 0.5, 1.0), 68.0)
			CyberTheme.draw_item_icon(ec_vis, c + Vector2(0, -8), "plasma_cannon", "ARMA", Color(1.0, 0.84, 0.0, 1.0), 78.0)
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

func _update_top_bar() -> void:
	var tm: Node = get_node_or_null("/root/TalentManager")
	var total_lvl: int = 1
	if tm and "talent_levels" in tm:
		for k in tm.talent_levels:
			total_lvl += int(tm.talent_levels[k])
	var callsign := Global.player_name if not Global.player_name.is_empty() else "NUOVO"
	if profile_level_label:
		profile_level_label.text = callsign + " [" + Global.get_class_display_name() + "] • Lv." + str(total_lvl)
	if energy_label: energy_label.text = "⚙️ " + str(Global.upgrade_scrolls)
	if coins_label: coins_label.text = "🪙 " + str(Global.total_coins)
	if gems_label: gems_label.text = "💎 " + str(Global.total_credits)

func _update_nav_styles() -> void:
	_style_nav_btn(btn_nav_shop, current_view == ViewMode.SHOP)
	_style_nav_btn(btn_nav_equip, current_view == ViewMode.INVENTORY)
	_style_nav_btn(btn_nav_home, current_view == ViewMode.HOME)
	_style_nav_btn(btn_upgrades, current_view == ViewMode.UPGRADES)
	_style_nav_btn(btn_nav_quests, current_view == ViewMode.QUESTS)

func _style_nav_btn(btn: Control, is_active: bool) -> void:
	if not btn:
		return
	btn.pivot_offset = btn.size / 2.0
	var label: Label = btn.get_node_or_null("Label") as Label
	if label:
		label.add_theme_color_override("font_color", CyberTheme.COL_YELLOW if is_active else Color(0.65, 0.72, 0.85, 1))
		label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.95))
		label.add_theme_constant_override("outline_size", 3)

	var sb := CyberTheme.make_cyber_box(
		Color(0.10, 0.16, 0.28, 0.98) if is_active else Color(0.05, 0.07, 0.13, 0.92),
		CyberTheme.COL_YELLOW if is_active else Color(0.0, 0.94, 1.0, 0.35),
		0.08,
		2 if is_active else 1,
		6 if is_active else 3,
		8 if is_active else 0
	)
	btn.add_theme_stylebox_override("panel", sb)

	var target_scale := Vector2(1.08, 1.08) if is_active else Vector2(1.0, 1.0)
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", target_scale, 0.18)

func _get_rarity_color(rarity_str: String) -> Color:
	match rarity_str.to_upper():
		"COMMON", "0": return Color(0.4, 0.4, 0.4, 1)
		"RARE", "1": return Color(0.1, 0.6, 1.0, 1)
		"EPIC", "2": return Color(0.7, 0.2, 1.0, 1)
		"LEGENDARY", "3", "GOLD": return Color(1.0, 0.75, 0.0, 1)
		"GREEN": return Color(0.2, 0.8, 0.4, 1)
		"BLUE": return Color(0.1, 0.6, 1.0, 1)
		"PURPLE": return Color(0.7, 0.2, 1.0, 1)
		_: return Color(0.3, 0.3, 0.3, 1)

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
	if section_title: section_title.text = "CAMPAGNA PRINCIPALE — SELEZIONE SETTORE"
	_hide_all_views()
	_fade_in_view(home_view)

	var world: WorldData = WorldDB.get_selected_world()
	if world:
		var world_num: int = WorldDB.world_order.find(world.id) + 1
		if world_num <= 0: world_num = 1
		var is_locked: bool = (world_num > Global.max_unlocked_world)

		if world_card_name:
			world_card_name.text = ("🔒 " if is_locked else "🔓 ") + world.display_name + (" [BLOCCATO]" if is_locked else "")
			world_card_name.add_theme_color_override("font_color", Color(0.65, 0.35, 0.45, 1.0) if is_locked else world.accent_color)
		if world_card_info:
			world_card_info.text = "Livelli: " + str(world.total_rooms) + " | Boss: " + world.boss_name + " | Bottino: x" + str(world.reward_multiplier) + " | Difficoltà: x" + str(world.enemy_hp_multiplier)
		if world_card_desc:
			if is_locked:
				world_card_desc.text = "🔒 SETTORE CRIPTATO: Completa il Mondo 0" + str(world_num - 1) + " per sbloccare l'accesso a questo settore."
			else:
				world_card_desc.text = world.description
		if btn_play_home:
			btn_play_home.disabled = is_locked
			if is_locked:
				btn_play_home.text = "🔒 COMPLETA MONDO 0" + str(world_num - 1) + " PER SBLOCCARE"
				CyberTheme.style_button(btn_play_home, CyberTheme.COL_MAGENTA, false)
			else:
				btn_play_home.text = "⚡ AFFRONTA SETTORE (" + str(world.total_rooms) + " LIVELLI) ▶"
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

	var hdr := Label.new()
	hdr.text = "⚡ ASSETTO DA COMBATTIMENTO & TELEMETRIA EROE (MODELLI 3D) ⚡"
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hdr.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_label(hdr, CyberTheme.COL_YELLOW, 3)
	dash.add_child(hdr)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var eq_weapon: WeaponStats = WeaponDB.get_equipped_weapon()
	var wep_id: String = WeaponDB.equipped_weapon_id
	var wep_name: String = eq_weapon.display_name if eq_weapon else "Pistola Base"
	var wep_dmg: int = eq_weapon.get_final_damage() if eq_weapon else 15

	var arm_id: String = WeaponDB.equipped_armor_id
	var eq_armor: Dictionary = WeaponDB.armors.get(arm_id, {}) as Dictionary
	var has_armor: bool = not arm_id.is_empty() and not eq_armor.is_empty()
	var arm_name: String = str(eq_armor.get("name", "Nessuna Corazza")) if has_armor else "Nessuna Corazza"
	var arm_hp: int = WeaponDB.get_equipped_armor_hp_bonus()

	var im: Node = get_node_or_null("/root/InventoryManager")
	var pet_item: Dictionary = im.get_equipped_item_in_slot("PET 1") if (im and im.has_method("get_equipped_item_in_slot")) else {}
	var has_pet: bool = not pet_item.is_empty() and not str(pet_item.get("id", "")).is_empty()
	var pet_id: String = str(pet_item.get("id", "drone_laser")) if has_pet else "drone_laser"
	var pet_name: String = str(pet_item.get("name", "Drone Laser")) if has_pet else "Slot Drone Vuoto"

	# 3 Vetrina Card Modelli 3D: Arma, Corazza, Drone
	var showcase_items := [
		{"id": wep_id, "slot": "ARMA", "title": wep_name, "stat": "⚔️ Danno: " + str(wep_dmg), "col": CyberTheme.COL_CYAN},
		{"id": arm_id if has_armor else "kevlar", "slot": "CORAZZA", "title": arm_name, "stat": ("🛡️ +" + str(arm_hp) + " HP") if has_armor else "🔒 Non Equipaggiata", "col": CyberTheme.COL_MAGENTA if has_armor else Color(0.35, 0.40, 0.52, 0.8)},
		{"id": pet_id, "slot": "PET 1", "title": pet_name, "stat": "🤖 Attivo in Arena" if has_pet else "🔒 Non Equipaggiato", "col": CyberTheme.COL_GREEN if has_pet else Color(0.35, 0.40, 0.52, 0.8)}
	]

	for s_info in showcase_items:
		var p := PanelContainer.new()
		p.custom_minimum_size = Vector2(200, 195)
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var c_acc: Color = s_info["col"]
		p.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.04, 0.06, 0.12, 0.96), c_acc, 0.05, 2, 5, 6))

		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_END
		vb.add_theme_constant_override("separation", 3)

		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 108)
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sid: String = s_info["id"]
		var sslot: String = s_info["slot"]
		spacer.draw.connect(func():
			CyberTheme.draw_item_icon(spacer, Vector2(spacer.size.x * 0.5, 56.0), sid, sslot, c_acc, 96.0)
		)
		vb.add_child(spacer)

		var l_name := Label.new()
		l_name.text = s_info["title"]
		l_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l_name.add_theme_font_size_override("font_size", 13)
		CyberTheme.style_label(l_name, Color.WHITE, 3)
		vb.add_child(l_name)

		var l_st := Label.new()
		l_st.text = s_info["stat"]
		l_st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l_st.add_theme_font_size_override("font_size", 12)
		CyberTheme.style_label(l_st, c_acc, 2)
		vb.add_child(l_st)

		p.add_child(vb)
		hbox.add_child(p)

	dash.add_child(hbox)

	var btn_quick_equip := Button.new()
	btn_quick_equip.custom_minimum_size = Vector2(460, 48)
	btn_quick_equip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_quick_equip.text = "⚙️ GESTISCI ARSENALE 3D, CORAZZE & IMPIANTI (6 SLOT) ▶"
	btn_quick_equip.add_theme_font_size_override("font_size", 15)
	CyberTheme.style_button(btn_quick_equip, CyberTheme.COL_CYAN, false)
	btn_quick_equip.pressed.connect(_on_nav_equip_pressed)
	dash.add_child(btn_quick_equip)

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
	if section_title: section_title.text = "ALBERO TALENTI PERMANENTI (6)"
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

func _update_active_slot_ui(slot_node_name: String, slot_type: String) -> void:
	var slot_panel: PanelContainer = find_child(slot_node_name, true, false) as PanelContainer
	if not slot_panel: return

	var im: Node = get_node_or_null("/root/InventoryManager")
	var eq_item: Dictionary = im.get_equipped_item_in_slot(slot_type) if (im and im.has_method("get_equipped_item_in_slot")) else {}

	var lbl: Label = slot_panel.get_node_or_null("Lbl") as Label
	var is_empty: bool = eq_item.is_empty() or eq_item.get("id", "").is_empty()
	var item_id: String = str(eq_item.get("id", ""))
	var item_lvl: int = im.get_item_level(item_id) if (im and not is_empty and im.has_method("get_item_level")) else 1

	if lbl:
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		if is_empty:
			lbl.text = slot_type + "\n[SLOTS LIBERO]"
			lbl.modulate = Color(0.65, 0.72, 0.85, 0.8)
		else:
			lbl.text = slot_type + " [Lv." + str(item_lvl) + "]\n" + str(eq_item.get("name", slot_type))
			lbl.modulate = Color.WHITE

	var rar_str: String = str(eq_item.get("rarity", "COMMON")) if not is_empty else "COMMON"
	var rar_col: Color = _get_rarity_color(rar_str) if not is_empty else Color(0.0, 0.94, 1.0, 0.55)
	slot_panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(
		Color(rar_col.r * 0.22, rar_col.g * 0.22, rar_col.b * 0.28, 0.96) if not is_empty else Color(0.06, 0.09, 0.16, 0.92),
		rar_col,
		0.05,
		2,
		6,
		6 if not is_empty else 2
	))

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
		CyberTheme.draw_item_icon(model_ctrl, Vector2(44.0, slot_panel.size.y * 0.5), draw_id, slot_type, rar_col, 68.0)
	)
	slot_panel.add_child(model_ctrl)

func _populate_inventory() -> void:
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

	var im: Node = get_node_or_null("/root/InventoryManager")
	var wep_lvl: int = im.get_item_level(WeaponDB.equipped_weapon_id) if (im and im.has_method("get_item_level")) else 1
	var arm_lvl: int = im.get_item_level(WeaponDB.equipped_armor_id) if (im and not WeaponDB.equipped_armor_id.is_empty() and im.has_method("get_item_level")) else 1

	var eq_weapon: WeaponStats = WeaponDB.get_equipped_weapon()
	var base_atk: int = eq_weapon.get_final_damage() if eq_weapon else 10
	var total_atk: int = base_atk + atk_bonus + (wep_lvl - 1) * 3

	var armor_bonus: int = WeaponDB.get_equipped_armor_hp_bonus() + ((arm_lvl - 1) * 18 if not WeaponDB.equipped_armor_id.is_empty() else 0)
	var total_hp: int = 100 + hp_bonus + armor_bonus
	var total_crit: int = 10 + crit_bonus
	var total_speed: int = 300 + speed_bonus + int(WeaponDB.get_equipped_boots_speed_bonus())

	if hero_atk_label != null: hero_atk_label.text = "⚔️ ATK: " + str(total_atk)
	if hero_hp_label != null: hero_hp_label.text = "❤️ HP: " + str(total_hp)
	if hero_crit_label != null: hero_crit_label.text = "🎯 CRIT: " + str(total_crit) + "%"
	if hero_speed_label != null: hero_speed_label.text = "⚡ VEL: " + str(total_speed) + " | ⚙️ " + str(Global.upgrade_scrolls)

	var fusible: Array = []
	if im and im.has_method("get_fusible_items"): fusible = im.get_fusible_items()

	if merge_status_label:
		if not fusible.is_empty():
			var f_item: Dictionary = fusible[0]
			merge_status_label.text = "🔴 Fusione Disponibile! 3x " + str(f_item["name"]) + " (" + str(f_item["rarity"]) + ")"
		else:
			merge_status_label.text = "Tocca un oggetto per Equipaggiarlo o Potenziarne il Livello (⚙️ Nuclei: " + str(Global.upgrade_scrolls) + ")."

	if inventory_grid:
		for child in inventory_grid.get_children(): child.queue_free()

		var items: Array = []
		if im and "inventory" in im: items = im.inventory

		for item in items:
			var item_id: String = str(item.get("id", ""))
			var is_eq: bool = im.is_item_equipped(item_id) if (im and im.has_method("is_item_equipped")) else false
			var i_lvl: int = im.get_item_level(item_id) if (im and im.has_method("get_item_level")) else 1
			var card := _create_gear_grid_card(item_id, str(item["name"]), str(item["slot"]), item.get("rarity", "COMMON"), is_eq, int(item.get("count", 1)), i_lvl)
			card.pressed.connect(func():
				SoundFX.play_click()
				_open_item_action_modal(item)
			)
			inventory_grid.add_child(card)

func _create_gear_grid_card(item_id: String, item_name: String, slot_name: String, rarity_val: Variant, is_eq: bool, count: int = 1, item_lvl: int = 1) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(204, 182)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var eq_badge := "\n⚡ [EQUIP • Lv." + str(item_lvl) + "]" if is_eq else ("\n[Lv." + str(item_lvl) + " • " + slot_name + "]" + (" (x" + str(count) + ")" if count > 1 else ""))
	btn.text = "\n\n\n\n" + item_name + eq_badge
	btn.add_theme_font_size_override("font_size", 13)

	var rarity_str: String = str(rarity_val)
	var rarity_col := _get_rarity_color(rarity_str)
	var border_col := CyberTheme.COL_YELLOW if is_eq else rarity_col
	var sb_norm := CyberTheme.make_cyber_box(Color(rarity_col.r * 0.20, rarity_col.g * 0.20, rarity_col.b * 0.26, 0.96), border_col, 0.05, 2, 6, 8)
	var sb_hov := CyberTheme.make_cyber_box(Color(rarity_col.r * 0.30, rarity_col.g * 0.30, rarity_col.b * 0.38, 0.98), border_col.lightened(0.35), 0.05, 2, 8, 12)
	btn.add_theme_stylebox_override("normal", sb_norm)
	btn.add_theme_stylebox_override("hover", sb_hov)
	btn.add_theme_stylebox_override("pressed", sb_hov)
	btn.add_theme_color_override("font_color", CyberTheme.COL_YELLOW if is_eq else Color.WHITE)
	btn.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.95))
	btn.add_theme_constant_override("outline_size", 3)

	# Modello 3D-Shaded dell'arma/corazza/anello/drone in grande formato nella card
	var icon_node := Control.new()
	icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_node.draw.connect(func():
		CyberTheme.draw_item_icon(icon_node, Vector2(btn.size.x * 0.5, 54.0), item_id, slot_name, border_col, 94.0)
	)
	btn.add_child(icon_node)

	return btn

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
	var talent_keys := ["atk", "hp", "crit", "recovery", "speed", "gold"]
	var talent_models := {
		"atk": "weapon_katana",
		"hp": "armor_nano_armor",
		"crit": "ring_crit",
		"recovery": "drone_shield",
		"speed": "ring_speed",
		"gold": "drone_laser"
	}

	for t_id in talent_keys:
		var def: Dictionary = tm.TALENT_DEFS[t_id] if (tm and "TALENT_DEFS" in tm) else {}
		var cur_lvl: int = int(tm.talent_levels.get(t_id, 0)) if (tm and "talent_levels" in tm) else 0
		var max_lvl: int = int(def.get("max_lvl", 5))
		var bonus_val: float = float(def.get("bonus_per_lvl", 1.0)) * float(cur_lvl)
		var cost: int = tm.get_cost(t_id) if (tm and tm.has_method("get_cost")) else 100

		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(315, 255)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var border_c := CyberTheme.COL_CYAN if cur_lvl > 0 else Color(0.28, 0.36, 0.52, 0.88)
		card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.05, 0.08, 0.15, 0.96), border_c, 0.05, 2, 6, 8 if cur_lvl > 0 else 2))

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		vbox.alignment = BoxContainer.ALIGNMENT_END

		var model_box := Control.new()
		model_box.custom_minimum_size = Vector2(0, 88)
		model_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var m_key: String = str(talent_models.get(t_id, "weapon_pistol_base"))
		model_box.draw.connect(func():
			CyberTheme.draw_item_icon(model_box, Vector2(model_box.size.x * 0.5, 44.0), m_key, "", border_c, 78.0)
		)
		vbox.add_child(model_box)

		var lbl_title := Label.new()
		lbl_title.text = str(def.get("icon", "⭐")) + " " + str(def.get("name", t_id))
		lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_title.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_label(lbl_title, CyberTheme.COL_CYAN, 3)
		vbox.add_child(lbl_title)

		var lbl_lvl := Label.new()
		lbl_lvl.text = "GRADO IMPIANTO: Lv. " + str(cur_lvl) + " / " + str(max_lvl)
		lbl_lvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_lvl.add_theme_font_size_override("font_size", 13)
		CyberTheme.style_label(lbl_lvl, CyberTheme.COL_YELLOW, 3)
		vbox.add_child(lbl_lvl)

		var lbl_desc := Label.new()
		lbl_desc.text = "Bonus Attivo: +" + str(bonus_val) + " " + str(def.get("unit", ""))
		lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_desc.add_theme_font_size_override("font_size", 13)
		CyberTheme.style_label(lbl_desc, Color(0.88, 0.94, 1.0, 1.0), 2)
		vbox.add_child(lbl_desc)

		var btn_upg := Button.new()
		btn_upg.custom_minimum_size = Vector2(240, 44)
		btn_upg.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if cost == -1:
			btn_upg.disabled = true
			btn_upg.text = "IMPIANTO AL MASSIMO"
			CyberTheme.style_button(btn_upg, CyberTheme.COL_YELLOW, false)
		else:
			btn_upg.disabled = (Global.total_coins < cost)
			btn_upg.text = "POTENZIA (" + str(cost) + " 🪙)"
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

		var reward_display: String = item_name + " (" + rarity + ")"
		_trigger_rewards_popup("🎁", "CASSA APERTA!", reward_display)
		if shop_result_label: shop_result_label.text = "🎉 TROVATO: " + reward_display
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

			var border_c := Color(0.28, 0.34, 0.48, 0.7)
			var bg_c := Color(0.05, 0.07, 0.13, 0.90)
			if day_num < Global.checkin_day:
				bg_c = Color(0.06, 0.14, 0.10, 0.85)
				border_c = CyberTheme.COL_GREEN
			elif day_num == Global.checkin_day:
				bg_c = Color(0.08, 0.18, 0.28, 0.98)
				border_c = CyberTheme.COL_YELLOW
			card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(bg_c, border_c, 0.05, 2, 6, 8 if day_num == Global.checkin_day else 2))

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
			lbl_day.add_theme_font_size_override("font_size", 14)
			CyberTheme.style_label(lbl_day, CyberTheme.COL_YELLOW if day_num == Global.checkin_day else Color(0.85, 0.92, 1.0, 1.0), 3)
			vbox.add_child(lbl_day)

			var lbl_rew := Label.new()
			lbl_rew.text = str(r["icon"]) + " " + str(r["amt"])
			lbl_rew.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl_rew.add_theme_font_size_override("font_size", 15)
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
	btn.add_theme_color_override("font_color", Color(0, 0.94, 1, 1) if is_active else Color(0.6, 0.6, 0.6, 1))

func _populate_quests() -> void:
	if not quests_container: return
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

		var max_val: int = int(q.get("target_amt", q.get("target_amount", q.get("target", q.get("max", 1)))))
		var is_claimed: bool = Global.quests_claimed.get(q_id, false)
		var q_title: String = str(q.get("title", "Missione"))
		var q_desc: String = str(q.get("desc", q.get("description", q_title)))

		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 152)
		var q_col := CyberTheme.COL_CYAN if not is_claimed else Color(0.25, 0.28, 0.35, 0.8)
		card.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.05, 0.08, 0.15, 0.96), q_col, 0.05, 2, 6, 8 if not is_claimed else 0))

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER

		var q_icon_ctrl := Control.new()
		q_icon_ctrl.custom_minimum_size = Vector2(92, 92)
		q_icon_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var q_m_id := "weapon_plasma_cannon" if "kills" in stat_type else ("armor_nano_armor" if "runs" in stat_type else "drone_laser")
		q_icon_ctrl.draw.connect(func():
			CyberTheme.draw_item_icon(q_icon_ctrl, Vector2(46, 46), q_m_id, "", q_col, 80.0)
		)
		hbox.add_child(q_icon_ctrl)

		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 6)

		var lbl_title := Label.new()
		lbl_title.text = q_title
		lbl_title.add_theme_font_size_override("font_size", 17)
		CyberTheme.style_label(lbl_title, CyberTheme.COL_CYAN, 3)
		vbox.add_child(lbl_title)

		var lbl_desc := Label.new()
		lbl_desc.text = q_desc + "  [" + str(min(current_val, max_val)) + " / " + str(max_val) + "]"
		lbl_desc.add_theme_font_size_override("font_size", 14)
		CyberTheme.style_label(lbl_desc, Color(0.88, 0.94, 1.0, 1.0), 2)
		vbox.add_child(lbl_desc)

		var pbar := ProgressBar.new()
		pbar.custom_minimum_size = Vector2(0, 18)
		pbar.max_value = max(1, max_val)
		pbar.value = min(current_val, max_val)
		pbar.show_percentage = false
		vbox.add_child(pbar)

		hbox.add_child(vbox)

		# Reward Badge
		var badge := PanelContainer.new()
		badge.custom_minimum_size = Vector2(104, 62)
		badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		badge.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.09, 0.12, 0.22, 0.95), CyberTheme.COL_MAGENTA, 0.08, 2, 5, 4))

		var badge_lbl := Label.new()
		badge_lbl.text = ("🪙 +" if q["reward_type"] == "coins" else "💎 +") + str(q["reward_amt"])
		badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_lbl.add_theme_font_size_override("font_size", 15)
		CyberTheme.style_label(badge_lbl, CyberTheme.COL_YELLOW if q["reward_type"] == "coins" else CyberTheme.COL_CYAN, 3)
		badge.add_child(badge_lbl)

		hbox.add_child(badge)

		var btn_claim := Button.new()
		btn_claim.custom_minimum_size = Vector2(130, 62)
		btn_claim.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var is_ready: bool = current_val >= max_val

		if is_claimed:
			btn_claim.disabled = true
			btn_claim.text = "COMPLETATA"
			CyberTheme.style_button(btn_claim, CyberTheme.COL_CYAN, false)
		elif is_ready:
			btn_claim.disabled = false
			btn_claim.text = "RISCATTA"
			CyberTheme.style_button(btn_claim, CyberTheme.COL_YELLOW, true)
		else:
			btn_claim.disabled = true
			btn_claim.text = str(current_val) + "/" + str(max_val)
			CyberTheme.style_button(btn_claim, CyberTheme.COL_CYAN, false)

		btn_claim.pressed.connect(func():
			if not is_claimed and is_ready:
				Global.quests_claimed[q_id] = true
				var rew_str: String = ("+" + str(q["reward_amt"]) + " 🪙 Monete") if q["reward_type"] == "coins" else ("+" + str(q["reward_amt"]) + " 💎 Gemme")
				if q["reward_type"] == "coins": Global.total_coins += int(q["reward_amt"])
				else: Global.total_credits += int(q["reward_amt"])
				SoundFX.play_pickup()
				_trigger_rewards_popup("🎯", "MISSIONE RISCATTATA!", rew_str)
				var sys_save: Node = get_node_or_null("/root/SaveSystem")
				if sys_save and sys_save.has_method("save_game"): sys_save.save_game()
				_update_top_bar()
				_populate_quests()
		)

		hbox.add_child(btn_claim)
		card.add_child(hbox)
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
	{"id": "RONIN", "title": "⚡ CYBER-RONIN", "wep": "pistol_base", "wep_name": "Pistola Base", "bonus": "+30 VEL | +5% CRIT", "col": Color(0.0, 0.95, 1.0, 1.0)},
	{"id": "VANGUARD", "title": "🛡️ VANGUARD", "wep": "shotgun", "wep_name": "Fucile a Pompa", "bonus": "+40 HP CORAZZA", "col": Color(0.99, 0.93, 0.04, 1.0)},
	{"id": "NETRUNNER", "title": "🔮 NETRUNNER", "wep": "homing_wand", "wep_name": "Conduttore Psion", "bonus": "+4 ATK GUIDATO", "col": Color(1.0, 0.08, 0.45, 1.0)}
]

const CHAR_COLOR_DEFS := [
	{"id": "CYAN", "label": "🔹 CIANO", "col": Color(0.0, 0.95, 1.0, 1.0)},
	{"id": "MAGENTA", "label": "🔸 MAGENTA", "col": Color(1.0, 0.12, 0.52, 1.0)},
	{"id": "GOLD", "label": "⭐ ORO", "col": Color(1.0, 0.86, 0.08, 1.0)},
	{"id": "GREEN", "label": "🟢 BIO-VERDE", "col": Color(0.12, 1.0, 0.52, 1.0)}
]

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

	var overlay := ColorRect.new()
	overlay.color = Color(0.015, 0.02, 0.05, 0.96)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ctrl.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	root_ctrl.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var main_panel := PanelContainer.new()
	main_panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.04, 0.06, 0.13, 0.98), CyberTheme.COL_CYAN, 0.01, 2, 8, 14))
	margin.add_child(main_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_panel.add_child(vbox)

	# 1. Titolo Terminale con Versione Build Visibile
	var lbl_hdr := Label.new()
	lbl_hdr.text = "// CREAZIONE OPERATIVO [" + Global.GAME_VERSION + "] //"
	lbl_hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hdr.add_theme_font_size_override("font_size", 19)
	CyberTheme.style_label(lbl_hdr, CyberTheme.COL_YELLOW, 4)
	vbox.add_child(lbl_hdr)

	var lbl_sub := Label.new()
	lbl_sub.text = "Personalizza Nome, Archetipo e Colore Visiera per iniziare a Night City"
	lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_sub.add_theme_font_size_override("font_size", 13)
	CyberTheme.style_label(lbl_sub, CyberTheme.COL_CYAN, 2)
	vbox.add_child(lbl_sub)

	# 2. Podio Olografico 3D Anteprima in Tempo Reale
	char_preview_panel = PanelContainer.new()
	char_preview_panel.custom_minimum_size = Vector2(260, 195)
	char_preview_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	char_preview_panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.03, 0.08, 0.16, 0.95), Global.get_player_accent_color(), 0.03, 2, 6, 10))
	vbox.add_child(char_preview_panel)

	var preview_vbox := VBoxContainer.new()
	preview_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	preview_vbox.add_theme_constant_override("separation", 2)
	preview_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	char_preview_panel.add_child(preview_vbox)

	var preview_ctrl := Control.new()
	preview_ctrl.custom_minimum_size = Vector2(220, 152)
	preview_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_vbox.add_child(preview_ctrl)

	char_preview_holo = Node2D.new()
	char_preview_holo.position = Vector2(110, 82)
	char_preview_holo.scale = Vector2(2.2, 2.2)
	char_preview_holo.draw.connect(_on_draw_char_preview_holo)
	preview_ctrl.add_child(char_preview_holo)

	char_preview_status_lbl = Label.new()
	char_preview_status_lbl.text = "CLASSE: " + char_selected_class + " | AURA: " + char_selected_color
	char_preview_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_preview_status_lbl.add_theme_font_size_override("font_size", 12)
	CyberTheme.style_label(char_preview_status_lbl, Global.get_player_accent_color(), 3)
	preview_vbox.add_child(char_preview_status_lbl)

	# 3. Inserimento Nome Operativo (Callsign)
	var lbl_name_prompt := Label.new()
	lbl_name_prompt.text = "1. NOME OPERATIVO / CALLSIGN:"
	lbl_name_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name_prompt.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(lbl_name_prompt, CyberTheme.COL_YELLOW, 3)
	vbox.add_child(lbl_name_prompt)

	var name_hbox := HBoxContainer.new()
	name_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	name_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(name_hbox)

	char_name_input = LineEdit.new()
	char_name_input.custom_minimum_size = Vector2(340, 46)
	char_name_input.placeholder_text = "Inserisci il tuo nome (es. V-RONIN)..."
	char_name_input.text = Global.player_name if not Global.player_name.is_empty() else "V-77"
	char_name_input.max_length = 14
	char_name_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_name_input.add_theme_font_size_override("font_size", 17)
	char_name_input.add_theme_stylebox_override("normal", CyberTheme.make_cyber_box(Color(0.03, 0.05, 0.10, 0.98), CyberTheme.COL_CYAN, 0.03, 2, 6, 4))
	char_name_input.text_submitted.connect(func(_t: String):
		char_name_input.release_focus()
		DisplayServer.virtual_keyboard_hide()
	)
	name_hbox.add_child(char_name_input)

	var btn_rand_name := Button.new()
	btn_rand_name.custom_minimum_size = Vector2(140, 46)
	btn_rand_name.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_rand_name.focus_mode = Control.FOCUS_NONE
	btn_rand_name.text = "🎲 CASUALE"
	btn_rand_name.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_button(btn_rand_name, CyberTheme.COL_MAGENTA, false)
	btn_rand_name.pressed.connect(_on_char_rand_name_pressed)
	name_hbox.add_child(btn_rand_name)

	# 4. Selezione Archetipo / Classe (3 Card con Modello Arma 3D)
	var lbl_class_prompt := Label.new()
	lbl_class_prompt.text = "2. SCEGLI IL TUO ARCHETIPO ESOSCHELETRO & ARMA INIZIALE:"
	lbl_class_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_class_prompt.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(lbl_class_prompt, CyberTheme.COL_YELLOW, 3)
	vbox.add_child(lbl_class_prompt)

	var class_hbox := HBoxContainer.new()
	class_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	class_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(class_hbox)

	for c_def in CHAR_CLASS_DEFS:
		var cb := Button.new()
		cb.custom_minimum_size = Vector2(190, 175)
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		cb.focus_mode = Control.FOCUS_NONE
		var cid: String = str(c_def["id"])
		var cwep: String = str(c_def["wep"])
		var ccol: Color = c_def["col"]
		cb.text = "\n\n\n\n" + str(c_def["title"]) + "\nArma: " + str(c_def["wep_name"]) + "\n" + str(c_def["bonus"])
		cb.add_theme_font_size_override("font_size", 12)
		CyberTheme.style_button(cb, ccol, char_selected_class == cid)
		class_hbox.add_child(cb)

		var w_icon := Control.new()
		w_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cb.add_child(w_icon)
		w_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		w_icon.draw.connect(func():
			CyberTheme.draw_item_icon(w_icon, Vector2(cb.size.x * 0.5, 48.0), cwep, "ARMA", ccol, 78.0)
		)

		cb.pressed.connect(_on_char_class_selected.bind(cid))
		char_class_btns[cid] = cb

	# 5. Selezione Colore Visiera / Aura Neon
	var lbl_col_prompt := Label.new()
	lbl_col_prompt.text = "3. COLORE AURA NEON & VISIERA:"
	lbl_col_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_col_prompt.add_theme_font_size_override("font_size", 14)
	CyberTheme.style_label(lbl_col_prompt, CyberTheme.COL_YELLOW, 3)
	vbox.add_child(lbl_col_prompt)

	var col_hbox := HBoxContainer.new()
	col_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	col_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(col_hbox)

	for col_def in CHAR_COLOR_DEFS:
		var col_btn := Button.new()
		col_btn.custom_minimum_size = Vector2(142, 48)
		col_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		col_btn.focus_mode = Control.FOCUS_NONE
		var col_id: String = str(col_def["id"])
		var col_val: Color = col_def["col"]
		var col_lbl: String = str(col_def["label"])
		col_btn.add_theme_font_size_override("font_size", 13)
		_style_color_choice_btn(col_btn, col_val, col_lbl, char_selected_color == col_id)
		col_btn.pressed.connect(_on_char_color_selected.bind(col_id))
		col_hbox.add_child(col_btn)
		char_color_btns[col_id] = col_btn

	# 6. Pulsanti di Conferma Creazione (e Chiudi se già creato)
	var action_hbox := HBoxContainer.new()
	action_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	action_hbox.add_theme_constant_override("separation", 14)
	vbox.add_child(action_hbox)

	var btn_confirm := Button.new()
	btn_confirm.custom_minimum_size = Vector2(440 if is_first_time else 340, 62)
	btn_confirm.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn_confirm.focus_mode = Control.FOCUS_NONE
	btn_confirm.text = "⚡ CREA OPERATIVO & INIZIA DA ZERO ⚡" if is_first_time else "⚡ SALVA / RICREA DA ZERO ⚡"
	btn_confirm.add_theme_font_size_override("font_size", 18)
	CyberTheme.style_button(btn_confirm, CyberTheme.COL_YELLOW, true)
	btn_confirm.pressed.connect(_on_char_confirm_pressed)
	action_hbox.add_child(btn_confirm)

	if not is_first_time:
		var btn_cancel := Button.new()
		btn_cancel.custom_minimum_size = Vector2(180, 62)
		btn_cancel.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn_cancel.focus_mode = Control.FOCUS_NONE
		btn_cancel.text = "ANNULLA"
		btn_cancel.add_theme_font_size_override("font_size", 16)
		CyberTheme.style_button(btn_cancel, CyberTheme.COL_CYAN, false)
		btn_cancel.pressed.connect(_on_char_cancel_pressed)
		action_hbox.add_child(btn_cancel)

func _style_color_choice_btn(btn: Button, col_val: Color, label_str: String, is_selected: bool) -> void:
	if not btn: return
	btn.text = ("✓ " if is_selected else "") + label_str
	var bg := Color(col_val.r * 0.42, col_val.g * 0.42, col_val.b * 0.42, 0.98) if is_selected else Color(0.06, 0.08, 0.14, 0.95)
	var border := Color.WHITE if is_selected else col_val
	var sb := CyberTheme.make_cyber_box(bg, border, 0.06, 3 if is_selected else 2, 8 if is_selected else 5, 12 if is_selected else 4)
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
	char_preview_holo.draw_circle(Vector2.ZERO, 32.0, Color(aura_col.r, aura_col.g, aura_col.b, 0.22))
	CyberModels.draw_hero(char_preview_holo, w_preview, menu_anim_t, true, true, -PI * 0.5 + sin(menu_anim_t * 2.0) * 0.25)

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
			CyberTheme.style_button(char_class_btns[id_k], c_def["col"], id_k == cid)
	if is_instance_valid(char_preview_status_lbl):
		char_preview_status_lbl.text = "CLASSE: " + char_selected_class + " | AURA: " + char_selected_color
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
	if is_instance_valid(char_preview_panel):
		char_preview_panel.add_theme_stylebox_override("panel", CyberTheme.make_cyber_box(Color(0.03, 0.08, 0.16, 0.95), Global.get_player_accent_color(), 0.03, 2, 6, 10))
	if is_instance_valid(char_preview_status_lbl):
		char_preview_status_lbl.text = "CLASSE: " + char_selected_class + " | AURA: " + char_selected_color
		CyberTheme.style_label(char_preview_status_lbl, Global.get_player_accent_color(), 3)
	if is_instance_valid(char_preview_holo):
		char_preview_holo.queue_redraw()

func _on_char_confirm_pressed() -> void:
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
	if sys_save and sys_save.has_method("reset_save"):
		sys_save.reset_save()

	Global.profile_created = true
	Global.player_name = final_name
	Global.player_class = char_selected_class
	Global.player_color_id = char_selected_color

	var im: Node = get_node_or_null("/root/InventoryManager")
	if im and im.has_method("init_starter_loadout"):
		im.init_starter_loadout(Global.player_class)

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
