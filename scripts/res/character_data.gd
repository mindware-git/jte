class_name CharacterData
extends Resource

# ═══════════════════════════════════════════════════════════════════════════════
# 에너지 타입
# ═══════════════════════════════════════════════════════════════════════════════

enum EnergyType { MP, SP }

# ═══════════════════════════════════════════════════════════════════════════════
# 기본 정보
# ═══════════════════════════════════════════════════════════════════════════════

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var element: GameManager.ElementType = GameManager.ElementType.EARTH
@export var energy_type: EnergyType = EnergyType.MP
# 6417564, 33554473, 268435497, 7766988

# ═══════════════════════════════════════════════════════════════════════════════
# 능력치 (실제 수치)
# ═══════════════════════════════════════════════════════════════════════════════

@export var st_pow: int = 10      # Power - 물리 공격력
@export var st_int: int = 10 # Intelligence - 마법 (예약어 회피)
@export var st_dex: int = 10      # Dexterity - 민첩
@export var st_att: int = 0       # Attack - 공격력 보정
@export var st_def: int = 5  # Defense - 방어력 (예약어 회피)
@export var st_luck: int = 5      # Luck - 운
@export var st_ap: int = 3        # Action Point - 행동점수


@export var max_hp: int = 100
@export var max_mp: int = 50
@export var max_sg: int = 50

# ═══════════════════════════════════════════════════════════════════════════════
# 공격 시스템
# ═══════════════════════════════════════════════════════════════════════════════
## 근거리 공격 쿨다운 (초)
@export var melee_cooldown: float = 0.5

## 근거리 공격 사거리
@export var melee_range: float = 60.0

@export var move_range: int = 2

# 성장 시스템
@export var level: int = 1
@export var exp: int = 0