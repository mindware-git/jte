class_name ForestEntrance
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 연등숲입구 (燃燈林入口)
# 화령들이 튀어 내려간 숲의 입구, 등롱이 흩어져 있다
# ═══════════════════════════════════════════════════════════════════════════════

const LOCATION_ID := "forest_entrance"


static func get_location_data() -> LocationData:
	return LocationData.create(
		LOCATION_ID,
		"LOC_FOREST_ENTRANCE",
		"LOC_FOREST_ENTRANCE_DESC",
		["seal_stone", "forest_deep"],
		["fire_spirit_entrance"]
	)


static func get_interactions() -> Array[InteractionData]:
	return [
		InteractionData.battle("fire_spirit_entrance", "INTERACT_FIRE_SPIRIT", "fire_spirit"),
	]


static func get_available_interactions(rna: Dictionary) -> Array[InteractionData]:
	var interactions := get_interactions()
	
	# 숨은 길 발견 시: 작은 염주 획득
	if rna.get("flags", {}).get("hidden_path_found", false):
		if not rna.get("flags", {}).get("small_rosary_obtained", false):
			interactions.append(InteractionData.investigate("hidden_path_entrance", "INTERACT_HIDDEN_PATH_ENTRANCE", "small_rosary"))
	
	return interactions