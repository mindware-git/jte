class_name Actor
extends CharacterBody2D

# ═══════════════════════════════════════════════════════════════════════════════
# Actor - 통합 캐릭터 클래스
# Player, NPC, Enemy 모두 이 클래스를 사용
# 타일 기반 이동, 방향 애니메이션, 역할별 동작 처리
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# Enums
# ═══════════════════════════════════════════════════════════════════════════════

## 역할
enum Role {
	NONE,     ## 역할 없음
	PLAYER,   ## 플레이어 (사용자 입력 제어)
	NPC,      ## NPC (대화, 상호작용)
	ENEMY     ## 적 (전투 AI)
}

## 상태
enum State {
	IDLE,      ## 대기
	MOVING,    ## 이동 중
	TALKING,   ## 대화 중
	IN_BATTLE  ## 전투 중
}

## 방향
enum Direction {
	DOWN,   ## 아래 (0)
	LEFT,   ## 왼쪽 (1)
	RIGHT,  ## 오른쪽 (2)
	UP      ## 위 (3)
}

# ═══════════════════════════════════════════════════════════════════════════════
# Signals
# ═══════════════════════════════════════════════════════════════════════════════

signal clicked(actor: Actor)
signal movement_finished()
signal hp_changed(current: int, max_hp: int)
signal mp_changed(current: int, max_mp: int)
signal died(actor: Actor)

# ═══════════════════════════════════════════════════════════════════════════════
# Constants
# ═══════════════════════════════════════════════════════════════════════════════

const TILE_SIZE := 16          ## 타일 크기 (픽셀)
const MOVE_SPEED := 100.0      ## 이동 속도 (픽셀/초)
const SPRITE_SIZE := Vector2i(64, 128)  ## 스프라이트 크기

# ═══════════════════════════════════════════════════════════════════════════════
# Data
# ═══════════════════════════════════════════════════════════════════════════════

## 캐릭터 데이터
var _data: CharacterData = null

## 역할
var _role: Role = Role.NONE

## 상태
var _state: State = State.IDLE

## 방향
var _direction: Direction = Direction.DOWN

# ═══════════════════════════════════════════════════════════════════════════════
# Movement (Tile-based)
# ═══════════════════════════════════════════════════════════════════════════════

## 현재 타일 좌표
var _current_tile: Vector2i = Vector2i(0, 0)

## 목표 타일 좌표
var _target_tile: Vector2i = Vector2i(0, 0)

## 이동 중 여부
var _is_moving: bool = false

## 목표 월드 위치
var _target_position: Vector2 = Vector2.ZERO

# ═══════════════════════════════════════════════════════════════════════════════
# Components
# ═══════════════════════════════════════════════════════════════════════════════

## 스프라이트 (tscn에 있음)
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## 충돌 모양 (tscn에 있음)
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

## 클릭 영역
var _click_area: Area2D = null

## 이름표
var _name_label: Label = null

# ═══════════════════════════════════════════════════════════════════════════════
# Battle Data (전투 시에만 사용)
# ═══════════════════════════════════════════════════════════════════════════════

var _battle_unit: BattleData.Unit = null
var _hp_bar: ProgressBar = null
var _mp_bar: ProgressBar = null
var _hp_label: Label = null
var _is_dead: bool = false

# ═══════════════════════════════════════════════════════════════════════════════
# Properties
# ═══════════════════════════════════════════════════════════════════════════════

var character_data: CharacterData:
	get: return _data

var display_name: String:
	get: return _data.display_name if _data else ""

var current_role: Role:
	get: return _role

var current_state: State:
	get: return _state

var current_tile: Vector2i:
	get: return _current_tile

var is_moving: bool:
	get: return _is_moving

# 전투용 프로퍼티
var current_hp: int:
	get: return _battle_unit.hp if _battle_unit else 0

var max_hp: int:
	get: return _battle_unit.max_hp if _battle_unit else 0

var current_mp: int:
	get: return _battle_unit.mp if _battle_unit else 0

var max_mp: int:
	get: return _battle_unit.max_mp if _battle_unit else 0

var is_dead: bool:
	get: return _is_dead

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_setup_collision_shape()
	_setup_click_area()
	_setup_name_label()


func _setup_collision_shape() -> void:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(64, 64)
		collision.shape = shape


func _physics_process(delta: float) -> void:
	if _is_moving:
		_process_movement(delta)


# ═══════════════════════════════════════════════════════════════════════════════
# Initialization
# ═══════════════════════════════════════════════════════════════════════════════

## Actor 초기화
func init(data: CharacterData, role: Role = Role.PLAYER) -> void:
	_data = data
	_role = role
	
	# 플레이어일 때만 카메라 추가
	if _role == Role.PLAYER:
		var camera := Camera2D.new()
		camera.enabled = true
		add_child(camera)
	
	_setup_sprite()
	_update_name_label()
	_update_animation()


