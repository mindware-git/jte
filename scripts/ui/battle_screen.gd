class_name BattleScreen
extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# BattleScreen
# 전투 화면 컨트롤러 (GDScript 동적 생성)
# ═══════════════════════════════════════════════════════════════════════════════

signal finished()

# ═══════════════════════════════════════════════════════════════════════════════
# 전투 UI 상태 머신 (BATTLE_ARCHITECTURE.md 참조)
# ═══════════════════════════════════════════════════════════════════════════════

enum BattleState {
	IDLE,           # 턴 시작, 캐릭터 대기
	ACTION_MENU,    # 행동 선택
	LIST_MENU,      # 아이템/스킬 리스트 선택 중
	CAST,           # 가용 범위 표시 (흰색)
	EFFECT,         # 효과 범위 표시 + Confirm 창
	ACTION          # 애니메이션 실행 중
}

var _state: BattleState = BattleState.IDLE

func _set_state(new_state: BattleState) -> void:
	_state = new_state
	print("[BattleState] 상태 변경: ", BattleState.keys()[_state])

# 위치 및 적 ID
var _location_id: String = "bluewood_village"
var _enemy_id: String = "rock_demon"

# RNA 데이터
var _rna: Dictionary = {}

# 타일맵 배경
var _tilemap_instance: Node2D = null

# 전투 데이터
var _battle_data: BattleData

# 레지스트리
var _char_registry: CharacterRegistry
var _skill_registry: SkillRegistry
var _item_registry: ItemRegistry

# AI
var _enemy_ai: EnemyAI

# 캐릭터 노드
var _character_nodes: Dictionary = {}
var _characters_parent: Node2D = null

# UI 노드
var _ui_layer: CanvasLayer = null
var _turn_label: Label
var _log_label: Label
var _action_menu: VBoxContainer
var _battle_grid: TacticGrid = null
var _confirm_dialog: Control = null
var _confirm_label: Label = null
var _confirm_action_callback: Callable = Callable()
var _item_menu: VBoxContainer = null
var _skill_menu: VBoxContainer = null
var _cancel_action_btn: Button = null

# 카메라
var _camera: Camera2D = null

# 선택 상태
var _selected_actor: BattleData.Unit = null
var _selected_action: BattleData.ActionType = BattleData.ActionType.ATTACK
var _selected_target: BattleData.Unit = null
var _selected_skill_id: String = ""
var _selected_item_id: String = ""
var _is_player_turn: bool = true

# 2단계 범위 시스템 상태
var _selected_cast_pos: Vector2i = Vector2i(-1, -1)  # 시전 중심점

# 범위 색상 상수
const RANGE_COLOR_MOVE := Color(0.3, 0.7, 1.0, 0.3)    # 파란색 (이동)
const RANGE_COLOR_CAST := Color(1.0, 1.0, 1.0, 0.3)    # 흰색 (가용 범위)
const RANGE_COLOR_ATTACK := Color(1.0, 0.3, 0.3, 0.3)   # 빨간색 (공격/적 대상)
const RANGE_COLOR_ALLY := Color(0.3, 1.0, 0.5, 0.3)     # 녹색 (아군 대상)

# 배치 좌표 (64x64 그리드 기준)
const ALLY_START_POS := Vector2(192, 384)   # 그리드 (3, 6)
const ALLY_SPACING := Vector2(64, 0)        # 64픽셀 간격
const ENEMY_START_POS := Vector2(768, 384)  # 그리드 (12, 6)
const ENEMY_SPACING := Vector2(64, 0)       # 64픽셀 간격


# ═══════════════════════════════════════════════════════════════════════════════
# Setup
# ═══════════════════════════════════════════════════════════════════════════════

func setup(rna: Dictionary) -> void:
	print("=== BattleScreen.setup() ===")
	print("RNA 받음: ", rna)
	
	_rna = rna
	_char_registry = CharacterRegistry.new()
	_skill_registry = SkillRegistry.new()
	_item_registry = ItemRegistry.new()
	
	# GameManager에서 전투 정보 가져오기
	_location_id = GameManager.current_location
	_enemy_id = GameManager.enemy_id
	
	print("location_id: ", _location_id)
	print("enemy_id: ", _enemy_id)
	print("party_members: ", GameManager.party_members)
	
	# 타일맵 배경 로드
	_load_tilemap_background()
	
	_create_ui()
	_setup_battle()


## 전투 설정 (위치 ID, 적 ID 포함)
func setup_battle(location_id: String, enemy_id: String, rna: Dictionary) -> void:
	_location_id = location_id
	_enemy_id = enemy_id
	_rna = rna
	
	_char_registry = CharacterRegistry.new()
	_skill_registry = SkillRegistry.new()
	_item_registry = ItemRegistry.new()
	
	# 타일맵 배경 로드
	_load_tilemap_background()
	
	_create_ui()
	_setup_battle()


# ═══════════════════════════════════════════════════════════════════════════════
# Tilemap Background
# ═══════════════════════════════════════════════════════════════════════════════

func _load_tilemap_background() -> void:
	# 기존 타일맵 제거
	if _tilemap_instance:
		_tilemap_instance.queue_free()
		_tilemap_instance = null
	
	# 타일맵 씬 경로 생성
	var scene_path := "res://scenes/locations/%s.tscn" % _location_id
	
	# 씬 존재 확인 후 로드
	if ResourceLoader.exists(scene_path):
		var scene_resource := load(scene_path)
		if scene_resource and scene_resource is PackedScene:
			_tilemap_instance = scene_resource.instantiate()
			add_child(_tilemap_instance)
			move_child(_tilemap_instance, 0)


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# CanvasLayer 생성 (UI 전용)
	_ui_layer = CanvasLayer.new()
	add_child(_ui_layer)
	
	# 배경 (반투명)
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.02, 0.08, 0.5)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 캐릭터 부모 노드
	_characters_parent = Node2D.new()
	add_child(_characters_parent)
	
	# 턴 표시 (상단) - CanvasLayer에 추가하여 카메라 영향 없음
	_turn_label = Label.new()
	_turn_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_turn_label.offset_top = 30
	_turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_turn_label.add_theme_font_size_override("font_size", 28)
	_turn_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	_ui_layer.add_child(_turn_label)
	
	# 로그 표시 (하단)
	_log_label = Label.new()
	_log_label.position = Vector2(312, 650)
	_log_label.size = Vector2(600, 30)
	_log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_log_label.add_theme_font_size_override("font_size", 16)
	_log_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	add_child(_log_label)
	
	# 행동 메뉴 (초기엔 숨김)
	_create_action_menu()
	
	# 범용 확인 다이얼로그 생성
	_create_confirm_dialog()
	
	# 아이템 메뉴 생성
	_create_item_menu()
	
	# 스킬 메뉴 생성
	_create_skill_menu()

	# 선택 취소 버튼 생성
	_create_cancel_action_button()
	
	# 카메라 생성
	_create_camera()

