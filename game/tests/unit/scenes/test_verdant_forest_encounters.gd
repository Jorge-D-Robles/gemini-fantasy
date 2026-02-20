extends GutTest

## Tests for VerdantForestEncounters.build_pool() — verifies pool entries
## are built correctly for each combination of available enemy resources.

const Helpers := preload("res://tests/helpers/test_helpers.gd")


func _make_enemy(id: StringName = &"test_enemy") -> Resource:
	return Helpers.make_battler_data({"id": id})


func test_build_pool_all_null_returns_empty() -> void:
	var pool := VerdantForestEncounters.build_pool(null, null, null, null, null, null)
	assert_eq(pool.size(), 0, "All-null resources yields empty pool")


func test_build_pool_only_creeping_vine_returns_2_entries() -> void:
	var vine := _make_enemy(&"creeping_vine")
	var pool := VerdantForestEncounters.build_pool(vine, null, null, null, null, null)
	assert_eq(pool.size(), 2, "Vine solo + vine pair = 2 entries")


func test_build_pool_vine_and_stalker_returns_4_entries() -> void:
	# vine solo, vine pair, stalker solo, vine+stalker mixed
	var vine := _make_enemy(&"creeping_vine")
	var stalker := _make_enemy(&"ash_stalker")
	var pool := VerdantForestEncounters.build_pool(vine, stalker, null, null, null, null)
	assert_eq(pool.size(), 4, "Vine + stalker = 4 entries (solo x2, mixed x1, vine pair x1)")


func test_build_pool_all_resources_returns_11_entries() -> void:
	var vine := _make_enemy(&"creeping_vine")
	var stalker := _make_enemy(&"ash_stalker")
	var specter := _make_enemy(&"hollow_specter")
	var sentinel := _make_enemy(&"ancient_sentinel")
	var harpy := _make_enemy(&"gale_harpy")
	var hound := _make_enemy(&"ember_hound")
	var pool := VerdantForestEncounters.build_pool(vine, stalker, specter, sentinel, harpy, hound)
	assert_eq(pool.size(), 11, "Full enemy set yields 11 pool entries")


func test_build_pool_mixed_entry_not_added_when_one_missing() -> void:
	# vine+stalker mixed requires BOTH — if stalker missing, no mixed entry
	var vine := _make_enemy(&"creeping_vine")
	var pool := VerdantForestEncounters.build_pool(vine, null, null, null, null, null)
	# Only vine solo + vine pair — no mixed entries
	assert_eq(pool.size(), 2, "No mixed entries when stalker is null")


func test_build_pool_harpy_hound_mixed_only_when_both_present() -> void:
	var harpy := _make_enemy(&"gale_harpy")
	var hound := _make_enemy(&"ember_hound")
	var pool_only_harpy := VerdantForestEncounters.build_pool(null, null, null, null, harpy, null)
	assert_eq(pool_only_harpy.size(), 1, "Harpy solo only when hound missing")
	var pool_both := VerdantForestEncounters.build_pool(null, null, null, null, harpy, hound)
	assert_eq(pool_both.size(), 3, "Harpy solo + hound solo + mixed when both present")
