extends GutTest

## Tests for OvergrownCapitalEncounters.build_pool() — verifies pool entries
## are built correctly for each combination of enemy resources.

const Helpers := preload("res://tests/helpers/test_helpers.gd")


func _make_enemy(id: StringName = &"test_enemy") -> Resource:
	return Helpers.make_battler_data({"id": id})


func test_build_pool_all_null_returns_empty() -> void:
	var pool := OvergrownCapitalEncounters.build_pool(null, null)
	assert_eq(pool.size(), 0, "All-null resources yields empty pool")


func test_build_pool_only_memory_bloom() -> void:
	var bloom := _make_enemy(&"memory_bloom")
	var pool := OvergrownCapitalEncounters.build_pool(bloom, null)
	assert_gt(pool.size(), 0, "bloom solo must have at least 1 entry")


func test_build_pool_only_creeping_vine() -> void:
	var vine := _make_enemy(&"creeping_vine")
	var pool := OvergrownCapitalEncounters.build_pool(null, vine)
	assert_gt(pool.size(), 0, "vine solo must have at least 1 entry")


func test_build_pool_both_resources_returns_min_entries() -> void:
	var bloom := _make_enemy(&"memory_bloom")
	var vine := _make_enemy(&"creeping_vine")
	var pool := OvergrownCapitalEncounters.build_pool(bloom, vine)
	assert_gte(pool.size(), 4, "both resources must yield at least 4 entries")


func test_all_pool_weights_positive() -> void:
	var bloom := _make_enemy(&"memory_bloom")
	var vine := _make_enemy(&"creeping_vine")
	var pool := OvergrownCapitalEncounters.build_pool(bloom, vine)
	for entry: EncounterPoolEntry in pool:
		assert_gt(entry.weight, 0.0, "every entry weight must be positive")


func test_build_pool_all_three_returns_more_entries() -> void:
	var bloom := _make_enemy(&"memory_bloom")
	var vine := _make_enemy(&"creeping_vine")
	var nomad := _make_enemy(&"echo_nomad")
	var pool := OvergrownCapitalEncounters.build_pool(bloom, vine, nomad)
	assert_gte(pool.size(), 6, "all three enemies must yield at least 6 entries")


func test_build_pool_null_nomad_still_yields_four_entries() -> void:
	var bloom := _make_enemy(&"memory_bloom")
	var vine := _make_enemy(&"creeping_vine")
	var pool := OvergrownCapitalEncounters.build_pool(bloom, vine, null)
	assert_gte(pool.size(), 4, "null nomad should not break existing pool entries")


func test_echo_nomad_tres_loads() -> void:
	var nomad := load("res://data/enemies/echo_nomad.tres") as EnemyData
	assert_not_null(nomad, "echo_nomad.tres must load")
	assert_eq(nomad.id, &"echo_nomad", "id must be echo_nomad")


func test_echo_nomad_stats_magic_biased() -> void:
	var nomad := load("res://data/enemies/echo_nomad.tres") as EnemyData
	assert_not_null(nomad)
	assert_gt(nomad.magic, nomad.attack, "Echo Nomad must be magic-biased")
	assert_gte(nomad.max_hp, 80, "Echo Nomad HP should be ~90")
	assert_lte(nomad.max_hp, 110, "Echo Nomad HP should be ~90")
