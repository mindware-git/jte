class_name OldMan
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 허풍 노인 (虚風老人)
# 청목진 주점의 수상한 노인
# 비싼 약주를 사주면 봉인 구절 힌트를 준다
# ═══════════════════════════════════════════════════════════════════════════════

const NPC_ID := "old_man"


static func get_npc_data() -> NPCData:
	return NPCData.create(
		NPC_ID,
		"NPC_OLD_MAN",
		"bluewood_village",
		"DIALOGUE_OLD_MAN_FIRST"
	)


static func get_dialogue(rna: Dictionary) -> DialogueData:
	# RNA 상태에 따른 동적 대화
	var flags: Dictionary = rna.get("flags", {})
	
	if flags.get("seal_hint_received", false):
		# 이미 힌트를 받은 경우
		return _get_repeat_dialogue()
	elif flags.get("old_man_wine_given", false):
		# 약주를 줬지만 아직 힌트를 못 받은 경우
		return _get_hint_dialogue()
	else:
		# 첫 만남
		return _get_first_dialogue()


static func _get_first_dialogue() -> DialogueData:
	return DialogueData.with_choices(
		"DIALOGUE_OLD_MAN_FIRST",
		"DIALOGUE_OLD_MAN_FIRST_TEXT",
		[
			# 비싼 약주를 사준다 (100금)
			DialogueData.DialogueChoice.create(
				"CHOICE_BUY_WINE",
				"DIALOGUE_OLD_MAN_BUY_WINE",
				[
					DialogueData.DialogueAction.set_flag("old_man_wine_given", true),
				]
			),
			# 사양한다
			DialogueData.DialogueChoice.create(
				"CHOICE_DECLINE",
				"DIALOGUE_OLD_MAN_DECLINE",
				[
					DialogueData.DialogueAction.end_dialogue()
				]
			)
		]
	)


static func _get_hint_dialogue() -> DialogueData:
	return DialogueData.with_choices(
		"DIALOGUE_OLD_MAN_HINT",
		"DIALOGUE_OLD_MAN_HINT_TEXT",
		[
			# 힌트를 듣는다
			DialogueData.DialogueChoice.create(
				"CHOICE_LISTEN_HINT",
				"DIALOGUE_OLD_MAN_RECEIVE_HINT",
				[
					DialogueData.DialogueAction.set_flag("seal_hint_received", true),
					DialogueData.DialogueAction.end_dialogue()
				]
			),
		]
	)


static func _get_repeat_dialogue() -> DialogueData:
	return DialogueData.simple(
		"DIALOGUE_OLD_MAN_REPEAT",
		"DIALOGUE_OLD_MAN_REPEAT_TEXT"
	)