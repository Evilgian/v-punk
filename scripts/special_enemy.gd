extends CharacterBody2D

# ==============================================================================
# ARCHETIPI SPECIALI DI NEMICI (KAMIKAZE, SHIELDER, ASSASSIN, SPITTER)
# - KAMIKAZE ("Ticker Kamikaze Bot"): corre veloce, innesca il nucleo a distanza
#   ravvicinata (0.65s telegrafati a terra) ed esplode ad area (90px).
# - SHIELDER ("Aegis Riot Enforcer"): avanza con scudo energetico frontale che
#   riduce del 65% i proiettili non-perforanti frontali; vulnerabile ai fianchi/spalle!
# - ASSASSIN ("Cyber-Wraith"): scatta lateralmente con blink olografico e lancia
#   doppie lame al plasma veloci.
# - SPITTER ("Bio-Cryo Spitter Turret"): crawler corazzato semi-stazionario che
#   spara raffiche incrociate / mortai elementali rallentanti.
# ==============================================================================

@export var archetype: String = "KAMIKAZE" # KAMIKAZE, SHIELDER, ASSASSIN, SPITTER
@export var speed: float = 120.0
@export var hp: int = 88
var max_hp: int = 88
@export var damage: int = 24
@export var drop_scene: PackedScene = preload("res://scenes/Drop.tscn")
@export var enemy_projectile_scene: PackedScene = preload("res://scenes/EnemyProjectile.tscn")

var player: Node2D = null
var anim_t: float = 0.0
var aim_angle: float = PI * 0.5
var world_id: String = "world_1"
var is_elite: bool = false
var spawn_warmup: float = 0.45

var contact_cd: float = 0.0
var action_timer: float = 0.0
var fuse_timer: float = 0.0
var is_primed: bool = false
var shield_flash: float = 0.0
var dash_timer: float = 0.0
var dash_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("enemies")
	var w: WorldData = WorldDB.get_selected_world()
	if w:
		world_id = w.id
	anim_t = randf() * TAU
	_configure_archetype_base_stats()
	max_hp = hp

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0] as Node2D

func _configure_archetype_base_stats() -> void:
	match archetype:
		"KAMIKAZE":
			hp = maxi(18, int(round(float(hp) * 0.72)))
			speed = maxf(135.0, speed * 1.48)
			damage = int(round(float(damage) * 1.45))
		"SHIELDER":
			hp = int(round(float(hp) * 1.65))
			speed = speed * 0.72
			damage = int(round(float(damage) * 1.15))
		"ASSASSIN":
			hp = int(round(float(hp) * 0.92))
			speed = maxf(125.0, speed * 1.32)
			action_timer = randf_range(0.8, 1.6)
		"SPITTER":
			hp = int(round(float(hp) * 1.30))
			speed = speed * 0.45
			action_timer = randf_range(0.6, 1.4)

func apply_knockback(impulse: Vector2) -> void:
	if archetype == "SHIELDER":
		global_position += impulse * 0.25
	elif archetype == "SPITTER":
		global_position += impulse * 0.15
	else:
		global_position += impulse
	global_position.x = clampf(global_position.x, 60.0, 660.0)
	global_position.y = clampf(global_position.y, 135.0, 1220.0)

func _physics_process(delta: float) -> void:
	anim_t += delta
	if shield_flash > 0.0:
		shield_flash = maxf(0.0, shield_flash - delta * 3.5)
	if contact_cd > 0.0:
		contact_cd -= delta

	if spawn_warmup > 0.0:
		spawn_warmup -= delta
		queue_redraw()
		return

	if not is_instance_valid(player):
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as Node2D
		queue_redraw()
		return

	var to_p: Vector2 = player.global_position - global_position
	var dist: float = to_p.length()
	var dir: Vector2 = to_p / maxf(0.001, dist)

	match archetype:
		"KAMIKAZE":
			aim_angle = dir.angle()
			if is_primed:
				fuse_timer += delta
				velocity = dir * (speed * 0.35)
				move_and_slide()
				if fuse_timer >= 0.65:
					_detonate_kamikaze()
					return
			else:
				velocity = dir * speed
				move_and_slide()
				if dist <= 72.0:
					is_primed = true
					fuse_timer = 0.0
					SoundFX.play_hit()

		"SHIELDER":
			# Lo scudiere ruota lo scudo con inerzia realistica: aggirandolo ai fianchi si colpisce scoperto!
			aim_angle = lerp_angle(aim_angle, dir.angle(), minf(1.0, delta * 3.2))
			velocity = dir * speed
			move_and_slide()
			action_timer += delta
			if dist <= 52.0 and contact_cd <= 0.0:
				if player.has_method("take_damage"):
					player.take_damage(damage)
					contact_cd = 1.0
			elif action_timer >= 2.8 and dist < 300.0:
				action_timer = 0.0
				_fire_proj(Vector2.from_angle(aim_angle), 0.95)

		"ASSASSIN":
			aim_angle = dir.angle()
			if dash_timer > 0.0:
				dash_timer -= delta
				velocity = dash_dir * (speed * 2.35)
				move_and_slide()
			else:
				var perp := Vector2(-dir.y, dir.x) * (1.0 if int(anim_t * 1.2) % 2 == 0 else -1.0)
				var desired := (dir * 0.72 + perp * 0.55).normalized() if dist > 150.0 else (-dir * 0.4 + perp * 0.9).normalized()
				velocity = desired * speed
				move_and_slide()
				action_timer += delta
				if action_timer >= 2.3:
					action_timer = 0.0
					dash_dir = (dir * 0.45 + perp * 0.95).normalized()
					dash_timer = 0.28
					# Lancia 2 lame energetiche gemelle dopo il blink!
					_fire_proj(dir.rotated(-0.10), 1.22)
					_fire_proj(dir.rotated(0.10), 1.22)
			if dist <= 44.0 and contact_cd <= 0.0 and player.has_method("take_damage"):
				player.take_damage(damage)
				contact_cd = 0.9

		"SPITTER":
			aim_angle = dir.angle()
			if dist > 420.0:
				velocity = dir * speed
				move_and_slide()
			else:
				velocity = Vector2.ZERO
			action_timer += delta
			var cd: float = 2.4 if not is_elite else 1.85
			if action_timer >= cd:
				action_timer = 0.0
				for a_off in [-0.22, 0.0, 0.22]:
					_fire_proj(dir.rotated(a_off), 0.88)

	queue_redraw()

