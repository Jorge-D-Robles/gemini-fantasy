extends GutTest

## Tests for Roothollow tilemap data constants — verifies map dimensions
## and ground detail density target (≤15% of visible open area).

const Maps = preload("res://scenes/roothollow/roothollow_maps.gd")


func test_ground_map_has_correct_row_count() -> void:
	assert_eq(
		Maps.GROUND_MAP.size(), Maps.MAP_ROWS,
		"GROUND_MAP should have MAP_ROWS rows",
	)


func test_ground_map_has_correct_column_count() -> void:
	for i in Maps.GROUND_MAP.size():
		assert_eq(
			Maps.GROUND_MAP[i].length(), Maps.MAP_COLS,
			"GROUND_MAP row %d should have MAP_COLS chars" % i,
		)


func test_decor_map_has_correct_row_count() -> void:
	assert_eq(
		Maps.DECOR_MAP.size(), Maps.MAP_ROWS,
		"DECOR_MAP should have MAP_ROWS rows",
	)


func test_path_map_has_correct_row_count() -> void:
	assert_eq(
		Maps.PATH_MAP.size(), Maps.MAP_ROWS,
		"PATH_MAP should have MAP_ROWS rows",
	)


func test_border_map_has_correct_row_count() -> void:
	assert_eq(
		Maps.BORDER_MAP.size(), Maps.MAP_ROWS,
		"BORDER_MAP should have MAP_ROWS rows",
	)


static func _count_decor_tiles() -> int:
	var count: int = 0
	for row_str: String in Maps.DECOR_MAP:
		for ch: String in row_str:
			if ch != " ":
				count += 1
	return count


static func _count_open_tiles() -> int:
	## Count tiles in the playable area (rows 3-23) that are NOT
	## border canopy (T in BORDER_MAP).
	var count: int = 0
	for row_idx: int in range(3, 24):
		var border_row: String = Maps.BORDER_MAP[row_idx]
		for col_idx: int in border_row.length():
			if border_row[col_idx] != "T":
				count += 1
	return count


func test_decor_density_at_most_fifteen_percent() -> void:
	var decor_count: int = _count_decor_tiles()
	var open_count: int = _count_open_tiles()
	var density: float = float(decor_count) / float(open_count) * 100.0
	assert_true(
		density <= 15.0,
		"Decor density should be ≤15%%, got %.1f%% (%d/%d)"
		% [density, decor_count, open_count],
	)


func test_decor_density_at_least_ten_percent() -> void:
	var decor_count: int = _count_decor_tiles()
	var open_count: int = _count_open_tiles()
	var density: float = float(decor_count) / float(open_count) * 100.0
	assert_true(
		density >= 10.0,
		"Decor density should be ≥10%%, got %.1f%% (%d/%d)"
		% [density, decor_count, open_count],
	)
