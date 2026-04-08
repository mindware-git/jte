# Implementation Plan

[Overview]
탐험 시스템에서 캐릭터가 맵을 자유롭게 이동하고 NPC 및 오브젝트와 상호작용할 수 있는 시스템을 구현합니다.

현재 `LocationScreen`은 리스트 기반 UI로 상호작용을 선택하는 방식입니다. 이를 확장하여 타일맵 위에서 플레이어 캐릭터가 실제로 이동하고, NPC나 보물상자 등의 오브젝트를 클릭하여 상호작용할 수 있도록 합니다.

**최소 접근 방안**: 기존 VillageScreen, ForestScreen 등은 유지하고, LocationScreen에만 탐험 기능을 추가하여 점진적으로 통합합니다.

**핵심 요구사항**:
1. 캐릭터(플레이어, NPC, 몹)는 공통된 표현 방식 사용 - CharacterBody2D 기반에 AnimatedSprite2D 포함
2. 이동은 텔레포트 방식 (클릭한 위치로 즉시 이동)
3. Camera2D는 기본 씬에 포함하지 않고, 필요시 GDScript에서 동적 추가
4. 땅 클릭 시 해당 위치로 이동
5. 상호작용 오브젝트 클릭 시 근처로 이동 후 상호작용 실행
6. 전투 진입은 기존 흐름 유지 (transition_requested → Battle 씬)

[Types]

### Direction enum
이동 방향을 나타내는 enum (애니메이션 선택용)
```gdscript
enum Direction { DOWN, LEFT, RIGHT, UP }
```

### InteractableType enum (기존 InteractionData.InteractionType 활용)
상호작용 오브젝트 타입
```gdscript
# NPC=0, SHOP=1, INVESTIGATE=2, STORY=3, BATTLE=4, PUZZLE=5, LOCATION=6
```

[Files]

### New Files

1. **scenes/entities/actor.tscn** ✓ (생성됨)
   - CharacterBody2D 기반 범용 캐릭터 프리팹
   - AnimatedSprite2D, CollisionShape2D 포함
   - Camera2D 미포함 (필요시 동적 추가)

2. **scenes/entities/actor.gd** ✓ (생성됨, 구현 필요)
   - Actor 스크립트
   - 텔레포트 이동 로직
   - 충돌 처리 (CharacterBody2D 활용)

3. **scripts/entities/interactable_object.gd**
   - 상호작용 가능한 오브젝트 (NPC, 보물상자 등)
   - Area2D 기반
   - 클릭 감지, 상호작용 범위 설정
   - InteractionData와 연동

### Modified Files

1. **scripts/ui/location_screen.gd**
   - 플레이어 캐릭터(Actor) 배치
   - 상호작용 오브젝트 동적 배치
   - 땅 클릭 이동 처리
   - 기존 버튼 UI 유지 (탐험 모드와 병행)

[Functions]

### New Functions

1. **Actor**
   - `init(data: CharacterData)` - 캐릭터 초기화
   - `move_to(target_pos: Vector2)` - 목표 위치로 텔레포트
   - `can_move_to(pos: Vector2) -> bool` - 이동 가능 여부 체크

2. **LocationScreen**
   - `_setup_player()` - 플레이어(Actor) 배치
   - `_setup_interactables()` - 상호작용 오브젝트 배치
   - `_on_ground_clicked(pos: Vector2)` - 땅 클릭 처리
   - `_on_interactable_clicked(obj: InteractableObject)` - 오브젝트 클릭 처리

### Modified Functions

1. **LocationScreen._create_ui()**
   - 플레이어 캐릭터 노드 추가
   - 상호작용 오브젝트 컨테이너 추가

[Classes]

### New Classes

1. **Actor (scenes/entities/actor.gd)**
   - 상속: CharacterBody2D
   - 주요 멤버:
     - `_animated_sprite: AnimatedSprite2D`
     - `_data: CharacterData`
   - 주요 메서드:
     - `move_to(pos: Vector2)` - 텔레포트 이동

2. **InteractableObject (scripts/entities/interactable_object.gd)**
   - 상속: Area2D
   - 주요 멤버:
     - `_interaction_data: InteractionData`
     - `_sprite: AnimatedSprite2D`
   - 시그널:
     - `interacted(player: Actor)`

### Modified Classes

1. **LocationScreen (scripts/ui/location_screen.gd)**
   - 추가 멤버:
     - `_player: Actor`
     - `_interactables: Node2D`
   - 변경 사항:
     - `_ready()`에서 플레이어와 오브젝트 배치

[Dependencies]

새로운 외부 의존성 없음. 기존 시스템 활용:
- CharacterData, InteractionData (기존)
- LocationRegistry (기존)
- GameManager (기존)

[Testing]

### 테스트 방법
1. `part_1.gd` 실행
2. `LocationScreen.new("bluewood_village")` 진입
3. Actor 표시 확인
4. 땅 클릭 → 이동 확인
5. NPC/오브젝트 클릭 → 상호작용 확인
6. 전투 진입 → Battle 씬 전환 확인

[Implementation Order]

1. **Actor 스크립트 구현** (scenes/entities/actor.gd)
   - CharacterBody2D 기반
   - AnimatedSprite2D 설정
   - 텔레포트 이동 로직
   - init() 함수

2. **InteractableObject 클래스 생성** (scripts/entities/interactable_object.gd)
   - Area2D 기반
   - 클릭 감지
   - InteractionData 연동

3. **LocationScreen 개선** (scripts/ui/location_screen.gd)
   - 플레이어(Actor) 배치
   - 상호작용 오브젝트 배치
   - 땅 클릭 이동 처리
   - 오브젝트 클릭 처리

4. **통합 테스트**
   - 실제 씬에서 동작 확인
   - 기존 기능 영향 없음 확인