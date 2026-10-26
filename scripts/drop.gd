extends Area2D

@export var drop_type: String = "xp_coin" # "xp_coin", "heal", "upgrade_scroll", "gear_drop"
var is_collecting: bool = false
var anim_t: float = 0.0
var preview_gear_icon: String = "armor_kevlar"

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D

func _ready() -> void:
	add_to_group("drops")
	body_entered.connect(_on_body_entered)
	if sprite:
		sprite.visible = false # Sostituito dal modello 3D/vettoriale neon in _draw()
	anim_t = randf() * TAU
	var icons := ["armor_kevlar", "armor_nano_armor", "ring_crit", "ring_speed", "drone_laser", "drone_shield", "weapon_shotgun", "weapon_katana"]
	preview_gear_icon = icons[randi() % icons.size()]

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

func _draw() -> void:
	var bob := sin(anim_t * 5.0) * 2.8
	var center := Vector2(0, bob)

	if drop_type == "heal":
		# Medikit Nanobot (Verde brillante)
		draw_circle(center, 13.0, Color(0.1, 1.0, 0.45, 0.25))
		draw_circle(center, 9.0, Color(0.08, 0.22, 0.14, 0.95))
		draw_arc(center, 9.0, 0.0, TAU, 24, Color(0.2, 1.0, 0.5, 0.95), 2.0)
		draw_rect(Rect2(center + Vector2(-2, -5), Vector2(4, 10)), Color(0.3, 1.0, 0.6, 1.0), true)
		draw_rect(Rect2(center + Vector2(-5, -2), Vector2(10, 4)), Color(0.3, 1.0, 0.6, 1.0), true)
	elif drop_type == "upgrade_scroll":
		# Nucleo Cyber-Upgrade ⚙️ (Esagono Viola/Oro pulsante)
		draw_circle(center, 15.0, Color(0.85, 0.25, 1.0, 0.30))
		var hex := PackedVector2Array()
		for i in range(6):
			var a := i * TAU / 6.0 + anim_t * 1.5
			hex.append(center + Vector2(cos(a), sin(a)) * 10.0)
		draw_colored_polygon(hex, Color(0.18, 0.08, 0.28, 0.96))
		for i in range(6):
			draw_line(hex[i], hex[(i + 1) % 6], Color(1.0, 0.85, 0.2, 0.98), 2.2)
		draw_circle(center, 4.5, Color(0.95, 0.35, 1.0, 1.0))
	elif drop_type == "gear_drop":
		# Capsula Equipaggiamento 3D (Corazza / Anello / Pet / Arma)
		var pulse := 0.65 + 0.35 * sin(anim_t * 6.0)
		draw_circle(center, 22.0, Color(1.0, 0.82, 0.12, 0.28 * pulse))
		draw_arc(center, 18.0, 0.0, TAU, 28, Color(1.0, 0.88, 0.2, 0.95), 2.2)
		var tex := CyberTheme.get_model_texture("res://assets/cyber_models/" + preview_gear_icon + ".png")
		if tex:
			draw_texture_rect(tex, Rect2(center - Vector2(16, 16), Vector2(32, 32)), false)
	else:
		# Cristallo Cyber-XP & Crediti (Ciano/Oro - Magnetico a fine stanza)
		draw_circle(center, 11.0, Color(0.0, 0.94, 1.0, 0.22))
		var pts := PackedVector2Array([
			center + Vector2(0, -8),
			center + Vector2(7, 0),
			center + Vector2(0, 8),
			center + Vector2(-7, 0)
		])
		draw_colored_polygon(pts, Color(0.0, 0.90, 1.0, 0.95))
		draw_circle(center, 3.0, Color(1.0, 0.9, 0.3, 1.0))

func _on_body_entered(body: Node2D) -> void:
	if is_collecting: return
	if body.is_in_group("player"):
		_collect(body)

func magnetize_to_player(player: Node2D) -> void:
	if is_collecting or not is_instance_valid(player): return
	if drop_type == "heal": return # XP, Monete, Nuclei e Drop Equipaggiamento vengono aspirati a fine stanza!

	is_collecting = true
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "global_position", player.global_position, 0.35)
	tw.finished.connect(func():
		if is_instance_valid(player):
			_collect(player)
		else:
			queue_free()
	)

func _collect(body: Node2D) -> void:
	if not is_instance_valid(body):
		queue_free()
		return

	var vfx: Node = get_node_or_null("/root/VFXManager")

	if drop_type == "heal":
		if "current_hp" in body and "max_hp" in body:
			var heal_amt := int(max(25.0, float(body.max_hp) * 0.20))
			body.current_hp = min(body.max_hp, body.current_hp + heal_amt)
			if body.has_signal("hp_changed"): body.hp_changed.emit(body.current_hp, body.max_hp)
			if vfx and vfx.has_method("spawn_floating_text"):
				vfx.spawn_floating_text(global_position, "💚 +" + str(heal_amt) + " HP", Color(0.25, 1.0, 0.55, 1.0))
	elif drop_type == "upgrade_scroll":
		Global.upgrade_scrolls += 1
		if body.has_method("add_exp"):
			body.add_exp(1)
		if vfx and vfx.has_method("spawn_floating_text"):
			vfx.spawn_floating_text(global_position, "⚙️ +1 NUCLEO POTENZIAMENTO!", Color(0.95, 0.45, 1.0, 1.0))
		var ss: Node = get_node_or_null("/root/SaveSystem")
		if ss and ss.has_method("save_game"): ss.save_game()
	elif drop_type == "gear_drop":
		var im: Node = get_node_or_null("/root/InventoryManager")
		var w_idx: int = WorldDB.world_order.find(WorldDB.selected_world_id) + 1
		if w_idx <= 0: w_idx = 1
		if im and im.has_method("roll_random_in_run_gear_drop"):
			var dropped: Dictionary = im.roll_random_in_run_gear_drop(w_idx)
			var d_name: String = str(dropped.get("name", "Equipaggiamento"))
			var d_rar: String = str(dropped.get("rarity", "COMMON"))
			if vfx and vfx.has_method("spawn_floating_text"):
				vfx.spawn_floating_text(global_position, "🎁 DROP: " + d_name.to_upper() + " (" + d_rar + ")!", Color(1.0, 0.88, 0.15, 1.0))
	else:
		if body.has_method("add_exp"):
			body.add_exp(1)
		var world: WorldData = WorldDB.get_selected_world()
		var reward_mult: float = world.reward_multiplier if world else 1.0
		var base_coins: int = int(randf_range(6.0, 11.0) * reward_mult)

		var tm: Node = get_node_or_null("/root/TalentManager")
		var gold_pct: float = tm.get_bonus_value("gold") if (tm and tm.has_method("get_bonus_value")) else 0.0
		var final_coins: int = int(float(base_coins) * (1.0 + (gold_pct / 100.0)))
		Global.total_coins += final_coins

	SoundFX.play_pickup()
	queue_free()
