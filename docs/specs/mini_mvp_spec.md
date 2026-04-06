# Mini MVP 스펙: 오프닝 + 손오공 만남

## 개요

동유기 1막 프롤로그의 가장 작은 구현 단위.
삼장이 손오공을 만나는 시점까지의 스토리를 데이터 기반으로 구현한다.

---

## 범위

1. 삼장이 동해 봉래산 이상 징조 전승을 듣는다
2. 오행봉으로 향하는 여정
3. 손오공 봉인 해방 (처음 만남)

---

## 데이터 구조 (Code-First Registry 패턴)

### StorySequenceData

개별 대화/연출 단위 데이터 클래스.

```gdscript
class_name StorySequenceData extends RefCounted

var speaker_id: String = "narration"  # "samjang", "sonogong", "narration"
var text: String = ""                  # 표시할 텍스트 (i18n 추후 적용)
var trigger_event: String = ""         # 완료 시 트리거 이벤트
```

### StoryRegistry

스토리 레지스트리 (Code-First). 모든 챕터와 시퀀스를 코드로 등록.

```gdscript
class_name StoryRegistry extends RefCounted

var _chapters: Dictionary = {}      # { chapter_id: Array[StorySequenceData] }
var _chapter_metadata: Dictionary = {}  # { chapter_id: { title, next_chapter } }

func _init() -> void:
    _register_all_chapters()

func _register_all_chapters() -> void:
    _register_act1_prologue()

func get_chapter(chapter_id: String) -> Array[StorySequenceData]
func get_chapter_title(chapter_id: String) -> String
func get_next_chapter(chapter_id: String) -> String
```

---

## Mini MVP 데이터

### 챕터: act1_prologue

| 순서 | 화자 | 텍스트 (한국어) |
|------|------|-----------------|
| 1 | 나레이션 | 당나라 변경, 고요한 사원. |
| 2 | 나레이션 | 젊은 승려 삼장은 오래된 전승 하나를 접한다. |
| 3 | 노승 | "동해 너머 봉래산에서 이상 징조가 일어나고 있다." |
| 4 | 노승 | "옛 길은 무너졌고, 그 길을 다시 열 수 있는 자는..." |
| 5 | 노승 | "오행봉에 봉인된 돌원숭이뿐이라 하더라." |
| 6 | 삼장 | "돌원숭이... 손오공인가요?" |
| 7 | 나레이션 | 삼장은 동쪽으로 향하는 길을 떠난다. |
| 8 | 나레이션 | 산과 폐허, 요괴의 습격을 지나... |
| 9 | 나레이션 | 마침내 오행봉에 도착한다. |
| 10 | 나레이션 | 거대한 바위 아래, 황금빛 봉인이 희미하게 빛나고 있다. |
| 11 | 삼장 | "이것이... 그 전설의..." |
| 12 | 나레이션 | 삼장이 봉인에 손을 댄 순간, |
| 13 | 나레이션 | 천지가 진동하고 바위가 갈라진다. |
| 14 | ??? | "...누가, 나를 깨웠나." |
| 15 | 나레이션 | 먼지 속에서 한 존재가 일어난다. |
| 16 | 손오공 | "네 녀석인가. 봉인을 푼 게." |
| 17 | 삼장 | "당신이... 손오공?" |
| 18 | 손오공 | "흐음... 제법이군." |
| 19 | 손오공 | "이왕 풀어놨으니, 책임은 져야지." |
| 20 | 나레이션 | 이렇게 삼장과 손오공의 여정이 시작된다. |

---

## 번역 키 구조

```
chapter.act1_prologue.title="1막 프롤로그: 운명의 만남"

speaker.samjang="삼장"
speaker.sonogong="손오공"
speaker.narration="나레이션"
speaker.old_monk="노승"

act1.prologue.001="당나라 변경, 고요한 사원."
act1.prologue.002="젊은 승려 삼장은 오래된 전승 하나를 접한다."
act1.prologue.003="동해 너머 봉래산에서 이상 징조가 일어나고 있다."
... (계속)
```

---

## 테스트 케이스

### test_story_chapter.gd

1. **test_create_chapter**
   - 챕터 생성 시 chapter_id, title_key가 올바르게 설정되는가

2. **test_chapter_sequences**
   - 시퀀스 배열이 올바르게 추가되는가
   - 시퀀스 개수가 맞는가

3. **test_sequence_speaker**
   - 각 시퀀스의 speaker_id가 올바른가

4. **test_next_chapter**
   - next_chapter_id가 올바르게 설정되는가
   - 빈 값일 때 처리

### test_story_manager.gd

1. **test_load_chapter**
   - 챕터 ID로 챕터를 로드할 수 있는가

2. **test_advance_sequence**
   - 다음 시퀀스로 진행이 되는가
   - 마지막 시퀀스에서 챕터 완료 처리

3. **test_chapter_completion**
   - 챕터 완료 시 플래그 설정
   - 다음 챕터 ID 반환

---

## 구현 파일 목록

| 순서 | 파일 | 설명 |
|------|------|------|
| 1 | `scripts/res/story_sequence_data.gd` | 시퀀스 데이터 클래스 |
| 2 | `scripts/res/registry/story_registry.gd` | 스토리 레지스트리 (Code-First) |
| 3 | `test/unit/test_story_registry.gd` | 레지스트리 테스트 |
| 4 | `scripts/ui/story_screen.gd` | UI 리팩토링 (데이터 기반) |

---

## 완료 조건

- [x] 스펙에 정의된 20개 시퀀스가 데이터로 저장됨
- [x] StoryScreen이 데이터를 읽어 시퀀스를 표시
- [x] 다음 버튼으로 시퀀스 진행
- [x] 마지막 시퀀스 후 VillageScreen으로 전환
- [x] 모든 테스트 통과 (12/12)
