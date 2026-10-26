extends Node2D

var pulse_time: float = 0.0

func _ready() -> void:
	# Safety cleanup timer in case parent is freed unexpectedly
	get_tree().create_timer(2.0).timeout.connect(func():
		if is_instance_valid(self):
			queue_free()
	)

func _process(delta: float) -> void:
	pulse_time += delta
	queue_redraw()

func _draw() -> void:
	var alpha := 0.35 + sin(pulse_time * 15.0) * 0.15
	# Zone d'impatto rossa trasparente (AreaIndicator) raggio 38px
	draw_circle(Vector2.ZERO, 38.0, Color(1.0, 0.1, 0.1, alpha))
	draw_arc(Vector2.ZERO, 38.0, 0, TAU, 32, Color(1.0, 0.3, 0.3, 0.9), 2.5)
	draw_line(Vector2(-12, 0), Vector2(12, 0), Color(1.0, 0.3, 0.3, 0.9), 2.0)
	draw_line(Vector2(0, -12), Vector2(0, 12), Color(1.0, 0.3, 0.3, 0.9), 2.0)
