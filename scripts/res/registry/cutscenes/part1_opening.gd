class_name Part1Opening
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# Part 1 오프닝 컷신
# 삼장이 청목진에 도착하여 손오공의 봉인을 풀고 만나는 장면
# ═══════════════════════════════════════════════════════════════════════════════

const CUTSCENE_ID := "part1_opening"


static func get_cutscene_data() -> CutsceneData:
	var cs := CutsceneData.create(CUTSCENE_ID, "bluewood_village", "explore")
	cs.title_key = "CHAPTER_ACT1_TITLE"

	# ─── 장면 1: 페이드 인 + 나레이션 ────────────────────────────────────

	cs.add(CutsceneCommand.fade("in", 1.5))

	# 삼장 등장 (마을 입구)
	cs.add(CutsceneCommand.spawn("sanzang", "sanzang", Vector2i(11, 14), "up"))
	cs.add(CutsceneCommand.camera_follow("sanzang"))

	# 나레이션
	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_001"))
	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_002"))

	# ─── 장면 2: 노승과의 대화 ───────────────────────────────────────────

	# 노승 등장
	cs.add(CutsceneCommand.spawn("old_monk", "old_monk", Vector2i(11, 8), "down"))

	# 삼장 이동 (노승 앞으로)
	cs.add(CutsceneCommand.move("sanzang", Vector2i(11, 10)))
	cs.add(CutsceneCommand.wait(0.5))

	# 노승의 말
	cs.add(CutsceneCommand.say("old_monk", "ACT1_PROLOGUE_003"))
	cs.add(CutsceneCommand.say("old_monk", "ACT1_PROLOGUE_004"))
	cs.add(CutsceneCommand.say("old_monk", "ACT1_PROLOGUE_005"))

	# 삼장의 반응
	cs.add(CutsceneCommand.say("sanzang", "ACT1_PROLOGUE_006"))

	# 노승 퇴장
	cs.add(CutsceneCommand.move("old_monk", Vector2i(15, 8)))
	cs.add(CutsceneCommand.despawn("old_monk"))

	# ─── 장면 3: 여정 ────────────────────────────────────────────────────

	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_007"))
	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_008"))
	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_009"))

	# 삼장 산 위로 이동
	cs.add(CutsceneCommand.move("sanzang", Vector2i(11, 4)))

	# ─── 장면 4: 봉인 발견, 손오공 등장 ─────────────────────────────────

	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_010"))
	cs.add(CutsceneCommand.say("sanzang", "ACT1_PROLOGUE_011"))

	# 봉인 해방 연출
	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_012"))
	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_013"))

	# 손오공 등장
	cs.add(CutsceneCommand.spawn("wukong", "wukong", Vector2i(11, 3), "down"))
	cs.add(CutsceneCommand.camera_follow("wukong"))
	cs.add(CutsceneCommand.wait(0.5))

	cs.add(CutsceneCommand.say("unknown", "ACT1_PROLOGUE_014"))
	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_015"))

	# ─── 장면 5: 첫 대화 ─────────────────────────────────────────────────

	# 카메라를 두 캐릭터 사이로
	cs.add(CutsceneCommand.camera(Vector2i(11, 4), 1.0, 0.5))

	cs.add(CutsceneCommand.say("wukong", "ACT1_PROLOGUE_016"))
	cs.add(CutsceneCommand.say("sanzang", "ACT1_PROLOGUE_017"))
	cs.add(CutsceneCommand.say("wukong", "ACT1_PROLOGUE_018"))
	cs.add(CutsceneCommand.say("wukong", "ACT1_PROLOGUE_019"))

	# 마무리
	cs.add(CutsceneCommand.say("narration", "ACT1_PROLOGUE_020"))

	# 플래그 설정
	cs.add(CutsceneCommand.set_flag("prologue_completed", true))
	cs.add(CutsceneCommand.set_flag("wukong_unlocked", true))

	# 페이드 아웃
	cs.add(CutsceneCommand.fade("out", 1.0))

	return cs
