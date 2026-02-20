extends GutTest

## Tests for T-0133: Save slot summary (location + timestamp) on Continue button.
## Covers TitleScreen.compute_save_summary() static helper.

const TitleScreenScript := preload("res://ui/title_screen/title_screen.gd")
const SP := preload("res://systems/scene_paths.gd")


# -- compute_save_summary --


func test_compute_save_summary_empty_data_returns_empty_strings() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({})
	assert_eq(result["location"], "", "Empty save data should give empty location")
	assert_eq(result["time_str"], "", "Empty save data should give empty time")


func test_compute_save_summary_roothollow_resolves() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({
		"scene_path": SP.ROOTHOLLOW,
		"timestamp": 0,
	})
	assert_eq(result["location"], "Roothollow", "Roothollow path should resolve")


func test_compute_save_summary_verdant_forest_resolves() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({
		"scene_path": SP.VERDANT_FOREST,
		"timestamp": 0,
	})
	assert_eq(result["location"], "Verdant Forest", "Verdant Forest path should resolve")


func test_compute_save_summary_overgrown_ruins_resolves() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({
		"scene_path": SP.OVERGROWN_RUINS,
		"timestamp": 0,
	})
	assert_eq(result["location"], "Overgrown Ruins", "Overgrown Ruins path should resolve")


func test_compute_save_summary_zero_timestamp_returns_empty_time() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({
		"scene_path": SP.ROOTHOLLOW,
		"timestamp": 0,
	})
	assert_eq(result["time_str"], "", "Zero timestamp should give empty time string")


func test_compute_save_summary_valid_timestamp_returns_nonempty() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({
		"scene_path": SP.ROOTHOLLOW,
		"timestamp": 1708387200,
	})
	assert_true(
		result["time_str"].length() > 0,
		"Valid timestamp should produce a non-empty time string",
	)


func test_compute_save_summary_missing_timestamp_returns_empty_time() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({
		"scene_path": SP.ROOTHOLLOW,
	})
	assert_eq(result["time_str"], "", "Missing timestamp key should give empty time")


func test_compute_save_summary_unknown_scene_returns_empty_location() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({
		"scene_path": "res://scenes/unknown/foo.tscn",
		"timestamp": 0,
	})
	assert_eq(
		result["location"], "",
		"Unknown scene path should give empty location",
	)


# -- compute_playtime_str --


func test_compute_playtime_str_zero_returns_empty() -> void:
	assert_eq(
		TitleScreenScript.compute_playtime_str(0.0),
		"",
		"0 seconds should return empty (not shown)",
	)


func test_compute_playtime_str_less_than_one_minute_returns_empty() -> void:
	assert_eq(
		TitleScreenScript.compute_playtime_str(59.9),
		"",
		"Less than 60 seconds should return empty",
	)


func test_compute_playtime_str_one_minute() -> void:
	assert_eq(
		TitleScreenScript.compute_playtime_str(60.0),
		"00:01",
		"60 seconds should format as 00:01",
	)


func test_compute_playtime_str_one_hour() -> void:
	assert_eq(
		TitleScreenScript.compute_playtime_str(3600.0),
		"01:00",
		"3600 seconds should format as 01:00",
	)


func test_compute_playtime_str_ninety_minutes() -> void:
	assert_eq(
		TitleScreenScript.compute_playtime_str(5400.0),
		"01:30",
		"5400 seconds should format as 01:30",
	)


func test_compute_save_summary_includes_playtime_str_key() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({})
	assert_true("playtime_str" in result, "Summary must include playtime_str key")


func test_compute_save_summary_with_playtime_formats_correctly() -> void:
	var result: Dictionary = TitleScreenScript.compute_save_summary({
		"scene_path": SP.ROOTHOLLOW,
		"timestamp": 0,
		"playtime_seconds": 3661.0,
	})
	assert_eq(result["playtime_str"], "01:01", "3661 seconds = 01:01")
