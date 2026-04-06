extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# Battle
# 전투 씬 (RNA 기반)
# ═══════════════════════════════════════════════════════════════════════════════

signal battle_finished(victory: bool)

# RNA 데이터
var _rna: Dictionary = {}

# 전투 데이터
var _battle_data: BattleData

# 레지스트리
var _char_registry: CharacterRegistry
var _skill_registry: SkillRegistry

# UI 노드
@onready var _grid: HBoxContainer
@onready var _ally_container: VBoxContainer
@onready var _enemy_container: VBoxContainer
@onready var _action_panel: VBoxContainer
@onready var _info_panel: VBoxContainer
@onready var _turn_label: Label
@onready var _log_label: Label

# 선택 상태
var _selected_action: BattleData.ActionType = BattleData.ActionType.ATTACK
var _selected_target: BattleData.Unit = null
var _is_player_turn: bool = true


# ═══════════════════════════════════════════════════════════════════════════════
# Setup
# ═══════════════════════════════════════════════════════════════════════════════

func setup(rna: Dictionary) -> void:
	_rna = rna
	_char_registry = CharacterRegistry.new()
	_skill_registry = SkillRegistry.new()
	
	_create_ui()
	_setup_battle()


func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.02, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 메인 컨테이너
	var main := HBoxContainer.new()
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.position = Vector2(50, 50)
	main.size = Vector2(1180, 500)
	add_child(main)
	
	# 아군 영역
	_ally_container = VBoxContainer.new()
	_ally_container.custom_minimum_size = Vector2(200, 400)
	main.add_child(_ally_container)
	
	# 중앙 (전장 + 정보)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.add_child(center)
	
	# 턴 표시
	_turn_label = Label.new()
	_turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_turn_label.add_theme_font_size_override("font_size", 28)
	_turn_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	center.add_child(_turn_label)
	
	# 전장 그리드
	_grid = HBoxContainer.new()
	_grid.alignment = BoxContainer.ALIGNMENT_CENTER
	_grid.custom_minimum_size = Vector2(600, 300)
	center.add_child(_grid)
	
	# 로그
	_log_label = Label.new()
	_log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_log_label.add_theme_font_size_override("font_size", 16)
	_log_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	center.add_child(_log_label)
	
	# 적군 영역
	_enemy_container = VBoxContainer.new()
	_enemy_container.custom_minimum_size = Vector2(200, 400)
	main.add_child(_enemy_container)
	
	# 행동 패널
	_action_panel = VBoxContainer.new()
	_action_panel.position = Vector2(50, 550)
	_create_action_buttons()
	
	# 정보 패널
	_info_panel = VBoxContainer.new()
	_info_panel.position = Vector2(900, 550)


func _create_action_buttons() -> void:
	var actions := [
		{"type": BattleData.ActionType.ATTACK, "text": "⚔️ 공격"},
		{"type": BattleData.ActionType.SKILL, "text": "✨ 스킬"},
		{"type": BattleData.ActionType.DEFEND, "text": "🛡️ 방어"},
	]
	
	for action_info in actions:
		var btn := Button.new()
		btn.text = action_info.text
		btn.custom_minimum_size = Vector2(150, 50)
		btn.pressed.connect(_on_action_button_pressed.bind(action_info.type))
		_action_panel.add_child(btn)


# ═══════════════════════════════════════════════════════════════════════════════
# Battle Setup
# ═══════════════════════════════════════════════════════════════════════════════

func _setup_battle() -> void:
	_battle_data = BattleData.new()
	
	# 아군 생성
	var allies: Array[BattleData.Unit] = []
	var party_ids: Array = _rna.get("party", ["sanzang"])
	for char_id in party_ids:
		var unit := _create_unit_from_character(char_id, BattleData.Side.ALLY)
		allies.append(unit)
	
	# 적군 생성
	var enemies: Array[BattleData.Unit] = []
	var enemy_ids: Array = _rna.get("enemies", ["rock_demon"])
	for enemy_id in enemy_ids:
		var unit := _create_enemy_unit(enemy_id)
		enemies.append(unit)
	
	_battle_data.setup("battle_" + str(randi()), allies, enemies)
	_render_units()
	_update_turn_display()


func _create_unit_from_character(char_id: String, side: BattleData.Side) -> BattleData.Unit:
	var char_data := _char_registry.get_character(char_id)
	if not char_data:
		# 기본값
		var unit := BattleData.Unit.new(char_id, char_id, side)
		return unit
	
	var unit := BattleData.Unit.new(char_id, char_data.display_name, side)
	unit.max_hp = char_data.max_hp
	unit.hp = char_data.max_hp
	unit.max_mp = char_data.max_mp
	unit.mp = char_data.max_mp
	unit.attack = char_data.melee_power
	unit.defense = char_data.max_hp / 20  # 임시 방어력
	unit.speed = int(char_data.max_speed / 20)
	return unit


func _create_enemy_unit(enemy_id: String) -> BattleData.Unit:
	var unit := BattleData.Unit.new(enemy_id, tr("ENEMY_" + enemy_id.to_upper()), BattleData.Side.ENEMY)
	
	# 적 데이터 (임시 하드코딩)
	match enemy_id:
		"rock_demon":
			unit.max_hp = 80
			unit.hp = 80
			unit.attack = 12
			unit.defense = 5
			unit.speed = 6
		"fire_spirit":
			unit.max_hp = 60
			unit.hp = 60
			unit.attack = 15
			unit.defense = 2
			unit.speed = 12
		_:
			unit.max_hp = 50
			unit.hp = 50
			unit.attack = 8
			unit.defense = 3
			unit.speed = 8
	
	return unit


