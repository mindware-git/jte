class_name BlueWoodShop
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# BlueWoodShop
# 청목진 상점 데이터
# ═══════════════════════════════════════════════════════════════════════════════

const SHOP_ID := "bluewood_shop"


static func get_shop_data() -> ShopData:
	var shop := ShopData.create(SHOP_ID, "SHOP_BLUEWOOD")
	shop.location_id = "bluewood_shop"
	shop.add_item("potion")
	return shop