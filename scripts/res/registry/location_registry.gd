class_name LocationRegistry
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# LocationRegistry
# 위치/상호작용 데이터 레지스트리
# 개별 위치 파일에서 데이터를 로드
# ═══════════════════════════════════════════════════════════════════════════════

# 위치 스크립트 preload
const BluewoodVillage := preload("res://scripts/res/registry/locations/bluewood_village.gd")
const ElementalSlope := preload("res://scripts/res/registry/locations/elemental_slope.gd")
const Shrine := preload("res://scripts/res/registry/locations/shrine.gd")
const SealStone := preload("res://scripts/res/registry/locations/seal_stone.gd")
const ForestEntrance := preload("res://scripts/res/registry/locations/forest_entrance.gd")
const ForestDeep := preload("res://scripts/res/registry/locations/forest_deep.gd")
const DonglimTemple := preload("res://scripts/res/registry/locations/donglim_temple.gd")

# 위치 데이터 맵
var _locations: Dictionary = {}

# 상호작용 데이터 맵
var _interactions: Dictionary = {}


func _init() -> void:
	_register_all_locations()


# ═══════════════════════════════════════════════════════════════════════════════
# 위치 등록
# ═══════════════════════════════════════════════════════════════════════════════

func _register_all_locations() -> void:
	# Part 1: 오행봉의 봉인
	_register_location(BluewoodVillage)
	_register_location(ElementalSlope)
	# _register_location(PlumAltar)
	# _register_location(MonkeySeal)
	# _register_location(LanternForest)
	
	# 기존 위치 (추후 정리)
	_register_location(Shrine)
	_register_location(SealStone)
	_register_location(ForestEntrance)
	_register_location(ForestDeep)
	
	# Part 2: 삼장법사의 동림사
	_register_location(DonglimTemple)
	# TODO: Part 2 나머지 위치 추가
	# _register_location(MyeongjuCity)
	# _register_location(TheaterBackstage)
	# _register_location(ObongHarbor)


func _register_location(loc_script: GDScript) -> void:
	# static 메서드 호출
	var loc_data: LocationData = loc_script.get_location_data.call()
	if loc_data:
		_locations[loc_data.id] = loc_data
		
		# 상호작용도 저장
		var interactions: Array = loc_script.get_interactions.call()
		for interact in interactions:
			_interactions[interact.id] = interact


# ═══════════════════════════════════════════════════════════════════════════════
# 조회 메서드 - 위치
# ═══════════════════════════════════════════════════════════════════════════════

func get_location(location_id: String) -> LocationData:
	return _locations.get(location_id)


func has_location(location_id: String) -> bool:
	return _locations.has(location_id)


func get_all_location_ids() -> Array[String]:
	var result: Array[String] = []
	for key in _locations.keys():
		result.append(key)
	return result


func get_connections(location_id: String) -> Array[String]:
	var loc := get_location(location_id)
	if loc:
		return loc.connections
	return []


func can_travel(from_id: String, to_id: String) -> bool:
	var connections := get_connections(from_id)
	return to_id in connections


# ═══════════════════════════════════════════════════════════════════════════════
# 조회 메서드 - 상호작용
# ═══════════════════════════════════════════════════════════════════════════════

func get_interaction(interaction_id: String) -> InteractionData:
	return _interactions.get(interaction_id)


func has_interaction(interaction_id: String) -> bool:
	return _interactions.has(interaction_id)


func get_interactions(location_id: String) -> Array[InteractionData]:
	var loc := get_location(location_id)
	if not loc:
		return []
	
	var result: Array[InteractionData] = []
	for interact_id in loc.interactions:
		var interact := get_interaction(interact_id)
		if interact:
			result.append(interact)
	return result


## RNA 상태를 기반으로 동적 인터랙션 조회
func get_available_interactions(location_id: String, rna: Dictionary) -> Array[InteractionData]:
	# 위치 스크립트 찾기
	var loc_script := _get_location_script(location_id)
	if loc_script and loc_script.has_method("get_available_interactions"):
		return loc_script.get_available_interactions.call(rna)
	
	# 동적 메서드가 없으면 기본 상호작용 반환
	return get_interactions(location_id)


func _get_location_script(location_id: String) -> GDScript:
	# location_id로 GDScript 로드
	return load("res://scripts/res/registry/locations/%s.gd" % location_id)
