class_name ShopData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# ShopData
# 상점 데이터 구조
# ═══════════════════════════════════════════════════════════════════════════════

# Preload dependencies
const ItemRegistryClass := preload("res://scripts/res/registry/item_registry.gd")
const ItemDataClass := preload("res://scripts/res/item_data.gd")

## 상점 아이템 항목 (재고 관리용)
class ShopItemEntry:
	var item_id: String = ""
	var stock: int = -1  # -1은 무제한
	var discount_rate: float = 1.0  # 할인율 (1.0 = 100%, 정가)
	
	func _init(p_item_id: String, p_stock: int = -1, p_discount: float = 1.0) -> void:
		item_id = p_item_id
		stock = p_stock
		discount_rate = p_discount


## 상점 ID
var id: String = ""

## 상점 이름 번역 키
var name_key: String = ""

## 상점 설명 번역 키
var description_key: String = ""

## 판매 아이템 항목들
var sell_items: Array[ShopItemEntry] = []

## 구매 가능 여부 (플레이어가 아이템을 팔 수 있는지)
var can_buy_from_player: bool = true

## 구매 가격 배율 (플레이어가 팔 때 기본 가격의 몇 %인지)
var buy_price_rate: float = 0.5  # 50% 가격에 구매

## 판매 가격 배율 (플레이어가 살 때 기본 가격의 몇 %인지)
var sell_price_rate: float = 1.0  # 100% 가격에 판매

## RNA 조건 (상점 오픈 조건)
var required_flags: Dictionary = {}

## 아이템 레지스트리 참조
var _item_registry: RefCounted


# ═══════════════════════════════════════════════════════════════════════════════
# Factory Methods
# ═══════════════════════════════════════════════════════════════════════════════

static func create(
	p_id: String,
	p_name_key: String,
	p_desc_key: String = ""
) -> ShopData:
	var shop := ShopData.new()
	shop.id = p_id
	shop.name_key = p_name_key
	shop.description_key = p_desc_key
	shop._item_registry = ItemRegistryClass.new()
	return shop


static func with_items(
	p_id: String,
	p_name_key: String,
	p_items: Array[String]
) -> ShopData:
	var shop := create(p_id, p_name_key)
	for item_id in p_items:
		shop.add_item(item_id)
	return shop


# ═══════════════════════════════════════════════════════════════════════════════
# Item Management
# ═══════════════════════════════════════════════════════════════════════════════

func add_item(item_id: String, stock: int = -1, discount: float = 1.0) -> void:
	var entry := ShopItemEntry.new(item_id, stock, discount)
	sell_items.append(entry)


func add_items(item_ids: Array[String]) -> void:
	for item_id in item_ids:
		add_item(item_id)


func get_item_ids() -> Array[String]:
	var result: Array[String] = []
	for entry in sell_items:
		result.append(entry.item_id)
	return result


func get_entry(item_id: String) -> ShopItemEntry:
	for entry in sell_items:
		if entry.item_id == item_id:
			return entry
	return null


func has_item(item_id: String) -> bool:
	return get_entry(item_id) != null


# ═══════════════════════════════════════════════════════════════════════════════
# Price Calculation
# ═══════════════════════════════════════════════════════════════════════════════

## 플레이어가 구매할 때 가격 (상점에서 파는 가격)
func get_sell_price(item_id: String) -> int:
	var item := _get_item_data(item_id)
	if not item:
		return 0
	
	var entry := get_entry(item_id)
	var base_price := item.price_coin
	
	# 할인율 적용
	if entry and entry.discount_rate < 1.0:
		base_price = int(base_price * entry.discount_rate)
	
	# 판매 배율 적용
	return int(base_price * sell_price_rate)


## 플레이어가 판매할 때 가격 (상점에서 사는 가격)
func get_buy_price(item_id: String) -> int:
	var item := _get_item_data(item_id)
	if not item:
		return 0
	
	# 구매 배율 적용
	return int(item.price_coin * buy_price_rate)


func _get_item_data(item_id: String) -> ItemDataClass:
	if not _item_registry:
		_item_registry = ItemRegistryClass.new()
	return _item_registry.get_item(item_id)


# ═══════════════════════════════════════════════════════════════════════════════
# RNA Conditions
# ═══════════════════════════════════════════════════════════════════════════════

## RNA 상태로 상점 오픈 여부 확인
func is_available(rna: Dictionary) -> bool:
	if required_flags.is_empty():
		return true
	
	var flags: Dictionary = rna.get("flags", {})
	for flag_name in required_flags.keys():
		var required_value = required_flags[flag_name]
		var current_value = flags.get(flag_name)
		if current_value != required_value:
			return false
	
	return true


func set_required_flag(flag_name: String, value: Variant) -> void:
	required_flags[flag_name] = value


# ═══════════════════════════════════════════════════════════════════════════════
# Serialization
# ═══════════════════════════════════════════════════════════════════════════════

func to_dict() -> Dictionary:
	var items_data: Array[Dictionary] = []
	for entry in sell_items:
		items_data.append({
			"item_id": entry.item_id,
			"stock": entry.stock,
			"discount_rate": entry.discount_rate
		})
	
	return {
		"id": id,
		"name_key": name_key,
		"description_key": description_key,
		"sell_items": items_data,
		"can_buy_from_player": can_buy_from_player,
		"buy_price_rate": buy_price_rate,
		"sell_price_rate": sell_price_rate,
		"required_flags": required_flags
	}


func from_dict(dict: Dictionary) -> void:
	id = dict.get("id", "")
	name_key = dict.get("name_key", "")
	description_key = dict.get("description_key", "")
	can_buy_from_player = dict.get("can_buy_from_player", true)
	buy_price_rate = dict.get("buy_price_rate", 0.5)
	sell_price_rate = dict.get("sell_price_rate", 1.0)
	required_flags = dict.get("required_flags", {})
	
	sell_items.clear()
	var items_data: Array = dict.get("sell_items", [])
	for item_data in items_data:
		if item_data is Dictionary:
			var entry := ShopItemEntry.new(
				item_data.get("item_id", ""),
				item_data.get("stock", -1),
				item_data.get("discount_rate", 1.0)
			)
			sell_items.append(entry)
