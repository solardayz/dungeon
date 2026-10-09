extends Node2D

## 가상 조이스틱 - 터치 및 마우스 입력 지원
signal direction_changed(dir: Vector2)

const RADIUS: float = 85.0
const KNOB_RADIUS: float = 38.0

var touch_index: int = -1
var knob_offset: Vector2 = Vector2.ZERO
var active: bool = false

func _draw():
	# 외부 배경 원
	draw_circle(Vector2.ZERO, RADIUS, Color(0.08, 0.1, 0.15, 0.55))
	# 외부 테두리
	draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 64, Color(1, 1, 1, 0.65), 4.0)
	# 십자 가이드라인
	draw_line(Vector2(-RADIUS * 0.65, 0), Vector2(RADIUS * 0.65, 0), Color(1, 1, 1, 0.25), 2.0)
	draw_line(Vector2(0, -RADIUS * 0.65), Vector2(0, RADIUS * 0.65), Color(1, 1, 1, 0.25), 2.0)

	# 내부 노브
	var knob_col = Color(0.3, 0.8, 1.0, 0.85) if active else Color(0.9, 0.9, 1.0, 0.65)
	draw_circle(knob_offset, KNOB_RADIUS + 2.0, Color(0, 0, 0, 0.35))
	draw_circle(knob_offset, KNOB_RADIUS, knob_col)
	draw_arc(knob_offset, KNOB_RADIUS, 0, TAU, 36, Color(1, 1, 1, 0.9), 3.0)

func _input(event):
	if event is InputEventScreenTouch:
		var local = to_local(event.position)
		if event.pressed:
			if local.length() <= RADIUS * 1.5 and touch_index == -1:
				touch_index = event.index
				active = true
				_update_knob(local)
		else:
			if event.index == touch_index:
				_reset_joystick()

	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			_update_knob(to_local(event.position))

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var local = to_local(event.position)
			if event.pressed:
				if local.length() <= RADIUS * 1.5 and touch_index == -1:
					touch_index = 888
					active = true
					_update_knob(local)
			else:
				if touch_index == 888:
					_reset_joystick()

	elif event is InputEventMouseMotion:
		if touch_index == 888:
			_update_knob(to_local(event.position))

func _update_knob(local: Vector2):
	knob_offset = local.limit_length(RADIUS)
	var dir = knob_offset / RADIUS
	dir.y *= 2.0  # 아이소메트릭 보정
	emit_signal("direction_changed", dir)
	queue_redraw()

func _reset_joystick():
	touch_index = -1
	active = false
	knob_offset = Vector2.ZERO
	emit_signal("direction_changed", Vector2.ZERO)
	queue_redraw()