func _create_cancel_action_button() -> void:
	_cancel_action_btn = Button.new()
	_cancel_action_btn.text = "← 뒤로"
	_cancel_action_btn.custom_minimum_size = Vector2(100, 40)
	_cancel_action_btn.position = Vector2(500, 520)
	_cancel_action_btn.visible = false
	_cancel_action_btn.add_theme_font_size_override("font_size", 18)
	_cancel_action_btn.pressed.connect(_on_back_button_pressed)
	_ui_layer.add_child(_cancel_action_btn)

func _show_cancel_action_button() -> void:
	if _cancel_action_btn:
		_cancel_action_btn.visible = true

func _hide_cancel_action_button() -> void:
	if _cancel_action_btn:
		_cancel_action_btn.visible = false

## 뒤로 가기 버튼 (action menu로 돌아가기)
func _on_back_button_pressed() -> void:
	_hide_battle_grid()
	_hide_confirm_dialog()
	_hide_skill_menu()
	_hide_item_menu()
	_hide_cancel_action_button()
	
	_selected_target = null
	_selected_item_id = ""
	_selected_skill_id = ""
	
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	_set_state(BattleState.ACTION_MENU)
	_log_label.text = "행동을 선택하세요."
	_show_action_menu()


## 기존 호환성 유지
func _on_cancel_action_pressed() -> void:
	_on_back_button_pressed()


# ═══════════════════════════════════════════════════════════════════════════════
# Camera
# ═══════════════════════════════════════════════════════════════════════════════

func _create_camera() -> void:
	_camera = Camera2D.new()
	_camera.enabled = true
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 5.0
	_camera.zoom = Vector2(1, 1)
	add_child(_camera)


## 카메라를 지정 위치로 부드럽게 이동
func _move_camera_to(target_pos: Vector2, duration: float = 0.5) -> void:
	if _camera == null:
		return
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_camera, "position", target_pos, duration)


## 카메라를 캐릭터 위치로 이동
func _move_camera_to_unit(unit: BattleData.Unit) -> void:
	if unit == null:
		return
	
	var target_pos := _grid_to_pixel(unit.grid_pos)
	_move_camera_to(target_pos)


## 카메라를 지정 그리드 위치로 이동
func _move_camera_to_grid(grid_pos: Vector2i) -> void:
	var target_pos := _grid_to_pixel(grid_pos)
	_move_camera_to(target_pos)


func _create_action_menu() -> void:
	_action_menu = VBoxContainer.new()
	_action_menu.visible = false
	_action_menu.modulate = Color(1, 1, 1, 0.95)
	_ui_layer.add_child(_action_menu)
	
	# 배경 패널
	var panel := PanelContainer.new()
	_action_menu.add_child(panel)
	
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	
	# 행동 버튼들
	var actions := [
		{"type": BattleData.ActionType.MOVE, "text": "👟 이동"},
		{"type": BattleData.ActionType.ATTACK, "text": "⚔️ 공격"},
		{"type": BattleData.ActionType.SKILL, "text": "✨ 스킬"},
		{"type": BattleData.ActionType.ITEM, "text": "🎒 아이템"},
		{"type": BattleData.ActionType.END_TURN, "text": "⏭️ 턴 종료"},
	]
	
	for action_info in actions:
		var btn := Button.new()
		btn.text = action_info.text
		btn.custom_minimum_size = Vector2(120, 40)
		btn.pressed.connect(_on_action_menu_selected.bind(action_info.type))
		vbox.add_child(btn)
	
	# 취소 버튼 없음 - action menu는 첫 단계이므로 취소할 필요 없음


func _show_action_menu() -> void:
	_action_menu.position = Vector2(100, 500)
	_action_menu.visible = true


func _hide_action_menu() -> void:
	_action_menu.visible = false
	_selected_actor = null


# ═══════════════════════════════════════════════════════════════════════════════
# Unified Confirm Dialog (범용 확인 다이얼로그)
# ═══════════════════════════════════════════════════════════════════════════════

func _create_confirm_dialog() -> void:
	_confirm_dialog = Control.new()
	_confirm_dialog.visible = false
	add_child(_confirm_dialog)
	
	# 배경
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(220, 100)
	_confirm_dialog.add_child(panel)
	
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	
	# 안내 문구 (동적으로 변경)
	_confirm_label = Label.new()
	_confirm_label.text = "확인하시겠습니까?"
	_confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_confirm_label)
	
	# 버튼 컨테이너
	var btn_container := HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_container)
	
	# 확인 버튼
	var confirm_btn := Button.new()
	confirm_btn.text = "확인"
	confirm_btn.custom_minimum_size = Vector2(80, 36)
	confirm_btn.pressed.connect(_on_confirm_accepted)
	btn_container.add_child(confirm_btn)
	
	# 취소 버튼
	var cancel_btn := Button.new()
	cancel_btn.text = "취소"
	cancel_btn.custom_minimum_size = Vector2(80, 36)
	cancel_btn.pressed.connect(_on_confirm_cancelled)
	btn_container.add_child(cancel_btn)


func _create_item_menu() -> void:
	_item_menu = VBoxContainer.new()
	_item_menu.visible = false
	_item_menu.modulate = Color(1, 1, 1, 0.95)
	add_child(_item_menu)
	
	# 배경 패널
	var panel := PanelContainer.new()
	_item_menu.add_child(panel)
	
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	
	# 아이템 목록 (레지스트리에서 가져오기)
	# var all_items := _item_registry.get_all_items()
	# for item: ItemData in all_items:
	# 	var btn := Button.new()
	# 	btn.text = "%s" % item.name
	# 	btn.custom_minimum_size = Vector2(120, 40)
	# 	btn.pressed.connect(_on_item_selected.bind(item.id))
	# 	vbox.add_child(btn)
	
	# 취소 버튼
	var cancel_btn := Button.new()
	cancel_btn.text = "✖ 취소"
	cancel_btn.custom_minimum_size = Vector2(120, 40)
	cancel_btn.pressed.connect(_on_cancel_action_pressed)
	vbox.add_child(cancel_btn)


func _show_item_menu() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	_item_menu.position = _action_menu.position  # 행동 메뉴 위치 재사용
	_item_menu.visible = true
	move_child(_item_menu, get_child_count() - 1)  # 최상단으로


func _hide_item_menu() -> void:
	_item_menu.visible = false


