extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 520.0
var damage: int = 35
var aoe_radius: float = 65.0
var max_dist: float = 480.0
var traveled: float = 0.0
var exploded: bool = false
var time: float = 0.0

func setup(dir: Vector2, pos: Vector2):
	direction = dir.normalized()
	global_position = pos
	z_index = 20

func _process(delta):
	if exploded:
		return

	time += delta
	var move_vec = direction * speed * delta
	global_position += move_vec
	traveled += move_vec.length()
	queue_redraw()

	# 적 충돌 검사
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if is_instance_valid(e) and not e.is_dead:
			if global_position.distance_to(e.global_position) < 32.0:
				_explode()
				return

	if traveled >= max_dist:
		_explode()

func _explode():
	exploded = true
	SoundManager.play("hit", 0.8, 2.0)
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if is_instance_valid(e) and not e.is_dead:
			if global_position.distance_to(e.global_position) <= aoe_radius:
				e.take_damage(damage)

	# 폭발 이펙트 (반짝임 후 제거)
	queue_redraw()
	await get_tree().create_timer(0.12).timeout
	queue_free()

func _draw():
	if not exploded:
		# 불꽃 아우라
		draw_circle(Vector2.ZERO, 15.0 + sin(time * 20.0) * 2.0, Color(1, 0.35, 0.1, 0.35))
		# 화염 코어
		draw_circle(Vector2.ZERO, 9.0, Color(1, 0.65, 0.1, 0.95))
		# 하이라이트 백색 중심
		draw_circle(Vector2.ZERO, 4.5, Color(1, 0.95, 0.7, 1.0))
		# 뒤쪽 화염 꼬리
		draw_circle(-direction * 8.0, 6.0, Color(1, 0.3, 0.05, 0.6))
		draw_circle(-direction * 14.0, 3.5, Color(0.9, 0.2, 0.0, 0.4))
	else:
		# 폭발 섬광
		draw_circle(Vector2.ZERO, aoe_radius, Color(1, 0.45, 0.1, 0.45))
		draw_circle(Vector2.ZERO, aoe_radius * 0.6, Color(1, 0.8, 0.2, 0.75))
		draw_circle(Vector2.ZERO, aoe_radius * 0.3, Color(1, 1, 0.8, 0.9))
