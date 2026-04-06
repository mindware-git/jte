class_name ItemData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# ItemData
# 아이템 데이터 구조
# ═══════════════════════════════════════════════════════════════════════════════

enum ItemType {
	WEAPON,      ## 무기
	ARMOR,       ## 방어구
	ACCESSORY,   ## 장신구
	CONSUMABLE   ## 소모품
}

enum ItemRarity {
	COMMON,      ## 일반
	UNCOMMON,    ## 고급
	RARE,        ## 희귀
	EPIC,        ## 영웅
	LEGENDARY    ## 전설
}

var id: String = ""
var name: String = ""
var description: String = ""
var type: ItemType = ItemType.WEAPON
var rarity: ItemRarity = ItemRarity.COMMON
var price_coin: int = 0
var price_gem: int = 0

# 스탯 보너스
var stat_bonus: Dictionary = {}  # { "attack": 5, "hp": 10, "mp": 5 }

# 아이콘 (나중에 리소스 경로)
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
		"rarity": rarity,
		"price_coin": price_coin,
		"price_gem": price_gem,
		"stat_bonus": stat_bonus,
		"icon_path": icon_path,
	}


func from_dict(dict: Dictionary) -> void:
	id = dict.get("id", "")
	name = dict.get("name", "")
	description = dict.get("description", "")
	type = dict.get("type", ItemType.WEAPON)
	rarity = dict.get("rarity", ItemRarity.COMMON)
	price_coin = dict.get("price_coin", 0)
	price_gem = dict.get("price_gem", 0)
	stat_bonus = dict.get("stat_bonus", {})
	icon_path = dict.get("icon_path", "")


# ═══════════════════════════════════════════════════════════════════════════════
# Display Helpers
# ═══════════════════════════════════════════════════════════════════════════════

func get_type_name() -> String:
	match type:
		ItemType.WEAPON: return "무기"
		ItemType.ARMOR: return "방어구"
		ItemType.ACCESSORY: return "장신구"
		ItemType.CONSUMABLE: return "소모품"
		_: return "기타"


func get_rarity_name() -> String:
	match rarity:
		ItemRarity.COMMON: return "일반"
		ItemRarity.UNCOMMON: return "고급"
		ItemRarity.RARE: return "희귀"
		ItemRarity.EPIC: return "영웅"
		ItemRarity.LEGENDARY: return "전설"
		_: return "일반"


func get_rarity_color() -> Color:
	match rarity:
		ItemRarity.COMMON: return Color(0.7, 0.7, 0.7)
		ItemRarity.UNCOMMON: return Color(0.3, 0.8, 0.3)
		ItemRarity.RARE: return Color(0.3, 0.5, 1.0)
		ItemRarity.EPIC: return Color(0.7, 0.3, 0.9)
		ItemRarity.LEGENDARY: return Color(1.0, 0.7, 0.2)
		_: return Color(0.7, 0.7, 0.7)


func get_stat_display() -> String:
	var parts: Array[String] = []
	for stat_name in stat_bonus.keys():
		var value: int = stat_bonus[stat_name]
		var stat_display := _get_stat_display_name(stat_name)
		parts.append("%s +%d" % [stat_display, value])
	return " | ".join(parts)


func _get_stat_display_name(stat: String) -> String:
	match stat:
		"hp": return "HP"
		"mp": return "MP"
		"attack": return "공격력"
		"defense": return "방어력"
		"speed": return "속도"
		_: return stat