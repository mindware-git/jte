# 동유기 저장/로드 아키텍처

## 목적

이 문서는 `동유기`의 저장/로드 구조를 별도로 정의한다.

핵심 목표는 세 가지다.

- 앱이 계속 업데이트되어도 기존 저장 데이터를 최대한 살린다.
- 저장용 데이터 구조와 런타임 구조를 명확히 분리한다.
- `main.gd` 중심 구조에서도 저장/복원이 단순하고 안정적으로 되게 한다.

이 문서에서는 Blender의 비유를 빌려 아래처럼 구분한다.

- `DNA`: 저장 파일에 기록되는 안정적인 스키마
- `RNA`: 런타임에서 게임이 실제로 쓰는 상태 구조

즉, 게임은 RNA로 동작하고, 저장은 DNA로 기록한다.

---

## 핵심 원칙

- 저장 포맷은 `런타임 변수 덤프`가 아니라 `의미 있는 게임 상태`만 담는다.
- 저장 포맷은 버전 정보를 반드시 가진다.
- 런타임 구조는 바뀔 수 있지만, 저장 포맷은 쉽게 깨지지 않아야 한다.
- 로드 시에는 `DNA -> Migration -> RNA` 순서로 복원한다.
- 세이브 파일은 항상 `검증 -> 변환 -> 적용` 순서로 처리한다.

---

## 전체 구조

저장/로드는 5개 계층으로 본다.

1. `Save Header`
2. `Save DNA Payload`
3. `Migration Layer`
4. `Load Adapter`
5. `Runtime RNA`

### 1. Save Header

파일이 어떤 저장인지 빠르게 판별하는 메타 정보다.

포함 권장 항목:

- `save_format_version`
- `app_version`
- `content_version`
- `created_at`
- `updated_at`
- `slot_type`
- `playtime_seconds`
- `preview`
- `checksum`

여기서 중요한 건 버전이 하나가 아니라는 점이다.

- `save_format_version`: 저장 스키마 버전
- `app_version`: 실제 앱 빌드 버전
- `content_version`: 스토리/밸런스 데이터 버전

이 셋을 분리해야 문제를 정확히 진단할 수 있다.

### 2. Save DNA Payload

저장 파일 본문이다.

게임을 다시 세울 수 있는 정보만 담는다.

포함:

- 플레이 진행도
- 파티 정보
- 인벤토리
- 퀘스트
- 플래그
- 상자 개봉 여부
- 맵 위치
- 팀 분리 상태

포함하지 않음:

- 카메라 보간 값
- 현재 프레임 애니메이션 시간
- UI 포커스 상태
- 일시적 전투 이펙트 상태

### 3. Migration Layer

구버전 저장 파일을 현재 포맷으로 끌어올리는 계층이다.

역할:

- 옛 필드명 변환
- 제거된 필드 기본값 보정
- 데이터 구조 재배치
- 잘못된 값 교정

원칙:

- `v1 -> v2 -> v3` 식의 단계적 마이그레이션이 안전하다.
- `v1 -> v5` 한 번에 점프하는 특수 코드보다 유지보수가 쉽다.

### 4. Load Adapter

최신 DNA를 런타임 RNA로 바꾸는 계층이다.

역할:

- 저장용 좌표를 런타임 위치 구조로 바꾸기
- 저장된 파티 목록을 런타임 파티 컨텍스트로 바꾸기
- 퀘스트 상태를 실제 진행 상태 객체로 바꾸기

### 5. Runtime RNA

게임이 실제로 도는 상태다.

포함:

- 현재 모드
- 현재 맵 인스턴스 상태
- 입력 잠금 여부
- 애니메이션 재생 단계
- 전투 임시 턴 상태
- 열린 UI 패널

원칙:

- RNA는 플레이에 최적화된 구조여야 한다.
- DNA에 맞추기 위해 RNA를 어색하게 만들지 않는다.

---

## 권장 저장 파일 분리

저장은 최소 3종으로 나누는 게 좋다.

### 1. Profile Save

기기 또는 계정 단위 설정.

포함:

- 언어
- 언어 자동 추종 여부
- 사운드
- 진동
- 텍스트 속도
- 연출 속도
- 접근성 옵션
- 클리어 이력

### 2. Slot Save

실제 플레이 진행 저장.

종류:

