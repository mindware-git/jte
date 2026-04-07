class_name ElementalSlope
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 오행산 중턱 (五行山 中層)
# 청목진에서 봉인석으로 가는 산길
# 바위귀신이 길을 막고 있음
# ═══════════════════════════════════════════════════════════════════════════════

const LOCATION_ID := "elemental_slope"


static func get_location_data() -> LocationData:
	return LocationData.create(
		LOCATION_ID,
		"LOC_ELEMENTAL_SLOPE",
		"LOC_ELEMENTAL_SLOPE_DESC",
		["bluewood_village", "plum_altar"],
		["rock_spirit", "dead_tree"]
	)


static func get_interactions() -> Array[InteractionData]:
	return [
		InteractionData.npc("rock_spirit", "INTERACT_ROCK_SPIRIT", "rock_spirit"),
		InteractionData.investigate("dead_tree", "INTERACT_DEAD_TREE"),
		InteractionData.battle("rock_spirit_battle", "INTERACT_BATTLE_ROCK_SPIRIT", "rock_demon"),
	]


## RNA 상태에 따른 동적 인터랙션
static func get_available_interactions(rna: Dictionary) -> Array[InteractionData]:
	var interactions := get_interactions()
	
	# 산깨비 죽통 사용 후 바위귀신 사라짐
	if rna.get("flags", {}).get("rock_spirit_cleared", false):
		interactions.clear()
		interactions.append(
			InteractionData.investigate("cleared_path", "INTERACT_CLEARED_PATH")
		)
	
	return interactions