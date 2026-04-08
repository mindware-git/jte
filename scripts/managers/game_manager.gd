extends Node

# ═══════════════════════════════════════════════════════════════════════════════
# GameManager - AutoLoad
# 게임 상태, 스토리 플래그, 매치 관리 통합
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# Enums
# ═══════════════════════════════════════════════════════════════════════════════

## 게임 상태
enum GameState {
	NONE,              ## 초기 상태
	LOADING,           ## 리소스 로딩
	MAIN_MENU,         ## 메인 메뉴
	SHOP,              ## 상점
	MATCHING,          ## 매칭 중
	CHARACTER_SELECT,  ## 캐릭터 선택
	PLAYING,           ## 게임 진행 중
	PAUSED,            ## 일시정지
	RESULT             ## 결과 화면
}

## 매치 모드
enum MatchMode {
	ONE_VS_ONE,      ## 1:1
	THREE_VS_THREE,  ## 3:3
	FIVE_VS_FIVE     ## 5:5
}

## 아이템 타입
enum ItemType {
	SKIN,       ## 코스튬/스킨
	EFFECT,     ## 이펙트
	CHARACTER,  ## 캐릭터 언락
	EMOTE       ## 이모티콘
}

## 화폐 타입
enum CurrencyType {
	COIN,  ## 게임 내 화폐
	GEM    ## 유료 화폐
}

## 속성 타입
enum ElementType {
	WATER,  ## 물
	FIRE,   ## 불
	WIND,   ## 바람
	EARTH   ## 흙
}

# ═══════════════════════════════════════════════════════════════════════════════
# Data Classes
# ═══════════════════════════════════════════════════════════════════════════════

## 플레이어 데이터
class PlayerData:
	var id: String = ""
	var player_name: String = ""
	var character_id: String = ""
	var team_id: int = 0
	var is_ready: bool = false
	
	func _init(p_id: String = "", p_player_name: String = "") -> void:
		id = p_id
		player_name = p_player_name

## 매치 데이터
class MatchData:
	var mode: MatchMode = MatchMode.ONE_VS_ONE
	var map_id: String = ""
	var players: Array[PlayerData] = []
	var time_limit: int = 300  # 초 단위
	
	func get_max_players() -> int:
		match mode:
			MatchMode.ONE_VS_ONE:
				return 2
			MatchMode.THREE_VS_THREE:
				return 6
			MatchMode.FIVE_VS_FIVE:
				return 10
			_:
				return 2

## 매치 결과
class MatchResult:
	var winning_team: int = -1
	var mvp_player_id: String = ""
	var duration: float = 0.0

## 상점 아이템
class ShopItem:
	var id: String = ""
	var item_name: String = ""
	var description: String = ""
	var type: ItemType = ItemType.SKIN
	var price: int = 0
	var currency: CurrencyType = CurrencyType.COIN
	var is_premium: bool = false

## 맵 데이터
class MapData:
	var id: String = ""
	var map_name: String = ""
	var alias: String = ""
	var element: ElementType = ElementType.EARTH
	var max_players: int = 8
	var has_teleport: bool = false
	var has_hazards: bool = true

# ═══════════════════════════════════════════════════════════════════════════════
# Signals
# ═══════════════════════════════════════════════════════════════════════════════

signal state_changed(old_state: GameState, new_state: GameState)
signal match_started(match_data: MatchData)
signal match_ended(result: MatchResult)
signal player_joined(player: PlayerData)
signal player_left(player_id: String)

# ═══════════════════════════════════════════════════════════════════════════════
# Currency System
# ═══════════════════════════════════════════════════════════════════════════════

var gem: int = 0  # 유료 화폐
var coin: int = 0  # 게임 내 화폐

# GEM → COIN 변환 비율
const GEM_TO_COIN_RATE := 100

# ═══════════════════════════════════════════════════════════════════════════════
# MVP Player State (from GameState)
# ═══════════════════════════════════════════════════════════════════════════════

var player_name: String = "삼장"
var player_hp: int = 100
var player_max_hp: int = 100
var player_mp: int = 50
var player_max_mp: int = 50
var player_attack: int = 10

# 게임 데이터
var gold: int = 0  # deprecated: coin 사용
var experience: int = 0
var level: int = 1

# 현재 위치
var current_map: String = "village"

# 적 데이터 (전투 중)
var enemy_name: String = ""
var enemy_hp: int = 0
var enemy_max_hp: int = 0
var enemy_attack: int = 0

# ═══════════════════════════════════════════════════════════════════════════════
# Character & Item System
# ═══════════════════════════════════════════════════════════════════════════════

# 보유 캐릭터 (PackedStringArray 사용)
var owned_characters: PackedStringArray = PackedStringArray(["samjang"])
var current_character: String = "samjang"

