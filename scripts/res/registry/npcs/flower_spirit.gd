class_name FlowerSpirit
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 꽃정령 (花精)
# 오행제단의 꽃정령
# 자비환 획득 이벤트
# ═══════════════════════════════════════════════════════════════════════════════

const NPC_ID := "flower_spirit"


static func get_npc_data() -> NPCData:
	return NPCData.create(
		NPC_ID,
		"NPC_FLOWER_SPIRIT",
		"shrine",
		"DIALOGUE_FLOWER_SPIRIT_FIRST"
	)


static func get_dialogue(rna: Dictionary) -> DialogueData:
	# 오행향로 완성 여부에 따른 분기
	if rna.get("flags", {}).get("incense_burner_complete", false):
		return _get_after_complete_dialogue()
	elif rna.get("flags", {}).get("flower_spirit_met", false):
		return _get_repeat_dialogue()
	else:
		return _get_first_dialogue()


static func _get_first_dialogue() -> DialogueData:
	return DialogueData.with_choices(
		"DIALOGUE_FLOWER_SPIRIT_FIRST",
		"DIALOGUE_FLOWER_SPIRIT_FIRST_TEXT",
		[
			# 도와주겠다고 한다
			DialogueData.DialogueChoice.create(
				"CHOICE_HELP_SPIRIT",
				"DIALOGUE_FLOWER_SPIRIT_HELP",
				[
					DialogueData.DialogueAction.set_flag("flower_spirit_met", true),
					DialogueData.DialogueAction.set_flag("incense_burner_quest", true),
					DialogueData.DialogueAction.end_dialogue()
				]
			),
			# 바쁘다고 한다
			DialogueData.DialogueChoice.create(
				"CHOICE_DECLINE_HELP",
				"DIALOGUE_FLOWER_SPIRIT_DECLINE",
				[
					DialogueData.DialogueAction.end_dialogue()
				]
			)
		]
	)


static func _get_repeat_dialogue() -> DialogueData:
	return DialogueData.simple(
		"DIALOGUE_FLOWER_SPIRIT_REPEAT",
		"DIALOGUE_FLOWER_SPIRIT_REPEAT_TEXT"
	)


static func _get_after_complete_dialogue() -> DialogueData:
	return DialogueData.simple(
		"DIALOGUE_FLOWER_SPIRIT_COMPLETE",
		"DIALOGUE_FLOWER_SPIRIT_COMPLETE_TEXT"
	)