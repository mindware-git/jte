# Tech Context - 동유기 (JTE)

## 기술 스택

### 게임 엔진
- **Godot 4.x**: 최신 stable 버전 사용
- **GDScript**: 주요 개발 언어
- **내장 i18n**: 국제화 시스템

### 개발 환경
- **IDE**: Visual Studio Code
- **버전 관리**: Git
- **테스트 프레임워크**: GUT (Godot Unit Testing)

### 배포 플랫폼
- **Android**: Primary target
- **iOS**: Secondary target

## 프로젝트 설정

### 디렉토리 구조

```
jte/
├── addons/gut/           # GUT 테스트 프레임워크
├── asset/
│   ├── saves/            # 저장 데이터
│   ├── sprite/           # 스프라이트 리소스
│   ├── Texture/          # 텍스처
│   └── tileset/          # 타일셋
├── docs/
│   ├── ARCHITECTURE.md
│   ├── BATTLE_ARCHITECTURE.md
│   ├── SAVE_LOAD_ARCHITECTURE.md
│   ├── data/             # 데이터 기획 문서
│   └── specs/            # 스펙 문서
├── localization/         # 번역 파일
├── memory-bank/          # Memory Bank
├── scenes/
│   ├── battle/           # 전투 씬
│   ├── dev/              # 개발용 씬
│   ├── locations/        # 위치 씬
│   ├── prd/              # 메인 씬
│   └── ui/               # UI 씬
├── scripts/
│   ├── entities/         # 엔티티 클래스
│   ├── managers/         # 매니저 클래스
│   ├── res/              # 리소스/데이터 클래스
│   └── ui/               # UI 스크립트
├── test/unit/            # 단위 테스트
├── .gutconfig.json       # GUT 설정
├── AGENTS.md             # AI 개발 가이드
└── project.godot         # Godot 프로젝트 설정
```

### GUT 테스트 실행

```bash
godot --headless --path . -s addons/gut/gut_cmdln.gd
```

### GUT 설정 (.gutconfig.json)

프로젝트 루트에 위치하며 테스트 디렉토리, 출력 형식 등을 설정합니다.

## 핵심 기술 제약

### 모바일 최적화
- **터치 전용**: 가상 조이스틱 없음
- **세션 설계**: 짧은 플레이 세션 지원
- **해상도 대응**: 16:9 및 더 긴 세로 비율

### 성능 고려사항
- 저사양 기기 지원
- 전투 연출 스킵 가능
- 컷인 생략 옵션

### 저장 시스템
- JSON 기반 저장 데이터
- DNA/RNA 분리 구조
- 마이그레이션 지원

## 의존성

### 내장 (Godot)
- AnimatedSprite2D
- Area2D / CollisionShape2D
- CanvasLayer
- TileMap

### 외부 애드온
- **GUT**: Godot Unit Testing
  - 버전: addons/gut/ 내 최신
  - 용도: 단위 테스트

## 데이터 관리

### 레지스트리 시스템

```gdscript
# 스킬 레지스트리
SkillRegistry.new()
    .get_skill("flame_slash")

# 아이템 레지스트리  
ItemRegistry.new()
    .get_item("health_potion")

# 캐릭터 레지스트리
CharacterRegistry.new()
    .get_character("songoku")
```

### 데이터 파일

```
scripts/res/
├── battle_data.gd      # Unit, BattleCell, BattleAction
├── skill_data.gd       # SkillData
├── item_data.gd        # ItemData
├── character_data.gd   # CharacterData
└── registry/
    ├── skill_registry.gd
    ├── item_registry.gd
    └── character_registry.gd
```

## 국제화 (i18n)

### 지원 언어
- 한국어 (ko)
- 중국어 (zh)
- 일본어 (ja)
- 영어 (en)

### 번역 파일

```
localization/
├── translations.csv        # 원본 번역 테이블
├── translations.ko.translation
├── translations.en.translation
├── translations.ja.translation
└── translations.zh.translation
```

### 번역 키 네이밍

```
part_01.cutscene.opening.samjang_001
item.bongrae_jade_token.name
skill.goku_staff_storm.name
ui.settings.save
```

## 개발 워크플로우

### Spec → Test → Implementation

1. **Spec 작성**: `docs/specs/`에 스펙 문서
2. **Test 작성**: `test/unit/`에 테스트 코드
3. **Implementation**: `scripts/`에 구현

### 네이밍 컨벤션

- **변수**: `bluewood` 스타일 (예: `bluewood_account`)
- **캐릭터 이름**: 그대로 사용 (예: `samzang`, `songoku`)
- **클래스**: PascalCase (예: `BattleGrid`)
- **함수**: snake_case (예: `get_skill()`)

## 기술 부채

1. 스프라이트 리소스 정리 필요
2. 전투 애니메이션 연출 미구현
3. 다국어 키 검증 시스템 필요
4. 저장 마이그레이션 테스트 필요

## 확장 계획

1. **전투 연출**: 컷인, 이펙트 시스템
2. **퍼즐 시스템**: 탐험 내 퍼즐 기믹
3. **이벤트 시스템**: 컷신 명령 시퀀스
4. **사운드**: BGM, 효과음 시스템