extends GutTest

# ═══════════════════════════════════════════════════════════════════════════════
# LocationRegistry 테스트
# ═══════════════════════════════════════════════════════════════════════════════

var _registry: LocationRegistry


func before_each() -> void:
	_registry = LocationRegistry.new()


# ═══════════════════════════════════════════════════════════════════════════════
# 위치 조회 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_has_location() -> void:
	assert_true(_registry.has_location("cheongmok_village"), "청목진이 존재해야 함")
	assert_true(_registry.has_location("mountain_entrance"), "산길입구가 존재해야 함")
	assert_false(_registry.has_location("nonexistent"), "존재하지 않는 위치는 false")


func test_get_location() -> void:
	var loc: LocationData = _registry.get_location("cheongmok_village")
	assert_not_null(loc, "청목진 데이터가 있어야 함")
	assert_eq(loc.id, "cheongmok_village", "ID가 올바라야 함")
	assert_eq(loc.name_key, "LOC_CHEONGMOK", "이름 키가 올바라야 함")


func test_get_location_returns_null_for_nonexistent() -> void:
	var loc: LocationData = _registry.get_location("nonexistent")
	assert_null(loc, "존재하지 않는 위치는 null")


func test_get_all_location_ids() -> void:
	var ids: Array[String] = _registry.get_all_location_ids()
	assert_true(ids.size() >= 7, "최소 7개 위치가 있어야 함")
	assert_true("cheongmok_village" in ids, "청목진이 목록에 있어야 함")


# ═══════════════════════════════════════════════════════════════════════════════
# 연결/이동 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_get_connections() -> void:
	var connections: Array[String] = _registry.get_connections("cheongmok_village")
	assert_eq(connections.size(), 1, "청목진에서 이동 가능한 곳은 1개")
	assert_true("mountain_entrance" in connections, "산길입구로 이동 가능해야 함")


func test_get_connections_multiple() -> void:
	var connections: Array[String] = _registry.get_connections("mountain_entrance")
	assert_eq(connections.size(), 2, "산길입구에서 이동 가능한 곳은 2개")
	assert_true("cheongmok_village" in connections, "청목진으로 이동 가능")
	assert_true("mountain_mid" in connections, "산길중턱으로 이동 가능")


func test_can_travel() -> void:
	assert_true(_registry.can_travel("cheongmok_village", "mountain_entrance"), "청목진→산길입구 이동 가능")
	assert_true(_registry.can_travel("mountain_entrance", "cheongmok_village"), "산길입구→청목진 이동 가능")
	assert_false(_registry.can_travel("cheongmok_village", "forest_deep"), "청목진→연등숲심부 직접 이동 불가")


# ═══════════════════════════════════════════════════════════════════════════════
# 상호작용 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_has_interaction() -> void:
	assert_true(_registry.has_interaction("tavern"), "주점 상호작용이 있어야 함")
	assert_true(_registry.has_interaction("well"), "우물 상호작용이 있어야 함")
	assert_false(_registry.has_interaction("nonexistent"), "존재하지 않는 상호작용은 false")


func test_get_interaction() -> void:
	var interact: InteractionData = _registry.get_interaction("tavern")
	assert_not_null(interact, "주점 상호작용이 있어야 함")
	assert_eq(interact.id, "tavern", "ID가 올바라야 함")
	assert_eq(interact.type, InteractionData.Type.NPC, "NPC 타입이어야 함")


func test_get_interactions_for_location() -> void:
	var interactions: Array[InteractionData] = _registry.get_interactions("cheongmok_village")
	assert_eq(interactions.size(), 3, "청목진에 3개 상호작용")
	
	var ids: Array[String] = []
	for interact in interactions:
		ids.append(interact.id)
	
	assert_true("tavern" in ids, "주점이 있어야 함")
	assert_true("general_store" in ids, "잡화상이 있어야 함")
	assert_true("well" in ids, "우물이 있어야 함")


func test_get_interactions_empty_for_nonexistent() -> void:
	var interactions: Array[InteractionData] = _registry.get_interactions("nonexistent")
	assert_eq(interactions.size(), 0, "존재하지 않는 위치는 빈 배열")


# ═══════════════════════════════════════════════════════════════════════════════
# InteractionData 팩토리 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_interaction_data_npc() -> void:
	var interact: InteractionData = InteractionData.npc("test_npc", "TEST_NPC", "npc_001")
	assert_eq(interact.id, "test_npc")
	assert_eq(interact.type, InteractionData.Type.NPC)
	assert_eq(interact.target_id, "npc_001")


func test_interaction_data_shop() -> void:
	var interact: InteractionData = InteractionData.shop("test_shop", "TEST_SHOP", "shop_001")
	assert_eq(interact.id, "test_shop")
	assert_eq(interact.type, InteractionData.Type.SHOP)
	assert_eq(interact.target_id, "shop_001")


func test_interaction_data_battle() -> void:
	var interact: InteractionData = InteractionData.battle("test_battle", "TEST_BATTLE", "enemy_001")
	assert_eq(interact.id, "test_battle")
	assert_eq(interact.type, InteractionData.Type.BATTLE)
	assert_eq(interact.target_id, "enemy_001")


# ═══════════════════════════════════════════════════════════════════════════════
# LocationData 팩토리 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_location_data_create() -> void:
	var loc: LocationData = LocationData.create(
		"test_loc",
		"LOC_TEST",
		"LOC_TEST_DESC",
		["conn1", "conn2"],
		["interact1"]
	)
	
	assert_eq(loc.id, "test_loc")
	assert_eq(loc.name_key, "LOC_TEST")
	assert_eq(loc.desc_key, "LOC_TEST_DESC")
	assert_eq(loc.connections.size(), 2)
	assert_eq(loc.interactions.size(), 1)