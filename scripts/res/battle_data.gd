class_name BattleData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# BattleData
# 전투 데이터 구조 (칸 기반 턴제)
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# Enums
# ═══════════════════════════════════════════════════════════════════════════════

## 진영
enum Side {
	ALLY,   # 아군
	ENEMY   # 적군
}

## 행동 타입
enum ActionType {
	ATTACK,   # 일반 공격
	SKILL,    # 스킬
	ITEM,     # 아이템
	DEFEND,   # 방어
	FLEE      # 도주
}

## 상태이상
enum Status {
	NONE,      # 없음
	POISON,    # 독
	BURN,      # 화상
	FREEZE,    # 빙결
	STUN,      # 기절
	CHARM,     # 매혹
	SEAL       # 봉인
}

# ═══════════════════════════════════════════════════════════════════════════════
# Unit (전투 유닛)
# ═══════════════════════════════════════════════════════════════════════════════

## 전투 유닛 데이터
class Unit:
	var id: String = ""
	var display_name: String = ""
	var side: BattleData.Side = BattleData.Side.ALLY
	
	# 스탯
	var max_hp: int = 100
	var hp: int = 100
	var max_mp: int = 50
	var mp: int = 50
	var attack: int = 10
	var defense: int = 5
	var speed: int = 10
	
	# 위치 (칸)
	var cell_index: int = 0
	
	# 상태이상
	var status: BattleData.Status = BattleData.Status.NONE
	var status_turns: int = 0
	
	# 행동 가능 여부
	var can_act: bool = true
	var is_dead: bool = false
	
	# 스킬 목록
	var skills: Array[String] = []
	
	func _init(p_id: String, p_name: String, p_side: BattleData.Side) -> void:
		id = p_id
		display_name = p_name
		side = p_side
	
	func take_damage(amount: int) -> int:
		var actual := maxi(1, amount - defense)
		hp = maxi(0, hp - actual)
		if hp <= 0:
			is_dead = true
		return actual
	
	func heal(amount: int) -> void:
		hp = mini(max_hp, hp + amount)
	
	func is_ally() -> bool:
		return side == BattleData.Side.ALLY
	
	func is_enemy() -> bool:
		return side == BattleData.Side.ENEMY


# ═══════════════════════════════════════════════════════════════════════════════
# BattleCell (전장 칸)
# ═══════════════════════════════════════════════════════════════════════════════

## 전장 칸 데이터
class BattleCell:
	var index: int = 0
	var side: BattleData.Side = BattleData.Side.ALLY
	var row: int = 0
	var column: int = 0
	var occupant: Unit = null
	
	func is_occupied() -> bool:
		return occupant != null


# ═══════════════════════════════════════════════════════════════════════════════
# BattleAction (행동)
# ═══════════════════════════════════════════════════════════════════════════════

## 전투 행동 데이터
class BattleAction:
	var actor: Unit = null
	var action_type: BattleData.ActionType = BattleData.ActionType.ATTACK
	var target: Unit = null
	var skill_id: String = ""
	var item_id: String = ""
	var damage: int = 0
	var healed: int = 0
	var is_critical: bool = false


# ═══════════════════════════════════════════════════════════════════════════════
# BattleData Main
# ═══════════════════════════════════════════════════════════════════════════════

## 전투 ID
var battle_id: String = ""

## 전장 크기 (아군 3칸, 적군 3칸)
var grid_width: int = 3
var grid_height: int = 1

## 전장 칸들
var cells: Array[BattleCell] = []

## 전투 참가자
var allies: Array[Unit] = []
var enemies: Array[Unit] = []

## 턴 큐
var turn_queue: Array[Unit] = []

## 현재 턴 인덱스
var current_turn: int = 0

## 전투 로그
var battle_log: Array[String] = []

## 전투 결과
var is_victory: bool = false
var is_battle_over: bool = false


# ═══════════════════════════════════════════════════════════════════════════════
# Setup Methods
# ═══════════════════════════════════════════════════════════════════════════════

## 전투 초기화
func setup(p_battle_id: String, p_allies: Array[Unit], p_enemies: Array[Unit]) -> void:
	battle_id = p_battle_id
	allies = p_allies
	enemies = p_enemies
	
	_setup_grid()
	_setup_turn_queue()


## 전장 칸 설정
func _setup_grid() -> void:
	cells.clear()
	
	# 아군 칸 (3칸)
	for i in range(3):
		var cell := BattleCell.new()
		cell.index = i
		cell.side = BattleData.Side.ALLY
		cell.column = i
		cells.append(cell)
		
		# 아군 배치
		if i < allies.size():
			cell.occupant = allies[i]
			allies[i].cell_index = i
	
	# 적군 칸 (3칸)
	for i in range(3):
		var cell := BattleCell.new()
		cell.index = 3 + i
		cell.side = BattleData.Side.ENEMY
		cell.column = i
		cells.append(cell)
		
		# 적군 배치
		if i < enemies.size():
			cell.occupant = enemies[i]
			enemies[i].cell_index = 3 + i


## 턴 큐 설정 (속도 기반)
func _setup_turn_queue() -> void:
	turn_queue.clear()
	
	var all_units: Array[Unit] = []
	all_units.append_array(allies)
	all_units.append_array(enemies)
	
	# 속도 내림차순 정렬
	all_units.sort_custom(func(a: Unit, b: Unit) -> bool:
		return a.speed > b.speed
	)
	
	for unit in all_units:
		if not unit.is_dead:
			turn_queue.append(unit)
	
	current_turn = 0


## 현재 행동자 가져오기
func get_current_actor() -> Unit:
	if turn_queue.is_empty():
		return null
	return turn_queue[current_turn % turn_queue.size()]


## 다음 턴으로 진행
func next_turn() -> void:
	current_turn += 1
	
	# 죽은 유닛 제거하고 큐 재구성
	if current_turn >= turn_queue.size():
		_setup_turn_queue()


## 전투 종료 체크
func check_battle_end() -> bool:
	var alive_allies := 0
	var alive_enemies := 0
	
	for ally in allies:
		if not ally.is_dead:
			alive_allies += 1
	
	for enemy in enemies:
		if not enemy.is_dead:
			alive_enemies += 1
	
	if alive_allies == 0:
		is_victory = false
		is_battle_over = true
		return true
	
	if alive_enemies == 0:
		is_victory = true
		is_battle_over = true
		return true
	
	return false


## 행동 실행
func execute_action(action: BattleAction) -> void:
	match action.action_type:
		BattleData.ActionType.ATTACK:
			_execute_attack(action)
		BattleData.ActionType.SKILL:
			_execute_skill(action)
		BattleData.ActionType.DEFEND:
			_execute_defend(action)


## 일반 공격 실행
func _execute_attack(action: BattleAction) -> void:
	if action.target == null:
		return
	
	var damage := action.actor.attack
	var actual := action.target.take_damage(damage)
	action.damage = actual
	
	battle_log.append("%s이(가) %s을(를) 공격! %d 데미지!" % [
		action.actor.display_name,
		action.target.display_name,
		actual
	])
	
	if action.target.is_dead:
		battle_log.append("%s이(가) 쓰러졌다!" % action.target.display_name)


## 스킬 실행
func _execute_skill(action: BattleAction) -> void:
	# TODO: 스킬 데이터 연동
	battle_log.append("%s이(가) %s 사용!" % [
		action.actor.display_name,
		action.skill_id
	])


## 방어 실행
func _execute_defend(action: BattleAction) -> void:
	# TODO: 방어 시 데미지 감소
	battle_log.append("%s이(가) 방어 태세!" % action.actor.display_name)
