extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# Part 1 개발용 진입점
# DNA 로드 후 main.tscn으로 전환
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# 파트 1 초기 상태 DNA 로드
	var dna_path := "res://asset/saves/dev/part_1_init.json"
	
	if GameManager.load_dev_dna(dna_path):
		print("파트 1 초기 상태 로드 성공")
		print("현재 화면: ", GameManager.current_screen)
		print("현재 위치: ", GameManager.current_location)
		print("파티: ", GameManager.party_members)
	else:
		push_warning("DNA 로드 실패, 기본값 사용")
		GameManager.current_screen = "explore"
		GameManager.current_location = "bluewood_village"
		GameManager.party_members = ["sanzang"]
	
	# main.tscn으로 전환 (화면 생성은 main.gd가 담당)
	get_tree().change_scene_to_file.call_deferred("res://scenes/prd/main.tscn")
