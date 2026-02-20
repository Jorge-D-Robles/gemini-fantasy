extends GutTest

## Tests for RootHollowShop — flag-conditional shop item path helper.
## Verifies that compute_item_paths() returns base items always, and
## appends Forest Remedy + Crystal Wick only when iris_recruited is set.

const RootHollowShop = preload("res://scenes/roothollow/roothollow_shop.gd")

const FOREST_REMEDY_PATH: String = "res://data/items/forest_remedy.tres"
const CRYSTAL_WICK_PATH: String = "res://data/items/crystal_wick.tres"
const BASE_PATHS: Array[String] = [
	"res://data/items/potion.tres",
	"res://data/items/ether.tres",
]


func test_base_paths_always_present() -> void:
	var result: Array[String] = RootHollowShop.compute_item_paths(
		BASE_PATHS, {},
	)
	for path: String in BASE_PATHS:
		assert_true(path in result, "Base path should always be included: %s" % path)


func test_iris_items_absent_without_flag() -> void:
	var result: Array[String] = RootHollowShop.compute_item_paths(
		BASE_PATHS, {},
	)
	assert_false(
		FOREST_REMEDY_PATH in result,
		"Forest Remedy should not appear without iris_recruited",
	)
	assert_false(
		CRYSTAL_WICK_PATH in result,
		"Crystal Wick should not appear without iris_recruited",
	)


func test_iris_items_present_with_flag() -> void:
	var result: Array[String] = RootHollowShop.compute_item_paths(
		BASE_PATHS, {"iris_recruited": true},
	)
	assert_true(
		FOREST_REMEDY_PATH in result,
		"Forest Remedy should appear when iris_recruited",
	)
	assert_true(
		CRYSTAL_WICK_PATH in result,
		"Crystal Wick should appear when iris_recruited",
	)


func test_base_paths_still_present_with_flag() -> void:
	var result: Array[String] = RootHollowShop.compute_item_paths(
		BASE_PATHS, {"iris_recruited": true},
	)
	for path: String in BASE_PATHS:
		assert_true(
			path in result, "Base path present when iris_recruited: %s" % path,
		)


func test_returns_array_of_strings() -> void:
	var result: Array[String] = RootHollowShop.compute_item_paths(
		BASE_PATHS, {},
	)
	assert_true(result is Array, "Should return an Array")
	assert_gt(result.size(), 0, "Should not be empty")


func test_empty_base_paths_with_no_flag() -> void:
	var result: Array[String] = RootHollowShop.compute_item_paths(
		[], {},
	)
	assert_eq(result.size(), 0, "Empty base + no flag = empty result")


func test_empty_base_paths_with_flag() -> void:
	var result: Array[String] = RootHollowShop.compute_item_paths(
		[], {"iris_recruited": true},
	)
	assert_eq(
		result.size(), 2, "Empty base + iris flag = exactly 2 iris items",
	)
