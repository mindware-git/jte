# Progress - 동유기 (JTE)

## 현재 상태

**개발 단계**: 파트 1 콘텐츠 구현 중 - 상점 시스템 완료

## 완료된 기능

### 상점 시스템 (2026-04-10)
- [x] ShopData 간소화 (id, name_key, location_id, item_ids)
- [x] ShopRegistry (get_shop_by_location)
- [x] BlueWoodShop 상점 데이터
- [x] ShopPanel UI (구매/판매 탭)
- [x] NPC 타입 시스템 (shop, dialogue, quest)
- [x] BlueWoodShopKeeper 상점 NPC
- [x] NPC 클릭 → 상점 열기 연동

### 이동 시스템 (2026-04-10)
- [x] GRID 기반 이동 (64x64 단위)
- [x] Actor 통합 이동 시스템 (Player, NPC, Enemy)
- [x] X축 우선 경로 계산
- [x] Role별 속도 차이 (Player 5배)
- [x] 이동 중 경로 변경 (Player만)
- [x] NPC 랜덤 배회 (2~5초 타이머)
- [x] 음수 좌표 방지

### 탐험 시스템
- [x] Gate 시스템 (맵 이동)
- [x] Interactable 시스템 (NPC, treasure, investigate, battle)
- [x] Actor 클릭 감지
- [x] NPC 근접 감지 (3 grid 거리)
- [x] ExploreScreen 동적 Interactable 생성

### 코어 아키텍처
- [x] 6계층 아키텍처 설계
- [x] main.gd 중심 화면 전환 시스템
- [x] 상태 기반 게임 흐름
- [x] GameManager 상수 (TILE_SIZE, GRID_SIZE)

### 캐릭터 시스템
- [x] Actor 통합 클래스 (CharacterBody2D)
- [x] CharacterData 데이터 구조
- [x] 클릭 영역 및 상호작용
- [x] Direction 애니메이션

### 전투 시스템
- [x] TacticGrid 그리드 시스템
- [x] BattleData (Unit, BattleCell, BattleAction)
- [x] EnemyAI 기본 구조
- [x] 칸 기반 타겟팅 설계

### 데이터 시스템
- [x] SkillData 및 SkillRegistry
- [x] ItemData 및 ItemRegistry
- [x] ShopData 및 ShopRegistry
- [x] NPCData 및 NPCRegistry
- [x] 레지스트리 패턴 구현

### UI 시스템
- [x] TitleScreen
- [x] LocationScreen
- [x] DialogueScreen
- [x] CharacterSelectScreen
- [x] HUD 기본 구조
- [x] ShopPanel (오버레이 상점)

### 저장 시스템
- [x] 저장/로드 아키텍처 설계 (DNA/RNA)
- [x] 개발용 저장 데이터 (asset/saves/dev/)

### 국제화
- [x] 번역 파일 구조
- [x] 4개 언어 지원 (ko, zh, ja, en)

### 파트 1 맵 시스템
- [x] TavernScreen (주점 내부 화면)
- [x] DialoguePanel (오버레이 대화)
- [x] 허풍 노인 NPC 데이터
- [x] bluewood_village 상호작용 (LOCATION 타입)
- [x] InteractionData LOCATION 타입 추가
- [x] bluewood_shop 씬 (청목진 상점)

## 진행 중인 작업

### 탐험 시스템
- [ ] AStarGrid2D 경로 탐색 (장애물 회피)
- [ ] GRID 선점 시스템
- [ ] 퍼즐 기믹
- [ ] 이벤트 트리거

### 전투 시스템 확장
- [ ] 전투 UI 개선
- [ ] 스킬 효과 구현
- [ ] 상태이상 시스템
- [ ] 전투 애니메이션 연출

### 저장 시스템 구현
- [ ] DNA/RNA 변환 로직
- [ ] 마이그레이션 시스템
- [ ] 자동 저장 로직

## 남은 작업

### 단기 (1-2주)
- [ ] 전투 튜토리얼
- [ ] 기본 스킬 10개 구현
- [ ] 첫 번째 던전 완성

