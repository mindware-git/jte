extends GutTest

# ═══════════════════════════════════════════════════════════════════════════════
# 캐릭터/스킬 시스템 테스트
# ═══════════════════════════════════════════════════════════════════════════════

var _char_registry: CharacterRegistry
var _skill_registry: SkillRegistry


func before_each() -> void:
	_char_registry = CharacterRegistry.new()
	_skill_registry = SkillRegistry.new()


# ═══════════════════════════════════════════════════════════════════════════════
# CharacterRegistry Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_has_sanzang() -> void:
	assert_true(_char_registry.has_character("sanzang"), "삼장이 존재해야 함")


func test_has_wukong() -> void:
	assert_true(_char_registry.has_character("wukong"), "손오공이 존재해야 함")


func test_get_sanzang() -> void:
	var char_data := _char_registry.get_character("sanzang")
	assert_not_null(char_data, "삼장 데이터가 있어야 함")
	assert_eq(char_data.id, "sanzang", "ID가 올바라야 함")
	assert_eq(char_data.display_name, "삼장법사", "이름이 올바라야 함")


func test_get_wukong() -> void:
	var char_data := _char_registry.get_character("wukong")
	assert_not_null(char_data, "손오공 데이터가 있어야 함")
	assert_eq(char_data.id, "wukong", "ID가 올바라야 함")
	assert_eq(char_data.display_name, "손오공", "이름이 올바라야 함")


func test_sanzang_has_high_mp() -> void:
	var sanzang := _char_registry.get_character("sanzang")
	var wukong := _char_registry.get_character("wukong")
	
	# 삼장은 MP가 높음
	assert_gt(sanzang.max_mp, wukong.max_mp, "삼장 MP > 손오공 MP")


func test_wukong_has_high_hp() -> void:
	var wukong := _char_registry.get_character("wukong")
	var sanzang := _char_registry.get_character("sanzang")
	
	# 손오공은 HP가 높음
	assert_gt(wukong.max_hp, sanzang.max_hp, "손오공 HP > 삼장 HP")


# ═══════════════════════════════════════════════════════════════════════════════
# SkillRegistry Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_has_sanzang_skills() -> void:
	assert_true(_skill_registry.has_skill("low_heal"), "로우 힐이 있어야 함")
	assert_true(_skill_registry.has_skill("cure"), "큐어가 있어야 함")


func test_get_sanzang_skills() -> void:
	var skills := _skill_registry.get_skills_for_character("sanzang")
	assert_gt(skills.size(), 0, "삼장 스킬이 있어야 함")


# ═══════════════════════════════════════════════════════════════════════════════
# Skill Data Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_heal_skill_properties() -> void:
	var skill := _skill_registry.get_skill("low_heal")
	assert_eq(skill.type, SkillData.SkillType.HEAL, "치유 타입이어야 함")
	assert_eq(skill.heal_amount, 60, "회복량이 60이어야 함")
	assert_eq(skill.mp_cost, 5, "MP 소모가 5이어야 함")


func test_attack_skill_properties() -> void:
	var skill := _skill_registry.get_skill("holy_water")
	assert_eq(skill.type, SkillData.SkillType.ATTACK, "공격 타입이어야 함")
	assert_eq(skill.damage_multiplier, 1.5, "데미지 배율이 1.5여야 함")


func test_buff_skill_properties() -> void:
	var skill := _skill_registry.get_skill("recover")
	assert_eq(skill.type, SkillData.SkillType.BUFF, "버프 타입이어야 함")
	assert_eq(skill.buff_type, "remove_debuff", "상태이상 제거여야 함")


func test_debuff_skill_properties() -> void:
	var skill := _skill_registry.get_skill("silence")
	assert_eq(skill.type, SkillData.SkillType.DEBUFF, "디버프 타입이어야 함")
	assert_eq(skill.buff_type, "silence", "침묵 디버프여야 함")


func test_skill_unlock_levels() -> void:
	# 저레벨 스킬
	var low_skill := _skill_registry.get_skill("low_heal")
	assert_eq(low_skill.unlock_level, 1, "로우 힐은 1레벨에 해금")
	
	# 고레벨 스킬
	var high_skill := _skill_registry.get_skill("refresh")
	assert_eq(high_skill.unlock_level, 30, "리프레쉬는 30레벨에 해금")