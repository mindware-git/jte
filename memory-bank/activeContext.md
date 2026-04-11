# Active Context - 동유기 (JTE)

## 현재 작업 포커스

현재 프로젝트는 **컷신 시스템 구현 완료** 단계입니다. 명령 시퀀스 기반의 StoryScreen이 구현되었으며, Part 1 오프닝 컷신 데이터가 작성되어 있습니다.

## 최근 변경 사항

### 2026-04-11 컷신 시스템 구현
- **CutsceneCommand**: SPAWN/MOVE/DIALOGUE/WAIT/ANIMATE/CAMERA/DESPAWN/SET_FLAG/FADE/SE 10종 명령
- **CutsceneData**: 명령 시퀀스 + 맵 배경 + 종료 후 전환 화면
- **CutsceneRegistry**: NPCRegistry 패턴, 개별 컷신 파일 등록
- **StoryScreen**: Node2D 기반, async 명령 실행, 터치 4배속 가속
- **DialoguePanel 재사용**: 컷신 중 NPC 대화에 기존 패널 활용
- 기존 StoryScreen/StorySequenceData/StoryRegistry 삭제

### 2026-04-11 상호작용 시스템 개선
- Input 기반 → Button 기반 상호작용 전환
- NPC 대화 연동 (_on_interactable_interacted → _open_dialogue)

### 파일 구조
```
scripts/res/
├── cutscene_command.gd       # 명령 데이터 (10종)
├── cutscene_data.gd          # 컷신 데이터
└── registry/
    ├── cutscene_registry.gd  # 컷신 레지스트리
    └── cutscenes/
        └── part1_opening.gd  # Part 1 오프닝

scripts/ui/
└── story_screen.gd           # 컷신 플레이어 (StoryScreen)

scenes/dev/
└── dev_story.gd              # 컷신 테스트 진입점
```

## 다음 단계

### 우선순위 1: 전체 플로우 연결
1. Title → StoryScreen(part1_opening) → ExploreScreen 한 사이클 동작 확인
2. ExploreScreen에서 이벤트 트리거 → StoryScreen 컷신 발동
3. ExploreScreen → BattleScreen → ExploreScreen 복귀

### 우선순위 2: 컷신 콘텐츠 확장
1. Part 1 오프닝 컷신 실제 테스트 및 연출 조정
2. 추가 컷신 데이터 (봉인 해방, 연등숲 소동)
3. SE(사운드) 시스템 연동

### 우선순위 3: 탐험 콘텐츠
1. 퍼즐 기믹 (오행 제단, 등롱 퍼즐)
2. AStarGrid2D 경로 탐색
3. 이벤트 트리거 (특정 위치 진입 시 컷신 자동 발동)

## 활성 결정 사항

### 컷신 명령 타입
| 타입 | 설명 | 비동기 |
|------|------|--------|
| SPAWN | 캐릭터 등장 | 즉시 |
| MOVE | 캐릭터 이동 | await movement_finished |
| DIALOGUE | NPC 대화 (DialoguePanel) | await dialogue_finished |
| SAY | 단순 대사 (하단 대사창) | 타이핑 + 자동 진행 |
| WAIT | 대기 | await timer |
| ANIMATE | 애니메이션 재생 | 즉시 |
| CAMERA | 카메라 이동/줌 | await tween |
| DESPAWN | 캐릭터 퇴장 | 즉시 |
| SET_FLAG | 플래그 설정 | 즉시 |
| FADE | 화면 페이드 | await tween |
| SE | 사운드 | 즉시 |

### 새 컷신 추가 방법
1. `scripts/res/registry/cutscenes/` 에 파일 생성
2. `get_cutscene_data()` static 함수로 CutsceneData 반환
3. `CutsceneRegistry._register_all_cutscenes()`에 등록

## 중요 패턴

### 컷신 실행 흐름
1. `GameManager.cutscene_id = "part1_opening"`
2. `GameManager.current_screen = "animation"`
3. main.gd → StoryScreen.new()
4. setup(rna) → CutsceneRegistry에서 데이터 로드
5. 명령 순차 실행 (await 기반)
6. 완료 → GameManager.current_screen = next_screen → finished.emit()

### 터치 가속
- 터치 중: speed_multiplier = 4.0
- 대사 타이핑 중 터치 → 즉시 완료
- 자동 진행 대기 중 터치 → 즉시 다음

### 테스트
- GUT 프레임워크 사용
- 실행: `godot --headless --path . -s addons/gut/gut_cmdln.gd`
- dev_story.tscn으로 컷신 직접 테스트 가능

## 프로젝트 인사이트

- **명령 시퀀스 패턴**: 컷신은 CutsceneCommand 배열로 표현, async 루프로 실행
- **Registry 패턴 일관성**: NPC/Shop/Cutscene 모두 동일한 레지스트리 구조
- **DialoguePanel 재사용**: 컷신/탐험 양쪽에서 동일한 대화 UI 사용
- **터치 가속**: StoryScreen은 재생속도 조절만 허용, 완전 스킵은 불가