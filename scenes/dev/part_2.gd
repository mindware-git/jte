extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# Part 2 개발용 진입점
# Part 1 완료 상태에서 Part 2 시작
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Part 1 완료 상태 DNA 로드
	var dna_path := "res://asset/saves/dev/part_1_complete.json"
	
	if GameManager.load_dev_dna(dna_path):
		print("Part 1 완료 상태 로드 성공")
		print("현재 위치: ", GameManager.current_location)
		print("파티: ", GameManager.party_members)
	else:
		push_warning("DNA 로드 실패, 기본값 사용")
		GameManager.current_location = "donglim_temple"
	
	# LocationScreen 시작
	_start_location()


func _start_location() -> void:
	var location_screen := LocationScreen.new(GameManager.current_location)
	location_screen.transition_requested.connect(_on_transition)
	add_child(location_screen)


func _on_transition(next_screen: Node) -> void:
	# 화면 전환
	for child in get_children():
		child.queue_free()
	
	if next_screen.has_signal("transition_requested"):
		next_screen.transition_requested.connect(_on_transition)
	add_child(next_screen)
