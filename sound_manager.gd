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
	_load_sound("gold", "res://sounds/gold.wav")
	_load_sound("potion", "res://sounds/potion.wav")
	_load_sound("whirlwind", "res://sounds/whirlwind.wav")
	_load_sound("fireball", "res://sounds/fireball.wav")
	_load_sound("bgm", "res://sounds/dungeon_bgm.wav")

var bgm_player: AudioStreamPlayer = null
var is_bgm_playing: bool = false
var bgm_enabled: bool = true

func _input(event):
	if not is_bgm_playing and bgm_enabled:
		if (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
			play_bgm()

func _load_sound(s_name: String, path: String):
	if ResourceLoader.exists(path):
		var res = load(path)
		if s_name == "bgm" and res is AudioStreamWAV:
			res.loop_mode = AudioStreamWAV.LOOP_FORWARD
		sounds[s_name] = res

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

func play_bgm():
	if not bgm_enabled:
		return
	if bgm_player == null:
		bgm_player = AudioStreamPlayer.new()
		bgm_player.volume_db = 1.0
		add_child(bgm_player)
		bgm_player.finished.connect(_on_bgm_finished)
	if sounds.has("bgm") and sounds["bgm"] != null:
		bgm_player.stream = sounds["bgm"]
		if not bgm_player.playing:
			bgm_player.play()
			is_bgm_playing = true

func _on_bgm_finished():
	if bgm_player and sounds.has("bgm") and bgm_enabled:
		bgm_player.play()

func stop_bgm():
	is_bgm_playing = false
	if bgm_player and bgm_player.playing:
		bgm_player.stop()

func toggle_bgm() -> bool:
	bgm_enabled = not bgm_enabled
	if bgm_enabled:
		play_bgm()
	else:
		stop_bgm()
	return bgm_enabled