func _create_skill_menu() -> void:
	_skill_menu = VBoxContainer.new()
	_skill_menu.visible = false
	_skill_menu.modulate = Color(1, 1, 1, 0.95)
	_ui_layer.add_child(_skill_menu)
	
	# 배경 패널
	var panel := PanelContainer.new()
	_skill_menu.add_child(panel)
	
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	
	# 스킬 버튼은 _show_skill_menu()에서 동적으로 생성
	# 취소 버튼만 미리 생성
	var cancel_btn := Button.new()
	cancel_btn.text = "✖ 취소"
	cancel_btn.custom_minimum_size = Vector2(140, 40)
	cancel_btn.pressed.connect(_on_cancel_action_pressed)
	vbox.add_child(cancel_btn)


func _show_skill_menu() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	print(">>> _show_skill_menu() - actor.id: ", _selected_actor.id)
	
	# 기존 스킬 버튼 제거 (취소 버튼 제외)
	var panel := _skill_menu.get_child(0) as PanelContainer
	if panel:
		var vbox := panel.get_child(0) as VBoxContainer
		if vbox:
			# 마지막 버튼(취소) 제외하고 모든 자식 제거
			while vbox.get_child_count() > 1:
				var child := vbox.get_child(0)
				child.queue_free()
			
	# 선택된 캐릭터의 스킬만 가져오기
	var skills := _skill_registry.get_skills_for_character(_selected_actor.id)
	print(">>> 스킬 개수: ", skills.size())
	
	# 방어 코드: 스킬이 없으면 메시지 표시
	if skills.is_empty():
		_log_label.text = "사용 가능한 스킬이 없습니다."
		push_warning("[BattleScreen] 캐릭터 '%s'에 스킬이 없습니다!" % _selected_actor.id)
		return
	
	# 스킬 버튼 생성
	if panel:
		var vbox := panel.get_child(0) as VBoxContainer
		if vbox:
			# 취소 버튼 앞에 스킬 버튼 추가
			for skill: SkillData in skills:
				var cost_text := ""
				if skill.mp_cost > 0:
					cost_text += "MP %d" % skill.mp_cost
				if skill.sg_cost > 0:
					if cost_text.length() > 0:
						cost_text += " "
					cost_text += "SG %d" % skill.sg_cost
				
				var btn_text := "%s (%s)" % [skill.name, cost_text] if cost_text.length() > 0 else skill.name
				
				var btn := Button.new()
				btn.text = btn_text
				btn.custom_minimum_size = Vector2(140, 40)
				btn.pressed.connect(_on_skill_selected.bind(skill.id))
				print(">>> 스킬 버튼 생성: ", skill.name, " id: ", skill.id, " connected: ", btn.pressed.is_connected(_on_skill_selected))
				# 취소 버튼 앞에 추가
				vbox.add_child(btn)
				vbox.move_child(btn, vbox.get_child_count() - 2)
	
	# 화면 오른쪽에 고정 위치로 표시 (CanvasLayer에 있으므로 카메라 영향 없음)
	_skill_menu.position = Vector2(850, 200)
	_skill_menu.visible = true


func _hide_skill_menu() -> void:
	if _skill_menu == null:
		return
	
	# 동적 스킬 버튼들 제거 (취소 버튼 제외)
	var panel := _skill_menu.get_child(0) as PanelContainer
	if panel:
		var vbox := panel.get_child(0) as VBoxContainer
		if vbox:
			while vbox.get_child_count() > 1:
				var child := vbox.get_child(0)
				if child is Button and child.pressed.is_connected(_on_skill_selected):
					child.pressed.disconnect(_on_skill_selected)
				child.queue_free()
	
	_skill_menu.visible = false


func _on_skill_selected(skill_id: String) -> void:
	print(">>> _on_skill_selected 호출됨! skill_id: ", skill_id)
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	var skill := _skill_registry.get_skill(skill_id)
	assert(skill != null, "스킬을 찾을 수 없습니다: %s" % skill_id)
	
	print(">>> skill 찾음: ", skill.name, " cast_range: ", skill.cast_range)
	print(">>> MP: ", _selected_actor.mp, "/", skill.mp_cost, " SG: ", _selected_actor.sg, "/", skill.sg_cost)
	
	# MP/SG 체크 (차감은 확정 후) - 비용이 0보다 클 때만 체크
	if skill.mp_cost > 0 and _selected_actor.mp < skill.mp_cost:
		_log_label.text = "MP가 부족합니다! (필요: %d, 보유: %d)" % [skill.mp_cost, _selected_actor.mp]
		return
	
	if skill.sg_cost > 0 and _selected_actor.sg < skill.sg_cost:
		_log_label.text = "SG가 부족합니다! (필요: %d, 보유: %d)" % [skill.sg_cost, _selected_actor.sg]
		return
	
	# MP/SG는 확정 후 차감 (취소 시 보존)
	_hide_skill_menu()
	
	# 스킬 범위 표시
	_log_label.text = "타겟을 선택하세요."
	_show_skill_range(skill_id)


func _show_skill_range(skill_id: String) -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	var skill := _skill_registry.get_skill(skill_id)
	assert(skill != null, "스킬을 찾을 수 없습니다: %s" % skill_id)
	
	print(">>> _show_skill_range - skill: ", skill.name, " cast_range: ", skill.cast_range)
	
	# 선택된 스킬 ID 저장
	_selected_skill_id = skill_id
	_selected_action = BattleData.ActionType.SKILL
	
	# 2단계 범위 시스템
	if skill.cast_range == 0:
		# cast_range=0이면 본인 위치에서 바로 효과 범위 표시
		_selected_cast_pos = _selected_actor.grid_pos
		_show_effect_range_for_skill(skill, _selected_cast_pos)
	else:
		# 가용 범위 표시 (흰색)
		_set_state(BattleState.CAST)
		_log_label.text = "시전 위치를 선택하세요."
		_show_cast_range_for_skill(skill)


## 스킬의 가용 범위 표시
func _show_cast_range_for_skill(skill: SkillData) -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	# 그리드 동적 생성
	if _battle_grid == null:
		_battle_grid = TacticGrid.new()
		add_child(_battle_grid)
		_battle_grid.cell_clicked.connect(_on_grid_cell_clicked)
		await get_tree().process_frame
	
	_battle_grid.visible = true
	_battle_grid.show_cast_range(_selected_actor.grid_pos, skill.cast_range, [])
	_show_cancel_action_button()


