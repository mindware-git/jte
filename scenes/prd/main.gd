extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# Main Entry Point
# RNA 기반 Screen 생성 및 전환 관리
# ═══════════════════════════════════════════════════════════════════════════════

var _current_screen: Node2D = null

func _ready() -> void:
	_create_screen()

# ═══════════════════════════════════════════════════════════════════════════════
# Screen Management (SOLID RNA 기반)
# ═══════════════════════════════════════════════════════════════════════════════

func _create_screen() -> void:
	# 현재 화면 제거
	if _current_screen:
		_current_screen.queue_free()
		await get_tree().process_frame
	
	# RNA 기반 Screen 생성
	var screen: Node2D
	
	match GameManager.current_screen:
		"title":
			screen = TitleScreen.new()
		"explore":
			screen = ExploreScreen.new()
		"battle":
			screen = BattleScreen.new()
		# "animation":
		# 	screen = StoryScreen.new()
		# "select":
		# 	screen = SaveSlotScreen.new()
		# "ending":
		# 	screen = EndingScreen.new()
		_:
			push_error("Unknown screen: " + GameManager.current_screen)
			screen = ExploreScreen.new()
	
	# 먼저 트리에 추가 (setup에서 is_inside_tree() 체크가 필요한 경우 대비)
	add_child(screen)
	_current_screen = screen
	
	# Screen 설정
	if screen.has_method("setup"):
		screen.setup(GameManager.to_rna())
	
	if screen.has_signal("finished"):
		screen.finished.connect(_on_screen_finished)

func _on_screen_finished() -> void:
	# RNA 기반 새 화면 생성
	_create_screen()
