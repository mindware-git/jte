class_name ExploreScreen
extends Node2D

# ═══════════════════════════════════════════════════════════════════════════════
# ExploreScreen
# 탐험 화면 컨트롤러 (Node2D 기반)
# ═══════════════════════════════════════════════════════════════════════════════

signal finished()

# RNA 데이터
var _rna: Dictionary = {}

# 현재 위치
var _location_id: String = "bluewood_village"

# ═══════════════════════════════════════════════════════════════════════════════
# Setup
# ═══════════════════════════════════════════════════════════════════════════════

func setup(rna: Dictionary) -> void:
	_rna = rna
	_location_id = rna.get("current_location", "bluewood_village")
	
	# 기본 UI 생성
	_create_ui()
	
	print("ExploreScreen 설정 완료: ", _location_id)


# ═══════════════════════════════════════════════════════════════════════════════
# UI Creation
# ═══════════════════════════════════════════════════════════════════════════════

func _create_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.15, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# 위치 표시 라벨
	var location_label := Label.new()
	location_label.text = "위치: " + _location_id
	location_label.position = Vector2(20, 20)
	location_label.add_theme_font_size_override("font_size", 24)
	location_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(location_label)
	
	# 파티 정보 라벨
	var party_label := Label.new()
	var party_members: Array = _rna.get("party_members", ["sanzang"])
	party_label.text = "파티: " + ", ".join(party_members)
	party_label.position = Vector2(20, 60)
	party_label.add_theme_font_size_override("font_size", 18)
	party_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	add_child(party_label)
	
	# 골드 표시
	var coin_label := Label.new()
	var coin: int = _rna.get("coin", 0)
	coin_label.text = "골드: %d" % coin
	coin_label.position = Vector2(20, 100)
	coin_label.add_theme_font_size_override("font_size", 18)
	coin_label.add_theme_color_override("font_color", Color.GOLD)
	add_child(coin_label)