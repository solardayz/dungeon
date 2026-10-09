extends CharacterBody2D

# ── 스탯 ──────────────────────────────────────────────
@export var max_hp       : int   = 40
@export var move_speed   : float = 70.0
@export var attack_dmg   : int   = 10
@export var attack_range : float = 45.0
@export var attack_cd    : float = 1.5
@export var detect_range : float = 200.0
@export var is_boss      : bool  = false

var hp          : int
var atk_timer   : float = 0.0
var is_dead     : bool  = false
var player_ref  = null

var last_direction = Vector2(1, 0)

var anim_directions = {
	"idle": [
		["side_right_idle",   false],
		["45front_right_idle",false],
		["front_idle",        false],
		["45front_left_idle", false],
		["side_left_idle",    false],
		["45back_left_idle",  false],
		["back_idle",         false],
		["45back_right_idle", false],
	],
	"walk": [
		["side_right_walk",   false],
		["45front_right_walk",false],
		["front_walk",        false],
		["45front_left_walk", false],
		["side_left_walk",    false],
		["45back_left_walk",  false],
		["back_walk",         false],
		["45back_right_walk", false],
	],
}

signal died(enemy)

func _ready():
	hp = max_hp
	add_to_group("enemy")
	# HP바 (간단한 ProgressBar)
	if has_node("HPBar"):
		$HPBar.max_value = max_hp
		$HPBar.value     = hp

func _physics_process(delta):
	if is_dead:
		return
	atk_timer = max(0.0, atk_timer - delta)

	# 플레이어 탐색
	if player_ref == null or not is_instance_valid(player_ref):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_ref = players[0]
		else:
			return

	var dist = global_position.distance_to(player_ref.global_position)

	# ── 공격 ──
	if dist < attack_range:
		velocity = Vector2.ZERO
		_update_animation()
		if atk_timer <= 0:
			atk_timer = attack_cd
			player_ref.take_damage(attack_dmg)
		return

	# ── 추적 ──
	if dist < detect_range:
		var dir = (player_ref.global_position - global_position).normalized()
		dir.y *= 0.5  # 아이소메트릭 보정
		velocity = dir * move_speed
		last_direction = velocity
		move_and_slide()
		_update_animation()
	else:
		velocity = Vector2.ZERO
		_update_animation()

func take_damage(dmg: int):
	if is_dead:
		return
	hp = max(0, hp - dmg)
	if has_node("HPBar"):
		$HPBar.value = hp
	# 피격 이펙트
	$Sprite2D.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid($Sprite2D):
		$Sprite2D.modulate = Color(1, 1, 1)
	if hp <= 0:
		_die()

func _die():
	is_dead = true
	SoundManager.play("enemy_die", randf_range(0.95, 1.1))
	emit_signal("died", self)
	# 사망 깜박임 후 제거
	$Sprite2D.modulate = Color(0.5, 0.5, 0.5, 0.5)
	await get_tree().create_timer(0.4).timeout
	queue_free()

func _update_animation():
	var vel = velocity if velocity.length() > 10 else last_direction
	if vel.length() < 1:
		vel = last_direction
	var anim_set = "walk" if velocity.length() > 10 else "idle"
	var angle    = rad_to_deg(vel.angle()) + 22.5
	var idx      = int(floor(angle / 45.0)) % 8
	if idx < 0:
		idx += 8
	$Sprite2D.play(anim_directions[anim_set][idx][0])
	$Sprite2D.flip_h = anim_directions[anim_set][idx][1]