## 스킬의 효과 범위 표시
func _show_effect_range_for_skill(skill: SkillData, center: Vector2i) -> void:
	print(">>> _show_effect_range_for_skill - center: ", center)
	assert(_battle_grid != null, "_battle_grid가 null입니다")
	
	# 색상 결정
	var effect_color := RANGE_COLOR_ATTACK
	if skill.type == SkillData.SkillType.HEAL or skill.type == SkillData.SkillType.BUFF:
		effect_color = RANGE_COLOR_ALLY
	
	# 효과 범위 표시
	_battle_grid.show_effect_range(center, skill.area_pattern, effect_color)
	_set_state(BattleState.EFFECT)
	
	# 뒤로 버튼 표시
	_show_cancel_action_button()
	
	# confirm 창 표시
	_show_confirm_dialog(
		"이 위치에 %s 사용?" % skill.name,
		center,
		_on_skill_confirmed
	)


## AreaPattern으로부터 셀 좌표 생성 (2단계 범위 시스템)
func _get_area_pattern_cells(area_pattern: SkillData.AreaPattern) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	match area_pattern:
		SkillData.AreaPattern.SINGLE:
			cells = [Vector2i(0, 0)]
		SkillData.AreaPattern.CROSS_1:
			cells = [
				Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0),
				Vector2i(1, 0), Vector2i(0, 1)
			]
		SkillData.AreaPattern.SQUARE_3x3:
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					cells.append(Vector2i(dx, dy))
		SkillData.AreaPattern.LINE_3:
			cells = [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)]
	return cells


func _on_item_selected(item_id: String) -> void:
	if _selected_actor == null:
		return
	return
	
#	var item := _item_registry.get_item(item_id)
#	if not item:
#		_log_label.text = "아이템을 찾을 수 없습니다."
#		_hide_item_menu()
#		return
#	
#	_hide_item_menu()
#	_selected_item_id = item_id
#	_selected_action = BattleData.ActionType.ITEM
#	
#	# target_type에 따라 분기
#	match item.target_type:
#		ItemData.ItemTargetType.SELF:
#			# 자기 자신 대상: 칸 선택 없이 바로 확인
#			_selected_target = _selected_actor
#			_show_confirm_dialog(
#				"%s 사용?" % item.name,
#				_selected_actor.grid_pos,
#				_on_item_confirmed
#			)
#		ItemData.ItemTargetType.ALLY:
#			# 아군 대상: 아군 위치 칸 범위 표시
#			_log_label.text = "대상 아군을 선택하세요."
#			_show_item_range_ally()
#		ItemData.ItemTargetType.ENEMY:
#			# 적 대상: 적 위치 칸 범위 표시
#			_log_label.text = "대상 적을 선택하세요."
#			_show_item_range_enemy(item)
#		ItemData.ItemTargetType.ALL_ALLY:
#			# 전체 아군: 바로 확인
#			_selected_target = _selected_actor
#			_show_confirm_dialog(
#				"%s을(를) 전체 아군에게 사용?" % item.name,
#				_selected_actor.grid_pos,
#				_on_item_confirmed
#			)


func _show_item_range_ally() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	return
	
	# 아군 위치만 하이라이트 (맨해튼 거리 내)
	#var item := _item_registry.get_item(_selected_item_id)
	#if not item:
		#return
	#
	#var range_pattern: Array[Vector2i] = []
	#for x in range(-item.use_range, item.use_range + 1):
		#for y in range(-item.use_range, item.use_range + 1):
			#if abs(x) + abs(y) <= item.use_range:
				#range_pattern.append(Vector2i(x, y))
	#
	## 점유되지 않은 칸은 제외 (아군이 있는 칸만 유효)
	#_show_range_cells(_selected_actor.grid_pos, range_pattern, [], RANGE_COLOR_ALLY)


func _show_item_range_enemy(item: ItemData) -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	var range_pattern: Array[Vector2i] = []
	for x in range(-item.use_range, item.use_range + 1):
		for y in range(-item.use_range, item.use_range + 1):
			if abs(x) + abs(y) <= item.use_range:
				range_pattern.append(Vector2i(x, y))
	
	_show_range_cells(_selected_actor.grid_pos, range_pattern, [], RANGE_COLOR_ATTACK)


# ═══════════════════════════════════════════════════════════════════════════════
# Unified Confirm Dialog Actions
# ═══════════════════════════════════════════════════════════════════════════════

func _show_confirm_dialog(message: String, grid_pos: Vector2i, callback: Callable) -> void:
	if _confirm_dialog == null:
		return
	
	_confirm_label.text = message
	_confirm_action_callback = callback
	
	var pixel_pos := Vector2(grid_pos.x * 64, grid_pos.y * 64)
	if _battle_grid:
		pixel_pos = _battle_grid.grid_to_pixel(grid_pos)
	_confirm_dialog.position = pixel_pos + Vector2(64, -20)
	_confirm_dialog.visible = true
	move_child(_confirm_dialog, get_child_count() - 1)


func _hide_confirm_dialog() -> void:
	if _confirm_dialog:
		_confirm_dialog.visible = false
	_confirm_action_callback = Callable()


func _on_confirm_accepted() -> void:
	var callback := _confirm_action_callback
	_hide_confirm_dialog()
	
	if callback.is_valid():
		callback.call()


func _on_confirm_cancelled() -> void:
	_hide_confirm_dialog()
	_selected_target = null
	
	# 가용 범위 선택 단계로 돌아가기
	_set_state(BattleState.CAST)
	
	# 그리드가 있으면 가용 범위 다시 표시
	if is_instance_valid(_battle_grid) and _battle_grid.visible and _selected_actor:
		match _selected_action:
			BattleData.ActionType.MOVE:
				_show_movable_cells()
			BattleData.ActionType.ATTACK:
				_show_cast_range_for_attack()
			BattleData.ActionType.SKILL:
				var skill := _skill_registry.get_skill(_selected_skill_id)
				if skill:
					_show_cast_range_for_skill(skill)
	else:
		# 그리드가 없으면 action menu로 돌아감
		_on_back_button_pressed()


# ═══════════════════════════════════════════════════════════════════════════════
# Confirm Callbacks (이동 / 공격 / 스킬 / 아이템)
# ═══════════════════════════════════════════════════════════════════════════════

func _on_move_confirmed() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	_set_state(BattleState.ACTION)
	
	var target_pos := _battle_grid.get_selected_cell() if _battle_grid else Vector2i(-1, -1)
	if target_pos == Vector2i(-1, -1):
		return
	
	# A* 경로 가져오기
	var path := _battle_grid.get_move_path(_selected_actor.grid_pos, target_pos)
	
	# 캐릭터 이동
	if _character_nodes.has(_selected_actor.id):
		var char_node: Actor = _character_nodes[_selected_actor.id]
		
		if path.size() >= 2:
			# 경로 따라 이동
			char_node.move_along_path(path)
			await char_node.movement_finished
		else:
			# 경로가 없으면 순간이동
			char_node.position = _battle_grid.grid_to_pixel(target_pos)
	
	# 위치 업데이트
	_selected_actor.grid_pos = target_pos
	
	# 그리드 제거
	_hide_battle_grid()
	_log_label.text = "%s이(가) 이동했다!" % _selected_actor.display_name
	
	# 턴 종료
	_end_player_action()


