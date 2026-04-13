class_name TitleScreen
extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# TitleScreen
# 게임 타이틀 화면 (Node2D 기반, UI는 Control 자식으로)
# ═══════════════════════════════════════════════════════════════════════════════

signal finished()

# UI 컨테이너
var _ui_container: Control
var _canvas_layer: CanvasLayer

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_create_ui_container()
	_create_ui()


# ═══════════════════════════════════════════════════════════════════════════════
# UI Container Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui_container() -> void:
	# CanvasLayer 생성 (UI 레이어 분리)
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.name = "UILayer"
	add_child(_canvas_layer)
	
	# UI 컨테이너는 CanvasLayer 아래에
	_ui_container = Control.new()
	_ui_container.name = "UIContainer"
	_ui_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas_layer.add_child(_ui_container)


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_container.add_child(bg)
	
	# 메인 VBoxContainer (타이틀 + 버튼 통합)
	var main_vbox := VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.set_anchors_preset(Control.PRESET_CENTER)
	main_vbox.position = Vector2(-150, -200)  # 중앙 정렬 보정
	main_vbox.size = Vector2(300, 400)
	_ui_container.add_child(main_vbox)
	
	# 상단 여백
	var top_spacer := Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 50)
	main_vbox.add_child(top_spacer)
	
	# 타이틀
	var title := Label.new()
	title.text = "동유기"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	main_vbox.add_child(title)
	
	# 부제목
	var subtitle := Label.new()
	subtitle.text = "Journey to East"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	main_vbox.add_child(subtitle)
	
	# 타이틀과 버튼 사이 간격
	var mid_spacer := Control.new()
	mid_spacer.custom_minimum_size = Vector2(0, 60)
	main_vbox.add_child(mid_spacer)
	
	# 새 게임 버튼
	var new_game_btn := Button.new()
	new_game_btn.text = "새 게임"
	new_game_btn.custom_minimum_size = Vector2(300, 60)
	new_game_btn.add_theme_font_size_override("font_size", 24)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	main_vbox.add_child(new_game_btn)
	
	# 버튼 간격
	var btn_spacer := Control.new()
	btn_spacer.custom_minimum_size = Vector2(0, 20)
	main_vbox.add_child(btn_spacer)
	
	# 이어하기 버튼
	var continue_btn := Button.new()
	continue_btn.text = "이어하기"
	continue_btn.custom_minimum_size = Vector2(300, 60)
	continue_btn.add_theme_font_size_override("font_size", 24)
	
	# 저장 데이터가 있으면 활성화
	var has_save := SaveManager.has_any_save_data()
	continue_btn.disabled = not has_save
	if has_save:
		continue_btn.pressed.connect(_on_continue_pressed)
	
	main_vbox.add_child(continue_btn)
	
	# 버전 표시 (하단 고정)
	var version := Label.new()
	version.text = "v0.1.0 - Button World MVP"
	version.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	version.position = Vector2(10, -30)
	version.add_theme_font_size_override("font_size", 12)
	version.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	_ui_container.add_child(version)

# ═══════════════════════════════════════════════════════════════════════════════
# Event Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_new_game_pressed() -> void:
	# 게임 상태 초기화
	GameManager.reset_state()
	
	# 프롤로그 컷신부터 시작
	GameManager.current_screen = "story"
	GameManager.cutscene_id = "part1_opening"
	finished.emit()


func _on_continue_pressed() -> void:
	# 불러오기 패널 표시 (오버레이)
	var load_panel := SaveSlotPanel.new()
	load_panel.setup(SaveSlotPanel.Mode.LOAD)
	load_panel.load_done.connect(_on_load_done)
	_ui_container.add_child(load_panel)


func _on_load_done(_slot_index: int) -> void:
	# 로드 완료 후 ExploreScreen으로 이동
	GameManager.current_screen = "explore"
	finished.emit()
