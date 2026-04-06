class_name MountainEntrance
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 산길입구
# 청목진에서 오행봉으로 오르는 입구
# 바위귀신이 길을 막고 있다
# ═══════════════════════════════════════════════════════════════════════════════

const LOCATION_ID := "mountain_entrance"


static func get_location_data() -> LocationData:
	return LocationData.create(
		LOCATION_ID,
		"LOC_MOUNTAIN_ENTRANCE",
		"LOC_MOUNTAIN_ENTRANCE_DESC",
		["cheongmok_village", "mountain_mid"],
		["rock_demon"]
	)


static func get_interactions() -> Array[InteractionData]:
	return [
		InteractionData.battle("rock_demon", "INTERACT_ROCK_DEMON", "rock_demon"),
	]


## RNA 상태에 따른 동적 인터랙션
## 바위귀신 처치 후: 길이 열림, 추가 조사 포인트
static func get_available_interactions(rna: Dictionary) -> Array[InteractionData]:
	var interactions: Array[InteractionData] = []
	
	# 바위귀신을 아직 처치하지 않았으면 전투 가능
	if not rna.get("flags", {}).get("rock_demon_defeated", false):
		interactions.append(InteractionData.battle("rock_demon", "INTERACT_ROCK_DEMON", "rock_demon"))
	else:
		# 처치 후: 죽은 나무 조사 포인트 추가
		interactions.append(InteractionData.investigate("dead_tree", "INTERACT_DEAD_TREE", "sangkkaebi_bomb"))
	
	return interactions