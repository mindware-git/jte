class_name Interactable
extends Area2D

# ═══════════════════════════════════════════════════════════════════════════════
# Interactable - 상호작용 가능한 오브젝트
# 플레이어가 근처에서 클릭하면 상호작용
# ═══════════════════════════════════════════════════════════════════════════════

signal interacted(interactable: Interactable)

## 상호작용 타입 ("npc", "treasure", "investigate", "battle", "shop", "puzzle", "event")
@export var interact_type: String = ""

## 상호작용 데이터 (타입별로 다름)
@export var interact_data: Dictionary = {}

## 전투 고유 ID (battle 타입에서 사용, RNA 플래그용)
@export var battle_id: String = ""

## 한 번만 상호작용 가능
@export var one_time: bool = true

## 이미 상호작용했는지
var _has_interacted: bool = false

## 플레이어가 범위 내에 있는지
var _player_in_range: bool = false

## 상호작용 버튼
@onready var _interaction_button: Button = $Button

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_setup_collision_size()
	_interaction_button.visible = false
	_interaction_button.pressed.connect(_on_button_pressed)


func _setup_collision_size() -> void:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision and collision.shape is RectangleShape2D:
		var shape := collision.shape as RectangleShape2D
		if interact_type == "npc":
			shape.size = Vector2(64 * 3, 64 * 3)  # 192x192 (3 grid)
		else:
			shape.size = Vector2(64, 64)
		print("Interactable collision 크기 설정: ", name, " type: ", interact_type, " size: ", shape.size)
	else:
		print("Interactable collision 없음: ", name)


func _on_body_entered(body: Node2D) -> void:
	if body is Actor and body.current_role == Actor.Role.PLAYER:
		_player_in_range = true
		print("Interactable: 플레이어 진입 - ", name)
		
		# 버튼 표시
		if _interaction_button:
			_interaction_button.visible = true
		
		# battle 타입은 자동 발동
		if interact_type == "battle" and can_interact():
			_interact()


func _on_body_exited(body: Node2D) -> void:
	if body is Actor and body.current_role == Actor.Role.PLAYER:
		_player_in_range = false
		print("Interactable: 플레이어 이탈 - ", name)
		
		# 버튼 숨기기
		if _interaction_button:
			_interaction_button.visible = false


# ═══════════════════════════════════════════════════════════════════════════════
# Interaction
# ═══════════════════════════════════════════════════════════════════════════════

func can_interact() -> bool:
	# battle 타입은 RNA 플래그 확인
	if interact_type == "battle":
		if battle_id != "" and GameManager.get_flag("battle_" + battle_id):
			return false
		return _player_in_range
	
	# 기존 one_time 로직
	if one_time and _has_interacted:
		return false
	return _player_in_range


func _on_button_pressed() -> void:
	if can_interact():
		_interact()


func _interact() -> void:
	_has_interacted = true
	
	# 버튼 숨기기
	if _interaction_button:
		_interaction_button.visible = false
	
	# battle 타입은 RNA에 플래그 저장
	if interact_type == "battle" and battle_id != "":
		GameManager.set_flag("battle_" + battle_id, true)
	
	print("Interactable: 상호작용 - ", name, " type: ", interact_type, " data: ", interact_data)
	interacted.emit(self)
