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
