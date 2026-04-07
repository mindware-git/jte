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
	# 화염 참격 - Flame Slash: 단일 불 속성 공격
	_register_skill(_create_attack_skill(
		"flame_slash",
		"Flame Slash",
		"Fire attack, 1.5x damage.",
		1, 10, 0, 1.5, SkillData.SkillElement.FIRE, SkillData.SkillRangeType.SINGLE
	))
	
	# 빙의 창 - Ice Spear: 십자 범위 물 속성 공격
	_register_skill(_create_attack_skill(
		"ice_spear",
		"Ice Spear",
		"Ice attack, 2.0x damage, cross range.",
		1, 15, 5, 2.0, SkillData.SkillElement.WATER, SkillData.SkillRangeType.CROSS_1
	))
	
	# 뇌전 폭풍 - Thunder Storm: 3x3 범위 바람 속성 공격
	_register_skill(_create_attack_skill(
		"thunder_storm",
		"Thunder Storm",
		"Lightning attack, 1.8x damage, area.",
		1, 20, 10, 1.8, SkillData.SkillElement.WIND, SkillData.SkillRangeType.SQUARE_3x3
	))
	
	# 빛의 치유 - Heal Light: 단일 대상 치유
	_register_skill(_create_heal_skill(
		"heal_light",
		"Heal Light",
		"Heals ally for 50 HP.",
		1, 12, 50
	))
	
	# 보호의 장벽 - Protect Barrier: 방어력 버프
	_register_skill(_create_buff_skill(
		"protect_barrier",
		"Protect Barrier",
		"Defense +5 for 3 turns.",
		1, 8, 0, "defense", 5, 3
	))


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