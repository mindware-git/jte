class_name StoryScreen
extends Control

# ═══════════════════════════════════════════════════════════════════════════════
# StoryScreen
# 스토리 화면 (타이핑 효과 + 자동 진행 + 터치 가속)
# ═══════════════════════════════════════════════════════════════════════════════

signal transition_requested(next_screen: Node)

## 표시할 챕터 ID
@export var chapter_id: String = "act1_prologue"

## 타이핑 속도 (초당 글자 수)
@export var typing_speed: float = 30.0

## 터치 중 가속 배율
@export var touch_speed_multiplier: float = 4.0

## 자동 진행 대기 시간 (초)
@export var auto_advance_delay: float = 1.5

# 스토리 데이터
var _registry: StoryRegistry
var _sequences: Array[StorySequenceData] = []
var _current_index: int = 0

# 타이핑 상태
var _full_text: String = ""
var _displayed_text: String = ""
var _char_index: int = 0
var _typing_timer: float = 0.0
var _is_typing: bool = false

# 자동 진행
var _auto_advance_timer: float = 0.0
var _waiting_for_auto_advance: bool = false

# 터치 상태
var _is_touching: bool = false

# UI 컴포넌트
var _text_label: Label
var _speaker_label: Label
var _progress_label: Label
var _touch_hint_label: Label

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	_registry = StoryRegistry.new()
	_load_chapter()
	_create_ui()
	_start_sequence()


func _process(delta: float) -> void:
	if _is_typing:
		_process_typing(delta)
	elif _waiting_for_auto_advance:
		_process_auto_advance(delta)


func _input(event: InputEvent) -> void:
	# 터치 시작
	if event is InputEventScreenTouch:
		if event.pressed:
			_is_touching = true
			_on_touch_begin()
		else:
			_is_touching = false
	
	# 마우스 클릭도 지원 (에디터 테스트용)
	if event is InputEventMouseButton:
		if event.pressed:
			_is_touching = true
			_on_touch_begin()
		else:
			_is_touching = false


# ═══════════════════════════════════════════════════════════════════════════════
# Chapter Loading
# ═══════════════════════════════════════════════════════════════════════════════

func _load_chapter() -> void:
	if _registry.has_chapter(chapter_id):
		_sequences = _registry.get_chapter(chapter_id)
	else:
		push_error("StoryScreen: 챕터를 찾을 수 없음: " + chapter_id)
		_sequences = []


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.05)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 대화 박스
	var dialogue_box := PanelContainer.new()
	dialogue_box.position = Vector2(100, 400)
	dialogue_box.size = Vector2(1080, 200)
	add_child(dialogue_box)
	
	var content := VBoxContainer.new()
	dialogue_box.add_child(content)
	
	# 화자 이름
	_speaker_label = Label.new()
	_speaker_label.text = "나레이션"
	_speaker_label.add_theme_font_size_override("font_size", 18)
	_speaker_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	content.add_child(_speaker_label)
	
	# 간격
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	content.add_child(spacer)
	
	# 대화 텍스트
	_text_label = Label.new()
	_text_label.text = ""
	_text_label.add_theme_font_size_override("font_size", 20)
	_text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	content.add_child(_text_label)
	
	# 진행 표시
	_progress_label = Label.new()
	_progress_label.text = "[1/1]"
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_progress_label.position = Vector2(1100, 610)
	_progress_label.add_theme_font_size_override("font_size", 14)
	_progress_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	add_child(_progress_label)
	
	# 터치 힌트
	_touch_hint_label = Label.new()
	_touch_hint_label.text = "터치하여 빠르게 진행"
	_touch_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_touch_hint_label.position = Vector2(480, 650)
	_touch_hint_label.add_theme_font_size_override("font_size", 14)
	_touch_hint_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	add_child(_touch_hint_label)


# ═══════════════════════════════════════════════════════════════════════════════
# Sequence Management
# ═══════════════════════════════════════════════════════════════════════════════

