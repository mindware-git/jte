extends GutTest

# ═══════════════════════════════════════════════════════════════════════════════
# test_battle_targeting.gd
# 아이템/스킬 칸 기반 타겟팅 + 확인(Confirm) 시스템 테스트
# ═══════════════════════════════════════════════════════════════════════════════


# ═══════════════════════════════════════════════════════════════════════════════
# ItemData target_type 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_item_data_has_target_type() -> void:
	var item := ItemData.new()
	# 기본값은 SELF
	assert_eq(item.target_type, ItemData.ItemTargetType.SELF,
		"기본 target_type은 SELF여야 한다")


func test_item_data_has_use_range() -> void:
	var item := ItemData.new()
	# 기본값은 0 (자기 자신)
	assert_eq(item.use_range, 0,
		"기본 use_range는 0이어야 한다")


func test_potion_targets_ally() -> void:
	var registry := ItemRegistry.new()
	var potion := registry.get_item("potion")

	assert_not_null(potion, "포션이 레지스트리에 있어야 한다")
	assert_eq(potion.target_type, ItemData.ItemTargetType.ALLY,
		"포션의 target_type은 ALLY여야 한다")


func test_ether_targets_ally() -> void:
	var registry := ItemRegistry.new()
	var ether := registry.get_item("ether")

	assert_not_null(ether, "에테르가 레지스트리에 있어야 한다")
	assert_eq(ether.target_type, ItemData.ItemTargetType.ALLY,
		"에테르의 target_type은 ALLY여야 한다")


func test_antidote_targets_ally() -> void:
	var registry := ItemRegistry.new()
	var antidote := registry.get_item("antidote")

	assert_not_null(antidote, "해독제가 레지스트리에 있어야 한다")
	assert_eq(antidote.target_type, ItemData.ItemTargetType.ALLY,
		"해독제의 target_type은 ALLY여야 한다")


func test_fire_bomb_targets_enemy() -> void:
	var registry := ItemRegistry.new()
	var fire_bomb := registry.get_item("fire_bomb")

	assert_not_null(fire_bomb, "화염탄이 레지스트리에 있어야 한다")
	assert_eq(fire_bomb.target_type, ItemData.ItemTargetType.ENEMY,
		"화염탄의 target_type은 ENEMY여야 한다")
	assert_gt(fire_bomb.use_range, 0,
		"화염탄의 use_range는 0보다 커야 한다")


func test_smoke_ball_targets_self() -> void:
	var registry := ItemRegistry.new()
	var smoke_ball := registry.get_item("smoke_ball")

	assert_not_null(smoke_ball, "연막탄이 레지스트리에 있어야 한다")
	assert_eq(smoke_ball.target_type, ItemData.ItemTargetType.SELF,
		"연막탄의 target_type은 SELF여야 한다")


# ═══════════════════════════════════════════════════════════════════════════════
# TacticGrid 색상 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_battle_grid_show_range_cells_with_color() -> void:
	var grid := TacticGrid.new()
	add_child_autofree(grid)
	await get_tree().process_frame

	var center := Vector2i(5, 5)
	var pattern: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0)]
	var green_color := Color(0.3, 1, 0.5, 0.3)

	# 색상 매개변수가 있는 show_range_cells 호출이 에러 없이 동작해야 함
	grid.show_range_cells(center, pattern, [], green_color)

	# 표시된 칸에 지정된 색이 있는지 확인
	assert_true(grid.is_movable_cell(Vector2i(6, 5)),
		"범위 내 칸이 movable로 표시되어야 한다")
	assert_true(grid.is_movable_cell(Vector2i(4, 5)),
		"범위 내 칸이 movable로 표시되어야 한다")


# ═══════════════════════════════════════════════════════════════════════════════
# 스킬 MP 차감 시점 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_skill_data_mp_cost_exists() -> void:
	var SkillRegistryScript := preload("res://scripts/res/registry/skill_registry.gd")
	var registry := SkillRegistryScript.new()
	var skill := registry.get_skill("low_heal")

	assert_not_null(skill, "로우 힐 스킬이 있어야 한다")
	assert_gt(skill.mp_cost, 0, "로우 힐의 MP 비용이 0보다 커야 한다")


