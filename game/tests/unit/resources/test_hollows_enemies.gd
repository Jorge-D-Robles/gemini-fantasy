# gdlint:ignore = max-public-methods
extends GutTest

## Tests for The Hollows enemy set:
## Time Wraith (AGGRESSIVE), Void Spawn (BASIC),
## Memory Phantom (BOSS). 9 new abilities.


func _wraith() -> EnemyData:
	return load("res://data/enemies/time_wraith.tres")


func _spawn() -> EnemyData:
	return load("res://data/enemies/void_spawn.tres")


func _phantom() -> EnemyData:
	return load("res://data/enemies/memory_phantom.tres")


# --- Time Wraith ---


func test_wraith_loads() -> void:
	assert_not_null(_wraith(), "time_wraith.tres should load")


func test_wraith_identity() -> void:
	assert_eq(_wraith().id, &"time_wraith")
	assert_eq(_wraith().display_name, "Time Wraith")


func test_wraith_aggressive_ai() -> void:
	assert_eq(
		_wraith().ai_type, EnemyData.AiType.AGGRESSIVE,
		"Should use AGGRESSIVE AI",
	)


func test_wraith_fast() -> void:
	assert_gte(
		_wraith().speed, 12,
		"Should be fast (temporal unpredictability)",
	)


func test_wraith_weak_to_light() -> void:
	var found := false
	for w in _wraith().weaknesses:
		if int(w) == AbilityData.Element.LIGHT:
			found = true
			break
	assert_true(found, "Should be weak to Light")


func test_wraith_has_abilities() -> void:
	assert_eq(
		_wraith().abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_temporal_strike_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/temporal_strike.tres"
	)
	assert_not_null(ability, "temporal_strike.tres should load")
	assert_eq(ability.id, &"temporal_strike")
	assert_eq(
		ability.damage_stat, AbilityData.DamageStat.MAGIC,
		"Should deal magic damage (bypasses defense)",
	)


func test_rewind_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/rewind.tres"
	)
	assert_not_null(ability, "rewind.tres should load")
	assert_eq(ability.id, &"rewind")
	assert_eq(
		ability.target_type, AbilityData.TargetType.SELF,
		"Should target self (self-heal)",
	)


func test_time_skip_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/time_skip.tres"
	)
	assert_not_null(ability, "time_skip.tres should load")
	assert_eq(ability.id, &"time_skip")
	assert_eq(ability.status_effect, "stun")


# --- Void Spawn ---


func test_spawn_loads() -> void:
	assert_not_null(_spawn(), "void_spawn.tres should load")


func test_spawn_identity() -> void:
	assert_eq(_spawn().id, &"void_spawn")
	assert_eq(_spawn().display_name, "Void Spawn")


func test_spawn_basic_ai() -> void:
	assert_eq(
		_spawn().ai_type, EnemyData.AiType.BASIC,
		"Should use BASIC AI (erratic)",
	)


func test_spawn_weak_to_light() -> void:
	var found := false
	for w in _spawn().weaknesses:
		if int(w) == AbilityData.Element.LIGHT:
			found = true
			break
	assert_true(found, "Should be weak to Light")


func test_spawn_has_abilities() -> void:
	assert_eq(
		_spawn().abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_reality_tear_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/reality_tear.tres"
	)
	assert_not_null(ability, "reality_tear.tres should load")
	assert_eq(ability.id, &"reality_tear")
	assert_gt(ability.damage_base, 0, "Should deal damage")


func test_nullify_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/nullify.tres"
	)
	assert_not_null(ability, "nullify.tres should load")
	assert_eq(ability.id, &"nullify")
	assert_eq(ability.status_effect, "dispel")


func test_existence_doubt_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/existence_doubt.tres"
	)
	assert_not_null(
		ability, "existence_doubt.tres should load"
	)
	assert_eq(ability.id, &"existence_doubt")
	assert_eq(
		ability.target_type, AbilityData.TargetType.ALL_ENEMIES,
		"Should be AoE debuff",
	)


# --- Memory Phantom ---


func test_phantom_loads() -> void:
	assert_not_null(
		_phantom(), "memory_phantom.tres should load"
	)


func test_phantom_identity() -> void:
	assert_eq(_phantom().id, &"memory_phantom")
	assert_eq(_phantom().display_name, "Memory Phantom")


func test_phantom_boss_ai() -> void:
	assert_eq(
		_phantom().ai_type, EnemyData.AiType.BOSS,
		"Should use BOSS AI",
	)


func test_phantom_high_stats() -> void:
	assert_gte(
		_phantom().max_hp, 140,
		"Boss should have high HP",
	)
	assert_gte(
		_phantom().magic, 24,
		"Boss should have high magic",
	)


func test_phantom_has_abilities() -> void:
	assert_eq(
		_phantom().abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_mirror_strike_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/mirror_strike.tres"
	)
	assert_not_null(ability, "mirror_strike.tres should load")
	assert_eq(ability.id, &"mirror_strike")
	assert_eq(ability.element, AbilityData.Element.DARK)


func test_corrupted_echo_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/corrupted_echo.tres"
	)
	assert_not_null(ability, "corrupted_echo.tres should load")
	assert_eq(ability.id, &"corrupted_echo")
	assert_eq(
		ability.target_type, AbilityData.TargetType.ALL_ENEMIES,
		"Should be AoE",
	)


func test_identity_shatter_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/identity_shatter.tres"
	)
	assert_not_null(
		ability, "identity_shatter.tres should load"
	)
	assert_eq(ability.id, &"identity_shatter")
	assert_eq(ability.status_effect, "stun")
