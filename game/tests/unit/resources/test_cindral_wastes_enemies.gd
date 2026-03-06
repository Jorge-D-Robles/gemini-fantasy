extends GutTest

## Tests for Cindral Wastes enemy set:
## Magma Crawler, Lava Elemental, and Ash Stalker ability upgrades.


func test_magma_crawler_loads() -> void:
	var enemy: EnemyData = load("res://data/enemies/magma_crawler.tres")
	assert_not_null(enemy, "magma_crawler.tres should load")


func test_magma_crawler_identity() -> void:
	var enemy: EnemyData = load("res://data/enemies/magma_crawler.tres")
	assert_eq(enemy.id, &"magma_crawler")
	assert_eq(enemy.display_name, "Magma Crawler")


func test_magma_crawler_defensive_tank() -> void:
	var enemy: EnemyData = load("res://data/enemies/magma_crawler.tres")
	assert_eq(
		enemy.ai_type, EnemyData.AiType.DEFENSIVE,
		"Should use DEFENSIVE AI",
	)
	assert_gte(enemy.defense, 16, "Should have high defense")
	assert_between(enemy.max_hp, 100, 160, "HP should be high")
	assert_lte(enemy.speed, 6, "Should be slow")


func test_magma_crawler_weak_to_ice() -> void:
	var found := false
	var enemy: EnemyData = load("res://data/enemies/magma_crawler.tres")
	for w in enemy.weaknesses:
		if int(w) == AbilityData.Element.ICE:
			found = true
			break
	assert_true(found, "Should be weak to Ice")


func test_magma_crawler_has_abilities() -> void:
	var enemy: EnemyData = load("res://data/enemies/magma_crawler.tres")
	assert_eq(
		enemy.abilities.size(), 3,
		"Should have 3 abilities (crush, harden, heat_wave)",
	)


func test_crush_ability() -> void:
	var ability: AbilityData = load("res://data/abilities/crush.tres")
	assert_not_null(ability, "crush.tres should load")
	assert_eq(ability.id, &"crush")
	assert_gt(ability.damage_base, 0, "Should deal damage")
	assert_eq(ability.status_effect, "burn")


func test_harden_ability() -> void:
	var ability: AbilityData = load("res://data/abilities/harden.tres")
	assert_not_null(ability, "harden.tres should load")
	assert_eq(ability.id, &"harden")
	assert_eq(
		ability.target_type, AbilityData.TargetType.SELF,
		"Should target self",
	)
	assert_eq(ability.status_effect, "shield")


func test_heat_wave_ability() -> void:
	var ability: AbilityData = load("res://data/abilities/heat_wave.tres")
	assert_not_null(ability, "heat_wave.tres should load")
	assert_eq(ability.id, &"heat_wave")
	assert_eq(
		ability.target_type, AbilityData.TargetType.ALL_ENEMIES,
		"Should be AoE",
	)
	assert_eq(ability.element, AbilityData.Element.FIRE)


func test_lava_elemental_loads() -> void:
	var enemy: EnemyData = load("res://data/enemies/lava_elemental.tres")
	assert_not_null(enemy, "lava_elemental.tres should load")


func test_lava_elemental_identity() -> void:
	var enemy: EnemyData = load("res://data/enemies/lava_elemental.tres")
	assert_eq(enemy.id, &"lava_elemental")
	assert_eq(enemy.display_name, "Lava Elemental")


func test_lava_elemental_aggressive() -> void:
	var enemy: EnemyData = load("res://data/enemies/lava_elemental.tres")
	assert_eq(
		enemy.ai_type, EnemyData.AiType.AGGRESSIVE,
		"Should use AGGRESSIVE AI",
	)


func test_lava_elemental_has_abilities() -> void:
	var enemy: EnemyData = load("res://data/enemies/lava_elemental.tres")
	assert_eq(
		enemy.abilities.size(), 3,
		"Should have 3 abilities",
	)


func test_ash_stalker_has_abilities() -> void:
	var enemy: EnemyData = load("res://data/enemies/ash_stalker.tres")
	assert_eq(
		enemy.abilities.size(), 3,
		"Should now have 3 abilities (bite, ember_breath, howl)",
	)
