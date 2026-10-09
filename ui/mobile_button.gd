extends Node2D

signal pressed
signal released

@export var radius: float = 58.0
@export var base_color: Color = Color(0.9, 0.25, 0.2, 0.75)
@export var pressed_color: Color = Color(1.0, 0.55, 0.45, 0.95)
@export var border_color: Color = Color(1.0, 1.0, 1.0, 0.85)
@export var text: String = "공격"
@export var action_name: StringName = &"attack"
@export var font_size: int = 22

var font: Font = null
var is_pressed: bool = false
var touch_id: int = -1

func _ready():
	if ResourceLoader.exists("res://fonts/korean.ttf"):
		font = load("res://fonts/korean.ttf")

func _draw():
	# 그림자 / 외부 링
	draw_circle(Vector2.ZERO, radius + 3.0, Color(0, 0, 0, 0.35))
	# 버튼 채우기
	var fill = pressed_color if is_pressed else base_color
	draw_circle(Vector2.ZERO, radius, fill)
	# 외곽선
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, border_color, 4.0)

	# 텍스트
	if font:
		var txt_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var txt_pos = Vector2(-txt_size.x / 2.0, txt_size.y * 0.35)
		draw_string(font, txt_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(1, 1, 1, 1))

func _input(event):
	if event is InputEventScreenTouch:
		var local = to_local(event.position)
		if event.pressed:
			if local.length() <= radius * 1.3 and touch_id == -1:
				touch_id = event.index
				_set_state(true)
		else:
			if event.index == touch_id:
				touch_id = -1
				_set_state(false)

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var local = to_local(event.position)
			if event.pressed:
				if local.length() <= radius * 1.3 and touch_id == -1:
					touch_id = 999
					_set_state(true)
			else:
				if touch_id == 999:
					touch_id = -1
					_set_state(false)

func _set_state(pressed_state: bool):
	if is_pressed == pressed_state:
		return
	is_pressed = pressed_state
	queue_redraw()
	if is_pressed:
		Input.action_press(action_name)
		emit_signal("pressed")
	else:
		Input.action_release(action_name)
		emit_signal("released")
