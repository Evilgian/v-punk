extends Area2D

@export var drop_type: String = "xp_coin" # "xp_coin", "heal", "item"
var is_collecting: bool = false
var anim_t: float = 0.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D

func _ready() -> void:
	add_to_group("drops")
	body_entered.connect(_on_body_entered)
	if sprite:
		sprite.visible = false # Sostituito dal modello vettoriale neon in _draw()
	anim_t = randf() * TAU

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

func _draw() -> void:
	var bob := sin(anim_t * 5.0) * 2.5
	var center := Vector2(0, bob)

	if drop_type == "heal":
		# Medikit Nanobot (Verde/Rosso brillante - Raccolta Manuale)
		draw_circle(center, 13.0, Color(0.1, 1.0, 0.45, 0.25))
		draw_circle(center, 9.0, Color(0.08, 0.22, 0.14, 0.95))
		draw_arc(center, 9.0, 0.0, TAU, 24, Color(0.2, 1.0, 0.5, 0.95), 2.0)
		# Croce medica luminosa
		draw_rect(Rect2(center + Vector2(-2, -5), Vector2(4, 10)), Color(0.3, 1.0, 0.6, 1.0), true)
		draw_rect(Rect2(center + Vector2(-5, -2), Vector2(10, 4)), Color(0.3, 1.0, 0.6, 1.0), true)
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
	if drop_type == "heal" or drop_type == "item": return # Solo XP e Monete sono magnetici!

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

	if drop_type == "heal":
		if "current_hp" in body and "max_hp" in body:
			var heal_amt := int(max(25.0, float(body.max_hp) * 0.20))
			body.current_hp = min(body.max_hp, body.current_hp + heal_amt)
			if body.has_signal("hp_changed"): body.hp_changed.emit(body.current_hp, body.max_hp)
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
