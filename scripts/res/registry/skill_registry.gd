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
	# 화염 참격 - Flame Slash: 단일 불 속성 공격 (used by test_battle_targeting.gd)
	_register_skill(_create_attack_skill(
		"flame_slash",
		"Flame Slash",
		"Fire attack, 1.5x damage.",
		1, 10, 0, 1.5, SkillData.SkillElement.FIRE, SkillData.SkillRangeType.SINGLE
	))

	# Sanzang Skills
	# 청심진언 (Cheongsim Jineon) - test_heal_skill_properties, test_skill_unlock_levels
	_register_skill(_create_heal_skill(
		"cheongsim_jineon",
		"청심진언",
		"치유 스킬",
		1, 8, 30
	))
	
	_register_skill(_create_heal_skill("daebe_jineon", "대비진언", "치유 스킬", 5, 10, 50))
	_register_skill(_create_heal_skill("jeonggi_jeongsim", "정기정심", "치유", 10, 15, 70))
	_register_skill(_create_heal_skill("bongrae_hoebok", "봉래회복", "치유", 15, 20, 100))
	_register_skill(_create_heal_skill("daejadaebi", "대자대비", "치유", 20, 30, 150))
	_register_skill(_create_heal_skill("honjeongri", "혼정리", "치유", 25, 40, 200))

	# Wukong Skills
	# 돌원숭이치기 (Dolwonsungi) - test_attack_skill_properties
	_register_skill(_create_attack_skill(
		"dolwonsungi",
		"돌원숭이치기",
		"기본 공격 스킬",
		1, 10, 0, 1.5, SkillData.SkillElement.EARTH, SkillData.SkillRangeType.SINGLE
	))
	
	# 여의난무 (Yeoui Nanmu) - test_skill_unlock_levels
	_register_skill(_create_attack_skill(
		"yeoui_nanmu",
		"여의난무",
		"최종 공격 스킬",
		20, 50, 0, 3.0, SkillData.SkillElement.NONE, SkillData.SkillRangeType.SQUARE_3x3
	))

	# 원숭이분신 (Wonsung Bunsin) - test_buff_skill_properties
	_register_skill(_create_buff_skill(
		"wonsung_bunsin",
		"원숭이분신",
		"속도 버프",
		5, 15, 0, "speed", 8, 3
	))

	# 잔원숭이웃음 (Janwonsung Utum) - test_debuff_skill_properties
	_register_skill(_create_debuff_skill(
		"janwonsung_utum",
		"잔원숭이웃음",
		"속도 디버프",
		10, 15, 0, "speed", -5, 3
	))

	# 주작난봉 (Jujak Nanbong) - test_wukong_fire_skill
	_register_skill(_create_attack_skill(
		"jujak_nanbong",
		"주작난봉",
		"불 속성 공격",
		12, 20, 0, 2.0, SkillData.SkillElement.FIRE, SkillData.SkillRangeType.CROSS_1
	))

	# 청룡봉격 (Cheongryong Bonggyeok) - test_wukong_wind_skill
	_register_skill(_create_attack_skill(
		"cheongryong_bonggyeok",
		"청룡봉격",
		"바람 속성 공격",
		8, 20, 0, 2.0, SkillData.SkillElement.WIND, SkillData.SkillRangeType.CROSS_1
	))

	# 현무거치 (Hyeonmu Geochi) - test_wukong_water_skill
	_register_skill(_create_attack_skill(
		"hyeonmu_geochi",
		"현무거치",
		"물 속성 공격",
		15, 20, 0, 2.0, SkillData.SkillElement.WATER, SkillData.SkillRangeType.CROSS_1
	))
	
	_register_skill(_create_attack_skill("baekho_dwijipgi", "백호뒤집기", "공격", 10, 20, 0, 2.0, SkillData.SkillElement.NONE, SkillData.SkillRangeType.SINGLE))



# ═══════════════════════════════════════════════════════════════════════════════
# Factory Methods
# ═══════════════════════════════════════════════════════════════════════════════

func _create_attack_skill(
	p_id: String,
	p_name: String,
	p_desc: String,
	p_unlock: int,
	p_mp: int,
	p_sg: int,
	p_multiplier: float,
	p_element: SkillData.SkillElement,
	p_range: SkillData.SkillRangeType
) -> SkillData:
	var skill := SkillData.new()
	skill.id = p_id
	skill.name = p_name
	skill.description = p_desc
	skill.type = SkillData.SkillType.ATTACK
	skill.element = p_element
	skill.unlock_level = p_unlock
	skill.mp_cost = p_mp
	skill.sg_cost = p_sg
	skill.damage_multiplier = p_multiplier
	skill.range_type = p_range
	return skill


func _create_heal_skill(
	p_id: String,
	p_name: String,
	p_desc: String,
	p_unlock: int,
	p_mp: int,
	p_heal: int
) -> SkillData:
	var skill := SkillData.new()
	skill.id = p_id
	skill.name = p_name
	skill.description = p_desc
	skill.type = SkillData.SkillType.HEAL
	skill.element = SkillData.SkillElement.WIND
	skill.unlock_level = p_unlock
	skill.mp_cost = p_mp
	skill.heal_amount = p_heal
	return skill


func _create_buff_skill(
	p_id: String,
	p_name: String,
	p_desc: String,
	p_unlock: int,
	p_mp: int,
	p_sg: int,
	p_buff_type: String,
	p_buff_value: int,
	p_duration: int
) -> SkillData:
	var skill := SkillData.new()
	skill.id = p_id
	skill.name = p_name
	skill.description = p_desc
	skill.type = SkillData.SkillType.BUFF
	skill.element = SkillData.SkillElement.WIND
	skill.unlock_level = p_unlock
	skill.mp_cost = p_mp
	skill.sg_cost = p_sg
	skill.buff_type = p_buff_type
	skill.buff_value = p_buff_value
	skill.buff_duration = p_duration
	return skill


func _create_debuff_skill(
	p_id: String,
	p_name: String,
	p_desc: String,
	p_unlock: int,
	p_mp: int,
	p_sg: int,
	p_buff_type: String,
	p_buff_value: int,
	p_duration: int
) -> SkillData:
	var skill := SkillData.new()
	skill.id = p_id
	skill.name = p_name
	skill.description = p_desc
	skill.type = SkillData.SkillType.DEBUFF
	skill.element = SkillData.SkillElement.NONE
	skill.unlock_level = p_unlock
	skill.mp_cost = p_mp
	skill.sg_cost = p_sg
	skill.buff_type = p_buff_type
	skill.buff_value = p_buff_value
	skill.buff_duration = p_duration
	return skill


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
		"sanzang": ["cheongsim_jineon", "jeonggi_jeongsim", "daebe_jineon", "bongrae_hoebok", "daejadaebi", "honjeongri"],
		"wukong": ["dolwonsungi", "cheongryong_bonggyeok", "baekho_dwijipgi", "janwonsung_utum", "wonsung_bunsin", "jujak_nanbong", "hyeonmu_geochi", "yeoui_nanmu"],
	}
	
	var result: Array[SkillData] = []
	if mapping.has(character_id):
		for skill_id in mapping[character_id]:
			var skill := get_skill(skill_id)
			if skill:
				result.append(skill)
	return result