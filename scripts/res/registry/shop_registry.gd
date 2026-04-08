class_name ShopRegistry
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# ShopRegistry
# 상점 데이터 레지스트리
# ═══════════════════════════════════════════════════════════════════════════════

# 상점 스크립트 preload
const GeneralStore := preload("res://scripts/res/registry/shops/general_store.gd")

var _shops: Dictionary = {}


func _init() -> void:
	_register_all_shops()


# ═══════════════════════════════════════════════════════════════════════════════
# Shop Registration
# ═══════════════════════════════════════════════════════════════════════════════

func _register_all_shops() -> void:
	# Part 1 상점들
	_register_shop(GeneralStore)
	# TODO: 더 많은 상점 추가


func _register_shop(shop_script: GDScript) -> void:
	var shop_data: ShopData = shop_script.get_shop_data.call()
	if shop_data:
		_shops[shop_data.id] = shop_data


func register_shop_data(shop_data: ShopData) -> void:
	_shops[shop_data.id] = shop_data


# ═══════════════════════════════════════════════════════════════════════════════
# Query Methods
# ═══════════════════════════════════════════════════════════════════════════════

func get_shop(shop_id: String) -> ShopData:
	return _shops.get(shop_id)


func has_shop(shop_id: String) -> bool:
	return _shops.has(shop_id)


func get_all_shops() -> Array[ShopData]:
	var result: Array[ShopData] = []
	for key in _shops.keys():
		result.append(_shops[key])
	return result


## RNA 상태에 따른 상점 오픈 여부 확인
func is_shop_available(shop_id: String, rna: Dictionary) -> bool:
	var shop := get_shop(shop_id)
	if not shop:
		return false
	return shop.is_available(rna)


## RNA 상태에 따른 판매 아이템 목록 조회
func get_shop_items(shop_id: String, rna: Dictionary) -> Array[String]:
	var shop := get_shop(shop_id)
	if not shop:
		return []
	
	if not shop.is_available(rna):
		return []
	
	return shop.get_item_ids()


## RNA 상태로 이용 가능한 상점 목록 조회
func get_available_shops(rna: Dictionary) -> Array[ShopData]:
	var result: Array[ShopData] = []
	for key in _shops.keys():
		var shop: ShopData = _shops[key]
		if shop.is_available(rna):
			result.append(shop)
	return result