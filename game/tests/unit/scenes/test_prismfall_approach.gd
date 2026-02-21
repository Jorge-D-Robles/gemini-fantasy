extends GutTest

## Tests for Prismfall Approach scene modules — map structure and encounter pool.

const MAP = preload("res://scenes/prismfall_approach/prismfall_approach_map.gd")
const Helpers := preload("res://tests/helpers/test_helpers.gd")

const MAP_COLS: int = 40
const MAP_ROWS: int = 24


func _make_enemy(id: StringName = &"test_enemy") -> Resource:
	return Helpers.make_battler_data({"id": id})


# -- Map structure --

func test_ground_map_has_24_rows() -> void:
	assert_eq(MAP.GROUND_MAP.size(), MAP_ROWS, "GROUND_MAP must have 24 rows")


func test_all_ground_map_rows_are_40_chars() -> void:
	for row_idx: int in range(MAP.GROUND_MAP.size()):
		assert_eq(
			MAP.GROUND_MAP[row_idx].length(),
			MAP_COLS,
			"GROUND_MAP row %d must be 40 chars" % row_idx,
		)


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


func test_detail_map_has_24_rows() -> void:
	assert_eq(MAP.DETAIL_MAP.size(), MAP_ROWS, "DETAIL_MAP must have 24 rows")


func test_all_detail_map_rows_are_40_chars() -> void:
	for row_idx: int in range(MAP.DETAIL_MAP.size()):
		assert_eq(
			MAP.DETAIL_MAP[row_idx].length(),
			MAP_COLS,
			"DETAIL_MAP row %d must be 40 chars" % row_idx,
		)


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
