# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Ironcoast/Initiative enemy set:
## Initiative Soldier (BASIC), Initiative Agent (AGGRESSIVE),
## Security Drone (DEFENSIVE), Initiative Scientist (SUPPORT).
## 12 new abilities across 4 enemies.


func _soldier() -> EnemyData:
	return load("res://data/enemies/initiative_soldier.tres")


func _agent() -> EnemyData:
	return load("res://data/enemies/initiative_agent.tres")


func _drone() -> EnemyData:
	return load("res://data/enemies/security_drone.tres")


func _scientist() -> EnemyData:
	return load("res://data/enemies/initiative_scientist.tres")


# --- Initiative Soldier ---


func test_soldier_loads() -> void:
	assert_not_null(
		_soldier(), "initiative_soldier.tres should load"
	)


func test_soldier_identity() -> void:
	assert_eq(_soldier().id, &"initiative_soldier")
	assert_eq(_soldier().display_name, "Initiative Soldier")


func test_soldier_basic_ai() -> void:
	assert_eq(
		_soldier().ai_type, EnemyData.AiType.BASIC,
		"Should use BASIC AI",
	)


func test_soldier_weak_to_dark() -> void:
	var found := false
	for w in _soldier().weaknesses:
		if int(w) == AbilityData.Element.DARK:
			found = true
			break
	assert_true(found, "Should be weak to Dark (magic bypass)")


func test_soldier_has_abilities() -> void:
	assert_eq(
		_soldier().abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_rifle_shot_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/rifle_shot.tres"
	)
	assert_not_null(ability, "rifle_shot.tres should load")
	assert_eq(ability.id, &"rifle_shot")
	assert_gt(ability.damage_base, 0, "Should deal damage")
	assert_eq(
		ability.target_type, AbilityData.TargetType.SINGLE_ENEMY,
		"Should target single enemy",
	)


func test_frag_grenade_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/frag_grenade.tres"
	)
	assert_not_null(ability, "frag_grenade.tres should load")
	assert_eq(ability.id, &"frag_grenade")
	assert_eq(
		ability.target_type, AbilityData.TargetType.ALL_ENEMIES,
		"Should be AoE",
	)


func test_stimpack_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/stimpack.tres"
	)
	assert_not_null(ability, "stimpack.tres should load")
	assert_eq(ability.id, &"stimpack")
	assert_eq(
		ability.target_type, AbilityData.TargetType.SELF,
		"Should target self",
	)


# --- Initiative Agent ---


func test_agent_loads() -> void:
	assert_not_null(
		_agent(), "initiative_agent.tres should load"
	)


func test_agent_identity() -> void:
	assert_eq(_agent().id, &"initiative_agent")
	assert_eq(_agent().display_name, "Initiative Agent")


func test_agent_aggressive_ai() -> void:
	assert_eq(
		_agent().ai_type, EnemyData.AiType.AGGRESSIVE,
		"Should use AGGRESSIVE AI",
	)


func test_agent_has_abilities() -> void:
	assert_eq(
		_agent().abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_precision_strike_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/precision_strike.tres"
	)
	assert_not_null(ability, "precision_strike.tres should load")
	assert_eq(ability.id, &"precision_strike")
	assert_gt(ability.damage_base, 0, "Should deal damage")


func test_smoke_screen_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/smoke_screen.tres"
	)
	assert_not_null(ability, "smoke_screen.tres should load")
	assert_eq(ability.id, &"smoke_screen")
	assert_eq(
		ability.target_type, AbilityData.TargetType.ALL_ENEMIES,
		"Should be AoE debuff",
	)


# --- Security Drone ---


func test_drone_loads() -> void:
	assert_not_null(
		_drone(), "security_drone.tres should load"
	)


func test_drone_identity() -> void:
	assert_eq(_drone().id, &"security_drone")
	assert_eq(_drone().display_name, "Security Drone")


func test_drone_defensive_ai() -> void:
	assert_eq(
		_drone().ai_type, EnemyData.AiType.DEFENSIVE,
		"Should use DEFENSIVE AI",
	)
	assert_gte(_drone().defense, 18, "Should have high defense")


func test_drone_weak_to_wind() -> void:
	var found := false
	for w in _drone().weaknesses:
		if int(w) == AbilityData.Element.WIND:
			found = true
			break
	assert_true(found, "Should be weak to Wind (EMP)")


func test_drone_has_abilities() -> void:
	assert_eq(
		_drone().abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_laser_blast_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/laser_blast.tres"
	)
	assert_not_null(ability, "laser_blast.tres should load")
	assert_eq(ability.id, &"laser_blast")
	assert_eq(
		ability.damage_stat, AbilityData.DamageStat.MAGIC,
		"Should deal magic damage",
	)


func test_scan_target_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/scan_target.tres"
	)
	assert_not_null(ability, "scan_target.tres should load")
	assert_eq(ability.id, &"scan_target")


# --- Initiative Scientist ---


func test_scientist_loads() -> void:
	assert_not_null(
		_scientist(), "initiative_scientist.tres should load"
	)


func test_scientist_identity() -> void:
	assert_eq(_scientist().id, &"initiative_scientist")
	assert_eq(
		_scientist().display_name, "Initiative Scientist"
	)


func test_scientist_support_ai() -> void:
	assert_eq(
		_scientist().ai_type, EnemyData.AiType.SUPPORT,
		"Should use SUPPORT AI",
	)


func test_scientist_has_abilities() -> void:
	assert_eq(
		_scientist().abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_resonance_injection_ability() -> void:
	var ability: AbilityData = load(
		"res://data/abilities/resonance_injection.tres"
	)
	assert_not_null(
		ability, "resonance_injection.tres should load"
	)
	assert_eq(ability.id, &"resonance_injection")
	assert_eq(
		ability.target_type, AbilityData.TargetType.SINGLE_ALLY,
		"Should target single ally to buff",
	)
