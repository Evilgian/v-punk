extends Node

var shoot_sound: AudioStreamWAV
var hit_sound: AudioStreamWAV
var pickup_sound: AudioStreamWAV
var click_sound: AudioStreamWAV
var explosion_sound: AudioStreamWAV

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_generate_sounds()

func _create_synth_sample(freq: float, duration: float, type: String = "sine") -> AudioStreamWAV:
	var sample_rate := 44100
	var total_samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(total_samples)

	for i in range(total_samples):
		var t := float(i) / sample_rate
		var val := 0.0
		var envelope := 1.0 - (float(i) / total_samples)

		match type:
			"sine":
				val = sin(2.0 * PI * freq * t) * envelope
			"square":
				val = (1.0 if sin(2.0 * PI * freq * t) > 0.0 else -1.0) * envelope
			"noise":
				val = (randf() * 2.0 - 1.0) * envelope
			"sweep":
				var f := freq * (1.0 - t / duration)
				val = sin(2.0 * PI * f * t) * envelope

		var byte_val := int(clamp((val + 1.0) * 0.5 * 255.0, 0.0, 255.0))
		data[i] = byte_val

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func _generate_sounds() -> void:
	shoot_sound = _create_synth_sample(440.0, 0.08, "sweep")
	hit_sound = _create_synth_sample(150.0, 0.06, "square")
	pickup_sound = _create_synth_sample(880.0, 0.12, "sine")
	click_sound = _create_synth_sample(600.0, 0.03, "sine")
	explosion_sound = _create_synth_sample(80.0, 0.25, "noise")

func _play(stream: AudioStream) -> void:
	if not stream:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_shoot() -> void:
	_play(shoot_sound)

func play_hit() -> void:
	_play(hit_sound)

func play_pickup() -> void:
	_play(pickup_sound)

func play_click() -> void:
	_play(click_sound)

func play_explosion() -> void:
	_play(explosion_sound)

func play_levelup() -> void:
	_play(pickup_sound)

func play_win() -> void:
	_play(pickup_sound)

func play_gameover() -> void:
	_play(explosion_sound)
