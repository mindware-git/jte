class_name DonglimTemple
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 동림사 (東林寺)
# 삼장이 머무는 사찰, Part 2 시작점
# ═══════════════════════════════════════════════════════════════════════════════

const LOCATION_ID := "donglim_temple"


static func get_location_data() -> LocationData:
	return LocationData.create(
		LOCATION_ID,
		"LOC_DONGLIM_TEMPLE",
		"LOC_DONGLIM_TEMPLE_DESC",
		["myeongju_city"],
		["temple_main_hall", "monk_quarters"]
	)


static func get_interactions() -> Array[InteractionData]:
	return [
		InteractionData.npc("temple_main_hall", "INTERACT_TEMPLE_MAIN_HALL", "head_monk"),
		InteractionData.investigate("monk_quarters", "INTERACT_MONK_QUARTERS"),
	]


static func get_available_interactions(rna: Dictionary) -> Array[InteractionData]:
	var interactions := get_interactions()
	
	# TODO: Part 2 진행에 따른 동적 인터랙션
	# 예: 저팔계, 사오정 합류 후 대화 추가
	
	return interactions