### 중기 (1개월)
- [ ] 파트 1 전체 플레이 가능
- [ ] 저장/로드 완전 구현
- [ ] 기본 UI/UX 개선

### 장기 (3개월+)
- [ ] 파트 1~16 콘텐츠
- [ ] 팀 분기 시스템
- [ ] 모바일 최적화
- [ ] Android/iOS 빌드

## 알려진 이슈

1. **스프라이트 리소스**: 정리 및 최적화 필요
2. **전투 연출**: 컷인, 이펙트 미구현
3. **다국어 검증**: 번역 키 누락 검사 필요
4. **테스트 커버리지**: 단위 테스트 확장 필요
5. **음수 좌표**: Player 클릭 이동에도 음수 방지 필요
6. **SkillData 테스트**: 2개 테스트 실패 (스킬 데이터 누락)

## 결정 이력

| 날짜 | 결정 사항 | 이유 |
|------|----------|------|
| 초기 | main.gd 중심 구조 | AI 가독성, 초기 개발 속도 |
| 초기 | 칸 기반 전투 | 환상서유기 스타일, 모바일 UX |
| 초기 | 레지스트리 패턴 | 데이터/로직 분리, 확장성 |
| 초기 | GUT 테스트 프레임워크 | Godot 표준, 커맨드라인 지원 |
| 4/8 | DialoguePanel 오버레이 | 화면 전환 없이 대화 표시 |
| 4/8 | part_1_init.json | 파트 1 초기 상태 정의 |
| 4/10 | GRID 기반 이동 | 64x64 단위, 충돌 영역과 일치 |
| 4/10 | chest → treasure | 보물상자 명확화 |
| 4/10 | X축 우선 경로 | 단순화, AStar는 나중에 |
| 4/10 | Role별 속도 | Player 5배 빠름 |
| 4/10 | NPC 타입 시스템 | shop, dialogue, quest 구분 |
| 4/10 | location_id 기반 상점 | 씬 이름으로 상점 매핑 |
| 4/10 | ShopData 간소화 | 불필요한 필드 제거 |

## 다음 마일스톤

**목표**: 파트 1 플레이 가능 버전

필요 작업:
1. ~~전투 시스템 완성~~
2. ~~GRID 기반 이동 시스템~~ (완료)
3. ~~상점 시스템~~ (완료)
4. 첫 번째 맵 완성 (진행 중)
5. 기본 스킬/아이템 구현
6. 저장/로드 기본 기능
7. 튜토리얼 플로우

## 이번 세션 작업 내역

### 2026-04-10 (상점 시스템)
1. ShopData 간소화 (불필요한 필드 제거)
2. ShopRegistry 생성 (get_shop_by_location)
3. BlueWoodShop 상점 데이터 생성
4. NPCData에 npc_type, shop_id 필드 추가
5. BlueWoodShopKeeper NPC 데이터 생성
6. NPCRegistry에 BlueWoodShopKeeper 등록
7. ExploreScreen._on_npc_clicked() NPC 타입별 처리
8. ExploreScreen._open_shop() 함수 추가
9. ShopData.get_item_ids() 함수 추가
10. 메모리 뱅크 업데이트

### 2026-04-10 (이동 시스템)
1. GameManager: TILE_SIZE(32), GRID_SIZE(64) 상수 추가
2. Actor.gd: GRID 기반 이동 시스템 구현
3. Actor.gd: Role별 속도 설정 (Player 5배)
4. Actor.gd: 이동 중 경로 변경 가능 (force 파라미터)
5. ExploreScreen.gd: NPC 랜덤 배회 구현
6. ExploreScreen.gd: NPC 초기화 시 set_tile() 호출
7. ExploreScreen.gd: 음수 좌표 방지
8. interactable.gd: chest → treasure 타입 변경

### 2026-04-08
1. TavernScreen 생성 (주점 내부 화면)
2. DialoguePanel 생성 (오버레이 대화 시스템)
3. old_man NPC 데이터 생성
4. NPCRegistry 등록
5. 번역 키 추가
6. part_0_complete.json → part_1_init.json
7. cheongmok_village → bluewood_village 수정
8. 파티 멤버 수정 (오공 제거)