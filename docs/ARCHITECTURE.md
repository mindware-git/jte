# 동유기 소프트웨어 아키텍처 초안

## 목적

이 문서는 `동유기`를 모바일 2D RPG로 구현하기 전에, 시스템 경계와 책임을 먼저 정리하기 위한 아키텍처 문서다.

지금 단계에서는 `코드 구조`보다 아래 네 가지를 먼저 고정한다.

- 플레이 흐름이 어떤 상태 구조로 흘러가는가
- 저장/로드가 무엇을 저장하고 무엇을 저장하지 않는가
- 애니메이션, 탐험, 전투가 어떻게 이어지는가
- 모바일 터치 UX를 어떤 기본 원칙으로 가져갈 것인가

중요한 전제도 하나 있다.

- 개발 초반에는 씬을 잘게 쪼개지 않는다.
- `main.tscn` 하나와 `main.gd` 중심으로 전체 흐름을 운용한다.
- 전투, 컷신, 탐험, 메뉴는 `별도 파일 구조`보다 `논리 상태`로 먼저 나눈다.
- 프로젝트 마지막 단계에서만, 확정된 부분을 개별 씬으로 분리한다.
- i18n은 별도 커스텀 시스템이 아니라 `Godot 내장 현지화 시스템`을 사용한다.
- 배포 대상은 `Android`와 `iOS`다.

---

## 파일 구조 원칙 (GDScript vs Scene)

### 핵심 원칙

**모든 것은 GDScript로 작성한다.** 씬 파일은 다음 경우에만 사용한다:
1. 스프라이트, Body2D 등 물리/렌더링 리소스
2. 맵 타일 (TileMap)
3. 테스트 씬 (에디터에서 실행용)
4. main.tscn (진입점)

### GDScript vs Scene 분류

