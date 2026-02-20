extends GutTest

## Tests for Verdant Forest CANOPY_MAP — verifies south-half canopy
## coverage so trunks in rows 17-23 have AbovePlayer tiles above them.
## Also includes regression guard for T-0049: camera limit_bottom must
## match map height (25 rows * 16 px/tile = 400 px).

const VerdantForest = preload("res://scenes/verdant_forest/verdant_forest_map.gd")

const MAP_ROWS: int = 25
const MAP_COLS: int = 40
const TILE_SIZE_PX: int = 16
## Camera2D limit_bottom in verdant_forest.tscn must equal this value.
const EXPECTED_CAMERA_LIMIT_BOTTOM: int = MAP_ROWS * TILE_SIZE_PX


func test_canopy_map_has_correct_row_count() -> void:
	assert_eq(
		VerdantForest.CANOPY_MAP.size(), MAP_ROWS,
		"CANOPY_MAP should have %d rows" % MAP_ROWS,
	)


func test_canopy_map_rows_are_correct_length() -> void:
	for i: int in VerdantForest.CANOPY_MAP.size():
		assert_eq(
			VerdantForest.CANOPY_MAP[i].length(), MAP_COLS,
			"CANOPY_MAP row %d should be %d chars" % [i, MAP_COLS],
		)


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


func test_canopy_map_trunk_b_row17_has_top_canopy_at_row15() -> void:
	## Trunk B at col 3, row 17. Canopy top-row goes at row 15.
	## Type B canopy: top-left '5' at trunk_col-1=2, top-right '6' at trunk_col=3.
	var row: String = VerdantForest.CANOPY_MAP[15]
	assert_eq(
		row[2], "5",
		"CANOPY_MAP[15] col 2 should be '5' (type-B top-left for trunk B@3,17)",
	)
	assert_eq(
		row[3], "6",
		"CANOPY_MAP[15] col 3 should be '6' (type-B top-right for trunk B@3,17)",
	)


func test_canopy_map_trunk_b_row17_has_bottom_canopy_at_row16() -> void:
	## Trunk B at col 3, row 17. Canopy bottom-row goes at row 16.
	## Type B: bot-left '7' at col 2, bot-right '8' at col 3.
	var row: String = VerdantForest.CANOPY_MAP[16]
	assert_eq(
		row[2], "7",
		"CANOPY_MAP[16] col 2 should be '7' (type-B bot-left for trunk B@3,17)",
	)
	assert_eq(
		row[3], "8",
		"CANOPY_MAP[16] col 3 should be '8' (type-B bot-right for trunk B@3,17)",
	)


func test_canopy_map_trunk_d_row23_has_bottom_canopy_at_row22() -> void:
	## Trunk D at col 4, row 23. Canopy bottom-row goes at row 22.
	## Type D: bot-left 'g' at col 3, bot-right 'h' at col 4.
	var row: String = VerdantForest.CANOPY_MAP[22]
	assert_eq(
		row[3], "g",
		"CANOPY_MAP[22] col 3 should be 'g' (type-D bot-left for trunk D@4,23)",
	)
	assert_eq(
		row[4], "h",
		"CANOPY_MAP[22] col 4 should be 'h' (type-D bot-right for trunk D@4,23)",
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
## If this fails, update Camera2D.limit_bottom in verdant_forest.tscn to 400.
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