func _on_attack_confirmed() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	assert(_selected_target != null, "_selected_target가 null입니다")
	
	_hide_battle_grid()
	
	# 실제 공격 실행
	_execute_action(_selected_target)


func _on_skill_confirmed() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	assert(_selected_target != null, "_selected_target가 null입니다")
	
	var skill := _skill_registry.get_skill(_selected_skill_id)
	if not skill:
		return
	
	# MP/SG 확정 후 차감
	_selected_actor.mp -= skill.mp_cost
	_selected_actor.sg -= skill.sg_cost
	
	_hide_battle_grid()
	_execute_skill_action(skill, _selected_target)


func _on_item_confirmed() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	return
	#var item := _item_registry.get_item(_selected_item_id)
	#if not item:
		#return
	#
	#_hide_battle_grid()
	#
	## 아이템 효과 적용
	#var target := _selected_target if _selected_target else _selected_actor
	#_execute_item_effect(item, target)


func _execute_item_effect(item: ItemData, target: BattleData.Unit) -> void:
	match item.id:
		"potion":
			target.heal(50)
			_log_label.text = "%s이(가) %s에게 포션을 사용! 50 HP 회복!" % [_selected_actor.display_name, target.display_name]
		"ether":
			target.mp = mini(target.max_mp, target.mp + 30)
			_log_label.text = "%s이(가) %s에게 에테르를 사용! 30 MP 회복!" % [_selected_actor.display_name, target.display_name]
		"antidote":
			target.status = BattleData.Status.NONE
			target.status_turns = 0
			_log_label.text = "%s이(가) %s에게 해독제를 사용! 상태이상 해제!" % [_selected_actor.display_name, target.display_name]
		"fire_bomb":
			var damage := 40
			var actual := target.take_damage(damage)
			_log_label.text = "%s이(가) 화염탄을 투척! %s에게 %d 데미지!" % [_selected_actor.display_name, target.display_name, actual]
			if target.is_dead:
				_log_label.text += " %s이(가) 쓰러졌다!" % target.display_name
		"smoke_ball":
			_log_label.text = "%s이(가) 연막탄을 사용! 회피율 상승!" % _selected_actor.display_name
		_:
			_log_label.text = "%s이(가) %s을(를) 사용했다!" % [_selected_actor.display_name, item.name]
	
	# 턴 종료
	_end_player_action()


## 플레이어 행동 후 공통 처리
func _end_player_action() -> void:
	_selected_actor = null
	_selected_target = null
	_selected_skill_id = ""
	_selected_item_id = ""
	_selected_action = BattleData.ActionType.ATTACK
	_hide_action_menu()
	_hide_cancel_action_button()
	_hide_battle_grid()
	
	_battle_data.next_turn()
	_render_units()
	
	if _battle_data.check_battle_end():
		_end_battle()
		return
	
	_update_turn_display()


## 칸에서 유닛 찾기 (아군/적 구분)
func _find_unit_at(grid_pos: Vector2i, search_side: String) -> BattleData.Unit:
	if search_side == "ally":
		for ally in _battle_data.allies:
			if ally.grid_pos == grid_pos and not ally.is_dead:
				return ally
	elif search_side == "enemy":
		for enemy in _battle_data.enemies:
			if enemy.grid_pos == grid_pos and not enemy.is_dead:
				return enemy
	else:
		# 양쪽 다 검색
		for unit in _battle_data.allies + _battle_data.enemies:
			if unit.grid_pos == grid_pos and not unit.is_dead:
				return unit
	return null


# ═══════════════════════════════════════════════════════════════════════════════
# Grid Interaction
# ═══════════════════════════════════════════════════════════════════════════════

func _on_grid_cell_clicked(grid_pos: Vector2i) -> void:
	assert(_battle_grid != null, "_battle_grid가 null입니다")
	assert(_battle_grid.is_movable_cell(grid_pos), "이동 불가능한 칸입니다")
	
	_set_state(BattleState.EFFECT)
	_battle_grid.select_cell(grid_pos)
	
	# 2단계 범위 시스템 처리
	if _state == BattleState.CAST:
		# 가용 범위에서 클릭 → 효과 범위 표시
		_selected_cast_pos = grid_pos
		
		match _selected_action:
			BattleData.ActionType.ATTACK:
				_show_effect_range_for_attack(grid_pos)
			BattleData.ActionType.SKILL:
				var skill := _skill_registry.get_skill(_selected_skill_id)
				if skill:
					_show_effect_range_for_skill(skill, grid_pos)
		return
	
	# 효과 범위 확인 단계 (_range_phase == 2) 또는 이동
	match _selected_action:
		BattleData.ActionType.MOVE:
			_show_confirm_dialog(
				"이동하시겠습니까?",
				grid_pos,
				_on_move_confirmed
			)
		
		BattleData.ActionType.ATTACK:
			var target_unit := _find_unit_at(grid_pos, "enemy")
			if target_unit != null:
				_selected_target = target_unit
				_show_confirm_dialog(
					"%s을(를) 공격?" % target_unit.display_name,
					grid_pos,
					_on_attack_confirmed
				)
		
		BattleData.ActionType.SKILL:
			var skill := _skill_registry.get_skill(_selected_skill_id)
			if not skill:
				return
			
			# 타겟 찾기 (스킬 타입에 따라)
			var search_side := "enemy"
			if skill.type == SkillData.SkillType.HEAL or skill.type == SkillData.SkillType.BUFF:
				search_side = "ally"
			elif skill.type == SkillData.SkillType.DEBUFF:
				search_side = "enemy"
			
			var target_unit := _find_unit_at(grid_pos, search_side)
			if target_unit != null:
				_selected_target = target_unit
				_show_confirm_dialog(
					"%s에게 %s 사용?" % [target_unit.display_name, skill.name],
					grid_pos,
					_on_skill_confirmed
				)
		
		BattleData.ActionType.ITEM:
			return
			#var item := _item_registry.get_item(_selected_item_id)
			#if not item:
				#return
			#
			## 타겟 찾기 (아이템 타입에 따라)
			#var search_side := "any"
			#if item.target_type == ItemData.ItemTargetType.ALLY:
				#search_side = "ally"
			#elif item.target_type == ItemData.ItemTargetType.ENEMY:
				#search_side = "enemy"
			#
			#var target_unit := _find_unit_at(grid_pos, search_side)
			#if target_unit != null:
				#_selected_target = target_unit
				#_show_confirm_dialog(
					#"%s에게 %s 사용?" % [target_unit.display_name, item.name],
					#grid_pos,
					#_on_item_confirmed
				#)


