class_name TitleScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# TitleScreen
# 게임 타이틀 화면
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_create_ui()


func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 타이틀
	var title := Label.new()
	title.text = "환상서유기"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 150)
	title.size = Vector2(1280, 80)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	add_child(title)
	
	# 부제목
	var subtitle := Label.new()
	subtitle.text = "Fantasy Journey West"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(0, 240)
	subtitle.size = Vector2(1280, 40)
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	add_child(subtitle)
	
	# 버튼 컨테이너
	var btn_container := VBoxContainer.new()
	btn_container.position = Vector2(490, 350)
	btn_container.size = Vector2(300, 200)
	add_child(btn_container)
	
	# 새 게임 버튼
	var new_game_btn := Button.new()
	new_game_btn.text = "새 게임"
	new_game_btn.custom_minimum_size = Vector2(300, 60)
	new_game_btn.add_theme_font_size_override("font_size", 24)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	btn_container.add_child(new_game_btn)
	
	# 간격
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	btn_container.add_child(spacer)
	
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
	
	btn_container.add_child(continue_btn)
	
	# 버전 표시
	var version := Label.new()
	version.text = "v0.1.0 - Button World MVP"
	version.position = Vector2(10, 690)
	version.add_theme_font_size_override("font_size", 12)
	version.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	add_child(version)


func _on_new_game_pressed() -> void:
	# 게임 상태 초기화
	GameManager.reset_state()
	
	# 스토리 화면으로 이동
	var story := StoryScreen.new()
	transition_requested.emit(story)


func _on_continue_pressed() -> void:
	# 불러오기 화면 표시
	var load_screen := SaveSlotScreen.new()
	load_screen.setup(SaveSlotScreen.Mode.LOAD)
	load_screen.load_done.connect(_on_load_done)
	add_child(load_screen)


func _on_load_done(_slot_index: int) -> void:
	# 로드 완료 후 마을 화면으로 이동
	var village := VillageScreen.new()
	transition_requested.emit(village)
