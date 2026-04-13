# Implementation Plan

## Overview
전투 시스템에 2단계 범위 시스템을 도입합니다. 이동은 단일 범위(effect_range)를, 공격/스킬/아이템은 이중 범위(cast_range + effect_range)를 사용합니다.

이 시스템은 플레이어가 스킬을 더 전략적으로 사용할 수 있게 합니다. 예를 들어, 3x3 효과 범위를 가진 화염구를 시전자 위치에서 3칸 떨어진 곳에 사용할 수 있습니다. 이는 기존 시스템이 효과 범위만 고려했던 것과 달리, 시전 가능한 위치와 실제 영향을 미치는 영역을 분리합니다.

## Types

### AreaPattern Enum (SkillData.gd)
기존 `SkillRangeType`을 `AreaPattern`으로 변경:
```gdscript
enum AreaPattern {
    SINGLE,      ## 단일 타겟 (1칸)
    CROSS_1,     ## 십자 1칸 (5칸)
    SQUARE_3x3,  ## 3x3 정방형 (9칸)
    LINE_3,      ## 라인 3칸
}
```

### RangeData Structure (새로운 클래스)
```gdscript
class_name RangeData
extends RefCounted

var cast_range: int = 1        ## 가용 범위 (시전 가능한 거리)
var effect_range: int = 0      ## 효과 범위 (효과 반경)
var area_pattern: AreaPattern  ## 효과 패턴
```

### ActionType Enum (BattleData.gd)
기존 유지, 범위 처리 로직만 변경

## Files

### 수정할 파일

#### `scripts/res/skill_data.gd`
- `range_type: SkillRangeType` → `area_pattern: AreaPattern`으로 변경
- `cast_range: int = 1` 추가 (가용 범위)
- `effect_range: int = 0` 추가 (효과 범위, 0이면 area_pattern만 사용)

#### `scripts/res/battle_data.gd`
- Unit 클래스에 `attack_cast_range: int = 1` 추가
- Unit 클래스에 `attack_effect_range: int = 1` 추가  
- Unit 클래스의 `attack_range: Array[Vector2i]` 제거 (동적 계산으로 대체)

#### `scripts/ui/battle_screen.gd`
- `_selected_cast_pos: Vector2i` 상태 추가 (시전 중심점)
- `_range_phase: int` 상태 추가 (0: 없음, 1: 가용범위 선택, 2: 효과범위 확인)
- `RANGE_COLOR_CAST` 상수 추가 (흰색, 가용 범위용)
- `_show_skill_range()` 수정: 가용 범위 표시
- `_show_attackable_cells()` 수정: 가용 범위 표시
- `_on_grid_cell_clicked()` 수정: 2단계 범위 처리
- `_get_area_pattern_cells()` 함수 추가: area_pattern으로부터 셀 좌표 생성

#### `scripts/res/item_data.gd` (존재하는 경우)
- `cast_range: int = 1` 추가
- `effect_range: int = 0` 추가
- `area_pattern: AreaPattern` 추가

#### `scripts/entities/battle_grid.gd`
- `show_cast_range()` 함수 추가: 가용 범위 표시용
- `show_effect_range()` 함수 추가: 효과 범위 표시용

### 새로 생성할 파일
없음 (기존 파일 수정만으로 처리)

## Functions

### 새로운 함수

#### `BattleScreen._get_area_pattern_cells(pattern: AreaPattern) -> Array[Vector2i]`
area_pattern enum으로부터 상대 좌표 배열을 반환합니다.
```gdscript
func _get_area_pattern_cells(pattern: SkillData.AreaPattern) -> Array[Vector2i]:
    match pattern:
        SkillData.AreaPattern.SINGLE:
            return [Vector2i(0, 0)]
        SkillData.AreaPattern.CROSS_1:
            return [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]
        SkillData.AreaPattern.SQUARE_3x3:
            var cells: Array[Vector2i] = []
            for dx in range(-1, 2):
                for dy in range(-1, 2):
                    cells.append(Vector2i(dx, dy))
            return cells
        SkillData.AreaPattern.LINE_3:
            return [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)]
    return [Vector2i(0, 0)]
```

#### `BattleScreen._get_cast_range_cells(cast_range: int) -> Array[Vector2i]`
가용 범위의 상대 좌표 배열을 반환합니다 (맨해튼 거리).
```gdscript
func _get_cast_range_cells(cast_range: int) -> Array[Vector2i]:
    var cells: Array[Vector2i] = []
    for x in range(-cast_range, cast_range + 1):
        for y in range(-cast_range, cast_range + 1):
            if abs(x) + abs(y) <= cast_range:
                cells.append(Vector2i(x, y))
    return cells
```

#### `BattleScreen._show_cast_range(cast_range: int)`
가용 범위를 흰색으로 표시합니다.

