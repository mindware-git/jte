class_name ItemData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# ItemData
# 아이템 데이터 구조
# ═══════════════════════════════════════════════════════════════════════════════

enum ItemType {
	WEAPON,      ## 무기
	ARMOR,       ## 방어구
	ACCESSORY,   ## 장신구
	CONSUMABLE   ## 소모품
}

enum ItemTargetType {
	SELF,        ## 자기 자신
	ALLY,        ## 아군 대상
	ENEMY,       ## 적 대상
	ALL_ALLY,    ## 전체 아군
}

var id: String = ""
var name: String = ""
var description: String = ""

var type: ItemType = ItemType.WEAPON
var price_buy: int = 0
var price_sell: int = 0
var price_gem: int = 0

# 스탯 보너스
@export var st_pow: int = 10      # Power - 물리 공격력
@export var st_int: int = 10 # Intelligence - 마법 (예약어 회피)
@export var st_dex: int = 10      # Dexterity - 민첩
@export var st_att: int = 0       # Attack - 공격력 보정
@export var st_def: int = 5  # Defense - 방어력 (예약어 회피)
@export var st_luck: int = 5      # Luck - 운
@export var st_ap: int = 3        # Action Point - 행동점수

var applicable_units: Array[String] = []
var applicable_shop: Array[String] = []

# 전투용 필드
var target_type: ItemTargetType = ItemTargetType.SELF  # 대상 타입 (기본: 자신)
var use_range: int = 0  # 사용 범위 (칸 수, 기본: 0)


## 희귀도 색상 반환
func get_rarity_color() -> Color:
	return Color.WHITE  # 기본 색상
