class_name ShopPanel
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# ShopPanel
# 오버레이 상점 UI
# 기존 화면 위에 표시되는 상점 인터페이스
# ═══════════════════════════════════════════════════════════════════════════════

signal closed(result: Dictionary)

## 상점 ID
var _shop_id: String = "general_store"

## 레지스트리
var _shop_registry: ShopRegistry
var _item_registry: ItemRegistry
var _shop_data: ShopData

## 현재 탭 (true = 구매, false = 판매)
var _is_buy_tab: bool = true

## 결과 데이터
var _result: Dictionary = {}

## UI 컴포넌트
var _overlay: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _coin_label: Label
var _tab_container: HBoxContainer
var _buy_tab_btn: Button
var _sell_tab_btn: Button
var _item_list: VBoxContainer
var _item_scroll: ScrollContainer
var _message_panel: PanelContainer
var _message_label: Label
var _message_confirm_btn: Button


# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _init(p_shop_id: String = "general_store") -> void:
	_shop_id = p_shop_id


func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_result = {}
	_shop_registry = ShopRegistry.new()
	_item_registry = ItemRegistry.new()
	_load_shop()
	_create_ui()
	_show_buy_tab()


# ═══════════════════════════════════════════════════════════════════════════════
# Shop Loading
# ═══════════════════════════════════════════════════════════════════════════════

func _load_shop() -> void:
	_shop_data = _shop_registry.get_shop(_shop_id)
	if not _shop_data:
		push_error("ShopPanel: 상점을 찾을 수 없음: " + _shop_id)


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 반투명 오버레이 (전체 화면)
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.6)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)
	
	# 상점 패널 (중앙)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(900, 550)
	_panel.position = Vector2(-450, -275)
	add_child(_panel)
	
	var main_vbox := VBoxContainer.new()
	_panel.add_child(main_vbox)
	
	# 헤더 (상점 이름 + 코인 표시)
	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 50)
	main_vbox.add_child(header)
	
	# 상점 이름
	_title_label = Label.new()
	if _shop_data:
		_title_label.text = tr(_shop_data.name_key)
	else:
		_title_label.text = _shop_id
	_title_label.add_theme_font_size_override("font_size", 28)
	_title_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	header.add_child(_title_label)
	
	# 코인 표시
	_coin_label = Label.new()
	_update_coin_display()
	_coin_label.add_theme_font_size_override("font_size", 18)
	_coin_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	header.add_child(_coin_label)
	
	# 구분선
	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 10)
	main_vbox.add_child(spacer1)
	
	# 탭 버튼
	_tab_container = HBoxContainer.new()
	_tab_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_tab_container.add_theme_constant_override("separation", 20)
	main_vbox.add_child(_tab_container)
	
	_buy_tab_btn = Button.new()
	_buy_tab_btn.text = "구매"
	_buy_tab_btn.toggle_mode = true
	_buy_tab_btn.custom_minimum_size = Vector2(120, 40)
	_buy_tab_btn.pressed.connect(_show_buy_tab)
	_tab_container.add_child(_buy_tab_btn)
	
	_sell_tab_btn = Button.new()
	_sell_tab_btn.text = "판매"
	_sell_tab_btn.toggle_mode = true
	_sell_tab_btn.custom_minimum_size = Vector2(120, 40)
	_sell_tab_btn.pressed.connect(_show_sell_tab)
	_tab_container.add_child(_sell_tab_btn)
	
	# 구분선
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	main_vbox.add_child(spacer2)
	
	# 아이템 목록 (스크롤)
	_item_scroll = ScrollContainer.new()
	_item_scroll.custom_minimum_size = Vector2(850, 350)
	main_vbox.add_child(_item_scroll)
	
	_item_list = VBoxContainer.new()
	_item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_scroll.add_child(_item_list)
	
	# 구분선
	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 15)
	main_vbox.add_child(spacer3)
	
	# 닫기 버튼
	var close_btn := Button.new()
	close_btn.text = "닫기"
	close_btn.custom_minimum_size = Vector2(150, 45)
	close_btn.pressed.connect(_on_close_pressed)
	main_vbox.add_child(close_btn)
	
	# 메시지 패널 (초기 숨김)
	_create_message_panel()