# 캐릭터별 상태
var character_states: Dictionary = {}  # { "samjang": CharacterState }

# 아이템 DB (나중에 외부 파일에서 로드)
var item_database: Dictionary = {}
var skill_database: Dictionary = {}

# 레벨별 스킬 정의 (나중에 외부 파일에서 로드)
var skill_unlock_table: Dictionary = {
	1: [],      # 레벨 1에 배우는 스킬
	2: ["power_strike"],
	3: [],
	4: ["heal"],
	5: [],
	6: ["fireball"],
	7: [],
	8: [],
	9: [],
	10: ["ultimate"],
}

# ═══════════════════════════════════════════════════════════════════════════════
# Story Flags (from StoryFlags)
# ═══════════════════════════════════════════════════════════════════════════════

var _flags: Dictionary = {}

# ═══════════════════════════════════════════════════════════════════════════════
# In-App Purchase State
# ═══════════════════════════════════════════════════════════════════════════════

var game_purchased: bool = false
var save_slots: int = 1

# ═══════════════════════════════════════════════════════════════════════════════
# PVP State
# ═══════════════════════════════════════════════════════════════════════════════

var current_state: GameState = GameState.NONE
var previous_state: GameState = GameState.NONE
var current_match: MatchData = null
var current_map_data: MapData = null
var players: Array[PlayerData] = []
var local_player: PlayerData = null

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	reset_mvp_state()
	_initialize()


func _initialize() -> void:
	change_state(GameState.LOADING)
	# 리소스 로드 완료 후
	change_state(GameState.MAIN_MENU)

# ═══════════════════════════════════════════════════════════════════════════════
# MVP State Management (from GameState)
# ═══════════════════════════════════════════════════════════════════════════════

func reset_mvp_state() -> void:
	player_hp = player_max_hp
	player_mp = player_max_mp
	coin = 0
	gold = 0  # deprecated
	experience = 0
	level = 1
	current_map = "village"
	gem = 0
	owned_characters = PackedStringArray(["samjang"])
	current_character = "samjang"
	character_states = {}
	_init_character_state()


func reset_state() -> void:
	reset_mvp_state()
	reset_flags()


func set_enemy(enemy_name_arg: String, hp: int, attack: int) -> void:
	enemy_name = enemy_name_arg
	enemy_hp = hp
	enemy_max_hp = hp
	enemy_attack = attack


func damage_player(amount: int) -> void:
	player_hp = maxi(0, player_hp - amount)


func damage_enemy(amount: int) -> void:
	enemy_hp = maxi(0, enemy_hp - amount)


func heal_player(amount: int) -> void:
	player_hp = mini(player_max_hp, player_hp + amount)


func is_player_dead() -> bool:
	return player_hp <= 0


func is_enemy_dead() -> bool:
	return enemy_hp <= 0


func add_gold(amount: int) -> void:
	# deprecated: add_coin 사용
	coin += amount
	gold = coin


func add_coin(amount: int) -> void:
	coin += amount
	gold = coin


func add_gem(amount: int) -> void:
	gem += amount


func convert_gem_to_coin(gem_amount: int) -> bool:
	if gem < gem_amount:
		return false
	gem -= gem_amount
	coin += gem_amount * GEM_TO_COIN_RATE
	gold = coin
	return true


func spend_coin(amount: int) -> bool:
	if coin < amount:
		return false
	coin -= amount
	gold = coin
	return true


func spend_gem(amount: int) -> bool:
	if gem < amount:
		return false
	gem -= amount
	return true


func add_experience(amount: int) -> void:
	experience += amount
	# 레벨업 체크 (간단한 공식)
	var required := level * 100
	if experience >= required:
		_level_up()


func _level_up() -> void:
	level += 1
	player_max_hp += 10
	player_max_mp += 5
	player_attack += 2
	player_hp = player_max_hp
	player_mp = player_max_mp
	
	# 레벨업 시 자동 스킬 습득
	_check_skill_unlock()

# ═══════════════════════════════════════════════════════════════════════════════
# Story Flags Management (from StoryFlags)
# ═══════════════════════════════════════════════════════════════════════════════

func reset_flags() -> void:
	_flags = {
		"prologue_complete": false,
		"quest_started": false,
		"quest_complete": false,
		"forest_unlocked": true,
		"temple_unlocked": false,
		"boss_defeated": false,
	}


func set_flag(flag_name: String, value: Variant = true) -> void:
	_flags[flag_name] = value


func get_flag(flag_name: String, default: Variant = false) -> Variant:
	return _flags.get(flag_name, default)


func has_flag(flag_name: String) -> bool:
	return _flags.has(flag_name) and _flags[flag_name] == true


