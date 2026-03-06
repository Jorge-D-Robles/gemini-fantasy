extends GutTest

## Tests for Merchant's Regret optional mini-boss data.

var _enemy: EnemyData
var _coin_shower: AbilityData
var _desperate_bargain: AbilityData


func before_each() -> void:
	_enemy = load("res://data/enemies/merchants_regret.tres")
	_coin_shower = load("res://data/abilities/coin_shower.tres")
	_desperate_bargain = load(
		"res://data/abilities/desperate_bargain.tres"
	)


func test_enemy_loads() -> void:
	assert_not_null(_enemy, "Enemy should load")


func test_enemy_id() -> void:
	assert_eq(_enemy.id, &"merchants_regret")


func test_enemy_is_boss() -> void:
	assert_eq(
		_enemy.ai_type, EnemyData.AiType.BOSS,
		"Should be BOSS AI",
	)


func test_enemy_hp_around_200() -> void:
	assert_eq(_enemy.max_hp, 200, "HP should be ~200")


func test_enemy_has_two_abilities() -> void:
	assert_eq(
		_enemy.abilities.size(), 2,
		"Should have 2 abilities",
	)


func test_enemy_weak_to_light() -> void:
	assert_has(
		_enemy.weaknesses,
		AbilityData.Element.LIGHT,
		"Should be weak to Light",
	)


func test_enemy_resists_dark() -> void:
	assert_has(
		_enemy.resistances,
		AbilityData.Element.DARK,
		"Should resist Dark",
	)


func test_enemy_gold_reward_high() -> void:
	assert_gt(
		_enemy.gold_reward, 50,
		"Boss should drop substantial gold",
	)


func test_coin_shower_loads() -> void:
	assert_not_null(
		_coin_shower, "Coin Shower ability should load",
	)


func test_coin_shower_is_aoe() -> void:
	assert_eq(
		_coin_shower.target_type,
		AbilityData.TargetType.ALL_ENEMIES,
		"Coin Shower should target ALL_ENEMIES",
	)


func test_desperate_bargain_loads() -> void:
	assert_not_null(
		_desperate_bargain,
		"Desperate Bargain should load",
	)


func test_desperate_bargain_has_status() -> void:
	assert_eq(
		_desperate_bargain.status_effect,
		"defense_down",
		"Should apply defense_down status",
	)


func test_desperate_bargain_high_chance() -> void:
	assert_gt(
		_desperate_bargain.status_chance, 0.5,
		"Should have high status chance",
	)
