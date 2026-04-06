extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# DevLocation
# 개발용: 특정 위치로 바로 진입
# ═══════════════════════════════════════════════════════════════════════════════

## 시작할 위치 ID
@export var start_location: String = "cheongmok_village"


func _ready() -> void:
	var location_screen := LocationScreen.new(start_location)
	location_screen.transition_requested.connect(_on_transition)
	add_child(location_screen)


func _on_transition(next_screen: Node) -> void:
	# 개발 모드에서는 간단히 처리
	for child in get_children():
		child.queue_free()
	
	if next_screen.has_signal("transition_requested"):
		next_screen.transition_requested.connect(_on_transition)
	add_child(next_screen)