- 수동 저장 슬롯
- 자동 저장 슬롯

### 3. Suspend Save

앱 중단 대응용 임시 저장.

특징:

- 앱 복귀 시 우선 확인
- 성공적으로 이어하기 후 삭제 또는 갱신
- 일반 수동 슬롯과는 별도 취급

---

## Save Header 설계

헤더는 빠른 표시와 안정성 확인을 위해 본문과 분리해 생각하는 편이 좋다.

권장 필드:

- `magic`
- `save_format_version`
- `app_version`
- `content_version`
- `slot_id`
- `slot_type`
- `save_uuid`
- `created_at`
- `updated_at`
- `playtime_seconds`
- `chapter_id`
- `part_id`
- `map_id`
- `party_leader_id`
- `preview_text_key`
- `checksum`

### 필드 의미

- `magic`: 동유기 저장 파일 식별자
- `save_format_version`: 마이그레이션 기준
- `app_version`: 어떤 앱 버전에서 썼는지
- `content_version`: 데이터 리밸런싱/스토리 변경 추적
- `preview_text_key`: 슬롯 UI에서 보여줄 설명 키

중요:

- 저장 호환성 판단은 `app_version`이 아니라 `save_format_version`이 기준이다.
- `app_version`은 진단용이고, `save_format_version`은 기술적 호환성 기준이다.

---

## Save DNA 설계 (구체 스키마)

DNA는 `안정성`이 가장 중요하다. 아래는 코드에서 실제로 흩어져 있는 모든 상태를 하나의 JSON 스키마로 통합한 결과다.

### 전체 DNA JSON 스키마

```json
{
  "header": {
    "magic": "DONGYUGI_SAVE",
    "save_format_version": 1,
    "app_version": "0.1.0",
    "content_version": 1,
    "slot_index": 0,
    "slot_type": "manual",
    "save_uuid": "uuid-v4-string",
    "created_at": "2026-04-09T14:30:00",
    "updated_at": "2026-04-09T16:00:00",
    "playtime_seconds": 3600.0,
    "checksum": "sha256-hex"
  },

  "progress": {
    "part_id": "part_1",
    "chapter_id": "act1_prologue",
    "sub_step_id": "",
    "current_objective_id": "",
    "last_animation_id": "",
    "last_explore_entry_id": ""
  },

  "world": {
    "current_screen": "explore",
    "current_location": "bluewood_village",
    "current_map": "village",
    "visited_locations": ["bluewood_village", "elemental_slope"],
    "location_states": {
      "bluewood_village": {
        "player_tile": [11, 12]
      },
      "elemental_slope": {
        "player_tile": [5, 8]
      }
    }
  },

  "party": {
    "members": ["sanzang", "wukong"],
    "leader": "sanzang",
    "owned_characters": ["sanzang", "wukong", "bajie"],
    "current_character": "sanzang",
    "character_states": {
      "sanzang": {
        "character_id": "sanzang",
        "level": 3,
        "experience": 250,
        "equipped_weapon": "equip_weapon_magic_staff",
        "equipped_armor": "equip_armor_monk_robe",
        "equipped_accessory": "",
        "learned_skills": ["divine_grace", "purifying_light"],
        "inventory": {
          "item_herb": 5,
          "item_potion": 2
        }
      },
      "wukong": {
        "character_id": "wukong",
        "level": 2,
        "experience": 120,
        "equipped_weapon": "equip_weapon_yeouibong",
        "equipped_armor": "equip_armor_tiger_pelt",
        "equipped_accessory": "equip_acc_nimbus",
        "learned_skills": ["nimbus_strike"],
        "inventory": {}
      }
    }
  },

  "player_stats": {
    "player_name": "삼장",
    "player_hp": 100,
    "player_max_hp": 100,
    "player_mp": 50,
    "player_max_mp": 50,
    "player_attack": 10,
    "level": 1,
    "experience": 0
  },

  "inventory": {
    "coin": 1500,
    "gem": 10
  },

  "quests": {},

  "flags": {
    "prologue_complete": true,
    "quest_started": true,
    "quest_complete": false,
    "forest_unlocked": true,
    "temple_unlocked": false,
    "boss_defeated": false,
    "wukong_unlocked": true,
    "current_part": "part_1",
    "current_chapter": "act1_prologue"
  },

  "system": {
    "game_purchased": false,
    "save_slots": 1
  }
}
```

