extends GutTest

# ═══════════════════════════════════════════════════════════════════════════════
# CutsceneRegistry 테스트
# ═══════════════════════════════════════════════════════════════════════════════

var _registry: CutsceneRegistry


func before_each() -> void:
	_registry = CutsceneRegistry.new()


# ═══════════════════════════════════════════════════════════════════════════════
# 컷신 조회 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_has_cutscene() -> void:
	assert_true(_registry.has_cutscene("part1_opening"), "part1_opening 컷신이 존재해야 함")
	assert_false(_registry.has_cutscene("nonexistent"), "존재하지 않는 컷신은 false")


func test_get_cutscene_returns_data() -> void:
	var cs := _registry.get_cutscene("part1_opening")
	assert_not_null(cs, "part1_opening 컷신 데이터가 존재해야 함")
	assert_eq(cs.id, "part1_opening")


func test_get_cutscene_null_for_nonexistent() -> void:
	var cs := _registry.get_cutscene("nonexistent")
	assert_null(cs, "존재하지 않는 컷신은 null")


func test_get_cutscene_has_commands() -> void:
	var cs := _registry.get_cutscene("part1_opening")
	assert_true(cs.command_count() > 0, "명령이 1개 이상 있어야 함")


func test_get_cutscene_location_id() -> void:
	var cs := _registry.get_cutscene("part1_opening")
	assert_eq(cs.location_id, "bluewood_village", "배경 맵이 bluewood_village여야 함")


func test_get_cutscene_next_screen() -> void:
	var cs := _registry.get_cutscene("part1_opening")
	assert_eq(cs.next_screen, "explore", "종료 후 explore로 전환")


func test_get_all_cutscene_ids() -> void:
	var ids := _registry.get_all_cutscene_ids()
	assert_true(ids.has("part1_opening"), "part1_opening이 목록에 있어야 함")


# ═══════════════════════════════════════════════════════════════════════════════
# CutsceneCommand 팩토리 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_spawn_command() -> void:
	var cmd := CutsceneCommand.spawn("sanzang", "sanzang", Vector2i(5, 10), "up")
	assert_eq(cmd.type, CutsceneCommand.CommandType.SPAWN)
	assert_eq(cmd.params["actor_id"], "sanzang")
	assert_eq(cmd.params["character_id"], "sanzang")
	assert_eq(cmd.params["tile"], Vector2i(5, 10))
	assert_eq(cmd.params["direction"], "up")


func test_move_command() -> void:
	var cmd := CutsceneCommand.move("sanzang", Vector2i(10, 5))
	assert_eq(cmd.type, CutsceneCommand.CommandType.MOVE)
	assert_eq(cmd.params["actor_id"], "sanzang")
	assert_eq(cmd.params["target_tile"], Vector2i(10, 5))


func test_say_command() -> void:
	var cmd := CutsceneCommand.say("narration", "TEST_KEY")
	assert_eq(cmd.type, CutsceneCommand.CommandType.DIALOGUE)
	assert_eq(cmd.params["speaker_id"], "narration")
	assert_eq(cmd.params["text_key"], "TEST_KEY")
	assert_true(cmd.params["simple"])


func test_dialogue_command() -> void:
	var cmd := CutsceneCommand.dialogue("old_monk")
	assert_eq(cmd.type, CutsceneCommand.CommandType.DIALOGUE)
	assert_eq(cmd.params["npc_id"], "old_monk")
	assert_false(cmd.params.get("simple", false))


func test_wait_command() -> void:
	var cmd := CutsceneCommand.wait(2.5)
	assert_eq(cmd.type, CutsceneCommand.CommandType.WAIT)
	assert_eq(cmd.params["duration"], 2.5)


func test_animate_command() -> void:
	var cmd := CutsceneCommand.animate("wukong", "attack")
	assert_eq(cmd.type, CutsceneCommand.CommandType.ANIMATE)
	assert_eq(cmd.params["actor_id"], "wukong")
	assert_eq(cmd.params["animation_name"], "attack")


func test_camera_command() -> void:
	var cmd := CutsceneCommand.camera(Vector2i(5, 5), 2.0, 1.5)
	assert_eq(cmd.type, CutsceneCommand.CommandType.CAMERA)
	assert_eq(cmd.params["target_tile"], Vector2i(5, 5))
	assert_eq(cmd.params["zoom"], 2.0)
	assert_eq(cmd.params["duration"], 1.5)


func test_camera_follow_command() -> void:
	var cmd := CutsceneCommand.camera_follow("sanzang", 0.5)
	assert_eq(cmd.type, CutsceneCommand.CommandType.CAMERA)
	assert_eq(cmd.params["follow_actor"], "sanzang")
	assert_eq(cmd.params["duration"], 0.5)


func test_despawn_command() -> void:
	var cmd := CutsceneCommand.despawn("old_monk")
	assert_eq(cmd.type, CutsceneCommand.CommandType.DESPAWN)
	assert_eq(cmd.params["actor_id"], "old_monk")


func test_set_flag_command() -> void:
	var cmd := CutsceneCommand.set_flag("test_flag", true)
	assert_eq(cmd.type, CutsceneCommand.CommandType.SET_FLAG)
	assert_eq(cmd.params["flag_name"], "test_flag")
	assert_eq(cmd.params["value"], true)


func test_fade_command() -> void:
	var cmd := CutsceneCommand.fade("in", 1.5, Color.WHITE)
	assert_eq(cmd.type, CutsceneCommand.CommandType.FADE)
	assert_eq(cmd.params["fade_type"], "in")
	assert_eq(cmd.params["duration"], 1.5)
	assert_eq(cmd.params["color"], Color.WHITE)


func test_se_command() -> void:
	var cmd := CutsceneCommand.se("explosion")
	assert_eq(cmd.type, CutsceneCommand.CommandType.SE)
	assert_eq(cmd.params["sound_id"], "explosion")


# ═══════════════════════════════════════════════════════════════════════════════
# CutsceneData 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_cutscene_data_create() -> void:
	var cs := CutsceneData.create("test", "test_map", "battle")
	assert_eq(cs.id, "test")
	assert_eq(cs.location_id, "test_map")
	assert_eq(cs.next_screen, "battle")
	assert_eq(cs.command_count(), 0)


func test_cutscene_data_add_commands() -> void:
	var cs := CutsceneData.create("test")
	cs.add(CutsceneCommand.spawn("a", "a", Vector2i.ZERO))
	cs.add(CutsceneCommand.move("a", Vector2i(1, 1)))
	cs.add(CutsceneCommand.despawn("a"))
	assert_eq(cs.command_count(), 3)


func test_cutscene_data_chaining() -> void:
	var cs := CutsceneData.create("test")
	var result := cs.add(CutsceneCommand.wait(1.0))
	assert_eq(result, cs, "add()는 self를 반환해야 함 (체이닝)")
