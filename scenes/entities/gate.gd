class_name Gate
extends Area2D

# ═══════════════════════════════════════════════════════════════════════════════
# Gate - 맵 간 이동 게이트
# 플레이어가 진입하면 다른 맵으로 이동
# ═══════════════════════════════════════════════════════════════════════════════

signal gate_entered(target_location: String, target_tile: Vector2i)

## 이동할 목적지 맵 ID
@export var target_location: String = ""

## 도착할 타일 좌표
@export var target_tile: Vector2i = Vector2i.ZERO

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	pass  # 시그널은 tscn에서 이미 연결됨


func _on_body_entered(body: Node2D) -> void:
	print("Gate: 무언가 진입함 - ", body, " type: ", body.get_class())
	
	# 플레이어만 감지
	if body is Actor:
		print("  → Actor 확인됨, role: ", body.current_role)
		if body.current_role == Actor.Role.PLAYER:
			print("  → 플레이어! 게이트 이동: ", target_location)
			gate_entered.emit(target_location, target_tile)
