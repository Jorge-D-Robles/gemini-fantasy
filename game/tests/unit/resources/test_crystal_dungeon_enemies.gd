extends GutTest

## Tests for Beneath Prismfall crystal dungeon enemy set:
## Crystal Sentinel, Resonance Wisp, and Prism Guardian.


func test_crystal_sentinel_loads() -> void:
	var enemy: EnemyData = load("res://data/enemies/crystal_sentinel.tres")
	assert_not_null(enemy, "crystal_sentinel.tres should load")


func test_crystal_sentinel_identity() -> void:
	var enemy: EnemyData = load("res://data/enemies/crystal_sentinel.tres")
	assert_eq(enemy.id, &"crystal_sentinel")
	assert_eq(enemy.display_name, "Crystal Sentinel")


func test_crystal_sentinel_defensive_stats() -> void:
	var enemy: EnemyData = load("res://data/enemies/crystal_sentinel.tres")
	assert_eq(
		enemy.ai_type, EnemyData.AiType.DEFENSIVE,
		"Should use DEFENSIVE AI",
	)
	assert_gte(enemy.defense, 18, "Should have high defense")
	assert_between(enemy.max_hp, 80, 130, "HP should be mid-high")


func test_crystal_sentinel_has_abilities() -> void:
	var enemy: EnemyData = load("res://data/enemies/crystal_sentinel.tres")
	assert_eq(
		enemy.abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_crystal_sentinel_crystal_slam() -> void:
	var ability: AbilityData = load("res://data/abilities/crystal_slam.tres")
	assert_not_null(ability, "crystal_slam.tres should load")
	assert_eq(ability.id, &"crystal_slam")
	assert_gt(ability.damage_base, 0, "Should deal damage")
	assert_eq(ability.element, AbilityData.Element.EARTH)


func test_crystal_sentinel_crystal_shield() -> void:
	var ability: AbilityData = load("res://data/abilities/crystal_shell.tres")
	assert_not_null(ability, "crystal_shell.tres should load")
	assert_eq(ability.id, &"crystal_shell")
	assert_eq(
		ability.target_type, AbilityData.TargetType.SELF,
		"Should target self",
	)
	assert_eq(ability.status_effect, "shield")
	assert_eq(ability.status_chance, 1.0)


func test_resonance_wisp_loads() -> void:
	var enemy: EnemyData = load("res://data/enemies/resonance_wisp.tres")
	assert_not_null(enemy, "resonance_wisp.tres should load")


func test_resonance_wisp_identity() -> void:
	var enemy: EnemyData = load("res://data/enemies/resonance_wisp.tres")
	assert_eq(enemy.id, &"resonance_wisp")
	assert_eq(enemy.display_name, "Resonance Wisp")


func test_resonance_wisp_support_ai() -> void:
	var enemy: EnemyData = load("res://data/enemies/resonance_wisp.tres")
	assert_eq(
		enemy.ai_type, EnemyData.AiType.SUPPORT,
		"Should use SUPPORT AI",
	)


func test_resonance_wisp_weak_to_dark() -> void:
	var enemy: EnemyData = load("res://data/enemies/resonance_wisp.tres")
	var found := false
	for w in enemy.weaknesses:
		if int(w) == AbilityData.Element.DARK:
			found = true
			break
	assert_true(found, "Should be weak to Dark")


func test_resonance_wisp_has_heal_ability() -> void:
	var ability: AbilityData = load("res://data/abilities/resonance_mend.tres")
	assert_not_null(ability, "resonance_mend.tres should load")
	assert_eq(ability.id, &"resonance_mend")
	assert_eq(
		ability.target_type, AbilityData.TargetType.SINGLE_ALLY,
		"Should heal a single ally",
	)
	assert_gt(ability.damage_base, 0, "Should have heal value")


func test_resonance_wisp_has_abilities() -> void:
	var enemy: EnemyData = load("res://data/enemies/resonance_wisp.tres")
	assert_eq(
		enemy.abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_prism_guardian_loads() -> void:
	var enemy: EnemyData = load("res://data/enemies/prism_guardian.tres")
	assert_not_null(enemy, "prism_guardian.tres should load")


func test_prism_guardian_identity() -> void:
	var enemy: EnemyData = load("res://data/enemies/prism_guardian.tres")
	assert_eq(enemy.id, &"prism_guardian")
	assert_eq(enemy.display_name, "Prism Guardian")


func test_prism_guardian_boss_ai() -> void:
	var enemy: EnemyData = load("res://data/enemies/prism_guardian.tres")
	assert_eq(
		enemy.ai_type, EnemyData.AiType.BOSS,
		"Should use BOSS AI for mini-boss",
	)


func test_prism_guardian_high_stats() -> void:
	var enemy: EnemyData = load("res://data/enemies/prism_guardian.tres")
	assert_gte(enemy.max_hp, 180, "Boss should have high HP")
	assert_gte(enemy.defense, 14, "Boss should have decent defense")
	assert_gte(enemy.resistance, 14, "Boss should have high magic resist")


func test_prism_guardian_refract_ability() -> void:
	var ability: AbilityData = load("res://data/abilities/refract.tres")
	assert_not_null(ability, "refract.tres should load")
	assert_eq(ability.id, &"refract")
	assert_eq(
		ability.target_type, AbilityData.TargetType.SELF,
		"Refract should target self",
	)
	assert_eq(ability.element, AbilityData.Element.LIGHT)


func test_prism_guardian_has_abilities() -> void:
	var enemy: EnemyData = load("res://data/enemies/prism_guardian.tres")
	assert_gte(
		enemy.abilities.size(), 3,
		"Should have at least 3 abilities",
	)


func test_prism_guardian_rewards() -> void:
	var enemy: EnemyData = load("res://data/enemies/prism_guardian.tres")
	assert_gte(enemy.exp_reward, 60, "Boss should give good XP")
	assert_gte(enemy.gold_reward, 40, "Boss should give good gold")
