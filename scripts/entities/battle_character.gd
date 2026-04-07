class_name BattleCharacter
extends Character

# ═══════════════════════════════════════════════════════════════════════════════
# BattleCharacter
# 전투용 캐릭터 (Character 상속)
# HP/MP 바, 스킬, 전투 로직 추가
# ═══════════════════════════════════════════════════════════════════════════════

# 시그널
signal hp_changed(current: int, max_hp: int)
signal mp_changed(current: int, max_mp: int)
signal died(character: BattleCharacter)
signal action_selected(action_type: int, target: BattleCharacter)

# 전투 데이터
var _battle_unit: BattleData.Unit = null

# UI 컴포넌트
var _hp_bar: ProgressBar = null
var _mp_bar: ProgressBar = null
var _hp_label: Label = null
var _status_container: HBoxContainer = null

# 상태
var _is_dead: bool = false

# ═══════════════════════════════════════════════════════════════════════════════
# Properties
# ═══════════════════════════════════════════════════════════════════════════════

var battle_unit: BattleData.Unit:
	get: return _battle_unit

var is_dead: bool:
	get: return _is_dead

var current_hp: int:
	get: return _battle_unit.hp if _battle_unit else 0

var max_hp: int:
	get: return _battle_unit.max_hp if _battle_unit else 0

var current_mp: int:
	get: return _battle_unit.mp if _battle_unit else 0

var max_mp: int:
	get: return _battle_unit.max_mp if _battle_unit else 0

# ═══════════════════════════════════════════════════════════════════════════════
# Initialization
# ═══════════════════════════════════════════════════════════════════════════════

## 전투 캐릭터 초기화
func init_battle(data: CharacterData, battle_unit: BattleData.Unit) -> void:
	_battle_unit = battle_unit
	
	# 기본 초기화
	init(data)
	
	# 전투 UI 추가
	_setup_battle_ui()


# ═══════════════════════════════════════════════════════════════════════════════
# Battle UI
# ═══════════════════════════════════════════════════════════════════════════════

func _setup_battle_ui() -> void:
	# HP 바 (캐릭터 하단)
	_hp_bar = ProgressBar.new()
	_hp_bar.max_value = max_hp
	_hp_bar.value = current_hp
	_hp_bar.custom_minimum_size = Vector2(60, 8)
	_hp_bar.position = Vector2(-30, 10)  # 캐릭터 하단
	_hp_bar.modulate = Color(0.2, 0.8, 0.2)  # 녹색
	add_child(_hp_bar)
	
	# HP 텍스트
	_hp_label = Label.new()
	_hp_label.text = "%d/%d" % [current_hp, max_hp]
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_label.position = Vector2(-30, 20)
	_hp_label.size = Vector2(60, 16)
	_hp_label.add_theme_font_size_override("font_size", 10)
	_hp_label.add_theme_color_override("font_color", Color.WHITE)
	_hp_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_hp_label.add_theme_constant_override("outline_size", 1)
	add_child(_hp_label)
	
	# MP 바 (HP 바 아래)
	if max_mp > 0:
		_mp_bar = ProgressBar.new()
		_mp_bar.max_value = max_mp
		_mp_bar.value = current_mp
		_mp_bar.custom_minimum_size = Vector2(60, 4)
		_mp_bar.position = Vector2(-30, 38)
		_mp_bar.modulate = Color(0.3, 0.5, 1)  # 파랑
		add_child(_mp_bar)
	
	# 상태이상 컨테이너
	_status_container = HBoxContainer.new()
	_status_container.position = Vector2(-30, -10)
	add_child(_status_container)


# ═══════════════════════════════════════════════════════════════════════════════
# Battle Actions
# ═══════════════════════════════════════════════════════════════════════════════

## 데미지 받기
func take_damage(amount: int) -> void:
	if _is_dead or _battle_unit == null:
		return
	
	_battle_unit.hp = maxi(0, _battle_unit.hp - amount)
	_update_hp_display()
	
	if _battle_unit.hp <= 0:
		_die()


## 회복
func heal(amount: int) -> void:
	if _is_dead or _battle_unit == null:
		return
	
	_battle_unit.hp = mini(max_hp, _battle_unit.hp + amount)
	_update_hp_display()


## MP 사용
func use_mp(amount: int) -> void:
	if _battle_unit == null:
		return
	
	_battle_unit.mp = maxi(0, _battle_unit.mp - amount)
	_update_mp_display()


## MP 회복
func recover_mp(amount: int) -> void:
	if _battle_unit == null:
		return
	
	_battle_unit.mp = mini(max_mp, _battle_unit.mp + amount)
	_update_mp_display()


## 사망 처리
func _die() -> void:
	_is_dead = true
	_battle_unit.is_dead = true
	
	# 시각 효과
	modulate = Color(0.5, 0.5, 0.5, 0.7)
	
	died.emit(self)


# ═══════════════════════════════════════════════════════════════════════════════
# UI Update
# ═══════════════════════════════════════════════════════════════════════════════

func _update_hp_display() -> void:
	if _hp_bar:
		_hp_bar.value = current_hp
	if _hp_label:
		_hp_label.text = "%d/%d" % [current_hp, max_hp]
	
	hp_changed.emit(current_hp, max_hp)


func _update_mp_display() -> void:
	if _mp_bar:
		_mp_bar.value = current_mp
	mp_changed.emit(current_mp, max_mp)


# ═══════════════════════════════════════════════════════════════════════════════
# Click Handling
# ═══════════════════════════════════════════════════════════════════════════════

func _on_clicked_battle(character: Character) -> void:
	if _is_dead:
		return
	
	# 전투에서 클릭 시 선택 처리
	# 실제 동작은 Battle 씬에서 처리
	clicked.emit(self)


## 하이라이트 효과
func set_highlight(enabled: bool) -> void:
	if enabled:
		modulate = Color(1.2, 1.2, 1.0)
	else:
		modulate = Color(1, 1, 1) if not _is_dead else Color(0.5, 0.5, 0.5, 0.7)


## 비활성화 표시
func set_dimmed(dimmed: bool) -> void:
	if dimmed:
		modulate = Color(0.6, 0.6, 0.6)
	else:
		modulate = Color(1, 1, 1) if not _is_dead else Color(0.5, 0.5, 0.5, 0.7)