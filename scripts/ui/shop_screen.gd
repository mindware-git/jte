class_name ShopScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# ShopScreen
# 상점 화면 (인앱결제)
# ═══════════════════════════════════════════════════════════════════════════════


signal closed()

var _return_screen: Control = null

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_create_ui()


func setup(return_screen: Control) -> void:
	_return_screen = return_screen


func _create_ui() -> void:
	# 배경 (반투명)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 상점 패널 (크기 확장)
	var shop_panel := PanelContainer.new()
	shop_panel.position = Vector2(190, 50)
	shop_panel.size = Vector2(900, 620)
	add_child(shop_panel)
	
	var content := VBoxContainer.new()
	shop_panel.add_child(content)
	
	# 타이틀
	var title := Label.new()
	title.text = "🛒 상점"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	content.add_child(title)
	
	# 화폐 표시
	var currency_row := HBoxContainer.new()
	currency_row.alignment = BoxContainer.ALIGNMENT_CENTER
	currency_row.add_theme_constant_override("separation", 50)
	content.add_child(currency_row)
	
	var gem_label := Label.new()
	gem_label.text = "💎 GEM: %d" % GameManager.gem
	gem_label.add_theme_font_size_override("font_size", 18)
	gem_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	currency_row.add_child(gem_label)
	
	var coin_label := Label.new()
	coin_label.text = "🪙 COIN: %d" % GameManager.coin
	coin_label.add_theme_font_size_override("font_size", 18)
	coin_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	currency_row.add_child(coin_label)
	
	# 구분선
	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 15)
	content.add_child(spacer1)
	
	# GEM → COIN 변환 섹션
	_create_gem_conversion(content)
	
	# 구분선
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	content.add_child(spacer2)
	
	# 게임 구매 아이템
	_create_game_purchase(content)
	
	# 구분선
	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 10)
	content.add_child(spacer3)
	
	# 저장 슬롯 구매
	_create_save_slot_purchase(content)
	
	# 구분선
	var spacer4 := Control.new()
	spacer4.custom_minimum_size = Vector2(0, 15)
	content.add_child(spacer4)
	
	# 닫기 버튼
	var close_btn := Button.new()
	close_btn.text = "닫기"
	close_btn.custom_minimum_size = Vector2(200, 50)
	close_btn.pressed.connect(_on_close_pressed)
	content.add_child(close_btn)


func _create_gem_conversion(parent: VBoxContainer) -> void:
	var section_panel := PanelContainer.new()
	parent.add_child(section_panel)
	
	var section_content := VBoxContainer.new()
	section_panel.add_child(section_content)
	
	# 섹션 타이틀
	var section_title := Label.new()
	section_title.text = "💱 GEM → COIN 변환"
	section_title.add_theme_font_size_override("font_size", 16)
	section_title.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9))
	section_content.add_child(section_title)
	
	# 변환 옵션들
	var options_row := HBoxContainer.new()
	options_row.add_theme_constant_override("separation", 15)
	section_content.add_child(options_row)
	
	# 변환 옵션: 10 GEM → 1000 COIN
	_create_conversion_option(options_row, 10, 1000)
	
	# 변환 옵션: 50 GEM → 5500 COIN (10% 보너스)
	_create_conversion_option(options_row, 50, 5500)
	
	# 변환 옵션: 100 GEM → 12000 COIN (20% 보너스)
	_create_conversion_option(options_row, 100, 12000)


func _create_conversion_option(parent: HBoxContainer, gem_amount: int, coin_amount: int) -> void:
	var option_panel := PanelContainer.new()
	parent.add_child(option_panel)
	
	var option_content := VBoxContainer.new()
	option_panel.add_child(option_content)
	
	var info_label := Label.new()
	info_label.text = "💎 %d → 🪙 %d" % [gem_amount, coin_amount]
	info_label.add_theme_font_size_override("font_size", 14)
	option_content.add_child(info_label)
	
	var rate_label := Label.new()
	var bonus_percent := int((float(coin_amount) / float(gem_amount) / float(GameManager.GEM_TO_COIN_RATE) - 1.0) * 100)
	if bonus_percent > 0:
		rate_label.text = "(보너스 +%d%%)" % bonus_percent
		rate_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	else:
		rate_label.text = ""
	rate_label.add_theme_font_size_override("font_size", 12)
	option_content.add_child(rate_label)
	
	var convert_btn := Button.new()
	convert_btn.text = "변환"
	convert_btn.custom_minimum_size = Vector2(80, 35)
	if GameManager.gem < gem_amount:
		convert_btn.disabled = true
	convert_btn.pressed.connect(_on_convert_gem.bind(gem_amount, coin_amount))
	option_content.add_child(convert_btn)