func _create_message_panel() -> void:
	_message_panel = PanelContainer.new()
	_message_panel.set_anchors_preset(Control.PRESET_CENTER)
	_message_panel.custom_minimum_size = Vector2(400, 100)
	_message_panel.position = Vector2(-200, -200)
	_message_panel.visible = false
	add_child(_message_panel)
	
	var content := VBoxContainer.new()
	_message_panel.add_child(content)
	
	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 18)
	content.add_child(_message_label)
	
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	content.add_child(spacer)
	
	_message_confirm_btn = Button.new()
	_message_confirm_btn.text = "확인"
	_message_confirm_btn.custom_minimum_size = Vector2(100, 35)
	content.add_child(_message_confirm_btn)


# ═══════════════════════════════════════════════════════════════════════════════
# Tab Management
# ═══════════════════════════════════════════════════════════════════════════════

func _show_buy_tab() -> void:
	_is_buy_tab = true
	_buy_tab_btn.button_pressed = true
	_sell_tab_btn.button_pressed = false
	_refresh_item_list()


func _show_sell_tab() -> void:
	_is_buy_tab = false
	_buy_tab_btn.button_pressed = false
	_sell_tab_btn.button_pressed = true
	_refresh_item_list()


func _refresh_item_list() -> void:
	# 기존 아이템 목록 제거
	for child in _item_list.get_children():
		child.queue_free()
	
	if _is_buy_tab:
		_show_buy_items()
	else:
		_show_sell_items()


# ═══════════════════════════════════════════════════════════════════════════════
# Item Display
# ═══════════════════════════════════════════════════════════════════════════════

func _show_buy_items() -> void:
	if not _shop_data:
		return
	
	var item_ids := _shop_data.get_item_ids()
	
	if item_ids.is_empty():
		var empty_label := Label.new()
		empty_label.text = "판매하는 아이템이 없습니다."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_item_list.add_child(empty_label)
		return
	
	for item_id in item_ids:
		var item := _item_registry.get_item(item_id)
		if not item:
			continue
		
		var price := _shop_data.get_sell_price(item_id)
		_create_item_row(item, price, true)


func _show_sell_items() -> void:
	if not _shop_data or not _shop_data.can_buy_from_player:
		var empty_label := Label.new()
		empty_label.text = "이 상점에서는 아이템을 판매할 수 없습니다."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_item_list.add_child(empty_label)
		return
	
	# 플레이어 인벤토리 아이템 표시
	var inventory := _get_player_inventory()
	
	if inventory.is_empty():
		var empty_label := Label.new()
		empty_label.text = "판매할 아이템이 없습니다."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_item_list.add_child(empty_label)
		return
	
	for item_id in inventory.keys():
		var item := _item_registry.get_item(item_id)
		if not item:
			continue
		
		var count: int = inventory[item_id]
		var price := _shop_data.get_buy_price(item_id)
		_create_item_row(item, price, false, count)


func _create_item_row(item: ItemData, price: int, is_buy: bool, count: int = 1) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 15)
	row.custom_minimum_size = Vector2(800, 50)
	_item_list.add_child(row)
	
	# 아이템 이름
	var name_label := Label.new()
	name_label.text = tr(item.name) if item.name.begins_with("ITEM_") else item.name
	name_label.custom_minimum_size = Vector2(200, 40)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", item.get_rarity_color())
	row.add_child(name_label)
	
	# 아이템 설명 (간략)
	var desc_label := Label.new()
	desc_label.text = tr(item.description) if item.description.begins_with("ITEM_") else item.description
	desc_label.custom_minimum_size = Vector2(350, 40)
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	row.add_child(desc_label)
	
	# 가격
	var price_label := Label.new()
	price_label.text = "🪙 %d" % price
	price_label.custom_minimum_size = Vector2(100, 40)
	price_label.add_theme_font_size_override("font_size", 14)
	price_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	row.add_child(price_label)
	
	# 수량 (판매 탭에서만)
	if not is_buy:
		var count_label := Label.new()
		count_label.text = "x%d" % count
		count_label.custom_minimum_size = Vector2(50, 40)
		count_label.add_theme_font_size_override("font_size", 14)
		row.add_child(count_label)
	
	# 구매/판매 버튼
	var action_btn := Button.new()
	action_btn.text = "구매" if is_buy else "판매"
	action_btn.custom_minimum_size = Vector2(80, 35)
	
	# 코인 부족 체크 (구매 시)
	if is_buy and GameManager.coin < price:
		action_btn.disabled = true
		action_btn.text = "코인 부족"
	
	action_btn.pressed.connect(_on_item_action.bind(item.id, is_buy, price))
	row.add_child(action_btn)


