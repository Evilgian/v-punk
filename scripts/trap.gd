extends Area2D

@export var trap_type: String = "SPIKES" # SPIKES, SANDPIT, LASER, CRYO, MAGMA, ACID, TESLA, VOID
@export var damage: float = 10.0

enum TrapState { IDLE, WARNING, ACTIVE }
var current_state: TrapState = TrapState.IDLE
var state_timer: float = 0.0
var anim_t: float = 0.0

@onready var color_rect: ColorRect = $ColorRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("traps")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if color_rect:
		color_rect.visible = false # Usiamo il rendering procedurale cyber ad alta definizione in _draw()
	queue_redraw()

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

	if trap_type == "SANDPIT":
		return

	state_timer += delta

	match current_state:
		TrapState.IDLE:
			if state_timer >= 1.8:
				state_timer = 0.0
				current_state = TrapState.WARNING
				_apply_warning_visuals()

		TrapState.WARNING:
			# Fase di preavviso di 0.5 sec prima del danno
			if state_timer >= 0.5:
				state_timer = 0.0
				current_state = TrapState.ACTIVE
				_apply_active_visuals()

		TrapState.ACTIVE:
			if state_timer >= 1.0:
				state_timer = 0.0
				current_state = TrapState.IDLE

func _draw() -> void:
	var rect := Rect2(Vector2(-34, -34), Vector2(68, 68))
	var is_warn := (current_state == TrapState.WARNING)
	var is_act := (current_state == TrapState.ACTIVE)
	var flash: bool = (int(state_timer * 14.0) % 2 == 0)

	if trap_type == "SANDPIT":
		# Turbina Gravitazionale Rallentante a Pavimento
		var t_idle := CyberTheme.get_model_texture("res://assets/cyber_models/trap_idle.png")
		if t_idle:
			draw_texture_rect(t_idle, rect, false, Color(1.0, 0.85, 0.4, 0.85))
		draw_circle(Vector2.ZERO, 28.0, Color(0.85, 0.60, 0.12, 0.28))
		for i in range(3):
			var r := 9.0 + i * 7.5
			var a := anim_t * (3.0 - i * 0.6)
			draw_arc(Vector2.ZERO, r, a, a + PI * 1.3, 20, Color(1.0, 0.82, 0.25, 0.85), 2.5)
		return

	if is_warn:
		# Fase di Preavviso: Botola meccanica che si illumina + Triangolo ⚠️ Lampeggiante + Anello Timer
		var t_warn := CyberTheme.get_model_texture("res://assets/cyber_models/trap_warn.png")
		if t_warn:
			draw_texture_rect(t_warn, rect, false, Color(1.0, 1.0, 1.0, 1.0 if flash else 0.72))
		var prog := clampf(state_timer / 0.5, 0.0, 1.0)
		draw_arc(Vector2.ZERO, 36.0, -PI * 0.5, -PI * 0.5 + TAU * prog, 28, Color(1.0, 0.78, 0.05, 0.95), 3.0)
	elif is_act:
		# Fase Attiva: Spuntoni 3D al Plasma / Griglia Laser / Bobina Tesla eruttano dalla botola!
		var act_col := _get_active_color()
		var t_act := CyberTheme.get_model_texture("res://assets/cyber_models/trap_spikes.png")
		if t_act:
			draw_texture_rect(t_act, rect, false, act_col.lightened(0.45))

		# Effetti energetici specifici per tipo di trappola sopra la botola 3D
		match trap_type:
			"LASER":
				for offset in [-14.0, 0.0, 14.0]:
					draw_line(Vector2(-30, offset), Vector2(30, offset), Color(0.0, 0.98, 1.0, 0.95), 3.2)
					draw_line(Vector2(offset, -30), Vector2(offset, 30), Color(0.0, 0.98, 1.0, 0.95), 3.2)
					draw_line(Vector2(-30, offset), Vector2(30, offset), Color.WHITE, 1.2)
			"TESLA":
				draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.95, 0.3, 0.95))
				for k in range(4):
					var ang := anim_t * 18.0 + k * (TAU / 4.0)
					var mid := Vector2.RIGHT.rotated(ang + 0.3) * 15.0
					var tip := Vector2.RIGHT.rotated(ang) * 30.0
					draw_line(Vector2.ZERO, mid, Color(0.6, 0.95, 1.0, 1.0), 2.5)
					draw_line(mid, tip, Color.WHITE, 2.0)
			"ACID", "MAGMA", "CRYO", "VOID":
				draw_arc(Vector2.ZERO, 24.0 + sin(anim_t * 20.0) * 3.0, 0, TAU, 24, act_col, 3.0)
		draw_arc(Vector2.ZERO, 36.0, 0, TAU, 24, act_col, 2.5)
	else:
		# Stato IDLE (Sicuro / Calpestabile): Griglia metallica chiusa a pavimento
		var t_idle := CyberTheme.get_model_texture("res://assets/cyber_models/trap_idle.png")
		if t_idle:
			draw_texture_rect(t_idle, rect, false, Color(0.85, 0.92, 1.0, 0.88))
		var idle_prog := clampf(state_timer / 1.8, 0.0, 1.0)
		draw_arc(Vector2.ZERO, 33.0, -PI * 0.5, -PI * 0.5 + TAU * idle_prog, 24, Color(0.0, 0.94, 1.0, 0.25), 1.5)

func _get_active_color() -> Color:
	match trap_type:
		"LASER": return Color(0.0, 0.95, 1.0, 0.95)
		"CRYO": return Color(0.4, 0.85, 1.0, 0.95)
		"MAGMA": return Color(1.0, 0.35, 0.05, 0.95)
		"ACID": return Color(0.55, 1.0, 0.1, 0.95)
		"TESLA": return Color(1.0, 0.9, 0.2, 0.95)
		"VOID": return Color(0.95, 0.15, 0.85, 0.95)
		_: return Color(1.0, 0.12, 0.18, 0.95)

func _apply_warning_visuals() -> void:
	SoundFX.play_hit()

func _apply_active_visuals() -> void:
	_check_damage_bodies()

func _check_damage_bodies() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			if (trap_type == "CRYO" or trap_type == "VOID") and "speed_modifier" in body:
				body.speed_modifier = 0.65
			if body.has_method("take_damage"):
				body.take_damage(int(damage))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if trap_type == "SANDPIT" and "speed_modifier" in body:
			body.speed_modifier = 0.6
		elif current_state == TrapState.ACTIVE:
			if (trap_type == "CRYO" or trap_type == "VOID") and "speed_modifier" in body:
				body.speed_modifier = 0.65
			if body.has_method("take_damage"):
				body.take_damage(int(damage))

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if "speed_modifier" in body:
			body.speed_modifier = 1.0
