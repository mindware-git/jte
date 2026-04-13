class_name SkillRegistry
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# SkillRegistry
# 스킬 데이터 레지스트리
# ═══════════════════════════════════════════════════════════════════════════════

var _skills: Dictionary = {}


func _init() -> void:
	_register_all_skills()


func _register_all_skills() -> void:
	_register_basic_skills()


# ═══════════════════════════════════════════════════════════════════════════════
# Basic Skills
# ═══════════════════════════════════════════════════════════════════════════════

func _register_basic_skills() -> void:
	# ═══════════════════════════════════════════════════════════════════════════════
	# 삼장법사 스킬
	# ═══════════════════════════════════════════════════════════════════════════════
	
	# 로우 힐 - 기본 치유
	var low_heal := SkillData.new()
	low_heal.id = "low_heal"
	low_heal.name = "로우 힐"
	low_heal.type = SkillData.SkillType.HEAL
	low_heal.mp_cost = 5
	low_heal.heal_amount = 60
	low_heal.cast_range = 2
	low_heal.area_pattern = SkillData.AreaPattern.SINGLE
	low_heal.unlock_level = 1
	_register_skill(low_heal)
	
	# 큐어 - 중급 치유
	var cure := SkillData.new()
	cure.id = "cure"
	cure.name = "큐어"
	cure.type = SkillData.SkillType.HEAL
	cure.mp_cost = 7
	cure.heal_amount = 110
	cure.cast_range = 2
	cure.area_pattern = SkillData.AreaPattern.SINGLE
	cure.unlock_level = 3
	_register_skill(cure)
	
	# 홀리 워터 - 성수 공격
	var holy_water := SkillData.new()
	holy_water.id = "holy_water"
	holy_water.name = "홀리 워터"
	holy_water.type = SkillData.SkillType.ATTACK
	holy_water.mp_cost = 10
	holy_water.damage_multiplier = 1.5
	holy_water.cast_range = 3
	holy_water.area_pattern = SkillData.AreaPattern.SINGLE
	holy_water.unlock_level = 5
	_register_skill(holy_water)
	
	# 라이프 드레인 - 흡혈
	var life_drain := SkillData.new()
	life_drain.id = "life_drain"
	life_drain.name = "라이프 드레인"
	life_drain.type = SkillData.SkillType.ATTACK
	life_drain.mp_cost = 20
	life_drain.damage_multiplier = 1.1
	life_drain.cast_range = 2
	life_drain.area_pattern = SkillData.AreaPattern.SINGLE
	life_drain.unlock_level = 8
	_register_skill(life_drain)
	
	# 하이 힐 - 고급 치유
	var high_heal := SkillData.new()
	high_heal.id = "high_heal"
	high_heal.name = "하이 힐"
	high_heal.type = SkillData.SkillType.HEAL
	high_heal.mp_cost = 20
	high_heal.heal_amount = 220
	high_heal.cast_range = 2
	high_heal.area_pattern = SkillData.AreaPattern.SINGLE
	high_heal.unlock_level = 12
	_register_skill(high_heal)
	
	# 리커버 - 상태 회복
	var recover := SkillData.new()
	recover.id = "recover"
	recover.name = "리커버"
	recover.type = SkillData.SkillType.BUFF
	recover.mp_cost = 20
	recover.buff_type = "remove_debuff"
	recover.cast_range = 2
	recover.area_pattern = SkillData.AreaPattern.SINGLE
	recover.unlock_level = 15
	_register_skill(recover)
	
	# 사일런스 - 침묵
	var silence := SkillData.new()
	silence.id = "silence"
	silence.name = "사일런스"
	silence.type = SkillData.SkillType.DEBUFF
	silence.mp_cost = 10
	silence.buff_type = "silence"
	silence.buff_duration = 3
	silence.cast_range = 3
	silence.area_pattern = SkillData.AreaPattern.SINGLE
	silence.unlock_level = 18
	_register_skill(silence)
	
	# 하이퍼 힐 - 대량 치유
	var hyper_heal := SkillData.new()
	hyper_heal.id = "hyper_heal"
	hyper_heal.name = "하이퍼 힐"
	hyper_heal.type = SkillData.SkillType.HEAL
	hyper_heal.mp_cost = 50
	hyper_heal.heal_amount = 500
	hyper_heal.cast_range = 2
	hyper_heal.area_pattern = SkillData.AreaPattern.CROSS_1
	hyper_heal.unlock_level = 25
	_register_skill(hyper_heal)
	
	# 리프레쉬 - 전체 회복
	var refresh := SkillData.new()
	refresh.id = "refresh"
	refresh.name = "리프레쉬"
	refresh.type = SkillData.SkillType.HEAL
	refresh.mp_cost = 40
	refresh.heal_amount = 9999  # 전회복
	refresh.cast_range = 2
	refresh.area_pattern = SkillData.AreaPattern.SINGLE
	refresh.unlock_level = 30
	_register_skill(refresh)


func _register_skill(skill: SkillData) -> void:
	_skills[skill.id] = skill


# ═══════════════════════════════════════════════════════════════════════════════
# 조회 메서드
# ═══════════════════════════════════════════════════════════════════════════════

func get_skill(id: String) -> SkillData:
	return _skills.get(id)


func has_skill(id: String) -> bool:
	return _skills.has(id)


func get_all_skills() -> Array[SkillData]:
	var result: Array[SkillData] = []
	for key in _skills.keys():
		result.append(_skills[key])
	return result


func get_skills_for_character(character_id: String) -> Array[SkillData]:
	# 캐릭터별 스킬 매핑
	var mapping := {
		"sanzang": [
			"low_heal", "cure", "holy_water", "life_drain",
			"high_heal", "recover", "silence",
			"hyper_heal", "refresh"
		],
		"wukong": [
			"stone_monkey_strike", "azure_dragon_blow", "white_tiger_flip",
			"phantom_grin", "mirror_image", "vermillion_rampage",
			"black_tortoise_crush", "moonlight_barrage",
			"ruyi_rampage", "golden_afterimage"
		],
	}
	
	var result: Array[SkillData] = []
	if mapping.has(character_id):
		for skill_id in mapping[character_id]:
			var skill := get_skill(skill_id)
			if skill:
				result.append(skill)
	return result