func _start_sequence() -> void:
	if _current_index >= _sequences.size():
		return
	
	var seq: StorySequenceData = _sequences[_current_index]
	_speaker_label.text = _get_speaker_display_name(seq.speaker_id)
	_full_text = tr(seq.text_key)
	_progress_label.text = "[%d/%d]" % [_current_index + 1, _sequences.size()]
	
	# 타이핑 시작
	_char_index = 0
	_displayed_text = ""
	_text_label.text = ""
	_is_typing = true
	_waiting_for_auto_advance = false
	
	# 마지막 시퀀스면 힌트 변경
	if _current_index == _sequences.size() - 1:
		_touch_hint_label.text = tr("UI_TOUCH_START")
	else:
		_touch_hint_label.text = tr("UI_TOUCH_HINT")


func _get_speaker_display_name(speaker_id: String) -> String:
	# 화자 이름도 번역 키 사용
	match speaker_id:
		"narration":
			return tr("SPEAKER_NARRATION")
		"sanzang":
			return tr("SPEAKER_SANZANG")
		"wukong":
			return tr("SPEAKER_WUKONG")
		"old_monk":
			return tr("SPEAKER_OLD_MONK")
		"unknown":
			return tr("SPEAKER_UNKNOWN")
		_:
			return speaker_id


func _process_typing(delta: float) -> void:
	# 타이핑 속도 계산 (터치 중이면 가속)
	var speed := typing_speed
	if _is_touching:
		speed *= touch_speed_multiplier
	
	# 타이핑 타이머 업데이트
	_typing_timer += delta
	var chars_to_add := int(_typing_timer * speed)
	
	if chars_to_add > 0:
		_typing_timer = 0.0
		
		for i in range(chars_to_add):
			if _char_index < _full_text.length():
				_displayed_text += _full_text[_char_index]
				_char_index += 1
			else:
				break
		
		_text_label.text = _displayed_text
		
		# 타이핑 완료 체크
		if _char_index >= _full_text.length():
			_on_typing_complete()


func _on_typing_complete() -> void:
	_is_typing = false
	
	# 이벤트 트리거 처리
	if _current_index < _sequences.size():
		var seq: StorySequenceData = _sequences[_current_index]
		if seq.trigger_event != "":
			_handle_event(seq.trigger_event)
	
	# 마지막 시퀀스가 아니면 자동 진행 대기
	if _current_index < _sequences.size() - 1:
		_waiting_for_auto_advance = true
		_auto_advance_timer = 0.0
	else:
		# 마지막 시퀀스면 터치 대기
		_touch_hint_label.visible = true


func _process_auto_advance(delta: float) -> void:
	# 터치 중이면 가속
	var delay := auto_advance_delay
	if _is_touching:
		delay /= touch_speed_multiplier
	
	_auto_advance_timer += delta
	
	if _auto_advance_timer >= delay:
		_waiting_for_auto_advance = false
		_advance_to_next()


func _advance_to_next() -> void:
	_current_index += 1
	
	if _current_index >= _sequences.size():
		_on_chapter_complete()
	else:
		_start_sequence()


# ═══════════════════════════════════════════════════════════════════════════════
# Touch Handling
# ═══════════════════════════════════════════════════════════════════════════════

func _on_touch_begin() -> void:
	if _is_typing:
		# 타이핑 중이면 즉시 완료
		_displayed_text = _full_text
		_text_label.text = _displayed_text
		_char_index = _full_text.length()
		_on_typing_complete()
	elif _waiting_for_auto_advance:
		# 자동 진행 대기 중이면 즉시 다음으로
		_waiting_for_auto_advance = false
		_advance_to_next()
	elif not _is_typing and not _waiting_for_auto_advance:
		# 마지막 시퀀스에서 대기 중이면 완료
		if _current_index >= _sequences.size() - 1:
			_advance_to_next()


# ═══════════════════════════════════════════════════════════════════════════════
# Chapter Completion
# ═══════════════════════════════════════════════════════════════════════════════

func _on_chapter_complete() -> void:
	GameManager.complete_prologue()
	
	# 다음 챕터 확인
	var next_chapter := _registry.get_next_chapter(chapter_id)
	if next_chapter != "":
		var next_screen := StoryScreen.new()
		next_screen.chapter_id = next_chapter
		transition_requested.emit(next_screen)
	else:
		var village := VillageScreen.new()
		transition_requested.emit(village)


# ═══════════════════════════════════════════════════════════════════════════════
# Event Handling
# ═══════════════════════════════════════════════════════════════════════════════

func _handle_event(event_id: String) -> void:
	match event_id:
		"unlock_wukong":
			GameManager.set_flag("wukong_unlocked", true)
		_:
			pass
