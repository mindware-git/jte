# Implementation Plan

## Overview

Actor 클래스를 통합하여 Player, NPC, Battle Unit이 모두 같은 Actor 클래스를 사용하도록 리팩토링하고, 타일 기반 이동 시스템을 구현하여 첫 맵에서 플레이어가 나타나도록 합니다.

기존에는 `Character`, `BattleCharacter`, `Actor`가 분리되어 있어 코드 중복과 복잡성이 증가했습니다. 이를 단일 `Actor` 클래스로 통합하고, 컨텍스트별 동작은 `ActorRole` enum과 내부 상태로 처리합니다. 타일 기반 이동은 `CharacterBody2D` 대신 직접 그리드 좌표 계산으로 구현합니다.

---

## [Types]

단일 Actor 클래스가 모든 캐릭터 타입을 처리하며, 역할과 상태를 enum으로 구분합니다.

### ActorRole (enum)
```gdscript
enum ActorRole {
    NONE,      ## 역할 없음 (기본 상태)
    PLAYER,    ## 플레이어 (사용자 입력 제어)
    NPC,       ## NPC (대화, 상호작용)
    ENEMY      ## 적 (전투 AI)
}
```

### ActorState (enum)
```gdscript
enum ActorState {
    IDLE,      ## 대기
    MOVING,    ## 이동 중
    TALKING,   ## 대화 중
    IN_BATTLE  ## 전투 중
}
```

### Direction (enum)
```gdscript
enum Direction {
    DOWN,      ## 아래 (0)
    LEFT,      ## 왼쪽 (1)
    RIGHT,     ## 오른쪽 (2)
    UP         ## 위 (3)
}
```

### TileCoord (type alias)
```gdscript
type TileCoord = Vector2i  ## 타일 좌표 (x, y)
```

### ActorData (Resource)
```gdscript
class_name ActorData
extends Resource

## 식별자
@export var id: String = ""

## 표시 이름 번역 키
@export var display_name_key: String = ""

## 역할
@export var role: ActorRole = ActorRole.NONE

## 초기 타일 위치
@export var initial_tile: Vector2i = Vector2i(0, 0)

## 초기 방향
@export var initial_direction: Direction = Direction.DOWN

## 스프라이트 프레임 경로 (선택)
@export var sprite_frames_path: String = ""

## 대화 ID (NPC용)
@export var dialogue_id: String = ""

## 전투 데이터 ID (Enemy용)
@export var battle_data_id: String = ""
```

---

## [Files]

기존 파일을 수정하고 새 파일을 생성합니다.

### 새 파일 생성

| 파일 경로 | 목적 |
|----------|------|
| `scripts/entities/actor_data.gd` | Actor 데이터 리소스 클래스 |
| `scripts/entities/actor_controller.gd` | 타일 기반 이동 컨트롤러 (선택적 분리) |

### 기존 파일 수정

| 파일 경로 | 수정 내용 |
|----------|----------|
| `scenes/entities/actor.gd` | 전면 재작성: Role/State 기반 통합 Actor |
| `scenes/entities/actor.tscn` | 구조 유지, 스크립트만 교체 |
| `scripts/ui/explore_screen.gd` | Actor 생성 및 맵 로드 로직 추가 |
| `scenes/dev/part_1.gd` | DNA 로드 후 ExploreScreen에서 Actor 초기화 |

### 삭제/통합 파일

| 파일 경로 | 처리 방식 |
|----------|----------|
| `scripts/entities/character.gd` | 삭제 (Actor로 통합) |
| `scripts/entities/battle_character.gd` | 삭제 (Actor로 통합) |

---

## [Functions]

### 새 함수

| 함수명 | 시그니처 | 파일 경로 | 목적 |
|--------|----------|----------|------|
| `init_actor` | `func init_actor(data: ActorData) -> void` | `actor.gd` | Actor 초기화 |
| `set_role` | `func set_role(new_role: ActorRole) -> void` | `actor.gd` | 역할 변경 |
| `move_to_tile` | `func move_to_tile(target_tile: Vector2i) -> void` | `actor.gd` | 타일 좌표로 이동 |
| `get_current_tile` | `func get_current_tile() -> Vector2i` | `actor.gd` | 현재 타일 좌표 반환 |
| `set_direction` | `func set_direction(dir: Direction) -> void` | `actor.gd` | 방향 설정 (애니메이션 동기화) |
| `_process_movement` | `func _process_movement(delta: float) -> void` | `actor.gd` | 이동 보간 처리 |
| `_update_animation` | `func _update_animation() -> void` | `actor.gd` | 상태/방향에 따른 애니메이션 업데이트 |
| `_spawn_player` | `func _spawn_player(rna: Dictionary) -> void` | `explore_screen.gd` | RNA 기반 플레이어 생성 |
| `_spawn_npcs` | `func _spawn_npcs(location_id: String) -> void` | `explore_screen.gd` | 위치별 NPC 생성 |