## 전투용 초기화
func init_battle(battle_unit: BattleData.Unit) -> void:
	_battle_unit = battle_unit
	_state = State.IN_BATTLE
	_setup_battle_ui()


# ═══════════════════════════════════════════════════════════════════════════════
# Setup Methods
# ═══════════════════════════════════════════════════════════════════════════════

func _setup_sprite() -> void:
	var animated_sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if not animated_sprite:
		return
	
	# SpriteFrames 로드
	if _data and _data.id != "":
		var frames_path := "res://asset/sprite/characters/%s.tres" % _data.id
		if ResourceLoader.exists(frames_path):
			animated_sprite.sprite_frames = load(frames_path)
		else:
			# 기본 프레임 로드
			var default_path := "res://asset/sprite/sprite_frames.tres"
			if ResourceLoader.exists(default_path):
				animated_sprite.sprite_frames = load(default_path)
	
	@warning_ignore("integer_division")
	animated_sprite.offset = Vector2(0, -SPRITE_SIZE.y / 2)


func _setup_click_area() -> void:
	_click_area = Area2D.new()
	@warning_ignore("integer_division")
	_click_area.position = Vector2(0, -TILE_SIZE / 2)
	
	var shape := RectangleShape2D.new()
	shape.size = Vector2(TILE_SIZE, TILE_SIZE)
	
	var collision := CollisionShape2D.new()
	collision.shape = shape
	_click_area.add_child(collision)
	
	_click_area.input_event.connect(_on_click_area_input)
	add_child(_click_area)
	
	print("Actor click_area 설정 완료: ", name, " position: ", _click_area.position, " size: ", shape.size)


func _setup_name_label() -> void:
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	@warning_ignore("integer_division")
	_name_label.position = Vector2(-SPRITE_SIZE.x / 2, -SPRITE_SIZE.y - 20)
	_name_label.size = Vector2(SPRITE_SIZE.x, 20)
	_name_label.add_theme_font_size_override("font_size", 12)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_name_label.add_theme_constant_override("outline_size", 2)
	add_child(_name_label)


func _update_name_label() -> void:
	if _name_label:
		_name_label.text = display_name


func _setup_battle_ui() -> void:
	# HP 바
	_hp_bar = ProgressBar.new()
	_hp_bar.max_value = max_hp
	_hp_bar.value = current_hp
	_hp_bar.custom_minimum_size = Vector2(60, 8)
	_hp_bar.position = Vector2(-30, 10)
	_hp_bar.modulate = Color(0.2, 0.8, 0.2)
	add_child(_hp_bar)
	
	# HP 텍스트
	_hp_label = Label.new()
	_hp_label.text = "%d/%d" % [current_hp, max_hp]
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_label.position = Vector2(-30, 20)
	_hp_label.size = Vector2(60, 16)
	_hp_label.add_theme_font_size_override("font_size", 10)
	_hp_label.add_theme_color_override("font_color", Color.WHITE)
	_hp_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_hp_label.add_theme_constant_override("outline_size", 1)
	add_child(_hp_label)
	
	# MP 바
	if max_mp > 0:
		_mp_bar = ProgressBar.new()
		_mp_bar.max_value = max_mp
		_mp_bar.value = current_mp
		_mp_bar.custom_minimum_size = Vector2(60, 4)
		_mp_bar.position = Vector2(-30, 38)
		_mp_bar.modulate = Color(0.3, 0.5, 1)
		add_child(_mp_bar)


# ═══════════════════════════════════════════════════════════════════════════════
# Movement (Tile-based)
# ═══════════════════════════════════════════════════════════════════════════════

## 타일 좌표 설정 (즉시 이동)
func set_tile(tile: Vector2i) -> void:
	_current_tile = tile
	_target_tile = tile
	position = _tile_to_world(tile)
	_is_moving = false


## 타일 좌표로 이동
func move_to_tile(tile: Vector2i) -> void:
	if _is_moving:
		return
	
	if _state == State.TALKING or _state == State.IN_BATTLE:
		return
	
	_target_tile = tile
	_target_position = _tile_to_world(tile)
	_is_moving = true
	_state = State.MOVING
	_update_animation()


## 이동 처리
func _process_movement(delta: float) -> void:
	position = position.move_toward(_target_position, MOVE_SPEED * delta)
	
	if position.distance_to(_target_position) < 1.0:
		position = _target_position
		_current_tile = _target_tile
		_is_moving = false
		_state = State.IDLE
		_update_animation()
		movement_finished.emit()


## 타일 좌표 → 월드 좌표
func _tile_to_world(tile: Vector2i) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(tile.x * TILE_SIZE + TILE_SIZE / 2, tile.y * TILE_SIZE + TILE_SIZE / 2)


## 월드 좌표 → 타일 좌표
func _world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / TILE_SIZE), int(world_pos.y / TILE_SIZE))


# ═══════════════════════════════════════════════════════════════════════════════
# Direction & Animation
# ═══════════════════════════════════════════════════════════════════════════════