### DNA 필드 원본 소스 대조표

아래 표는 이 DNA JSON의 각 필드가 현재 코드에서 **어디에 흩어져 있는지**를 정리한 것이다. 통합 전의 원본 위치를 기록해 두어야 마이그레이션과 리팩터링이 안전하다.

| DNA 경로 | 현재 코드 위치 | 변수명 |
|---|---|---|
| `header.slot_index` | SaveData | `slot_index` |
| `header.created_at` | SaveData | `saved_at` |
| `header.playtime_seconds` | SaveData | `play_time` |
| `progress.part_id` | GameManager._flags | `_flags["current_part"]` |
| `progress.chapter_id` | GameManager._flags | `_flags["current_chapter"]` |
| `world.current_screen` | GameManager | `current_screen` |
| `world.current_location` | GameManager | `current_location` |
| `world.current_map` | GameManager | `current_map` |
| `world.visited_locations` | GameManager | `visited_locations` |
| `world.location_states` | GameManager | `location_states` |
| `party.members` | GameManager | `party_members` |
| `party.leader` | GameManager | `party_leader` |
| `party.owned_characters` | GameManager | `owned_characters` |
| `party.current_character` | GameManager | `current_character` |
| `party.character_states.*` | GameManager | `character_states` → `CharacterState` |
| `player_stats.player_name` | GameManager | `player_name` |
| `player_stats.player_hp` | GameManager | `player_hp` |
| `player_stats.player_max_hp` | GameManager | `player_max_hp` |
| `player_stats.player_mp` | GameManager | `player_mp` |
| `player_stats.player_max_mp` | GameManager | `player_max_mp` |
| `player_stats.player_attack` | GameManager | `player_attack` |
| `player_stats.level` | GameManager | `level` |
| `player_stats.experience` | GameManager | `experience` |
| `inventory.coin` | GameManager | `coin` |
| `inventory.gem` | GameManager | `gem` |
| `flags.*` | GameManager | `_flags` |
| `system.game_purchased` | GameManager | `game_purchased` |
| `system.save_slots` | GameManager | `save_slots` |

### DNA에 포함하지 않는 것

아래는 DNA에 절대 넣지 않는다 (RNA에만 존재):

- `enemy_name`, `enemy_hp`, `enemy_max_hp`, `enemy_attack` (전투 임시)
- `enemy_id`, `from_battle`, `battle_victory` (화면 전환 임시)
- `current_state`, `previous_state` (GameState enum, PVP 용)
- `current_match`, `current_map_data`, `players`, `local_player` (PVP 런타임)
- `item_database`, `skill_database`, `skill_unlock_table` (정적 레지스트리)

---

## Runtime RNA 설계 (구체 Dictionary)

RNA는 `플레이 중심`이어야 한다. 모든 RNA는 `GameManager.rna` 하위의 Dictionary로 통합하여 각 Screen의 `setup(rna)` 호출에 일관되게 전달한다.

### GameManager.rna 전체 구조

```gdscript
## GameManager.to_rna() → Dictionary
var rna: Dictionary = {
    # ─── Flow RNA ─────────────────────────────────────────
    "flow": {
        "current_screen": "explore",       # "title" | "story" | "explore" | "battle" | "location" | "shop" | "result"
        "current_location": "bluewood_village",
        "previous_screen": "story",
        "input_locked": false,
        "from_battle": false,              # 전투에서 돌아왔는가
        "battle_victory": false,           # 직전 전투 승리 여부
    },

    # ─── Party RNA ────────────────────────────────────────
    "party": {
        "members": ["sanzang", "wukong"],
        "leader": "sanzang",
        "owned_characters": ["sanzang", "wukong", "bajie"],
        "current_character": "sanzang",
    },

    # ─── Player Stats RNA ─────────────────────────────────
    "player_stats": {
        "player_name": "삼장",
        "player_hp": 100,
        "player_max_hp": 100,
        "player_mp": 50,
        "player_max_mp": 50,
        "player_attack": 10,
        "level": 1,
        "experience": 0,
    },

    # ─── Economy RNA ──────────────────────────────────────
    "economy": {
        "coin": 1500,
        "gem": 10,
    },

    # ─── World RNA ────────────────────────────────────────
    "world": {
        "current_map": "village",
        "visited_locations": ["bluewood_village", "elemental_slope"],
        "location_states": {
            "bluewood_village": { "player_tile": Vector2i(11, 12) },
        },
    },

    # ─── Battle RNA (전투 진입 시에만 채워짐) ─────────────
    "battle": {
        "enemy_id": "fire_spirit",
        "enemy_name": "불의 정령",
        "enemy_hp": 0,
        "enemy_max_hp": 0,
        "enemy_attack": 0,
    },

    # ─── Flags RNA ────────────────────────────────────────
    "flags": {
        "prologue_complete": true,
        "quest_started": true,
        "quest_complete": false,
        "forest_unlocked": true,
        "temple_unlocked": false,
        "boss_defeated": false,
        "wukong_unlocked": true,
        "current_part": "part_1",
        "current_chapter": "act1_prologue",
    },

    # ─── System RNA ───────────────────────────────────────
    "system": {
        "game_purchased": false,
        "save_slots": 1,
    },
}
```

