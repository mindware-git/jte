class_name StoryScreen
extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# StoryScreen
# 컷신 자동 진행 화면 (명령 시퀀스 기반)
# 맵 로드, Actor 관리, 대화/카메라 연출, 터치 가속
# ═══════════════════════════════════════════════════════════════════════════════

signal finished()

# ═══════════════════════════════════════════════════════════════════════════════
# Constants
# ═══════════════════════════════════════════════════════════════════════════════

const ACTOR_SCENE := preload("res://scenes/entities/actor.tscn")

## 터치 가속 배율
const TOUCH_SPEED_MULTIPLIER := 4.0

# ═══════════════════════════════════════════════════════════════════════════════
# Variables
# ═══════════════════════════════════════════════════════════════════════════════

## RNA 데이터
var _rna: Dictionary = {}

## 컷신 데이터
var _cutscene: CutsceneData = null

## 레지스트리
var _registry: CutsceneRegistry = null

## 현재 명령 인덱스
var _command_index: int = 0

## 스폰된 Actor 맵 (actor_id → Actor)
var _actors: Dictionary = {}

## 맵 노드
var _map_node: Node2D = null

## 카메라
var _camera: Camera2D = null

## 페이드 오버레이
var _fade_overlay: CanvasLayer = null
var _fade_rect: ColorRect = null

## 터치 상태
var _is_touching: bool = false

## 속도 배율 (터치 시 가속)
var _speed_multiplier: float = 1.0

## 실행 중 여부
var _is_running: bool = false

## 대사 관련
var _dialogue_container: CanvasLayer = null
var _dialogue_panel_bg: PanelContainer = null
var _dialogue_speaker_label: Label = null
var _dialogue_text_label: Label = null
var _dialogue_waiting: bool = false

## 타이핑 상태
var _typing_full_text: String = ""
var _typing_displayed: String = ""
var _typing_char_index: int = 0
var _typing_timer: float = 0.0
var _is_typing: bool = false
var _typing_speed: float = 30.0

## 자동 진행 대기
var _auto_advance_timer: float = 0.0
var _auto_advance_delay: float = 1.5
var _waiting_for_advance: bool = false


# ═══════════════════════════════════════════════════════════════════════════════
# Setup
# ═══════════════════════════════════════════════════════════════════════════════

func setup(rna: Dictionary) -> void:
	_rna = rna

	var cutscene_id: String = rna.get("cutscene_id", "part1_opening")
	_registry = CutsceneRegistry.new()
	_cutscene = _registry.get_cutscene(cutscene_id)

	if _cutscene == null:
		push_error("StoryScreen: 컷신을 찾을 수 없음: " + cutscene_id)
		_complete_cutscene()
		return

	# 맵 배경 로드
	_load_location()

	# 카메라 설정
	_setup_camera()

	# 페이드 오버레이 설정
	_setup_fade_overlay()

	# 대사 UI 설정
	_setup_dialogue_ui()

	# 명령 실행 시작
	_command_index = 0
	_is_running = true
	_execute_next_command()

	print("StoryScreen 설정 완료: ", cutscene_id)


# ═══════════════════════════════════════════════════════════════════════════════
# Location Loading (ExploreScreen 패턴 재사용)
# ═══════════════════════════════════════════════════════════════════════════════

func _load_location() -> void:
	if _cutscene.location_id == "":
		return

	var path := "res://scenes/locations/%s.tscn" % _cutscene.location_id

	if not ResourceLoader.exists(path):
		push_error("맵 씬을 찾을 수 없음: " + path)
		return

	var scene := load(path).instantiate() as Node2D
	add_child(scene)
	_map_node = scene

	print("맵 로드 완료: ", _cutscene.location_id)


# ═══════════════════════════════════════════════════════════════════════════════
# Camera Setup
# ═══════════════════════════════════════════════════════════════════════════════

func _setup_camera() -> void:
	_camera = Camera2D.new()
	_camera.enabled = true
	add_child(_camera)


# ═══════════════════════════════════════════════════════════════════════════════
# Fade Overlay
# ═══════════════════════════════════════════════════════════════════════════════

func _setup_fade_overlay() -> void:
	_fade_overlay = CanvasLayer.new()
	_fade_overlay.layer = 20
	add_child(_fade_overlay)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 1)  # 시작할 때 검은 화면
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_overlay.add_child(_fade_rect)


# ═══════════════════════════════════════════════════════════════════════════════
# Dialogue UI (컷신 전용 하단 대사창)
# ═══════════════════════════════════════════════════════════════════════════════

