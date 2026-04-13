class_name TacticGrid
extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# TacticGrid
# 전투용 그리드 시스템 (64x64 칸)
# ═══════════════════════════════════════════════════════════════════════════════

signal cell_clicked(grid_pos: Vector2i)

# 그리드 설정
const CELL_SIZE := 64
const GRID_WIDTH := 16  # 1024px
const GRID_HEIGHT := 9  # 576px

# 칸 노드들
var _cells: Dictionary = {}  # Vector2i -> TacticGridCell
var _movable_cells: Array[Vector2i] = []
var _selected_cell: Vector2i = Vector2i(-1, -1)

# A* 경로 탐색
var _astar: AStarGrid2D = null

# ═══════════════════════════════════════════════════════════════════════════════
# Initialization
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_setup_astar()
	_create_grid()


func _setup_astar() -> void:
	_astar = AStarGrid2D.new()
	_astar.region = Rect2i(0, 0, GRID_WIDTH, GRID_HEIGHT)
	_astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER  # 4방향만
	_astar.update()


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
	
	# 위치 설정: 셀 중심 기준 (grid_to_pixel이 중심 반환)
	var pixel_pos := grid_to_pixel(grid_pos)
	cell.position = pixel_pos - Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
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
# Coordinate Conversion (GameManager 위임)
# ═══════════════════════════════════════════════════════════════════════════════

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	return GameManager.grid_to_pixel(grid_pos)


func pixel_to_grid(pixel_pos: Vector2) -> Vector2i:
	return GameManager.pixel_to_grid(pixel_pos)


# ═══════════════════════════════════════════════════════════════════════════════
# Range Display (2단계 범위 시스템)
# ═══════════════════════════════════════════════════════════════════════════════

## 가용 범위 표시 (흰색)
func show_cast_range(from_pos: Vector2i, cast_range: int, occupied: Array[Vector2i] = []) -> void:
	clear_highlights()
	
	if cast_range == 0:
		# cast_range=0이면 본인 위치만
		_movable_cells = [from_pos]
		_set_cell_color(from_pos, Color(1, 1, 1, 0.3))
	else:
		# 맨해튼 거리 기반 가용 범위
		for x in range(-cast_range, cast_range + 1):
			for y in range(-cast_range, cast_range + 1):
				var dist := absi(x) + absi(y)
				if dist <= cast_range:
					var grid_pos := Vector2i(from_pos.x + x, from_pos.y + y)
					if _is_valid_grid_pos(grid_pos) and grid_pos not in occupied:
						_movable_cells.append(grid_pos)
						_set_cell_color(grid_pos, Color(1, 1, 1, 0.3))


## 효과 범위 표시 (빨간색/녹색)
func show_effect_range(center: Vector2i, area_pattern, highlight_color: Color = Color(1, 0.3, 0.3, 0.3)) -> void:
	# 기존 표시 유지하면서 효과 범위 추가
	var effect_cells := _get_area_pattern_cells(center, area_pattern)
	
	for grid_pos in effect_cells:
		if _is_valid_grid_pos(grid_pos):
			_set_cell_color(grid_pos, highlight_color)


## AreaPattern으로부터 셀 목록 생성
func _get_area_pattern_cells(center: Vector2i, area_pattern) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	
	# area_pattern이 Array면 직접 사용 (이동 범위 등)
	if area_pattern is Array:
		for offset in area_pattern:
			cells.append(Vector2i(center.x + offset.x, center.y + offset.y))
		return cells
	
	# SkillData.AreaPattern enum 처리
	var pattern_type = area_pattern
	match pattern_type:
		0:  # SINGLE
			cells.append(center)
		1:  # CROSS_1
			cells.append_array([
				Vector2i(center.x, center.y - 1),
				Vector2i(center.x - 1, center.y),
				center,
				Vector2i(center.x + 1, center.y),
				Vector2i(center.x, center.y + 1)
			])
		2:  # SQUARE_3x3
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					cells.append(Vector2i(center.x + dx, center.y + dy))
		3:  # LINE_3
			cells.append_array([
				Vector2i(center.x, center.y - 1),
				center,
				Vector2i(center.x, center.y + 1)
			])
		_:
			cells.append(center)
	
	return cells


## 이동 가능한 칸 표시 (기존 호환성 유지)
func show_movable_cells(from_pos: Vector2i, move_range: int, occupied: Array[Vector2i]) -> void:
	clear_highlights()
	
	_movable_cells = _get_movable_cells(from_pos, move_range, occupied)
	
	for grid_pos in _movable_cells:
		_set_cell_color(grid_pos, Color(1, 1, 1, 0.3))  # 흰색 반투명


## 범위 칸 표시 (공통 함수, 색상 지정 가능)
func show_range_cells(center: Vector2i, range_pattern: Array[Vector2i], occupied: Array[Vector2i] = [], highlight_color: Color = Color(1, 0.5, 0.5, 0.3)) -> void:
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
		_set_cell_color(grid_pos, highlight_color)


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


# ═══════════════════════════════════════════════════════════════════════════════
# A* Pathfinding
# ═══════════════════════════════════════════════════════════════════════════════

## 점유 상태 업데이트
func update_occupied(occupied: Array[Vector2i]) -> void:
	if _astar == null:
		return
	
	# 모든 칸 초기화
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			_astar.set_point_solid(Vector2i(x, y), false)
	
	# 점유된 칸 설정
	for pos in occupied:
		if _is_valid_grid_pos(pos):
			_astar.set_point_solid(pos, true)


## 경로 기반 이동 가능 칸 계산 (A* 사용)
func get_reachable_cells(from_pos: Vector2i, move_range: int, occupied: Array[Vector2i]) -> Array[Vector2i]:
	# from_pos(이동하는 캐릭터 위치)를 제외한 점유 목록으로 업데이트
	var filtered_occupied: Array[Vector2i] = []
	for pos in occupied:
		if pos != from_pos:
			filtered_occupied.append(pos)
	update_occupied(filtered_occupied)
	
	var reachable: Array[Vector2i] = []
	
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var target := Vector2i(x, y)
			if target == from_pos:
				continue
			
			# A* 경로 탐색
			var path := _astar.get_id_path(from_pos, target)
			
			# 경로가 존재하고, 길이가 move_range 이하인 경우
			# path는 [from_pos, ..., target] 형태이므로 실제 이동 칸 수는 path.size() - 1
			if path.size() > 1 and path.size() - 1 <= move_range:
				reachable.append(target)
	
	return reachable


## 이동 경로 반환 (애니메이션용)
func get_move_path(from_pos: Vector2i, to_pos: Vector2i) -> Array[Vector2i]:
	if _astar == null:
		return []
	
	return _astar.get_id_path(from_pos, to_pos)


## A* 기반 이동 가능한 칸 표시
func show_reachable_cells(from_pos: Vector2i, move_range: int, occupied: Array[Vector2i]) -> void:
	clear_highlights()
	
	_movable_cells = get_reachable_cells(from_pos, move_range, occupied)
	
	for grid_pos in _movable_cells:
		_set_cell_color(grid_pos, Color(1, 1, 1, 0.3))  # 흰색 반투명
