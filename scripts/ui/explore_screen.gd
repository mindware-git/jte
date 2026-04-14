class_name ExploreScreen
extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# ExploreScreen
# 탐험 화면 컨트롤러 (Node2D 기반)
# 맵 로드, 플레이어/NPC 스폰, 상호작용 관리
# ═══════════════════════════════════════════════════════════════════════════════

signal finished()

# ═══════════════════════════════════════════════════════════════════════════════
# Constants
# ═══════════════════════════════════════════════════════════════════════════════

const ACTOR_SCENE := preload("res://scenes/entities/actor.tscn")
const INTERACTABLE_SCENE := preload("res://scenes/entities/interactable.tscn")
const DEFAULT_PLAYER_TILE := Vector2i(11, 12)

# ═══════════════════════════════════════════════════════════════════════════════
# Variables
# ═══════════════════════════════════════════════════════════════════════════════

## RNA 데이터
var _rna: Dictionary = {}

## 현재 위치 ID
var _location_id: String = "bluewood_village"

## 맵 노드
var _map_node: Node2D = null

## 플레이어 Actor
var _player: Actor = null

## NPC 목록
var _npcs: Array[Actor] = []

# ═══════════════════════════════════════════════════════════════════════════════
# Setup
# ═══════════════════════════════════════════════════════════════════════════════

func setup(rna: Dictionary) -> void:
	_rna = rna
	_location_id = rna.get("current_location", "bluewood_village")
	
	# 순서대로 초기화
	_load_location_scene()
	_connect_gates()
	_connect_interactables()
	_spawn_player()
	_spawn_npcs()
	_spawn_treasures()
	_create_battle_triggers()
	_create_ui()
	
	print("ExploreScreen 설정 완료: ", _location_id)


# ═══════════════════════════════════════════════════════════════════════════════
# Location Loading
# ═══════════════════════════════════════════════════════════════════════════════

func _load_location_scene() -> void:
	var path := "res://scenes/locations/%s.tscn" % _location_id
	
	if not ResourceLoader.exists(path):
		push_error("맵 씬을 찾을 수 없음: " + path)
		return
	
	var scene := load(path).instantiate() as Node2D
	add_child(scene)
	_map_node = scene
	
	print("맵 로드 완료: ", _location_id)


# ═══════════════════════════════════════════════════════════════════════════════
# Player Spawning
# ═══════════════════════════════════════════════════════════════════════════════

func _spawn_player() -> void:
	_player = ACTOR_SCENE.instantiate()

	# 파티 리더의 CharacterData 가져오기
	var leader_id: String = GameManager.party_leader
	var player_data: CharacterData = null
	
	# CharacterRegistry에서 데이터 조회
	var registry := CharacterRegistry.new()
	player_data = registry.get_character(leader_id)
	
	# 데이터가 없으면 기본값 생성
	if player_data == null:
		player_data = CharacterData.new()
		player_data.id = leader_id
		player_data.display_name = leader_id.capitalize()
	
	# Actor 초기화
	_player.init(player_data, Actor.Role.PLAYER)
	
	# Global RNA에서 플레이어 타일 위치 가져오기
	var player_tile: Vector2i = GameManager.get_location_state(
		_location_id,
		"player_tile",
		DEFAULT_PLAYER_TILE
	)
	_player.set_tile(player_tile)
	
	# 클릭 시그널 연결
	_player.clicked.connect(_on_player_clicked)
	
	add_child(_player)
	
	print("플레이어 스폰 완료: ", leader_id, " at ", player_tile)


# ═══════════════════════════════════════════════════════════════════════════════
# Gate Connection
# ═══════════════════════════════════════════════════════════════════════════════

func _connect_gates() -> void:
	if _map_node == null:
		return
	
	# Gate 컨테이너 찾기
	var gates_container := _map_node.find_child("Gate", false, false)
	if gates_container == null:
		return
	
	# 모든 Gate에 시그널 연결
	for child in gates_container.get_children():
		if child is Gate:
			var gate := child as Gate
			gate.gate_entered.connect(_on_gate_entered)
			print("Gate 연결: ", gate.name, " → ", gate.target_location)


func _on_gate_entered(target_location: String, target_tile: Vector2i) -> void:
	print("Gate 진입: ", target_location, " at ", target_tile)
	
	# RNA 업데이트
	GameManager.current_screen = "explore"
	GameManager.current_location = target_location
	GameManager.set_location_state(target_location, "player_tile", target_tile)
	
	# 화면 전환 신호
	finished.emit()


