extends GutTest

# ═══════════════════════════════════════════════════════════════════════════════
# Shop System Unit Tests
# ═══════════════════════════════════════════════════════════════════════════════

# Preload scripts
var _shop_registry_script := preload("res://scripts/res/registry/shop_registry.gd")
var _item_registry_script := preload("res://scripts/res/registry/item_registry.gd")

var _shop_data: ShopData
var _shop_registry: ShopRegistry
var _item_registry: ItemRegistry


func before_each() -> void:
	_shop_data = null
	_shop_registry = null
	_item_registry = _item_registry_script.new()


# ═══════════════════════════════════════════════════════════════════════════════
# ShopData Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_shop_data_creation() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST", "Test shop description")
	
	assert_eq(_shop_data.id, "test_shop", "Shop ID should match")
	assert_eq(_shop_data.name_key, "SHOP_TEST", "Shop name key should match")
	assert_eq(_shop_data.description_key, "Test shop description", "Shop description should match")
	assert_eq(_shop_data.sell_items.size(), 0, "New shop should have no items")


func test_shop_data_with_items() -> void:
	var items: Array[String] = ["potion", "ether", "antidote"]
	_shop_data = ShopData.with_items("test_shop", "SHOP_TEST", items)
	
	assert_eq(_shop_data.id, "test_shop", "Shop ID should match")
	assert_eq(_shop_data.sell_items.size(), 3, "Shop should have 3 items")
	assert_true(_shop_data.has_item("potion"), "Shop should have potion")
	assert_true(_shop_data.has_item("ether"), "Shop should have ether")
	assert_true(_shop_data.has_item("antidote"), "Shop should have antidote")


func test_shop_data_add_item() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST")
	_shop_data.add_item("potion")
	_shop_data.add_item("ether", 5)  # 재고 5개
	_shop_data.add_item("antidote", -1, 0.8)  # 20% 할인
	
	assert_eq(_shop_data.sell_items.size(), 3, "Shop should have 3 items")
	
	var potion_entry = _shop_data.get_entry("potion")
	assert_eq(potion_entry.stock, -1, "Potion should have unlimited stock")
	
	var ether_entry = _shop_data.get_entry("ether")
	assert_eq(ether_entry.stock, 5, "Ether should have stock of 5")
	
	var antidote_entry = _shop_data.get_entry("antidote")
	assert_eq(antidote_entry.discount_rate, 0.8, "Antidote should have 20% discount")


func test_shop_data_get_item_ids() -> void:
	var items: Array[String] = ["potion", "ether"]
	_shop_data = ShopData.with_items("test_shop", "SHOP_TEST", items)
	
	var item_ids = _shop_data.get_item_ids()
	assert_eq(item_ids.size(), 2, "Should return 2 item IDs")
	assert_true(item_ids.has("potion"), "Should contain potion")
	assert_true(item_ids.has("ether"), "Should contain ether")


func test_shop_data_has_item() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST")
	_shop_data.add_item("potion")
	
	assert_true(_shop_data.has_item("potion"), "Should have potion")
	assert_false(_shop_data.has_item("ether"), "Should not have ether")


# ═══════════════════════════════════════════════════════════════════════════════
# Price Calculation Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_shop_calculate_sell_price() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST")
	_shop_data.sell_price_rate = 1.0  # 정가
	_shop_data.add_item("potion")  # 기본 가격 50
	
	var price = _shop_data.get_sell_price("potion")
	assert_eq(price, 50, "Sell price should be 50 at 100% rate")


func test_shop_calculate_sell_price_with_discount() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST")
	_shop_data.sell_price_rate = 1.0
	_shop_data.add_item("potion", -1, 0.8)  # 20% 할인
	
	var price = _shop_data.get_sell_price("potion")
	assert_eq(price, 40, "Sell price should be 40 with 20% discount (50 * 0.8)")


func test_shop_calculate_buy_price() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST")
	_shop_data.add_item("potion")  # price_sell = 25
	
	var price = _shop_data.get_buy_price("potion")
	assert_eq(price, 25, "Buy price should be 25 (price_sell)")


func test_shop_price_rate_modification() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST")
	_shop_data.sell_price_rate = 1.5  # 150% 가격
	_shop_data.add_item("ether")  # price_buy = 100, price_sell = 50
	
	var sell_price = _shop_data.get_sell_price("ether")
	var buy_price = _shop_data.get_buy_price("ether")
	
	assert_eq(sell_price, 150, "Sell price should be 150 at 150% rate")
	assert_eq(buy_price, 50, "Buy price should be 50 (price_sell)")


