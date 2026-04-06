class_name LocationData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# LocationData
# 위치 정보 데이터 클래스 (DNA - 저장 호환)
# ═══════════════════════════════════════════════════════════════════════════════

## 위치 ID
## 예: "cheongmok_village", "mountain_entrance"
var id: String = ""

## 위치 이름 번역 키
## 예: "LOC_CHEONGMOK"
var name_key: String = ""

## 위치 설명 번역 키
## 예: "LOC_CHEONGMOK_DESC"
var desc_key: String = ""

## 이동 가능한 위치 ID 목록
var connections: Array[String] = []

## 상호작용 ID 목록
var interactions: Array[String] = []


# ═══════════════════════════════════════════════════════════════════════════════
# Factory Method
# ═══════════════════════════════════════════════════════════════════════════════

static func create(
	p_id: String,
	p_name_key: String,
	p_desc_key: String = "",
	p_connections: Array[String] = [],
	p_interactions: Array[String] = []
) -> LocationData:
	var loc := LocationData.new()
	loc.id = p_id
	loc.name_key = p_name_key
	loc.desc_key = p_desc_key
	loc.connections = p_connections
	loc.interactions = p_interactions
	return loc