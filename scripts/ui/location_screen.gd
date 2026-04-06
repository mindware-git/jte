class_name LocationScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# LocationScreen
# 리스트 기반 위치 탐험 화면
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)

## 표시할 위치 ID
@export var location_id: String = "cheongmok_village"

# 레지스트리
var _registry: LocationRegistry
var _location_data: LocationData

# UI 컴포넌트
var _name_label: Label
var _desc_label: Label
var _interact_container: VBoxContainer
var _travel_container: VBoxContainer

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _init(p_location_id: String = "cheongmok_village") -> void:
	location_id = p_location_id


func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_registry = LocationRegistry.new()
	_load_location()
	_create_ui()


# ═══════════════════════════════════════════════════════════════════════════════
# Location Loading
# ═══════════════════════════════════════════════════════════════════════════════

func _load_location() -> void:
	_location_data = _registry.get_location(location_id)
	if not _location_data:
		push_error("LocationScreen: 위치를 찾을 수 없음: " + location_id)


func setup(p_location_id: String) -> void:
	location_id = p_location_id
	if is_inside_tree():
		_load_location()
		_refresh_ui()


func get_location_name() -> String:
	if _location_data:
		return tr(_location_data.name_key)
	return location_id


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.05)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 메인 컨테이너
	var main_container := VBoxContainer.new()
	main_container.position = Vector2(100, 50)
	main_container.size = Vector2(1080, 600)
	add_child(main_container)
	
	# 위치 이름
	_name_label = Label.new()
	if _location_data:
		_name_label.text = tr(_location_data.name_key)
	else:
		_name_label.text = location_id
	_name_label.add_theme_font_size_override("font_size", 32)
	_name_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	main_container.add_child(_name_label)
	
	# 설명
	_desc_label = Label.new()
	if _location_data:
		_desc_label.text = tr(_location_data.desc_key)
	else:
		_desc_label.text = ""
	_desc_label.add_theme_font_size_override("font_size", 18)
	_desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	main_container.add_child(_desc_label)
	
	# 간격
	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 30)
	main_container.add_child(spacer1)
	
	# 상호작용 섹션
	var interact_section := VBoxContainer.new()
	main_container.add_child(interact_section)
	
	var interact_title := Label.new()
	interact_title.text = "상호작용"
	interact_title.add_theme_font_size_override("font_size", 20)
	interact_title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	interact_section.add_child(interact_title)
	
	_interact_container = VBoxContainer.new()
	interact_section.add_child(_interact_container)
	
	# 간격
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	main_container.add_child(spacer2)
	
	# 이동 섹션
	var travel_section := VBoxContainer.new()
	main_container.add_child(travel_section)
	
	var travel_title := Label.new()
	travel_title.text = "이동"
	travel_title.add_theme_font_size_override("font_size", 20)
	travel_title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	travel_section.add_child(travel_title)
	
	_travel_container = VBoxContainer.new()
	travel_section.add_child(_travel_container)
	
	# 버튼 생성
	_create_buttons()


func _create_buttons() -> void:
	# RNA 상태를 기반으로 동적 상호작용 조회
	var rna: Dictionary = GameManager.to_rna()
	var interactions := _registry.get_available_interactions(location_id, rna)
	for interact in interactions:
		var btn := Button.new()
		btn.text = tr(interact.name_key)
		btn.custom_minimum_size = Vector2(300, 40)
		btn.pressed.connect(_on_interaction_pressed.bind(interact))
		_interact_container.add_child(btn)
	
	# 상호작용이 없으면 안내
	if interactions.is_empty():
		var no_interact := Label.new()
		no_interact.text = "이곳에선 할 수 있는 것이 없다."
		no_interact.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_interact_container.add_child(no_interact)
	
	# 이동 버튼
	var connections := _registry.get_connections(location_id)
	for conn_id in connections:
		var conn_data := _registry.get_location(conn_id)
		if conn_data:
			var btn := Button.new()
			btn.text = "→ " + tr(conn_data.name_key)
			btn.custom_minimum_size = Vector2(300, 40)
			btn.pressed.connect(_on_travel_pressed.bind(conn_id))
			_travel_container.add_child(btn)


