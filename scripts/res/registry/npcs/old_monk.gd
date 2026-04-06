class_name OldMonk
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 노승 (老僧)
# 청목진의 주점에 있는 노승
# 약주를 주는 이벤트
# ═══════════════════════════════════════════════════════════════════════════════

const NPC_ID := "old_monk"


static func get_npc_data() -> NPCData:
	return NPCData.create(
		NPC_ID,
		"NPC_OLD_MONK",
		"cheongmok_village",
		"DIALOGUE_OLD_MONK_FIRST"
	)


static func get_dialogue(rna: Dictionary) -> DialogueData:
	# RNA 상태에 따른 동적 대화
	if rna.get("flags", {}).get("old_monk_met", false):
		# 이미 만난 경우
		return _get_repeat_dialogue()
	else:
		# 첫 만남
		return _get_first_dialogue()


static func _get_first_dialogue() -> DialogueData:
	return DialogueData.with_choices(
		"DIALOGUE_OLD_MONK_FIRST",
		"DIALOGUE_OLD_MONK_FIRST_TEXT",
		[
			# 약주를 받는다
			DialogueData.DialogueChoice.create(
				"CHOICE_ACCEPT_DRINK",
				"DIALOGUE_OLD_MONK_ACCEPT",
				[
					DialogueData.DialogueAction.give_item("medicine_wine", 1),
					DialogueData.DialogueAction.set_flag("old_monk_met", true),
					DialogueData.DialogueAction.end_dialogue()
				]
			),
			# 사양한다
			DialogueData.DialogueChoice.create(
				"CHOICE_DECLINE_DRINK",
				"DIALOGUE_OLD_MONK_DECLINE",
				[
					DialogueData.DialogueAction.set_flag("old_monk_met", true),
					DialogueData.DialogueAction.end_dialogue()
				]
			)
		]
	)


static func _get_repeat_dialogue() -> DialogueData:
	return DialogueData.simple(
		"DIALOGUE_OLD_MONK_REPEAT",
		"DIALOGUE_OLD_MONK_REPEAT_TEXT"
	)