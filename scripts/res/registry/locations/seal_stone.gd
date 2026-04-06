class_name SealStone
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 봉인석 (封印石)
# 손오공이 봉인된 돌, 봉인을 풀면 연등숲으로 이어진다
# ═══════════════════════════════════════════════════════════════════════════════

const LOCATION_ID := "seal_stone"


static func get_location_data() -> LocationData:
	return LocationData.create(
		LOCATION_ID,
		"LOC_SEAL_STONE",
		"LOC_SEAL_STONE_DESC",
		["shrine", "forest_entrance"],
		["seal"]
	)


static func get_interactions() -> Array[InteractionData]:
	return [
		InteractionData.story("seal", "INTERACT_SEAL", "act1_seal_release"),
	]


## RNA 상태에 따른 동적 인터랙션
## 봉인 해제 전: 봉인 상호작용, 해제 후: 손오공 대화
static func get_available_interactions(rna: Dictionary) -> Array[InteractionData]:
	var interactions: Array[InteractionData] = []
	
	if not rna.get("flags", {}).get("wukong_unsealed", false):
		# 봉인 해제 전
		interactions.append(InteractionData.story("seal", "INTERACT_SEAL", "act1_seal_release"))
	else:
		# 봉인 해제 후: 손오공과 대화 가능
		interactions.append(InteractionData.npc("wukong_seal", "INTERACT_WUKONG_SEAL", "wukong"))
	
	return interactions