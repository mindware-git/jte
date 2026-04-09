# Active Context - 동유기 (JTE)

## 현재 작업 포커스

현재 프로젝트는 **파트 1 콘텐츠 구현 단계**입니다. 탐험 시스템의 핵심인 Gate와 Interactable 시스템이 완성되었으며, Registry 시스템이 정리되었습니다.

## 최근 변경 사항

### 2026-04-09 Registry 시스템 정리
- **CharacterRegistry**: 레거시 캐릭터(gyro, shamu, enemy_slime) 제거, 동유기 캐릭터만 유지 (sanzang, wukong, bajie, sandy)
- **LocationRegistry**: 삭제 - 씬 기반으로 대체
- **NPCRegistry**: 유지 - 대화 데이터 관리 전담

### 2026-04-09 NPC Registry → Actor/Interactable 통합 설계
```
Location Scene (tscn)
├── Actor (NPC) ──────→ 시각적 표현, 이동
├── Gate ────────────→ 위치 전환
└── Interactable ────→ 클릭 감지

ExploreScreen
├── NPCRegistry ────→ 대화 데이터 조회
└── DialogueUI ─────→ 대화 표시
```

### 2026-04-09 전투 시스템 개선
- **RNA 데이터 전달 문제 해결**: `to_rna()`와 `_setup_battle()` 간 키 불일치 수정
- **전투 진입 문제 해결**: `main.gd`에서 `add_child()` 후 `setup()` 호출 순서 변경
- **전투 종료 후 화면 전환**: 승리 시 explore, 패배 시 title 화면으로 전환

### 파일 구조
```
scripts/res/
├── character_data.gd
├── npc_data.gd
├── item_data.gd
├── skill_data.gd
├── battle_data.gd
├── save_data.gd
└── registry/
    ├── character_registry.gd  # 동유기 캐릭터만
    ├── npc_registry.gd        # 대화 데이터 관리
    ├── skill_registry.gd
    └── item_registry.gd

scenes/entities/
├── gate.tscn              # 맵 이동용 Area2D
├── gate.gd                # Gate 로직
├── interactable.tscn      # 상호작용용 Area2D
├── interactable.gd        # Interactable 로직
├── actor.tscn             # 캐릭터 (Player, NPC, Enemy)
└── actor.gd               # Actor 로직
```

## 다음 단계

1. **대화 시스템 연동**
   - NPCRegistry에서 대화 데이터 조회
   - DialogueUI 구현

2. **전투 시스템 완성**
   - 전투 UI 개선
   - 스킬 효과 구현

3. **저장 시스템 구현**
   - DNA/RNA 변환 로직

## 활성 결정 사항

### Registry 책임 분리
| Registry | 책임 |
|----------|------|
| CharacterRegistry | 캐릭터 데이터 (스탯, 속성) |
| NPCRegistry | NPC 대화 데이터 |
| SkillRegistry | 스킬 데이터 |
| ItemRegistry | 아이템 데이터 |

### 상호작용 시스템 설계
- Gate: 맵 이동 전용, 플레이어 접촉 시 자동 발동
- Interactable: 클릭 기반 상호작용, NPC/상자/조사 포인트

### 화면 관리
- `main.gd`가 모든 화면 전환 관리
- 화면은 동적 생성, `.tscn` 파일 최소화

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

## 프로젝트 인사이트

- **탐험이 핵심**: 전투는 탐험의 연장선
- **모바일 우선**: 모든 UX는 터치 기준
- **AI 협업**: Spec → Test → Implementation 흐름 유지
- **오버레이 방식**: 화면 전환 없이 패널 표시
- **Registry 분리**: 데이터 타입별 전담 관리