class_name SaveSlotScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# SaveSlotScreen
# 저장/로드 슬롯 선택 화면
# ═══════════════════════════════════════════════════════════════════════════════

signal closed()
signal save_done(slot_index: int)
signal load_done(slot_index: int)

enum Mode { SAVE, LOAD }

var _mode: Mode = Mode.SAVE
var _slots: Array[SaveData] = []
var _confirm_popup: Control = null
var _pending_slot: int = -1

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_create_ui()


func setup(mode: Mode) -> void:
	_mode = mode
	_reload_slots()


func _reload_slots() -> void:
	_slots = SaveManager.get_all_slots(GameManager.save_slots)
	# UI 갱신은 _create_ui에서 처리됨

# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 배경 (반투명)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 메인 패널
	var panel := PanelContainer.new()
	panel.position = Vector2(290, 100)
	panel.size = Vector2(700, 500)
	add_child(panel)
	
	var content := VBoxContainer.new()
	panel.add_child(content)
	
	# 타이틀
	var title := Label.new()
	title.text = "💾 저장" if _mode == Mode.SAVE else "📂 불러오기"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	content.add_child(title)
	
	# 구분선
	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 20)
	content.add_child(spacer1)
	
	# 슬롯 버튼들
	_slots = SaveManager.get_all_slots(GameManager.save_slots)
	
	for slot in _slots:
		_create_slot_button(content, slot)
	
	# 구분선
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	content.add_child(spacer2)
	
	# 닫기 버튼
	var close_btn := Button.new()
	close_btn.text = "닫기"
	close_btn.custom_minimum_size = Vector2(200, 50)
	close_btn.pressed.connect(_on_close_pressed)
	content.add_child(close_btn)


func _create_slot_button(parent: VBoxContainer, slot: SaveData) -> void:
	var slot_panel := PanelContainer.new()
	parent.add_child(slot_panel)
	
	var slot_content := HBoxContainer.new()
	slot_content.add_theme_constant_override("separation", 20)
	slot_panel.add_child(slot_content)
	
	# 슬롯 이름
	var name_label := Label.new()
	name_label.text = slot.get_display_name()
	name_label.custom_minimum_size = Vector2(100, 0)
	name_label.add_theme_font_size_override("font_size", 18)
	slot_content.add_child(name_label)
	
	# 슬롯 정보
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot_content.add_child(info_vbox)
	
	var info_label := Label.new()
	if SaveManager.has_slot_data(slot.slot_index):
		info_label.text = slot.get_display_info()
		info_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	else:
		info_label.text = "- 빈 슬롯 -"
		info_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	info_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(info_label)
	
	var time_label := Label.new()
	time_label.text = slot.get_display_time()
	time_label.add_theme_font_size_override("font_size", 12)
	time_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	info_vbox.add_child(time_label)
	
	# 버튼
	var btn := Button.new()
	if _mode == Mode.SAVE:
		btn.text = "저장"
	else:
		if SaveManager.has_slot_data(slot.slot_index):
			btn.text = "로드"
		else:
			btn.text = "없음"
			btn.disabled = true
	btn.custom_minimum_size = Vector2(100, 50)
	btn.pressed.connect(_on_slot_pressed.bind(slot.slot_index))
	slot_content.add_child(btn)


# ═══════════════════════════════════════════════════════════════════════════════
# Event Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_slot_pressed(slot_index: int) -> void:
	if _mode == Mode.SAVE:
		# 저장 모드: 기존 데이터가 있으면 확인 팝업
		if SaveManager.has_slot_data(slot_index):
			_pending_slot = slot_index
			_show_confirm_popup("이미 저장된 데이터가 있습니다.\n덮어쓰시겠습니까?")
		else:
			_do_save(slot_index)
	else:
		# 로드 모드: 바로 로드
		_do_load(slot_index)


func _do_save(slot_index: int) -> void:
	var success := SaveManager.save_game(slot_index)
	if success:
		_show_message("저장 완료!")
		save_done.emit(slot_index)
		_reload_ui()


func _do_load(slot_index: int) -> void:
	var success := SaveManager.load_game(slot_index)
	if success:
		_show_message("로드 완료!")
		load_done.emit(slot_index)
		# 로드 후 화면 닫기
		await get_tree().create_timer(0.5).timeout
		queue_free()


func _show_confirm_popup(message: String) -> void:
	if _confirm_popup:
		_confirm_popup.queue_free()
	
	_confirm_popup = PanelContainer.new()
	_confirm_popup.position = Vector2(340, 250)
	_confirm_popup.size = Vector2(600, 200)
	add_child(_confirm_popup)
	
	var content := VBoxContainer.new()
	_confirm_popup.add_child(content)
	
	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	content.add_child(label)
	
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	content.add_child(spacer)
	
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 30)
	content.add_child(btn_row)
	
	var confirm_btn := Button.new()
	confirm_btn.text = "확인"
	confirm_btn.custom_minimum_size = Vector2(120, 50)
	confirm_btn.pressed.connect(_on_confirm_yes)
	btn_row.add_child(confirm_btn)
	
	var cancel_btn := Button.new()
	cancel_btn.text = "취소"
	cancel_btn.custom_minimum_size = Vector2(120, 50)
	cancel_btn.pressed.connect(_on_confirm_no)
	btn_row.add_child(cancel_btn)


func _on_confirm_yes() -> void:
	if _pending_slot >= 0:
		_do_save(_pending_slot)
		_pending_slot = -1
	
	if _confirm_popup:
		_confirm_popup.queue_free()
		_confirm_popup = null


func _on_confirm_no() -> void:
	_pending_slot = -1
	
	if _confirm_popup:
		_confirm_popup.queue_free()
		_confirm_popup = null


func _show_message(message: String) -> void:
	var popup := PanelContainer.new()
	popup.position = Vector2(390, 300)
	popup.size = Vector2(500, 80)
	add_child(popup)
	
	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	popup.add_child(label)
	
	await get_tree().create_timer(1.0).timeout
	popup.queue_free()


func _reload_ui() -> void:
	# 기존 UI 제거
	for child in get_children():
		child.queue_free()
	
	await get_tree().process_frame
	_create_ui()


func _on_close_pressed() -> void:
	closed.emit()
	queue_free()