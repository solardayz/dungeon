extends CharacterBody2D

const SPEED        = 160.0
const DASH_SPEED   = 400.0
const DASH_TIME    = 0.18
const ATTACK_RANGE = 80.0
const ATTACK_DMG   = 25
const ATTACK_COOLDOWN = 0.5

var max_hp      = 100
var hp          = 100
var is_dashing  = false
var dash_timer  = 0.0
var dash_dir    = Vector2.ZERO
var atk_cooldown = 0.0
var is_dead     = false
var invincible  = false
var inv_timer   = 0.0
var hud_ref     = null   # HUD 참조 (모바일 입력)

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

var last_direction = Vector2(1, 0)
var state = "idle"

signal died
signal hp_changed(new_hp, max_hp)

func _ready():
	add_to_group("player")

func set_hud(h):
	hud_ref = h

func _physics_process(delta):
	if is_dead:
		return

	if invincible:
		inv_timer -= delta
		if inv_timer <= 0:
			invincible = false

	if atk_cooldown > 0:
		atk_cooldown -= delta

	if is_dashing:
		dash_timer -= delta
		velocity = dash_dir * DASH_SPEED
		move_and_slide()
		if dash_timer <= 0:
			is_dashing = false
		return

	# ── 이동: 키보드 + 모바일 조이스틱 ──
	var motion = Vector2(
		Input.get_action_strength(&"move_right") - Input.get_action_strength(&"move_left"),
		Input.get_action_strength(&"move_down")  - Input.get_action_strength(&"move_up")
	)
	# 모바일 조이스틱
	if hud_ref and motion.length() < 0.1:
		var mob_dir = hud_ref.get_mobile_dir()
		if mob_dir.length() > 0.1:
			motion = mob_dir

	motion.y /= 2.0
	motion    = motion.normalized() * SPEED
	velocity  = motion
	move_and_slide()

	if velocity.length() > 10:
		last_direction = velocity
		state = "walk"
	else:
		if state != "attack":
			state = "idle"

	# ── 대쉬: 키보드 + 모바일 ──
	var want_dash = Input.is_action_just_pressed(&"dash")
	if hud_ref and hud_ref.consume_mobile_dash():
		want_dash = true
	if want_dash and not is_dashing:
		var dir = velocity.normalized() if velocity.length() > 10 else last_direction.normalized()
		is_dashing = true
		dash_timer  = DASH_TIME
		dash_dir    = dir
		invincible  = true
		inv_timer   = DASH_TIME + 0.1
		SoundManager.play("dash", randf_range(0.95, 1.1))

	# ── 공격: 키보드 + 모바일 ──
	var want_atk = Input.is_action_just_pressed(&"attack")
	if hud_ref and hud_ref.consume_mobile_atk():
		want_atk = true
	if want_atk and atk_cooldown <= 0:
		_do_attack()

	_update_animation()

func _do_attack():
	atk_cooldown = ATTACK_COOLDOWN
	state = "attack"
	SoundManager.play("swing", randf_range(0.95, 1.1))
	var enemies = get_tree().get_nodes_in_group("enemy")
	var hit_any = false
	for e in enemies:
		if is_instance_valid(e) and global_position.distance_to(e.global_position) < ATTACK_RANGE:
			e.take_damage(ATTACK_DMG)
			hit_any = true
	if hit_any:
		SoundManager.play("hit", randf_range(0.95, 1.15))
	await get_tree().create_timer(0.3).timeout
	if not is_dead:
		state = "idle"

func take_damage(dmg: int):
	if invincible or is_dead:
		return
	hp = max(0, hp - dmg)
	emit_signal("hp_changed", hp, max_hp)
	invincible = true
	inv_timer  = 0.6
	SoundManager.play("hurt", randf_range(0.95, 1.05))
	$Sprite2D.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid($Sprite2D):
		$Sprite2D.modulate = Color(0.5, 0.8, 1.5)
	if hp <= 0:
		_die()

func _die():
	is_dead = true
	state   = "dead"
	emit_signal("died")

func _update_animation():
	if state == "dead":
		return
	var anim_set  = state if state in anim_directions else "idle"
	var angle     = rad_to_deg(last_direction.angle()) + 22.5
	var slice_dir = int(floor(angle / 45.0)) % 8
	if slice_dir < 0:
		slice_dir += 8
	$Sprite2D.play(anim_directions[anim_set][slice_dir][0])
	$Sprite2D.flip_h = anim_directions[anim_set][slice_dir][1]
