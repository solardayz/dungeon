extends Node2D

var text: String = ""
var color: Color = Color.WHITE
var font_size: int = 18
var lifetime: float = 0.85
var time: float = 0.0
var font: Font = null

func _ready():
	z_index = 50
	if ResourceLoader.exists("res://fonts/korean.ttf"):
		font = load("res://fonts/korean.ttf")

func setup(t: String, c: Color, f_size: int = 18):
	text = t
	color = c
	font_size = f_size
	queue_redraw()

func _process(delta):
	time += delta
	position.y -= 48.0 * delta
	queue_redraw()
	if time >= lifetime:
		queue_free()

func _draw():
	if font and text != "":
		var alpha = clamp(1.0 - (time / lifetime), 0.0, 1.0)
		var c = Color(color.r, color.g, color.b, alpha)
		var sz = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		# 검은 외곽 그림자
		draw_string(font, Vector2(-sz.x/2.0 + 1, sz.y*0.35 + 1), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0, 0, 0, alpha * 0.8))
		draw_string(font, Vector2(-sz.x/2.0, sz.y*0.35), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, c)
