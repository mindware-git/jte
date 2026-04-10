# Active Context - 동유기 (JTE)

## 현재 작업 포커스

현재 프로젝트는 **상점 시스템 구현 완료** 단계입니다. NPC 클릭 시 NPC 타입에 따라 상점 또는 대화가 열리는 시스템이 구현되었습니다.

## 최근 변경 사항

### 2026-04-10 상점 시스템 구현
- **ShopData 간소화**: 불필요한 필드 제거, `id`, `name_key`, `location_id`, `item_ids`만 유지
- **ShopRegistry**: `get_shop_by_location()` 함수로 위치별 상점 조회
- **BlueWoodShop**: 청목진 상점 (`bluewood_shop`), potion 1개 판매

### 2026-04-10 NPC 시스템 확장
- **NPCData 확장**: `npc_type` ("shop", "dialogue", "quest"), `shop_id` 필드 추가
- **BlueWoodShopKeeper**: 청목진 상점 주인 NPC
  - `npc_type = "shop"`, `shop_id = "bluewood_shop"`
  - `location_id = "bluewood_shop"`
- **NPCRegistry**: BlueWoodShopKeeper 등록

### 2026-04-10 ExploreScreen 수정
- **_on_npc_clicked()**: NPC 타입별 처리
  - `shop` → ShopPanel 열기
  - 기타 → 대화 시스템 (TODO)
- **_open_shop()**: ShopPanel 인스턴스 생성

### 파일 구조
```
scripts/res/
├── shop_data.gd              # 상점 데이터 (간소화)
├── npc_data.gd               # NPC 데이터 (npc_type, shop_id 추가)
└── registry/
    ├── shop_registry.gd      # 상점 레지스트리
    ├── npc_registry.gd       # NPC 레지스트리
    ├── shops/
    │   └── bluewood_shop.gd  # 청목진 상점
    └── npcs/
        └── bluewood_shop_keeper.gd  # 상점 주인 NPC

scenes/locations/
└── bluewood_shop.tscn        # 청목진 상점 씬

scripts/ui/
├── explore_screen.gd         # NPC 클릭 처리
└── shop_panel.gd             # 상점 UI
```

## 다음 단계

1. **대화 시스템 연동**
   - NPCRegistry에서 대화 데이터 조회
   - DialoguePanel 구현

2. **상점 확장**
   - 더 많은 아이템 추가
   - 다른 지역 상점 구현

3. **테스트 코드 작성**
   - ShopRegistry 테스트
   - NPCRegistry 테스트

## 활성 결정 사항

### NPC 타입
| 타입 | 설명 | 동작 |
|------|------|------|
| shop | 상점 NPC | ShopPanel 열기 |
| dialogue | 대화 NPC | 대화 시스템 연동 |
| quest | 퀘스트 NPC | 퀘스트 시스템 연동 |

### 상점 시스템 특징
- **location_id 기반**: 씬 이름과 상점 ID 매핑
- **아이템 가격**: ItemData의 `price_buy`, `price_sell` 사용
- **ShopPanel**: 구매/판매 탭, 코인 표시

### 네이밍 컨벤션
- NPC 이름: `BluewoodShopKeeper` → `to_snake_case()` → `bluewood_shop_keeper`
- 상점 ID: `bluewood_shop`
- 씬 이름: `bluewood_shop.tscn`

## 중요 패턴

### NPC 클릭 흐름
1. NPC 클릭 → `_on_npc_clicked()`
2. NPCRegistry에서 NPCData 조회
3. `npc_type` 확인
4. `shop` → `_open_shop(shop_id)`
5. ShopPanel 표시

### 상점 데이터 조회
```gdscript
var shop_registry := ShopRegistry.new()
var shop := shop_registry.get_shop_by_location("bluewood_shop")
```

### 테스트
- GUT 프레임워크 사용
- 실행: `godot --headless --path . -s addons/gut/gut_cmdln.gd`
- 현재: 42/44 통과 (SkillData 관련 2개 실패)

## 프로젝트 인사이트

- **NPC 타입 시스템**: 하나의 NPC 클래스로 다양한 역할 처리
- **Registry 패턴**: 모든 데이터는 Registry에서 관리
- **위치 기반 상점**: 씬 이름으로 상점 자동 매핑