#### `BattleScreen._show_effect_range_at(cast_pos: Vector2i, pattern: AreaPattern, color: Color)`
지정된 위치에 효과 범위를 표시합니다.

### 수정할 함수

#### `BattleScreen._show_skill_range(skill_id: String)`
- 현재: 효과 범위만 표시
- 수정: 가용 범위(흰색) 표시, `_range_phase = 1` 설정

#### `BattleScreen._show_attackable_cells()`
- 현재: `_selected_actor.attack_range` 사용
- 수정: `_selected_actor.attack_cast_range`로 가용 범위 표시

#### `BattleScreen._on_grid_cell_clicked(grid_pos: Vector2i)`
- 현재: 즉시 confirm 창 표시
- 수정: 
  - `_range_phase == 1`이면: 효과 범위 표시 + confirm 창
  - `_range_phase == 2`이면: confirm 창만 (기존 동작)

#### `BattleScreen._show_movable_cells()`
- 현재: 그대로 유지 (이동은 단일 범위)

## Classes

### SkillData (수정)
```gdscript
class_name SkillData
extends RefCounted

enum SkillType { ATTACK, HEAL, BUFF, DEBUFF }
enum AreaPattern { SINGLE, CROSS_1, SQUARE_3x3, LINE_3 }

var id: String = ""
var name: String = ""
var description: String = ""
var type: SkillType = SkillType.ATTACK
var unlock_level: int = 1
var applicable_units: Array[String] = []

# 비용
var mp_cost: int = 10
var sg_cost: int = 0

# 범위 (새로운 2단계 시스템)
var cast_range: int = 1      # 가용 범위
var effect_range: int = 0    # 효과 범위 (0이면 area_pattern만 사용)
var area_pattern: AreaPattern = AreaPattern.SINGLE

# 효과 수치
var damage_multiplier: float = 1.0
var heal_amount: int = 0
var buff_type: String = ""
var buff_duration: int = 3
```

### BattleData.Unit (수정)
```gdscript
# 기존 attack_range 제거, 새로운 속성 추가:
var attack_cast_range: int = 1   # 기본 공격 가용 범위
var attack_effect_range: int = 1 # 기본 공격 효과 범위
```

## Dependencies

변경 없음. 기존 의존성 유지:
- GameManager (GRID_SIZE, grid_to_pixel)
- SkillRegistry
- ItemRegistry
- CharacterRegistry

## Testing

### 단위 테스트 (GUT)
`test/unit/test_battle_range_system.gd` 파일 생성:

1. `_get_area_pattern_cells()` 테스트
   - 각 AreaPattern별 올바른 좌표 반환 확인
   
2. `_get_cast_range_cells()` 테스트
   - cast_range=1, 2, 3일 때 올바른 셀 개수 확인
   - 맨해튼 거리 조건 확인

3. 범위 표시 테스트
   - 가용 범위 표시 확인
   - 효과 범위 표시 확인
   - 2단계 전환 확인

### 수동 테스트
1. 전투 진입
2. 공격 선택 → 가용 범위(흰색) 표시 확인
3. 가용 범위 셀 클릭 → 효과 범위(빨강) 표시 + confirm 창 확인
4. 스킬 선택 → 동일하게 동작 확인
5. 이동 선택 → 기존대로 동작 확인 (단일 범위)

## Implementation Order

1. **SkillData 수정** - `scripts/res/skill_data.gd`
   - SkillRangeType → AreaPattern으로 enum 이름 변경
   - `cast_range`, `effect_range`, `area_pattern` 속성 추가
   - 기존 `range_type` 참조를 `area_pattern`으로 변경

2. **BattleData.Unit 수정** - `scripts/res/battle_data.gd`
   - `attack_cast_range`, `attack_effect_range` 추가
   - `_init()`에서 기본값 설정
   - 기존 `attack_range` 관련 코드 수정

3. **TacticGrid 수정** - `scripts/entities/battle_grid.gd`
   - 필요시 범위 표시 함수 추가/수정

4. **BattleScreen 수정** - `scripts/ui/battle_screen.gd`
   - 상태 변수 추가 (`_selected_cast_pos`, `_range_phase`)
   - 상수 추가 (`RANGE_COLOR_CAST`)
   - `_get_area_pattern_cells()` 함수 추가
   - `_get_cast_range_cells()` 함수 추가
   - `_show_skill_range()` 수정
   - `_show_attackable_cells()` 수정
   - `_on_grid_cell_clicked()` 수정
   - `_get_skill_range_pattern()` → `_get_area_pattern_cells()`로 대체

5. **SkillRegistry 수정** - `scripts/res/registry/skill_registry.gd`
   - 스킬 데이터에 새로운 범위 속성 반영

6. **테스트 작성 및 실행**
   - 범위 시스템 단위 테스트
   - 수동 테스트로 전체 흐름 확인