func _setup_dialogue_ui() -> void:
	_dialogue_container = CanvasLayer.new()
	_dialogue_container.layer = 15
	add_child(_dialogue_container)

	# 루트 컨트롤
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dialogue_container.add_child(root)

	# 하단 대사창 패널
	_dialogue_panel_bg = PanelContainer.new()
	_dialogue_panel_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue_panel_bg.offset_top = -200
	_dialogue_panel_bg.offset_left = 50
	_dialogue_panel_bg.offset_right = -50
	_dialogue_panel_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dialogue_panel_bg.visible = false
	root.add_child(_dialogue_panel_bg)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_dialogue_panel_bg.add_child(vbox)

	# 화자 이름
	_dialogue_speaker_label = Label.new()
	_dialogue_speaker_label.add_theme_font_size_override("font_size", 22)
	_dialogue_speaker_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	vbox.add_child(_dialogue_speaker_label)

	# 대사 텍스트
	_dialogue_text_label = Label.new()
	_dialogue_text_label.add_theme_font_size_override("font_size", 18)
	_dialogue_text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_dialogue_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_dialogue_text_label.custom_minimum_size = Vector2(0, 80)
	vbox.add_child(_dialogue_text_label)


# ═══════════════════════════════════════════════════════════════════════════════
# Input Handling
# ═══════════════════════════════════════════════════════════════════════════════

func _input(event: InputEvent) -> void:
	# 터치 시작/종료
	if event is InputEventScreenTouch:
		_is_touching = event.pressed
		_speed_multiplier = TOUCH_SPEED_MULTIPLIER if _is_touching else 1.0
		if event.pressed:
			_on_touch()

	# 마우스 클릭도 지원 (에디터 테스트용)
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_is_touching = true
			_speed_multiplier = TOUCH_SPEED_MULTIPLIER
			_on_touch()
		elif not event.pressed:
			_is_touching = false
			_speed_multiplier = 1.0


func _on_touch() -> void:
	# 타이핑 중이면 즉시 완료
	if _is_typing:
		_typing_displayed = _typing_full_text
		_dialogue_text_label.text = _typing_displayed
		_typing_char_index = _typing_full_text.length()
		_finish_typing()
	# 자동 진행 대기 중이면 즉시 다음으로
	elif _waiting_for_advance:
		_waiting_for_advance = false
		_dialogue_panel_bg.visible = false
		_dialogue_waiting = false
		_execute_next_command()


# ═══════════════════════════════════════════════════════════════════════════════
# Process (타이핑 + 자동 진행)
# ═══════════════════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	if _is_typing:
		_process_typing(delta)
	elif _waiting_for_advance:
		_process_auto_advance(delta)


func _process_typing(delta: float) -> void:
	var speed := _typing_speed * _speed_multiplier
	_typing_timer += delta

	var chars_to_add := int(_typing_timer * speed)
	if chars_to_add > 0:
		_typing_timer = 0.0
		for i in range(chars_to_add):
			if _typing_char_index < _typing_full_text.length():
				_typing_displayed += _typing_full_text[_typing_char_index]
				_typing_char_index += 1
			else:
				break

		_dialogue_text_label.text = _typing_displayed

		if _typing_char_index >= _typing_full_text.length():
			_finish_typing()


func _finish_typing() -> void:
	_is_typing = false
	_waiting_for_advance = true
	_auto_advance_timer = 0.0


func _process_auto_advance(delta: float) -> void:
	var delay := _auto_advance_delay / _speed_multiplier
	_auto_advance_timer += delta

	if _auto_advance_timer >= delay:
		_waiting_for_advance = false
		_dialogue_panel_bg.visible = false
		_dialogue_waiting = false
		_execute_next_command()


# ═══════════════════════════════════════════════════════════════════════════════
# Command Execution
# ═══════════════════════════════════════════════════════════════════════════════

func _execute_next_command() -> void:
	if _cutscene == null:
		return

	if _command_index >= _cutscene.commands.size():
		_complete_cutscene()
		return

	var cmd: CutsceneCommand = _cutscene.commands[_command_index]
	_command_index += 1

	print("컷신 명령 [%d/%d]: %s" % [_command_index, _cutscene.commands.size(), CutsceneCommand.CommandType.keys()[cmd.type]])

	match cmd.type:
		CutsceneCommand.CommandType.SPAWN:
			_cmd_spawn(cmd)
		CutsceneCommand.CommandType.MOVE:
			_cmd_move(cmd)
		CutsceneCommand.CommandType.DIALOGUE:
			_cmd_dialogue(cmd)
		CutsceneCommand.CommandType.WAIT:
			_cmd_wait(cmd)
		CutsceneCommand.CommandType.ANIMATE:
			_cmd_animate(cmd)
		CutsceneCommand.CommandType.CAMERA:
			_cmd_camera(cmd)
		CutsceneCommand.CommandType.DESPAWN:
			_cmd_despawn(cmd)
		CutsceneCommand.CommandType.SET_FLAG:
			_cmd_set_flag(cmd)
		CutsceneCommand.CommandType.FADE:
			_cmd_fade(cmd)
		CutsceneCommand.CommandType.SE:
			_cmd_se(cmd)
		_:
			push_error("알 수 없는 컷신 명령: " + str(cmd.type))
			_execute_next_command()


