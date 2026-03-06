extends GutTest

## Tests for Thornback Bear enemy data and its abilities.

var _enemy: EnemyData


func before_each() -> void:
	_enemy = load("res://data/enemies/thornback_bear.tres") as EnemyData


func test_thornback_bear_loads() -> void:
	assert_not_null(_enemy, "thornback_bear.tres should load")


func test_id_matches() -> void:
	assert_eq(_enemy.id, &"thornback_bear")


func test_display_name() -> void:
	assert_eq(_enemy.display_name, "Thornback Bear")


func test_hp_around_120() -> void:
	assert_between(_enemy.max_hp, 100, 140, "HP should be ~120")


func test_ai_type_aggressive() -> void:
	assert_eq(
		_enemy.ai_type, EnemyData.AiType.AGGRESSIVE,
		"Should use AGGRESSIVE AI",
	)


func test_weak_to_fire() -> void:
	var found := false
	for w in _enemy.weaknesses:
		if int(w) == AbilityData.Element.FIRE:
			found = true
			break
	assert_true(found, "Should be weak to Fire")


func test_has_abilities() -> void:
	assert_gte(
		_enemy.abilities.size(), 2,
		"Should have at least 2 abilities",
	)


func test_maul_ability_loads() -> void:
	var maul: AbilityData = load("res://data/abilities/maul.tres")
	assert_not_null(maul, "maul.tres should load")
	assert_eq(maul.id, &"maul")
	assert_gt(maul.damage_base, 0, "Maul should deal damage")


func test_thorn_volley_ability_loads() -> void:
	var tv: AbilityData = load("res://data/abilities/thorn_volley.tres")
	assert_not_null(tv, "thorn_volley.tres should load")
	assert_eq(tv.id, &"thorn_volley")
	assert_eq(
		tv.target_type, AbilityData.TargetType.ALL_ENEMIES,
		"Thorn Volley should be AoE",
	)
