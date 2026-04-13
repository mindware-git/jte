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

enum AreaPattern {
	SINGLE,      ## 단일 타겟 (1칸)
	CROSS_1,     ## 십자 1칸 (5칸)
	SQUARE_3x3,  ## 3x3 정방형 (9칸)
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

# 범위 (2단계 시스템)
var cast_range: int = 1           ## 가용 범위 (시전 가능한 거리)
var effect_range: int = 0         ## 효과 범위 (0이면 area_pattern만 사용)
var area_pattern: AreaPattern = AreaPattern.SINGLE  ## 효과 패턴

# 효과 수치
var damage_multiplier: float = 1.0  ## 공격 스킬 데미지 배율
var heal_amount: int = 0           ## 치유량
var buff_type: String = ""         ## 버프/디버프 타입
var buff_duration: int = 3         ## 버프 지속 턴 수