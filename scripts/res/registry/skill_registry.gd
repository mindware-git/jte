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

	# ───────────────────────────────────────────────────────────────────────
	# Sanzang Skills (Original IDs 10–19)
	# ───────────────────────────────────────────────────────────────────────

	# 청심진언 - Gentle Heal: 기본 단일 치유
	_register_skill(_create_heal_skill(
		"gentle_heal",
		"청심진언",
		"Restores a small amount of HP to one ally.",
		1, 5, 60
	))

	# 정기정심 - Purify: 단일 정화 + 치유
	_register_skill(_create_heal_skill(
		"purify",
		"정기정심",
		"Removes all debuffs and status ailments from one ally.",
		5, 7, 110
	))

	# 홀리워터 - Holy Water: AoE INT 기반 공격 (언데드 특효)
	_register_skill(_create_attack_skill(
		"holy_water",
		"홀리워터",
		"Splashes blessed water dealing INT-based damage. Effective vs undead.",
		8, 10, 0, 1.2, SkillData.SkillElement.WATER, SkillData.SkillRangeType.CROSS_1
	))

	# 생기흡수 - Life Drain: 단일 흡혈 공격
	_register_skill(_create_attack_skill(
		"life_drain",
		"생기흡수",
		"Drains enemy vitality, dealing INT damage and recovering HP.",
		12, 20, 0, 1.8, SkillData.SkillElement.NONE, SkillData.SkillRangeType.SINGLE
	))

	# 대비진언 - Greater Heal: 고급 단일 치유
	_register_skill(_create_heal_skill(
		"greater_heal",
		"대비진언",
		"Restores a large amount of HP to one ally.",
		15, 20, 220
	))

	# 봉래회복 - Restore: 단일 완전 정화 + 회복
	_register_skill(_create_heal_skill(
		"restore",
		"봉래회복",
		"Fully cures all ailments and restores moderate HP.",
		18, 20, 100
	))

	# 봉인진언 - Silence: 스킬 봉인 디버프
	_register_skill(_create_debuff_skill(
		"silence",
		"봉인진언",
		"Seals the target's skills for 2 turns.",
		10, 10, 0, "silence", 1, 2
	))

	# 대자대비 - Divine Heal: 전체 대량 치유
	_register_skill(_create_heal_skill(
		"divine_heal",
		"대자대비",
		"Restores massive HP to all allies.",
		25, 50, 2100
	))

	# 혼정리 - Full Restore: 전체 정화 + 회복
	_register_skill(_create_heal_skill(
		"full_restore",
		"혼정리",
		"Fully purifies the entire party, removing all ailments and restoring HP.",
		30, 40, 2100
	))

	# 영등부르기 - Summon Spirit: 소환
	_register_skill(_create_buff_skill(
		"summon_spirit",
		"영등부르기",
		"Summons a guardian spirit to assist in battle.",
		20, 0, 0, "summon", 40, 3
	))

	# ───────────────────────────────────────────────────────────────────────
	# Wukong Skills (Original IDs 0–9)
	# ───────────────────────────────────────────────────────────────────────

	# 돌원숭이치기 - Stone Monkey Strike: 기본 물리 공격
	_register_skill(_create_attack_skill(
		"stone_monkey_strike",
		"돌원숭이치기",
		"A quick overhead smash. POW-based.",
		1, 5, 0, 1.5, SkillData.SkillElement.EARTH, SkillData.SkillRangeType.SINGLE
	))

	# 청룡봉격 - Azure Dragon Blow: 바람 속성 봉격
	_register_skill(_create_attack_skill(
		"azure_dragon_blow",
		"청룡봉격",
		"Channels the Azure Dragon's fury into a powerful staff strike.",
		5, 8, 0, 1.8, SkillData.SkillElement.WIND, SkillData.SkillRangeType.SINGLE
	))

	# 백호뒤집기 - White Tiger Flip: 강타
	_register_skill(_create_attack_skill(
		"white_tiger_flip",
		"백호뒤집기",
		"A spinning vault kick inspired by the White Tiger.",
		8, 12, 0, 2.0, SkillData.SkillElement.NONE, SkillData.SkillRangeType.SINGLE
	))

	# 잔원숭이웃음 - Phantom Grin: 전체 디버프
	_register_skill(_create_debuff_skill(
		"phantom_grin",
		"잔원숭이웃음",
		"A mocking grin that unnerves all enemies, lowering their accuracy.",
		10, 15, 0, "speed", -5, 3
	))

	# 원숭이분신 - Mirror Image: 자기 버프
	_register_skill(_create_buff_skill(
		"mirror_image",
		"원숭이분신",
		"Creates illusory clones, dramatically boosting evasion.",
		12, 20, 0, "speed", 8, 3
	))

	# 주작난봉 - Vermillion Rampage: 화속성 AoE
	_register_skill(_create_attack_skill(
		"vermillion_rampage",
		"주작난봉",
		"Blazing staff strikes infused with the Vermillion Bird's fire.",
		16, 26, 0, 2.5, SkillData.SkillElement.FIRE, SkillData.SkillRangeType.CROSS_1
	))

	# 현무거치 - Black Tortoise Crush: 수속성 AoE
	_register_skill(_create_attack_skill(
		"black_tortoise_crush",
		"현무거치",
		"A devastating ground slam channeling the Black Tortoise's weight.",
		20, 35, 0, 2.8, SkillData.SkillElement.WATER, SkillData.SkillRangeType.CROSS_1
	))

	# 월광난타 - Moonlight Barrage: 다단 AoE
	_register_skill(_create_attack_skill(
		"moonlight_barrage",
		"월광난타",
		"A furious multi-hit combo under pale moonlight.",
		25, 46, 0, 3.0, SkillData.SkillElement.NONE, SkillData.SkillRangeType.SQUARE_3x3
	))

	# 여의난무 - Ruyi Rampage: 최종 AoE
	_register_skill(_create_attack_skill(
		"ruyi_rampage",
		"여의난무",
		"Extends the Ruyi Jingu Bang to its full size and rampages across the battlefield.",
		30, 62, 0, 3.5, SkillData.SkillElement.NONE, SkillData.SkillRangeType.SQUARE_3x3
	))

	# 금강잔영 - Golden Afterimage: 궁극기 (힐+공격)
	_register_skill(_create_attack_skill(
		"golden_afterimage",
		"금강잔영",
		"The ultimate technique — a golden blur that heals allies and obliterates enemies.",
		35, 80, 0, 4.0, SkillData.SkillElement.NONE, SkillData.SkillRangeType.SQUARE_3x3
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
		"sanzang": [
			"gentle_heal", "purify", "holy_water", "life_drain",
			"greater_heal", "restore", "silence",
			"divine_heal", "full_restore", "summon_spirit"
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