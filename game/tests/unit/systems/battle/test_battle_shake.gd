extends GutTest

## Tests for BattleShake static helpers — is_heavy_hit() and compute_intensity().


# -- is_heavy_hit --

func test_is_heavy_hit_exactly_at_threshold() -> void:
	assert_true(BattleShake.is_heavy_hit(25, 100))


func test_is_not_heavy_hit_one_below_threshold() -> void:
	assert_false(BattleShake.is_heavy_hit(24, 100))


func test_is_heavy_hit_full_damage() -> void:
	assert_true(BattleShake.is_heavy_hit(100, 100))


func test_is_not_heavy_hit_zero_damage() -> void:
	assert_false(BattleShake.is_heavy_hit(0, 100))


func test_is_not_heavy_hit_zero_max_hp() -> void:
	assert_false(BattleShake.is_heavy_hit(50, 0))


func test_is_heavy_hit_above_threshold() -> void:
	assert_true(BattleShake.is_heavy_hit(50, 100))


# -- compute_intensity --

func test_intensity_at_threshold_equals_base() -> void:
	var result: float = BattleShake.compute_intensity(25, 100)
	assert_almost_eq(result, BattleShake.SHAKE_INTENSITY_BASE, 0.01)


func test_intensity_at_full_damage_equals_max() -> void:
	var result: float = BattleShake.compute_intensity(100, 100)
	assert_almost_eq(result, BattleShake.SHAKE_INTENSITY_MAX, 0.01)


func test_intensity_clamped_to_base_when_below_threshold() -> void:
	# sub-threshold damage returns base intensity when clamped
	var result: float = BattleShake.compute_intensity(10, 100)
	assert_almost_eq(result, BattleShake.SHAKE_INTENSITY_BASE, 0.01)


func test_intensity_zero_max_hp_returns_zero() -> void:
	var result: float = BattleShake.compute_intensity(50, 0)
	assert_almost_eq(result, 0.0, 0.01)
