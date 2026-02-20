extends GutTest

## Tests for EncounterSystem step counting, encounter selection logic,
## and the two-phase warning → trigger flow.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _system: EncounterSystem


func before_each() -> void:
	_system = load("res://systems/encounter/encounter_system.gd").new()
	add_child_autofree(_system)


func _make_pool_entry(
	weight: float,
	enemy_count: int = 1,
) -> EncounterPoolEntry:
	var enemies: Array[Resource] = []
	for i in enemy_count:
		enemies.append(Helpers.make_battler_data({
			"id": &"enemy_%d" % i,
			"display_name": "Enemy %d" % i,
		}))
	return EncounterPoolEntry.create(enemies, weight)


func test_select_enemy_group_empty_pool() -> void:
	_system.enemy_pool = []
	var result := _system._select_enemy_group()
	assert_eq(result.size(), 0, "Empty pool returns empty array")


func test_select_enemy_group_single_entry() -> void:
	var entry := _make_pool_entry(1.0, 2)
	_system.enemy_pool = [entry]
	var result := _system._select_enemy_group()
	assert_eq(result.size(), 2, "Single entry always selected")
	assert_same(result, entry.enemies, "Returns the entry's enemies")


func test_select_enemy_group_returns_valid_entry() -> void:
	var e1 := _make_pool_entry(1.0, 1)
	var e2 := _make_pool_entry(1.0, 2)
	var e3 := _make_pool_entry(1.0, 3)
	_system.enemy_pool = [e1, e2, e3]

	# Run 50 times to verify all results are valid pool entries
	for i in 50:
		var result := _system._select_enemy_group()
		assert_true(
			result == e1.enemies or result == e2.enemies or result == e3.enemies,
			"Result must be from the pool (iteration %d)" % i,
		)


func test_select_enemy_group_respects_weights() -> void:
	# Entry with weight 100 should be selected almost every time
	var heavy := _make_pool_entry(100.0, 1)
	var light := _make_pool_entry(0.001, 2)
	_system.enemy_pool = [heavy, light]

	var heavy_count: int = 0
	var runs: int = 200
	for i in runs:
		var result := _system._select_enemy_group()
		if result == heavy.enemies:
			heavy_count += 1

	assert_gt(heavy_count, 180, "Heavy weight entry selected >90%% of the time")


func test_step_counter_respects_min_steps() -> void:
	_system.min_steps_between = 5
	_system.encounter_rate = 1.0
	_system.enemy_pool = [_make_pool_entry(1.0)]
	watch_signals(_system)

	# Take 4 steps — should NOT trigger warning or encounter
	for i in 4:
		_system._on_step()
	assert_signal_not_emitted(
		_system, "encounter_triggered",
		"No encounter before min_steps_between",
	)
	assert_signal_not_emitted(
		_system, "encounter_warning",
		"No warning before min_steps_between",
	)

	# 5th step should emit warning (not trigger yet)
	_system._on_step()
	assert_signal_emitted(
		_system, "encounter_warning",
		"Warning emits at min_steps_between with rate 1.0",
	)
	assert_signal_not_emitted(
		_system, "encounter_triggered",
		"Trigger not emitted until timeout",
	)

	# Complete the warning phase
	_system._on_warning_timeout()
	assert_signal_emitted(
		_system, "encounter_triggered",
		"Trigger emitted after warning timeout",
	)


func test_step_counter_resets_after_trigger() -> void:
	_system.min_steps_between = 2
	_system.encounter_rate = 1.0
	_system.enemy_pool = [_make_pool_entry(1.0)]
	watch_signals(_system)

	# Trigger first encounter (steps 1, 2 → warning)
	_system._on_step()
	_system._on_step()
	# Complete the warning phase
	_system._on_warning_timeout()
	assert_signal_emit_count(
		_system, "encounter_triggered", 1,
		"First encounter triggered",
	)

	# Next step should NOT trigger (counter reset to 0, need min_steps again)
	_system._on_step()
	assert_signal_emit_count(
		_system, "encounter_triggered", 1,
		"Counter resets — no immediate re-trigger",
	)


func test_reset_steps() -> void:
	_system._step_counter = 10
	_system._distance_accumulator = 50.0
	_system.reset_steps()
	assert_eq(_system._step_counter, 0, "Step counter reset")
	assert_eq(_system._distance_accumulator, 0.0, "Distance accumulator reset")


func test_zero_encounter_rate_never_triggers() -> void:
	_system.min_steps_between = 0
	_system.encounter_rate = 0.0
	_system.enemy_pool = [_make_pool_entry(1.0)]
	watch_signals(_system)

	for i in 100:
		_system._on_step()
	assert_signal_not_emitted(
		_system, "encounter_triggered",
		"Zero rate never triggers encounters",
	)


# -- encounter_warning two-phase flow --

func test_encounter_warning_signal_defined() -> void:
	assert_true(
		_system.has_signal("encounter_warning"),
		"encounter_warning signal is defined on EncounterSystem",
	)


func test_warning_in_progress_initially_false() -> void:
	assert_false(
		_system._warning_in_progress,
		"Warning flag starts false",
	)


func test_on_step_emits_warning_not_trigger() -> void:
	_system.min_steps_between = 1
	_system.encounter_rate = 1.0
	_system.enemy_pool = [_make_pool_entry(1.0)]
	watch_signals(_system)

	_system._on_step()

	assert_signal_emitted(
		_system, "encounter_warning",
		"encounter_warning emitted on successful roll",
	)
	assert_signal_not_emitted(
		_system, "encounter_triggered",
		"encounter_triggered NOT emitted until timeout",
	)


func test_warning_in_progress_blocks_steps() -> void:
	_system.min_steps_between = 1
	_system.encounter_rate = 1.0
	_system.enemy_pool = [_make_pool_entry(1.0)]
	_system._warning_in_progress = true
	watch_signals(_system)

	_system._on_step()

	assert_signal_not_emitted(
		_system, "encounter_warning",
		"Steps blocked during active warning",
	)
	assert_signal_not_emitted(
		_system, "encounter_triggered",
		"Trigger blocked during active warning",
	)


func test_on_warning_timeout_emits_trigger() -> void:
	_system.enemy_pool = [_make_pool_entry(1.0)]
	_system._pending_group = _system.enemy_pool[0].enemies
	_system._warning_in_progress = true
	watch_signals(_system)

	_system._on_warning_timeout()

	assert_signal_emitted(
		_system, "encounter_triggered",
		"encounter_triggered emitted after timeout",
	)
	assert_false(
		_system._warning_in_progress,
		"Warning flag cleared after timeout",
	)


func test_pending_group_cleared_after_timeout() -> void:
	_system.enemy_pool = [_make_pool_entry(1.0)]
	_system._pending_group = _system.enemy_pool[0].enemies
	_system._warning_in_progress = true

	_system._on_warning_timeout()

	assert_eq(
		_system._pending_group.size(), 0,
		"Pending group cleared after timeout",
	)
