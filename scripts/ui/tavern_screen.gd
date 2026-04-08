class_name TavernScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# TavernScreen
# 주점 내부 화면
# 허풍 노인이 있는 곳
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)

# NPC 레지스트리
var _npc_registry: NPCRegistry

# UI 컴포넌트
var _name_label: Label
var _desc_label: Label
var _npc_container: VBoxContainer

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_npc_registry = NPCRegistry.new()
	_create_ui()


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 배경 (어두운 주점 분위기)
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.05, 0.02)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 메인 컨테이너
	var main_container := VBoxContainer.new()
	main_container.position = Vector2(100, 50)
	main_container.size = Vector2(1080, 600)
	add_child(main_container)
	
	# 주점 이름
	_name_label = Label.new()
	_name_label.text = "술집"
	_name_label.add_theme_font_size_override("font_size", 32)
	_name_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	main_container.add_child(_name_label)
	
	# 설명
	_desc_label = Label.new()
	_desc_label.text = "어두운 주점 안이다. 술 냄새와 함께 웅성거리는 소리가 들린다."
	_desc_label.add_theme_font_size_override("font_size", 18)
	_desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	main_container.add_child(_desc_label)
	
	# 간격
	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 30)
	main_container.add_child(spacer1)
	
	# NPC 섹션
	var npc_section := VBoxContainer.new()
	main_container.add_child(npc_section)
	
	var npc_title := Label.new()
	npc_title.text = "사람들"
	npc_title.add_theme_font_size_override("font_size", 20)
	npc_title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	npc_section.add_child(npc_title)
	
	_npc_container = VBoxContainer.new()
	npc_section.add_child(_npc_container)
	
	# NPC 버튼 생성
	_create_npc_buttons()
	
	# 간격
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	main_container.add_child(spacer2)
	
	# 나가기 버튼
	var exit_btn := Button.new()
	exit_btn.text = "← 마을로 돌아가기"
	exit_btn.custom_minimum_size = Vector2(300, 50)
	exit_btn.pressed.connect(_on_exit_pressed)
	main_container.add_child(exit_btn)


func _create_npc_buttons() -> void:
	# 허풍 노인
	var old_man_btn := Button.new()
	old_man_btn.text = "🧓 허풍 노인 - 탁자에 앉아 있다"
	old_man_btn.custom_minimum_size = Vector2(400, 50)
	old_man_btn.pressed.connect(_on_old_man_pressed)
	_npc_container.add_child(old_man_btn)
	
	# TODO: 다른 NPC 추가 가능
	# var bartender_btn := Button.new()
	# bartender_btn.text = "🍸 바텐더"
	# bartender_btn.custom_minimum_size = Vector2(400, 50)
	# bartender_btn.pressed.connect(_on_bartender_pressed)
	# _npc_container.add_child(bartender_btn)


# ═══════════════════════════════════════════════════════════════════════════════
# Button Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_old_man_pressed() -> void:
	# DialoguePanel 오버레이 표시
	var dialogue_panel := DialoguePanel.new("old_man")
	dialogue_panel.dialogue_finished.connect(_on_dialogue_finished)
	add_child(dialogue_panel)


func _on_dialogue_finished(result: Dictionary) -> void:
	# 대화 종료 후 처리
	print("대화 종료: ", result)
	# result에 items_acquired가 있으면 이미 DialoguePanel에서 표시됨


func _on_exit_pressed() -> void:
	# 마을로 돌아가기
	var village_screen := LocationScreen.new("bluewood_village")
	transition_requested.emit(village_screen)