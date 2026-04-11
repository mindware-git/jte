class_name CutsceneData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# CutsceneData
# 컷신 단위 데이터 (명령 시퀀스 + 메타데이터)
# ═══════════════════════════════════════════════════════════════════════════════

## 컷신 ID (예: "part1_opening")
var id: String = ""

## 배경 맵 ID (scenes/locations/{location_id}.tscn 로드)
## 비어있으면 맵 없이 단색 배경
var location_id: String = ""

## 컷신 제목 번역 키 (표시용, optional)
var title_key: String = ""

## 명령 시퀀스
var commands: Array[CutsceneCommand] = []

## 종료 후 전환할 Screen ("explore", "battle", "select" 등)
var next_screen: String = "explore"

## 종료 후 추가 RNA 업데이트 (optional)
var on_complete_data: Dictionary = {}


# ═══════════════════════════════════════════════════════════════════════════════
# Builder Methods
# ═══════════════════════════════════════════════════════════════════════════════

## 명령 추가 (체이닝 가능)
func add(cmd: CutsceneCommand) -> CutsceneData:
	commands.append(cmd)
	return self


## 명령 개수
func command_count() -> int:
	return commands.size()


# ═══════════════════════════════════════════════════════════════════════════════
# Factory
# ═══════════════════════════════════════════════════════════════════════════════

static func create(
	p_id: String,
	p_location_id: String = "",
	p_next_screen: String = "explore"
) -> CutsceneData:
	var data := CutsceneData.new()
	data.id = p_id
	data.location_id = p_location_id
	data.next_screen = p_next_screen
	return data