func _refresh_ui() -> void:
	# 기존 버튼 제거
	for child in _interact_container.get_children():
		child.queue_free()
	for child in _travel_container.get_children():
		child.queue_free()
	
	# 데이터 갱신
	if _location_data:
		_name_label.text = tr(_location_data.name_key)
		_desc_label.text = tr(_location_data.desc_key)
	
	# 버튼 재생성
	_create_buttons()


# ═══════════════════════════════════════════════════════════════════════════════
# Button Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_interaction_pressed(interact: InteractionData) -> void:
	# Godot 4 enum: NPC=0, SHOP=1, INVESTIGATE=2, STORY=3, BATTLE=4, PUZZLE=5
	match interact.type:
		0:  # NPC
			_on_npc_interaction(interact)
		1:  # SHOP
			_on_shop_interaction(interact)
		2:  # INVESTIGATE
			_on_investigate_interaction(interact)
		3:  # STORY
			_on_story_interaction(interact)
		4:  # BATTLE
			_on_battle_interaction(interact)
		5:  # PUZZLE
			_on_puzzle_interaction(interact)


func _on_travel_pressed(target_location_id: String) -> void:
	# 위치 이동
	location_id = target_location_id
	_load_location()
	_refresh_ui()
	
	# 게임 상태 업데이트
	GameManager.current_location = target_location_id


# ═══════════════════════════════════════════════════════════════════════════════
# Interaction Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_npc_interaction(interact: InteractionData) -> void:
	# DialogueScreen으로 전환
	var dialogue_screen := DialogueScreen.new(interact.target_id)
	transition_requested.emit(dialogue_screen)


func _show_choice_dialog(message: String, choices: Array[String], callback: Callable) -> void:
	# 다이얼로그 컨테이너
	var dialog := PanelContainer.new()
	dialog.set_anchors_preset(Control.PRESET_CENTER)
	dialog.custom_minimum_size = Vector2(400, 200)
	dialog.position = Vector2(360, 260)
	
	var vbox := VBoxContainer.new()
	dialog.add_child(vbox)
	
	# 메시지
	var msg_label := Label.new()
	msg_label.text = message
	msg_label.add_theme_font_size_override("font_size", 18)
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(msg_label)
	
	# 간격
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	# 선택 버튼들
	var btn_container := HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_container)
	
	for i in choices.size():
		var btn := Button.new()
		btn.text = choices[i]
		btn.custom_minimum_size = Vector2(100, 40)
		btn.pressed.connect(func() -> void:
			callback.call(i)
			dialog.queue_free()
		)
		btn_container.add_child(btn)
	
	add_child(dialog)


func _on_shop_interaction(interact: InteractionData) -> void:
	# TODO: ShopScreen 열기
	print("상점 상호작용: ", interact.target_id)


func _on_investigate_interaction(interact: InteractionData) -> void:
	# 조사/BOX 상호작용: 아이템 획득
	var item_id := interact.target_id if interact.target_id != "" else "회복약"
	
	# RNA에 아이템 추가
	GameManager.add_item_to_inventory(item_id)
	
	# 획득 메시지 표시
	print("아이템 획득: %s" % item_id)
	
	# TODO: 화면에 메시지 표시 (팝업 또는 토스트)


func _on_story_interaction(interact: InteractionData) -> void:
	var story_screen := StoryScreen.new()
	story_screen.chapter_id = interact.target_id
	transition_requested.emit(story_screen)


func _on_battle_interaction(interact: InteractionData) -> void:
	# BattleScreen으로 전환
	var battle_screen := BattleScreen.new(interact.target_id)
	transition_requested.emit(battle_screen)


func _on_puzzle_interaction(interact: InteractionData) -> void:
	# TODO: PuzzleScreen으로 전환
	print("퍼즐 상호작용: ", interact.target_id)
