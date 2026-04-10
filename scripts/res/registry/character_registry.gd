class_name CharacterRegistry
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 캐릭터 데이터 레지스트리 (Code-First)
# ═══════════════════════════════════════════════════════════════════════════════

var _characters: Dictionary = {}


func _init() -> void:
	_register_all_characters()


func _register_all_characters() -> void:
	# 동유기 캐릭터
	_register_sanzang()
	_register_wukong()
	_register_enemy_slime()

# ═══════════════════════════════════════════════════════════════════════════════
# 삼장법사 (Sanzang)
# ═══════════════════════════════════════════════════════════════════════════════

func _register_sanzang() -> void:
	var data := CharacterData.new()
	data.id = "sanzang"
	data.display_name = "삼장법사"
	data.description = "동천취경의 여정을 이끄는 젊은 승려"
	# 능력치 (힐러/서포터)
	data.max_hp = 90
	

# ═══════════════════════════════════════════════════════════════════════════════
# 손오공 (Wukong)
# ═══════════════════════════════════════════════════════════════════════════════

func _register_wukong() -> void:
	var data := CharacterData.new()
	data.id = "wukong"
	data.display_name = "손오공"
	data.description = "오행봉에서 봉인이 풀린 돌원숭이"
	
	# 능력치 (딜러/전열)
	data.max_hp = 130
	data.max_mp = 80
	_characters[data.id] = data


# ═══════════════════════════════════════════════════════════════════════════════
# 조회 메서드
# ═══════════════════════════════════════════════════════════════════════════════

func get_character(id: String) -> CharacterData:
	if _characters.has(id):
		return _characters[id]
	return null


func get_all_characters() -> Array[CharacterData]:
	var result: Array[CharacterData] = []
	for key in _characters.keys():
		result.append(_characters[key])
	return result


func get_all_ids() -> Array[String]:
	var result: Array[String] = []
	for key in _characters.keys():
		result.append(key)
	return result


# ═══════════════════════════════════════════════════════════════════════════════
# 적 캐릭터 (Enemy Slime)
# ═══════════════════════════════════════════════════════════════════════════════

func _register_enemy_slime() -> void:
	var data := CharacterData.new()
	data.id = "enemy_slime"
	data.display_name = "슬라임"
	data.description = "기본 적"
	data.element = GameManager.ElementType.EARTH
	
	# 능력치 (약한 적)
	data.max_hp = 30
	data.max_mp = 0
	
	_characters[data.id] = data


func has_character(id: String) -> bool:
	return _characters.has(id)
