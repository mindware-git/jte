class_name CutsceneCommand
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# CutsceneCommand
# 컷신 개별 명령 데이터
# ═══════════════════════════════════════════════════════════════════════════════

## 명령 타입
enum CommandType {
	SPAWN,       ## 캐릭터 등장
	MOVE,        ## 캐릭터 이동
	DIALOGUE,    ## 대화 (DialoguePanel 오버레이)
	WAIT,        ## 대기
	ANIMATE,     ## 애니메이션 재생
	CAMERA,      ## 카메라 이동/줌
	DESPAWN,     ## 캐릭터 퇴장
	SET_FLAG,    ## 플래그 설정
	FADE,        ## 화면 페이드
	SE,          ## 사운드 이펙트
}

var type: CommandType
var params: Dictionary = {}


# ═══════════════════════════════════════════════════════════════════════════════
# Factory Methods
# ═══════════════════════════════════════════════════════════════════════════════

## 캐릭터 등장
## actor_id: 컷신 내 식별 ID (예: "sanzang")
## character_id: CharacterRegistry ID (예: "sanzang")
## tile: 등장 위치 (그리드 좌표)
## direction: 방향 ("down", "up", "left", "right")
static func spawn(
	actor_id: String,
	character_id: String,
	tile: Vector2i,
	direction: String = "down"
) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.SPAWN
	cmd.params = {
		"actor_id": actor_id,
		"character_id": character_id,
		"tile": tile,
		"direction": direction,
	}
	return cmd


## 캐릭터 이동
## actor_id: 이동할 캐릭터
## target_tile: 목표 그리드 좌표
static func move(actor_id: String, target_tile: Vector2i) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.MOVE
	cmd.params = {
		"actor_id": actor_id,
		"target_tile": target_tile,
	}
	return cmd


## 대화 (DialoguePanel 오버레이)
## npc_id: NPCRegistry에서 조회할 NPC ID
static func dialogue(npc_id: String) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.DIALOGUE
	cmd.params = {
		"npc_id": npc_id,
	}
	return cmd


## 단순 대사 (NPC 없이 화자 + 텍스트만)
## speaker_id: 화자 ID
## text_key: 번역 키
static func say(speaker_id: String, text_key: String) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.DIALOGUE
	cmd.params = {
		"speaker_id": speaker_id,
		"text_key": text_key,
		"simple": true,
	}
	return cmd


## 대기
## duration: 대기 시간 (초, 가속 적용됨)
static func wait(duration: float) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.WAIT
	cmd.params = {
		"duration": duration,
	}
	return cmd


## 애니메이션 재생
## actor_id: 대상 캐릭터
## animation_name: 재생할 애니메이션 이름
static func animate(actor_id: String, animation_name: String) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.ANIMATE
	cmd.params = {
		"actor_id": actor_id,
		"animation_name": animation_name,
	}
	return cmd


## 카메라 이동/줌
## target_tile: 카메라 목표 위치 (그리드 좌표)
## zoom: 줌 레벨 (1.0 = 기본)
## duration: 이동 시간 (초)
static func camera(
	target_tile: Vector2i,
	zoom: float = 1.0,
	duration: float = 1.0
) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.CAMERA
	cmd.params = {
		"target_tile": target_tile,
		"zoom": zoom,
		"duration": duration,
	}
	return cmd


## 카메라 액터 추적
## actor_id: 추적할 캐릭터
## duration: 이동 시간 (초)
static func camera_follow(actor_id: String, duration: float = 0.5) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.CAMERA
	cmd.params = {
		"follow_actor": actor_id,
		"duration": duration,
	}
	return cmd


## 캐릭터 퇴장
## actor_id: 퇴장할 캐릭터
static func despawn(actor_id: String) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.DESPAWN
	cmd.params = {
		"actor_id": actor_id,
	}
	return cmd


## 플래그 설정
## flag_name: 플래그 이름
## value: 플래그 값
static func set_flag(flag_name: String, value: Variant = true) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.SET_FLAG
	cmd.params = {
		"flag_name": flag_name,
		"value": value,
	}
	return cmd


## 화면 페이드
## fade_type: "in" 또는 "out"
## duration: 페이드 시간 (초)
## color: 페이드 색상
static func fade(
	fade_type: String,
	duration: float = 1.0,
	color: Color = Color.BLACK
) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.FADE
	cmd.params = {
		"fade_type": fade_type,
		"duration": duration,
		"color": color,
	}
	return cmd


## 사운드 이펙트
## sound_id: 사운드 리소스 ID
static func se(sound_id: String) -> CutsceneCommand:
	var cmd := CutsceneCommand.new()
	cmd.type = CommandType.SE
	cmd.params = {
		"sound_id": sound_id,
	}
	return cmd
