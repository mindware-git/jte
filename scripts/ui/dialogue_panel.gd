class_name DialoguePanel
extends CanvasLayer

# ═══════════════════════════════════════════════════════════════════════════════
# DialoguePanel
# 오버레이 다이얼로그 패널
# 기존 화면 위에 표시되는 대화 UI
# ═══════════════════════════════════════════════════════════════════════════════

signal dialogue_finished(result: Dictionary)

## NPC ID
var _npc_id: String = "old_monk"

## 레지스트리
var _registry: NPCRegistry

## 현재 대화
var _current_dialogue: DialogueData
var _npc_data: NPCData

## 결과 데이터
var _result: Dictionary = {}

## UI 컴포넌트
var _container: Control
var _overlay: ColorRect
var _panel: PanelContainer
var _name_label: Label
var _text_label: Label
var _choices_container: VBoxContainer
var _item_message: PanelContainer

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _init(p_npc_id: String = "old_monk") -> void:
	_npc_id = p_npc_id
	layer = 10  # 최상위 레이어


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_tree().paused = true
	
	_result = {}
	_registry = NPCRegistry.new()
	_load_npc()
	_create_ui()
	_show_dialogue()


# ═══════════════════════════════════════════════════════════════════════════════
# NPC Loading
# ═══════════════════════════════════════════════════════════════════════════════

func _load_npc() -> void:
	_npc_data = _registry.get_npc(_npc_id)
	if not _npc_data:
		push_error("DialoguePanel: NPC를 찾을 수 없음: " + _npc_id)
		return
	
	# RNA 상태로 대화 로드
	var rna := GameManager.to_rna()
	_current_dialogue = _registry.get_dialogue(_npc_id, rna)


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 최상위 컨테이너 (CanvasLayer 안에 Control 필요)
	_container = Control.new()
	_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_container.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_container)
	
	# 반투명 오버레이 (전체 화면)
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.6)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_container.add_child(_overlay)
	
	# 대화 패널 (중앙)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(1000, 300)
	_container.add_child(_panel)
	
	var vbox := VBoxContainer.new()
	_panel.add_child(vbox)
	
	# NPC 이름
	_name_label = Label.new()
	if _npc_data:
		_name_label.text = tr(_npc_data.display_name_key)
	else:
		_name_label.text = _npc_id
	_name_label.add_theme_font_size_override("font_size", 24)
	_name_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	vbox.add_child(_name_label)
	
	# 대사
	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_text_label.custom_minimum_size = Vector2(950, 100)
	_text_label.add_theme_font_size_override("font_size", 18)
	_text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(_text_label)
	
	# 간격
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	# 선택지 컨테이너
	_choices_container = VBoxContainer.new()
	vbox.add_child(_choices_container)
	
	# 아이템 획득 메시지 (초기 숨김)
	_create_item_message()


func _create_item_message() -> void:
	_item_message = PanelContainer.new()
	_item_message.set_anchors_preset(Control.PRESET_CENTER)
	_item_message.custom_minimum_size = Vector2(400, 80)
	_item_message.visible = false
	_container.add_child(_item_message)
	
	var label := Label.new()
	label.name = "MessageLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))
	_item_message.add_child(label)


# ═══════════════════════════════════════════════════════════════════════════════
# Dialogue Display
# ═══════════════════════════════════════════════════════════════════════════════

func _show_dialogue() -> void:
	if not _current_dialogue:
		_close()
		return
	
	# 대사 표시
	_text_label.text = tr(_current_dialogue.text_key)
	
	# 선택지 표시
	_show_choices(_current_dialogue.choices)


func _show_choices(choices: Array[DialogueData.DialogueChoice]) -> void:
	# 기존 선택지 제거
	for child in _choices_container.get_children():
		child.queue_free()
	
	if choices.is_empty():
		# 선택지가 없으면 자동 종료
		await get_tree().create_timer(1.0).timeout
		_close()
		return
	
	for i in choices.size():
		var choice := choices[i]
		var btn := Button.new()
		btn.text = tr(choice.text_key)
		btn.custom_minimum_size = Vector2(300, 40)
		btn.pressed.connect(_on_choice_selected.bind(choice))
		_choices_container.add_child(btn)


func _on_choice_selected(choice: DialogueData.DialogueChoice) -> void:
	# 액션 실행
	_execute_actions(choice.actions)
	
	# 다음 대화로 이동
	if choice.next_dialogue_id != "":
		# TODO: 대화 체인 로드
		_close()
	else:
		_close()


func _execute_actions(actions: Array[DialogueData.DialogueAction]) -> void:
	for action in actions:
		match action.action_type:
			DialogueData.ActionType.GIVE_ITEM:
				var item_id: String = action.target_id
				var count: int = action.value if action.value is int else 1
				GameManager.add_item_to_inventory(item_id, count)
				print("아이템 획득: %s x%d" % [item_id, count])
				
				# 결과에 저장
				if not _result.has("items_acquired"):
					_result["items_acquired"] = []
				_result["items_acquired"].append({"id": item_id, "count": count})
				
				# 아이템 획득 메시지 표시
				_show_item_acquired(item_id, count)
			
			DialogueData.ActionType.SET_FLAG:
				GameManager.set_flag(action.target_id, action.value)
				print("플래그 설정: %s = %s" % [action.target_id, str(action.value)])
				_result["flag_%s" % action.target_id] = action.value
			
			DialogueData.ActionType.HEAL:
				var amount: int = action.value if action.value is int else 0
				GameManager.heal_player(amount)
				print("HP 회복: %d" % amount)
				_result["heal_amount"] = amount
			
			DialogueData.ActionType.TAKE_MONEY:
				var amount: int = action.value if action.value is int else 0
				GameManager.coin -= amount
				print("골드 차감: %d" % amount)
				_result["money_taken"] = amount
			
			DialogueData.ActionType.END_DIALOGUE:
				pass  # 대화 종료는 별도 처리


func _show_item_acquired(item_id: String, count: int) -> void:
	# 아이템 이름 가져오기 (TODO: ItemRegistry에서)
	var item_name := item_id
	
	var label: Label = _item_message.get_node("MessageLabel")
	if label:
		label.text = "✨ %s x%d을(를) 얻었다!" % [item_name, count]
	
	_item_message.visible = true
	
	# 2초 후 숨기기
	await get_tree().create_timer(2.0).timeout
	_item_message.visible = false


func _close() -> void:
	get_tree().paused = false
	dialogue_finished.emit(_result)
	queue_free()
