extends Node2D

# ── 씬 참조 ──────────────────────────────────────────────────────────
@onready var hud     : CanvasLayer = $HUD
@onready var dungeon : Node2D      = $Dungeon

const ENEMY_SCENE  = preload("res://player/enemy.tscn")
const PLAYER_SCENE = preload("res://player/player.tscn")

# 스폰 위치 (dungeon.tscn 월드 좌표 기준)
const SPAWN_POSITIONS = [
	Vector2(500,  150),
	Vector2(900,  80),
	Vector2(750,  320),
	Vector2(300,  480),
	Vector2(1100, 300),
	Vector2(200,   40),
	Vector2(1350, 180),
	Vector2(650,  600),
]
const BOSS_SPAWN = Vector2(700, 200)

var total_enemies  : int  = 8
var boss_spawned   : bool = false
var player_node           = null
var enemy_count    : int  = 0

func _ready():
	# 기존 dungeon.tscn 내의 Goblin 제거 (플레이어와 충돌 방지)
	var existing_goblin = dungeon.get_node_or_null("Walls/Goblin")
	if existing_goblin:
		existing_goblin.queue_free()

	# 기존 카메라 제거 (플레이어 카메라 사용)
	var existing_cam = dungeon.get_node_or_null("Walls/Goblin/Camera2D")
	if existing_cam:
		existing_cam.queue_free()

	# 플레이어 스폰
	player_node = PLAYER_SCENE.instantiate()
	player_node.position = Vector2(273, -2)
	dungeon.add_child(player_node)

	# 플레이어 카메라 활성화 및 화면 확대 (1.85배 줌인)
	var cam = player_node.get_node_or_null("Camera2D")
	if cam:
		cam.enabled = true
		cam.make_current()
		cam.zoom = Vector2(1.85, 1.85)
		cam.position_smoothing_enabled = true
		cam.position_smoothing_speed = 8.0

	# 일반 고블린 스폰 (7마리)
	for i in range(total_enemies - 1):
		_spawn_enemy(SPAWN_POSITIONS[i], false)

	# HUD 연결
	hud.setup(player_node, total_enemies)

	# 스토리 표시
	hud.show_story("dungeon: 고블린들을 처치하고 왕 그롬카르를 무찌르세요!")

func _spawn_enemy(pos: Vector2, boss: bool):
	var e = ENEMY_SCENE.instantiate()
	e.position = pos
	if boss:
		e.max_hp       = 200
		e.attack_dmg   = 20
		e.move_speed   = 90.0
		e.attack_range = 55.0
		e.detect_range = 400.0
		e.is_boss      = true
		e.scale        = Vector2(1.4, 1.4)
		e.modulate     = Color(1.5, 0.4, 0.4, 1)
	dungeon.add_child(e)
	enemy_count += 1
	e.died.connect(_on_enemy_died)

func _on_enemy_died(_enemy):
	enemy_count -= 1
	hud.on_enemy_killed()

	# 모든 일반 적 처치 → 보스 등장
	if enemy_count <= 0 and not boss_spawned:
		boss_spawned = true
		await get_tree().create_timer(1.2).timeout
		# 보스 등장 메시지
		hud.show_boss_warning()
		await get_tree().create_timer(2.0).timeout
		_spawn_enemy(BOSS_SPAWN, true)
		enemy_count += 1