### RNA 필드 상세

#### 1. Flow RNA — 화면 전환 제어

현재 코드에서 `GameManager.current_screen`, `GameManager.from_battle`, `GameManager.battle_victory` 등이 별도 변수로 흩어져 있는 것을 `rna.flow`로 통합한다.

| 키 | 타입 | 설명 | 원본 변수 |
|---|---|---|---|
| `current_screen` | String | 현재 활성 화면 ID | `GameManager.current_screen` |
| `current_location` | String | 현재 위치(맵) ID | `GameManager.current_location` |
| `previous_screen` | String | 직전 화면 (복귀용) | (신규) |
| `input_locked` | bool | 입력 잠금 여부 | (신규) |
| `from_battle` | bool | 전투에서 돌아왔는지 | `GameManager.from_battle` |
| `battle_victory` | bool | 직전 전투 승리 여부 | `GameManager.battle_victory` |

#### 2. Party RNA — 파티 구성

| 키 | 타입 | 설명 | 원본 변수 |
|---|---|---|---|
| `members` | Array[String] | 현재 파티 멤버 ID 목록 | `GameManager.party_members` |
| `leader` | String | 파티 리더 ID | `GameManager.party_leader` |
| `owned_characters` | PackedStringArray | 보유 중인 전체 캐릭터 | `GameManager.owned_characters` |
| `current_character` | String | 현재 선택된 캐릭터 | `GameManager.current_character` |

#### 3. Player Stats RNA — 플레이어 수치

| 키 | 타입 | 설명 | 원본 변수 |
|---|---|---|---|
| `player_name` | String | 캐릭터 이름 | `GameManager.player_name` |
| `player_hp` | int | 현재 HP | `GameManager.player_hp` |
| `player_max_hp` | int | 최대 HP | `GameManager.player_max_hp` |
| `player_mp` | int | 현재 MP | `GameManager.player_mp` |
| `player_max_mp` | int | 최대 MP | `GameManager.player_max_mp` |
| `player_attack` | int | 공격력 | `GameManager.player_attack` |
| `level` | int | 레벨 | `GameManager.level` |
| `experience` | int | 경험치 | `GameManager.experience` |

#### 4. Economy RNA — 화폐

| 키 | 타입 | 설명 | 원본 변수 |
|---|---|---|---|
| `coin` | int | 게임 내 화폐 | `GameManager.coin` |
| `gem` | int | 유료 화폐 | `GameManager.gem` |

> **참고**: `GameManager.gold`는 deprecated이며 `coin`과 동일. RNA에서는 `coin`만 사용한다.

#### 5. World RNA — 월드 및 로컬 상태

| 키 | 타입 | 설명 | 원본 변수 |
|---|---|---|---|
| `current_map` | String | 현재 맵 (레거시) | `GameManager.current_map` |
| `visited_locations` | Array[String] | 방문한 위치 목록 | `GameManager.visited_locations` |
| `location_states` | Dictionary | 맵별 로컬 RNA | `GameManager.location_states` |

`location_states`의 각 항목은 로컬 DNA와 동일한 구조:

```gdscript
location_states["bluewood_village"] = {
    "player_tile": Vector2i(11, 12),
    # 추후 확장: npc 위치, 상자 열림 여부 등
}
```