# ═══════════════════════════════════════════════════════════════════════════════
# ShopRegistry Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_shop_registry_get_shop() -> void:
	_shop_registry = _shop_registry_script.new()
	
	var shop = _shop_registry.get_shop("general_store")
	assert_not_null(shop, "Should find general_store shop")
	assert_eq(shop.id, "general_store", "Shop ID should be general_store")


func test_shop_registry_has_shop() -> void:
	_shop_registry = _shop_registry_script.new()
	
	assert_true(_shop_registry.has_shop("general_store"), "Should have general_store")
	assert_false(_shop_registry.has_shop("nonexistent_shop"), "Should not have nonexistent_shop")


func test_shop_registry_get_shop_items() -> void:
	_shop_registry = _shop_registry_script.new()
	
	var rna := {}
	var items = _shop_registry.get_shop_items("general_store", rna)
	
	assert_true(items.size() > 0, "General store should have items")
	assert_true(items.has("potion"), "Should have potion")
	assert_true(items.has("ether"), "Should have ether")


func test_shop_registry_is_shop_available() -> void:
	_shop_registry = _shop_registry_script.new()
	
	var rna := {}
	var available = _shop_registry.is_shop_available("general_store", rna)
	
	assert_true(available, "General store should be available without conditions")


# ═══════════════════════════════════════════════════════════════════════════════
# RNA Conditions Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_shop_rna_conditions() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST")
	_shop_data.set_required_flag("wukong_unsealed", true)
	_shop_data.add_item("potion")
	
	# 조건 충족 안 됨
	var rna_no_flag := {"flags": {}}
	assert_false(_shop_data.is_available(rna_no_flag), "Should not be available without flag")
	
	# 조건 충족
	var rna_with_flag := {"flags": {"wukong_unsealed": true}}
	assert_true(_shop_data.is_available(rna_with_flag), "Should be available with correct flag")


func test_shop_no_conditions() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST")
	_shop_data.add_item("potion")
	
	# 조건 없으면 항상 가능
	var rna := {}
	assert_true(_shop_data.is_available(rna), "Should be available with no conditions")


# ═══════════════════════════════════════════════════════════════════════════════
# Serialization Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_shop_data_serialization() -> void:
	_shop_data = ShopData.create("test_shop", "SHOP_TEST", "Test description")
	_shop_data.add_item("potion")
	_shop_data.add_item("ether", 5, 0.9)
	_shop_data.sell_price_rate = 1.2
	_shop_data.buy_price_rate = 0.4
	
	var dict = _shop_data.to_dict()
	
	assert_eq(dict["id"], "test_shop", "Serialized ID should match")
	assert_eq(dict["name_key"], "SHOP_TEST", "Serialized name key should match")
	assert_eq(dict["sell_items"].size(), 2, "Should have 2 serialized items")
	assert_eq(dict["sell_price_rate"], 1.2, "Serialized sell price rate should match")
	assert_eq(dict["buy_price_rate"], 0.4, "Serialized buy price rate should match")


func test_shop_data_deserialization() -> void:
	var dict := {
		"id": "loaded_shop",
		"name_key": "SHOP_LOADED",
		"description_key": "Loaded shop",
		"sell_items": [
			{"item_id": "potion", "stock": 10, "discount_rate": 1.0},
			{"item_id": "ether", "stock": -1, "discount_rate": 0.9}
		],
		"can_buy_from_player": true,
		"buy_price_rate": 0.5,
		"sell_price_rate": 1.0,
		"required_flags": {}
	}
	
	_shop_data = ShopData.new()
	_shop_data.from_dict(dict)
	
	assert_eq(_shop_data.id, "loaded_shop", "Deserialized ID should match")
	assert_eq(_shop_data.sell_items.size(), 2, "Should have 2 deserialized items")
	assert_true(_shop_data.has_item("potion"), "Should have potion")
	assert_true(_shop_data.has_item("ether"), "Should have ether")


# ═══════════════════════════════════════════════════════════════════════════════
# ItemRegistry Integration Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_item_registry_items_exist() -> void:
	# 기본 아이템들이 존재하는지 확인
	assert_not_null(_item_registry.get_item("potion"), "Potion should exist")
	assert_not_null(_item_registry.get_item("ether"), "Ether should exist")
	assert_not_null(_item_registry.get_item("antidote"), "Antidote should exist")
	assert_not_null(_item_registry.get_item("fire_bomb"), "Fire bomb should exist")
	assert_not_null(_item_registry.get_item("smoke_ball"), "Smoke ball should exist")


func test_item_registry_prices() -> void:
	var potion = _item_registry.get_item("potion")
	assert_eq(potion.price_buy, 50, "Potion price should be 50")
	
	var ether = _item_registry.get_item("ether")
	assert_eq(ether.price_buy, 100, "Ether price should be 100")
