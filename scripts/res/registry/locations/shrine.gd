class_name Shrine
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 오행제단 (五行祭壇)
# 오색 매화가 심긴 제단, 오행향로를 만드는 곳
# ═══════════════════════════════════════════════════════════════════════════════

const LOCATION_ID := "shrine"


static func get_location_data() -> LocationData:
	return LocationData.create(
		LOCATION_ID,
		"LOC_SHRINE",
		"LOC_SHRINE_DESC",
		["mountain_mid", "seal_stone"],
		["shrine_puzzle"]
	)


static func get_interactions() -> Array[InteractionData]:
	return [
		InteractionData.puzzle("shrine_puzzle", "INTERACT_SHRINE_PUZZLE"),
	]


## RNA 상태에 따른 동적 인터랙션
## 꽃정령과 대화 후 자비환 획득 가능
static func get_available_interactions(rna: Dictionary) -> Array[InteractionData]:
	var interactions := get_interactions()
	
	# 오행향로 완성 전: 꽃정령 대화
	if not rna.get("flags", {}).get("incense_burner_complete", false):
		interactions.append(InteractionData.npc("flower_spirit", "INTERACT_FLOWER_SPIRIT", "flower_spirit"))
	
	return interactions