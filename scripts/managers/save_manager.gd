extends Node

# ═══════════════════════════════════════════════════════════════════════════════
# SaveManager - AutoLoad
# 로컬 저장/로드 관리
# ═══════════════════════════════════════════════════════════════════════════════

signal save_completed(slot_index: int, success: bool)
signal load_completed(slot_index: int, success: bool)

const SAVE_DIR := "user://saves/"
const SAVE_FILE_PREFIX := "slot_"
const SAVE_FILE_EXT := ".json"
const LOCATIONS_DIR := "locations/"

# ═══════════════════════════════════════════════════════════════════════════════
# Lifecycle
# ═══════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_ensure_save_directory()


func _ensure_save_directory() -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")


func _ensure_locations_directory(slot_index: int) -> void:
	var dir_path := SAVE_DIR + SAVE_FILE_PREFIX + str(slot_index) + "/" + LOCATIONS_DIR
	DirAccess.make_dir_recursive_absolute(dir_path)

# ═══════════════════════════════════════════════════════════════════════════════
# Save Operations
# ═══════════════════════════════════════════════════════════════════════════════

func save_game(slot_index: int) -> bool:
	var data := SaveData.create_from_game_manager(slot_index)
	var file_path := _get_save_file_path(slot_index)
	
	var json_string := JSON.stringify(data.to_dict(), "  ")
	
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("저장 실패: %s" % FileAccess.get_open_error())
		save_completed.emit(slot_index, false)
		return false
	
	file.store_string(json_string)
	file.close()
	
	print("저장 완료: 슬롯 %d" % (slot_index + 1))
	save_completed.emit(slot_index, true)
	return true


func load_game(slot_index: int) -> bool:
	var file_path := _get_save_file_path(slot_index)
	
	if not FileAccess.file_exists(file_path):
		push_error("저장 파일 없음: 슬롯 %d" % (slot_index + 1))
		load_completed.emit(slot_index, false)
		return false
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("로드 실패: %s" % FileAccess.get_open_error())
		load_completed.emit(slot_index, false)
		return false
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("JSON 파싱 실패: %s" % json.get_error_message())
		load_completed.emit(slot_index, false)
		return false
	
	var data := SaveData.new()
	data.from_dict(json.data)
	data.apply_to_game_manager()
	
	print("로드 완료: 슬롯 %d" % (slot_index + 1))
	load_completed.emit(slot_index, true)
	return true


func delete_slot(slot_index: int) -> bool:
	var file_path := _get_save_file_path(slot_index)
	
	if not FileAccess.file_exists(file_path):
		return false
	
	var dir := DirAccess.open(SAVE_DIR)
	if dir and dir.remove(file_path) == OK:
		print("슬롯 삭제 완료: %d" % (slot_index + 1))
		return true
	
	return false


# ═══════════════════════════════════════════════════════════════════════════════
# Query Operations
# ═══════════════════════════════════════════════════════════════════════════════

func has_slot_data(slot_index: int) -> bool:
	return FileAccess.file_exists(_get_save_file_path(slot_index))


func has_any_save_data() -> bool:
	for i in range(GameManager.save_slots):
		if has_slot_data(i):
			return true
	return false


func get_slot_data(slot_index: int) -> SaveData:
	if not has_slot_data(slot_index):
		return null
	
	var file_path := _get_save_file_path(slot_index)
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return null
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	if json.parse(json_string) != OK:
		return null
	
	var data := SaveData.new()
	data.from_dict(json.data)
	return data


func get_all_slots(max_slots: int = 3) -> Array[SaveData]:
	var slots: Array[SaveData] = []
	
	for i in range(max_slots):
		var data := get_slot_data(i)
		if data:
			slots.append(data)
		else:
			# 빈 슬롯도 인덱스 정보만 가진 객체로 추가
			var empty := SaveData.new()
			empty.slot_index = i
			slots.append(empty)
	
	return slots

# ═══════════════════════════════════════════════════════════════════════════════
# Helpers
# ═══════════════════════════════════════════════════════════════════════════════

func _get_save_file_path(slot_index: int) -> String:
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot_index) + SAVE_FILE_EXT


# ═══════════════════════════════════════════════════════════════════════════════
# Local DNA Operations (맵별 로컬 데이터)
# ═══════════════════════════════════════════════════════════════════════════════

## 로컬 DNA 로드
func load_local_dna(location_id: String, slot_index: int = 0) -> Dictionary:
	var path := _get_local_dna_path(location_id, slot_index)
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			var json: Variant = JSON.parse_string(file.get_as_text())
			if json:
				return json
	return _create_empty_local_dna(location_id)


## 로컬 DNA 저장
func save_local_dna(location_id: String, data: Dictionary, slot_index: int = 0) -> bool:
	_ensure_locations_directory(slot_index)
	var path := _get_local_dna_path(location_id, slot_index)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		data["last_visit"] = Time.get_datetime_string_from_system()
		file.store_string(JSON.stringify(data, "  "))
		print("로컬 DNA 저장 완료: %s" % location_id)
		return true
	push_error("로컬 DNA 저장 실패: %s" % location_id)
	return false


## 로컬 DNA 삭제 (새 게임 등)
func delete_local_dna(location_id: String, slot_index: int = 0) -> void:
	var path := _get_local_dna_path(location_id, slot_index)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("로컬 DNA 삭제 완료: %s" % location_id)


## 슬롯의 모든 로컬 DNA 삭제
func delete_all_local_dna(slot_index: int = 0) -> void:
	var locations_path := SAVE_DIR + SAVE_FILE_PREFIX + str(slot_index) + "/" + LOCATIONS_DIR
	var dir := DirAccess.open(locations_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(SAVE_FILE_EXT):
				dir.remove(file_name)
			file_name = dir.get_next()
		print("모든 로컬 DNA 삭제 완료: 슬롯 %d" % (slot_index + 1))


## 빈 로컬 DNA 생성
func _create_empty_local_dna(location_id: String) -> Dictionary:
	return {
		"location_id": location_id,
		"player": { "pos": [0, 0], "facing": "down" },
		"npcs": {},
		"chests": {},
		"puzzles": {},
		"investigated": {}
	}


## 로컬 DNA 경로
func _get_local_dna_path(location_id: String, slot_index: int) -> String:
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot_index) + "/" + LOCATIONS_DIR + location_id + SAVE_FILE_EXT