func _show_range_cells(center: Vector2i, range_pattern: Array[Vector2i], occupied: Array[Vector2i] = [], color: Color = Color(1, 0.5, 0.5, 0.3)) -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	# 그리드 동적 생성
	if _battle_grid == null:
		_battle_grid = TacticGrid.new()
		add_child(_battle_grid)
		_battle_grid.cell_clicked.connect(_on_grid_cell_clicked)
		await get_tree().process_frame  # _ready() 완료 대기
	
	_battle_grid.visible = true
	_battle_grid.show_range_cells(center, range_pattern, occupied, color)
	_show_cancel_action_button()


func _show_movable_cells() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	# 점유된 칸 수집
	var occupied: Array[Vector2i] = []
	for ally in _battle_data.allies:
		if not ally.is_dead:
			occupied.append(ally.grid_pos)
	for enemy in _battle_data.enemies:
		if not enemy.is_dead:
			occupied.append(enemy.grid_pos)
	
	# 그리드 동적 생성
	if _battle_grid == null:
		_battle_grid = TacticGrid.new()
		add_child(_battle_grid)
		_battle_grid.cell_clicked.connect(_on_grid_cell_clicked)
	
	_battle_grid.visible = true
	
	# A* 기반 이동 가능한 칸 표시
	_battle_grid.show_reachable_cells(_selected_actor.grid_pos, _selected_actor.move_range, occupied)
	_show_cancel_action_button()


func _hide_battle_grid() -> void:
	if _battle_grid:
		_battle_grid.queue_free()
		_battle_grid = null


# ═══════════════════════════════════════════════════════════════════════════════
# Battle Setup
# ═══════════════════════════════════════════════════════════════════════════════

func _setup_battle() -> void:
	print("=== _setup_battle() ===")
	print("_rna: ", _rna)
	
	_battle_data = BattleData.new()
	
	# 아군 생성
	var allies: Array[BattleData.Unit] = []
	var party_ids: Array = _rna.get("party_members", ["sanzang"])
	print("party_ids: ", party_ids)
	for char_id in party_ids:
		var unit := _create_unit_from_character(char_id, BattleData.Side.ALLY)
		allies.append(unit)
	
	# 적군 생성
	var enemies: Array[BattleData.Unit] = []
	var unit := _create_enemy_unit(_enemy_id)
	enemies.append(unit)
	
	_battle_data.setup("battle_" + str(randi()), allies, enemies)
	_render_units()
	_update_turn_display()


func _create_unit_from_character(char_id: String, side: BattleData.Side) -> BattleData.Unit:
	var char_data := _char_registry.get_character(char_id)
	if not char_data:
		var unit := BattleData.Unit.new(char_id, char_id, side)
		return unit
	
	var unit := BattleData.Unit.new(char_id, char_data.display_name, side)
	unit.max_hp = char_data.max_hp
	unit.hp = char_data.max_hp
	unit.max_mp = char_data.max_mp
	unit.mp = char_data.max_mp
	unit.attack = char_data.st_pow + char_data.st_att
	unit.defense = char_data.st_def
	return unit


func _create_enemy_unit(enemy_id: String) -> BattleData.Unit:
	var unit := BattleData.Unit.new(enemy_id, tr("ENEMY_" + enemy_id.to_upper()), BattleData.Side.ENEMY)
	
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
# Rendering (절대 좌표)
# ═══════════════════════════════════════════════════════════════════════════════

func _render_units() -> void:
	# 기존 캐릭터 제거
	_character_nodes.clear()
	for child in _characters_parent.get_children():
		child.queue_free()
	
	# 아군 배치 (grid_pos 기반)
	for ally in _battle_data.allies:
		var char_node := _create_battle_character(ally)
		char_node.position = _grid_to_pixel(ally.grid_pos)
		_characters_parent.add_child(char_node)
		_character_nodes[ally.id] = char_node
	
	# 적군 배치 (grid_pos 기반)
	for enemy in _battle_data.enemies:
		var char_node := _create_battle_character(enemy)
		char_node.position = _grid_to_pixel(enemy.grid_pos)
		_characters_parent.add_child(char_node)
		_character_nodes[enemy.id] = char_node


## 그리드 좌표를 픽셀 좌표로 변환
func _grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	return GameManager.grid_to_pixel(grid_pos)


func _create_battle_character(unit: BattleData.Unit) -> Actor:
	var battle_char_scene := preload("res://scenes/entities/actor.tscn")
	var battle_char: Actor = battle_char_scene.instantiate()
	
	# 캐릭터 데이터 가져오기
	var char_data: CharacterData = null
	if unit.is_ally():
		char_data = _char_registry.get_character(unit.id)
	
	# Actor 초기화
	if char_data:
		battle_char.init(char_data, Actor.Role.PLAYER if unit.is_ally() else Actor.Role.ENEMY)
	battle_char.init_battle(unit)
	
	# 클릭 시그널 연결
	battle_char.clicked.connect(_on_character_clicked.bind(unit, battle_char))
	
	return battle_char


func _on_character_clicked(actor: Actor, unit: BattleData.Unit, battle_char: Actor) -> void:
	# 죽은 캐릭터 클릭 무시
	if unit.is_dead:
		return
	
	# 아군 클릭: 행동 메뉴 표시 (내 턴일 때만)
	if unit.is_ally() and _is_player_turn:
		_selected_actor = unit
		_show_action_menu()
	
	# 적 클릭: 대상 선택
	elif unit.is_enemy():
		if _selected_actor != null and _selected_action != null:
			# 행동 선택 후 대상 선택
			_on_target_selected(unit)
		elif _is_player_turn:
			# 바로 공격
			_log_label.text = "먼저 행동을 선택하세요."


func _update_turn_display() -> void:
	var actor := _battle_data.get_current_actor()
	print("=== _update_turn_display() ===")
	print("current_actor: ", actor.display_name if actor else "null")
	print("is_ally: ", actor.is_ally() if actor else "null")
	
	if actor:
		_turn_label.text = "%s의 턴" % actor.display_name
		_is_player_turn = actor.is_ally()
		
		# 현재 턴 캐릭터 하이라이트
		_highlight_current_actor(actor)
		
		# 카메라를 현재 턴 캐릭터 위치로 이동
		_move_camera_to_unit(actor)
		
		if _is_player_turn:
			_set_state(BattleState.ACTION_MENU)
			# 아군 턴이면 자동으로 action menu 표시
			_selected_actor = actor
			_show_action_menu()
		else:
			print(">>> 적 턴 시작 - 0.5초 대기")
			# 적 턴은 자동 진행
			if is_inside_tree():
				await get_tree().create_timer(0.5).timeout
				print(">>> _process_enemy_turn() 호출")
				_process_enemy_turn()
			else:
				print(">>> 트리에 없음 - 적 턴 스킵")


