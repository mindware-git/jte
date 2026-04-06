# 버튼 월드 MVP 구현 계획

## 개요

환상서유기 모바일의 **버튼 기반 MVP**. 모든 상호작용은 텍스트와 버튼으로 이루어집니다.

---

## 1. 핵심 패턴

```gdscript
class_name SomeScreen extends Control

signal transition_requested(next_screen: Node)

func _ready() -> void:
    anchors_preset = Control.PRESET_FULL_RECT
    _create_ui()

func _create_ui() -> void:
    # 동적으로 UI 생성
    pass

func _on_button_pressed() -> void:
    var next := NextScreen.new()
    transition_requested.emit(next)
```

---

## 2. 화면 흐름

```
TitleScreen → StoryScreen → VillageScreen
                              ├── DialogueScreen
                              ├── ForestScreen → BattleScreen → BattleResultScreen
                              └── TempleScreen → EndingScreen
```

---

## 3. 구현 파일 목록

| 순서 | 파일 | 설명 |
|------|------|------|
| 1 | `scripts/managers/game_state.gd` | AutoLoad - 게임 상태 |
| 2 | `scripts/managers/story_flags.gd` | AutoLoad - 플래그 관리 |
| 3 | `scripts/ui/title_screen.gd` | 타이틀 화면 |
| 4 | `scripts/ui/story_screen.gd` | 오프닝 스토리 |
| 5 | `scripts/ui/village_screen.gd` | 마을 |
| 6 | `scripts/ui/dialogue_screen.gd` | 대화 시스템 |
| 7 | `scripts/ui/forest_screen.gd` | 숲 탐험 |
| 8 | `scripts/ui/battle_screen.gd` | 전투 |
| 9 | `scripts/ui/battle_result_screen.gd` | 전투 결과 |
| 10 | `scripts/ui/temple_screen.gd` | 사원 (보스) |
| 11 | `scripts/ui/ending_screen.gd` | 엔딩 |
| 12 | `scenes/prd/main.gd` 수정 | 진입점 |