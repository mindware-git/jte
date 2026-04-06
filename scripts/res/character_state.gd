class_name CharacterState
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# CharacterState
# 캐릭터별 상태 (장착 아이템, 습득 스킬)
# ═══════════════════════════════════════════════════════════════════════════════

var character_id: String = ""
var level: int = 1
var experience: int = 0

# 장착 아이템
var equipped_weapon: String = ""
var equipped_armor: String = ""
var equipped_accessory: String = ""

# 습득한 스킬 ID 목록 (PackedStringArray 사용)
var learned_skills: PackedStringArray = PackedStringArray()

# 인벤토리 (아이템 ID -> 개수)
var inventory: Dictionary = {}

# ═══════════════════════════════════════════════════════════════════════════════
# Serialization
# ═══════════════════════════════════════════════════════════════════════════════

func to_dict() -> Dictionary:
	return {
		"character_id": character_id,
		"level": level,
		"experience": experience,
		"equipped_weapon": equipped_weapon,
		"equipped_armor": equipped_armor,
		"equipped_accessory": equipped_accessory,
		"learned_skills": learned_skills,
		"inventory": inventory,
	}


func from_dict(dict: Dictionary) -> void:
	character_id = dict.get("character_id", "")
	level = dict.get("level", 1)
	experience = dict.get("experience", 0)
	equipped_weapon = dict.get("equipped_weapon", "")
	equipped_armor = dict.get("equipped_armor", "")
	equipped_accessory = dict.get("equipped_accessory", "")
	
	# PackedStringArray로 변환
	var skills: Array = dict.get("learned_skills", [])
	learned_skills = PackedStringArray()
	for s in skills:
		learned_skills.append(str(s))
	
	inventory = dict.get("inventory", {})


# ═══════════════════════════════════════════════════════════════════════════════
# Equipment Management
# ═══════════════════════════════════════════════════════════════════════════════

func equip_item(item_id: String, slot: String) -> void:
	match slot:
		"weapon": equipped_weapon = item_id
		"armor": equipped_armor = item_id
		"accessory": equipped_accessory = item_id


func unequip_item(slot: String) -> String:
	var prev: String = ""
	match slot:
		"weapon":
			prev = equipped_weapon
			equipped_weapon = ""
		"armor":
			prev = equipped_armor
			equipped_armor = ""
		"accessory":
			prev = equipped_accessory
			equipped_accessory = ""
	return prev


func get_equipped_item(slot: String) -> String:
	match slot:
		"weapon": return equipped_weapon
		"armor": return equipped_armor
		"accessory": return equipped_accessory
		_: return ""


func get_all_equipped() -> Dictionary:
	return {
		"weapon": equipped_weapon,
		"armor": equipped_armor,
		"accessory": equipped_accessory,
	}


# ═══════════════════════════════════════════════════════════════════════════════
# Inventory Management
# ═══════════════════════════════════════════════════════════════════════════════

func add_item(item_id: String, count: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] += count
	else:
		inventory[item_id] = count


func remove_item(item_id: String, count: int = 1) -> bool:
	if not inventory.has(item_id):
		return false
	if inventory[item_id] < count:
		return false
	
	inventory[item_id] -= count
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	return true


func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)


func has_item(item_id: String) -> bool:
	return inventory.get(item_id, 0) > 0


# ═══════════════════════════════════════════════════════════════════════════════
# Skill Management
# ═══════════════════════════════════════════════════════════════════════════════

func learn_skill(skill_id: String) -> void:
	if not learned_skills.has(skill_id):
		learned_skills.append(skill_id)


func has_skill(skill_id: String) -> bool:
	return learned_skills.has(skill_id)


func get_skills() -> PackedStringArray:
	return learned_skills.duplicate()