func _highlight_current_actor(actor: BattleData.Unit) -> void:
	# 모든 캐릭터 흐림
	for char_id in _character_nodes:
		var char_node: Actor = _character_nodes[char_id]
		char_node.set_dimmed(true)
	
	# 현재 행동자만 밝게
	if _character_nodes.has(actor.id):
		var char_node: Actor = _character_nodes[actor.id]
		char_node.set_dimmed(false)
		char_node.set_highlight(true)


# ═══════════════════════════════════════════════════════════════════════════════
# Actions
# ═══════════════════════════════════════════════════════════════════════════════

func _on_action_menu_selected(action_type: BattleData.ActionType) -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	_selected_action = action_type
	
	match action_type:
		BattleData.ActionType.ATTACK:
			_set_state(BattleState.CAST)
			_action_menu.visible = false
			_log_label.text = "공격할 칸을 선택하세요."
			_show_attackable_cells()
		BattleData.ActionType.SKILL:
			_set_state(BattleState.LIST_MENU)
			_action_menu.visible = false
			_log_label.text = "사용할 스킬을 선택하세요."
			_show_skill_menu()
		BattleData.ActionType.MOVE:
			_set_state(BattleState.CAST)
			_action_menu.visible = false
			_log_label.text = "이동할 칸을 선택하세요."
			_show_movable_cells()
		BattleData.ActionType.ITEM:
			_set_state(BattleState.LIST_MENU)
			_action_menu.visible = false
			_log_label.text = "사용할 아이템을 선택하세요."
			_show_item_menu()
		BattleData.ActionType.END_TURN:
			_set_state(BattleState.IDLE)
			_hide_action_menu()
			_selected_actor = null
			_battle_data.next_turn()
			_render_units()
			
			if _battle_data.check_battle_end():
				_end_battle()
				return
			
			_update_turn_display()


func _show_attackable_cells() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	# 2단계 범위 시스템
	if _selected_actor.attack_cast_range == 0:
		# cast_range=0이면 본인 위치에서 바로 효과 범위 표시
		_selected_cast_pos = _selected_actor.grid_pos
		_show_effect_range_for_attack(_selected_cast_pos)
	else:
		# 가용 범위 표시 (흰색)
		_set_state(BattleState.CAST)
		_log_label.text = "공격할 위치를 선택하세요."
		_show_cast_range_for_attack()


## 공격의 가용 범위 표시
func _show_cast_range_for_attack() -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	# 그리드 동적 생성
	if _battle_grid == null:
		_battle_grid = TacticGrid.new()
		add_child(_battle_grid)
		_battle_grid.cell_clicked.connect(_on_grid_cell_clicked)
		await get_tree().process_frame
	
	_battle_grid.visible = true
	_battle_grid.show_cast_range(_selected_actor.grid_pos, _selected_actor.attack_cast_range, [])
	_show_cancel_action_button()


## 공격의 효과 범위 표시
func _show_effect_range_for_attack(center: Vector2i) -> void:
	if _battle_grid == null:
		return
	
	# 효과 범위 표시 (SINGLE 패턴)
	_battle_grid.show_effect_range(center, SkillData.AreaPattern.SINGLE, RANGE_COLOR_ATTACK)
	_set_state(BattleState.EFFECT)
	
	# 해당 위치에 적이 있으면 타겟 설정
	var target_unit := _find_unit_at(center, "enemy")
	if target_unit != null:
		_selected_target = target_unit
		_show_confirm_dialog(
			"%s을(를) 공격?" % target_unit.display_name,
			center,
			_on_attack_confirmed
		)
	else:
		_show_confirm_dialog(
			"이 위치를 공격?",
			center,
			_on_attack_confirmed
		)


func _highlight_enemies() -> void:
	# 모든 캐릭터 흐림
	for char_id in _character_nodes:
		var char_node: Actor = _character_nodes[char_id]
		char_node.set_dimmed(true)
	
	# 적만 밝게
	for enemy in _battle_data.enemies:
		if not enemy.is_dead and _character_nodes.has(enemy.id):
			var char_node: Actor = _character_nodes[enemy.id]
			char_node.set_dimmed(false)


func _on_target_selected(target: BattleData.Unit) -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	_execute_action(target)


func _execute_action(target: BattleData.Unit) -> void:
	var actor := _selected_actor if _selected_actor else _battle_data.get_current_actor()
	if actor == null:
		return
	
	var action := BattleData.BattleAction.new()
	action.actor = actor
	action.action_type = _selected_action
	action.target = target
	
	_battle_data.execute_action(action)
	_log_label.text = _battle_data.battle_log[-1] if _battle_data.battle_log.size() > 0 else ""
	
	# 턴 종료
	_end_player_action()


func _process_enemy_turn() -> void:
	print("=== _process_enemy_turn() ===")
	var actor := _battle_data.get_current_actor()
	print("초기 actor: ", actor.display_name if actor else "null")
	
	while actor and actor.is_ally():
		print(">>> 아군 턴 감지 - next_turn 호출")
		_battle_data.next_turn()
		actor = _battle_data.get_current_actor()
		print(">>> next_turn 후 actor: ", actor.display_name if actor else "null")
	
	if actor == null:
		print(">>> actor가 null - 리턴")
		return
	
	print(">>> 적 actor 확정: ", actor.display_name)
	
	# AI 초기화
	if _enemy_ai == null:
		print(">>> EnemyAI 생성")
		_enemy_ai = EnemyAI.new()
	
	# AI로 행동 결정
	print(">>> AI decide_action 호출")
	var action_data := _enemy_ai.decide_action(actor, _battle_data, _skill_registry)
	print(">>> action_data: ", action_data)
	print(">>> action_data.type: ", action_data.type if action_data else "null")
	
	# 행동 실행
	match action_data.type:
		"MOVE":
			print(">>> MOVE 실행")
			_process_enemy_move(actor, action_data.position)
		"ATTACK":
			print(">>> ATTACK 실행")
			_process_enemy_attack(actor, action_data.target)
		"SKILL":
			print(">>> SKILL 실행")
			_process_enemy_skill(actor, action_data.target, action_data.skill)
		_:
			print(">>> 알 수 없는 액션 타입: ", action_data.type)


