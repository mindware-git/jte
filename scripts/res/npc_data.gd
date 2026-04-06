class_name NPCData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# NPCData
# NPC 데이터 구조
# ═══════════════════════════════════════════════════════════════════════════════

## NPC ID
var id: String = ""

## 표시 이름 번역 키
var display_name_key: String = ""

## 초상화 리소스 경로
var portrait: String = ""

## 기본 대화 ID
var default_dialogue_id: String = ""

## 위치 ID (어느 위치에 있는지)
var location_id: String = ""


# ═══════════════════════════════════════════════════════════════════════════════
# Factory
# ═══════════════════════════════════════════════════════════════════════════════

static func create(
	p_id: String,
	p_display_name_key: String,
	p_location_id: String,
	p_default_dialogue_id: String = "",
	p_portrait: String = ""
) -> NPCData:
	var npc := NPCData.new()
	npc.id = p_id
	npc.display_name_key = p_display_name_key
	npc.location_id = p_location_id
	npc.default_dialogue_id = p_default_dialogue_id if p_default_dialogue_id != "" else "DIALOGUE_" + p_id.to_upper()
	npc.portrait = p_portrait
	return npc