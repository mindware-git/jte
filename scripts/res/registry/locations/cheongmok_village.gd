class_name CheongmokVillage
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 청목진 (靑木鎭)
# 변경의 작은 마을, 밤마다 이상한 소문이 돈다
# Part 1 시작점
# ═══════════════════════════════════════════════════════════════════════════════

const LOCATION_ID := "cheongmok_village"


static func get_location_data() -> LocationData:
	return LocationData.create(
		LOCATION_ID,
		"LOC_CHEONGMOK",
		"LOC_CHEONGMOK_DESC",
		["mountain_entrance"],
		["tavern", "general_store", "well"]
	)


static func get_interactions() -> Array[InteractionData]:
	return [
		InteractionData.npc("tavern", "INTERACT_TAVERN", "old_man"),
		InteractionData.shop("general_store", "INTERACT_GENERAL_STORE"),
		InteractionData.investigate("well", "INTERACT_WELL"),
	]


## RNA 상태에 따른 동적 인터랙션
## 예: 손오공 합류 후 추가 대화 등
static func get_available_interactions(rna: Dictionary) -> Array[InteractionData]:
	var interactions := get_interactions()
	
	# 손오공 합류 후 우물 뒤 숨겨진 길 발견
	if rna.get("flags", {}).get("wukong_unsealed", false):
		if not rna.get("flags", {}).get("hidden_path_found", false):
			interactions.append(
				InteractionData.investigate("hidden_path", "INTERACT_HIDDEN_PATH")
			)
	
	return interactions