func _process_enemy_move(enemy: BattleData.Unit, move_pos: Vector2i) -> void:
	if move_pos.x < 0:
		# 이동 불가 - 공격 시도
		var alive_allies: Array[BattleData.Unit] = []
		for ally in _battle_data.allies:
			if not ally.is_dead:
				alive_allies.append(ally)
		
		if not alive_allies.is_empty():
			var target := alive_allies[randi() % alive_allies.size()]
			_process_enemy_attack(enemy, target)
		else:
			_battle_data.next_turn()
			_update_turn_display()
		return
	
	enemy.grid_pos = move_pos
	_log_label.text = "%s이(가) 이동했다!" % enemy.display_name
	
	# 캐릭터 위치 업데이트
	if _character_nodes.has(enemy.id):
		var char_node: Actor = _character_nodes[enemy.id]
		char_node.position = _grid_to_pixel(move_pos)
	
	_battle_data.next_turn()
	_render_units()
	
	if _battle_data.check_battle_end():
		_end_battle()
		return
	
	_update_turn_display()


func _process_enemy_attack(enemy: BattleData.Unit, target: BattleData.Unit) -> void:
	if target == null:
		_battle_data.next_turn()
		_update_turn_display()
		return
	
	var action := BattleData.BattleAction.new()
	action.actor = enemy
	action.action_type = BattleData.ActionType.ATTACK
	action.target = target
	
	_battle_data.execute_action(action)
	_log_label.text = _battle_data.battle_log[-1] if _battle_data.battle_log.size() > 0 else ""
	
	_battle_data.next_turn()
	_render_units()
	
	if _battle_data.check_battle_end():
		_end_battle()
		return
	
	_update_turn_display()


func _process_enemy_skill(enemy: BattleData.Unit, target: BattleData.Unit, skill: SkillData) -> void:
	if target == null or skill == null:
		# 스킬 실패 - 일반 공격으로 대체
		var alive_allies: Array[BattleData.Unit] = []
		for ally in _battle_data.allies:
			if not ally.is_dead:
				alive_allies.append(ally)
		
		if not alive_allies.is_empty():
			var fallback_target := alive_allies[randi() % alive_allies.size()]
			_process_enemy_attack(enemy, fallback_target)
		else:
			_battle_data.next_turn()
			_update_turn_display()
		return
	
	# 스킬 비용 차감
	enemy.mp -= skill.mp_cost
	enemy.sg -= skill.sg_cost
	
	# 스킬 실행
	match skill.type:
		SkillData.SkillType.ATTACK:
			var damage := int(enemy.attack * skill.damage_multiplier)
			var actual := target.take_damage(damage)
			_log_label.text = "%s이(가) %s 사용! %s에게 %d 데미지!" % [
				enemy.display_name,
				skill.name,
				target.display_name,
				actual
			]
			
			if target.is_dead:
				_log_label.text += " %s이(가) 쓰러졌다!" % target.display_name
		
		SkillData.SkillType.HEAL:
			target.heal(skill.heal_amount)
			_log_label.text = "%s이(가) %s 사용! %s의 HP %d 회복!" % [
				enemy.display_name,
				skill.name,
				target.display_name,
				skill.heal_amount
			]
		
		_:
			_log_label.text = "%s이(가) %s 사용!" % [enemy.display_name, skill.name]
	
	_battle_data.next_turn()
	_render_units()
	
	if _battle_data.check_battle_end():
		_end_battle()
		return
	
	_update_turn_display()


func _end_battle() -> void:
	_hide_action_menu()
	
	# 결과 표시
	var result_label := Label.new()
	result_label.text = "승리!" if _battle_data.is_victory else "패배..."
	result_label.position = Vector2(512, 300)
	result_label.size = Vector2(200, 60)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 48)
	result_label.add_theme_color_override("font_color", 
		Color(0.9, 0.7, 0.2) if _battle_data.is_victory else Color(0.8, 0.3, 0.3))
	add_child(result_label)
	
	# 확인 버튼
	var confirm_btn := Button.new()
	confirm_btn.text = "확인"
	confirm_btn.position = Vector2(512, 400)
	confirm_btn.size = Vector2(200, 50)
	confirm_btn.pressed.connect(_on_battle_confirm_pressed)
	add_child(confirm_btn)


func _on_battle_confirm_pressed() -> void:
	# RNA 업데이트
	if _battle_data.is_victory:
		GameManager.current_screen = "explore"
	else:
		GameManager.current_screen = "title"
	
	GameManager.from_battle = true
	GameManager.battle_victory = _battle_data.is_victory
	
	# 화면 전환
	finished.emit()


# ═══════════════════════════════════════════════════════════════════════════════
# Skill Action Execution
# ═══════════════════════════════════════════════════════════════════════════════

func _execute_skill_action(skill: SkillData, target_unit: BattleData.Unit) -> void:
	assert(_selected_actor != null, "_selected_actor가 null입니다")
	
	match skill.type:
		SkillData.SkillType.ATTACK:
			var damage := int(_selected_actor.attack * skill.damage_multiplier)
			var actual := target_unit.take_damage(damage)
			_log_label.text = "%s이(가) %s 사용! %s에게 %d 데미지!" % [
				_selected_actor.display_name,
				skill.name,
				target_unit.display_name,
				actual
			]
			
			if target_unit.is_dead:
				_log_label.text += " %s이(가) 쓰러졌다!" % target_unit.display_name
		
		SkillData.SkillType.HEAL:
			target_unit.heal(skill.heal_amount)
			_log_label.text = "%s이(가) %s 사용! %s의 HP %d 회복!" % [
				_selected_actor.display_name,
				skill.name,
				target_unit.display_name,
				skill.heal_amount
			]
		
		SkillData.SkillType.BUFF:
			_log_label.text = "%s이(가) %s 사용! %s에게 %s 버프!" % [
				_selected_actor.display_name,
				skill.name,
				target_unit.display_name,
				_get_buff_display_name(skill.buff_type)
			]
			# TODO: 버프 시스템 구현 필요
		
		SkillData.SkillType.DEBUFF:
			_log_label.text = "%s이(가) %s 사용! %s에게 %s 디버프!" % [
				_selected_actor.display_name,
				skill.name,
				target_unit.display_name,
				_get_buff_display_name(skill.buff_type)
			]
			# TODO: 디버프 시스템 구현 필요
	
	# 턴 종료
	_end_player_action()


func _get_buff_display_name(buff_type: String) -> String:
	match buff_type:
		"attack": return "공격력"
		"defense": return "방어력"
		"speed": return "속도"
		_: return buff_type