# ═══════════════════════════════════════════════════════════════════════════════
# Interactable Connection
# ═══════════════════════════════════════════════════════════════════════════════

func _connect_interactables() -> void:
	if _map_node == null:
		return
	
	# Interactable 컨테이너 찾기
	var interactables_container := _map_node.find_child("Interactable", false, false)
	if interactables_container == null:
		return
	
	# 모든 Interactable에 시그널 연결
	for child in interactables_container.get_children():
		if child is Interactable:
			var interactable := child as Interactable
			interactable.interacted.connect(_on_interactable_interacted)
			print("Interactable 연결: ", interactable.name, " type: ", interactable.interact_type)


func _on_interactable_interacted(interactable: Interactable) -> void:
	print("Interactable 상호작용: ", interactable.name)
	
	match interactable.interact_type:
		"treasure":
			# 보물 상자 열기
			var treasure_path: String = interactable.interact_data.get("treasure_path", "")
			if treasure_path != "":
				var treasure := get_node_or_null(treasure_path) as Treasure
				if treasure:
					_open_treasure(treasure)
					# Interactable 제거
					interactable.queue_free()
		"investigate":
			# 조사 포인트
			var item_id: String = interactable.interact_data.get("item_id", "")
			if item_id != "":
				print("  → 아이템 획득: ", item_id)
				GameManager.add_item_to_inventory(item_id)
		"npc":
			# NPC 대화
			var npc_id: String = interactable.interact_data.get("npc_id", "")
			print("  → NPC 대화: ", npc_id)
			if npc_id != "":
				var npc_registry := NPCRegistry.new()
				var npc_data: NPCData = npc_registry.get_npc(npc_id)
				if npc_data and npc_data.npc_type == "shop":
					_open_shop(npc_data.shop_id)
				else:
					_open_dialogue(npc_id)
		"battle":
			# 전투 진입
			var enemy_id: String = interactable.interact_data.get("enemy_id", "")
			print("  → 전투 진입: ", enemy_id)
			_start_battle(enemy_id)
		"story":
			# 컷신 발동
			var cutscene_id: String = interactable.interact_data.get("cutscene_id", "")
			print("  → 컷신 발동: ", cutscene_id)
			if cutscene_id != "":
				_start_cutscene(cutscene_id)
		_:
			print("  → 알 수 없는 타입: ", interactable.interact_type)


func _start_battle(enemy_id: String) -> void:
	# RNA 업데이트
	GameManager.current_screen = "battle"
	GameManager.enemy_id = enemy_id
	GameManager.from_battle = true
	
	# 화면 전환 신호
	finished.emit()


func _start_cutscene(cutscene_id: String) -> void:
	# RNA 업데이트
	GameManager.current_screen = "story"
	GameManager.cutscene_id = cutscene_id
	
	# 화면 전환 신호
	finished.emit()


# ═══════════════════════════════════════════════════════════════════════════════
# NPC Spawning
# ═══════════════════════════════════════════════════════════════════════════════

func _spawn_npcs() -> void:
	# 맵 씬에 이미 배치된 NPC들을 찾아서 초기화
	if _map_node == null:
		return
	
	# NPC 노드 찾기
	var npc_container := _map_node.find_child("NPC", false, false)
	if npc_container == null:
		return
	
	# 자식 Actor 노드들 처리
	for child in npc_container.get_children():
		if child is Actor:
			var npc_actor := child as Actor
			_initialize_npc(npc_actor)
			_npcs.append(npc_actor)


func _initialize_npc(npc: Actor) -> void:
	# NPC 데이터 생성 (임시)
	var npc_data := CharacterData.new()
	npc_data.id = npc.name.to_snake_case()
	npc_data.display_name = npc.name
	
	# NPC 초기화
	npc.init(npc_data, Actor.Role.NPC)
	
	# 현재 위치를 GRID로 설정 (중요!)
	var npc_grid := _world_to_tile(npc.position)
	npc.set_tile(npc_grid)
	
	# NPC 주변에 Interactable 생성 (대화 범위)
	_create_npc_interactable(npc)

	# 이전 Actor 클릭 기반 상호작용은 버튼 기반으로 전환되었으므로 연결하지 않음
	# (클릭 이벤트는 이제 Interactable의 버튼으로 처리)

	# 랜덤 배회 타이머 추가
	var wander_timer := Timer.new()
	wander_timer.wait_time = randf_range(2.0, 5.0)  # 2~5초 랜덤
	wander_timer.autostart = true
	wander_timer.one_shot = false  # 반복
	wander_timer.timeout.connect(_on_npc_wander_timer.bind(npc))
	npc.add_child(wander_timer)
	
	print("NPC 초기화: ", npc.name)