# ── SPAWN ────────────────────────────────────────────────────────────────────

func _cmd_spawn(cmd: CutsceneCommand) -> void:
	var actor_id: String = cmd.params.get("actor_id", "")
	var character_id: String = cmd.params.get("character_id", "")
	var tile: Vector2i = cmd.params.get("tile", Vector2i.ZERO)
	var direction_str: String = cmd.params.get("direction", "down")

	# Actor 인스턴스 생성
	var actor: Actor = ACTOR_SCENE.instantiate()

	# CharacterData 조회
	var registry := CharacterRegistry.new()
	var char_data: CharacterData = registry.get_character(character_id)
	if char_data == null:
		char_data = CharacterData.new()
		char_data.id = character_id
		char_data.display_name = character_id.capitalize()

	actor.init(char_data, Actor.Role.NPC)
	actor.set_tile(tile)

	# 방향 설정
	var dir: Actor.Direction = Actor.Direction.DOWN
	match direction_str:
		"up": dir = Actor.Direction.UP
		"left": dir = Actor.Direction.LEFT
		"right": dir = Actor.Direction.RIGHT
	actor.set_direction(dir)

	add_child(actor)
	_actors[actor_id] = actor

	print("  → SPAWN: ", actor_id, " at ", tile)

	# 즉시 다음 명령
	_execute_next_command()


# ── MOVE ─────────────────────────────────────────────────────────────────────

func _cmd_move(cmd: CutsceneCommand) -> void:
	var actor_id: String = cmd.params.get("actor_id", "")
	var target_tile: Vector2i = cmd.params.get("target_tile", Vector2i.ZERO)

	var actor: Actor = _actors.get(actor_id)
	if actor == null:
		push_error("MOVE: 존재하지 않는 Actor: " + actor_id)
		_execute_next_command()
		return

	# 이동 완료 시그널 대기
	actor.movement_finished.connect(_on_move_finished, CONNECT_ONE_SHOT)
	actor.move_to_target(target_tile, true)

	print("  → MOVE: ", actor_id, " → ", target_tile)


func _on_move_finished() -> void:
	_execute_next_command()


# ── DIALOGUE ─────────────────────────────────────────────────────────────────

func _cmd_dialogue(cmd: CutsceneCommand) -> void:
	var is_simple: bool = cmd.params.get("simple", false)

	if is_simple:
		# 단순 대사 (하단 대사창)
		var speaker_id: String = cmd.params.get("speaker_id", "narration")
		var text_key: String = cmd.params.get("text_key", "")

		_show_say(speaker_id, text_key)
	else:
		# NPC 대화 (DialoguePanel 오버레이)
		var npc_id: String = cmd.params.get("npc_id", "")
		_show_dialogue_panel(npc_id)


func _show_say(speaker_id: String, text_key: String) -> void:
	# 화자 이름 설정
	_dialogue_speaker_label.text = _get_speaker_display_name(speaker_id)

	# 타이핑 시작
	_typing_full_text = tr(text_key)
	_typing_displayed = ""
	_typing_char_index = 0
	_typing_timer = 0.0
	_is_typing = true
	_dialogue_waiting = true

	_dialogue_text_label.text = ""
	_dialogue_panel_bg.visible = true

	print("  → SAY: [%s] %s" % [speaker_id, text_key])


func _show_dialogue_panel(npc_id: String) -> void:
	var dialogue_panel := DialoguePanel.new(npc_id)
	dialogue_panel.dialogue_finished.connect(_on_dialogue_panel_finished, CONNECT_ONE_SHOT)
	add_child(dialogue_panel)

	print("  → DIALOGUE: ", npc_id)


func _on_dialogue_panel_finished(_result: Dictionary) -> void:
	_execute_next_command()


func _get_speaker_display_name(speaker_id: String) -> String:
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


# ── WAIT ─────────────────────────────────────────────────────────────────────

func _cmd_wait(cmd: CutsceneCommand) -> void:
	var duration: float = cmd.params.get("duration", 1.0)
	var actual_duration := duration / _speed_multiplier

	print("  → WAIT: ", duration, "s")

	await get_tree().create_timer(actual_duration).timeout
	_execute_next_command()


