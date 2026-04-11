class_name CutsceneRegistry
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# CutsceneRegistry
# 컷신 데이터 레지스트리 (NPCRegistry 패턴)
# ═══════════════════════════════════════════════════════════════════════════════

var _cutscenes: Dictionary = {}


func _init() -> void:
	_register_all_cutscenes()


# ═══════════════════════════════════════════════════════════════════════════════
# 컷신 등록
# ═══════════════════════════════════════════════════════════════════════════════

func _register_all_cutscenes() -> void:
	# Part 1
	_register_cutscene(Part1Opening)


func _register_cutscene(cutscene_script: GDScript) -> void:
	var cutscene_data: CutsceneData = cutscene_script.get_cutscene_data.call()
	if cutscene_data:
		_cutscenes[cutscene_data.id] = cutscene_data


# ═══════════════════════════════════════════════════════════════════════════════
# 조회 메서드
# ═══════════════════════════════════════════════════════════════════════════════

func get_cutscene(cutscene_id: String) -> CutsceneData:
	return _cutscenes.get(cutscene_id)


func has_cutscene(cutscene_id: String) -> bool:
	return _cutscenes.has(cutscene_id)


func get_all_cutscene_ids() -> Array[String]:
	var result: Array[String] = []
	for key in _cutscenes.keys():
		result.append(key)
	return result