func _on_npc_wander_timer(npc: Actor) -> void:
	if npc.is_moving:
		return
	
	# 현재 위치 기준 랜덤 이동 (±3 GRID)
	var random_offset := Vector2i(
		randi_range(-3, 3),
		randi_range(-3, 3)
	)
	var target := npc.current_tile + random_offset
	
	# 음수 좌표 방지
	if target.x < 0 or target.y < 0:
		return
	
	print("NPC 랜덤 이동: ", npc.display_name, " → ", target)
	npc.move_to_target(target)


func _create_npc_interactable(npc: Actor) -> void:
	# Interactable 씬 인스턴스 생성
	var interactable := INTERACTABLE_SCENE.instantiate() as Interactable
	interactable.name = npc.name + "_Interactable"
	interactable.interact_type = "npc"
	interactable.interact_data = {"npc_id": npc.name.to_snake_case()}
	# position 설정 제거 - NPC의 자식으로 추가하면 NPC를 따라다님
	
	# 시그널 연결
	interactable.interacted.connect(_on_interactable_interacted)
	
	# NPC의 자식으로 추가하여 NPC 이동 시 함께 이동
	npc.add_child(interactable)
	print("NPC Interactable 생성: ", interactable.name, " (NPC 자식)")


# ═══════════════════════════════════════════════════════════════════════════════
# Treasure Spawning
# ═══════════════════════════════════════════════════════════════════════════════

func _spawn_treasures() -> void:
	if _map_node == null:
		return
	
	# Treasure 컨테이너 찾기
	var treasure_container := _map_node.find_child("Treasure", false, false)
	if treasure_container == null:
		return
	
	# 자식 Treasure 노드들 처리
	for child in treasure_container.get_children():
		if child is Treasure:
			var treasure := child as Treasure
			# 이미 열린 보물 상자는 Interactable 생성하지 않음
			if not treasure.is_opened():
				_create_treasure_interactable(treasure)
				print("Treasure 발견: ", treasure.name, " item: ", treasure.get_item_id())


func _create_treasure_interactable(treasure: Treasure) -> void:
	# Interactable 씬 인스턴스 생성
	var interactable := INTERACTABLE_SCENE.instantiate() as Interactable
	interactable.name = treasure.name + "_Interactable"
	interactable.interact_type = "treasure"
	interactable.interact_data = {
		"item_id": treasure.get_item_id(),
		"treasure_id": treasure.get_treasure_id(),
		"treasure_path": treasure.get_path()  # Treasure 노드 참조용
	}
	interactable.position = treasure.position
	
	# 시그널 연결
	interactable.interacted.connect(_on_interactable_interacted)
	
	add_child(interactable)
	print("Treasure Interactable 생성: ", interactable.name, " at ", interactable.position)


func _open_treasure(treasure: Treasure) -> void:
	# 아이템 획득
	var item_id := treasure.get_item_id()
	if item_id != "":
		GameManager.add_item_to_inventory(item_id)
		print("아이템 획득: ", item_id)
	
	# 보물 상자 열림 상태로 변경
	treasure.set_opened(true)


# ═══════════════════════════════════════════════════════════════════════════════
# Battle Triggers
# ═══════════════════════════════════════════════════════════════════════════════

