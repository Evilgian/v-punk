extends Control

signal joystick_vector_changed(vector: Vector2)

@export var max_distance: float = 80.0
@export var dead_zone: float = 0.15
@export var base_color: Color = Color(0.0, 0.85, 1.0, 0.22)
@export var border_color: Color = Color(0.0, 0.94, 1.0, 0.85)
@export var knob_color: Color = Color(0.0, 0.7, 1.0, 0.65)
@export var knob_border_color: Color = Color(0.6, 0.95, 1.0, 0.95)
@export var knob_radius: float = 30.0

var output_vector: Vector2 = Vector2.ZERO
var is_pressed: bool = false
var touch_index: int = -1
var joystick_center: Vector2 = Vector2.ZERO
var knob_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("virtual_joystick")
	mouse_filter = MOUSE_FILTER_PASS

func get_output() -> Vector2:
	return output_vector

func _draw() -> void:
	if not is_pressed: return

	# Draw Holographic Base Circle & Glow Rings
	draw_circle(joystick_center, max_distance, base_color)
	draw_arc(joystick_center, max_distance, 0, TAU, 64, border_color, 3.0)
	draw_arc(joystick_center, max_distance * 0.6, 0, TAU, 32, Color(0, 0.94, 1, 0.3), 1.5)

	# Draw Holographic Knob Circle
	var knob_center := joystick_center + knob_position
	draw_circle(knob_center, knob_radius, knob_color)
	draw_arc(knob_center, knob_radius, 0, TAU, 32, knob_border_color, 2.5)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.y > (get_viewport_rect().size.y * 0.35):
			_start_touch(event.position, event.index)
		elif not event.pressed and event.index == touch_index:
			_end_touch()
	elif event is InputEventScreenDrag and event.index == touch_index:
		_update_touch(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and event.position.y > (get_viewport_rect().size.y * 0.35):
				_start_touch(event.position, -1)
			elif not event.pressed:
				_end_touch()
	elif event is InputEventMouseMotion and is_pressed and touch_index == -1:
		_update_touch(event.position)

func _start_touch(event_pos: Vector2, index: int) -> void:
	is_pressed = true
	touch_index = index
	joystick_center = event_pos
	knob_position = Vector2.ZERO
	output_vector = Vector2.ZERO
	queue_redraw()

func _update_touch(event_pos: Vector2) -> void:
	if not is_pressed: return
	var delta := event_pos - joystick_center
	var dist := delta.length()

	if dist > max_distance:
		delta = delta.normalized() * max_distance

	knob_position = delta

	var raw_output := delta / max_distance
	if raw_output.length() < dead_zone:
		output_vector = Vector2.ZERO
	else:
		output_vector = raw_output

	joystick_vector_changed.emit(output_vector)
	queue_redraw()

func _end_touch() -> void:
	is_pressed = false
	touch_index = -1
	knob_position = Vector2.ZERO
	output_vector = Vector2.ZERO
	joystick_vector_changed.emit(Vector2.ZERO)
	queue_redraw()
