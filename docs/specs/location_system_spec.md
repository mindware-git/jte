# 맵/이동 시스템 Spec

## 개요

리스트 기반 위치 탐험 시스템. Save/Load Architecture와 호환되는 DNA 구조 사용.

---

## 데이터 구조

### LocationData (DNA)

```gdscript
class_name LocationData extends RefCounted

var id: String = ""                    # "cheongmok_village"
var name_key: String = ""              # "LOC_CHEONGMOK"
var desc_key: String = ""              # "LOC_CHEONGMOK_DESC"
var connections: Array[String] = []    # 이동 가능한 위치 ID
var interactions: Array[String] = []   # 상호작용 대상 ID (npc, shop, 등)
```

### InteractionData

```gdscript
class_name InteractionData extends RefCounted

var id: String = ""                    # "tavern", "well"
var name_key: String = ""              # "INTERACT_TAVERN"
var type: String = ""                  # "npc", "shop", "investigate", "story"
var target_id: String = ""             # 연결된 대상 (NPC ID, 상점 ID, 스토리 ID)
```

---

## 레지스트리

### LocationRegistry

```gdscript
class_name LocationRegistry extends RefCounted

# 위치 조회
func get_location(location_id: String) -> LocationData
func has_location(location_id: String) -> bool
func get_all_location_ids() -> Array[String]

# 이동
func get_connections(location_id: String) -> Array[String]
func can_travel(from_id: String, to_id: String) -> bool

# 상호작용
func get_interactions(location_id: String) -> Array[InteractionData]
func get_interaction(interaction_id: String) -> InteractionData
```

---

## UI

### LocationScreen

```
┌─────────────────────────────────────┐
│ 🏘️ 청목진                           │
│ 작은 마을이 조용히 서 있다.          │
│                                     │
│ [주점] [잡화상] [우물]               │
│                                     │
│ ───────────────────────────────     │
│ 이동:                               │
│ [산길입구]                          │
└─────────────────────────────────────┘
```

#### 책임
- 현재 위치 표시 (이름, 설명)
- 상호작용 버튼 리스트
- 이동 버튼 리스트
- 버튼 클릭 시 적절한 화면으로 전환

---

## GameState 확장

```gdscript
# scripts/managers/game_state.gd (또는 game_manager.gd)

# RNA - 런타임
var current_location_id: String = "cheongmok_village"

# DNA - 저장용
func to_dna() -> Dictionary
func from_dna(data: Dictionary)
```

---

## Part 1 초기 위치

| ID | 이름 | 연결 | 상호작용 |
|----|------|------|----------|
| `cheongmok_village` | 청목진 | `mountain_entrance` | 주점, 잡화상, 우물 |
| `mountain_entrance` | 산길입구 | `cheongmok_village`, `mountain_mid` | 바위귀신 |
| `mountain_mid` | 산길중턱 | `mountain_entrance`, `shrine` | 제단 |
| `shrine` | 오행제단 | `mountain_mid`, `seal_stone` | 매화정령 |
| `seal_stone` | 봉인석 | `shrine`, `forest_entrance` | 봉인 |
| `forest_entrance` | 연등숲입구 | `seal_stone`, `forest_deep` | 화령 |
| `forest_deep` | 연등숲심부 | `forest_entrance` | 등롱 |

---

## 화면 전환 흐름

```
LocationScreen → 버튼 클릭
    ↓
이동 버튼 → current_location_id 변경 → LocationScreen 리프레시
    ↓
상호작용 버튼 → 해당 화면으로 전환
    - NPC → DialogueScreen
    - 상점 → ShopScreen
    - 조사 → StoryScreen 또는 아이템 획득
    - 전투 → BattleScreen
```

---

## 테스트 목록

1. `test_location_registry.gd`
   - 위치 조회
   - 연결된 위치 반환
   - 상호작용 조회
   - 이동 가능 여부 확인

---

## i18n 키

```
LOC_CHEONGMOK,청목진,Cheongmok Village,青木鎮,青木镇
LOC_MOUNTAIN_ENTRANCE,산길입구,Mountain Entrance,山道入口,山道入口
LOC_CHEONGMOK_DESC,"작은 마을이 조용히 서 있다.","A small village sits quietly.","小さな村が静かに佇んでいる。","小村庄静静地坐落着。"
INTERACT_TAVERN,주점,Tavern,酒場,酒馆
INTERACT_GENERAL_STORE,잡화상,General Store,雑貨屋,杂货店
INTERACT_WELL,우물,Well,井戸,水井