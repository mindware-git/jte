class_name ItemRegistry
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# ItemRegistry
# 아이템 데이터 레지스트리
# ═══════════════════════════════════════════════════════════════════════════════

var _items: Dictionary = {}


func _init() -> void:
	_register_all_items()


func _register_all_items() -> void:
	_register_consumables()


# ═══════════════════════════════════════════════════════════════════════════════
# Consumables (소모품)
# ═══════════════════════════════════════════════════════════════════════════════

func _register_consumables() -> void:
	# 회복약 - Potion: HP 50 회복 (아군 대상)
	_register_item(_create_targeted_consumable(
		"potion",
		"Potion",
		"Restores 50 HP.",
		50, {"hp": 50},
		ItemData.ItemTargetType.ALLY, 99
	))
	
	# 에테르 - Ether: MP 30 회복 (아군 대상)
	_register_item(_create_targeted_consumable(
		"ether",
		"Ether",
		"Restores 30 MP.",
		100, {"mp": 30},
		ItemData.ItemTargetType.ALLY, 99
	))
	
	# 해독제 - Antidote: 상태이상 해제 (아군 대상)
	_register_item(_create_targeted_consumable(
		"antidote",
		"Antidote",
		"Cures status ailments.",
		100, {"status_cure": 1},
		ItemData.ItemTargetType.ALLY, 99
	))
	
	# 화염탄 - Fire Bomb: 적에게 40 데미지 (적 대상, 사거리 5)
	_register_item(_create_targeted_consumable(
		"fire_bomb",
		"Fire Bomb",
		"Deals 40 damage to enemy.",
		80, {"damage": 40},
		ItemData.ItemTargetType.ENEMY, 5
	))
	
	# 연막탄 - Smoke Ball: 자신에게 사용 (회피율 증가)
	_register_item(_create_targeted_consumable(
		"smoke_ball",
		"Smoke Ball",
		"Creates smokescreen, increases evasion.",
		60, {"evasion": 1},
		ItemData.ItemTargetType.SELF, 0
	))


# ═══════════════════════════════════════════════════════════════════════════════
# Factory Methods
# ═══════════════════════════════════════════════════════════════════════════════

func _create_consumable(
	p_id: String,
	p_name: String,
	p_desc: String,
	p_price: int,
	p_effect: Dictionary
) -> ItemData:
	var item := ItemData.new()
	item.id = p_id
	item.name = p_name
	item.description = p_desc
	item.type = ItemData.ItemType.CONSUMABLE
	item.rarity = ItemData.ItemRarity.COMMON
	item.price_coin = p_price
	item.stat_bonus = p_effect
	return item


func _create_targeted_consumable(
	p_id: String,
	p_name: String,
	p_desc: String,
	p_price: int,
	p_effect: Dictionary,
	p_target: ItemData.ItemTargetType,
	p_range: int
) -> ItemData:
	var item := _create_consumable(p_id, p_name, p_desc, p_price, p_effect)
	item.target_type = p_target
	item.use_range = p_range
	return item


func _register_item(item: ItemData) -> void:
	_items[item.id] = item


# ═══════════════════════════════════════════════════════════════════════════════
# 조회 메서드
# ═══════════════════════════════════════════════════════════════════════════════

func get_item(id: String) -> ItemData:
	return _items.get(id)


func has_item(id: String) -> bool:
	return _items.has(id)


func get_all_items() -> Array[ItemData]:
	var result: Array[ItemData] = []
	for key in _items.keys():
		result.append(_items[key])
	return result