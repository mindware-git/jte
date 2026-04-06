class_name EndingScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# EndingScreen
# 엔딩 화면 (게임 클리어)
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	# 보스 처치 플래그 설정
	GameManager.defeat_boss()
	_create_ui()


func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.05)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 타이틀
	var title := Label.new()
	title.text = "🌟 THE END 🌟"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 80)
	title.size = Vector2(1280, 100)
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	add_child(title)
	
	# 엔딩 텍스트 패널
	var text_panel := PanelContainer.new()
	text_panel.position = Vector2(190, 220)
	text_panel.size = Vector2(900, 300)
	add_child(text_panel)
	
	var content := VBoxContainer.new()
	text_panel.add_child(content)
	
	var lines := [
		"여정이 끝났다.",
		"",
		"악마는 다시 봉인되었고",
		"마을은 평화를 되찾았다.",
		"",
		"%s의 여정은 여기서 끝나지만," % GameManager.player_name,
		"또 다른 모험이 기다리고 있을지도...",
		"",
		"🎉 감사합니다! 🎉"
	]
	
	for line in lines:
		var label := Label.new()
		label.text = line
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		content.add_child(label)
	
	# 플레이어 최종 상태
	var status_panel := PanelContainer.new()
	status_panel.position = Vector2(340, 550)
	status_panel.size = Vector2(600, 80)
	add_child(status_panel)
	
	var status_content := VBoxContainer.new()
	status_panel.add_child(status_content)
	
	var stats := Label.new()
	stats.text = "최종 상태: Lv.%d | HP: %d | MP: %d | 💰 %d | ⭐ %d XP" % [
		GameManager.level, GameManager.player_max_hp, GameManager.player_max_mp,
		GameManager.gold, GameManager.experience
	]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 16)
	status_content.add_child(stats)
	
	# 타이틀로 돌아가기 버튼
	var title_btn := Button.new()
	title_btn.text = "타이틀로 돌아가기"
	title_btn.position = Vector2(540, 660)
	title_btn.size = Vector2(200, 50)
	title_btn.add_theme_font_size_override("font_size", 20)
	title_btn.pressed.connect(_on_title_pressed)
	add_child(title_btn)


func _on_title_pressed() -> void:
	# 게임 상태 초기화
	GameManager.reset_state()
	
	var title := TitleScreen.new()
	transition_requested.emit(title)