class_name TempleScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# TempleScreen
# 사원 화면 (보스 전투)
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)
signal shop_requested()

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	GameManager.current_map = "temple"
	_create_ui()


func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.05, 0.15)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 상단 여백 (HUD 공간)
	var top_spacer := Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 60)
	add_child(top_spacer)
	
	# 위치 설명
	var desc := Label.new()
	desc.text = "오래된 사원이다.\n강력한 기운이 느껴진다...\n\n⚠️ 보스가 기다리고 있습니다!"
	desc.position = Vector2(100, 80)
	desc.size = Vector2(1080, 120)
	desc.add_theme_font_size_override("font_size", 18)
	desc.add_theme_color_override("font_color", Color(0.7, 0.6, 0.8))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(desc)
	
	# 버튼 컨테이너
	var btn_container := VBoxContainer.new()
	btn_container.position = Vector2(100, 250)
	btn_container.size = Vector2(500, 200)
	btn_container.add_theme_constant_override("separation", 15)
	add_child(btn_container)
	
	# 보스 도전 버튼
	var boss_btn := Button.new()
	if GameManager.is_game_purchased():
		boss_btn.text = "👹 보스에게 도전"
	else:
		boss_btn.text = "👹 보스에게 도전 [구매 필요]"
	boss_btn.custom_minimum_size = Vector2(500, 60)
	boss_btn.add_theme_font_size_override("font_size", 20)
	boss_btn.pressed.connect(_on_boss_pressed)
	btn_container.add_child(boss_btn)
	
	# 구매 안내 (구매하지 않은 경우)
	if not GameManager.is_game_purchased():
		var purchase_info := Label.new()
		purchase_info.text = "💡 상점에서 게임을 구매하면 보스에 도전할 수 있습니다."
		purchase_info.position = Vector2(100, 400)
		purchase_info.size = Vector2(500, 40)
		purchase_info.add_theme_font_size_override("font_size", 14)
		purchase_info.add_theme_color_override("font_color", Color(0.7, 0.7, 0.5))
		add_child(purchase_info)
		
		var shop_btn := Button.new()
		shop_btn.text = "🛒 상점으로 이동"
		shop_btn.position = Vector2(100, 450)
		shop_btn.size = Vector2(200, 40)
		shop_btn.pressed.connect(_on_shop_pressed)
		add_child(shop_btn)
	
	# 마을로 돌아가기
	var village_btn := Button.new()
	village_btn.text = "🏠 마을로 돌아가기"
	village_btn.custom_minimum_size = Vector2(500, 60)
	village_btn.add_theme_font_size_override("font_size", 20)
	village_btn.pressed.connect(_on_village_pressed)
	btn_container.add_child(village_btn)


func _on_boss_pressed() -> void:
	# 구매 확인
	if not GameManager.is_game_purchased():
		_show_purchase_required()
		return
	
	# 보스 전투 설정 - battle.tscn 사용
	var battle_scene := preload("res://scenes/battle/battle.tscn").instantiate()
	var rna := {
		"party": GameManager.party_members,
		"enemies": ["fire_spirit"],  # 보스 적
		"flags": {"is_boss": true}
	}
	battle_scene.setup(rna)
	battle_scene.battle_finished.connect(_on_battle_finished)
	add_child(battle_scene)


func _on_battle_finished(_victory: bool) -> void:
	# 전투 종료 후 사원 화면 유지
	pass


func _on_shop_pressed() -> void:
	shop_requested.emit()


func _show_purchase_required() -> void:
	var popup := PanelContainer.new()
	popup.position = Vector2(340, 280)
	popup.size = Vector2(600, 150)
	add_child(popup)
	
	var content := VBoxContainer.new()
	popup.add_child(content)
	
	var label := Label.new()
	label.text = "⚠️ 게임을 구매해야 보스에 도전할 수 있습니다.\n상점에서 게임을 구매해주세요."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	content.add_child(label)
	
	var close_btn := Button.new()
	close_btn.text = "확인"
	close_btn.pressed.connect(func(): popup.queue_free())
	content.add_child(close_btn)


func _on_village_pressed() -> void:
	var village := VillageScreen.new()
	transition_requested.emit(village)