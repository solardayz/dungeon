extends Node

var sounds: Dictionary = {}

func _ready():
	_load_sound("swing", "res://sounds/swing.wav")
	_load_sound("hit", "res://sounds/hit.wav")
	_load_sound("dash", "res://sounds/dash.wav")
	_load_sound("hurt", "res://sounds/hurt.wav")
	_load_sound("enemy_die", "res://sounds/enemy_die.wav")
	_load_sound("boss_spawn", "res://sounds/boss_spawn.wav")
	_load_sound("victory", "res://sounds/victory.wav")
	_load_sound("defeat", "res://sounds/defeat.wav")
	_load_sound("click", "res://sounds/click.wav")

func _load_sound(s_name: String, path: String):
	if ResourceLoader.exists(path):
		sounds[s_name] = load(path)

func play(s_name: String, pitch: float = 1.0, vol_db: float = 0.0):
	if not sounds.has(s_name) or sounds[s_name] == null:
		return
	var asp = AudioStreamPlayer.new()
	asp.stream = sounds[s_name]
	asp.pitch_scale = pitch
	asp.volume_db = vol_db
	add_child(asp)
	asp.finished.connect(asp.queue_free)
	asp.play()