func unlock_temple() -> void:
	set_flag("temple_unlocked", true)
	set_flag("quest_complete", true)


func complete_prologue() -> void:
	set_flag("prologue_complete", true)


func start_quest() -> void:
	set_flag("quest_started", true)


func defeat_boss() -> void:
	set_flag("boss_defeated", true)

# ═══════════════════════════════════════════════════════════════════════════════
# In-App Purchase Management
# ═══════════════════════════════════════════════════════════════════════════════

func purchase_game() -> void:
	game_purchased = true


func purchase_save_slot() -> void:
	save_slots += 1


func can_enter_temple() -> bool:
	return game_purchased and has_flag("temple_unlocked")


func is_game_purchased() -> bool:
	return game_purchased

# ═══════════════════════════════════════════════════════════════════════════════
# Character & Item Management
# ═══════════════════════════════════════════════════════════════════════════════

func _init_character_state() -> void:
	if not character_states.has(current_character):
		var state := CharacterState.new()
		state.character_id = current_character
		character_states[current_character] = state


func get_current_character_state() -> CharacterState:
	if not character_states.has(current_character):
		_init_character_state()
	return character_states[current_character]


func _check_skill_unlock() -> void:
	var state := get_current_character_state()
	if skill_unlock_table.has(level):
		var skills: Array = skill_unlock_table[level]
		for skill_id in skills:
			state.learn_skill(skill_id)
			print("스킬 습득: %s (Lv.%d)" % [skill_id, level])


func get_learned_skills() -> PackedStringArray:
	var state := get_current_character_state()
	return state.get_skills()


func equip_item(item_id: String) -> bool:
	# TODO: 아이템 DB에서 타입 확인 후 장착
	var state := get_current_character_state()
	# 임시: 무기로 장착
	state.equip_item(item_id, "weapon")
	return true


func unequip_item(slot: String) -> String:
	var state := get_current_character_state()
	return state.unequip_item(slot)


func add_item_to_inventory(item_id: String, count: int = 1) -> void:
	var state := get_current_character_state()
	state.add_item(item_id, count)


func remove_item_from_inventory(item_id: String, count: int = 1) -> bool:
	var state := get_current_character_state()
	return state.remove_item(item_id, count)


func has_item(item_id: String) -> bool:
	var state := get_current_character_state()
	return state.has_item(item_id)


func buy_item(item_id: String, price: int, use_coin: bool = true) -> bool:
	if use_coin:
		if not spend_coin(price):
			return false
	else:
		if not spend_gem(price):
			return false
	
	add_item_to_inventory(item_id)
	return true


func get_total_stat_bonus() -> Dictionary:
	var _state := get_current_character_state()
	var bonus := {
		"hp": 0,
		"mp": 0,
		"attack": 0,
		"defense": 0,
	}
	
	# 장착 아이템의 스탯 보너스 합산
	# TODO: 아이템 DB에서 아이템 정보 가져와서 보너스 계산
	
	return bonus

# ═══════════════════════════════════════════════════════════════════════════════
# PVP State Management
# ═══════════════════════════════════════════════════════════════════════════════

func change_state(new_state: GameState) -> bool:
	if current_state == new_state:
		return false
	
	previous_state = current_state
	current_state = new_state
	state_changed.emit(previous_state, current_state)
	return true


func get_current_state() -> GameState:
	return current_state


func get_previous_state() -> GameState:
	return previous_state

# ═══════════════════════════════════════════════════════════════════════════════
# Match Management
# ═══════════════════════════════════════════════════════════════════════════════

func start_match(mode: MatchMode, map_id: String) -> bool:
	if current_state != GameState.CHARACTER_SELECT:
		return false
	
	current_match = MatchData.new()
	current_match.mode = mode
	current_match.map_id = map_id
	
	change_state(GameState.PLAYING)
	match_started.emit(current_match)
	return true


func end_match(result: MatchResult) -> void:
	if current_state != GameState.PLAYING:
		return
	
	change_state(GameState.RESULT)
	match_ended.emit(result)


func cancel_match() -> void:
	current_match = null
	change_state(GameState.MAIN_MENU)

# ═══════════════════════════════════════════════════════════════════════════════
# Player Management
# ═══════════════════════════════════════════════════════════════════════════════

func add_player(player: PlayerData) -> bool:
	for p in players:
		if p.id == player.id:
			return false
	players.append(player)
	player_joined.emit(player)
	return true


func remove_player(player_id: String) -> bool:
	for i in range(players.size()):
		if players[i].id == player_id:
			players.remove_at(i)
			player_left.emit(player_id)
			return true
	return false


func get_player(player_id: String) -> PlayerData:
	for p in players:
		if p.id == player_id:
			return p
	return null


