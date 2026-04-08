class_name InteractionData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# InteractionData
# 상호작용 정보 데이터 클래스
# ═══════════════════════════════════════════════════════════════════════════════

## 상호작용 타입 열거형
enum Type {
	NPC,        # NPC 대화
	SHOP,       # 상점
	INVESTIGATE, # 조사/탐색
	STORY,      # 스토리 이벤트
	BATTLE,     # 전투
	PUZZLE,     # 퍼즐
	LOCATION,   # 다른 위치/건물로 이동
}

## 상호작용 ID
## 예: "tavern", "well", "old_monk"
var id: String = ""

## 표시 이름 번역 키
## 예: "INTERACT_TAVERN"
var name_key: String = ""

## 상호작용 타입
var type: Type = Type.INVESTIGATE

## 연결된 대상 ID
## NPC면 NPC ID, 상점이면 상점 ID, 스토리면 챕터 ID
var target_id: String = ""


# ═══════════════════════════════════════════════════════════════════════════════
# Factory Methods
# ═══════════════════════════════════════════════════════════════════════════════

static func create(
	p_id: String,
	p_name_key: String,
	p_type: Type,
	p_target_id: String = ""
) -> InteractionData:
	var interact := InteractionData.new()
	interact.id = p_id
	interact.name_key = p_name_key
	interact.type = p_type
	interact.target_id = p_target_id
	return interact


static func npc(p_id: String, p_name_key: String, p_npc_id: String = "") -> InteractionData:
	return create(p_id, p_name_key, Type.NPC, p_npc_id if p_npc_id != "" else p_id)


static func shop(p_id: String, p_name_key: String, p_shop_id: String = "") -> InteractionData:
	return create(p_id, p_name_key, Type.SHOP, p_shop_id if p_shop_id != "" else p_id)


static func investigate(p_id: String, p_name_key: String, p_target_id: String = "") -> InteractionData:
	return create(p_id, p_name_key, Type.INVESTIGATE, p_target_id)


static func story(p_id: String, p_name_key: String, p_chapter_id: String) -> InteractionData:
	return create(p_id, p_name_key, Type.STORY, p_chapter_id)


static func battle(p_id: String, p_name_key: String, p_enemy_id: String) -> InteractionData:
	return create(p_id, p_name_key, Type.BATTLE, p_enemy_id)


static func puzzle(p_id: String, p_name_key: String, p_puzzle_id: String = "") -> InteractionData:
	return create(p_id, p_name_key, Type.PUZZLE, p_puzzle_id if p_puzzle_id != "" else p_id)


static func location(p_id: String, p_name_key: String, p_location_id: String = "") -> InteractionData:
	return create(p_id, p_name_key, Type.LOCATION, p_location_id if p_location_id != "" else p_id)
