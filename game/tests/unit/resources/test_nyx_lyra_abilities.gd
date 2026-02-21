extends GutTest

## Tests for T-0223: Nyx (4) and Lyra (1) AbilityData .tres stubs.
## Nyx: void_bolt, phase_shift, reality_break, shadow_bind
## Lyra: fragment_vision

const _VOID_BOLT := preload("res://data/abilities/void_bolt.tres")
const _PHASE_SHIFT := preload("res://data/abilities/phase_shift.tres")
const _REALITY_BREAK := preload("res://data/abilities/reality_break.tres")
const _SHADOW_BIND := preload("res://data/abilities/shadow_bind.tres")
const _FRAGMENT_VISION := preload("res://data/abilities/fragment_vision.tres")


# --- Nyx: Void Bolt ---

func test_void_bolt_stats() -> void:
	assert_eq(_VOID_BOLT.ee_cost, 20, "Void Bolt must cost 20 EE")
	assert_eq(_VOID_BOLT.damage_stat, 1, "Void Bolt uses MAGIC stat (1)")
	assert_eq(_VOID_BOLT.element, 7, "Void Bolt element must be DARK (7)")
	assert_eq(_VOID_BOLT.target_type, 0, "Void Bolt targets SINGLE_ENEMY (0)")
	assert_gt(_VOID_BOLT.damage_base, 0, "Void Bolt must have positive damage_base")
	assert_false(_VOID_BOLT.display_name.is_empty(), "Void Bolt must have a display_name")


# --- Nyx: Phase Shift ---

func test_phase_shift_stats() -> void:
	assert_eq(_PHASE_SHIFT.ee_cost, 30, "Phase Shift must cost 30 EE")
	assert_eq(_PHASE_SHIFT.target_type, 4, "Phase Shift targets SELF (4)")
	assert_false(_PHASE_SHIFT.display_name.is_empty(), "Phase Shift must have a display_name")


# --- Nyx: Reality Break ---

func test_reality_break_stats() -> void:
	assert_eq(_REALITY_BREAK.ee_cost, 35, "Reality Break must cost 35 EE")
	assert_eq(_REALITY_BREAK.resonance_cost, 40.0, "Reality Break requires 40% Resonance")
	assert_eq(_REALITY_BREAK.target_type, 1, "Reality Break targets ALL_ENEMIES (1)")
	assert_false(_REALITY_BREAK.display_name.is_empty(), "Reality Break must have a display_name")


# --- Nyx: Shadow Bind ---

func test_shadow_bind_stats() -> void:
	assert_eq(_SHADOW_BIND.ee_cost, 40, "Shadow Bind must cost 40 EE")
	assert_eq(_SHADOW_BIND.target_type, 1, "Shadow Bind targets ALL_ENEMIES (1)")
	assert_false(
		_SHADOW_BIND.status_effect.is_empty(),
		"Shadow Bind must have a status_effect (immobilize)",
	)
	assert_false(_SHADOW_BIND.display_name.is_empty(), "Shadow Bind must have a display_name")


# --- Lyra: Fragment Vision ---

func test_fragment_vision_stats() -> void:
	assert_eq(_FRAGMENT_VISION.ee_cost, 25, "Fragment Vision must cost 25 EE")
	assert_eq(_FRAGMENT_VISION.target_type, 3, "Fragment Vision targets ALL_ALLIES (3)")
	assert_eq(_FRAGMENT_VISION.damage_stat, 1, "Fragment Vision uses MAGIC stat (1)")
	assert_false(
		_FRAGMENT_VISION.display_name.is_empty(),
		"Fragment Vision must have a display_name",
	)
