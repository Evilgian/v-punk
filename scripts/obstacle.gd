extends StaticBody2D

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var shadow: Sprite2D = get_node_or_null("Shadow") as Sprite2D

var accent_col: Color = Color(0.0, 0.94, 1.0, 1.0)
var world_id: String = "world_1"

func _ready() -> void:
	add_to_group("obstacles")
	if sprite: sprite.visible = false
	if shadow: shadow.visible = false
	var w: WorldData = WorldDB.get_selected_world()
	if w:
		accent_col = w.accent_color
		world_id = w.id
	queue_redraw()

func _draw() -> void:
	CyberModels.draw_obstacle(self, accent_col, world_id)
