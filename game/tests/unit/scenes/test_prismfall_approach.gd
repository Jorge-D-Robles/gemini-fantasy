extends GutTest

## Tests for Prismfall Approach scene modules — map structure and encounter pool.

const MAP = preload("res://scenes/prismfall_approach/prismfall_approach_map.gd")
const Helpers := preload("res://tests/helpers/test_helpers.gd")

const MAP_COLS: int = 40
const MAP_ROWS: int = 24


func _make_enemy(id: StringName = &"test_enemy") -> Resource:
	return Helpers.make_battler_data({"id": id})


# -- Map structure --

func test_map_dimensions_match_constants() -> void:
	assert_eq(MAP.COLS, MAP_COLS, "COLS constant must be 40")
	assert_eq(MAP.ROWS, MAP_ROWS, "ROWS constant must be 24")


func test_ground_noise_seed_defined() -> void:
	assert_true(MAP.GROUND_NOISE_SEED != 0, "GROUND_NOISE_SEED must be non-zero")


func test_ground_entries_nonempty() -> void:
	assert_true(MAP.GROUND_ENTRIES.size() > 0, "GROUND_ENTRIES must have at least one entry")


func test_ground_entries_have_threshold_and_atlas() -> void:
	for entry: Dictionary in MAP.GROUND_ENTRIES:
		assert_true(entry.has("threshold"), "Each GROUND_ENTRY must have a threshold key")
		assert_true(entry.has("atlas"), "Each GROUND_ENTRY must have an atlas key")


func test_ground_catchall_entry_is_minus_one() -> void:
	var last: Dictionary = MAP.GROUND_ENTRIES[MAP.GROUND_ENTRIES.size() - 1]
	assert_eq(last.get("threshold", 0.0), -1.0, "Last GROUND_ENTRY threshold must be -1.0 (catch-all)")


func test_detail_entries_nonempty() -> void:
	assert_true(MAP.DETAIL_ENTRIES.size() > 0, "DETAIL_ENTRIES must have at least one entry")


func test_path_map_has_24_rows() -> void:
	assert_eq(MAP.PATH_MAP.size(), MAP_ROWS, "PATH_MAP must have 24 rows")


func test_all_path_map_rows_are_40_chars() -> void:
	for row_idx: int in range(MAP.PATH_MAP.size()):
		assert_eq(
			MAP.PATH_MAP[row_idx].length(),
			MAP_COLS,
			"PATH_MAP row %d must be 40 chars" % row_idx,
		)


func test_path_present_in_interior_rows() -> void:
	var has_path: bool = false
	for row_idx: int in range(2, 23):
		if MAP.PATH_MAP[row_idx].contains("P"):
			has_path = true
			break
	assert_true(has_path, "PATH_MAP rows 2-22 must contain path tiles")


# -- Encounter pool --

func test_build_pool_all_null_returns_empty() -> void:
	var pool := PrismfallApproachEncounters.build_pool(null, null, null, null, null)
	assert_eq(pool.size(), 0, "All-null pool must be empty")


func test_build_pool_only_gale_harpy_returns_2_entries() -> void:
	var harpy := _make_enemy(&"gale_harpy")
	var pool := PrismfallApproachEncounters.build_pool(harpy, null, null, null, null)
	assert_eq(pool.size(), 2, "Harpy solo + harpy pair = 2 entries")


func test_build_pool_gale_harpy_and_cinder_wisp_returns_5_entries() -> void:
	var harpy := _make_enemy(&"gale_harpy")
	var wisp := _make_enemy(&"cinder_wisp")
	var pool := PrismfallApproachEncounters.build_pool(harpy, wisp, null, null, null)
	# harpy solo, harpy pair, wisp solo, wisp pair, harpy+wisp mixed = 5
	assert_eq(pool.size(), 5, "Harpy + wisp = 5 entries")


func test_build_pool_all_resources_returns_10_entries() -> void:
	var harpy := _make_enemy(&"gale_harpy")
	var wisp := _make_enemy(&"cinder_wisp")
	var specter := _make_enemy(&"hollow_specter")
	var sentinel := _make_enemy(&"ancient_sentinel")
	var hound := _make_enemy(&"ember_hound")
	var pool := PrismfallApproachEncounters.build_pool(harpy, wisp, specter, sentinel, hound)
	assert_eq(pool.size(), 10, "Full enemy set yields 10 pool entries")


func test_build_pool_mixed_not_added_when_wisp_missing() -> void:
	var harpy := _make_enemy(&"gale_harpy")
	var pool := PrismfallApproachEncounters.build_pool(harpy, null, null, null, null)
	assert_eq(pool.size(), 2, "No harpy+wisp mixed entry when wisp is null")
