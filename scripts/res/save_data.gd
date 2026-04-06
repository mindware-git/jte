class_name SaveData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# SaveData
# 게임 상태 저장용 데이터 구조
# ═══════════════════════════════════════════════════════════════════════════════

var slot_index: int = 0
var saved_at: String = ""  # ISO timestamp
var play_time: float = 0.0  # 플레이 시간 (초)

# 플레이어 상태
var player_name: String = "삼장"
var player_hp: int = 100
var player_max_hp: int = 100
var player_mp: int = 50
var player_max_mp: int = 50
var player_attack: int = 10
var gold: int = 0
var experience: int = 0
var level: int = 1

# 위치
var current_map: String = "village"

# 스토리 플래그
var flags: Dictionary = {}

# 인앱결제 상태
var game_purchased: bool = false
var save_slots: int = 1

# 화폐
var gem: int = 0
var coin: int = 0

# 캐릭터 (PackedStringArray 사용)
var owned_characters: PackedStringArray = PackedStringArray(["samjang"])
var current_character: String = "samjang"

# 캐릭터별 상태 (직렬화된 Dictionary)
var character_states_data: Dictionary = {}

# ═══════════════════════════════════════════════════════════════════════════════
# Serialization
# ═══════════════════════════════════════════════════════════════════════════════

func to_dict() -> Dictionary:
	return {
		"slot_index": slot_index,
		"saved_at": saved_at,
		"play_time": play_time,
		"player_name": player_name,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"player_mp": player_mp,
		"player_max_mp": player_max_mp,
		"player_attack": player_attack,
		"gold": gold,
		"experience": experience,
		"level": level,
		"current_map": current_map,
		"flags": flags,
		"game_purchased": game_purchased,
		"save_slots": save_slots,
		"gem": gem,
		"coin": coin,
		"owned_characters": owned_characters,
		"current_character": current_character,
		"character_states_data": character_states_data,
	}


func from_dict(dict: Dictionary) -> void:
	slot_index = dict.get("slot_index", 0)
	saved_at = dict.get("saved_at", "")
	play_time = dict.get("play_time", 0.0)
	player_name = dict.get("player_name", "삼장")
	player_hp = dict.get("player_hp", 100)
	player_max_hp = dict.get("player_max_hp", 100)
	player_mp = dict.get("player_mp", 50)
	player_max_mp = dict.get("player_max_mp", 50)
	player_attack = dict.get("player_attack", 10)
	gold = dict.get("gold", 0)
	experience = dict.get("experience", 0)
	level = dict.get("level", 1)
	current_map = dict.get("current_map", "village")
	flags = dict.get("flags", {})
	game_purchased = dict.get("game_purchased", false)
	save_slots = dict.get("save_slots", 1)
	gem = dict.get("gem", 0)
	coin = dict.get("coin", 0)
	
	# PackedStringArray로 변환
	var chars: Array = dict.get("owned_characters", ["samjang"])
	owned_characters = PackedStringArray()
	for c in chars:
		owned_characters.append(str(c))
	
	current_character = dict.get("current_character", "samjang")
	character_states_data = dict.get("character_states_data", {})


# ═══════════════════════════════════════════════════════════════════════════════
# Factory Methods
# ═══════════════════════════════════════════════════════════════════════════════

static func create_from_game_manager(slot: int) -> SaveData:
	var data := SaveData.new()
	data.slot_index = slot
	data.saved_at = Time.get_datetime_string_from_system()
	
	# GameManager에서 현재 상태 복사
	data.player_name = GameManager.player_name
	data.player_hp = GameManager.player_hp
	data.player_max_hp = GameManager.player_max_hp
	data.player_mp = GameManager.player_mp
	data.player_max_mp = GameManager.player_max_mp
	data.player_attack = GameManager.player_attack
	data.gold = GameManager.gold
	data.experience = GameManager.experience
	data.level = GameManager.level
	data.current_map = GameManager.current_map
	data.flags = GameManager._flags.duplicate()
	data.game_purchased = GameManager.game_purchased
	data.save_slots = GameManager.save_slots
	
	# 화폐
	data.gem = GameManager.gem
	data.coin = GameManager.coin
	
	# 캐릭터
	data.owned_characters = GameManager.owned_characters.duplicate()
	data.current_character = GameManager.current_character
	
	# 캐릭터별 상태 직렬화
	data.character_states_data = {}
	for char_id in GameManager.character_states.keys():
		var state: CharacterState = GameManager.character_states[char_id]
		data.character_states_data[char_id] = state.to_dict()
	
	return data


func apply_to_game_manager() -> void:
	# GameManager에 상태 복원
	GameManager.player_name = player_name
	GameManager.player_hp = player_hp
	GameManager.player_max_hp = player_max_hp
	GameManager.player_mp = player_mp
	GameManager.player_max_mp = player_max_mp
	GameManager.player_attack = player_attack
	GameManager.gold = gold
	GameManager.coin = coin
	GameManager.experience = experience
	GameManager.level = level
	GameManager.current_map = current_map
	GameManager._flags = flags.duplicate()
	GameManager.game_purchased = game_purchased
	GameManager.save_slots = save_slots
	
	# 화폐
	GameManager.gem = gem
	GameManager.coin = coin
	
	# 캐릭터
	GameManager.owned_characters = owned_characters.duplicate()
	GameManager.current_character = current_character
	
	# 캐릭터별 상태 복원
	GameManager.character_states = {}
	for char_id in character_states_data.keys():
		var state := CharacterState.new()
		state.from_dict(character_states_data[char_id])
		GameManager.character_states[char_id] = state


# ═══════════════════════════════════════════════════════════════════════════════
# Display Helpers
# ═══════════════════════════════════════════════════════════════════════════════

func get_display_name() -> String:
	return "슬롯 %d" % (slot_index + 1)


func get_display_info() -> String:
	return "%s | Lv.%d | %s" % [player_name, level, current_map]


func get_display_time() -> String:
	if saved_at.is_empty():
		return "없음"
	return saved_at