func _create_battle_triggers() -> void:
	# elemental_slope 맵에만 전투 트리거 생성
	if _location_id != "elemental_slope":
		return
	
	# 전투 트리거 생성 (맵 중앙쯤)
	var battle_trigger := INTERACTABLE_SCENE.instantiate() as Interactable
	battle_trigger.name = "BattleTrigger_FireSpirit"
	battle_trigger.interact_type = "battle"
	battle_trigger.battle_id = "elemental_slope_01"
	battle_trigger.interact_data = {"enemy_id": "fire_spirit"}
	battle_trigger.position = Vector2(200, 200)  # TODO: 적절한 위치로 조정
	
	# 시그널 연결
	battle_trigger.interacted.connect(_on_interactable_interacted)
	
	add_child(battle_trigger)
	print("Battle Trigger 생성: ", battle_trigger.name, " at ", battle_trigger.position)


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 위치 표시 라벨
	var location_label := Label.new()
	location_label.text = "위치: " + _location_id
	location_label.position = Vector2(20, 20)
	location_label.add_theme_font_size_override("font_size", 24)
	location_label.add_theme_color_override("font_color", Color.WHITE)
	location_label.add_theme_color_override("font_outline_color", Color.BLACK)
	location_label.add_theme_constant_override("outline_size", 2)
	add_child(location_label)
	
	# 파티 정보 라벨
	var party_label := Label.new()
	var party_members: Array = _rna.get("party_members", ["sanzang"])
	party_label.text = "파티: " + ", ".join(party_members)
	party_label.position = Vector2(20, 50)
	party_label.add_theme_font_size_override("font_size", 18)
	party_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	party_label.add_theme_color_override("font_outline_color", Color.BLACK)
	party_label.add_theme_constant_override("outline_size", 1)
	add_child(party_label)
	
	# 골드 표시
	var coin_label := Label.new()
	var coin: int = _rna.get("coin", 0)
	coin_label.text = "골드: %d" % coin
	coin_label.position = Vector2(20, 80)
	coin_label.add_theme_font_size_override("font_size", 18)
	coin_label.add_theme_color_override("font_color", Color.GOLD)
	coin_label.add_theme_color_override("font_outline_color", Color.BLACK)
	coin_label.add_theme_constant_override("outline_size", 1)
	add_child(coin_label)
	
	# 도움말
	var help_label := Label.new()
	help_label.text = "방향키 또는 WASD로 이동"
	help_label.position = Vector2(20, 120)
	help_label.add_theme_font_size_override("font_size", 14)
	help_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	help_label.add_theme_color_override("font_outline_color", Color.BLACK)
	help_label.add_theme_constant_override("outline_size", 1)
	add_child(help_label)


# ═══════════════════════════════════════════════════════════════════════════════
# Input Handling
# ═══════════════════════════════════════════════════════════════════════════════

func _unhandled_input(event: InputEvent) -> void:
	if _player == null:
		return
	
	# 마우스 클릭으로 경로 이동
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos := get_global_mouse_position()
		var target_grid := _world_to_tile(click_pos)
		
		# 클릭 위치와 GRID 매핑 print
		print("클릭 위치: ", click_pos, " → GRID: ", target_grid)
		
		# 경로 이동 시작 (이동 중에도 경로 변경 가능)
		_player.move_to_target(target_grid, true)
		return


## 월드 좌표 → 타일 좌표 (그리드 기반)
func _world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / GameManager.GRID_SIZE), int(world_pos.y / GameManager.GRID_SIZE))


func _save_player_position(tile: Vector2i) -> void:
	GameManager.set_location_state(_location_id, "player_tile", tile)


# ═══════════════════════════════════════════════════════════════════════════════
# Event Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_player_clicked(actor: Actor) -> void:
	print("플레이어 클릭: ", actor.display_name)


func _on_npc_clicked(npc: Actor) -> void:
	print("NPC 클릭: ", npc.name, " 위치: ", _location_id)
	
	# NPC ID로 NPCData 조회
	var npc_id: String = npc.name.to_snake_case()
	var npc_registry := NPCRegistry.new()
	var npc_data: NPCData = npc_registry.get_npc(npc_id)
	
	if npc_data == null:
		print("  → NPC 데이터 없음: ", npc_id)
		return
	
	# NPC 타입별 처리
	match npc_data.npc_type:
		"shop":
			print("  → 상점 열기: ", npc_data.shop_id)
			_open_shop(npc_data.shop_id)
		_:
			print("  → 대화: ", npc_id)
			_open_dialogue(npc_id)


func _open_shop(shop_id: String) -> void:
	var shop_panel := ShopPanel.new(shop_id)
	add_child(shop_panel)


func _open_dialogue(npc_id: String) -> void:
	var dialogue_panel := DialoguePanel.new(npc_id)
	add_child(dialogue_panel)


# ═══════════════════════════════════════════════════════════════════════════════
# Properties
# ═══════════════════════════════════════════════════════════════════════════════

var player: Actor:
	get: return _player
