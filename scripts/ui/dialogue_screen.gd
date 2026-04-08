class_name DialogueScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# DialogueScreen
# 대화 화면
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)
signal dialogue_finished()

## NPC ID
@export var npc_id: String = "old_monk"

## 복귀할 화면 (null이면 LocationScreen으로)
var _return_screen: Control = null

# 레지스트리
var _registry: NPCRegistry

# 현재 대화
var _current_dialogue: DialogueData
var _npc_data: NPCData

# UI 컴포넌트
var _name_label: Label
var _text_label: Label
var _choices_container: VBoxContainer


# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _init(p_npc_id: String = "old_monk", p_return_screen: Control = null) -> void:
	npc_id = p_npc_id
	_return_screen = p_return_screen


func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_registry = NPCRegistry.new()
	_load_npc()
	_create_ui()
	_show_dialogue()


# ═══════════════════════════════════════════════════════════════════════════════
# NPC Loading
# ═══════════════════════════════════════════════════════════════════════════════

func _load_npc() -> void:
	_npc_data = _registry.get_npc(npc_id)
	if not _npc_data:
		push_error("DialogueScreen: NPC를 찾을 수 없음: " + npc_id)
		return
	
	# RNA 상태로 대화 로드
	var rna := GameManager.to_rna()
	_current_dialogue = _registry.get_dialogue(npc_id, rna)


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 반투명 배경
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 대화 패널
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.custom_minimum_size = Vector2(1000, 300)
	panel.position = Vector2(140, 350)
	add_child(panel)
	
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	
	# NPC 이름
	_name_label = Label.new()
	if _npc_data:
		_name_label.text = tr(_npc_data.display_name_key)
	else:
		_name_label.text = npc_id
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


# ═══════════════════════════════════════════════════════════════════════════════
# Dialogue Display
# ═══════════════════════════════════════════════════════════════════════════════

func _show_dialogue() -> void:
	if not _current_dialogue:
		_end_dialogue()
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
		_end_dialogue()
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
		_end_dialogue()
	else:
		_end_dialogue()


func _execute_actions(actions: Array[DialogueData.DialogueAction]) -> void:
	for action in actions:
		match action.action_type:
			DialogueData.ActionType.GIVE_ITEM:
				var count: int = action.value if action.value is int else 1
				GameManager.add_item_to_inventory(action.target_id, count)
				print("아이템 획득: %s x%d" % [action.target_id, count])
			
			DialogueData.ActionType.SET_FLAG:
				GameManager.set_flag(action.target_id, action.value)
				print("플래그 설정: %s = %s" % [action.target_id, str(action.value)])
			
			DialogueData.ActionType.HEAL:
				var amount: int = action.value if action.value is int else 0
				GameManager.heal_player(amount)
				print("HP 회복: %d" % amount)
			
			DialogueData.ActionType.START_BATTLE:
				var battle_scene := preload("res://scenes/battle/battle.tscn").instantiate()
				var rna := {
					"party": GameManager.party_members,
					"enemies": [action.target_id],
					"flags": {}
				}
				battle_scene.setup(rna)
				battle_scene.battle_finished.connect(_on_battle_finished)
				add_child(battle_scene)
				return
			
			DialogueData.ActionType.END_DIALOGUE:
				pass  # 대화 종료는 별도 처리


func _on_battle_finished(_victory: bool) -> void:
	# 전투 종료 후 대화 종료
	_end_dialogue()


func _end_dialogue() -> void:
	dialogue_finished.emit()
	
	# 복귀 화면이 있으면 그곳으로, 없으면 LocationScreen으로
	if _return_screen and is_instance_valid(_return_screen):
		transition_requested.emit(_return_screen)
	else:
		var loc_screen := LocationScreen.new(GameManager.current_location)
		transition_requested.emit(loc_screen)
