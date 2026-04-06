extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# Main Entry Point
# 모든 화면은 동적으로 생성되고 교체됩니다.
# HUD는 항상 상단에 표시됩니다.
# ═══════════════════════════════════════════════════════════════════════════════

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

var _hud: CanvasLayer
var _current_screen: Control = null
var _previous_screen_name: String = ""  # 전투 후 복귀용

# HUD를 표시하지 않을 화면들
var _no_hud_screens: Array[String] = [
	"TitleScreen",
	"StoryScreen", 
	"EndingScreen",
	"BattleScreen",
	"BattleResultScreen",
	"LocationScreen",
]

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_create_hud()
	_show_title()


func _create_hud() -> void:
	_hud = HUD_SCENE.instantiate()
	_hud.save_requested.connect(_on_save_requested)
	_hud.load_requested.connect(_on_load_requested)
	_hud.quit_requested.connect(_on_quit_requested)
	_hud.shop_requested.connect(_on_shop_requested)
	add_child(_hud)


# ═══════════════════════════════════════════════════════════════════════════════
# Screen Management
# ═══════════════════════════════════════════════════════════════════════════════

func _show_title() -> void:
	var title := TitleScreen.new()
	title.transition_requested.connect(_on_transition)
	add_child(title)
	_current_screen = title
	_update_hud_visibility(title)


func _on_transition(next_screen: Node) -> void:
	# 이전 화면 이름 저장 (전투 후 복귀용)
	if _current_screen:
		var current_name: String = _current_screen.get_script().get_global_name()
		# 전투/결과 화면이 아닐 때만 저장
		if current_name != "BattleScreen" and current_name != "BattleResultScreen":
			_previous_screen_name = current_name
		_current_screen.queue_free()
	
	# 새 화면 추가
	if next_screen.has_signal("transition_requested"):
		next_screen.transition_requested.connect(_on_transition)
	if next_screen.has_signal("shop_requested"):
		next_screen.shop_requested.connect(_on_shop_requested)
	
	# BattleScreen에 복귀 화면 이름 전달
	if next_screen.get_script().get_global_name() == "BattleScreen":
		if next_screen.has_method("setup_return_screen"):
			next_screen.setup_return_screen(_previous_screen_name)
	
	add_child(next_screen)
	_current_screen = next_screen
	
	# HUD 업데이트
	_update_hud_visibility(next_screen)
	_update_hud_map(next_screen)


func _update_hud_visibility(screen: Node) -> void:
	var screen_name: String = screen.get_script().get_global_name()
	var show_hud: bool = not screen_name in _no_hud_screens
	_hud.visible = show_hud
	
	if show_hud:
		_hud.refresh()


func _update_hud_map(screen: Node) -> void:
	if not _hud.visible:
		return
	
	# 맵 이름 가져오기
	var map_name := _get_map_name(screen)
	if map_name != "":
		_hud.setup(map_name)


func _get_map_name(screen: Node) -> String:
	var screen_name: String = screen.get_script().get_global_name()
	
	match screen_name:
		"LocationScreen":
			# LocationScreen의 location_id로 맵 이름 가져오기
			if screen.has_method("get_location_name"):
				return screen.get_location_name()
			return ""
		"DialogueScreen":
			return GameManager.current_map  # 이전 맵 유지
		_:
			return ""


# ═══════════════════════════════════════════════════════════════════════════════
# HUD Signal Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_save_requested() -> void:
	var save_screen := SaveSlotScreen.new()
	save_screen.setup(SaveSlotScreen.Mode.SAVE)
	save_screen.save_done.connect(_on_save_done)
	save_screen.load_done.connect(_on_load_done)
	add_child(save_screen)


func _on_load_requested() -> void:
	var load_screen := SaveSlotScreen.new()
	load_screen.setup(SaveSlotScreen.Mode.LOAD)
	load_screen.save_done.connect(_on_save_done)
	load_screen.load_done.connect(_on_load_done)
	add_child(load_screen)


func _on_save_done(_slot_index: int) -> void:
	# 저장 완료 후 HUD 갱신
	if _hud.visible:
		_hud.refresh()


func _on_load_done(_slot_index: int) -> void:
	# 로드 완료 후 화면 재구성
	# 현재 화면 제거하고 새로운 화면 생성
	if _current_screen:
		_current_screen.queue_free()
	
	# GameManager.current_map에 따라 적절한 화면 생성
	var new_screen := create_screen_by_name(GameManager.current_map)
	if new_screen.has_signal("transition_requested"):
		new_screen.transition_requested.connect(_on_transition)
	if new_screen.has_signal("shop_requested"):
		new_screen.shop_requested.connect(_on_shop_requested)
	
	await get_tree().process_frame
	add_child(new_screen)
	_current_screen = new_screen
	
	_update_hud_visibility(new_screen)
	_update_hud_map(new_screen)


func _on_quit_requested() -> void:
	# 타이틀로 돌아가기
	if _current_screen:
		_current_screen.queue_free()
	
	GameManager.reset_state()
	_previous_screen_name = ""
	
	var title := TitleScreen.new()
	title.transition_requested.connect(_on_transition)
	add_child(title)
	_current_screen = title
	_update_hud_visibility(title)


# ═══════════════════════════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════════════════════════

func create_screen_by_name(screen_name: String) -> Control:
	# LocationScreen 사용 (location_id로 화면 생성)
	var location_screen := LocationScreen.new(screen_name)
	return location_screen


func _on_shop_requested() -> void:
	# 상점 화면을 현재 화면 위에 오버레이로 표시
	var shop := ShopScreen.new()
	shop.setup(_current_screen)
	shop.closed.connect(_on_shop_closed)
	add_child(shop)


func _on_shop_closed() -> void:
	# 상점 닫힌 후 HUD 갱신
	if _hud.visible:
		_hud.refresh()
