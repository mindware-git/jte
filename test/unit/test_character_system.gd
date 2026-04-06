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


func test_sanzang_is_healer() -> void:
	var sanzang := _char_registry.get_character("sanzang")
	var wukong := _char_registry.get_character("wukong")
	
	# 삼장은 MP가 높고 공격력이 낮음
	assert_gt(sanzang.max_mp, wukong.max_mp, "삼장 MP > 손오공 MP")
	assert_lt(sanzang.melee_power, wukong.melee_power, "삼장 공격력 < 손오공 공격력")


func test_wukong_is_attacker() -> void:
	var wukong := _char_registry.get_character("wukong")
	var sanzang := _char_registry.get_character("sanzang")
	
	# 손오공은 HP, 공격력이 높음
	assert_gt(wukong.max_hp, sanzang.max_hp, "손오공 HP > 삼장 HP")
	assert_gt(wukong.melee_power, sanzang.melee_power, "손오공 공격력 > 삼장 공격력")


func test_wukong_can_fly() -> void:
	var wukong := _char_registry.get_character("wukong")
	assert_true(wukong.is_flying, "손오공은 근운으로 비행 가능")


# ═══════════════════════════════════════════════════════════════════════════════
# SkillRegistry Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_has_sanzang_skills() -> void:
	assert_true(_skill_registry.has_skill("cheongsim_jineon"), "청심진언이 있어야 함")
	assert_true(_skill_registry.has_skill("daebe_jineon"), "대비진언이 있어야 함")


func test_has_wukong_skills() -> void:
	assert_true(_skill_registry.has_skill("dolwonsungi"), "돌원숭이치기가 있어야 함")
	assert_true(_skill_registry.has_skill("yeoui_nanmu"), "여의난무가 있어야 함")


func test_get_sanzang_skills() -> void:
	var skills := _skill_registry.get_skills_for_character("sanzang")
	assert_gt(skills.size(), 0, "삼장 스킬이 있어야 함")
	
	# 첫 스킬은 청심진언
	var first := skills[0]
	assert_eq(first.id, "cheongsim_jineon", "첫 스킬은 청심진언")


func test_get_wukong_skills() -> void:
	var skills := _skill_registry.get_skills_for_character("wukong")
	assert_gt(skills.size(), 0, "손오공 스킬이 있어야 함")
	
	# 첫 스킬은 돌원숭이치기
	var first := skills[0]
	assert_eq(first.id, "dolwonsungi", "첫 스킬은 돌원숭이치기")


# ═══════════════════════════════════════════════════════════════════════════════
# Skill Data Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_heal_skill_properties() -> void:
	var skill := _skill_registry.get_skill("cheongsim_jineon")
	assert_eq(skill.type, SkillData.SkillType.HEAL, "치유 타입이어야 함")
	assert_eq(skill.heal_amount, 30, "회복량이 30이어야 함")
	assert_eq(skill.mp_cost, 8, "MP 소모가 8이어야 함")


func test_attack_skill_properties() -> void:
	var skill := _skill_registry.get_skill("dolwonsungi")
	assert_eq(skill.type, SkillData.SkillType.ATTACK, "공격 타입이어야 함")
	assert_eq(skill.damage_multiplier, 1.5, "데미지 배율이 1.5여야 함")
	assert_eq(skill.element, SkillData.SkillElement.EARTH, "땅 속성이어야 함")


func test_buff_skill_properties() -> void:
	var skill := _skill_registry.get_skill("wonsung_bunsin")
	assert_eq(skill.type, SkillData.SkillType.BUFF, "버프 타입이어야 함")
	assert_eq(skill.buff_type, "speed", "속도 버프여야 함")
	assert_eq(skill.buff_value, 8, "버프 수치가 8이어야 함")


func test_debuff_skill_properties() -> void:
	var skill := _skill_registry.get_skill("janwonsung_utum")
	assert_eq(skill.type, SkillData.SkillType.DEBUFF, "디버프 타입이어야 함")
	assert_eq(skill.buff_type, "speed", "속도 디버프여야 함")


func test_skill_unlock_levels() -> void:
	# 저레벨 스킬
	var low_skill := _skill_registry.get_skill("cheongsim_jineon")
	assert_eq(low_skill.unlock_level, 1, "청심진언은 1레벨에 해금")
	
	# 고레벨 스킬
	var high_skill := _skill_registry.get_skill("yeoui_nanmu")
	assert_eq(high_skill.unlock_level, 20, "여의난무는 20레벨에 해금")


# ═══════════════════════════════════════════════════════════════════════════════
# Element Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_wukong_fire_skill() -> void:
	var skill := _skill_registry.get_skill("jujak_nanbong")
	assert_eq(skill.element, SkillData.SkillElement.FIRE, "주작난봉은 불 속성")


func test_wukong_wind_skill() -> void:
	var skill := _skill_registry.get_skill("cheongryong_bonggyeok")
	assert_eq(skill.element, SkillData.SkillElement.WIND, "청룡봉격은 바람 속성")


func test_wukong_water_skill() -> void:
	var skill := _skill_registry.get_skill("hyeonmu_geochi")
	assert_eq(skill.element, SkillData.SkillElement.WATER, "현무거치는 물 속성")