#### 6. Battle RNA — 전투 (임시, 저장하지 않음)

| 키 | 타입 | 설명 | 원본 변수 |
|---|---|---|---|
| `enemy_id` | String | 적 ID | `GameManager.enemy_id` |
| `enemy_name` | String | 적 표시 이름 | `GameManager.enemy_name` |
| `enemy_hp` | int | 적 현재 HP | `GameManager.enemy_hp` |
| `enemy_max_hp` | int | 적 최대 HP | `GameManager.enemy_max_hp` |
| `enemy_attack` | int | 적 공격력 | `GameManager.enemy_attack` |

#### 7. Flags RNA — 게임 플래그

`_flags` Dictionary를 그대로 복사. 주요 키:

| 키 | 타입 | 설명 |
|---|---|---|
| `prologue_complete` | bool | 프롤로그 완료 |
| `quest_started` | bool | 퀘스트 시작 |
| `quest_complete` | bool | 퀘스트 완료 |
| `forest_unlocked` | bool | 숲 맵 해금 |
| `temple_unlocked` | bool | 사원 맵 해금 |
| `boss_defeated` | bool | 보스 처치 |
| `wukong_unlocked` | bool | 손오공 해금 |
| `current_part` | String | 현재 파트 ID |
| `current_chapter` | String | 현재 챕터 ID |

#### 8. System RNA — 시스템/구매 상태

| 키 | 타입 | 설명 | 원본 변수 |
|---|---|---|---|
| `game_purchased` | bool | 게임 구매 여부 | `GameManager.game_purchased` |
| `save_slots` | int | 보유 저장 슬롯 수 | `GameManager.save_slots` |

### RNA ↔ DNA 변환 규칙

```
저장 시 (RNA → DNA):
  rna.flow.current_screen       → dna.world.current_screen
  rna.flow.current_location     → dna.world.current_location
  rna.flow.from_battle          → (저장하지 않음)
  rna.flow.battle_victory       → (저장하지 않음)
  rna.party.*                   → dna.party.*
  rna.player_stats.*            → dna.player_stats.*
  rna.economy.coin              → dna.inventory.coin
  rna.economy.gem               → dna.inventory.gem
  rna.world.*                   → dna.world.*
  rna.battle.*                  → (저장하지 않음)
  rna.flags.*                   → dna.flags.*
  rna.system.*                  → dna.system.*

로드 시 (DNA → RNA):
  dna.world.current_screen      → rna.flow.current_screen
  dna.world.current_location    → rna.flow.current_location
  (없음)                        → rna.flow.from_battle = false
  (없음)                        → rna.flow.battle_victory = false
  dna.party.*                   → rna.party.*
  dna.player_stats.*            → rna.player_stats.*
  dna.inventory.coin            → rna.economy.coin
  dna.inventory.gem             → rna.economy.gem
  dna.world.*                   → rna.world.*
  (없음)                        → rna.battle.* = 초기값
  dna.flags.*                   → rna.flags.*
  dna.system.*                  → rna.system.*
```

중요:

- RNA는 저장 포맷과 일대일 대응일 필요가 없다.
- 로드 어댑터가 둘 사이를 연결한다.
- Battle RNA, Flow의 임시 상태는 절대 DNA에 넣지 않는다.

---

## DNA와 RNA의 경계

저장 구조와 런타임 구조를 섞으면 업데이트 때 깨지기 쉽다.

그래서 아래 규칙을 지킨다.

### DNA에 넣을 것

- 다시 세우는 데 필요한 사실
- 장기 호환이 필요한 값
- 사람이 읽어도 의미가 통하는 값

### RNA에만 둘 것

- 현재 처리 중인 연산
- 프레임 단위 임시 상태
- UI 애니메이션 순간값
- 경로 탐색 캐시

예:

- `현재 파트가 6이다` -> DNA
- `플레이어가 현재 0.2초 동안 밀려나고 있다` -> RNA
- `상자 103을 열었다` -> DNA
- `말풍선 타이핑이 12글자까지 진행됐다` -> RNA

---

## 버전 아키텍처

버전은 최소 4개를 본다.

1. `app_version`
2. `save_format_version`
3. `content_version`
4. `localization_version`

### 1. app_version

앱 빌드 버전이다.

용도:

- 오류 리포트
- 특정 빌드 문제 추적