# ── ANIMATE ──────────────────────────────────────────────────────────────────

func _cmd_animate(cmd: CutsceneCommand) -> void:
	var actor_id: String = cmd.params.get("actor_id", "")
	var animation_name: String = cmd.params.get("animation_name", "")

	var actor: Actor = _actors.get(actor_id)
	if actor:
		actor.play_animation(animation_name)
		print("  → ANIMATE: ", actor_id, " → ", animation_name)

	# 즉시 다음 명령
	_execute_next_command()


# ── CAMERA ───────────────────────────────────────────────────────────────────

func _cmd_camera(cmd: CutsceneCommand) -> void:
	var duration: float = cmd.params.get("duration", 1.0)
	var actual_duration := duration / _speed_multiplier

	# 카메라 추적 모드
	var follow_actor: String = cmd.params.get("follow_actor", "")
	if follow_actor != "":
		var actor: Actor = _actors.get(follow_actor)
		if actor:
			var tween := create_tween()
			tween.tween_property(_camera, "global_position", actor.global_position, actual_duration)
			await tween.finished
			print("  → CAMERA FOLLOW: ", follow_actor)
		_execute_next_command()
		return

	# 위치 이동 모드
	var target_tile: Vector2i = cmd.params.get("target_tile", Vector2i.ZERO)
	var zoom_level: float = cmd.params.get("zoom", 1.0)

	@warning_ignore("integer_division")
	var target_pos := Vector2(
		target_tile.x * GameManager.GRID_SIZE + GameManager.GRID_SIZE / 2,
		target_tile.y * GameManager.GRID_SIZE + GameManager.GRID_SIZE / 2
	)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_camera, "global_position", target_pos, actual_duration)
	tween.tween_property(_camera, "zoom", Vector2(zoom_level, zoom_level), actual_duration)
	await tween.finished

	print("  → CAMERA: tile ", target_tile, " zoom ", zoom_level)

	_execute_next_command()


# ── DESPAWN ──────────────────────────────────────────────────────────────────

func _cmd_despawn(cmd: CutsceneCommand) -> void:
	var actor_id: String = cmd.params.get("actor_id", "")

	var actor: Actor = _actors.get(actor_id)
	if actor:
		actor.queue_free()
		_actors.erase(actor_id)
		print("  → DESPAWN: ", actor_id)

	_execute_next_command()


# ── SET_FLAG ─────────────────────────────────────────────────────────────────

func _cmd_set_flag(cmd: CutsceneCommand) -> void:
	var flag_name: String = cmd.params.get("flag_name", "")
	var value: Variant = cmd.params.get("value", true)

	GameManager.set_flag(flag_name, value)
	print("  → SET_FLAG: ", flag_name, " = ", value)

	_execute_next_command()


# ── FADE ─────────────────────────────────────────────────────────────────────

func _cmd_fade(cmd: CutsceneCommand) -> void:
	var fade_type: String = cmd.params.get("fade_type", "in")
	var duration: float = cmd.params.get("duration", 1.0)
	var color: Color = cmd.params.get("color", Color.BLACK)
	var actual_duration := duration / _speed_multiplier

	if fade_type == "in":
		# 어두움 → 밝음
		_fade_rect.color = Color(color.r, color.g, color.b, 1.0)
		var tween := create_tween()
		tween.tween_property(_fade_rect, "color:a", 0.0, actual_duration)
		await tween.finished
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		# 밝음 → 어두움
		_fade_rect.color = Color(color.r, color.g, color.b, 0.0)
		var tween := create_tween()
		tween.tween_property(_fade_rect, "color:a", 1.0, actual_duration)
		await tween.finished

	print("  → FADE: ", fade_type, " (", duration, "s)")

	_execute_next_command()


# ── SE ───────────────────────────────────────────────────────────────────────

func _cmd_se(cmd: CutsceneCommand) -> void:
	var sound_id: String = cmd.params.get("sound_id", "")

	# TODO: 사운드 재생 시스템 연동
	print("  → SE: ", sound_id)

	_execute_next_command()


# ═══════════════════════════════════════════════════════════════════════════════
# Cutscene Completion
# ═══════════════════════════════════════════════════════════════════════════════

func _complete_cutscene() -> void:
	_is_running = false

	if _cutscene:
		# 종료 후 RNA 업데이트
		GameManager.current_screen = _cutscene.next_screen
		for key in _cutscene.on_complete_data:
			_rna[key] = _cutscene.on_complete_data[key]

		print("컷신 완료: ", _cutscene.id, " → ", _cutscene.next_screen)
	else:
		GameManager.current_screen = "explore"

	finished.emit()
