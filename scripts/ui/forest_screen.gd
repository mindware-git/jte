class_name ForestScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# ForestScreen
# 숲 탐험 화면 (랜덤 인카운터 발생)
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	GameManager.current_map = "forest"
	_create_ui()


func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.06, 0.02)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 상단 여백 (HUD 공간)
	var top_spacer := Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 60)
	add_child(top_spacer)
	
	# 위치 설명
	var desc := Label.new()
	desc.text = "어두운 숲이다.\n어디선가 몬스터의 기척이 느껴진다..."
	desc.position = Vector2(100, 80)
	desc.size = Vector2(1080, 80)
	desc.add_theme_font_size_override("font_size", 18)
	desc.add_theme_color_override("font_color", Color(0.6, 0.7, 0.6))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(desc)
	
	# 버튼 컨테이너
	var btn_container := VBoxContainer.new()
	btn_container.position = Vector2(100, 200)
	btn_container.size = Vector2(500, 300)
	btn_container.add_theme_constant_override("separation", 15)
	add_child(btn_container)
	
	# 탐색하기 버튼
	var explore_btn := Button.new()
	explore_btn.text = "⚔️ 탐색하기 (전투 발생 확률 50%)"
	explore_btn.custom_minimum_size = Vector2(500, 60)
	explore_btn.add_theme_font_size_override("font_size", 20)
	explore_btn.pressed.connect(_on_explore_pressed)
	btn_container.add_child(explore_btn)
	
	# 사원으로 이동 (조건부)
	var temple_btn := Button.new()
	if GameManager.has_flag("temple_unlocked"):
		temple_btn.text = "🏛️ 사원으로 이동"
	else:
		temple_btn.text = "🏛️ 사원으로 이동 [퀘스트 필요]"
		temple_btn.disabled = true
	temple_btn.custom_minimum_size = Vector2(500, 60)
	temple_btn.add_theme_font_size_override("font_size", 20)
	temple_btn.pressed.connect(_on_temple_pressed)
	btn_container.add_child(temple_btn)
	
	# 마을로 돌아가기
	var village_btn := Button.new()
	village_btn.text = "🏠 마을로 돌아가기"
	village_btn.custom_minimum_size = Vector2(500, 60)
	village_btn.add_theme_font_size_override("font_size", 20)
	village_btn.pressed.connect(_on_village_pressed)
	btn_container.add_child(village_btn)
	
	# 퀘스트 상태
	_create_quest_panel()


func _create_quest_panel() -> void:
	var quest_panel := PanelContainer.new()
	quest_panel.position = Vector2(100, 480)
	quest_panel.size = Vector2(500, 100)
	add_child(quest_panel)
	
	var content := VBoxContainer.new()
	quest_panel.add_child(content)
	
	var quest_title := Label.new()
	quest_title.text = "📜 퀘스트: 마을의 위기"
	quest_title.add_theme_font_size_override("font_size", 16)
	quest_title.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	content.add_child(quest_title)
	
	var quest_desc := Label.new()
	if GameManager.has_flag("quest_complete"):
		quest_desc.text = "✅ 완료! 사원으로 이동하세요."
		quest_desc.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	elif GameManager.has_flag("quest_started"):
		quest_desc.text = "📍 숲에서 몬스터를 처치하세요!"
		quest_desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	else:
		quest_desc.text = "📍 먼저 촌장과 대화하세요."
		quest_desc.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	quest_desc.add_theme_font_size_override("font_size", 14)
	content.add_child(quest_desc)


func _on_explore_pressed() -> void:
	# 50% 확률로 전투 발생
	if randf() < 0.5:
		# 전투 시작 - battle.tscn 사용
		var battle_scene := preload("res://scenes/battle/battle.tscn").instantiate()
		var rna := {
			"party": GameManager.party_members,
			"enemies": ["rock_demon"],
			"flags": {}
		}
		battle_scene.setup(rna)
		battle_scene.battle_finished.connect(_on_battle_finished)
		add_child(battle_scene)
	else:
		# 아무 일 없음 - 메시지 표시
		_show_message("아무 일도 일어나지 않았다.\n계속 탐색할 수 있다.")


func _on_battle_finished(_victory: bool) -> void:
	# 전투 종료 후 숲 화면 유지
	pass


func _show_message(text: String) -> void:
	# 간단한 메시지 팝업
	var popup := PanelContainer.new()
	popup.position = Vector2(340, 280)
	popup.size = Vector2(600, 150)
	add_child(popup)
	
	var content := VBoxContainer.new()
	popup.add_child(content)
	
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	content.add_child(label)
	
	var close_btn := Button.new()
	close_btn.text = "확인"
	close_btn.pressed.connect(func(): popup.queue_free())
	content.add_child(close_btn)


func _on_temple_pressed() -> void:
	var temple := TempleScreen.new()
	transition_requested.emit(temple)


func _on_village_pressed() -> void:
	var village := VillageScreen.new()
	transition_requested.emit(village)