extends GutTest

## Tests for OvergrownRuinsEncounters.build_pool() — verifies pool entries
## are built correctly for each combination of enemy resources.

const Helpers := preload("res://tests/helpers/test_helpers.gd")


func _make_enemy(id: StringName = &"test_enemy") -> Resource:
	return Helpers.make_battler_data({"id": id})


func test_build_pool_all_null_returns_empty() -> void:
	var pool := OvergrownRuinsEncounters.build_pool(null, null)
	assert_eq(pool.size(), 0, "All-null resources yields empty pool")


func test_build_pool_only_memory_bloom_returns_2_entries() -> void:
	var bloom := _make_enemy(&"memory_bloom")
	var pool := OvergrownRuinsEncounters.build_pool(bloom, null)
	assert_eq(pool.size(), 2, "Bloom solo + bloom pair = 2 entries")


func test_build_pool_only_creeping_vine_returns_1_entry() -> void:
	var vine := _make_enemy(&"creeping_vine")
	var pool := OvergrownRuinsEncounters.build_pool(null, vine)
	assert_eq(pool.size(), 1, "Vine solo = 1 entry (no mixed without bloom)")


func test_build_pool_both_resources_returns_4_entries() -> void:
	var bloom := _make_enemy(&"memory_bloom")
	var vine := _make_enemy(&"creeping_vine")
	var pool := OvergrownRuinsEncounters.build_pool(bloom, vine)
	assert_eq(pool.size(), 4, "bloom solo, bloom pair, vine solo, bloom+vine mixed = 4 entries")


func test_build_pool_mixed_entry_only_when_both_present() -> void:
	var bloom := _make_enemy(&"memory_bloom")
	var vine := _make_enemy(&"creeping_vine")
	# With both, the 4th entry is the mixed [bloom, vine] group
	var pool := OvergrownRuinsEncounters.build_pool(bloom, vine)
	var mixed_entry: EncounterPoolEntry = pool[3] as EncounterPoolEntry
	assert_eq(mixed_entry.enemies.size(), 2, "Mixed entry has 2 enemies")