### 2. save_format_version

가장 중요하다.

용도:

- 저장 호환성
- 마이그레이션 시작점 판단

### 3. content_version

스토리, 밸런스, 맵 데이터 버전이다.

용도:

- 맵 구조 변경 추적
- 상자/몬스터/퀘스트 데이터 변경 추적

### 4. localization_version

번역 리소스 버전이다.

용도:

- 저장 호환성보다는 텍스트 리소스 정합성 점검

권장 판단 순서:

1. `magic` 확인
2. `save_format_version` 확인
3. 필요한 마이그레이션 적용
4. `content_version` 차이 확인
5. 앵커/맵/퀘스트 유효성 재검증
6. RNA로 적재

---

## 마이그레이션 전략

### 원칙

- 모든 저장 버전은 `현재 버전`까지 올릴 수 있어야 한다.
- 마이그레이션 함수는 `순수 변환`에 가깝게 유지한다.
- 실패 시 원본 저장은 절대 덮어쓰지 않는다.

### 권장 방식

- `migrate_v1_to_v2`
- `migrate_v2_to_v3`
- `migrate_v3_to_v4`

이런 식으로 단계별 체인을 유지한다.

### 마이그레이션에서 자주 생기는 일

- 필드명 변경
- 아이템 ID 교체
- 맵 ID 분리
- 퀘스트 상태 열거형 변경
- 팀 분리 상태 구조 추가

### 안전 규칙

- 삭제된 데이터는 가능한 기본값으로 보정
- 더 이상 존재하지 않는 맵 위치는 가장 가까운 안전 앵커로 이동
- 제거된 아이템은 대체 아이템 또는 환급값으로 치환
- 잘못된 플래그 조합은 더 보수적인 진행 상태로 되돌림

---

## 로드 파이프라인

로드는 아래 순서로 처리하는 게 안전하다.

1. 슬롯 선택
2. 헤더 읽기
3. 기본 무결성 검사
4. DNA 본문 읽기
5. 저장 포맷 버전 확인
6. 최신 버전까지 마이그레이션
7. 콘텐츠 정합성 검사
8. DNA를 RNA로 변환
9. 메인 상태에 적용
10. Explore 또는 Animation의 안전 진입점으로 복귀

중요:

- 로드 직후 바로 중간 프레임으로 복귀하려 하지 않는다.
- 항상 `안전 진입점` 개념으로 재시작한다.

---

## 저장 파이프라인

저장은 아래 순서가 안전하다.

1. 현재 RNA에서 저장 가능한 사실만 추출
2. DNA 구조로 정리
3. 현재 버전 메타 정보 추가
4. 검증
5. 임시 파일에 기록
6. 체크섬 기록
7. 성공 시 슬롯 파일 교체
8. 슬롯 미리보기 갱신

원칙:

- 부분 저장으로 기존 슬롯을 깨뜨리지 않는다.
- 항상 `임시 파일 -> 교체` 순서로 간다.

---

## 안전 진입점 설계

동유기는 `Animation -> Explore -> Battle -> Explore` 흐름이므로, 저장/로드도 중간 프레임 복원보다 안전 진입점 복원이 중요하다.

권장 규칙:

- Animation 중 저장은 기본적으로 금지
- Animation 직후 Explore 시작 지점에서 자동 저장
- Battle 중 일반 저장 금지
- Battle 패배/승리 후 결과 반영 뒤 Explore에서 저장 가능

로드 후 복귀 기준:

- 일반 슬롯: 가장 최근 Explore 안전 지점
- 자동 저장: 이벤트 종료 직후 Explore 안전 지점
- 중단 저장: 가능하면 현재 모드 복귀, 불안정하면 Explore 안전 지점

---

## 슬롯 미리보기 설계

모바일에서 슬롯은 짧게 읽혀야 한다.

표시 추천:

- 챕터/파트명
- 플레이 시간
- 저장 시각
- 현재 리더 초상
- 현재 지역명
- 간단한 진행 문구

예:

- `Part 03 꼭두장터`
- `03:42:18`
- `청목진 외곽`
- `공연 대본을 찾는 중`

이 미리보기 문구도 하드코딩이 아니라 번역 키로 관리하는 편이 안전하다.

---

## 검증 규칙

로드 전에 최소한 아래는 확인한다.

