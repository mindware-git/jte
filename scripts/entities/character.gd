class_name Character
extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# Character
# 기본 캐릭터 노드 (64x128 크기, 하단 64x64 클릭 영역)
# 탐험/전투 공통 기본 클래스
# ═══════════════════════════════════════════════════════════════════════════════

# 시그널
signal clicked(character: Character)

# 데이터
var _data: CharacterData = null

# 컴포넌트
var _sprite: Sprite2D = null
var _click_area: Area2D = null
var _collision_shape: CollisionShape2D = null
var _name_label: Label = null

# 캐릭터 크기
const SPRITE_SIZE := Vector2i(64, 128)
const COLLISION_SIZE := Vector2i(64, 64)  # 하단 클릭 영역

# ═══════════════════════════════════════════════════════════════════════════════
# Properties
# ═══════════════════════════════════════════════════════════════════════════════

var character_data: CharacterData:
	get: return _data

var display_name: String:
	get: return _data.display_name if _data else ""

# ═══════════════════════════════════════════════════════════════════════════════
# Initialization
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# init() 호출 후 동작
	pass


## 캐릭터 초기화
func init(data: CharacterData) -> void:
	_data = data
	_setup_sprite()
	_setup_click_area()
	_setup_name_label()


# ═══════════════════════════════════════════════════════════════════════════════
# Setup Methods
# ═══════════════════════════════════════════════════════════════════════════════

func _setup_sprite() -> void:
	_sprite = Sprite2D.new()
	
	# 텍스처 로드 (캐릭터 ID 기반)
	var texture_path := _get_texture_path()
	if ResourceLoader.exists(texture_path):
		_sprite.texture = load(texture_path)
	else:
		# 기본 텍스처 없으면 색상 박스로 대체
		_sprite.texture = _create_default_texture()
	
	# 중앙 정렬 (하단이 y=0)
	_sprite.offset = Vector2(0, -SPRITE_SIZE.y / 2)
	
	add_child(_sprite)


func _get_texture_path() -> String:
	if _data == null:
		return ""
	return "res://asset/Texture/Characters/%s.png" % _data.id


func _create_default_texture() -> ImageTexture:
	var image := Image.create(SPRITE_SIZE.x, SPRITE_SIZE.y, false, Image.FORMAT_RGBA8)
	var color := _get_element_color()
	image.fill(color)
	
	var texture := ImageTexture.create_from_image(image)
	return texture


func _get_element_color() -> Color:
	if _data == null:
		return Color.GRAY
	
	# GameManager.ElementType에 따라 색상 반환
	# TODO: CharacterData에 element 타입에 맞게 수정
	return Color(0.5, 0.7, 0.9)  # 기본 파랑


func _setup_click_area() -> void:
	_click_area = Area2D.new()
	_click_area.position = Vector2(0, -COLLISION_SIZE.y / 2)  # 하단에 위치
	
	# 충돌 모양 (하단 64x64)
	_collision_shape = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = COLLISION_SIZE
	_collision_shape.shape = shape
	_click_area.add_child(_collision_shape)
	
	# 클릭 시그널 연결
	_click_area.input_event.connect(_on_click_area_input)
	
	add_child(_click_area)


func _setup_name_label() -> void:
	_name_label = Label.new()
	_name_label.text = display_name
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.position = Vector2(-SPRITE_SIZE.x / 2, -SPRITE_SIZE.y - 20)
	_name_label.size = Vector2(SPRITE_SIZE.x, 20)
	_name_label.add_theme_font_size_override("font_size", 12)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_name_label.add_theme_constant_override("outline_size", 2)
	
	add_child(_name_label)


# ═══════════════════════════════════════════════════════════════════════════════
# Input Handling
# ═══════════════════════════════════════════════════════════════════════════════

func _on_click_area_input(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
		viewport.set_input_as_handled()


# ═══════════════════════════════════════════════════════════════════════════════
# Utility
# ═══════════════════════════════════════════════════════════════════════════════

## 스프라이트 텍스처 설정
func set_sprite_texture(texture: Texture2D) -> void:
	if _sprite:
		_sprite.texture = texture


## 클릭 가능 여부 설정
func set_clickable(enabled: bool) -> void:
	if _click_area:
		_click_area.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED


## 이름 표시 여부 설정
func set_name_visible(visible: bool) -> void:
	if _name_label:
		_name_label.visible = visible