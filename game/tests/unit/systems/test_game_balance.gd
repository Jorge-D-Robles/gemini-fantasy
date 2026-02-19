extends GutTest

## Tests for GameBalance centralized constants.

const GameBalance = preload("res://systems/game_balance.gd")


# -- Resonance constants --


func test_resonance_max() -> void:
	assert_eq(GameBalance.RESONANCE_MAX, 150.0)


func test_resonance_resonant_threshold() -> void:
	assert_eq(GameBalance.RESONANCE_RESONANT_THRESHOLD, 75.0)


func test_resonance_overload_threshold() -> void:
	assert_eq(GameBalance.RESONANCE_OVERLOAD_THRESHOLD, 100.0)


func test_resonance_gain_damage_taken() -> void:
	assert_eq(GameBalance.RESONANCE_GAIN_DAMAGE_TAKEN, 1.0)


func test_resonance_gain_damage_dealt() -> void:
	assert_eq(GameBalance.RESONANCE_GAIN_DAMAGE_DEALT, 0.6)


func test_resonance_gain_defending() -> void:
	assert_eq(GameBalance.RESONANCE_GAIN_DEFENDING, 1.5)


func test_resonance_gain_scaling() -> void:
	assert_eq(GameBalance.RESONANCE_GAIN_SCALING, 0.1)


func test_defend_resonance_base() -> void:
	assert_eq(GameBalance.DEFEND_RESONANCE_BASE, 10.0)


# -- Damage formula constants --


func test_defense_scaling_divisor() -> void:
	assert_eq(GameBalance.DEFENSE_SCALING_DIVISOR, 200.0)


func test_defense_mod_min() -> void:
	assert_eq(GameBalance.DEFENSE_MOD_MIN, 0.1)


func test_hollow_stat_penalty() -> void:
	assert_eq(GameBalance.HOLLOW_STAT_PENALTY, 0.5)


func test_defend_damage_reduction() -> void:
	assert_eq(GameBalance.DEFEND_DAMAGE_REDUCTION, 0.5)


func test_overload_incoming_damage_mult() -> void:
	assert_eq(GameBalance.OVERLOAD_INCOMING_DAMAGE_MULT, 2.0)


func test_overload_outgoing_damage_mult() -> void:
	assert_eq(GameBalance.OVERLOAD_OUTGOING_DAMAGE_MULT, 2.0)


func test_resonant_ability_bonus() -> void:
	assert_eq(GameBalance.RESONANT_ABILITY_BONUS, 1.2)


func test_stat_damage_scaling() -> void:
	assert_eq(GameBalance.STAT_DAMAGE_SCALING, 0.5)


# -- Turn order --


func test_turn_delay_base() -> void:
	assert_eq(GameBalance.TURN_DELAY_BASE, 100.0)


# -- Revive --


func test_revive_hp_percent() -> void:
	assert_eq(GameBalance.REVIVE_HP_PERCENT, 0.25)


# -- XP / Leveling --


func test_xp_curve_base() -> void:
	assert_eq(GameBalance.XP_CURVE_BASE, 100)


# -- Party limits --


func test_max_active_party() -> void:
	assert_eq(GameBalance.MAX_ACTIVE_PARTY, 4)


func test_max_reserve_party() -> void:
	assert_eq(GameBalance.MAX_RESERVE_PARTY, 4)


# -- Enemy AI thresholds --


func test_ai_defensive_hp_threshold() -> void:
	assert_eq(GameBalance.AI_DEFENSIVE_HP_THRESHOLD, 0.3)


func test_ai_support_heal_threshold() -> void:
	assert_eq(GameBalance.AI_SUPPORT_HEAL_THRESHOLD, 0.5)
