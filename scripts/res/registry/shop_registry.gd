class_name ShopRegistry
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# ShopRegistry
# 상점 데이터 레지스트리
# ═══════════════════════════════════════════════════════════════════════════════

const BlueWoodShopScript := preload("res://scripts/res/registry/shops/bluewood_shop.gd")

var _shops: Dictionary = {}


func _init() -> void:
	_register_all_shops()


func _register_all_shops() -> void:
	_register_shop(BlueWoodShopScript)


func _register_shop(shop_script: GDScript) -> void:
	var shop_data: ShopData = shop_script.get_shop_data.call()
	if shop_data:
		_shops[shop_data.id] = shop_data


# ═══════════════════════════════════════════════════════════════════════════════
# Query
# ═══════════════════════════════════════════════════════════════════════════════

func get_shop(shop_id: String) -> ShopData:
	return _shops.get(shop_id)


func get_shop_by_location(location_id: String) -> ShopData:
	for shop_id in _shops.keys():
		var shop: ShopData = _shops[shop_id]
		if shop.location_id == location_id:
			return shop
	return null


func has_shop(shop_id: String) -> bool:
	return _shops.has(shop_id)