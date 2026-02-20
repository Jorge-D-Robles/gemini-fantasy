extends GutTest

## Tests for Verdant Forest map constants — canopy coverage and camera bounds.
## Regression guards for T-0049: camera limit_bottom must match map height.

const VerdantForest = preload("res://scenes/verdant_forest/verdant_forest_map.gd")

const MAP_ROWS: int = 25
const TILE_SIZE_PX: int = 16
## Camera2D limit_bottom in verdant_forest.tscn must equal this value.
const EXPECTED_CAMERA_LIMIT_BOTTOM: int = MAP_ROWS * TILE_SIZE_PX


func test_canopy_map_south_half_has_tiles() -> void:
	## Rows 15-22 must not all be blank — trunks in rows 17-23 need
	## canopy tiles above them on the AbovePlayer layer.
	var any_non_empty: bool = false
	for row_idx: int in range(15, 23):
		if VerdantForest.CANOPY_MAP[row_idx].strip_edges() != "":
			any_non_empty = true
			break
	assert_true(
		any_non_empty,
		"At least one of CANOPY_MAP rows 15-22 should have canopy tiles",
	)


## Regression guard for T-0049 (part 1): GROUND_MAP must have exactly 25 rows
## so the map is 400 px tall — matching Camera2D limit_bottom in the .tscn.
func test_ground_map_has_25_rows_400px_tall() -> void:
	var map_height_px: int = VerdantForest.GROUND_MAP.size() * TILE_SIZE_PX
	assert_eq(
		map_height_px,
		EXPECTED_CAMERA_LIMIT_BOTTOM,
		"GROUND_MAP must have 25 rows (400 px tall) to match Camera2D limit_bottom=400",
	)


## Regression guard for T-0049 (part 2): verdant_forest.tscn must contain
## limit_bottom = 400 so the camera covers all 25 map rows.
func test_verdant_forest_tscn_camera_limit_bottom_is_400() -> void:
	var tscn_path: String = "res://scenes/verdant_forest/verdant_forest.tscn"
	var file := FileAccess.open(tscn_path, FileAccess.READ)
	assert_not_null(file, "verdant_forest.tscn must be readable")
	if file == null:
		return
	var content: String = file.get_as_text()
	file.close()
	assert_true(
		content.contains("limit_bottom = 400"),
		"verdant_forest.tscn Camera2D must have limit_bottom = 400 (T-0049 regression guard)",
	)