func get_players_by_team(team_id: int) -> Array[PlayerData]:
	var result: Array[PlayerData] = []
	for p in players:
		if p.team_id == team_id:
			result.append(p)
	return result

# ═══════════════════════════════════════════════════════════════════════════════
# Pause/Resume
# ═══════════════════════════════════════════════════════════════════════════════

func pause_game() -> bool:
	if current_state != GameState.PLAYING:
		return false
	get_tree().paused = true
	change_state(GameState.PAUSED)
	return true


func resume_game() -> bool:
	if current_state != GameState.PAUSED:
		return false
	get_tree().paused = false
	change_state(GameState.PLAYING)
	return true


# ═══════════════════════════════════════════════════════════════════════════════
# Save/Load DNA System
# ═══════════════════════════════════════════════════════════════════════════════

## 현재 화면 (Screen 전환용)
var current_screen: String = "title"

## 현재 위치 (LocationScreen용)
var current_location: String = "cheongmok_village"

## 방문한 위치들
var visited_locations: Array[String] = []

## 맵(Location)별 로컬 데이터 저장소 (NPC 위치, 상자 열림 여부 등)
var location_states: Dictionary = {}

## 파티 멤버
var party_members: Array[String] = ["sanzang"]

## 파티 리더
var party_leader: String = "sanzang"


## DNA에서 RNA로 변환 (로드)
func from_dna(dna: Dictionary) -> void:
	# Progress
	if dna.has("progress"):
		var progress: Dictionary = dna["progress"]
		if progress.has("part_id"):
			set_flag("current_part", progress["part_id"])
		if progress.has("chapter_id"):
			set_flag("current_chapter", progress["chapter_id"])
	
	# World
	if dna.has("world"):
		var world: Dictionary = dna["world"]
		if world.has("current_screen"):
			current_screen = world["current_screen"]
		if world.has("current_location"):
			current_location = world["current_location"]
		if world.has("visited_locations"):
			visited_locations.clear()
			for loc in world["visited_locations"]:
				visited_locations.append(loc)
		if world.has("location_states"):
			location_states = world["location_states"].duplicate(true)
	
	# Party
	if dna.has("party"):
		var party: Dictionary = dna["party"]
		if party.has("members"):
			party_members.clear()
			for member in party["members"]:
				party_members.append(member)
		if party.has("leader"):
			party_leader = party["leader"]
	
	# Inventory
	if dna.has("inventory"):
		var inv: Dictionary = dna["inventory"]
		if inv.has("gold"):
			coin = inv["gold"]
			gold = coin
		if inv.has("items"):
			for item_id in inv["items"]:
				add_item_to_inventory(item_id)
	
	# Flags
	if dna.has("flags"):
		var flags: Dictionary = dna["flags"]
		for flag_name in flags.keys():
			set_flag(flag_name, flags[flag_name])


## RNA 상태를 Dictionary로 반환 (동적 인터랙션용)
func to_rna() -> Dictionary:
	return {
		"current_location": current_location,
		"visited_locations": visited_locations,
		"party_members": party_members,
		"party_leader": party_leader,
		"coin": coin,
		"flags": _flags.duplicate()
	}


## RNA에서 DNA로 변환 (저장)
func to_dna() -> Dictionary:
	var dna := {
		"header": {
			"save_format_version": 1,
			"app_version": "0.1.0",
			"content_version": 1
		},
		"progress": {
			"part_id": get_flag("current_part", "part_1"),
			"chapter_id": get_flag("current_chapter", "act1_prologue")
		},
		"world": {
			"current_location": current_location,
			"visited_locations": visited_locations,
			"location_states": location_states
		},
		"party": {
			"members": party_members,
			"leader": party_leader
		},
		"inventory": {
			"gold": coin,
			"items": []  # TODO: 인벤토리 아이템 목록
		},
		"flags": _flags.duplicate()
	}
	return dna


## 개발용 DNA 파일 로드
func load_dev_dna(file_path: String) -> bool:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("DNA 파일을 열 수 없음: " + file_path)
		return false
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		push_error("JSON 파싱 오류: " + json.get_error_message())
		return false
	
	var dna: Dictionary = json.data
	from_dna(dna)
	return true


# ═══════════════════════════════════════════════════════════════════════════════
# Local DNA (Location States) API
# ═══════════════════════════════════════════════════════════════════════════════

func get_location_state(location_id: String, key: String, default: Variant = null) -> Variant:
	if not location_states.has(location_id):
		return default
	
	if not location_states[location_id].has(key):
		return default
		
	return location_states[location_id][key]


func set_location_state(location_id: String, key: String, value: Variant) -> void:
	if not location_states.has(location_id):
		location_states[location_id] = {}
		
	location_states[location_id][key] = value
