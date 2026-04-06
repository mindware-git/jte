class_name StoryRegistry
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# 스토리 데이터 레지스트리 (Code-First)
# ═══════════════════════════════════════════════════════════════════════════════

# 챕터별 시퀀스 배열
var _chapters: Dictionary = {}

# 챕터 메타데이터 { title, next_chapter }
var _chapter_metadata: Dictionary = {}

# 화자 이름 매핑
var _speaker_names: Dictionary = {}


func _init() -> void:
	_register_speakers()
	_register_all_chapters()


# ═══════════════════════════════════════════════════════════════════════════════
# 화자 등록
# ═══════════════════════════════════════════════════════════════════════════════

func _register_speakers() -> void:
	_speaker_names = {
		"narration": "나레이션",
		"sanzang": "삼장",
		"wukong": "손오공",
		"old_monk": "노승",
		"unknown": "???",
	}


# ═══════════════════════════════════════════════════════════════════════════════
# 챕터 등록
# ═══════════════════════════════════════════════════════════════════════════════

func _register_all_chapters() -> void:
	_register_act1_prologue()


func _register_act1_prologue() -> void:
	var chapter_id := "act1_prologue"
	var sequences: Array[StorySequenceData] = []
	
	# 1-2: 사원에서 전승을 듣는다
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_001"))
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_002"))
	
	# 3-5: 노승의 말
	sequences.append(StorySequenceData.create("old_monk", "ACT1_PROLOGUE_003"))
	sequences.append(StorySequenceData.create("old_monk", "ACT1_PROLOGUE_004"))
	sequences.append(StorySequenceData.create("old_monk", "ACT1_PROLOGUE_005"))
	
	# 6: 삼장의 반응
	sequences.append(StorySequenceData.create("sanzang", "ACT1_PROLOGUE_006"))
	
	# 7-9: 여정
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_007"))
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_008"))
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_009"))
	
	# 10-11: 봉인 발견
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_010"))
	sequences.append(StorySequenceData.create("sanzang", "ACT1_PROLOGUE_011"))
	
	# 12-13: 봉인 해방
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_012"))
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_013"))
	
	# 14-15: 손오공 등장
	sequences.append(StorySequenceData.create("unknown", "ACT1_PROLOGUE_014"))
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_015"))
	
	# 16-19: 첫 대화
	sequences.append(StorySequenceData.create("wukong", "ACT1_PROLOGUE_016"))
	sequences.append(StorySequenceData.create("sanzang", "ACT1_PROLOGUE_017"))
	sequences.append(StorySequenceData.create("wukong", "ACT1_PROLOGUE_018"))
	sequences.append(StorySequenceData.create("wukong", "ACT1_PROLOGUE_019"))
	
	# 20: 마무리
	sequences.append(StorySequenceData.create("narration", "ACT1_PROLOGUE_020"))
	
	_chapters[chapter_id] = sequences
	_chapter_metadata[chapter_id] = {
		"title_key": "CHAPTER_ACT1_TITLE",
		"next_chapter": ""
	}


# ═══════════════════════════════════════════════════════════════════════════════
# 조회 메서드
# ═══════════════════════════════════════════════════════════════════════════════

func get_chapter(chapter_id: String) -> Array[StorySequenceData]:
	if _chapters.has(chapter_id):
		return _chapters[chapter_id]
	return []


func get_chapter_title_key(chapter_id: String) -> String:
	if _chapter_metadata.has(chapter_id):
		return _chapter_metadata[chapter_id].get("title_key", "")
	return ""


func get_next_chapter(chapter_id: String) -> String:
	if _chapter_metadata.has(chapter_id):
		return _chapter_metadata[chapter_id].get("next_chapter", "")
	return ""


func get_speaker_name(speaker_id: String) -> String:
	return _speaker_names.get(speaker_id, speaker_id)


func has_chapter(chapter_id: String) -> bool:
	return _chapters.has(chapter_id)


func get_all_chapter_ids() -> Array[String]:
	var result: Array[String] = []
	for key in _chapters.keys():
		result.append(key)
	return result