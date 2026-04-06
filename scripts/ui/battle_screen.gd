class_name BattleScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# BattleScreen
# Button MVP 전투 화면 (칸 기반 턴제)
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)

## 적 ID
@export var enemy_id: String = "rock_demon"

# 전투 데이터
var _battle_data: BattleData = null

# UI 컴포넌트
var _ally_panel: VBoxContainer
var _enemy_panel: VBoxContainer
var _log_label: Label
var _action_panel: VBoxContainer
var _turn_label: Label

# 선택 상태
var _selected_action: BattleData.ActionType = BattleData.ActionType.ATTACK
var _selected_target: BattleData.Unit = null


# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _init(p_enemy_id: String = "rock_demon") -> void:
	enemy_id = p_enemy_id


func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_setup_battle()
	_create_ui()
	_update_ui()


# ═══════════════════════════════════════════════════════════════════════════════
# Battle Setup
# ═══════════════════════════════════════════════════════════════════════════════

func _setup_battle() -> void:
	_battle_data = BattleData.new()
	
	# 아군 생성 (파티에서)
	var allies: Array[BattleData.Unit] = []
	for member_id in GameManager.party_members:
		var unit := _create_unit_from_party(member_id)
		allies.append(unit)
	
	# 적군 생성
	var enemies: Array[BattleData.Unit] = []
	var enemy := _create_enemy_unit(enemy_id)
	enemies.append(enemy)
	
	_battle_data.setup("battle_" + enemy_id, allies, enemies)


func _create_unit_from_party(member_id: String) -> BattleData.Unit:
	var unit := BattleData.Unit.new(member_id, tr("CHAR_" + member_id.to_upper()), BattleData.Side.ALLY)
	unit.max_hp = 100
	unit.hp = GameManager.player_hp
	unit.max_mp = 50
	unit.mp = GameManager.player_mp
	unit.attack = GameManager.player_attack
	unit.defense = 5
	unit.speed = 10
	return unit


func _create_enemy_unit(p_enemy_id: String) -> BattleData.Unit:
	var unit := BattleData.Unit.new(p_enemy_id, tr("ENEMY_" + p_enemy_id.to_upper()), BattleData.Side.ENEMY)
	
	# 적 데이터 (임시 하드코딩)
	match p_enemy_id:
		"rock_demon":
			unit.max_hp = 50
			unit.hp = 50
			unit.attack = 8
			unit.defense = 3
			unit.speed = 5
		"fire_spirit":
			unit.max_hp = 40
			unit.hp = 40
			unit.attack = 12
			unit.defense = 2
			unit.speed = 15
		_:
			unit.max_hp = 30
			unit.hp = 30
			unit.attack = 5
			unit.defense = 2
			unit.speed = 8
	
	return unit


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.05, 0.15)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 메인 컨테이너
	var main := HBoxContainer.new()
	main.position = Vector2(50, 50)
	main.size = Vector2(1180, 500)
	add_child(main)
	
	# 아군 패널
	_ally_panel = VBoxContainer.new()
	main.add_child(_ally_panel)
	
	# 중앙 (전투 로그)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.add_child(center)
	
	_turn_label = Label.new()
	_turn_label.add_theme_font_size_override("font_size", 24)
	_turn_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	center.add_child(_turn_label)
	
	_log_label = Label.new()
	_log_label.add_theme_font_size_override("font_size", 16)
	_log_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_log_label.custom_minimum_size = Vector2(400, 200)
	center.add_child(_log_label)
	
	# 적군 패널
	_enemy_panel = VBoxContainer.new()
	main.add_child(_enemy_panel)
	
	# 행동 패널
	_action_panel = VBoxContainer.new()
	_action_panel.position = Vector2(50, 550)
	_create_action_buttons()


func _create_action_buttons() -> void:
	var actions := [
		{"type": BattleData.ActionType.ATTACK, "text": "공격"},
		{"type": BattleData.ActionType.SKILL, "text": "스킬"},
		{"type": BattleData.ActionType.DEFEND, "text": "방어"},
	]
	
	for action_info in actions:
		var btn := Button.new()
		btn.text = action_info.text
		btn.custom_minimum_size = Vector2(150, 50)
		btn.pressed.connect(_on_action_button_pressed.bind(action_info.type))
		_action_panel.add_child(btn)


# ═══════════════════════════════════════════════════════════════════════════════
# UI Update
# ═══════════════════════════════════════════════════════════════════════════════

func _update_ui() -> void:
	# 아군 표시
	for child in _ally_panel.get_children():
		child.queue_free()
	
	for ally in _battle_data.allies:
		var label := Label.new()
		label.text = "%s\nHP: %d/%d" % [ally.display_name, ally.hp, ally.max_hp]
		label.add_theme_font_size_override("font_size", 18)
		if ally.is_dead:
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		else:
			label.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
		_ally_panel.add_child(label)
	
	# 적군 표시
	for child in _enemy_panel.get_children():
		child.queue_free()
	
	for enemy in _battle_data.enemies:
		var btn := Button.new()
		btn.text = "%s\nHP: %d/%d" % [enemy.display_name, enemy.hp, enemy.max_hp]
		btn.custom_minimum_size = Vector2(200, 80)
		if enemy.is_dead:
			btn.disabled = true
		else:
			btn.pressed.connect(_on_target_selected.bind(enemy))
		_enemy_panel.add_child(btn)
	
	# 턴 표시
	var actor := _battle_data.get_current_actor()
	if actor:
		_turn_label.text = "%s의 턴" % actor.display_name
	
	# 로그 표시
	if _battle_data.battle_log.size() > 0:
		_log_label.text = _battle_data.battle_log[-1]


# ═══════════════════════════════════════════════════════════════════════════════
# Button Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_action_button_pressed(action_type: BattleData.ActionType) -> void:
	var actor := _battle_data.get_current_actor()
	if actor == null or actor.is_enemy():
		return
	
	_selected_action = action_type
	
	if action_type == BattleData.ActionType.DEFEND:
		# 방어는 즉시 실행
		_execute_player_action(null)
	elif action_type == BattleData.ActionType.ATTACK:
		# 대상 선택 대기
		_log_label.text = "공격할 대상을 선택하세요."
	elif action_type == BattleData.ActionType.SKILL:
		# TODO: 스킬 선택 UI
		_log_label.text = "스킬 준비 중..."


func _on_target_selected(target: BattleData.Unit) -> void:
	var actor := _battle_data.get_current_actor()
	if actor == null or actor.is_enemy():
		return
	
	_execute_player_action(target)


func _execute_player_action(target: BattleData.Unit) -> void:
	var actor := _battle_data.get_current_actor()
	if actor == null:
		return
	
	var action := BattleData.BattleAction.new()
	action.actor = actor
	action.action_type = _selected_action
	action.target = target
	
	_battle_data.execute_action(action)
	_battle_data.next_turn()
	
	_update_ui()
	
	# 전투 종료 체크
	if _battle_data.check_battle_end():
		_end_battle()
		return
	
	# 적 턴 처리
	_process_enemy_turn()


func _process_enemy_turn() -> void:
	await get_tree().create_timer(0.5).timeout
	
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
	_battle_data.next_turn()
	
	_update_ui()
	
	# 전투 종료 체크
	if _battle_data.check_battle_end():
		_end_battle()


func _end_battle() -> void:
	# 결과 화면으로 전환
	var result := BattleResultScreen.new()
	result.setup(_battle_data.is_victory, _battle_data.battle_log)
	transition_requested.emit(result)
