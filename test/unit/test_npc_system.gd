extends GutTest

# ═══════════════════════════════════════════════════════════════════════════════
# NPC/대화 시스템 테스트
# ═══════════════════════════════════════════════════════════════════════════════

var _registry: NPCRegistry


func before_each() -> void:
	_registry = NPCRegistry.new()


# ═══════════════════════════════════════════════════════════════════════════════
# NPCData Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_npc_data_create() -> void:
	var npc := NPCData.create("test_npc", "NPC_TEST", "test_location")
	assert_eq(npc.id, "test_npc")
	assert_eq(npc.display_name_key, "NPC_TEST")
	assert_eq(npc.location_id, "test_location")
	assert_eq(npc.default_dialogue_id, "DIALOGUE_TEST_NPC")


func test_npc_data_custom_dialogue() -> void:
	var npc := NPCData.create("test_npc", "NPC_TEST", "test_location", "CUSTOM_DIALOGUE")
	assert_eq(npc.default_dialogue_id, "CUSTOM_DIALOGUE")


# ═══════════════════════════════════════════════════════════════════════════════
# NPCRegistry Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_registry_has_old_monk() -> void:
	assert_true(_registry.has_npc("old_monk"))


func test_registry_has_flower_spirit() -> void:
	assert_true(_registry.has_npc("flower_spirit"))


func test_registry_get_npc() -> void:
	var npc := _registry.get_npc("old_monk")
	assert_not_null(npc)
	assert_eq(npc.id, "old_monk")
	assert_eq(npc.location_id, "cheongmok_village")


func test_registry_get_nonexistent_npc() -> void:
	var npc := _registry.get_npc("nonexistent")
	assert_null(npc)


func test_registry_get_npcs_by_location() -> void:
	var npcs := _registry.get_npcs_by_location("cheongmok_village")
	assert_gt(npcs.size(), 0)
	
	var found_old_monk := false
	for npc in npcs:
		if npc.id == "old_monk":
			found_old_monk = true
	assert_true(found_old_monk)


# ═══════════════════════════════════════════════════════════════════════════════
# DialogueData Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_dialogue_simple() -> void:
	var dialogue := DialogueData.simple("test_dialogue", "DIALOGUE_TEXT")
	assert_eq(dialogue.id, "test_dialogue")
	assert_eq(dialogue.text_key, "DIALOGUE_TEXT")
	assert_eq(dialogue.choices.size(), 1)


func test_dialogue_with_choices() -> void:
	var choices: Array[DialogueData.DialogueChoice] = [
		DialogueData.DialogueChoice.create("CHOICE_1", "NEXT_1"),
		DialogueData.DialogueChoice.create("CHOICE_2", "NEXT_2"),
	]
	var dialogue := DialogueData.with_choices("test_dialogue", "DIALOGUE_TEXT", choices)
	assert_eq(dialogue.choices.size(), 2)


# ═══════════════════════════════════════════════════════════════════════════════
# DialogueAction Tests
# ═══════════════════════════════════════════════════════════════════════════════

func test_action_give_item() -> void:
	var action := DialogueData.DialogueAction.give_item("potion", 3)
	assert_eq(action.action_type, DialogueData.ActionType.GIVE_ITEM)
	assert_eq(action.target_id, "potion")
	assert_eq(action.value, 3)


func test_action_set_flag() -> void:
	var action := DialogueData.DialogueAction.set_flag("test_flag", true)
	assert_eq(action.action_type, DialogueData.ActionType.SET_FLAG)
	assert_eq(action.target_id, "test_flag")
	assert_eq(action.value, true)


func test_action_heal() -> void:
	var action := DialogueData.DialogueAction.heal(50)
	assert_eq(action.action_type, DialogueData.ActionType.HEAL)
	assert_eq(action.value, 50)


func test_action_start_battle() -> void:
	var action := DialogueData.DialogueAction.start_battle("boss_dragon")
	assert_eq(action.action_type, DialogueData.ActionType.START_BATTLE)
	assert_eq(action.target_id, "boss_dragon")


func test_action_end_dialogue() -> void:
	var action := DialogueData.DialogueAction.end_dialogue()
	assert_eq(action.action_type, DialogueData.ActionType.END_DIALOGUE)


# ═══════════════════════════════════════════════════════════════════════════════
# RNA 기반 동적 대화 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_get_dialogue_first_meeting() -> void:
	# 첫 만남 (플래그 없음)
	var rna := {"flags": {}}
	var dialogue := _registry.get_dialogue("old_monk", rna)
	
	assert_not_null(dialogue)
	assert_eq(dialogue.id, "DIALOGUE_OLD_MONK_FIRST")
	assert_eq(dialogue.choices.size(), 2)


func test_get_dialogue_after_meeting() -> void:
	# 이미 만난 경우
	var rna := {"flags": {"old_monk_met": true}}
	var dialogue := _registry.get_dialogue("old_monk", rna)
	
	assert_not_null(dialogue)
	assert_eq(dialogue.id, "DIALOGUE_OLD_MONK_REPEAT")


func test_get_dialogue_flower_spirit_before_quest() -> void:
	var rna := {"flags": {}}
	var dialogue := _registry.get_dialogue("flower_spirit", rna)
	
	assert_not_null(dialogue)
	assert_eq(dialogue.id, "DIALOGUE_FLOWER_SPIRIT_FIRST")


func test_get_dialogue_flower_spirit_after_complete() -> void:
	var rna := {"flags": {"incense_burner_complete": true}}
	var dialogue := _registry.get_dialogue("flower_spirit", rna)
	
	assert_not_null(dialogue)
	assert_eq(dialogue.id, "DIALOGUE_FLOWER_SPIRIT_COMPLETE")