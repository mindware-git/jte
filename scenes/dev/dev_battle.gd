extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# DevBattle
# 테스트용 전투 씬
# RNA만 바꿔서 다양한 전투 테스트 가능
# ═══════════════════════════════════════════════════════════════════════════════

## 테스트할 RNA (인스펙터에서 수정 가능)
@export var test_party: Array[String] = ["sanzang", "wukong"]
@export var test_enemies: Array[String] = ["rock_demon"]


func _ready() -> void:
	# 테스트 RNA 생성
	var rna := _create_test_rna()
	
	# Battle 씬 인스턴스화
	var battle_scene := preload("res://scenes/battle/battle.tscn").instantiate()
	battle_scene.setup(rna)
	battle_scene.battle_finished.connect(_on_battle_finished)
	add_child(battle_scene)


func _create_test_rna() -> Dictionary:
	return {
		"party": test_party,
		"enemies": test_enemies,
		"flags": {
			"test_mode": true
		}
	}


func _on_battle_finished(victory: bool) -> void:
	print("[DevBattle] 전투 종료: %s" % ("승리" if victory else "패배"))
	
	# 결과 표시
	var result := Label.new()
	result.text = "전투 테스트 완료: %s\nESC로 종료" % ("승리" if victory else "패배")
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.add_theme_font_size_override("font_size", 24)
	result.position = Vector2(440, 300)
	result.add_theme_color_override("font_color", Color.WHITE)
	add_child(result)