# ═══════════════════════════════════════════════════════════════════════════════
# Transaction Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_item_action(item_id: String, is_buy: bool, price: int) -> void:
	_show_transaction_confirm(item_id, is_buy, price)


func _show_transaction_confirm(item_id: String, is_buy: bool, price: int) -> void:
	var item := _item_registry.get_item(item_id)
	if not item:
		return
	
	var item_name := item.name
	var action_text := "구매" if is_buy else "판매"
	
	_message_label.text = "%s을(를) %d 코인에 %s하시겠습니까?" % [item_name, price, action_text]
	_message_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	
	# 기존 연결 해제
	if _message_confirm_btn.pressed.is_connected(_on_close_message):
		_message_confirm_btn.pressed.disconnect(_on_close_message)
	if _message_confirm_btn.pressed.is_connected(_execute_transaction):
		_message_confirm_btn.pressed.disconnect(_execute_transaction)
	
	_message_confirm_btn.pressed.connect(_execute_transaction.bind(item_id, is_buy, price))
	
	_message_panel.visible = true


func _execute_transaction(item_id: String, is_buy: bool, price: int) -> void:
	var success := false
	var message := ""
	
	if is_buy:
		# 구매
		if GameManager.coin >= price:
			GameManager.coin -= price
			GameManager.add_item_to_inventory(item_id)
			success = true
			message = "구매 완료!"
			
			# 결과에 기록
			if not _result.has("items_bought"):
				_result["items_bought"] = []
			_result["items_bought"].append({"id": item_id, "price": price})
		else:
			message = "코인이 부족합니다!"
	else:
		# 판매
		if _remove_item_from_inventory(item_id):
			GameManager.coin += price
			success = true
			message = "판매 완료!"
			
			# 결과에 기록
			if not _result.has("items_sold"):
				_result["items_sold"] = []
			_result["items_sold"].append({"id": item_id, "price": price})
		else:
			message = "아이템이 없습니다!"
	
	_show_transaction_result(message, success)


func _show_transaction_result(message: String, success: bool) -> void:
	_message_label.text = message
	_message_label.add_theme_color_override("font_color", 
		Color(0.4, 0.8, 0.4) if success else Color(0.9, 0.4, 0.4))
	
	# 기존 연결 해제
	if _message_confirm_btn.pressed.is_connected(_execute_transaction):
		_message_confirm_btn.pressed.disconnect(_execute_transaction)
	
	_message_confirm_btn.pressed.connect(_on_close_message)
	
	# 코인 표시 갱신
	_update_coin_display()
	
	# 아이템 목록 갱신
	_refresh_item_list()


func _on_close_message() -> void:
	_message_panel.visible = false


# ═══════════════════════════════════════════════════════════════════════════════
# Helper Methods
# ═══════════════════════════════════════════════════════════════════════════════

func _update_coin_display() -> void:
	_coin_label.text = "🪙 %d" % GameManager.coin


func _get_player_inventory() -> Dictionary:
	# GameManager에서 현재 캐릭터의 인벤토리 가져오기
	var state := GameManager.get_current_character_state()
	if state:
		return state.inventory
	return {}


func _remove_item_from_inventory(item_id: String) -> bool:
	return GameManager.remove_item_from_inventory(item_id)


func _on_close_pressed() -> void:
	closed.emit(_result)
	queue_free()
