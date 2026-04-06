class_name NPCRegistry
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# NPCRegistry
# NPC/대화 데이터 레지스트리
# ═══════════════════════════════════════════════════════════════════════════════

var _npcs: Dictionary = {}


func _init() -> void:
	_register_all_npcs()


# ═══════════════════════════════════════════════════════════════════════════════
# NPC 등록
# ═══════════════════════════════════════════════════════════════════════════════

func _register_all_npcs() -> void:
	# Part 1
	_register_npc(OldMonk)
	_register_npc(FlowerSpirit)
	# TODO: 더 많은 NPC 추가


func _register_npc(npc_script: GDScript) -> void:
	var npc_data: NPCData = npc_script.get_npc_data.call()
	if npc_data:
		_npcs[npc_data.id] = npc_data


# ═══════════════════════════════════════════════════════════════════════════════
# 조회 메서드
# ═══════════════════════════════════════════════════════════════════════════════

func get_npc(npc_id: String) -> NPCData:
	return _npcs.get(npc_id)


func has_npc(npc_id: String) -> bool:
	return _npcs.has(npc_id)


func get_npcs_by_location(location_id: String) -> Array[NPCData]:
	var result: Array[NPCData] = []
	for npc_id in _npcs.keys():
		var npc: NPCData = _npcs[npc_id]
		if npc.location_id == location_id:
			result.append(npc)
	return result


## RNA 상태에 따른 동적 대화 조회
func get_dialogue(npc_id: String, rna: Dictionary) -> DialogueData:
	var npc_script := _get_npc_script(npc_id)
	if npc_script and npc_script.has_method("get_dialogue"):
		return npc_script.get_dialogue.call(rna)
	
	# 기본 대화 반환
	var npc := get_npc(npc_id)
	if npc:
		return DialogueData.simple(npc.default_dialogue_id, npc.default_dialogue_id)
	return null


func _get_npc_script(npc_id: String) -> GDScript:
	return load("res://scripts/res/registry/npcs/%s.gd" % npc_id)