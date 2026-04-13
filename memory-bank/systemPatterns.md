# System Patterns - 동유기 (JTE)

## 시스템 아키텍처

### 6계층 구조

```
┌─────────────────────────────────────────┐
│         Application Layer               │  부팅, 설정, 진입 분기
├─────────────────────────────────────────┤
│           Flow Layer                    │  화면 전환, 모드 관리
├─────────────────────────────────────────┤
│        Game State Layer                 │  진행 상태, 파티, 인벤토리
├─────────────────────────────────────────┤
│       Content Data Layer                │  스킬, 아이템, 몬스터 정의
├─────────────────────────────────────────┤
│        Presentation Layer               │  UI, 애니메이션, 이펙트
├─────────────────────────────────────────┤
│          Platform Layer                 │  입력, 저장, 언어
└─────────────────────────────────────────┘
```

### main.gd 중심 구조

초기 개발에서는 `main.gd`가 모든 상태를 관리합니다:

```gdscript
# 논리 상태 (동일 파일 내 분리)
- Flow State: 현재 모드 (boot, title, animation, explore, battle)
- World State: 맵, NPC, 상자, 플래그
- Party State: 파티, 능력치, 인벤토리
- Battle State: 턴, 행동, 결과
- UI State: 열린 패널
- Input State: 터치 상태
- Animation State: 연출 단계
```

## 핵심 디자인 패턴

### 1. 상태 머신 패턴

게임 흐름을 상태로 관리:

```
Boot → Title → Animation → Explore ⇄ Battle
                      ↓
                  Overlay UI
```

### 2. 레지스트리 패턴

모든 데이터는 레지스트리에서 관리:

```gdscript
# 스킬 레지스트리 예시
class SkillRegistry:
    var _skills: Dictionary  # {skill_id: SkillData}
    
    func get_skill(id: String) -> SkillData
    func get_all_skills() -> Array[SkillData]
```

**장점**:
- 데이터와 로직 분리
- 아군/적 동일 방식 사용
- 확장 용이

### 3. 전략 패턴 (AI)

적 AI는 전략과 행동을 분리:

```
EnemyAI
├── 전략 (Strategy)
│   ├── AGGRESSIVE   # 공격적
│   ├── DEFENSIVE    # 방어적
│   └── BALANCED     # 균형
│
└── 행동 (Action)
    ├── MOVE
    ├── ATTACK
    └── SKILL
```

### 4. DNA/RNA 패턴 (저장)

저장 데이터와 런타임 상태 분리:

```
DNA (저장용)          RNA (런타임)
├── meta              ├── Flow RNA
├── progress          ├── Animation RNA
├── world             ├── Explore RNA
├── party             ├── Battle RNA
├── inventory         ├── UI RNA
├── quests            └── Domain RNA
├── flags
└── system
```

## 컴포넌트 관계

### 캐릭터 상속 구조

```
RefCounted
├── CharacterData     # 캐릭터 정의 데이터
├── SkillData         # 스킬 데이터
├── ItemData          # 아이템 데이터
└── BattleData
    ├── Unit          # 전투 유닛 (아군/적 공통)
    ├── BattleCell    # 전장 칸
    └── BattleAction  # 행동 데이터

Node2D
├── Character         # 기본 캐릭터 (탐험/전투 공통)
└── TacticGrid        # 그리드 시스템
```

### 화면 전환 흐름

```
main.gd
    │
    ├── TitleScreen
    │       ↓
    ├── StoryScreen (컷신 시퀀스)
    │       ↓
    ├── ExploreScreen ←→ BattleScreen
    │       ↓
    ├── LocationScreen → LocationScreen (위치 이동)
    │       ↓
    └── DialoguePanel / ShopPanel (오버레이)
```

### 5. 컷신 명령 시퀀스 패턴

컷신은 명령 배열을 async 루프로 순차 실행:

```gdscript
# CutsceneCommand
enum CommandType { SPAWN, MOVE, DIALOGUE, WAIT, ANIMATE, CAMERA, DESPAWN, SET_FLAG, FADE, SE }

# CutsceneData
var commands: Array[CutsceneCommand]

# StoryScreen
func _execute_next_command() -> void:
    var cmd := _cutscene.commands[_command_index]
    _command_index += 1
    match cmd.type:
        SPAWN: _cmd_spawn(cmd)     # 즉시 → _execute_next_command()
        MOVE: _cmd_move(cmd)       # await movement_finished → _execute_next_command()
        DIALOGUE: _cmd_dialogue(cmd) # await dialogue_finished → _execute_next_command()
        ...
```

**장점**:
- 데이터로 연출 정의 (Code-First)
- 새 명령 타입 쉽게 추가 가능
- 터치 가속으로 전체 속도 제어

## 칸 기반 전투 시스템

### 전장 구조

```
아군 영역          적군 영역
┌───┬───┬───┐    ┌───┬───┬───┐
│ A │ B │ C │    │ D │ E │ F │
├───┼───┼───┤    ├───┼───┼───┤
│ G │ H │ I │    │ J │ K │ L │
└───┴───┴───┘    └───┴───┴───┘
```

### 타겟 패턴

- 단일 칸
- 가로 1줄
- 세로 1줄
- 앞열 전체
- 후열 전체
- 십자
- 전체 적군/아군

### 행동 흐름

```
1. 행동자 선택 (캐릭터 탭)
2. 행동 선택 (공격/스킬/아이템/이동)
3. 대상 선택 (칸 탭)
4. 계산 → 연출 → 결과
```

## 저장 시스템

### 저장 슬롯 구조

```
- 수동 슬롯 3개
- 자동 저장 1개
- 중단 저장 1개
```

### 로드 파이프라인

```
슬롯 선택 → 헤더 읽기 → 검증 → DNA 읽기 
→ 마이그레이션 → RNA 변환 → 상태 적용 → 안전 진입점 복귀
```

## 모바일 UX 패턴

### 터치 입력

- **탭**: 이동, 선택, 대화 진행
- **길게 누르기**: 설명 표시, 빠른 진행
- **드래그**: 연속 이동 방향

### UI 계층

```
┌─────────────────────────┐
│         HUD             │  항상 표시 (일부 화면 제외)
├─────────────────────────┤
│      Game Screen        │  현재 화면
├─────────────────────────┤
│     Overlay Menu        │  인벤토리, 설정 등
└─────────────────────────┘
```

## 중요 구현 경로

### 전투 진입/복귀

```
탐험 → 적 심볼 접촉 → 전투 씬 로드 → 전투 종료 → 탐색 복귀
```

### 팀 분기

```
Roster (전체 동료)
├── Squad A (한국 팀)
├── Squad B (일본 팀)
└── Shared Inventory
```

## 확장 포인트

1. **새 캐릭터**: CharacterData 추가, 레지스트리 등록
2. **새 스킬**: SkillData 추가, 타겟 패턴 정의
3. **새 맵**: LocationScreen 확장
4. **새 컷신**: cutscenes/ 폴더에 파일 생성, CutsceneRegistry에 등록
5. **새 NPC**: npcs/ 폴더에 파일 생성, NPCRegistry에 등록
6. **새 상점**: shops/ 폴더에 파일 생성, ShopRegistry에 등록