### 수정 함수

| 함수명 | 파일 경로 | 수정 내용 |
|--------|----------|----------|
| `setup` | `explore_screen.gd` | 맵 로드, 플레이어/NPC 스폰 추가 |
| `_create_ui` | `explore_screen.gd` | Actor 레이어 추가 |

---

## [Classes]

### Actor (수정)

```gdscript
class_name Actor
extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# Actor - 통합 캐릭터 클래스
# Player, NPC, Enemy 모두 이 클래스를 사용
# 타일 기반 이동, 방향 애니메이션, 역할별 동작 처리
# ═══════════════════════════════════════════════════════════════════════════════

## 시그널
signal clicked(actor: Actor)
signal movement_finished()

## Enum
enum ActorRole { NONE, PLAYER, NPC, ENEMY }
enum ActorState { IDLE, MOVING, TALKING, IN_BATTLE }
enum Direction { DOWN, LEFT, RIGHT, UP }

## 데이터
var _data: ActorData = null
var _role: ActorRole = ActorRole.NONE
var _state: ActorState = ActorState.IDLE
var _direction: Direction = Direction.DOWN

## 타일 위치
var _current_tile: Vector2i = Vector2i(0, 0)
var _target_tile: Vector2i = Vector2i(0, 0)

## 이동 설정
const TILE_SIZE := 16  # 타일 크기 (픽셀)
const MOVE_SPEED := 4.0  # 타일/초

## 컴포넌트
var _animated_sprite: AnimatedSprite2D = null
var _click_area: Area2D = null

## 전투 데이터 (전투 시에만 사용)
var _battle_hp: int = 0
var _battle_max_hp: int = 0
var _battle_mp: int = 0
var _battle_max_mp: int = 0
```

### ActorData (새로 생성)

```gdscript
class_name ActorData
extends Resource

@export var id: String = ""
@export var display_name_key: String = ""
@export var role: Actor.ActorRole = Actor.ActorRole.NONE
@export var initial_tile: Vector2i = Vector2i(0, 0)
@export var initial_direction: Actor.Direction = Actor.Direction.DOWN
@export var sprite_frames_path: String = ""
@export var dialogue_id: String = ""
@export var battle_data_id: String = ""
```

### 삭제 클래스

| 클래스명 | 파일 경로 | 대체 방안 |
|----------|----------|----------|
| `Character` | `scripts/entities/character.gd` | `Actor`로 통합 |
| `BattleCharacter` | `scripts/entities/battle_character.gd` | `Actor`로 통합 |

---

## [Dependencies]

새로운 외부 의존성은 없습니다. 기존 Godot 내장 클래스만 사용합니다.

### 내부 의존성

- `GameManager` - RNA 데이터, 파티 정보
- `CharacterRegistry` - 캐릭터 데이터 조회 (선택적)
- `NPCRegistry` - NPC 데이터 조회

---

## [Testing]

### 테스트 파일

| 파일 경로 | 목적 |
|----------|------|
| `test/unit/test_actor.gd` | Actor 클래스 단위 테스트 |
| `test/unit/test_actor_movement.gd` | 타일 기반 이동 테스트 |

### 테스트 시나리오

1. **Actor 생성 테스트**
   - 각 Role별 Actor 생성
   - 초기 위치/방향 설정 확인

2. **타일 이동 테스트**
   - `move_to_tile` 호출 시 목표 좌표로 이동
   - 이동 완료 시 `movement_finished` 시그널 발생
   - 이동 중 추가 이동 요청 무시

3. **애니메이션 테스트**
   - 방향 변경 시 올바른 애니메이션 재생
   - 상태 변경 시 애니메이션 업데이트

4. **ExploreScreen 통합 테스트**
   - 맵 로드 후 플레이어 스폰 확인
   - NPC 스폰 확인

---

## [Implementation Order]

1. **ActorData 리소스 클래스 생성**
   - `scripts/entities/actor_data.gd` 생성
   - 기본 속성 정의

2. **Actor 클래스 재작성**
   - `scenes/entities/actor.gd` 전면 수정
   - Role/State enum 정의
   - 타일 기반 이동 구현
   - 방향 애니메이션 시스템

3. **기존 클래스 삭제**
   - `character.gd` 삭제
   - `battle_character.gd` 삭제
   - 참조 업데이트

4. **ExploreScreen 수정**
   - 맵 로드 로직 추가
   - 플레이어 스폰 구현
   - NPC 스폰 구현

5. **테스트 작성**
   - Actor 단위 테스트
   - 이동 테스트

6. **통합 검증**
   - part_1.gd 실행 시 플레이어가 맵에 나타나는지 확인