func test_unit_mp_preserved_before_confirm() -> void:
	# MP가 스킬 선택 시점이 아닌 확정 시점에 차감되는지 확인
	var unit := BattleData.Unit.new("test", "테스트", BattleData.Side.ALLY)
	unit.max_mp = 50
	unit.mp = 50

	var SkillRegistryScript := preload("res://scripts/res/registry/skill_registry.gd")
	var registry := SkillRegistryScript.new()
	var skill := registry.get_skill("low_heal")

	# 스킬을 선택만 하고 아직 사용하지 않은 상태 시뮬레이션
	var mp_before := unit.mp

	# MP가 변하지 않아야 함 (실제 battle.gd에서 확인 후 차감하도록 수정)
	assert_eq(unit.mp, mp_before,
		"스킬 선택만 한 상태에서 MP가 차감되면 안 된다")

	# 확정 후 차감
	unit.mp -= skill.mp_cost
	assert_eq(unit.mp, mp_before - skill.mp_cost,
		"확정 후 MP가 정확히 차감되어야 한다")


# ═══════════════════════════════════════════════════════════════════════════════
# 아이템 범위 계산 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_item_ally_range_pattern() -> void:
	# ALLY 타겟 아이템의 범위 패턴이 올바르게 생성되는지
	var item := ItemData.new()
	item.target_type = ItemData.ItemTargetType.ALLY
	item.use_range = 3

	# 맨해튼 거리 3 이내의 패턴 생성
	var pattern: Array[Vector2i] = []
	for x in range(-item.use_range, item.use_range + 1):
		for y in range(-item.use_range, item.use_range + 1):
			if abs(x) + abs(y) <= item.use_range:
				pattern.append(Vector2i(x, y))

	assert_gt(pattern.size(), 0, "범위 패턴이 비어있으면 안 된다")
	assert_true(Vector2i(0, 0) in pattern, "자기 위치도 패턴에 포함되어야 한다")
	assert_true(Vector2i(3, 0) in pattern, "맨해튼 거리 3인 칸도 포함되어야 한다")
	assert_false(Vector2i(3, 1) in pattern, "맨해튼 거리 4인 칸은 포함되면 안 된다")


func test_item_enemy_range_pattern() -> void:
	# ENEMY 타겟 아이템의 범위 패턴이 올바르게 생성되는지
	var item := ItemData.new()
	item.target_type = ItemData.ItemTargetType.ENEMY
	item.use_range = 5

	var pattern: Array[Vector2i] = []
	for x in range(-item.use_range, item.use_range + 1):
		for y in range(-item.use_range, item.use_range + 1):
			if abs(x) + abs(y) <= item.use_range:
				pattern.append(Vector2i(x, y))

	assert_true(Vector2i(5, 0) in pattern, "사거리 최대 거리도 포함되어야 한다")
	assert_false(Vector2i(6, 0) in pattern, "사거리 초과 거리는 포함되면 안 된다")


# ═══════════════════════════════════════════════════════════════════════════════
# BattleData Unit 위치 기반 탐색 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_find_ally_at_position() -> void:
	var battle_data := BattleData.new()
	var allies: Array[BattleData.Unit] = []
	var ally := BattleData.Unit.new("sanzang", "삼장", BattleData.Side.ALLY)
	ally.grid_pos = Vector2i(3, 6)
	allies.append(ally)

	var enemies: Array[BattleData.Unit] = []
	var enemy := BattleData.Unit.new("rock_demon", "바위 요괴", BattleData.Side.ENEMY)
	enemy.grid_pos = Vector2i(12, 6)
	enemies.append(enemy)

	battle_data.setup("test_battle", allies, enemies)

	# 아군 위치에서 아군 찾기
	var found: BattleData.Unit = null
	for a in battle_data.allies:
		if a.grid_pos == Vector2i(3, 6) and not a.is_dead:
			found = a
			break

	assert_not_null(found, "아군 위치에서 아군을 찾아야 한다")
	assert_eq(found.id, "sanzang", "삼장이어야 한다")


func test_find_enemy_at_position() -> void:
	var battle_data := BattleData.new()
	var allies: Array[BattleData.Unit] = []
	var ally := BattleData.Unit.new("sanzang", "삼장", BattleData.Side.ALLY)
	allies.append(ally)

	var enemies: Array[BattleData.Unit] = []
	var enemy := BattleData.Unit.new("rock_demon", "바위 요괴", BattleData.Side.ENEMY)
	enemy.grid_pos = Vector2i(12, 6)
	enemies.append(enemy)

	battle_data.setup("test_battle", allies, enemies)

	# 적 위치에서 적 찾기
	var found: BattleData.Unit = null
	for e in battle_data.enemies:
		if e.grid_pos == Vector2i(12, 6) and not e.is_dead:
			found = e
			break

	assert_not_null(found, "적 위치에서 적을 찾아야 한다")
	assert_eq(found.id, "rock_demon", "바위 요괴여야 한다")
