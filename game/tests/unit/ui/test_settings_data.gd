extends GutTest

## Tests for SettingsData static methods.
## Validates volume math, save/load persistence, and bus control.

const SD := preload("res://ui/settings_menu/settings_data.gd")

const TEST_PATH := "user://test_settings.json"


func after_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(
			ProjectSettings.globalize_path(TEST_PATH)
		)


# -- percent_to_db --


func test_percent_to_db_at_100() -> void:
	var db := SD.percent_to_db(100)
	assert_almost_eq(db, 0.0, 0.01, "100% should be 0 dB")


func test_percent_to_db_at_0() -> void:
	var db := SD.percent_to_db(0)
	assert_eq(db, SD.SILENT_DB, "0% should be SILENT_DB floor")


func test_percent_to_db_at_50() -> void:
	var db := SD.percent_to_db(50)
	var expected := linear_to_db(0.5)
	assert_almost_eq(
		db, expected, 0.01,
		"50% should be ~-6.02 dB",
	)


func test_percent_clamp_over_100() -> void:
	var db := SD.percent_to_db(150)
	assert_almost_eq(
		db, 0.0, 0.01,
		"Values over 100 should clamp to 100% (0 dB)",
	)


func test_percent_clamp_under_0() -> void:
	var db := SD.percent_to_db(-10)
	assert_eq(
		db, SD.SILENT_DB,
		"Values under 0 should clamp to 0% (SILENT_DB)",
	)


# -- db_to_percent --


func test_db_to_percent_roundtrip() -> void:
	for pct in [0, 25, 50, 75, 100]:
		var db := SD.percent_to_db(pct)
		var result := SD.db_to_percent(db)
		assert_eq(
			result, pct,
			"Round-trip for %d%% failed" % pct,
		)


func test_db_to_percent_silent_floor() -> void:
	assert_eq(
		SD.db_to_percent(-100.0), 0,
		"Very low dB should map to 0%",
	)


# -- save / load --


func test_load_settings_defaults() -> void:
	var settings := SD.load_settings_from(TEST_PATH)
	assert_eq(settings["master_volume"], 100)
	assert_eq(settings["bgm_volume"], 100)
	assert_eq(settings["sfx_volume"], 100)


func test_save_and_load_roundtrip() -> void:
	SD.save_settings_to(TEST_PATH, 80, 60, 40)
	var settings := SD.load_settings_from(TEST_PATH)
	assert_eq(settings["master_volume"], 80)
	assert_eq(settings["bgm_volume"], 60)
	assert_eq(settings["sfx_volume"], 40)


func test_load_settings_corrupt_json() -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string("not valid json {{{")
	file = null
	var settings := SD.load_settings_from(TEST_PATH)
	assert_eq(
		settings["master_volume"], 100,
		"Corrupt JSON should return defaults",
	)


func test_save_clamps_values() -> void:
	SD.save_settings_to(TEST_PATH, 150, -10, 50)
	var settings := SD.load_settings_from(TEST_PATH)
	assert_eq(settings["master_volume"], 100, "Over 100 clamped")
	assert_eq(settings["bgm_volume"], 0, "Under 0 clamped")
	assert_eq(settings["sfx_volume"], 50, "Normal value preserved")


# -- apply_volume / get_bus_percent --


func test_apply_volume_sets_bus() -> void:
	SD.apply_volume("Master", 75)
	var idx := AudioServer.get_bus_index("Master")
	var db := AudioServer.get_bus_volume_db(idx)
	var expected := SD.percent_to_db(75)
	assert_almost_eq(
		db, expected, 0.01,
		"Bus volume should match applied percent",
	)
	# Restore
	AudioServer.set_bus_volume_db(idx, 0.0)


func test_apply_volume_invalid_bus() -> void:
	# Should not crash — just warns
	SD.apply_volume("NonExistentBus", 50)
	assert_true(true, "No crash on invalid bus name")


func test_get_bus_percent() -> void:
	var idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(idx, 0.0)
	var pct := SD.get_bus_percent("Master")
	assert_eq(pct, 100, "0 dB should read as 100%")
	# Restore
	AudioServer.set_bus_volume_db(idx, 0.0)
