class_name MountainMid
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 산길중턱
# 오행봉 중턱, 오색 매화가 심긴 제단으로 가는 길
# ═══════════════════════════════════════════════════════════════════════════════

const LOCATION_ID := "mountain_mid"


static func get_location_data() -> LocationData:
	return LocationData.create(
		LOCATION_ID,
		"LOC_MOUNTAIN_MID",
		"LOC_MOUNTAIN_MID_DESC",
		["mountain_entrance", "shrine"],
		["shrine_mid"]
	)


static func get_interactions() -> Array[InteractionData]:
	return [
		InteractionData.puzzle("shrine_mid", "INTERACT_SHRINE"),
	]


static func get_available_interactions(rna: Dictionary) -> Array[InteractionData]:
	return get_interactions()