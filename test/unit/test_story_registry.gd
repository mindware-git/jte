extends GutTest

# ═══════════════════════════════════════════════════════════════════════════════
# StoryRegistry 테스트
# ═══════════════════════════════════════════════════════════════════════════════

var _registry: StoryRegistry


func before_each() -> void:
	_registry = StoryRegistry.new()


# ═══════════════════════════════════════════════════════════════════════════════
# 챕터 조회 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_has_chapter() -> void:
	assert_true(_registry.has_chapter("act1_prologue"), "act1_prologue 챕터가 존재해야 함")
	assert_false(_registry.has_chapter("nonexistent"), "존재하지 않는 챕터는 false")


func test_get_chapter_returns_sequences() -> void:
	var sequences := _registry.get_chapter("act1_prologue")
	assert_eq(sequences.size(), 20, "시퀀스가 20개여야 함")


func test_get_chapter_empty_for_nonexistent() -> void:
	var sequences := _registry.get_chapter("nonexistent")
	assert_eq(sequences.size(), 0, "존재하지 않는 챕터는 빈 배열")


func test_get_chapter_title_key() -> void:
	var title_key := _registry.get_chapter_title_key("act1_prologue")
	assert_eq(title_key, "CHAPTER_ACT1_TITLE", "챕터 제목 키가 올바라야 함")


func test_get_chapter_title_key_empty_for_nonexistent() -> void:
	var title_key := _registry.get_chapter_title_key("nonexistent")
	assert_eq(title_key, "", "존재하지 않는 챕터는 빈 문자열")


func test_get_next_chapter_empty() -> void:
	var next := _registry.get_next_chapter("act1_prologue")
	assert_eq(next, "", "다음 챕터가 없으면 빈 문자열")


# ═══════════════════════════════════════════════════════════════════════════════
# 시퀀스 데이터 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_sequence_speaker_ids() -> void:
	var sequences := _registry.get_chapter("act1_prologue")
	
	# 첫 번째 시퀀스는 나레이션
	assert_eq(sequences[0].speaker_id, "narration", "첫 시퀀스는 나레이션")
	
	# 노승 시퀀스 확인 (3번째, 인덱스 2)
	assert_eq(sequences[2].speaker_id, "old_monk", "3번째 시퀀스는 노승")
	
	# 삼장 시퀀스 확인 (6번째, 인덱스 5)
	assert_eq(sequences[5].speaker_id, "sanzang", "6번째 시퀀스는 삼장")
	
	# 손오공 시퀀스 확인 (16번째, 인덱스 15)
	assert_eq(sequences[15].speaker_id, "wukong", "16번째 시퀀스는 손오공")


func test_sequence_text_keys() -> void:
	var sequences := _registry.get_chapter("act1_prologue")
	
	assert_eq(sequences[0].text_key, "ACT1_PROLOGUE_001", "첫 시퀀스 텍스트 키")
	assert_eq(sequences[2].text_key, "ACT1_PROLOGUE_003", "노승 첫 대사 텍스트 키")


# ═══════════════════════════════════════════════════════════════════════════════
# 화자 이름 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_get_speaker_name() -> void:
	assert_eq(_registry.get_speaker_name("narration"), "나레이션")
	assert_eq(_registry.get_speaker_name("sanzang"), "삼장")
	assert_eq(_registry.get_speaker_name("wukong"), "손오공")
	assert_eq(_registry.get_speaker_name("old_monk"), "노승")
	assert_eq(_registry.get_speaker_name("unknown"), "???")


func test_get_speaker_name_unknown_returns_id() -> void:
	# 등록되지 않은 화자 ID는 그대로 반환
	assert_eq(_registry.get_speaker_name("some_unknown_speaker"), "some_unknown_speaker")


# ═══════════════════════════════════════════════════════════════════════════════
# StorySequenceData 팩토리 테스트
# ═══════════════════════════════════════════════════════════════════════════════

func test_story_sequence_data_create() -> void:
	var seq := StorySequenceData.create("test_speaker", "TEST_KEY", "test_event")
	
	assert_eq(seq.speaker_id, "test_speaker")
	assert_eq(seq.text_key, "TEST_KEY")
	assert_eq(seq.trigger_event, "test_event")


func test_story_sequence_data_create_no_trigger() -> void:
	var seq := StorySequenceData.create("test_speaker", "TEST_KEY")
	
	assert_eq(seq.speaker_id, "test_speaker")
	assert_eq(seq.text_key, "TEST_KEY")
	assert_eq(seq.trigger_event, "")
