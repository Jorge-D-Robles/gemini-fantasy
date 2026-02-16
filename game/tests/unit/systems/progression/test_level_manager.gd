extends GutTest

## Tests for LevelManager — XP calculation, leveling, and stat scaling.

var _character: CharacterData


func before_each() -> void:
	_character = CharacterData.new()
	_character.id = &"test_hero"
	_character.display_name = "Test Hero"
	_character.max_hp = 100
	_character.max_ee = 50
	_character.attack = 10
	_character.magic = 10
	_character.defense = 10
	_character.resistance = 10
	_character.speed = 10
	_character.luck = 10
	_character.hp_growth = 10.0
	_character.ee_growth = 5.0
	_character.attack_growth = 1.5
	_character.magic_growth = 1.5
	_character.defense_growth = 1.5
	_character.resistance_growth = 1.5
	_character.speed_growth = 1.0
	_character.luck_growth = 1.0


# --- xp_for_level ---

func test_xp_for_level_1() -> void:
	assert_eq(LevelManager.xp_for_level(1), 100)


func test_xp_for_level_2() -> void:
	assert_eq(LevelManager.xp_for_level(2), 400)


func test_xp_for_level_3() -> void:
	assert_eq(LevelManager.xp_for_level(3), 900)


func test_xp_for_level_10() -> void:
	assert_eq(LevelManager.xp_for_level(10), 10000)


# --- xp_to_next_level ---

func test_xp_to_next_level_from_zero() -> void:
	# Level 1, 0 XP. Next level (2) needs 400 XP total.
	assert_eq(LevelManager.xp_to_next_level(_character), 400)


func test_xp_to_next_level_with_partial_xp() -> void:
	_character.current_xp = 200
	assert_eq(LevelManager.xp_to_next_level(_character), 200)


# --- can_level_up ---

func test_can_level_up_false_when_insufficient() -> void:
	_character.current_xp = 399
	assert_false(LevelManager.can_level_up(_character))


func test_can_level_up_true_at_exact_threshold() -> void:
	_character.current_xp = 400
	assert_true(LevelManager.can_level_up(_character))


func test_can_level_up_true_with_excess() -> void:
	_character.current_xp = 500
	assert_true(LevelManager.can_level_up(_character))


# --- get_stat_at_level ---

func test_get_stat_at_level_1_returns_base() -> void:
	assert_eq(LevelManager.get_stat_at_level(100, 10.0, 1), 100)


func test_get_stat_at_level_2() -> void:
	# 100 + floor(10.0 * 1) = 110
	assert_eq(LevelManager.get_stat_at_level(100, 10.0, 2), 110)


func test_get_stat_at_level_5() -> void:
	# 100 + floor(10.0 * 4) = 140
	assert_eq(LevelManager.get_stat_at_level(100, 10.0, 5), 140)


func test_get_stat_at_level_fractional_growth() -> void:
	# 10 + floor(1.5 * 2) = 10 + 3 = 13
	assert_eq(LevelManager.get_stat_at_level(10, 1.5, 3), 13)


func test_get_stat_at_level_fractional_truncation() -> void:
	# 10 + floor(1.5 * 1) = 10 + 1 = 11
	assert_eq(LevelManager.get_stat_at_level(10, 1.5, 2), 11)


# --- level_up ---

func test_level_up_increments_level() -> void:
	_character.current_xp = 400
	LevelManager.level_up(_character)
	assert_eq(_character.level, 2)


func test_level_up_returns_stat_changes() -> void:
	_character.current_xp = 400
	var changes := LevelManager.level_up(_character)
	# hp: 110 - 100 = 10
	assert_eq(changes["hp"], 10)
	# ee: 55 - 50 = 5
	assert_eq(changes["ee"], 5)
	# attack: 11 - 10 = 1
	assert_eq(changes["attack"], 1)
	# speed: 11 - 10 = 1
	assert_eq(changes["speed"], 1)


func test_level_up_does_not_modify_base_stats() -> void:
	_character.current_xp = 400
	LevelManager.level_up(_character)
	# Base stats stay at level-1 values — scaling happens in Battler
	assert_eq(_character.max_hp, 100)
	assert_eq(_character.attack, 10)


func test_level_up_consecutive_returns_correct_deltas() -> void:
	_character.current_xp = 900
	var first := LevelManager.level_up(_character)
	var second := LevelManager.level_up(_character)
	assert_eq(_character.level, 3)
	# L1->L2 hp: 110-100=10, L2->L3 hp: 120-110=10
	assert_eq(first["hp"], 10)
	assert_eq(second["hp"], 10)
	# L1->L2 attack: 11-10=1, L2->L3 attack: 13-11=2 (floor(1.5*2)-floor(1.5*1))
	assert_eq(first["attack"], 1)
	assert_eq(second["attack"], 2)


# --- add_xp ---

func test_add_xp_increases_current_xp() -> void:
	LevelManager.add_xp(_character, 200)
	assert_eq(_character.current_xp, 200)


func test_add_xp_no_level_up() -> void:
	var results := LevelManager.add_xp(_character, 200)
	assert_eq(results.size(), 0)
	assert_eq(_character.level, 1)


func test_add_xp_single_level_up() -> void:
	var results := LevelManager.add_xp(_character, 400)
	assert_eq(results.size(), 1)
	assert_eq(_character.level, 2)


func test_add_xp_multiple_level_ups() -> void:
	# Level 2 needs 400, level 3 needs 900
	var results := LevelManager.add_xp(_character, 1000)
	assert_eq(results.size(), 2)
	assert_eq(_character.level, 3)


func test_add_xp_preserves_excess() -> void:
	LevelManager.add_xp(_character, 500)
	assert_eq(_character.current_xp, 500)
	assert_eq(_character.level, 2)


func test_add_xp_each_result_has_stat_keys() -> void:
	var results := LevelManager.add_xp(_character, 400)
	assert_eq(results.size(), 1)
	assert_has(results[0], "hp")
	assert_has(results[0], "ee")
	assert_has(results[0], "attack")
	assert_has(results[0], "magic")
	assert_has(results[0], "defense")
	assert_has(results[0], "resistance")
	assert_has(results[0], "speed")
	assert_has(results[0], "luck")


# --- Battler integration ---

func test_battler_loads_level_scaled_stats() -> void:
	_character.level = 5
	var battler := Battler.new()
	add_child_autofree(battler)
	battler.data = _character
	battler.initialize_from_data()
	# max_hp: 100 + floor(10.0 * 4) = 140
	assert_eq(battler.max_hp, 140)
	assert_eq(battler.current_hp, 140)
	# attack: 10 + floor(1.5 * 4) = 10 + 6 = 16
	assert_eq(battler.attack, 16)
	# speed: 10 + floor(1.0 * 4) = 14
	assert_eq(battler.speed, 14)


func test_battler_level_1_stats_unchanged() -> void:
	var battler := Battler.new()
	add_child_autofree(battler)
	battler.data = _character
	battler.initialize_from_data()
	# Level 1: stats should equal base values
	assert_eq(battler.max_hp, 100)
	assert_eq(battler.attack, 10)
	assert_eq(battler.speed, 10)


func test_battler_enemy_data_unaffected() -> void:
	var enemy := BattlerData.new()
	enemy.max_hp = 200
	enemy.attack = 15
	var battler := Battler.new()
	add_child_autofree(battler)
	battler.data = enemy
	battler.initialize_from_data()
	# Non-CharacterData should load stats directly
	assert_eq(battler.max_hp, 200)
	assert_eq(battler.attack, 15)