func _fire_proj(dir: Vector2, spd_mult: float = 1.0) -> void:
	if not enemy_projectile_scene:
		return
	var proj := enemy_projectile_scene.instantiate() as Area2D
	if proj:
		proj.global_position = global_position + Vector2(0, -14)
		proj.direction = dir
		proj.rotation = dir.angle()
		if "speed" in proj:
			proj.speed = float(proj.speed) * spd_mult
		if "damage" in proj:
			proj.damage = maxi(6, int(round(float(damage) * 0.75)))
		get_tree().current_scene.add_child.call_deferred(proj)

func _detonate_kamikaze() -> void:
	SoundFX.play_explosion()
	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx and vfx.has_method("spawn_explosion"):
		vfx.spawn_explosion(global_position, Color(1.0, 0.32, 0.08, 1.0))
	if is_instance_valid(player) and player.global_position.distance_to(global_position) <= 92.0:
		if player.has_method("take_damage"):
			player.take_damage(damage)
	var col := get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", true)
	queue_free()

func _draw() -> void:
	if spawn_warmup > 0.0:
		CyberModels.draw_spawn_telegraph(self, Vector2(0, 14), 26.0, Color(1.0, 0.35, 0.25), 1.0 - spawn_warmup / 0.45)

	var act_ratio: float = 0.0
	match archetype:
		"KAMIKAZE":
			act_ratio = clampf(fuse_timer / 0.65, 0.0, 1.0) if is_primed else 0.0
		"SHIELDER":
			act_ratio = shield_flash
		"ASSASSIN":
			act_ratio = clampf(dash_timer / 0.28, 0.0, 1.0)
		"SPITTER":
			act_ratio = clampf(1.0 - action_timer * 3.0, 0.0, 1.0) if action_timer < 0.33 else 0.0

	CyberModels.draw_special_enemy(self, archetype, world_id, anim_t, aim_angle, act_ratio, is_elite, velocity)

	if max_hp > 0:
		var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
		var bar_alpha := 0.95 if hp < max_hp else 0.74
		var bar_col := Color(1.0, 0.84, 0.16, bar_alpha) if is_elite else _get_archetype_bar_color(bar_alpha)
		var y_bar: float = -56.0 if archetype == "SHIELDER" else -48.0
		draw_rect(Rect2(Vector2(-20, y_bar), Vector2(40, 6)), Color(0.03, 0.05, 0.10, bar_alpha), true)
		draw_rect(Rect2(Vector2(-19, y_bar + 1), Vector2(38.0 * ratio, 4)), bar_col, true)

func _get_archetype_bar_color(a: float) -> Color:
	match archetype:
		"KAMIKAZE": return Color(1.0, 0.42, 0.10, a)
		"SHIELDER": return Color(0.15, 0.88, 1.0, a)
		"ASSASSIN": return Color(0.88, 0.25, 1.0, a)
		_: return Color(0.25, 0.98, 0.62, a)

func take_damage(amount: int, is_crit: bool = false, hit_from_dir: Vector2 = Vector2.ZERO) -> void:
	if has_meta("last_hit_crit"):
		is_crit = bool(get_meta("last_hit_crit"))
		remove_meta("last_hit_crit")
	if has_meta("last_hit_dir"):
		hit_from_dir = Vector2(get_meta("last_hit_dir"))
		remove_meta("last_hit_dir")

	if max_hp < hp:
		max_hp = hp
	var eff_dmg: int = amount

	# Aegis Riot Enforcer riduce i colpi che arrivano sul fronte dello scudo!
	if archetype == "SHIELDER" and hit_from_dir.length_squared() > 0.01:
		var front_vec := Vector2.from_angle(aim_angle)
		if hit_from_dir.normalized().dot(-front_vec) > 0.35:
			eff_dmg = maxi(1, int(round(float(amount) * 0.38)))
			shield_flash = 1.0

	hp -= eff_dmg
	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx:
		if vfx.has_method("spawn_floating_damage"):
			vfx.spawn_floating_damage(global_position, eff_dmg, is_crit)
		if vfx.has_method("flash_hit"):
			vfx.flash_hit(self)

	queue_redraw()
	if hp <= 0:
		die()

func die() -> void:
	Global.total_coins += 12 if archetype != "SHIELDER" else 18
	Global.quest_kills += 1
	SoundFX.play_explosion()

	var col := get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", true)

	var vfx: Node = get_node_or_null("/root/VFXManager")
	if vfx and vfx.has_method("spawn_burst"):
		vfx.spawn_burst(global_position, _get_archetype_bar_color(1.0))

	if drop_scene:
		var drop := drop_scene.instantiate() as Area2D
		if drop:
			drop.global_position = global_position
			if "drop_type" in drop:
				var r := randf()
				if r < 0.018:
					drop.drop_type = "gear_drop"
				elif r < 0.16:
					drop.drop_type = "upgrade_scroll"
				elif r < 0.24:
					drop.drop_type = "heal"
			get_tree().current_scene.add_child.call_deferred(drop)
	queue_free()