| 타입 | 방식 | 예시 |
|------|------|------|
| **화면 컨트롤러** | GDScript `.new()` | LocationScreen, BattleScreen, DialoguePanel |
| **데이터 클래스** | GDScript | CharacterData, SkillData, ItemData |
| **매니저** | GDScript | GameManager, EnemyAI |
| **레지스트리** | GDScript | SkillRegistry, ItemRegistry |
| **캐릭터 리소스** | Scene `.instantiate()` | Actor (CharacterBody2D + AnimatedSprite2D) |
| **맵 리소스** | Scene `.instantiate()` | locations/*.tscn (TileMap) |
| **진입점** | Scene | main.tscn, part_1.tscn |
| **테스트** | Scene | dev/*.tscn |

### 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GDScript (모든 로직)                               │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         진입점 (Scene)                               │    │
│  │  main.tscn ── main.gd                                                │    │
│  │  part_1.tscn ── part_1.gd                                            │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│                                    ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      화면 컨트롤러 (GDScript)                         │    │
│  │                                                                      │    │
│  │  LocationScreen.new(id) ── BattleScreen.new()                        │    │
│  │         │                       │                                    │    │
│  │         │                       ▼                                    │    │
│  │         │              Actor.tscn.instantiate()                      │    │
│  │         │              locations/*.tscn.instantiate()                │    │
│  │         │                                                            │    │
│  └─────────┼────────────────────────────────────────────────────────────┘    │
│            │                                                                 │
│            ▼                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         데이터/매니저 (GDScript)                      │    │
│  │                                                                      │    │
│  │  CharacterData, SkillData, ItemData                                  │    │
│  │  GameManager, EnemyAI                                                │    │
│  │  SkillRegistry, ItemRegistry, LocationRegistry                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                         Scene (리소스만)                                     │
│                                                                              │
│  scenes/entities/actor.tscn        ← CharacterBody2D + AnimatedSprite2D     │
│  scenes/locations/*.tscn           ← TileMap (맵 타일)                      │
│  scenes/prd/main.tscn              ← 진입점                                 │
│  scenes/dev/*.tscn                 ← 테스트 씬                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 전환 흐름 상세

#### 1. A맵 → B맵 이동
```
LocationScreen.new("bluewood_village")
    │
    ├── Actor.tscn instantiate()
    ├── locations/bluewood_village.tscn instantiate()
    │
    ▼
이동 버튼 클릭
    │
    ▼
transition_requested.emit(LocationScreen.new("forest_entrance"))
    │
    ▼
part_1.gd: _on_transition()
    │
    ▼
LocationScreen.new("forest_entrance")
    │
    ├── Actor.tscn instantiate()
    └── locations/forest_entrance.tscn instantiate()
```

#### 2. A맵 → 전투 → A맵
```
LocationScreen.new("bluewood_village")
    │
    ▼
전투 상호작용 클릭
    │
    ▼
_on_battle_interaction()
    │
    ▼
transition_requested.emit(Battle.instantiate())
    │
    ▼
part_1.gd: _on_transition()
    │
    ▼
Battle.tscn 실행
    │
    ▼
battle_finished.emit(victory)
    │
    ▼
_on_battle_finished()
    │
    ▼
transition_requested.emit(LocationScreen.new("bluewood_village"))
```

#### 3. A맵 → 애니메이션 → A맵
```
LocationScreen.new("bluewood_village")
    │
    ▼
스토리 상호작용 클릭
    │
    ▼
_on_story_interaction()
    │
    ▼
transition_requested.emit(AnimationScreen.new("cutscene_01"))
    │
    ▼
part_1.gd: _on_transition()
    │
    ▼
AnimationScreen
    │
    ├── animation/cutscene_01.tscn instantiate()
    │
    ▼
animation_finished.emit()
    │
    ▼
transition_requested.emit(LocationScreen.new("bluewood_village"))
```

### 전환 타입 요약

| 전환 | 로직 (GDScript) | 콘텐츠 (Scene) |
|------|-----------------|----------------|
| 맵 이동 | LocationScreen.new(id) | locations/{id}.tscn, Actor.tscn |
| 전투 | BattleScreen.new() | locations/{id}.tscn (배경) |
| 애니메이션 | AnimationScreen.new(id) | - |
| 대화 | DialoguePanel.new(id) | - (오버레이) |
| 상점 | ShopPanel.new(id) | - (오버레이) |

---

## 설계 원칙

- `콘텐츠`와 `런타임 로직`은 분리한다.
- `화면 단위 책임`은 분리하되, 초반에는 실제 Godot 씬 분할보다 `상태 분리`를 우선한다.
- 진행 상태의 진실은 별도 게임 상태 계층이 가진다.
- 저장 데이터는 `현재 노드 상태 전체`가 아니라 `복원 가능한 게임 상태`만 담는다.
- 스토리 연출은 하드코딩보다 `이벤트 명령 시퀀스`로 다룬다.
- 모바일 UX는 `터치 전용`, `짧은 세션`, `가독성`, `실수 복구`를 우선한다.
- 언어별 차이는 텍스트 리소스로 분리하고, 게임 로직은 언어에 의존하지 않게 한다.
- 환상서유기식 재미인 `탐색`, `반복 대화`, `숨은 상자`, `퍼즐`, `꽁트 컷신`이 시스템적으로 잘 버티는 구조여야 한다.

---

## 구현 전략 전제

이 문서에서 말하는 `Scene`은 당장 `.tscn` 파일을 많이 만든다는 뜻이 아니다.

초기 개발 기준:

- 실제 파일은 `main.tscn` 하나
- 실제 진입 로직은 `main.gd` 하나
- 탐험, 전투, 컷신, 메뉴는 `main.gd` 안의 상태와 하위 컨트롤러 개념으로 운용

즉, 지금 필요한 것은 `파일 분해 아키텍처`보다 `상태 기반 아키텍처`다.

권장 흐름:

1. `main.gd` 안에서 게임 루프와 상태 전환을 먼저 고정
2. 데이터와 이벤트 포맷을 먼저 안정화
3. 반복 사용되는 UI/연출/맵 조각만 나중에 씬으로 추출

이 방식은 AI가 코드 문맥을 한곳에서 읽고 수정하기 쉽다는 장점이 있다.

---

## 최상위 구조

게임은 크게 6개 계층으로 본다.

1. `Application Layer`
2. `Flow Layer`
3. `Game State Layer`
4. `Content Data Layer`
5. `Presentation Layer`
6. `Platform Layer`

### 1. Application Layer

앱 부팅, 초기 설정, 리소스 준비, 저장 슬롯 확인, 첫 진입 경로 결정만 담당한다.

핵심 책임:

- 게임 시작
- 기본 설정 로드
- 마지막 중단 지점 확인
- 타이틀 또는 이어하기 진입

### 2. Flow Layer

어떤 씬으로 이동하는지, 어떤 모드를 겹쳐 띄우는지 관리한다.

핵심 책임:

- 타이틀 -> 탐험
- 탐험 -> 전투
- 탐험 -> 컷신
- 컷신 종료 -> 탐험 복귀
- 탐험/전투 -> 저장 메뉴
- 스토리 분기 후 파티 분리/합류

### 3. Game State Layer

플레이 진행의 진실이 있는 곳이다. 씬을 갈아끼워도 유지되어야 하는 정보는 전부 여기로 모은다.

핵심 책임:

- 현재 챕터와 파트 진행도
- 파티 구성
- 보유 아이템/장비/스킬
- 퀘스트 상태
- 플래그와 퍼즐 해금 여부
- 맵별 상자 개봉 여부
- NPC 대화 단계
- 파티 분리 상태

### 4. Content Data Layer

스토리 문서와 데이터 문서를 실제 게임 콘텐츠 단위로 정리한 계층이다.

핵심 책임:

- 아이템 정의
- 스킬 정의
- 몬스터 정의
- 상자 정의
- 맵 정의
- 전투 정의
- 컷신 정의
- 퀘스트 정의

### 5. Presentation Layer

탐험 화면, 전투 화면, UI, 애니메이션, 카메라, 이펙트처럼 플레이어가 직접 보는 부분이다.

핵심 책임:

- 탐험 HUD
- 대화 UI
- 전투 UI
- 메뉴 UI
- 전투 애니메이션
- 필드 상호작용 피드백

### 6. Platform Layer

모바일 기기 특성에 맞는 입력, 저장 시점, 앱 중단/복귀 대응을 다룬다.

핵심 책임:

- 터치 입력
- 해상도 적응
- 안전 영역
- 앱 백그라운드 진입 시 임시 저장
- 저사양 연출 옵션
- Android/iOS별 수명주기 대응
- 언어 설정 반영


---

## Screen 타입 분류

화면 전체가 전환되는 단위를 Screen이라고 한다.

### Screen 목록 (7개)

| Screen | 용도 | 전환 시점 |
|--------|------|-----------|
| **BootScreen** | 초기화/로딩 | 게임 시작 |
| **TitleScreen** | 타이틀/메뉴 | Boot 완료 후 |
| **SelectScreen** | 월드맵 이동, 시나리오 분기 | 이동/분기 시 |
| **AnimationScreen** | 컷신/연출 | 스토리 진행 |
| **ExploreScreen** | 탐험 | 메인 게임플레이 |
| **BattleScreen** | 전투 | 전투 진입 시 |
| **EndingScreen** | 엔딩/크레딧 | 게임 클리어 |

### 게임 흐름

```
BootScreen → TitleScreen → SelectScreen → AnimationScreen → ExploreScreen
                  ↑              │                              │
                  │              └──────────────────────────────┘
                  │                                             │
                  │              ┌──────────────────────────────┘
                  │              ↓
                  └────── EndingScreen ← AnimationScreen
                              
                              ┌──────────────────────────────┐
                              │                              │
                         ExploreScreen ←──────────→ BattleScreen
                              │                              │
                              └──────────────────────────────┘
```

### Screen 전환 매커니즘 (SOLID 기반)

**핵심 원칙: 화면 간 서로 몰라야 한다.**

- main.gd만 화면 전환 책임
- 각 Screen은 RNA만 수정하고 `finished` 신호
- main은 RNA를 보고 적절한 Screen 생성

#### GameManager vs SaveManager 책임 분리

```
┌─────────────────────────────────────────────────────────────┐
│                     GameManager (AutoLoad)                  │
│                                                             │
│  책임: RNA 자료 구조 보관 및 관리                            │
│                                                             │
│  - current_screen: String = "title"  # 현재 화면            │
│  - current_location, enemy_id, cutscene_id                  │
│  - from_battle, victory                                     │
│  - party_members, coin, flags                               │
│                                                             │
│  메서드:                                                     │
│  - to_rna() -> Dictionary   # RNA 반환                      │
│  - reset_rna()              # RNA 초기화 (새 게임)           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     SaveManager (AutoLoad)                  │
│                                                             │
│  책임: RNA ↔ DNA 변환 및 파일 저장/로드                      │
│                                                             │
│  메서드:                                                     │
│  - save(slot_id)            # RNA → DNA → 파일 저장         │
│  - load(slot_id)            # 파일 → DNA → RNA 복원         │
│  - from_dna(dna)            # DNA → RNA 변환                │
│  - to_dna()                 # RNA → DNA 변환                │
└─────────────────────────────────────────────────────────────┘
```

#### RNA 초기값

```gdscript
# game_manager.gd
var current_screen: String = "title"  # 앱 시작 시 기본값
```

#### 새로 시작하기 vs 이어하기

```
┌─────────────────────────────────────────────────────────────┐
│                      TitleScreen                            │
│                                                             │
│  [새로 시작하기]                                            │
│      │                                                      │
│      ├── GameManager.reset_rna()                            │
│      │   └── current_screen = "animation"                   │
│      │   └── current_location = "opening_location"          │
│      │   └── party_members = ["sanzang"]                    │
│      │   └── coin = 0, flags 초기화                         │
│      │                                                      │
│      └── finished.emit()                                    │
│          → main: _create_screen()                           │
│          → AnimationScreen.new() (오프닝 컷신)               │
│                                                             │
│  [이어하기]                                                  │
│      │                                                      │
│      ├── SaveManager.load(slot_id)                          │
│      │   └── DNA 파일 로드                                  │
│      │   └── GameManager.from_dna(dna)                      │
│      │       └── RNA 복원                                   │
│      │       └── current_screen = "explore" (저장 시점)     │
│      │                                                      │
│      └── finished.emit()                                    │
│          → main: _create_screen()                           │
│          → ExploreScreen.new() (저장 위치)                  │
└─────────────────────────────────────────────────────────────┘
```

#### 새로 시작하기 상세

```gdscript
# TitleScreen
func _on_new_game_pressed() -> void:
    GameManager.reset_rna()
    finished.emit()

# GameManager
func reset_rna() -> void:
    current_screen = "animation"
    current_location = "opening_location"
    cutscene_id = "part_1_opening"
    party_members = ["sanzang"]
    coin = 0
    _flags = {}
    from_battle = false
    victory = false
```

#### 이어하기 상세

```gdscript
# TitleScreen
func _on_continue_pressed(slot_id: int) -> void:
    SaveManager.load(slot_id)
    finished.emit()

# SaveManager
func load(slot_id: int) -> bool:
    var dna := _load_dna_file(slot_id)
    if dna.is_empty():
        return false
    GameManager.from_dna(dna)
    return true

# GameManager
func from_dna(dna: Dictionary) -> void:
    current_screen = dna.get("current_screen", "explore")
    current_location = dna.get("current_location", "bluewood_village")
    # ... 기타 필드 복원
```

#### main.gd 흐름

```gdscript
# main.gd
func _ready() -> void:
    # GameManager는 AutoLoad로 이미 초기화됨
    # RNA 초기값: current_screen = "title"
    _create_screen()

func _create_screen() -> void:
    var screen: BaseScreen
    
    match GameManager.current_screen:
        "title":
            screen = TitleScreen.new()
        "animation":
            screen = AnimationScreen.new()
        "explore":
            screen = ExploreScreen.new()
        "battle":
            screen = BattleScreen.new()
        "select":
            screen = SelectScreen.new()
        "ending":
            screen = EndingScreen.new()
        _:
            push_error("Unknown screen: " + GameManager.current_screen)
            return
    
    screen.setup(GameManager.to_rna())
    screen.finished.connect(_on_screen_finished)
    add_child(screen)

func _on_screen_finished() -> void:
    for child in get_children():
        child.queue_free()
    _create_screen()
```

#### RNA (런타임 상태)

```gdscript
# scripts/res/rna.gd
class_name RNA

var current_screen: String = "explore"  # 현재 화면 타입
var location_id: String = ""             # 현재 위치
var enemy_id: String = ""                # 전투 적 ID
var cutscene_id: String = ""             # 컷신 ID
var from_battle: bool = false            # 전투에서 복귀 여부
var victory: bool = false                # 전투 승리 여부
```

#### Screen 인터페이스

```gdscript
# 모든 Screen의 기본 구조
class_name BaseScreen
extends Control

signal finished()  # 화면 종료 신호

var rna: RNA  # main으로부터 주입

## RNA 기반 초기화
func setup(p_rna: RNA) -> void:
    rna = p_rna
```

#### main.gd (컨트롤러)

```gdscript
# main.gd 또는 part_1.gd
extends Node2D

var rna: RNA

func _ready() -> void:
    # DNA 로드 후 RNA 생성
    rna = GameManager.to_rna()
    _create_screen()

func _create_screen() -> void:
    # RNA 기반 Screen 생성
    var screen: BaseScreen
    
    match rna.current_screen:
        "explore":
            screen = ExploreScreen.new()
        "battle":
            screen = BattleScreen.new()
        "animation":
            screen = AnimationScreen.new()
        _:
            push_error("Unknown screen: " + rna.current_screen)
            return
    
    screen.setup(rna)
    screen.finished.connect(_on_screen_finished)
    add_child(screen)

func _on_screen_finished() -> void:
    # 현재 화면 제거
    for child in get_children():
        child.queue_free()
    
    # RNA 기반 새 화면 생성
    _create_screen()
```

#### Screen 예시 (ExploreScreen)

```gdscript
# ExploreScreen.gd
class_name ExploreScreen
extends BaseScreen

func _on_battle_interaction(enemy_id: String) -> void:
    # RNA 수정
    rna.current_screen = "battle"
    rna.enemy_id = enemy_id
    rna.from_battle = false
    
    # main에게 "나 끝났어" 신호
    finished.emit()

func _on_location_change(location_id: String) -> void:
    rna.current_screen = "explore"
    rna.location_id = location_id
    finished.emit()
```

#### 전환 흐름

```
┌─────────────────────────────────────────────────────────────┐
│                         main.gd                             │
│                                                             │
│  RNA: { current_screen: "explore", location_id: "village" } │
│                           │                                 │
│                           ▼                                 │
│          ┌────────────────────────────────┐                │
│          │       ExploreScreen            │                │
│          │                                │                │
│          │  "전투 진입!"                   │                │
│          │  RNA.current_screen = "battle" │                │
│          │  RNA.enemy_id = "goblin"       │                │
│          │  finished.emit() ──────────────┼──┐             │
│          └────────────────────────────────┘  │             │
│                                              │             │
│  main: _on_screen_finished() ◄───────────────┘             │
│           │                                                 │
│           ▼                                                 │
│  RNA: { current_screen: "battle", enemy_id: "goblin" }      │
│           │                                                 │
│           ▼                                                 │
│          ┌────────────────────────────────┐                │
│          │       BattleScreen             │                │
│          │                                │                │
│          │  "전투 종료!"                   │                │
│          │  RNA.current_screen = "explore"│                │
│          │  RNA.victory = true            │                │
│          │  finished.emit() ──────────────┼──┐             │
│          └────────────────────────────────┘  │             │
│                                              │             │
│  main: _on_screen_finished() ◄───────────────┘             │
│           │                                                 │
│           ▼                                                 │
│  RNA: { current_screen: "explore", victory: true }          │
│           │                                                 │
│           ▼                                                 │
│          ┌────────────────────────────────┐                │
│          │       ExploreScreen            │                │
│          └────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

### Screen 간 전환 매트릭스

| From | To | Trigger | Context |
|------|-----|---------|---------|
| BootScreen | TitleScreen | 로딩 완료 | {} |
| TitleScreen | SelectScreen | 새 게임 | {new_game: true} |
| TitleScreen | ExploreScreen | 이어하기 | DNA에서 로드 |
| SelectScreen | AnimationScreen | 선택 완료 | {cutscene_id} |
| SelectScreen | ExploreScreen | 이동 선택 | {location_id} |
| AnimationScreen | ExploreScreen | 연출 종료 | {location_id} |
| ExploreScreen | BattleScreen | 전투 진입 | {enemy_id, location_id} |
| ExploreScreen | AnimationScreen | 스토리 트리거 | {cutscene_id} |
| ExploreScreen | SelectScreen | 월드맵 열기 | {} |
| BattleScreen | ExploreScreen | 전투 종료 | {victory, location_id} |
| BattleScreen | AnimationScreen | 보스 클리어 | {cutscene_id} |
| EndingScreen | TitleScreen | 종료 | {} |

### 전환 코드 예시

```gdscript
# part_1.gd (컨트롤러)
func _on_transition(next_screen: Node) -> void:
    # 1. 현재 화면 제거
    for child in get_children():
        child.queue_free()
    
    # 2. 시그널 연결
    if next_screen.has_signal("transition_requested"):
        next_screen.transition_requested.connect(_on_transition)
    
    # 3. 새 화면 추가
    add_child(next_screen)


# ExploreScreen → BattleScreen
func _on_battle_interaction(enemy_id: String) -> void:
    var battle := BattleScreen.new()
    battle.setup({
        location_id = location_id,
        enemy_id = enemy_id,
        rna = GameManager.to_rna()
    })
    transition_requested.emit(battle)


# BattleScreen → ExploreScreen
func _on_battle_finished(victory: bool) -> void:
    var explore := ExploreScreen.new()
    explore.setup({
        location_id = _location_id,
        from_battle = true,
        victory = victory
    })
    transition_requested.emit(explore)
```

### Screen 상세

#### 1. BootScreen
- 초기화, 리소스 로딩
- 저장 데이터 확인
- 자동으로 다음 Screen으로 전환

#### 2. TitleScreen
- 새 게임 / 이어하기
- 설정
- 크레딧

#### 3. SelectScreen
- 월드맵에서 이동 위치 선택
- 시나리오 분기 선택 (한국 팀 / 일본 팀)
- 선택 후 ExploreScreen 또는 AnimationScreen으로 전환

#### 4. AnimationScreen
- 컷신 자동 진행
- 탭으로 빠르게 진행
- 종료 후 ExploreScreen으로 전환

#### 5. ExploreScreen
- 캐릭터 이동, NPC 대화, 상호작용
- 전투 진입 시 BattleScreen으로 전환
- 스토리 트리거 시 AnimationScreen으로 전환

#### 6. BattleScreen
- 턴제 전투
- 전투 종료 후 ExploreScreen으로 복귀
- 보스 클리어 시 AnimationScreen으로 전환 가능

#### 7. EndingScreen
- 엔딩 크레딧
- 타이틀로 복귀

### 오버레이 Panel (화면 전환 없음)

| Panel | 용도 |
|-------|------|
| DialoguePanel | NPC 대화 |
| ShopPanel | 상점 |
| MenuPanel | 인벤토리/설정/파티 |

---

## 논리 화면 아키텍처

여기서 말하는 씬은 `논리적 화면 상태`다.

초기 개발에서는 아래 상태들이 모두 `main.gd` 내부 상태로 존재해도 된다.

역할 기준으로는 아래 6종이면 충분하다.

### 1. Boot State

역할:

- 설정 불러오기
- 저장 데이터 확인
- 필수 리소스 워밍업
- 타이틀 또는 이어하기 진입

주의:

- 여기서 게임 로직을 돌리지 않는다.
- 오래 머무는 씬이 아니라 진입 분기용 씬이다.

### 2. Title State

역할:

- 새 게임
- 이어하기
- 저장 슬롯 보기
- 옵션
- 크레딧

모바일 고려:

- 첫 화면 버튼 수를 줄인다.
- `이어하기`를 가장 크게 둔다.

### 3. Animation State

스토리 진행용 자동 연출 상태다.

역할:

- 캐릭터 자동 이동
- 카메라 연출
- 말풍선 대사 출력
- 표정/모션 전환
- 간단한 이벤트 실행

입력 원칙:

- 탭으로 다음 진행
- 화면을 누르고 있으면 빠르게 전개
- 완전 스킵보다는 `빠른 재생`에 가깝게 운용

종료 원칙:

- 마지막 장면이 끝나면 바로 Explore로 이어진다.
- 전환 직후부터 플레이어가 직접 움직일 수 있어야 한다.

### 4. Explore State

게임의 기본 상태다. 마을, 필드, 던전, 선박 위 이동, 축제장, 퍼즐 공간이 모두 이 계열에 들어간다.

역할:

- 캐릭터 이동
- NPC 대화
- 상호작용
- 퍼즐 기믹
- 상자 개봉
- 필드 이벤트 발동
- 숨겨진 조사 포인트 처리
- 랜덤 또는 고정 전투 진입

내부 서브 레이어:

- `Map Layer`: 지형, 충돌, 장식
- `Actor Layer`: 플레이어, NPC, 적 심볼
- `Interaction Layer`: 상자, 조사점, 문, 트리거
- `Event Layer`: 컷신 트리거, 스크립트 포인트
- `Field UI Layer`: 미니 HUD, 버튼, 퀘스트 힌트

중요:

- 퍼즐은 Explore에서 분리하지 않는다.
- 캐릭터가 움직이며 푸는 기믹은 전부 Explore의 일부다.
- 등롱 맞추기, 바닥 문양 밟기, 숨은 길 찾기, 조사 순서 맞추기는 모두 탐험 시스템으로 처리한다.

### 5. Battle State

턴제 전투 전용 씬이다.

자세한 구조는 [BATTLE_ARCHITECTURE.md](/Users/kwang/Documents/git-repos/jte/docs/BATTLE_ARCHITECTURE.md)를 기준으로 한다.
동유기 전투는 `환상서유기식 턴제 + 칸 기반 스킬 판정`을 전제로 한다.

역할:

- 아군/적 배치
- 행동 선택
- 대상 칸 선택
- 스킬 실행
- 상태이상 처리
- 전투 결과 계산
- 보상 지급
- 승패 후 복귀 경로 결정

핵심 원칙:

- 전투 계산과 전투 연출은 분리한다.
- 계산이 끝난 뒤 연출이 재생되는 구조가 안정적이다.
- 스킬은 유닛보다 `칸 패턴` 기준으로 설명되고 판정된다.
- 몬스터도 같은 칸 규칙 위에서 공격하고 스킬을 사용한다.

### 6. Overlay UI State

게임 위에 겹쳐지는 메뉴와 팝업 계층이다.

포함:

- 인벤토리
- 장비
- 파티 편성
- 퀘스트 로그
- 세팅
- 설정
- 튜토리얼 카드

원칙:

- 탐험/전투 상태 위에 오버레이로 띄우고, 메인 상태는 유지한다.
- 모바일에서는 화면 전환보다 오버레이가 피로가 적다.
- 저장과 로드는 별도 메인 화면이 아니라 `세팅 안의 기능`으로 둔다.

### 7. Transition State

로딩, 챕터 전환, 바다 건너기, 꿈 연출처럼 짧은 브리지 씬이다.

역할:

- 비동기 로딩 감추기
- 지역 이동 분위기 만들기
- 챕터 카드 연출

---

## 게임 흐름 모델

실행 중 게임은 아래 상태를 오간다.

`Boot -> Title -> Animation -> Explore -> Battle -> Explore`

필요시 아래 상태가 겹친다.

- `Overlay`
- `Loading`
- `Suspend`

핵심은 `Explore`가 중심이라는 점이다.

- Animation은 Explore로 진입시키는 도입부다.
- 마을도 Explore
- 던전도 Explore
- 숨은 상자 찾기도 Explore
- 반복 대화 보상도 Explore
- 퍼즐도 Explore

즉, 동유기의 기본 재미는 `애니메이션으로 상황을 보여주고, 탐험에서 웃기고 찾고 말 걸고, 필요할 때 전투로 들어갔다가 다시 탐험으로 돌아오는 구조`가 되어야 한다.

---

## 게임 상태 아키텍처

저장과 복원이 가능하려면 상태를 세 층으로 나누는 게 안전하다.

### 1. Global Profile State

계정 또는 기기 단위 설정이다.

포함:

- 언어
- 사운드 설정
- 진동
- UI 크기
- 터치 배치
- 접근성 옵션
- 클리어 이력

### 2. Save Slot State

플레이 진행도를 담는 핵심 저장 단위다.

포함:

- 플레이 시간
- 현재 파트
- 현재 맵 ID
- 현재 위치
- 현재 파티
- 파티별 레벨/스탯/장비/스킬 상태
- 인벤토리와 재화
- 퀘스트 상태
- 주요 플래그
- 상자 개봉 정보
- 퍼즐 완료 정보
- 분기 선택 정보
- 현재 탑 진행층
- 재합류 전 팀 분리 상태

### 3. Scene Runtime State

씬 안에서만 유효한 임시 상태다.

예:

- 현재 대사 타이핑 위치
- 애니메이션 자동 이동 진행도
- 적 AI의 이번 턴 임시 판단
- 카메라 흔들림
- 필드 이펙트 재생 중 여부

원칙:

- 이 계층은 저장하지 않는다.
- 저장 시에는 복원 가능한 값으로만 환원한다.

---

## 저장/로드 아키텍처

자세한 저장 구조는 [SAVE_LOAD_ARCHITECTURE.md](/Users/kwang/Documents/git-repos/jte/docs/SAVE_LOAD_ARCHITECTURE.md)를 기준으로 한다.
핵심 원칙만 여기 요약한다.

## 저장 대상

- 현재 선택 언어 또는 시스템 언어 추종 여부
- 현재 챕터/파트
- 맵과 좌표
- 직전 Animation 종료 지점 또는 Explore 진입 지점
- 파티 구성과 분리 상태
- 레벨, 경험치, 능력치
- 장비와 스킬 습득 상태
- 인벤토리
- 퀘스트 진행도
- 대화 플래그
- 상자 개봉 여부
- 퍼즐 해결 여부
- 보스 처치 여부
- 컷신 시청 여부
- 상점 해금 상태

## 저장 비대상

- 현재 프레임의 애니메이션 진행도
- 노드 인스턴스 내부 임시값
- 현재 열려 있는 UI 팝업의 스크롤 위치
- 카메라 이동 보간 상태
- 전투 이펙트 재생 순간값

## 저장 방식 원칙

- `수동 저장`과 `자동 저장`을 분리한다.
- `중단 저장`을 별도로 둔다.
- 저장/로드 진입 위치는 `세팅 메뉴 내부`로 둔다.

추천 슬롯 구조:

- 수동 슬롯 3개
- 자동 저장 1개
- 앱 종료/전화 수신 대응용 중단 저장 1개

버전 원칙:

- 모든 저장 파일은 `save_format_version`을 가진다.
- 저장 호환성 판단은 `app_version`이 아니라 `save_format_version` 기준으로 한다.
- `content_version`은 맵/퀘스트/밸런스 변경 추적용으로 별도 보관한다.

## 자동 저장 시점

- 파트 시작
- Animation 종료 후 Explore 진입 직후
- 파트 종료
- 보스 직전
- 보스 승리 직후
- 지역 이동 직후
- 파티 분리/합류 직후
- 중요한 아이템 획득 직후

## 저장 안전 지점 원칙

- 이동 중 입력을 잠깐 잠근 뒤 저장한다.
- 전투 중에는 일반 저장을 막고, `중단 저장`만 허용한다.
- Animation 도중 저장은 허용하지 않거나, Animation 시작 지점으로 되돌린다.

이 원칙이 필요한 이유는 모바일에서 앱 중단이 잦기 때문이다.
또한 업데이트가 잦은 프로젝트에서 저장 호환성을 관리하려면 `DNA(저장 포맷)`와 `RNA(런타임 상태)`를 분리해야 한다.

---

## 파티 분리/합류 아키텍처

동유기는 중반 이후 `한국 팀`과 `일본 팀` 분기가 중요하므로 일반적인 단일 파티 구조로는 부족하다.

따라서 저장 데이터와 게임 상태는 `활성 파티 1개`만 보지 않고 `복수 파티 컨텍스트`를 가져야 한다.

필수 구조:

- `Roster`: 전체 동료 목록
- `Squad A`: 현재 조작 중인 팀
- `Squad B`: 분리된 반대편 팀
- `Shared Inventory`: 공용 소지품
- `Squad Local Flags`: 팀별 임시 진행 상태

원칙:

- 합류 전까지는 경험치, 장비, 위치를 팀 단위로 추적한다.
- 공용 소지품 여부는 초기에 정해야 한다.

권장안:

- 주요 퀘스트 아이템은 공용
- 소비 아이템과 장비는 팀별 소지 가능

이렇게 해야 `한국 팀에서 얻은 봉래옥패`와 `일본 팀에서 얻은 항로 정보` 같은 서사 자산을 자연스럽게 합칠 수 있다.

---

## 탐험 아키텍처

탐험은 동유기의 본체다. 따라서 던전도 마을도 같은 규칙으로 읽히도록 통일해야 한다.

### 탐험 루프

`이동 -> 조사 -> 대화 -> 발견 -> 전투 또는 퍼즐 -> 보상 -> 다음 단서`

보다 실제 플레이 흐름으로 쓰면 아래와 같다.

`애니메이션 시작 -> 자동 연출 -> 탐험 시작 -> NPC 대화/상자 탐색 -> 전투 진입 -> 전투 종료 -> 탐험 복귀`

### 상호작용 오브젝트 분류

#### Gate (자동 트리거)
- 맵 이동 전용
- 플레이어 접촉 시 자동으로 다음 맵으로 이동
- `body_entered` 시그널 기반
- 파일: `scenes/entities/gate.tscn`, `scenes/entities/gate.gd`

#### Interactable (클릭 기반)
- NPC 대화
- 상자 (아이템 획득)
- 조사 포인트
- 퍼즐 장치
- 스토리 트리거
- 은닉 포인트
- `body_entered` + 클릭 조합
- 파일: `scenes/entities/interactable.tscn`, `scenes/entities/interactable.gd`

#### Gate vs Interactable 분리 이유
| 타입 | 용도 | 감지 방식 | 사용자 입력 |
|------|------|-----------|-------------|
| Gate | 맵 이동 | body_entered 자동 | 불필요 |
| Interactable | 상호작용 | body_entered + 클릭 | 필요 |

**NPC용 Interactable collision 크기**: 192x192 (3 grid 거리에서 대화 가능)

### NPC Registry와 Actor/Interactable 통합

NPC 데이터는 `NPCRegistry`가 관리하고, 시각적 표현은 `Actor`, 상호작용 감지는 `Interactable`이 담당합니다.

```
┌─────────────────────────────────────────────────────────────┐
│                     Location Scene (tscn)                   │
│                                                             │
│  ┌─────────────┐                                            │
│  │   Actor     │  ←── NPC 시각적 표현, 이동                 │
│  │   (NPC)     │      CharacterData 기반 초기화             │
│  └─────────────┘                                            │
│         │                                                   │
│         ▼                                                   │
│  ┌─────────────┐                                            │
│  │Interactable │  ←── 클릭 감지, interacted 신호            │
│  │  (npc 타입) │      interact_data = {npc_id: "..."}      │
│  └─────────────┘                                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      ExploreScreen                          │
│                                                             │
│  1. Location 씬 로드                                        │
│  2. NPC Actor 발견 → Interactable 생성                      │
│  3. Interactable.interacted → NPCRegistry 조회              │
│  4. DialogueData → DialogueUI 표시                          │
└─────────────────────────────────────────────────────────────┘
```

#### NPCRegistry 책임
- NPCData 저장소 (id, display_name_key, portrait, default_dialogue_id)
- 위치별 NPC 목록 조회 (`get_npcs_by_location`)
- RNA 기반 동적 대화 조회 (`get_dialogue`)

#### Actor 책임
- NPC 시각적 표현
- 타일 기반 이동
- 방향 애니메이션

#### Interactable 책임
- 플레이어 진입 감지
- 클릭 이벤트 처리
- `interacted` 신호 발생

#### 데이터 흐름
```
플레이어 클릭
    │
    ▼
Interactable._on_input_event()
    │
    ▼
interacted.emit(self)
    │
    ▼
ExploreScreen._on_interactable_interacted()
    │
    ▼
NPCRegistry.get_dialogue(npc_id, rna)
    │
    ▼
DialogueUI.show(dialogue_data)
```

### 조사 UX 원칙

- 조사 가능한 물체는 거리와 방향 기준으로 판정한다.
- 숨은 오브젝트는 `노출 없이 완전 랜덤`으로 두지 않는다.
- 반드시 하나 이상의 힌트를 둔다.

힌트 예:

- 반복 대화
- 이상한 문장
- 배경 오브젝트의 비정상 배치
- 바닥 문양
- 카메라 끄트머리의 빈 공간

### 퍼즐 아키텍처 원칙

퍼즐은 세 단계로 나눈다.

1. `관찰`
2. `해석`
3. `실행`

좋은 퍼즐 조건:

- 해답 전에 단서가 보인다
- 실패해도 손해가 과하지 않다
- 성공하면 서사 또는 보상과 연결된다
- 동료의 성격이 대사로 끼어든다

즉, 퍼즐도 시스템만 있으면 안 되고 `꽁트 대사`와 함께 굴러야 한다.
그리고 별도 미니게임보다 `이동과 조사의 확장`으로 설계하는 편이 동유기와 더 잘 맞는다.

---

## 전투 아키텍처

자세한 내용은 [BATTLE_ARCHITECTURE.md](/Users/kwang/Documents/git-repos/jte/docs/BATTLE_ARCHITECTURE.md)를 기준으로 한다.
여기서는 상위 원칙만 요약한다.

전투는 별도 씬이지만, 탐험과 서사가 끊기지 않게 연결되어야 한다.

### 전투의 세 층

1. `Battle Rule Layer`
2. `Battle Presentation Layer`
3. `Battle Result Layer`

### 1. Battle Rule Layer

역할:

- 턴 순서
- 칸 기반 대상 판정
- 데미지 계산
- 버프/디버프
- 상태이상
- 승패 판정

### 2. Battle Presentation Layer

역할:

- 공격 모션
- 스킬 컷인
- 카메라 이동
- 피격 반응
- 숫자 표시
- 화면 흔들림
- 속성 이펙트

중요 원칙:

- 연출은 교체 가능해야 한다.
- 같은 스킬이라도 약식 연출과 강화 연출을 분리할 수 있어야 한다.
- 저사양 모바일에서는 컷인을 생략할 수 있어야 한다.
- 어느 칸이 영향을 받는지 즉시 읽혀야 한다.

### 3. Battle Result Layer

역할:

- 경험치
- 전리품
- 퀘스트 갱신
- 컷신 분기
- 탐험 복귀 위치 결정

### 전투 애니메이션 씬 구조

사용자 요청의 `전투씬`, `애니메이션 씬`은 완전히 따로 놀기보다 아래처럼 잡는 게 낫다.

- `Battle Scene`: 규칙과 UI의 본체
- `Battle Animation Layer`: 스킬 연출 전용 무대

이렇게 하면 계산은 안정적으로 유지하고, 연출은 나중에 보강하기 쉽다.

### 전투 시작/종료 규칙

- 심볼 접촉
- 스토리 강제 전투
- 조사형 함정 전투
- 퍼즐 실패 전투

종료 후:

- 원래 Explore 상태로 복귀
- 보스라면 다음 Animation 상태로 연결 가능
- 패배라면 최근 안전 지점 또는 이벤트 분기 처리

---

## 애니메이션 및 이벤트 아키텍처

동유기는 파트별 개그 연출과 지역 이벤트가 많기 때문에, Animation은 `명령 기반 시퀀스`로 설계하는 게 맞다.

추천 명령 단위:

- 대사 출력
- 초상/감정 변경
- 캐릭터 이동
- 방향 전환
- 표정/이모트
- 카메라 이동
- 화면 흔들기
- 사운드 재생
- 아이템 지급
- 플래그 설정
- 파티 변경
- 전투 시작
- 애니메이션 종료 후 탐험 제어권 반환

이 구조가 필요한 이유:

- `같은 시스템`으로 정극과 꽁트를 모두 처리할 수 있다.
- 대사만 바꾸면 유사한 이벤트를 재사용할 수 있다.
- 스토리 문서와 매핑하기 쉽다.

핵심 UX:

- 플레이어는 Animation에서 조작권이 없다.
- 대신 `누르고 있으면 빨라진다`는 약속이 명확해야 한다.
- 마지막 장면이 끝나면 지체 없이 Explore 조작으로 넘어가야 한다.

---

## UI/UX 아키텍처

모바일 2D RPG의 UI는 `항상 보이는 HUD`, `상황형 버튼`, `오버레이 메뉴`로 나눈다.

### 1. 항상 보이는 HUD

탐험 기준:

- 이동 입력
- 상호작용 버튼
- 메뉴 버튼
- 현재 목적지 힌트
- 미니 상태 표시

전투 기준:

- 행동 버튼
- 대상 선택
- 상태 아이콘
- 턴 정보

### 2. 상황형 버튼

예:

- 조사
- 밀기
- 당기기
- 읽기
- 타기
- 잠수
- 대화

원칙:

- 버튼은 상황에 따라 하나만 크게 보여준다.
- 모바일에서는 고정 버튼이 많을수록 오조작이 늘어난다.

### 3. 오버레이 메뉴

포함:

- 인벤토리
- 장비
- 스킬
- 파티
- 퀘스트
- 세팅

세팅 내부:

- 저장
- 로드
- 사운드
- 진동
- 텍스트 속도
- 연출 속도

원칙:

- 전면 교체보다 시트형 또는 패널형이 빠르다.
- 닫았다가 다시 열었을 때 마지막 탭을 유지한다.

---

## 모바일 입력 아키텍처

기본 입력은 `터치 전용`이다.

가상 조이스틱은 사용하지 않는다.
입력은 `탭`, `길게 누르기`, `드래그`, `영역 선택` 중심으로 설계한다.

### 탐험 입력

- 이동하고 싶은 지점을 탭하면 캐릭터가 그 지점으로 이동
- 드래그하면 연속 이동 방향을 갱신
- NPC나 상자, 조사 포인트를 직접 탭하면 해당 대상으로 접근 후 상호작용
- 빈 공간 탭은 이동
- 우상단 또는 고정 코너 버튼으로 메뉴 진입

### 대화 입력

- 탭으로 다음
- 길게 눌러 빠르게 넘기기
- 자동 진행 토글

### 애니메이션 입력

- 기본은 자동 진행
- 화면을 누르고 있으면 빠른 진행
- 대사 박스와 말풍선 모두 같은 규칙 적용

### 전투 입력

- 큰 행동 버튼 4개 이내
- 추가 행동은 확장 패널
- 타겟 선택은 탭
- 스킬 설명은 길게 누르기

### 터치 UX 원칙

- 플레이어가 `이동`과 `상호작용`을 따로 배우지 않아도 되게 한다.
- 닿을 수 있는 오브젝트를 탭하면 `자동 접근 후 실행`이 기본이다.
- 작은 오브젝트는 터치 범위를 실제 그래픽보다 넓게 둔다.
- 숨은 요소는 완전 픽셀 헌팅이 아니라, 의심 지점을 누르게 만드는 단서를 준다.
- 긴 던전에서는 손가락을 많이 움직이지 않도록 목적지 보정과 경로 보정을 둔다.

### 접근성 고려

- 버튼 위치 좌우 반전
- UI 크기 조절
- 진동 끄기
- 화면 흔들림 감소
- 컷신 자동 넘김 속도 조절

---

## 국제화 아키텍처

국제화는 `Godot i18n 시스템`을 그대로 사용한다.

지원 언어:

- 한국어
- 중국어
- 일본어
- 영어

원칙:

- 코드와 데이터는 `언어 중립 키`를 사용한다.
- 실제 노출 문구만 번역 리소스에서 가져온다.
- 퀘스트 이름, 아이템 이름, 스킬 이름, 시스템 문구, 튜토리얼, 말풍선, UI 라벨을 모두 같은 체계로 관리한다.

### 언어 적용 원칙

- 첫 실행 시 기기 언어를 우선 참고한다.
- 지원 언어가 아니면 영어를 기본값으로 둔다.
- 세팅에서 언제든 수동 변경 가능해야 한다.
- 언어 변경 즉시 UI와 대사가 반영되어야 한다.

### 번역 키 설계 원칙

- `part_01.cutscene.opening.samjang_001`
- `item.bongrae_jade_token.name`
- `item.bongrae_jade_token.desc`
- `skill.goku_staff_storm.name`
- `ui.settings.save`

이런 식으로 `콘텐츠 종류 + 식별자 + 필드` 형태가 안전하다.

### 언어별 주의점

- 한국어/중국어/일본어는 텍스트 길이가 짧아도 정보량이 높다.
- 영어는 같은 의미라도 길어질 수 있으니 버튼 폭과 말풍선 폭이 더 여유 있어야 한다.
- 일본어와 중국어는 줄바꿈 규칙과 문장부호 간격이 한국어/영어와 다르므로 자동 줄바꿈 결과를 직접 확인해야 한다.

### 스토리 텍스트 운영 원칙

- 말맛이 중요한 꽁트 대사는 직역보다 `언어별 자연스러운 농담`으로 다듬는 여지를 둔다.
- 하지만 퍼즐 단서 문구는 의미가 흔들리면 안 되므로, 번역 검수 우선순위를 높인다.
- 말풍선 길이가 너무 길어지면 자동 분할보다 원문 자체를 짧게 재작성하는 편이 안전하다.

---

## 플랫폼 아키텍처

배포 대상은 `Android`와 `iOS`다.

### 공통 원칙

- 터치만으로 모든 주요 기능을 수행할 수 있어야 한다.
- 앱 중단 후 복귀 시 진행 손실이 최소화되어야 한다.
- 저사양 기기에서도 탐험과 UI는 안정적으로 유지되어야 한다.

### Android 고려 사항

- 백그라운드 진입 빈도가 높으므로 중단 저장이 중요하다.
- 기기 해상도와 화면 비율 편차가 크므로 HUD와 말풍선 안전 영역 검증이 중요하다.

### iOS 고려 사항

- 안전 영역 대응을 명확히 해야 한다.
- 제스처 충돌을 줄이기 위해 가장자리 버튼 배치를 조심해야 한다.

### 공통 UI 검증 포인트

- 16:9뿐 아니라 더 긴 세로 비율에서도 UI가 깨지지 않는가
- 말풍선과 버튼이 노치, 홈 인디케이터와 겹치지 않는가
- 언어별 텍스트 길이가 늘어나도 버튼이 버티는가
- 앱 중단 후 복귀 시 Animation, Explore, Battle 중 어디로 돌아갈지 일관적인가

---

## 데이터 아키텍처

현재는 `docs/story`와 `docs/data`가 기획 원본이다.
이후 실제 게임 데이터는 아래 단위로 정리하는 것이 좋다.

### 핵심 데이터 단위

- `Chapter Definition`
- `Map Definition`
- `Quest Definition`
- `Cutscene Definition`
- `Battle Definition`
- `Monster Definition`
- `Item Definition`
- `Skill Definition`
- `Box Definition`
- `Localization Table`

### 권장 데이터 흐름

1. 스토리 문서에서 파트 목표와 이벤트 추출
2. 데이터 문서에서 아이템/스킬/몬스터 명세 정리
3. 맵 정의에 NPC, 상자, 트리거, 출구 배치
4. 컷신 정의에 이벤트 명령 시퀀스 작성
5. 퀘스트 정의에 조건과 보상 연결
6. 모든 노출 문자열을 번역 키에 연결

핵심은 `문서가 곧 데이터가 되도록` 중간 계층을 얇게 유지하는 것이다.

---

## GDScript 중심 운영 구조

사용자 전제대로, 프로젝트는 초반에 `gd 중심`으로 운용한다.

즉, 아키텍처의 핵심은 `씬 파일 개수`가 아니라 `main.gd 안의 책임 분리`다.

권장 논리 분해:

- `App State`: 부팅, 타이틀, 이어하기 판단
- `Flow State`: 현재 모드가 애니메이션인지 탐험인지 전투인지
- `World State`: 맵, NPC, 상자, 플래그
- `Party State`: 파티, 능력치, 인벤토리
- `Battle State`: 턴, 행동, 결과
- `UI State`: 어떤 패널이 열려 있는지
- `Input State`: 현재 터치가 이동인지 UI 조작인지
- `Animation State`: 자동 이동, 말풍선, 연출 단계

중요한 점:

- 이 분해는 처음엔 같은 파일 안에 있어도 된다.
- 대신 변수와 함수의 책임은 명확히 갈라야 한다.
- 나중에 안정된 부분만 별도 `.gd`나 `.tscn`으로 추출한다.

---

## 추천 콘텐츠 단위 매핑

동유기 문서 구조를 소프트웨어 단위로 옮기면 아래처럼 된다.

- `docs/story/changed/part-01.md` ~ `part-16.md`
  - 챕터/파트 정의의 기준
- `docs/data/DONGYUGI_ITEM_PLAN.md`
  - 아이템 리네이밍 및 계열 기준
- `docs/data/DONGYUGI_SKILL_PLAN.md`
  - 스킬 역할과 연출 톤 기준
- `docs/data/DONGYUGI_MONSTER_PLAN.md`
  - 파트별 적 생태와 보스 기준
- `docs/data/DONGYUGI_BOX_PLAN.md`
  - 탐색 보상과 은닉 패턴 기준

국제화 기준:

- 스토리 문서의 고유명사도 최종적으로는 번역 키로 관리
- 데이터 문서의 아이템/스킬/몬스터 명칭도 표시 이름과 내부 ID를 분리

즉, 스토리와 시스템은 따로 설계하는 것이 아니라 `파트 단위 경험`으로 묶여야 한다.

---

## 성능과 운영 원칙

모바일 환경에서는 아래 원칙이 중요하다.

- 맵 전환은 짧고 예측 가능해야 한다.
- 전투 연출은 스킵 가능해야 한다.
- 긴 던전은 중간 정비 지점을 둔다.
- 텍스트는 짧은 세션에서도 다시 따라가기 쉬워야 한다.
- 자동 저장은 자주 하되 체감되지 않게 해야 한다.

특히 동유기는 탐색과 대사가 많으므로 아래 기능이 중요하다.

- 직전 대화 다시 보기
- 최근 퀘스트 목표 다시 보기
- 획득 아이템 로그
- 최근 저장 시점 표시
- 언어 변경 후 즉시 반영

---

## 구현 우선순위 제안

코드를 지금 짜지는 않더라도, 실제 제작 순서는 아래가 안정적이다.

1. `main.gd` 안의 `Flow + Save/Load` 뼈대 확정
2. `Explore` 기본 루프 구축
3. `상호작용/상자/대화/플래그` 구축
4. `Battle` 규칙 계층 구축
5. `Battle Animation Layer` 추가
6. `Animation/Event` 시퀀스 구축
7. `파티 분리/합류` 구축
8. `모바일 UI 최적화` 반복
9. 마지막 단계에서만 안정된 기능을 씬/모듈로 분리
10. Android/iOS 실기기에서 언어별 UI 검증

이 순서가 좋은 이유는 `동유기의 핵심 재미가 탐험과 이벤트`이기 때문이다.
전투 연출을 먼저 화려하게 만드는 것보다, 파트 1 하나를 처음부터 끝까지 플레이 가능한 구조로 만드는 쪽이 훨씬 검증력이 높다.

---

## 핵심 결론

동유기의 아키텍처는 `main.gd 중심 상태 머신 위에 애니메이션, 탐험, 전투가 얹히는 구조`로 잡는 것이 맞다.

중요한 결정은 다섯 가지다.

- 씬의 진실이 아니라 `게임 상태`가 진실이어야 한다.
- 저장은 `노드 전체`가 아니라 `복원 가능한 진행 상태`를 담아야 한다.
- 전투는 `규칙`과 `연출`을 분리해야 한다.
- 파티 분리/합류를 처음부터 상태 모델에 넣어야 한다.
- 퍼즐은 별도 모드보다 `탐험의 일부`로 설계해야 한다.
- 애니메이션은 `자동 진행 + 누르고 있으면 가속 + 끝나면 즉시 탐험 전환` 규칙을 가져야 한다.
- 모바일 UX는 `터치 직접 조작`, `자동 접근 상호작용`, `자주 이어하기`를 기준으로 설계해야 한다.
- 국제화는 처음부터 `Godot i18n + 언어 중립 키` 기준으로 가야 한다.

이 기준만 지키면, 이후 스토리와 데이터가 더 바뀌더라도 구조는 쉽게 버틴다.
