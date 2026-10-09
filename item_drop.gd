extends Node2D

var item_type: String = "gold" # "gold" or "potion"
var amount: int = 15
var time: float = 0.0
var picked_up: bool = false
var FloatingTextClass = preload("res://ui/floating_text.gd")

func setup(p_type: String, p_amount: int):
	item_type = p_type
	amount = p_amount
	z_index = 5

func _ready():
	z_index = 5

func _process(delta):
	time += delta
	queue_redraw()

	if picked_up:
		return

	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		if global_position.distance_to(player.global_position) < 46.0:
			_collect(player)

func _collect(player):
	picked_up = true
	var ft = FloatingTextClass.new()
	ft.global_position = global_position + Vector2(0, -25)

	if item_type == "gold":
		if player.has_method("add_gold"):
			player.add_gold(amount)
		SoundManager.play("gold", randf_range(0.95, 1.15))
		ft.setup("+%d 골드" % amount, Color(1, 0.88, 0.2), 18)
	elif item_type == "potion":
		if player.has_method("heal"):
			player.heal(amount)
		SoundManager.play("potion", randf_range(0.95, 1.1))
		ft.setup("+%d HP" % amount, Color(0.2, 1.0, 0.4), 18)

	get_parent().add_child(ft)
	queue_free()

func _draw():
	var offset_y = sin(time * 5.0) * 4.0
	var pos = Vector2(0, -12 + offset_y)

	# 바닥 그림자
	draw_ellipse(Vector2(0, 0), 10.0, 4.0, Color(0, 0, 0, 0.35))

	if item_type == "gold":
		# 금화 광채
		draw_circle(pos, 13.0, Color(1, 0.85, 0.1, 0.25))
		# 금화 외곽
		draw_circle(pos, 8.5, Color(1, 0.78, 0.05))
		# 금화 내부 링
		draw_arc(pos, 6.0, 0, TAU, 16, Color(0.85, 0.55, 0.0), 1.5)
		# 반짝임 하이라이트
		draw_circle(pos + Vector2(-2, -2), 2.0, Color(1, 1, 1, 0.75))
	elif item_type == "potion":
		# 빨간 포션 광채
		draw_circle(pos, 14.0, Color(1, 0.2, 0.3, 0.25))
		# 물약 유리병 바닥
		draw_circle(pos + Vector2(0, 3), 7.5, Color(0.9, 0.1, 0.25, 0.9))
		# 병 목
		draw_rect(Rect2(-2.5, pos.y - 7, 5, 6), Color(0.8, 0.15, 0.25, 0.9))
		# 코르크 마개
		draw_rect(Rect2(-3.5, pos.y - 10, 7, 3), Color(0.72, 0.5, 0.3, 1.0))
		# 광택 하이라이트
		draw_circle(pos + Vector2(-2.5, 1), 2.2, Color(1, 1, 1, 0.8))

func draw_ellipse(center: Vector2, rx: float, ry: float, col: Color):
	var pts = PackedVector2Array()
	var num = 24
	for i in range(num):
		var ang = (TAU / num) * i
		pts.append(center + Vector2(cos(ang) * rx, sin(ang) * ry))
	draw_colored_polygon(pts, col)
