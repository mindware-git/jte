class_name EnemyAI
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# EnemyAI
# 적 AI 시스템 (전략 + 세부 행동 분리)
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# 전략 (Strategy)
# ═══════════════════════════════════════════════════════════════════════════════

## 전략 타입
enum Strategy {
	AGGRESSIVE,   # 공격적: HP가 낮은 적 우선, 적극적 접근
	DEFENSIVE,    # 방어적: 거리 유지, 신중한 행동
	BALANCED      # 균형: 상황에 따라 유연하게
}

## 현재 전략
var _current_strategy: Strategy = Strategy.BALANCED


# ═══════════════════════════════════════════════════════════════════════════════
# 전략 선택
# ═══════════════════════════════════════════════════════════════════════════════

## 전략 선택 (현재는 무작위)
func select_strategy(_enemy: BattleData.Unit) -> Strategy:
	# TODO: 상황 기반 전략 선택 (HP, 위치, 아군 수 등)
	_current_strategy = randi() % 3 as Strategy
	return _current_strategy


# ═══════════════════════════════════════════════════════════════════════════════
# 행동 결정
# ═══════════════════════════════════════════════════════════════════════════════

## 행동 결정 (메인 진입점)
## 반환: { "type": "MOVE"|"ATTACK"|"SKILL", "target": Unit, "position": Vector2i, "skill": SkillData }
func decide_action(
	enemy: BattleData.Unit,
	battle_data: BattleData,
	skill_registry: SkillRegistry
) -> Dictionary:
	# 1. 전략 선택
	select_strategy(enemy)
	
	# 2. 공격 범위 내 타겟 확인
	var targets_in_range := _get_targets_in_range(enemy, battle_data)
	
	# 3. 스킬 사용 가능 확인
	var usable_skill := _get_usable_skill(enemy, skill_registry)
	
	# 4. 행동 결정
	if targets_in_range.size() > 0:
		# 타겟이 있음
		if usable_skill != null and randf() > 0.5:
			# 스킬 사용 (50% 확률)
			return {
				"type": "SKILL",
				"target": _select_target(targets_in_range, enemy),
				"skill": usable_skill,
				"position": Vector2i(-1, -1)
			}
		else:
			# 일반 공격
			return {
				"type": "ATTACK",
				"target": _select_target(targets_in_range, enemy),
				"skill": null,
				"position": Vector2i(-1, -1)
			}
	else:
		# 타겟이 없음 - 이동
		var move_pos := _get_approach_position(enemy, battle_data)
		return {
			"type": "MOVE",
			"target": null,
			"skill": null,
			"position": move_pos
		}


# ═══════════════════════════════════════════════════════════════════════════════
# 헬퍼 함수들
# ═══════════════════════════════════════════════════════════════════════════════

## 공격 범위 내 타겟 확인
func _get_targets_in_range(enemy: BattleData.Unit, battle_data: BattleData) -> Array[BattleData.Unit]:
	var targets: Array[BattleData.Unit] = []
	
	# 적의 공격 범위 계산 (맨해튼 거리 기반)
	var attackable_positions: Array[Vector2i] = []
	for x in range(-enemy.attack_cast_range, enemy.attack_cast_range + 1):
		for y in range(-enemy.attack_cast_range, enemy.attack_cast_range + 1):
			if absi(x) + absi(y) <= enemy.attack_cast_range:
				attackable_positions.append(enemy.grid_pos + Vector2i(x, y))
	
	# 범위 내 아군 확인
	for ally in battle_data.allies:
		if ally.is_dead:
			continue
		if ally.grid_pos in attackable_positions:
			targets.append(ally)
	
	return targets


## 사용 가능한 스킬 확인
func _get_usable_skill(enemy: BattleData.Unit, skill_registry: SkillRegistry) -> SkillData:
	if enemy.skills.is_empty():
		return null
	
	# 스킬 목록에서 사용 가능한 것 찾기
	var usable_skills: Array[SkillData] = []
	for skill_id in enemy.skills:
		var skill := skill_registry.get_skill(skill_id)
		if skill == null:
			continue
		
		# MP/SG 체크
		if enemy.mp >= skill.mp_cost and enemy.sg >= skill.sg_cost:
			usable_skills.append(skill)
	
	if usable_skills.is_empty():
		return null
	
	# 무작위 선택
	return usable_skills[randi() % usable_skills.size()]


## 타겟 선택 (전략 기반)
func _select_target(targets: Array[BattleData.Unit], _enemy: BattleData.Unit) -> BattleData.Unit:
	if targets.is_empty():
		return null
	
	match _current_strategy:
		Strategy.AGGRESSIVE:
			# HP가 가장 낮은 타겟
			return _get_lowest_hp_target(targets)
		Strategy.DEFENSIVE:
			# 가장 가까운 타겟
			return _get_nearest_target(targets, _enemy)
		Strategy.BALANCED:
			# 무작위
			return targets[randi() % targets.size()]
	
	return targets[0]


## HP가 가장 낮은 타겟
func _get_lowest_hp_target(targets: Array[BattleData.Unit]) -> BattleData.Unit:
	var lowest: BattleData.Unit = targets[0]
	for target in targets:
		if target.hp < lowest.hp:
			lowest = target
	return lowest


## 가장 가까운 타겟
func _get_nearest_target(targets: Array[BattleData.Unit], enemy: BattleData.Unit) -> BattleData.Unit:
	var nearest: BattleData.Unit = targets[0]
	var min_dist := _get_distance(enemy.grid_pos, nearest.grid_pos)
	
	for target in targets:
		var dist := _get_distance(enemy.grid_pos, target.grid_pos)
		if dist < min_dist:
			min_dist = dist
			nearest = target
	
	return nearest


## 거리 계산 (맨해튼)
func _get_distance(from: Vector2i, to: Vector2i) -> int:
	return absi(from.x - to.x) + absi(from.y - to.y)


## 접근 위치 계산
func _get_approach_position(enemy: BattleData.Unit, battle_data: BattleData) -> Vector2i:
	# 가장 가까운 아군 찾기
	var nearest_ally: BattleData.Unit = null
	var min_dist := 999
	
	for ally in battle_data.allies:
		if ally.is_dead:
			continue
		var dist := _get_distance(enemy.grid_pos, ally.grid_pos)
		if dist < min_dist:
			min_dist = dist
			nearest_ally = ally
	
	if nearest_ally == null:
		return enemy.grid_pos
	
	# 아군 방향으로 한 칸 이동
	var direction := nearest_ally.grid_pos - enemy.grid_pos
	var move_dir := Vector2i(0, 0)
	
	if direction.x != 0:
		move_dir.x = 1 if direction.x > 0 else -1
	elif direction.y != 0:
		move_dir.y = 1 if direction.y > 0 else -1
	
	var new_pos := enemy.grid_pos + move_dir
	
	# 그리드 범위 체크 (TacticGrid.GRID_WIDTH, GRID_HEIGHT 참고)
	if new_pos.x >= 0 and new_pos.x < 16 and new_pos.y >= 0 and new_pos.y < 9:
		return new_pos
	
	return enemy.grid_pos
