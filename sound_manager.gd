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

func play_bgm():
	if bgm_player == null:
		bgm_player = AudioStreamPlayer.new()
		bgm_player.volume_db = -8.0
		add_child(bgm_player)
		bgm_player.finished.connect(_on_bgm_finished)
	if sounds.has("bgm") and sounds["bgm"] != null:
		bgm_player.stream = sounds["bgm"]
		if not bgm_player.playing:
			bgm_player.play()

func _on_bgm_finished():
	if bgm_player and sounds.has("bgm"):
		bgm_player.play()

func stop_bgm():
	if bgm_player and bgm_player.playing:
		bgm_player.stop()

