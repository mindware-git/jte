# Progress - 동유기 (JTE)

## 현재 상태

**개발 단계**: 파트 1 콘텐츠 구현 중

## 완료된 기능

### 코어 아키텍처
- [x] 6계층 아키텍처 설계
- [x] main.gd 중심 화면 전환 시스템
- [x] 상태 기반 게임 흐름

### 캐릭터 시스템
- [x] Character 기본 클래스 (scripts/entities/character.gd)
- [x] CharacterData 데이터 구조
- [x] 클릭 영역 및 상호작용

### 전투 시스템
- [x] BattleGrid 그리드 시스템
- [x] BattleData (Unit, BattleCell, BattleAction)
- [x] EnemyAI 기본 구조
- [x] 칸 기반 타겟팅 설계

### 데이터 시스템
- [x] SkillData 및 SkillRegistry
- [x] ItemData 및 ItemRegistry
- [x] 레지스트리 패턴 구현

### UI 시스템
- [x] TitleScreen
- [x] LocationScreen
- [x] DialogueScreen
- [x] CharacterSelectScreen
- [x] HUD 기본 구조
- [x] ShopScreen (기본)

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

## 진행 중인 작업

### 탐험 시스템
- [ ] 상점 시스템 (ShopPanel)
- [ ] 상호작용 오브젝트 시스템
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

## 결정 이력

| 날짜 | 결정 사항 | 이유 |
|------|----------|------|
| 초기 | main.gd 중심 구조 | AI 가독성, 초기 개발 속도 |
| 초기 | 칸 기반 전투 | 환상서유기 스타일, 모바일 UX |
| 초기 | 레지스트리 패턴 | 데이터/로직 분리, 확장성 |
| 초기 | GUT 테스트 프레임워크 | Godot 표준, 커맨드라인 지원 |
| 4/8 | DialoguePanel 오버레이 | 화면 전환 없이 대화 표시 |
| 4/8 | part_1_init.json | 파트 1 초기 상태 정의 |

## 다음 마일스톤

**목표**: 파트 1 플레이 가능 버전

필요 작업:
1. ~~전투 시스템 완성~~
2. 첫 번째 맵 완성 (진행 중)
3. 기본 스킬/아이템 구현
4. 저장/로드 기본 기능
5. 튜토리얼 플로우

## 이번 세션 작업 내역

### 2026-04-08
1. TavernScreen 생성 (주점 내부 화면)
2. DialoguePanel 생성 (오버레이 대화 시스템)
3. old_man NPC 데이터 생성
4. NPCRegistry 등록
5. 번역 키 추가
6. part_0_complete.json → part_1_init.json
7. cheongmok_village → bluewood_village 수정
8. 파티 멤버 수정 (오공 제거)