# ═══════════════════════════════════════════════════════════════════════════════
# Rendering
# ═══════════════════════════════════════════════════════════════════════════════

func _render_units() -> void:
	# 아군 렌더링
	for child in _ally_container.get_children():
		child.queue_free()
	
	for ally in _battle_data.allies:
		var unit_node := _create_unit_node(ally)
		_ally_container.add_child(unit_node)
	
	# 적군 렌더링
	for child in _enemy_container.get_children():
		child.queue_free()
	
	for enemy in _battle_data.enemies:
		var unit_node := _create_unit_node(enemy)
		_enemy_container.add_child(unit_node)


func _create_unit_node(unit: BattleData.Unit) -> Control:
	var container := PanelContainer.new()
	container.custom_minimum_size = Vector2(180, 120)
	
	var vbox := VBoxContainer.new()
	container.add_child(vbox)
	
	# 이름
	var name_label := Label.new()
	name_label.text = unit.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	if unit.is_dead:
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	elif unit.is_ally():
		name_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1))
	else:
		name_label.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	vbox.add_child(name_label)
	
	# HP 바
	var hp_bar := ProgressBar.new()
	hp_bar.max_value = unit.max_hp
	hp_bar.value = unit.hp
	hp_bar.custom_minimum_size = Vector2(160, 20)
	vbox.add_child(hp_bar)
	
	# HP 텍스트
	var hp_label := Label.new()
	hp_label.text = "HP: %d/%d" % [unit.hp, unit.max_hp]
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(hp_label)
	
	# MP 바
	if unit.max_mp > 0:
		var mp_bar := ProgressBar.new()
		mp_bar.max_value = unit.max_mp
		mp_bar.value = unit.mp
		mp_bar.custom_minimum_size = Vector2(160, 10)
		mp_bar.modulate = Color(0.3, 0.5, 1)
		vbox.add_child(mp_bar)
	
	# 클릭 가능 (적만)
	if unit.is_enemy() and not unit.is_dead:
		container.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed:
				_on_target_selected(unit)
		)
		container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	return container


func _update_turn_display() -> void:
	var actor := _battle_data.get_current_actor()
	if actor:
		_turn_label.text = "%s의 턴" % actor.display_name
		_is_player_turn = actor.is_ally()
		
		if not _is_player_turn:
			# 적 턴은 자동 진행
			await get_tree().create_timer(0.5).timeout
			_process_enemy_turn()


# ═══════════════════════════════════════════════════════════════════════════════
# Actions
# ═══════════════════════════════════════════════════════════════════════════════

func _on_action_button_pressed(action_type: BattleData.ActionType) -> void:
	if not _is_player_turn:
		return
	
	var actor := _battle_data.get_current_actor()
	if actor == null:
		return
	
	_selected_action = action_type
	
	match action_type:
		BattleData.ActionType.ATTACK:
			_log_label.text = "공격할 대상을 선택하세요."
		BattleData.ActionType.SKILL:
			_log_label.text = "스킬 준비 중..."
		BattleData.ActionType.DEFEND:
			_execute_action(null)


func _on_target_selected(target: BattleData.Unit) -> void:
	if not _is_player_turn:
		return
	
	_execute_action(target)


func _execute_action(target: BattleData.Unit) -> void:
	var actor := _battle_data.get_current_actor()
	if actor == null:
		return
	
	var action := BattleData.BattleAction.new()
	action.actor = actor
	action.action_type = _selected_action
	action.target = target
	
	_battle_data.execute_action(action)
	_log_label.text = _battle_data.battle_log[-1] if _battle_data.battle_log.size() > 0 else ""
	
	_battle_data.next_turn()
	_render_units()
	
	# 전투 종료 체크
	if _battle_data.check_battle_end():
		_end_battle()
		return
	
	_update_turn_display()


func _process_enemy_turn() -> void:
	var actor := _battle_data.get_current_actor()
	while actor and actor.is_ally():
		_battle_data.next_turn()
		actor = _battle_data.get_current_actor()
	
	if actor == null:
		return
	
	# 적 AI: 무작위 아군 공격
	var alive_allies: Array[BattleData.Unit] = []
	for ally in _battle_data.allies:
		if not ally.is_dead:
			alive_allies.append(ally)
	
	if alive_allies.is_empty():
		return
	
	var target := alive_allies[randi() % alive_allies.size()]
	
	var action := BattleData.BattleAction.new()
	action.actor = actor
	action.action_type = BattleData.ActionType.ATTACK
	action.target = target
	
	_battle_data.execute_action(action)
	_log_label.text = _battle_data.battle_log[-1] if _battle_data.battle_log.size() > 0 else ""
	
	_battle_data.next_turn()
	_render_units()
	
	# 전투 종료 체크
	if _battle_data.check_battle_end():
		_end_battle()
		return
	
	_update_turn_display()


func _end_battle() -> void:
	# 결과 표시
	var result_label := Label.new()
	result_label.text = "승리!" if _battle_data.is_victory else "패배..."
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 48)
	result_label.add_theme_color_override("font_color", 
		Color(0.9, 0.7, 0.2) if _battle_data.is_victory else Color(0.8, 0.3, 0.3))
	result_label.position = Vector2(400, 250)
	add_child(result_label)
	
	# 확인 버튼
	var confirm_btn := Button.new()
	confirm_btn.text = "확인"
	confirm_btn.position = Vector2(540, 400)
	confirm_btn.custom_minimum_size = Vector2(200, 50)
	confirm_btn.pressed.connect(func() -> void:
		battle_finished.emit(_battle_data.is_victory)
	)
	add_child(confirm_btn)
