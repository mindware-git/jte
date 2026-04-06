class_name SkillData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# SkillData
# 스킬 데이터 구조
# ═══════════════════════════════════════════════════════════════════════════════

enum SkillType {
	ATTACK,      ## 공격 스킬
	HEAL,        ## 치유 스킬
	BUFF,        ## 버프 스킬
	DEBUFF       ## 디버프 스킬
}

enum SkillElement {
	NONE,        ## 무속성
	FIRE,        ## 불
	WATER,       ## 물
	WIND,        ## 바람
	EARTH        ## 흙
}

var id: String = ""
var name: String = ""
var description: String = ""
var type: SkillType = SkillType.ATTACK
var element: SkillElement = SkillElement.NONE

# 습득 조건
var unlock_level: int = 1

# 비용
var mp_cost: int = 10

# 효과
var damage_multiplier: float = 1.0  # 기본 공격력 배수
var heal_amount: int = 0
var buff_type: String = ""  # "attack", "defense", "speed"
var buff_value: int = 0
var buff_duration: int = 3  # 턴 수

# 아이콘
var icon_path: String = ""

# ═══════════════════════════════════════════════════════════════════════════════
# Serialization
# ═══════════════════════════════════════════════════════════════════════════════

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"type": type,
		"element": element,
		"unlock_level": unlock_level,
		"mp_cost": mp_cost,
		"damage_multiplier": damage_multiplier,
		"heal_amount": heal_amount,
		"buff_type": buff_type,
		"buff_value": buff_value,
		"buff_duration": buff_duration,
		"icon_path": icon_path,
	}


func from_dict(dict: Dictionary) -> void:
	id = dict.get("id", "")
	name = dict.get("name", "")
	description = dict.get("description", "")
	type = dict.get("type", SkillType.ATTACK)
	element = dict.get("element", SkillElement.NONE)
	unlock_level = dict.get("unlock_level", 1)
	mp_cost = dict.get("mp_cost", 10)
	damage_multiplier = dict.get("damage_multiplier", 1.0)
	heal_amount = dict.get("heal_amount", 0)
	buff_type = dict.get("buff_type", "")
	buff_value = dict.get("buff_value", 0)
	buff_duration = dict.get("buff_duration", 3)
	icon_path = dict.get("icon_path", "")


# ═══════════════════════════════════════════════════════════════════════════════
# Display Helpers
# ═══════════════════════════════════════════════════════════════════════════════

func get_type_name() -> String:
	match type:
		SkillType.ATTACK: return "공격"
		SkillType.HEAL: return "치유"
		SkillType.BUFF: return "버프"
		SkillType.DEBUFF: return "디버프"
		_: return "기타"


func get_element_name() -> String:
	match element:
		SkillElement.NONE: return "무속성"
		SkillElement.FIRE: return "불"
		SkillElement.WATER: return "물"
		SkillElement.WIND: return "바람"
		SkillElement.EARTH: return "흙"
		_: return "무속성"


func get_element_color() -> Color:
	match element:
		SkillElement.NONE: return Color(0.7, 0.7, 0.7)
		SkillElement.FIRE: return Color(1.0, 0.3, 0.3)
		SkillElement.WATER: return Color(0.3, 0.5, 1.0)
		SkillElement.WIND: return Color(0.3, 0.8, 0.5)
		SkillElement.EARTH: return Color(0.7, 0.5, 0.3)
		_: return Color(0.7, 0.7, 0.7)


func get_effect_description() -> String:
	match type:
		SkillType.ATTACK:
			return "공격력 x%.1f 배" % damage_multiplier
		SkillType.HEAL:
			return "HP %d 회복" % heal_amount
		SkillType.BUFF:
			return "%s +%d (%d턴)" % [_get_buff_display_name(), buff_value, buff_duration]
		SkillType.DEBUFF:
			return "%s -%d (%d턴)" % [_get_buff_display_name(), buff_value, buff_duration]
		_:
			return ""


func _get_buff_display_name() -> String:
	match buff_type:
		"attack": return "공격력"
		"defense": return "방어력"
		"speed": return "속도"
		_: return buff_type