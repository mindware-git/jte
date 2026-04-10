class_name ShopData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# ShopData
# 상점 데이터 구조 (간소화)
# ═══════════════════════════════════════════════════════════════════════════════

const ItemRegistryClass := preload("res://scripts/res/registry/item_registry.gd")

## 상점 ID
var id: String = ""

## 상점 이름 번역 키
var name_key: String = ""

## 위치 ID
var location_id: String = ""

## 판매 아이템 ID 목록
var item_ids: Array[String] = []

## 아이템 레지스트리 참조
var _item_registry: RefCounted = null


# ═══════════════════════════════════════════════════════════════════════════════
# Factory
# ═══════════════════════════════════════════════════════════════════════════════

static func create(p_id: String, p_name_key: String) -> ShopData:
	var shop := ShopData.new()
	shop.id = p_id
	shop.name_key = p_name_key
	return shop


# ═══════════════════════════════════════════════════════════════════════════════
# Item Management
# ═══════════════════════════════════════════════════════════════════════════════

func add_item(item_id: String) -> void:
	item_ids.append(item_id)


func add_items(items: Array[String]) -> void:
	for item_id in items:
		item_ids.append(item_id)


func has_item(item_id: String) -> bool:
	return item_id in item_ids


func get_item_ids() -> Array[String]:
	return item_ids


# ═══════════════════════════════════════════════════════════════════════════════
# Price
# ═══════════════════════════════════════════════════════════════════════════════

## 플레이어가 구매할 때 가격 (상점에서 파는 가격)
func get_sell_price(item_id: String) -> int:
	var item := _get_item(item_id)
	return item.price_buy if item else 0


## 플레이어가 판매할 때 가격 (상점에서 사는 가격)
func get_buy_price(item_id: String) -> int:
	var item := _get_item(item_id)
	return item.price_sell if item else 0


func _get_item(item_id: String) -> ItemData:
	if _item_registry == null:
		_item_registry = ItemRegistryClass.new()
	return _item_registry.get_item(item_id)
