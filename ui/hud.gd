extends CanvasLayer

@onready var hp_bar       : ProgressBar    = $HUD/TopLeft/HPRow/HPBar
@onready var hp_label     : Label          = $HUD/TopLeft/HPRow/HPLabel
@onready var kill_label   : Label          = $HUD/TopLeft/KillLabel
@onready var story_panel  : Control        = $StoryBanner
@onready var story_text   : Label          = $StoryBanner/Margin/HBox/StoryText
@onready var story_btn    : Button         = $StoryBanner/Margin/HBox/OKButton
@onready var result_panel : Panel          = $ResultPanel
@onready var result_label : Label          = $ResultPanel/Margin/VBox/ResultLabel
@onready var result_sub   : Label          = $ResultPanel/Margin/VBox/SubLabel
@onready var result_btn   : Button         = $ResultPanel/Margin/VBox/RestartBtn
@onready var attack_hint  : Label          = $HUD/TopRight/AttackHint
@onready var boss_label   : Label          = $HUD/BossWarning
@onready var joystick     : Node2D         = $MobileControls/Joystick
@onready var atk_btn      : Node2D         = $MobileControls/AttackBtn
@onready var dash_btn     : Node2D         = $MobileControls/DashBtn

var kills  : int = 0
var total  : int = 0
var player      = null

var mobile_dir   : Vector2 = Vector2.ZERO
var mobile_atk   : bool    = false
var mobile_dash  : bool    = false

func _ready():
	story_btn.pressed.connect(_on_story_ok)
	result_btn.pressed.connect(_on_restart)
	result_panel.hide()
	boss_label.hide()
	joystick.direction_changed.connect(_on_joystick_changed)
	atk_btn.pressed.connect(_on_atk_pressed)
	dash_btn.pressed.connect(_on_dash_pressed)
	get_viewport().size_changed.connect(_layout_mobile)
	call_deferred(&"_layout_mobile")

func _layout_mobile():
	var vp = get_viewport().get_visible_rect().size
	joystick.position = Vector2(160, vp.y - 160)
	atk_btn.position  = Vector2(vp.x - 140, vp.y - 140)
	dash_btn.position = Vector2(vp.x - 310, vp.y - 120)

func setup(p, t: int):
	player = p
	total  = t
	kills  = 0
	_update_kill_label()
	if is_instance_valid(player):
		player.hp_changed.connect(_on_hp_changed)
		player.died.connect(_on_player_died)
		player.set_hud(self)
	_update_hp(player.hp, player.max_hp)

func _on_hp_changed(new_hp, max_hp):
	_update_hp(new_hp, max_hp)

func _update_hp(new_hp, max_hp):
	hp_bar.max_value = max_hp
	hp_bar.value     = new_hp
	hp_label.text    = "%d/%d" % [new_hp, max_hp]

func on_enemy_killed():
	kills += 1
	_update_kill_label()
	if kills >= total:
		await get_tree().create_timer(0.8).timeout
		show_result(true)

func _update_kill_label():
	kill_label.text = "처치: %d / %d" % [kills, total]

func _on_player_died():
	await get_tree().create_timer(0.5).timeout
	show_result(false)

func show_result(victory: bool):
	result_panel.show()
	if victory:
		SoundManager.play("victory", 1.0, 2.0)
		result_label.text = "승리!"
		result_sub.text   = "고블린 왕 그롬카르를 처치했습니다!\n왕국에 평화가 찾아왔습니다."
		result_label.add_theme_color_override("font_color", Color(1, 0.85, 0))
	else:
		SoundManager.play("defeat", 1.0, 2.0)
		result_label.text = "패배..."
		result_sub.text   = "기사가 쓰러졌습니다.\n다시 도전하세요!"
		result_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_story_ok():
	SoundManager.play("click")
	story_panel.hide()

func _on_restart():
	SoundManager.play("click")
	get_tree().reload_current_scene()

func show_story(text_str: String):
	story_text.text = text_str
	story_panel.show()

func show_boss_warning():
	boss_label.show()
	boss_label.text = "고블린 왕 그롬카르가 나타났다!"
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(boss_label):
		boss_label.hide()

# ── 모바일 입력 ──
func _on_joystick_changed(dir: Vector2):
	mobile_dir = dir

func _on_atk_pressed():
	mobile_atk = true

func _on_dash_pressed():
	mobile_dash = true

func get_mobile_dir() -> Vector2:
	return mobile_dir

func consume_mobile_atk() -> bool:
	if mobile_atk:
		mobile_atk = false
		return true
	return false

func consume_mobile_dash() -> bool:
	if mobile_dash:
		mobile_dash = false
		return true
	return false
