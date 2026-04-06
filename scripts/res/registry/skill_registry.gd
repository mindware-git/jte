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
	# 삼장 스킬 (치유/진언 계열)
	_register_sanzang_skills()
	# 손오공 스킬 (봉술/분신 계열)
	_register_wukong_skills()


# ═══════════════════════════════════════════════════════════════════════════════
# 삼장 스킬 (10~19)
# ═══════════════════════════════════════════════════════════════════════════════

func _register_sanzang_skills() -> void:
	# 청심진언 (로우 힐)
	_register_skill(_create_heal_skill(
		"cheongsim_jineon",
		"청심진언",
		"마음을 맑게 하는 진언으로 약간의 HP를 회복한다.",
		1, 8, 30
	))
	
	# 정기정심 (큐어)
	_register_skill(_create_heal_skill(
		"jeonggi_jeongsim",
		"정기정심",
		"정신을 집중하여 중량의 HP를 회복한다.",
		5, 15, 60
	))
	
	# 대비진언 (하이 힐)
	_register_skill(_create_heal_skill(
		"daebe_jineon",
		"대비진언",
		"자비의 진언으로 대량의 HP를 회복한다.",
		10, 25, 100
	))
	
	# 봉래회복 (리커버)
	_register_skill(_create_heal_skill(
		"bongrae_hoebok",
		"봉래회복",
		"봉래의 신비한 힘으로 완전히 회복한다.",
		15, 40, 200
	))
	
	# 대자대비 (하이퍼 힐)
	_register_skill(_create_heal_skill(
		"daejadaebi",
		"대자대비",
		"큰 자비로 파티 전체의 HP를 회복한다.",
		20, 50, 150
	))
	
	# 혼정리 (리프레쉬)
	_register_skill(_create_buff_skill(
		"honjeongri",
		"혼정리",
		"정신을 맑게 하여 상태이상을 해제한다.",
		8, 12, "defense", 5, 3
	))


# ═══════════════════════════════════════════════════════════════════════════════
# 손오공 스킬 (0~9)
# ═══════════════════════════════════════════════════════════════════════════════

func _register_wukong_skills() -> void:
	# 돌원숭이치기 (덩 킹콩)
	_register_skill(_create_attack_skill(
		"dolwonsungi",
		"돌원숭이치기",
		"여의봉으로 강력하게 내려친다.",
		1, 10, 1.5, SkillData.SkillElement.EARTH
	))
	
	# 청룡봉격 (맹장신군 청룡)
	_register_skill(_create_attack_skill(
		"cheongryong_bonggyeok",
		"청룡봉격",
		"청룡의 기운을 담은 봉술 공격.",
		5, 15, 2.0, SkillData.SkillElement.WIND
	))
	
	# 백호뒤집기 (감병신군 백호)
	_register_skill(_create_attack_skill(
		"baekho_dwijipgi",
		"백호뒤집기",
		"백호의 기운으로 적을 뒤집어 버린다.",
		8, 18, 2.2, SkillData.SkillElement.EARTH
	))
	
	# 잔원숭 웃음 (체셔 캣)
	_register_skill(_create_debuff_skill(
		"janwonsung_utum",
		"잔원숭 웃음",
		"알 수 없는 웃음으로 적을 혼란시킨다.",
		10, 20, "speed", 3, 2
	))
	
	# 원숭분신 (분신술)
	_register_skill(_create_buff_skill(
		"wonsung_bunsin",
		"원숭분신",
		"분신을 만들어 회피율을 높인다.",
		12, 25, "speed", 8, 3
	))
	
	# 주작난봉 (능광신군 주작)
	_register_skill(_create_attack_skill(
		"jujak_nanbong",
		"주작난봉",
		"주작의 불꽃으로 적을 휩쓴다.",
		15, 22, 2.5, SkillData.SkillElement.FIRE
	))
	
	# 현무거치 (집명신군 현무)
	_register_skill(_create_attack_skill(
		"hyeonmu_geochi",
		"현무거치",
		"현무의 방어력을 무시하고 공격한다.",
		18, 28, 2.8, SkillData.SkillElement.WATER
	))
	
	# 여의난무 (슈퍼난무)
	_register_skill(_create_attack_skill(
		"yeoui_nanmu",
		"여의난무",
		"여의봉을 미친 듯이 휘둘러 적 전체를 공격한다.",
		20, 35, 3.0, SkillData.SkillElement.NONE
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
	p_multiplier: float,
	p_element: SkillData.SkillElement
) -> SkillData:
	var skill := SkillData.new()
	skill.id = p_id
	skill.name = p_name
	skill.description = p_desc
	skill.type = SkillData.SkillType.ATTACK
	skill.element = p_element
	skill.unlock_level = p_unlock
	skill.mp_cost = p_mp
	skill.damage_multiplier = p_multiplier
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