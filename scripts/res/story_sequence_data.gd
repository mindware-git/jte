class_name StorySequenceData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# StorySequenceData
# 개별 대화/연출 단위 데이터 클래스 (i18n 지원)
# ═══════════════════════════════════════════════════════════════════════════════

## 화자 ID
## 예: "samjang", "sonogong", "narration", "old_monk"
var speaker_id: String = "narration"

## 텍스트 번역 키
## 예: "ACT1_PROLOGUE_001"
var text_key: String = ""

## 완료 시 트리거할 이벤트 ID
## 예: "unlock_sonogong", "start_battle"
var trigger_event: String = ""


# ═══════════════════════════════════════════════════════════════════════════════
# Factory Method
# ═══════════════════════════════════════════════════════════════════════════════

static func create(p_speaker_id: String, p_text_key: String, p_trigger: String = "") -> StorySequenceData:
	var seq := StorySequenceData.new()
	seq.speaker_id = p_speaker_id
	seq.text_key = p_text_key
	seq.trigger_event = p_trigger
	return seq