- 헤더 버전이 읽히는가
- 체크섬이 맞는가
- 맵 ID가 존재하는가
- 파티 리더가 유효한가
- 아이템 수량이 음수가 아닌가
- 퀘스트 상태가 정의된 값인가
- 팀 분리 상태와 현재 파티 구성이 모순되지 않는가

실패 시 정책:

- 가벼운 문제는 자동 보정
- 중간 문제는 경고 후 안전 복구
- 치명적 문제는 로드 차단

---

## 변경에 강한 설계 원칙

업데이트가 잦으면 특히 아래 규칙이 중요하다.

- 맵 위치는 좌표보다 `entry_anchor_id` 우선
- 퀘스트는 문자열 ID 기반
- 아이템/스킬/몬스터는 내부 ID와 표시 이름 분리
- 플래그는 숫자 인덱스 나열보다 이름 기반
- 팀 분리 상태는 처음부터 독립 구조로 보관

즉, 보이는 이름이나 문구가 바뀌어도 저장 파일은 깨지지 않아야 한다.

---

## 맵별 로컬 DNA (Local DNA)

### 개요

전역 DNA(GameManager)는 파티, 인벤토리, 퀘스트 등 게임 전체 상태를 관리하지만, **맵별 NPC 위치, 상자 열림 여부, 퍼즐 상태** 같은 로컬 데이터는 별도로 관리한다.

이유:
- 모든 맵의 NPC 위치를 전역 DNA에 저장하면 데이터 과다
- 플레이어가 방문하지 않은 맵의 데이터는 불필요
- 맵 단위로 데이터를 분리하면 메모리 효율 향상

### 저장 구조

#### 개발용 초기 데이터 (읽기 전용)
```
asset/saves/
├── part_1_init.json             # 파트 1 초기 상태 (개발용)
└── ...                          # 개발/테스트용 참조 데이터
```

#### 런타임 저장 영역 (실제 앱)
```
user://saves/
├── slot_1/
│   ├── global.json              # 전역 DNA (GameManager)
│   └── locations/
│       ├── bluewood_village.json    # 청목진 로컬 DNA
│       ├── elemental_slope.json     # 원소사면 로컬 DNA
│       └── ...                      # 방문한 맵만 생성
├── slot_2/
└── auto_save/
```

> **참고**: `asset/` 경로는 개발 중 참조용 초기 데이터이며, 실제 앱에서는 `user://` 경로에 저장/로드됩니다.

### 로컬 DNA 스키마

```json
{
    "location_id": "bluewood_village",
    "last_visit": "2026-04-08T14:30:00",
    "player": {
        "pos": [100, 100],
        "facing": "down"
    },
    "npcs": {
        "old_man": { "pos": [300, 200], "state": "talked" },
        "villager_1": { "pos": [350, 180], "state": "idle" }
    },
    "chests": {
        "hidden_chest_1": { "opened": true }
    },
    "puzzles": {
        "well_puzzle": { "solved": false }
    },
    "investigated": {
        "well": true,
        "hidden_path": false
    }
}
```

### 로컬 DNA 필드 설명

| 필드 | 타입 | 설명 |
|------|------|------|
| `location_id` | String | 맵 식별자 |
| `last_visit` | String | 마지막 방문 시각 (ISO 8601) |
| `player` | Object | 플레이어 상태 |
| `player.pos` | [x, y] | 플레이어 현재 위치 |
| `player.facing` | String | 플레이어 방향 (up, down, left, right) |
| `npcs` | Object | NPC별 상태 |
| `npcs.{id}.pos` | [x, y] | NPC 현재 위치 |
| `npcs.{id}.state` | String | NPC 상태 (idle, talked, quest_given 등) |
| `chests` | Object | 상자별 열림 여부 |
| `puzzles` | Object | 퍼즐별 해결 상태 |
| `investigated` | Object | 조사 포인트별 조사 여부 |

### 생명주기

1. **맵 진입 시**: 로컬 DNA 파일이 있으면 로드, 없으면 빈 상태로 시작
2. **맵 체류 중**: NPC 위치 변경, 상자 열기 등의 이벤트 발생 시 로컬 DNA 갱신
3. **맵 이탈 시**: 로컬 DNA 파일 저장
4. **전역 저장 시**: 현재 맵의 로컬 DNA도 함께 저장

