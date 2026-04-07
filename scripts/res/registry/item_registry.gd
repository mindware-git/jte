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
	# 회복약 - Potion: HP 50 회복
	_register_item(_create_consumable(
		"potion",
		"Potion",
		"Restores 50 HP.",
		50, {"hp": 50}
	))
	
	# 에테르 - Ether: MP 30 회복
	_register_item(_create_consumable(
		"ether",
		"Ether",
		"Restores 30 MP.",
		100, {"mp": 30}
	))
	
	# 해독제 - Antidote: 상태이상 해제
	_register_item(_create_consumable(
		"antidote",
		"Antidote",
		"Cures status ailments.",
		100, {"status_cure": 1}
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