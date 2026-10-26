extends Node

var shoot_sound: AudioStreamWAV
var hit_sound: AudioStreamWAV
var pickup_sound: AudioStreamWAV
var click_sound: AudioStreamWAV
var explosion_sound: AudioStreamWAV
var bgm_player: AudioStreamPlayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_generate_sounds()
	_setup_cyber_bgm()

func _setup_cyber_bgm() -> void:
	var sample_rate := 22050
	var duration := 3.2
	var total_samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(total_samples)
	var notes := [110.0, 110.0, 130.81, 146.83, 110.0, 164.81, 146.83, 130.81]
	var step_samples := int(total_samples / notes.size())

	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var note_idx := min(int(i / step_samples), notes.size() - 1)
		var freq: float = notes[note_idx]
		var local_env := 1.0 - (float(i % step_samples) / float(step_samples)) * 0.65
		var wave := (sin(TAU * freq * t) * 0.6 + sin(TAU * freq * 0.5 * t) * 0.4) * local_env * 0.16
		data[i] = int(clamp((wave + 1.0) * 0.5 * 255.0, 0.0, 255.0))

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_samples
	wav.data = data

	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = wav
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(bgm_player)
	apply_volume_settings()
	bgm_player.play()

func apply_volume_settings() -> void:
	if bgm_player:
		if Global.music_volume <= 0.01:
			bgm_player.volume_db = -80.0
		else:
			bgm_player.volume_db = linear_to_db(Global.music_volume * 0.45)

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
	if not stream or Global.sfx_volume <= 0.01:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = linear_to_db(Global.sfx_volume)
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
