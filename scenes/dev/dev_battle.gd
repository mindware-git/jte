extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# DevBattle
# 테스트용 전투 진입점
# DNA 로드 후 main.tscn으로 전환
# ═══════════════════════════════════════════════════════════════════════════════

## 테스트용 RNA 설정 (인스펙터에서 수정 가능)
@export var test_party: Array[String] = ["sanzang", "wukong"]
@export var test_enemies: Array[String] = ["rock_demon"]


func _ready() -> void:
	# 배틀 테스트용 DNA 로드
	var dna_path := "res://asset/saves/dev/battle_init.json"
	
	if GameManager.load_dev_dna(dna_path):
		print("배틀 초기 상태 로드 성공")
		print("현재 화면: ", GameManager.current_screen)
		print("파티: ", GameManager.party_members)
		print("적: ", GameManager.enemy_id)
	else:
		push_warning("DNA 로드 실패, 기본값 사용")
		GameManager.current_screen = "battle"
		GameManager.party_members = test_party
		GameManager.enemy_id = test_enemies[0] if test_enemies.size() > 0 else "rock_demon"
		GameManager.current_location = "test_battle"
		GameManager.coin = 100
		GameManager._flags = {"test_mode": true}
	
	# main.tscn으로 전환 (화면 생성은 main.gd가 담당)
	get_tree().change_scene_to_file.call_deferred("res://scenes/prd/main.tscn")
