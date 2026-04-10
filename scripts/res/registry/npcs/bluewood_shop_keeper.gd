class_name BluewoodShopKeeper
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# BlueWoodShopKeeper
# 청목진 상점 주인 NPC
# ═══════════════════════════════════════════════════════════════════════════════


static func get_npc_data() -> NPCData:
	var npc := NPCData.create(
		"bluewood_shop_keeper",
		"NPC_BLUEWOOD_SHOP_KEEPER",
		"bluewood_shop"
	)
	npc.npc_type = "shop"
	npc.shop_id = "bluewood_shop"
	return npc