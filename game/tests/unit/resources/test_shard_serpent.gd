extends GutTest

## Tests for Shard Serpent enemy data and its abilities.

var _enemy: EnemyData


func before_each() -> void:
	_enemy = load("res://data/enemies/shard_serpent.tres") as EnemyData


func test_shard_serpent_loads() -> void:
	assert_not_null(_enemy, "shard_serpent.tres should load")


func test_id_matches() -> void:
	assert_eq(_enemy.id, &"shard_serpent")


func test_display_name() -> void:
	assert_eq(_enemy.display_name, "Shard Serpent")


func test_hp_around_80() -> void:
	assert_between(_enemy.max_hp, 60, 100, "HP should be ~80")


func test_ai_type_basic() -> void:
	assert_eq(
		_enemy.ai_type, EnemyData.AiType.BASIC,
		"Should use BASIC AI",
	)


func test_weak_to_earth() -> void:
	var found := false
	for w in _enemy.weaknesses:
		if int(w) == AbilityData.Element.EARTH:
			found = true
			break
	assert_true(found, "Should be weak to Earth (blunt/impact)")


func test_has_three_abilities() -> void:
	assert_eq(
		_enemy.abilities.size(), 3,
		"Should have 3 abilities (Crystal Strike, Burrow, Shatter)",
	)


func test_crystal_strike_ability() -> void:
	var cs: AbilityData = load("res://data/abilities/crystal_strike.tres")
	assert_not_null(cs, "crystal_strike.tres should load")
	assert_eq(cs.id, &"crystal_strike")
	assert_gt(cs.damage_base, 0, "Crystal Strike should deal damage")
	assert_eq(cs.status_effect, "stun", "Should have stun chance")
	assert_gt(cs.status_chance, 0.0, "Stun chance should be > 0")


func test_burrow_ability() -> void:
	var b: AbilityData = load("res://data/abilities/burrow.tres")
	assert_not_null(b, "burrow.tres should load")
	assert_eq(b.id, &"burrow")
	assert_eq(
		b.target_type, AbilityData.TargetType.SELF,
		"Burrow should target self",
	)


func test_shatter_ability() -> void:
	var s: AbilityData = load("res://data/abilities/shatter.tres")
	assert_not_null(s, "shatter.tres should load")
	assert_eq(s.id, &"shatter")
	assert_eq(
		s.target_type, AbilityData.TargetType.ALL_ENEMIES,
		"Shatter should be AoE",
	)
	assert_gt(s.damage_base, 0, "Shatter should deal damage")


func test_prismfall_encounter_pool_includes_serpent() -> void:
	var serpent := load("res://data/enemies/shard_serpent.tres")
	var harpy := load("res://data/enemies/gale_harpy.tres")
	var wisp := load("res://data/enemies/cinder_wisp.tres")
	var specter := load("res://data/enemies/hollow_specter.tres")
	var sentinel := load("res://data/enemies/ancient_sentinel.tres")
	var hound := load("res://data/enemies/ember_hound.tres")
	var pool := PrismfallApproachEncounters.build_pool(
		harpy, wisp, specter, sentinel, hound, serpent,
	)
	var has_serpent := false
	for entry: EncounterPoolEntry in pool:
		for enemy: Resource in entry.enemies:
			var ed := enemy as EnemyData
			if ed and ed.id == &"shard_serpent":
				has_serpent = true
				break
	assert_true(has_serpent, "Pool should include Shard Serpent")