### ExploreScreen 연동

```gdscript
# ExploreScreen에서 로컬 DNA 사용 예시
class_name ExploreScreen
extends Node2D

var _location_id: String
var _local_dna: Dictionary = {}

func setup(rna: Dictionary) -> void:
    _location_id = rna.get("current_location", "bluewood_village")
    
    # 로컬 DNA 로드
    _local_dna = LocalDnaManager.load(_location_id)
    
    # NPC 스폰: 레지스트리(기본 위치) + 로컬 DNA(현재 위치) 병합
    _spawn_npcs()
    
func _spawn_npcs() -> void:
    var spawns := LocationRegistry.get_npc_spawns(_location_id)
    
    for spawn in spawns:
        var npc := Actor.new()
        npc.setup(false, spawn.npc_id)
        
        # 로컬 DNA에 위치가 있으면 사용, 없으면 기본 위치
        if _local_dna.npcs.has(spawn.npc_id):
            npc.position = Vector2(
                _local_dna.npcs[spawn.npc_id].pos[0],
                _local_dna.npcs[spawn.npc_id].pos[1]
            )
        else:
            npc.position = spawn.position
        
        add_child(npc)

func _on_leave_location() -> void:
    # 로컬 DNA 저장
    _collect_npc_positions()
    LocalDnaManager.save(_location_id, _local_dna)
```

### LocalDnaManager 인터페이스

```gdscript
class_name LocalDnaManager
extends RefCounted

## 로컬 DNA 로드
static func load(location_id: String) -> Dictionary:
    var path := "user://saves/slot_1/locations/%s.json" % location_id
    if FileAccess.file_exists(path):
        var file := FileAccess.open(path, FileAccess.READ)
        var json := JSON.parse_string(file.get_as_text())
        if json:
            return json
    return { "location_id": location_id, "npcs": {}, "chests": {}, "puzzles": {} }

## 로컬 DNA 저장
static func save(location_id: String, data: Dictionary) -> bool:
    var dir := DirAccess.open("user://saves/slot_1")
    if not dir:
        DirAccess.make_dir_recursive_absolute("user://saves/slot_1/locations")
    
    var path := "user://saves/slot_1/locations/%s.json" % location_id
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data, "  "))
        return true
    return false

## 특정 맵의 로컬 DNA 삭제 (새 게임 등)
static func delete(location_id: String) -> void:
    var path := "user://saves/slot_1/locations/%s.json" % location_id
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)
```

### 전역 DNA vs 로컬 DNA 분리 기준

| 데이터 | 저장 위치 | 이유 |
|--------|----------|------|
| 파티 구성, 레벨, 장비 | 전역 DNA | 게임 전체 상태 |
| 인벤토리, 재화 | 전역 DNA | 게임 전체 상태 |
| 퀘스트 진행 | 전역 DNA | 게임 전체 상태 |
| 주요 플래그 | 전역 DNA | 게임 전체 상태 |
| 현재 맵 ID | 전역 DNA | 맵 로드 기준 |
| 플레이어 위치 | 로컬 DNA | 맵 단위, 맵 진입 시 복원 |
| NPC 위치 | 로컬 DNA | 맵 단위, 방문한 맵만 |
| 상자 열림 여부 | 로컬 DNA | 맵 단위 |
| 퍼즐 해결 여부 | 로컬 DNA | 맵 단위 |
| 조사 포인트 | 로컬 DNA | 맵 단위 |

---

## 동유기에 맞는 권장 결론

동유기의 저장/로드는 아래 모델로 가는 것이 가장 안전하다.

- `Profile Save`와 `Slot Save`를 분리한다.
- 모든 슬롯은 `save_format_version`을 가진다.
- `app_version`과 `content_version`은 별도로 저장한다.
- 저장 포맷 `DNA`와 런타임 상태 `RNA`를 명확히 나눈다.
- 로드는 `DNA -> Migration -> Adapter -> RNA` 순서로만 처리한다.
- 복귀는 항상 `안전 진입점` 기준으로 한다.
- **맵별 로컬 DNA를 분리하여 NPC 위치, 상자, 퍼즐 상태를 관리한다.**

이 구조면 스토리, 맵, 파티 구조가 계속 바뀌어도 저장 호환성을 관리하기가 훨씬 쉬워진다.
