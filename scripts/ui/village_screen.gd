class_name VillageScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# VillageScreen
# 마을 화면 (핵심 탐험 허브)
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	GameManager.current_map = "village"
	_create_ui()


func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.06, 0.04)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 상단 여백 (HUD 공간)
	var top_spacer := Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 60)
	add_child(top_spacer)
	
	# 위치 설명
	var desc := Label.new()
	desc.text = "평화로운 마을이다.\n주민들이 분주하게 움직인다."
	desc.position = Vector2(100, 80)
	desc.size = Vector2(1080, 80)
	desc.add_theme_font_size_override("font_size", 18)
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(desc)
	
	# 버튼 컨테이너
	var btn_container := VBoxContainer.new()
	btn_container.position = Vector2(100, 200)
	btn_container.size = Vector2(500, 300)
	btn_container.add_theme_constant_override("separation", 15)
	add_child(btn_container)
	
	# 촌장과 대화
	var chief_btn := Button.new()
	chief_btn.text = "👤 촌장과 대화"
	chief_btn.custom_minimum_size = Vector2(500, 60)
	chief_btn.add_theme_font_size_override("font_size", 20)
	chief_btn.pressed.connect(_on_chief_pressed)
	btn_container.add_child(chief_btn)
	
	# 숲으로 이동
	var forest_btn := Button.new()
	forest_btn.text = "🌲 숲으로 이동"
	forest_btn.custom_minimum_size = Vector2(500, 60)
	forest_btn.add_theme_font_size_override("font_size", 20)
	forest_btn.pressed.connect(_on_forest_pressed)
	btn_container.add_child(forest_btn)
	
	# 사원으로 이동 (조건부)
	var temple_btn := Button.new()
	if GameManager.has_flag("temple_unlocked"):
		temple_btn.text = "🏛️ 사원으로 이동 (보스)"
	else:
		temple_btn.text = "🏛️ 사원으로 이동 [잠김]"
		temple_btn.disabled = true
	temple_btn.custom_minimum_size = Vector2(500, 60)
	temple_btn.add_theme_font_size_override("font_size", 20)
	temple_btn.pressed.connect(_on_temple_pressed)
	btn_container.add_child(temple_btn)
	
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
		quest_desc.text = "✅ 완료! 사원으로 이동할 수 있습니다."
		quest_desc.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	elif GameManager.has_flag("quest_started"):
		quest_desc.text = "📍 숲의 몬스터를 처치하세요."
		quest_desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	else:
		quest_desc.text = "📍 촌장에게 물어보세요."
		quest_desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	quest_desc.add_theme_font_size_override("font_size", 14)
	content.add_child(quest_desc)


func _on_chief_pressed() -> void:
	var dialogue := DialogueScreen.new()
	dialogue.setup("chief", self)
	transition_requested.emit(dialogue)


func _on_forest_pressed() -> void:
	var forest := ForestScreen.new()
	transition_requested.emit(forest)


func _on_temple_pressed() -> void:
	var temple := TempleScreen.new()
	transition_requested.emit(temple)