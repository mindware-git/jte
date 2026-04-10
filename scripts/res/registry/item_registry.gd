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
	# 기본 아이템 등록
	_register_item(_create_potion())
	_register_item(_create_ether())
	_register_item(_create_antidote())
	_register_item(_create_fire_bomb())
	_register_item(_create_smoke_ball())


func _register_item(item: ItemData) -> void:
	_items[item.id] = item


func get_item(item_id: String) -> ItemData:
	return _items.get(item_id)


func has_item(item_id: String) -> bool:
	return _items.has(item_id)


func get_all_items() -> Array[ItemData]:
	var result: Array[ItemData] = []
	for key in _items.keys():
		result.append(_items[key])
	return result


# ═══════════════════════════════════════════════════════════════════════════════
# Item Factory Methods
# ═══════════════════════════════════════════════════════════════════════════════

func _create_potion() -> ItemData:
	var item := ItemData.new()
	item.id = "potion"
	item.name = "회복약"
	item.description = "HP를 50 회복한다."
	item.type = ItemData.ItemType.CONSUMABLE
	item.price_buy = 50
	item.price_sell = 25
	item.target_type = ItemData.ItemTargetType.ALLY
	item.use_range = 3
	return item


func _create_ether() -> ItemData:
	var item := ItemData.new()
	item.id = "ether"
	item.name = "에테르"
	item.description = "MP를 30 회복한다."
	item.type = ItemData.ItemType.CONSUMABLE
	item.price_buy = 100
	item.price_sell = 50
	item.target_type = ItemData.ItemTargetType.ALLY
	item.use_range = 3
	return item


func _create_antidote() -> ItemData:
	var item := ItemData.new()
	item.id = "antidote"
	item.name = "해독제"
	item.description = "독 상태를 치료한다."
	item.type = ItemData.ItemType.CONSUMABLE
	item.price_buy = 100
	item.price_sell = 50
	item.target_type = ItemData.ItemTargetType.ALLY
	item.use_range = 3
	return item


func _create_fire_bomb() -> ItemData:
	var item := ItemData.new()
	item.id = "fire_bomb"
	item.name = "화염탄"
	item.description = "적에게 불속성 데미지를 입힌다."
	item.type = ItemData.ItemType.CONSUMABLE
	item.price_buy = 80
	item.price_sell = 40
	item.target_type = ItemData.ItemTargetType.ENEMY
	item.use_range = 4
	return item


func _create_smoke_ball() -> ItemData:
	var item := ItemData.new()
	item.id = "smoke_ball"
	item.name = "연막탄"
	item.description = "전투에서 도망칠 확률을 높인다."
	item.type = ItemData.ItemType.CONSUMABLE
	item.price_buy = 60
	item.price_sell = 30
	item.target_type = ItemData.ItemTargetType.SELF
	item.use_range = 0
	return item
