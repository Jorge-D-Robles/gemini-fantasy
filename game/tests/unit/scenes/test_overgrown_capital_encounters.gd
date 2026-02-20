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
