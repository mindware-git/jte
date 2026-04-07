class_name BattleGrid
extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# BattleGrid
# 전투용 그리드 시스템 (64x64 칸)
# ═══════════════════════════════════════════════════════════════════════════════

signal cell_clicked(grid_pos: Vector2i)

# 그리드 설정
const CELL_SIZE := 64
const GRID_WIDTH := 16  # 1024px
const GRID_HEIGHT := 9  # 576px

# 칸 노드들
var _cells: Dictionary = {}  # Vector2i -> BattleGridCell
var _movable_cells: Array[Vector2i] = []
var _selected_cell: Vector2i = Vector2i(-1, -1)

# ═══════════════════════════════════════════════════════════════════════════════
# Initialization
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_create_grid()


func _create_grid() -> void:
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var grid_pos := Vector2i(x, y)
			var cell := _create_cell(grid_pos)
			_cells[grid_pos] = cell
			add_child(cell)


func _create_cell(grid_pos: Vector2i) -> Control:
	var cell := Control.new()
	cell.name = "Cell_%d_%d" % [grid_pos.x, grid_pos.y]
	
	# 위치 설정
	var pixel_pos := grid_to_pixel(grid_pos)
	cell.position = pixel_pos
	cell.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
	
	# 색상 사각형 (기본 투명)
	var rect := ColorRect.new()
	rect.color = Color(1, 1, 1, 0)  # 투명
	rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	cell.add_child(rect)
	rect.name = "Background"
	
	# 클릭 영역
	var button := Button.new()
	button.flat = true
	button.size = Vector2(CELL_SIZE, CELL_SIZE)
	button.modulate = Color(1, 1, 1, 0)  # 투명
	button.pressed.connect(_on_cell_pressed.bind(grid_pos))
	cell.add_child(button)
	button.name = "Button"
	
	return cell


# ═══════════════════════════════════════════════════════════════════════════════
# Coordinate Conversion
# ═══════════════════════════════════════════════════════════════════════════════

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)


func pixel_to_grid(pixel_pos: Vector2) -> Vector2i:
	return Vector2i(int(pixel_pos.x / CELL_SIZE), int(pixel_pos.y / CELL_SIZE))


# ═══════════════════════════════════════════════════════════════════════════════
# Movable Cells
# ═══════════════════════════════════════════════════════════════════════════════

## 이동 가능한 칸 표시
func show_movable_cells(from_pos: Vector2i, move_range: int, occupied: Array[Vector2i]) -> void:
	clear_highlights()
	
	_movable_cells = _get_movable_cells(from_pos, move_range, occupied)
	
	for grid_pos in _movable_cells:
		_set_cell_color(grid_pos, Color(1, 1, 1, 0.3))  # 흰색 반투명


## 범위 칸 표시 (공통 함수)
func show_range_cells(center: Vector2i, range_pattern: Array[Vector2i], occupied: Array[Vector2i] = []) -> void:
	clear_highlights()
	
	_movable_cells.clear()
	
	for offset in range_pattern:
		var grid_pos := center + offset
		
		# 그리드 범위 체크
		if not _is_valid_grid_pos(grid_pos):
			continue
		
		# 점유 체크 (모든 캐릭터)
		var is_occupied := false
		for occ_pos in occupied:
			if grid_pos == occ_pos:
				is_occupied = true
				break
		
		# 점유된 칸은 표시하지 않음
		if is_occupied:
			continue
		
		_movable_cells.append(grid_pos)
		_set_cell_color(grid_pos, Color(1, 0.5, 0.5, 0.3))  # 빨간색 반투명 (공격 범위)


## 이동 가능한 칸 계산
func _get_movable_cells(from_pos: Vector2i, move_range: int, occupied: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	
	for dy in range(-move_range, move_range + 1):
		for dx in range(-move_range, move_range + 1):
			if dx == 0 and dy == 0:
				continue
			
			var check_pos := Vector2i(from_pos.x + dx, from_pos.y + dy)
			
			# 그리드 범위 체크
			if not _is_valid_grid_pos(check_pos):
				continue
			
			# 맨해튼 거리 체크
			if absi(dx) + absi(dy) > move_range:
				continue
			
			# 점유 체크
			if check_pos in occupied:
				continue
			
			result.append(check_pos)
	
	return result


func _is_valid_grid_pos(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and \
		   grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT


# ═══════════════════════════════════════════════════════════════════════════════
# Selection
# ═══════════════════════════════════════════════════════════════════════════════

## 칸 선택 (파란색으로 변경)
func select_cell(grid_pos: Vector2i) -> bool:
	if grid_pos not in _movable_cells:
		return false
	
	# 이전 선택 해제
	if _selected_cell != Vector2i(-1, -1):
		_set_cell_color(_selected_cell, Color(1, 1, 1, 0.3))  # 흰색으로 복원
	
	# 새 선택
	_selected_cell = grid_pos
	_set_cell_color(grid_pos, Color(0.3, 0.5, 1, 0.5))  # 파란색
	
	return true


## 선택된 칸 반환
func get_selected_cell() -> Vector2i:
	return _selected_cell


## 선택 해제
func clear_selection() -> void:
	if _selected_cell != Vector2i(-1, -1):
		if _selected_cell in _movable_cells:
			_set_cell_color(_selected_cell, Color(1, 1, 1, 0.3))
		else:
			_set_cell_color(_selected_cell, Color(1, 1, 1, 0))
	_selected_cell = Vector2i(-1, -1)


## 모든 하이라이트 제거
func clear_highlights() -> void:
	for grid_pos in _movable_cells:
		_set_cell_color(grid_pos, Color(1, 1, 1, 0))
	_movable_cells.clear()
	clear_selection()


## 이동 가능한 칸에 있는지 확인
func is_movable_cell(grid_pos: Vector2i) -> bool:
	return grid_pos in _movable_cells


# ═══════════════════════════════════════════════════════════════════════════════
# Cell Appearance
# ═══════════════════════════════════════════════════════════════════════════════

func _set_cell_color(grid_pos: Vector2i, color: Color) -> void:
	if not _cells.has(grid_pos):
		return
	
	var cell: Control = _cells[grid_pos]
	var bg: ColorRect = cell.get_node_or_null("Background")
	if bg:
		bg.color = color


# ═══════════════════════════════════════════════════════════════════════════════
# Input Handling
# ═══════════════════════════════════════════════════════════════════════════════

func _on_cell_pressed(grid_pos: Vector2i) -> void:
	cell_clicked.emit(grid_pos)