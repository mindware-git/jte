class_name BattleResultScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# BattleResultScreen
# 전투 결과 화면 (승리/패배)
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)

var _is_victory: bool = false
var _battle_log: Array[String] = []
var _exp_gained: int = 0
var _gold_gained: int = 0


# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_create_ui()


func setup(victory: bool, battle_log: Array[String]) -> void:
	_is_victory = victory
	_battle_log = battle_log
	
	# 보상 계산
	if victory:
		_exp_gained = 50
		_gold_gained = 100
		# 승리 플래그 설정
		var current_loc := GameManager.current_location
		if current_loc == "mountain_entrance":
			GameManager.set_flag("rock_demon_defeated", true)
		elif current_loc == "forest_deep":
			GameManager.set_flag("fire_spirit_boss_defeated", true)
	else:
		_exp_gained = 10
		_gold_gained = 0
		# 패배 시 HP 회복
		GameManager.player_hp = GameManager.player_max_hp


func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 결과 타이틀
	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 100)
	title.size = Vector2(1280, 100)
	title.add_theme_font_size_override("font_size", 64)
	
	if _is_victory:
		title.text = "승리!"
		title.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	else:
		title.text = "패배..."
		title.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))
	add_child(title)
	
	# 보상 패널
	var reward_panel := PanelContainer.new()
	reward_panel.position = Vector2(390, 250)
	reward_panel.size = Vector2(500, 200)
	add_child(reward_panel)
	
	var content := VBoxContainer.new()
	reward_panel.add_child(content)
	
	# 보상 타이틀
	var reward_title := Label.new()
	reward_title.text = "보상"
	reward_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_title.add_theme_font_size_override("font_size", 24)
	content.add_child(reward_title)
	
	# 경험치
	var exp_label := Label.new()
	exp_label.text = "경험치: +%d" % _exp_gained
	exp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exp_label.add_theme_font_size_override("font_size", 20)
	content.add_child(exp_label)
	
	# 경험치 추가
	GameManager.add_experience(_exp_gained)
	
	# 골드
	var gold_label := Label.new()
	gold_label.text = "골드: +%d" % _gold_gained
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_label.add_theme_font_size_override("font_size", 20)
	content.add_child(gold_label)
	
	# 골드 추가
	GameManager.add_gold(_gold_gained)
	
	# 전투 로그 (마지막 몇 줄)
	if _battle_log.size() > 0:
		var log_label := Label.new()
		var log_text := ""
		var start := maxi(0, _battle_log.size() - 3)
		for i in range(start, _battle_log.size()):
			log_text += _battle_log[i] + "\n"
		log_label.text = log_text
		log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		log_label.add_theme_font_size_override("font_size", 14)
		log_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		content.add_child(log_label)
	
	# 확인 버튼
	var confirm_btn := Button.new()
	confirm_btn.text = "확인"
	confirm_btn.position = Vector2(540, 500)
	confirm_btn.size = Vector2(200, 60)
	confirm_btn.add_theme_font_size_override("font_size", 24)
	confirm_btn.pressed.connect(_on_confirm_pressed)
	add_child(confirm_btn)


func _on_confirm_pressed() -> void:
	# LocationScreen으로 복귀
	var loc_screen := LocationScreen.new(GameManager.current_location)
	transition_requested.emit(loc_screen)