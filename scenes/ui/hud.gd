extends CanvasLayer

# ═══════════════════════════════════════════════════════════════════════════════
# HUD - 상단 상태 바
# 모든 게임 화면에서 사용되는 공통 HUD
# ═══════════════════════════════════════════════════════════════════════════════

signal save_requested()
signal load_requested()
signal quit_requested()
signal shop_requested()

var _map_name: String = ""
var _status_label: Label
var _settings_popup: Control
var _settings_btn: Button

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	layer = 10
	_create_ui()


func _create_ui() -> void:
	# 메인 컨테이너
	var container := Control.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	
	# 상단 바
	var top_bar := PanelContainer.new()
	top_bar.position = Vector2(0, 0)
	top_bar.size = Vector2(1280, 50)
	top_bar.anchor_right = 1.0
	container.add_child(top_bar)
	
	var bar_content := HBoxContainer.new()
	bar_content.add_theme_constant_override("separation", 15)
	top_bar.add_child(bar_content)
	
	# 설정 버튼 (기어)
	_settings_btn = Button.new()
	_settings_btn.text = "⚙️"
	_settings_btn.custom_minimum_size = Vector2(50, 40)
	_settings_btn.add_theme_font_size_override("font_size", 20)
	_settings_btn.pressed.connect(_on_settings_pressed)
	bar_content.add_child(_settings_btn)
	
	# 상태 라벨
	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 16)
	_status_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_content.add_child(_status_label)
	
	# 설정 팝업 (기본 숨김)
	_create_settings_popup(container)


func _create_settings_popup(parent: Control) -> void:
	_settings_popup = PanelContainer.new()
	_settings_popup.position = Vector2(10, 55)
	_settings_popup.size = Vector2(180, 200)
	_settings_popup.visible = false
	parent.add_child(_settings_popup)
	
	var content := VBoxContainer.new()
	_settings_popup.add_child(content)
	
	# 타이틀
	var title := Label.new()
	title.text = "설정"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	content.add_child(title)
	
	# 구분선
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	content.add_child(spacer)
	
	# 상점 버튼
	var shop_btn := Button.new()
	shop_btn.text = "🛒 상점"
	shop_btn.custom_minimum_size = Vector2(160, 40)
	shop_btn.pressed.connect(_on_shop_pressed)
	content.add_child(shop_btn)
	
	# 불러오기 버튼
	var load_btn := Button.new()
	load_btn.text = "📂 불러오기"
	load_btn.custom_minimum_size = Vector2(160, 40)
	load_btn.pressed.connect(_on_load_pressed)
	content.add_child(load_btn)
	
	# 저장하기 버튼
	var save_btn := Button.new()
	save_btn.text = "💾 저장하기"
	save_btn.custom_minimum_size = Vector2(160, 40)
	save_btn.pressed.connect(_on_save_pressed)
	content.add_child(save_btn)
	
	# 종료 버튼
	var quit_btn := Button.new()
	quit_btn.text = "🚪 종료"
	quit_btn.custom_minimum_size = Vector2(160, 40)
	quit_btn.pressed.connect(_on_quit_pressed)
	content.add_child(quit_btn)


# ═══════════════════════════════════════════════════════════════════════════════
# Public API
# ═══════════════════════════════════════════════════════════════════════════════

func setup(map_name: String) -> void:
	_map_name = map_name
	_update_status()


func _update_status() -> void:
	_status_label.text = "🗺️ %s | %s | Lv.%d | ❤️ %d/%d | 💙 %d/%d | 💰 %d" % [
		_map_name,
		GameManager.player_name,
		GameManager.level,
		GameManager.player_hp, GameManager.player_max_hp,
		GameManager.player_mp, GameManager.player_max_mp,
		GameManager.gold
	]


func refresh() -> void:
	_update_status()


func hide_settings() -> void:
	_settings_popup.visible = false


# ═══════════════════════════════════════════════════════════════════════════════
# Signal Handlers
# ═══════════════════════════════════════════════════════════════════════════════

func _on_settings_pressed() -> void:
	_settings_popup.visible = not _settings_popup.visible


func _on_load_pressed() -> void:
	_settings_popup.visible = false
	load_requested.emit()


func _on_save_pressed() -> void:
	_settings_popup.visible = false
	save_requested.emit()


func _on_quit_pressed() -> void:
	_settings_popup.visible = false
	quit_requested.emit()


func _on_shop_pressed() -> void:
	_settings_popup.visible = false
	shop_requested.emit()