func _on_convert_gem(gem_amount: int, coin_amount: int) -> void:
	if GameManager.convert_gem_to_coin(gem_amount):
		# 실제로는 coin_amount를 추가해야 함 (convert_gem_to_coin은 기본 비율만 적용)
		GameManager.coin = coin_amount  # 보너스 포함된 금액으로 설정
		GameManager.gold = GameManager.coin
		_show_purchase_success("변환 완료! 💎 %d → 🪙 %d" % [gem_amount, coin_amount])
		_rebuild_ui()
	else:
		_show_purchase_success("GEM이 부족합니다!")


func _create_game_purchase(parent: VBoxContainer) -> void:
	var item_panel := PanelContainer.new()
	parent.add_child(item_panel)
	
	var item_content := VBoxContainer.new()
	item_panel.add_child(item_content)
	
	# 아이템 이름
	var name_label := Label.new()
	if GameManager.is_game_purchased():
		name_label.text = "🎮 게임 구매 (보스 진입 권한) ✅ 구매완료"
		name_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	else:
		name_label.text = "🎮 게임 구매 (보스 진입 권한)"
		name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	name_label.add_theme_font_size_override("font_size", 18)
	item_content.add_child(name_label)
	
	# 설명
	var desc_label := Label.new()
	desc_label.text = "보스(사원)에 진입할 수 있는 권한을 얻습니다."
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	item_content.add_child(desc_label)
	
	# 가격 및 구매 버튼
	var price_row := HBoxContainer.new()
	price_row.add_theme_constant_override("separation", 20)
	item_content.add_child(price_row)
	
	var price_label := Label.new()
	price_label.text = "₩5,000"
	price_label.add_theme_font_size_override("font_size", 20)
	price_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	price_row.add_child(price_label)
	
	if not GameManager.is_game_purchased():
		var buy_btn := Button.new()
		buy_btn.text = "구매하기"
		buy_btn.custom_minimum_size = Vector2(120, 40)
		buy_btn.pressed.connect(_on_purchase_game)
		price_row.add_child(buy_btn)


func _create_save_slot_purchase(parent: VBoxContainer) -> void:
	var item_panel := PanelContainer.new()
	parent.add_child(item_panel)
	
	var item_content := VBoxContainer.new()
	item_panel.add_child(item_content)
	
	# 아이템 이름
	var name_label := Label.new()
	name_label.text = "💾 저장 슬롯 확장 (현재: %d개)" % GameManager.save_slots
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	item_content.add_child(name_label)
	
	# 설명
	var desc_label := Label.new()
	desc_label.text = "게임 진행 상태를 저장할 수 있는 슬롯을 추가합니다."
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	item_content.add_child(desc_label)
	
	# 가격 및 구매 버튼
	var price_row := HBoxContainer.new()
	price_row.add_theme_constant_override("separation", 20)
	item_content.add_child(price_row)
	
	var price_label := Label.new()
	price_label.text = "₩1,000"
	price_label.add_theme_font_size_override("font_size", 20)
	price_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	price_row.add_child(price_label)
	
	var buy_btn := Button.new()
	buy_btn.text = "구매하기"
	buy_btn.custom_minimum_size = Vector2(120, 40)
	buy_btn.pressed.connect(_on_purchase_save_slot)
	price_row.add_child(buy_btn)


# ═══════════════════════════════════════════════════════════════════════════════
# Purchase Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_purchase_game() -> void:
	# 실제 인앱결제는 여기서 처리
	# 지금은 바로 구매 완료로 처리
	GameManager.purchase_game()
	_show_purchase_success("게임 구매 완료!")
	# UI 갱신을 위해 재생성
	_rebuild_ui()


func _on_purchase_save_slot() -> void:
	GameManager.purchase_save_slot()
	_show_purchase_success("저장 슬롯 추가 완료! (현재: %d개)" % GameManager.save_slots)
	_rebuild_ui()


func _show_purchase_success(message: String) -> void:
	var popup := PanelContainer.new()
	popup.position = Vector2(390, 250)
	popup.size = Vector2(500, 100)
	add_child(popup)
	
	var content := VBoxContainer.new()
	popup.add_child(content)
	
	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	content.add_child(label)
	
	# 자동으로 닫기
	await get_tree().create_timer(1.5).timeout
	popup.queue_free()


func _rebuild_ui() -> void:
	# 기존 UI 제거
	for child in get_children():
		child.queue_free()
	
	# 새 UI 생성
	await get_tree().process_frame
	_create_ui()


func _on_close_pressed() -> void:
	closed.emit()
	if _return_screen:
		# 바로 이전 화면으로 돌아가기 (화면 전환 없이 닫기)
		queue_free()
	else:
		queue_free()
