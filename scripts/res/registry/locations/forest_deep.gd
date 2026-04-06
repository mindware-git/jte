class_name ForestDeep
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 연등숲심부 (燃燈林深處)
# 화령들의 축제가 벌어지는 숲의 깊은 곳, 등롱 퍼즐을 풀어야 한다
# Part 1 클라이맥스
# ═══════════════════════════════════════════════════════════════════════════════

const LOCATION_ID := "forest_deep"


static func get_location_data() -> LocationData:
	return LocationData.create(
		LOCATION_ID,
		"LOC_FOREST_DEEP",
		"LOC_FOREST_DEEP_DESC",
		["forest_entrance"],
		["lantern_puzzle", "fire_spirit_boss"]
	)


static func get_interactions() -> Array[InteractionData]:
	return [
		InteractionData.puzzle("lantern_puzzle", "INTERACT_LANTERN_PUZZLE"),
		InteractionData.battle("fire_spirit_boss", "INTERACT_FIRE_SPIRIT_BOSS", "fire_spirit_boss"),
	]


## RNA 상태에 따른 동적 인터랙션
## 등롱 퍼즐 완료 후: 보스 전투 가능
static func get_available_interactions(rna: Dictionary) -> Array[InteractionData]:
	var interactions: Array[InteractionData] = []
	
	# 등롱 퍼즐 미완료: 퍼즐만
	if not rna.get("flags", {}).get("lantern_puzzle_complete", false):
		interactions.append(InteractionData.puzzle("lantern_puzzle", "INTERACT_LANTERN_PUZZLE"))
	else:
		# 퍼즐 완료 후: 보스 전투
		if not rna.get("flags", {}).get("fire_spirit_boss_defeated", false):
			interactions.append(InteractionData.battle("fire_spirit_boss", "INTERACT_FIRE_SPIRIT_BOSS", "fire_spirit_boss"))
		else:
			# 보스 처치 후: 축제 완료
			interactions.append(InteractionData.story("festival_complete", "INTERACT_FESTIVAL_COMPLETE", "act1_ending"))
	
	return interactions