# Active Context - 동유기 (JTE)

## 현재 작업 포커스

현재 프로젝트는 **파트 1 콘텐츠 구현 단계**입니다. 상점 시스템이 완성되었으며, 탐험 시스템 확장이 다음 작업입니다.

## 최근 변경 사항

### 2026-04-08 상점 시스템 구현 완료
- ShopData (상점 데이터 클래스) 생성
- ShopRegistry (상점 레지스트리) 생성
- GeneralStore (잡화상 상점 데이터) 생성
- ShopPanel (오버레이 상점 UI) 생성
- LocationScreen에 상점 상호작용 연동
- bluewood_village에 잡화상 연결
- 상점 관련 번역 키 추가

### 2026-04-08 이전 구현
- TavernScreen (주점 내부 화면) 생성
- DialoguePanel (오버레이 다이얼로그) 생성
- old_man NPC 데이터 생성 및 NPCRegistry 등록
- InteractionData LOCATION 타입 추가
- part_0_complete.json → part_1_init.json (파일명 변경)
- cheongmok_village → bluewood_village (위치 ID 수정)
- 파티 멤버에서 오공 제거 (초기 상태)

### 파일 구조
```
scripts/
├── entities/
│   ├── character.gd        # 기본 캐릭터
│   └── battle_grid.gd      # 전투 그리드
├── managers/
│   └── enemy_ai.gd         # 적 AI
├── res/
│   ├── battle_data.gd      # 전투 데이터
│   ├── skill_data.gd       # 스킬 데이터
│   ├── interaction_data.gd  # 상호작용 데이터
│   └── registry/           # 레지스트리들
│       ├── locations/
│       │   └── bluewood_village.gd
│       └── npcs/
│           └── old_man.gd
└── ui/
    ├── dialogue_screen.gd
    ├── dialogue_panel.gd     # 오버레이 대화
    ├── tavern_screen.gd      # 주점 내부
    ├── location_screen.gd
    └── ...
```

## 다음 단계

1. **탐험 시스템 확장**
   - 상호작용 오브젝트
   - 퍼즐 기믹
   - 이벤트 트리거

2. **전투 시스템 완성**
   - 전투 UI 개선
   - 스킬 효과 구현
   - 상태이상 시스템

3. **저장 시스템 구현**
   - DNA/RNA 변환 로직
   - 마이그레이션 시스템

## 활성 결정 사항

### 화면 관리
- `main.gd`가 모든 화면 전환 관리
- 화면은 동적 생성, `.tscn` 파일 최소화
- HUD는 항상 상단, 특정 화면에서만 숨김

### 오버레이 패턴
- DialoguePanel: 기존 화면 위에 대화 표시
- ShopPanel: 기존 화면 위에 상점 표시
- `add_child(panel)` 방식, 화면 전환 없음

### 전투 설계
- 칸 기반 타겟팅
- 아군/적 동일 Unit 구조
- 레지스트리로 스킬/아이템 관리

### 데이터 관리
- GameManager에서 게임 상태 관리
- JSON 기반 저장 데이터
- 번역 키 기반 텍스트

## 중요 패턴

### 네이밍 컨벤션
- 변수: `bluewood` 스타일 (예: `bluewood_account`)
- 캐릭터 이름: 그대로 사용 (예: `sanzang`)

### 테스트
- GUT 프레임워크 사용
- 실행: `godot --headless --path . -s addons/gut/gut_cmdln.gd`

### 문서 참조
- `docs/ARCHITECTURE.md` - 전체 아키텍처
- `docs/BATTLE_ARCHITECTURE.md` - 전투 시스템
- `docs/SAVE_LOAD_ARCHITECTURE.md` - 저장 시스템

## 알려진 이슈

1. ShopPanel 테스트 파일 컴파일 이슈 (순환 참조 의심)
2. ItemRegistry에 더 많은 아이템 데이터 필요

## 프로젝트 인사이트

- **탐험이 핵심**: 전투는 탐험의 연장선
- **모바일 우선**: 모든 UX는 터치 기준
- **AI 협업**: Spec → Test → Implementation 흐름 유지
- **오버레이 방식**: 화면 전환 없이 패널 표시