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
	pass


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
