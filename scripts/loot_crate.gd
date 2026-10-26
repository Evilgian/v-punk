extends StaticBody2D

@export var hp: int = 20
var max_hp: int = 20
@export var drop_scene: PackedScene = preload("res://scenes/Drop.tscn")

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
var anim_t: float = 0.0

func _ready() -> void:
	max_hp = hp
	if sprite: sprite.visible = false
	add_to_group("obstacles")
	add_to_group("loot_crates")

func _process(delta: float) -> void:
	anim_t += delta
	queue_redraw()

func _draw() -> void:
	var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
	CyberModels.draw_loot_crate(self, anim_t, ratio)

func take_damage(amount: int) -> void:
	hp -= amount
	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx and vfx.has_method("flash_hit"):
		vfx.flash_hit(self)
	queue_redraw()
	if hp <= 0:
		_destroy_crate()

func _destroy_crate() -> void:
	Global.total_credits += 10
	var col := get_node_or_null("CollisionShape2D")
	if col: col.set_deferred("disabled", true)

	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx and vfx.has_method("spawn_burst"):
		vfx.spawn_burst(global_position, Color(1.0, 0.84, 0.0, 1.0))

	if drop_scene:
		var drop := drop_scene.instantiate() as Node2D
		if drop:
			drop.global_position = global_position
			if "drop_type" in drop:
				var r := randf()
				if r < 0.22:
					drop.drop_type = "gear_drop" # 22% Drop diretto di Equipaggiamento dalle Casse!
				elif r < 0.60:
					drop.drop_type = "upgrade_scroll" # 38% Nucleo Potenziamento ⚙️
				elif r < 0.85:
					drop.drop_type = "heal"
			get_tree().current_scene.add_child.call_deferred(drop)

	queue_free()
