extends GutTest

## Tests for Kael's full ability set (7 AbilityData .tres files).
## T-0221: Verifies EE cost, damage_stat, and display_name for each ability.

const _ECHO_STRIKE := preload("res://data/abilities/echo_strike.tres")
const _RESONANCE_PULSE := preload("res://data/abilities/resonance_pulse.tres")
const _MEMORY_WEAVE := preload("res://data/abilities/memory_weave.tres")
const _ADAPTIVE_STRIKE := preload("res://data/abilities/adaptive_strike.tres")
const _ECHO_FUSION := preload("res://data/abilities/echo_fusion.tres")
const _REALITY_ANCHOR := preload("res://data/abilities/reality_anchor.tres")
const _CONVERGENCE_TOUCH := preload("res://data/abilities/convergence_touch.tres")


func test_echo_strike_stats() -> void:
	assert_eq(_ECHO_STRIKE.ee_cost, 15, "Echo Strike must cost 15 EE")
	assert_eq(_ECHO_STRIKE.damage_stat, 0, "Echo Strike uses ATTACK stat (0)")
	assert_false(_ECHO_STRIKE.display_name.is_empty(), "Echo Strike must have a display name")


func test_resonance_pulse_stats() -> void:
	assert_eq(_RESONANCE_PULSE.ee_cost, 25, "Resonance Pulse must cost 25 EE")
	assert_eq(_RESONANCE_PULSE.damage_stat, 1, "Resonance Pulse uses MAGIC stat (1)")
	assert_false(
		_RESONANCE_PULSE.display_name.is_empty(), "Resonance Pulse must have a display name"
	)


func test_memory_weave_stats() -> void:
	assert_eq(_MEMORY_WEAVE.ee_cost, 20, "Memory Weave must cost 20 EE")
	assert_eq(_MEMORY_WEAVE.target_type, 3, "Memory Weave targets ALL_ALLIES (3)")
	assert_false(_MEMORY_WEAVE.display_name.is_empty(), "Memory Weave must have a display name")


func test_adaptive_strike_stats() -> void:
	assert_eq(_ADAPTIVE_STRIKE.ee_cost, 30, "Adaptive Strike must cost 30 EE")
	assert_eq(_ADAPTIVE_STRIKE.damage_stat, 0, "Adaptive Strike uses ATTACK stat (0)")
	assert_false(
		_ADAPTIVE_STRIKE.display_name.is_empty(), "Adaptive Strike must have a display name"
	)


func test_echo_fusion_stats() -> void:
	assert_eq(_ECHO_FUSION.ee_cost, 40, "Echo Fusion must cost 40 EE")
	assert_eq(_ECHO_FUSION.resonance_cost, 50.0, "Echo Fusion must require 50% Resonance")
	assert_eq(_ECHO_FUSION.damage_stat, 1, "Echo Fusion uses MAGIC stat (1)")
	assert_false(_ECHO_FUSION.display_name.is_empty(), "Echo Fusion must have a display name")


func test_reality_anchor_stats() -> void:
	assert_eq(_REALITY_ANCHOR.ee_cost, 35, "Reality Anchor must cost 35 EE")
	assert_eq(_REALITY_ANCHOR.target_type, 3, "Reality Anchor targets ALL_ALLIES (3)")
	assert_false(
		_REALITY_ANCHOR.status_effect.is_empty(), "Reality Anchor must have a status_effect"
	)
	assert_false(
		_REALITY_ANCHOR.display_name.is_empty(), "Reality Anchor must have a display name"
	)


func test_convergence_touch_stats() -> void:
	assert_eq(_CONVERGENCE_TOUCH.ee_cost, 60, "Convergence Touch must cost 60 EE")
	assert_eq(_CONVERGENCE_TOUCH.resonance_cost, 75.0, "Convergence Touch must require 75% Resonance")
	assert_eq(_CONVERGENCE_TOUCH.damage_stat, 1, "Convergence Touch uses MAGIC stat (1)")
	assert_eq(_CONVERGENCE_TOUCH.status_chance, 0.25, "Convergence Touch has 25% Overload chance")
	assert_false(
		_CONVERGENCE_TOUCH.display_name.is_empty(), "Convergence Touch must have a display name"
	)
