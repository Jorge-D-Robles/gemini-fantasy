extends RefCounted

## Centralized game balance constants. Import via:
##   const GameBalance = preload("res://systems/game_balance.gd")
##
## All tunable numbers that affect gameplay balance live here.
## Visual/animation timing and per-entity @exports do not belong here.

# -- Resonance system --

const RESONANCE_MAX: float = 150.0
const RESONANCE_RESONANT_THRESHOLD: float = 75.0
const RESONANCE_OVERLOAD_THRESHOLD: float = 100.0
const RESONANCE_GAIN_DAMAGE_TAKEN: float = 1.0
const RESONANCE_GAIN_DAMAGE_DEALT: float = 0.6
const RESONANCE_GAIN_DEFENDING: float = 1.5
const RESONANCE_GAIN_SCALING: float = 0.1
const DEFEND_RESONANCE_BASE: float = 10.0

# -- Damage formula --

const DEFENSE_SCALING_DIVISOR: float = 200.0
const DEFENSE_MOD_MIN: float = 0.1
const HOLLOW_STAT_PENALTY: float = 0.5
const DEFEND_DAMAGE_REDUCTION: float = 0.5
const OVERLOAD_INCOMING_DAMAGE_MULT: float = 2.0
const OVERLOAD_OUTGOING_DAMAGE_MULT: float = 2.0
const RESONANT_ABILITY_BONUS: float = 1.2
const STAT_DAMAGE_SCALING: float = 0.5

# -- Turn order --

const TURN_DELAY_BASE: float = 100.0

# -- Revive --

const REVIVE_HP_PERCENT: float = 0.25

# -- XP / Leveling --

const XP_CURVE_BASE: int = 100

# -- Party limits --

const MAX_ACTIVE_PARTY: int = 4
const MAX_RESERVE_PARTY: int = 4

# -- Critical hit --

const CRIT_BASE_CHANCE: float = 0.05          # 5% baseline crit chance
const CRIT_LUCK_BONUS_PER_POINT: float = 0.005 # +0.5% crit chance per luck point
const CRIT_DAMAGE_MULT: float = 1.5           # ×1.5 damage on a critical hit

# -- Enemy AI thresholds --

const AI_DEFENSIVE_HP_THRESHOLD: float = 0.3
const AI_SUPPORT_HEAL_THRESHOLD: float = 0.5
