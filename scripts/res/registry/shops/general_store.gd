class_name GeneralStore
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# GeneralStore
# 잡화상 상점 데이터
# 청목진에 있는 기본 아이템 상점
# ═══════════════════════════════════════════════════════════════════════════════

const SHOP_ID := "general_store"


static func get_shop_data() -> ShopData:
	var shop := ShopData.create(
		SHOP_ID,
		"SHOP_GENERAL_STORE",
		"SHOP_GENERAL_STORE_DESC"
	)
	
	# 기본 아이템 목록
	shop.add_items([
		"potion",      # 회복약 50 코인
		"ether",       # 에테르 100 코인
		"antidote",    # 해독제 100 코인
		"fire_bomb",   # 화염탄 80 코인
		"smoke_ball",  # 연막탄 60 코인
	])
	
	# 플레이어가 아이템을 팔 수 있음
	shop.can_buy_from_player = true
	
	# 플레이어가 팔 때 50% 가격
	shop.buy_price_rate = 0.5
	
	# 플레이어가 살 때 정가
	shop.sell_price_rate = 1.0
	
	return shop