class_name Treasure
extends StaticBody2D

# ═══════════════════════════════════════════════════════════════════════════════
# Treasure - 보물 상자
# 맵 에디터에서 item_id를 설정하여 아이템을 담을 수 있음
# ═══════════════════════════════════════════════════════════════════════════════

## 보물 상자에서 나올 아이템 ID
@export var item_id: String = ""

## 고유 식별자 (자동 생성 또는 수동 설정)
@export var treasure_id: String = ""

## 열림 상태
var _is_opened: bool = false

## 스프라이트
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# treasure_id가 없으면 위치 기반으로 자동 생성
	if treasure_id == "":
		var grid_pos := Vector2i(int(position.x / 64), int(position.y / 64))
		treasure_id = "treasure_%d_%d" % [grid_pos.x, grid_pos.y]
	
	# 열림 상태 복원
	_restore_opened_state()


func _restore_opened_state() -> void:
	var is_opened: bool = GameManager.get_location_state(
		GameManager.current_location,
		"treasure_" + treasure_id,
		false
	)
	
	if is_opened:
		_is_opened = true
		_update_sprite()


# ═══════════════════════════════════════════════════════════════════════════════
# Public API
# ═══════════════════════════════════════════════════════════════════════════════

func is_opened() -> bool:
	return _is_opened


func set_opened(opened: bool) -> void:
	_is_opened = opened
	
	# 상태 저장
	GameManager.set_location_state(
		GameManager.current_location,
		"treasure_" + treasure_id,
		true
	)
	
	_update_sprite()
	print("Treasure 열림: ", treasure_id, " 아이템: ", item_id)


func get_item_id() -> String:
	return item_id


func get_treasure_id() -> String:
	return treasure_id


# ═══════════════════════════════════════════════════════════════════════════════
# Internal
# ═══════════════════════════════════════════════════════════════════════════════

func _update_sprite() -> void:
	if _sprite == null:
		return
	
	if _is_opened:
		_sprite.animation = "opened"
	else:
		_sprite.animation = "default"
