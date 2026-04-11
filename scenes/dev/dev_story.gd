extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# DevStory
# 테스트용 컷신 진입점
# RNA 설정 후 main.tscn으로 전환
# ═══════════════════════════════════════════════════════════════════════════════

## 테스트할 컷신 ID (인스펙터에서 수정 가능)
@export var test_cutscene_id: String = "part1_opening"


func _ready() -> void:
	# 컷신 테스트용 RNA 설정
	GameManager.current_screen = "animation"
	GameManager.cutscene_id = test_cutscene_id
	GameManager.current_location = "bluewood_village"
	GameManager.party_members = ["sanzang"]
	GameManager.coin = 0
	GameManager._flags = {"test_mode": true}

	print("DevStory: 컷신 테스트 시작")
	print("  cutscene_id: ", test_cutscene_id)

	# main.tscn으로 전환 (화면 생성은 main.gd가 담당)
	get_tree().change_scene_to_file.call_deferred("res://scenes/prd/main.tscn")
