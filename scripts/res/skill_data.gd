class_name SkillData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# SkillData
# 스킬 데이터 구조
# ═══════════════════════════════════════════════════════════════════════════════

enum SkillType {
	ATTACK,      ## 공격 스킬
	HEAL,        ## 치유 스킬
	BUFF,        ## 버프 스킬
	DEBUFF       ## 디버프 스킬
}

enum SkillRangeType {
	SINGLE,      ## 단일 타겟
	CROSS_1,     ## 십자 1칸
	SQUARE_3x3,  ## 3x3 정방형
	LINE_3,      ## 라인 3칸
}

var id: String = ""
var name: String = ""
var description: String = ""
var type: SkillType = SkillType.ATTACK

# 습득 조건
var unlock_level: int = 1

var applicable_units: Array[String] = []

# 비용
var mp_cost: int = 10
var sg_cost: int = 0

# 범위
var range_type: SkillRangeType = SkillRangeType.SINGLE