## 방향 설정
func set_direction(dir: Direction) -> void:
	if _direction == dir:
		return
	_direction = dir
	_update_animation()


## 방향 설정 (벡터 기반)
func set_direction_from_vector(move_vec: Vector2) -> void:
	if move_vec.y > 0:
		set_direction(Direction.DOWN)
	elif move_vec.y < 0:
		set_direction(Direction.UP)
	elif move_vec.x < 0:
		set_direction(Direction.LEFT)
	elif move_vec.x > 0:
		set_direction(Direction.RIGHT)


## 애니메이션 업데이트
func _update_animation() -> void:
	if not _animated_sprite or not _animated_sprite.sprite_frames:
		return
	
	var anim_name := _get_animation_name()
	
	# 해당 애니메이션이 없으면 default 사용
	if _animated_sprite.sprite_frames.has_animation(anim_name):
		_animated_sprite.play(anim_name)
	elif _animated_sprite.sprite_frames.has_animation("default"):
		_animated_sprite.play("default")


## 애니메이션 이름 생성
func _get_animation_name() -> String:
	var state_name := "idle"
	if _is_moving:
		state_name = "walk"
	
	var dir_name := ""
	match _direction:
		Direction.DOWN:
			dir_name = "_down"
		Direction.UP:
			dir_name = "_up"
		Direction.LEFT:
			dir_name = "_left"
		Direction.RIGHT:
			dir_name = "_right"
	
	return state_name + dir_name


# ═══════════════════════════════════════════════════════════════════════════════
# Battle Actions
# ═══════════════════════════════════════════════════════════════════════════════

## 데미지 받기
func take_damage(amount: int) -> void:
	if _is_dead or _battle_unit == null:
		return
	
	_battle_unit.hp = maxi(0, _battle_unit.hp - amount)
	_update_hp_display()
	
	if _battle_unit.hp <= 0:
		_die()


## 회복
func heal(amount: int) -> void:
	if _is_dead or _battle_unit == null:
		return
	
	_battle_unit.hp = mini(max_hp, _battle_unit.hp + amount)
	_update_hp_display()


## MP 사용
func use_mp(amount: int) -> void:
	if _battle_unit == null:
		return
	
	_battle_unit.mp = maxi(0, _battle_unit.mp - amount)
	_update_mp_display()


## MP 회복
func recover_mp(amount: int) -> void:
	if _battle_unit == null:
		return
	
	_battle_unit.mp = mini(max_mp, _battle_unit.mp + amount)
	_update_mp_display()


## 사망 처리
func _die() -> void:
	_is_dead = true
	if _battle_unit:
		_battle_unit.is_dead = true
	
	modulate = Color(0.5, 0.5, 0.5, 0.7)
	died.emit(self)


## HP 표시 업데이트
func _update_hp_display() -> void:
	if _hp_bar:
		_hp_bar.value = current_hp
	if _hp_label:
		_hp_label.text = "%d/%d" % [current_hp, max_hp]
	hp_changed.emit(current_hp, max_hp)


## MP 표시 업데이트
func _update_mp_display() -> void:
	if _mp_bar:
		_mp_bar.value = current_mp
	mp_changed.emit(current_mp, max_mp)


## 하이라이트 효과
func set_highlight(enabled: bool) -> void:
	if enabled:
		modulate = Color(1.2, 1.2, 1.0)
	else:
		modulate = Color(1, 1, 1) if not _is_dead else Color(0.5, 0.5, 0.5, 0.7)


## 비활성화 표시
func set_dimmed(dimmed: bool) -> void:
	if dimmed:
		modulate = Color(0.6, 0.6, 0.6)
	else:
		modulate = Color(1, 1, 1) if not _is_dead else Color(0.5, 0.5, 0.5, 0.7)


# ═══════════════════════════════════════════════════════════════════════════════
# Input Handling
# ═══════════════════════════════════════════════════════════════════════════════

func _on_click_area_input(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("  → Actor 클릭됨! ", name)
		clicked.emit(self)
		viewport.set_input_as_handled()


# ═══════════════════════════════════════════════════════════════════════════════
# Utility
# ═══════════════════════════════════════════════════════════════════════════════

## 클릭 가능 여부 설정
func set_clickable(enabled: bool) -> void:
	if _click_area:
		_click_area.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED


## 이름 표시 여부 설정
func set_name_visible(should_show: bool) -> void:
	if _name_label:
		_name_label.visible = should_show


## 스프라이트 프레임 설정
func set_sprite_frames(frames: SpriteFrames) -> void:
	if _animated_sprite:
		_animated_sprite.sprite_frames = frames
		_animated_sprite.play("idle_down")


## 애니메이션 재생
func play_animation(anim_name: String) -> void:
	if _animated_sprite and _animated_sprite.sprite_frames:
		if _animated_sprite.sprite_frames.has_animation(anim_name):
			_animated_sprite.play(anim_name)


## 애니메이션 정지
func stop_animation() -> void:
	if _animated_sprite:
		_animated_sprite.stop()
