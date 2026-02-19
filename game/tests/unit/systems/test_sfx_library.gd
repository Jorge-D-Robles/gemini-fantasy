extends GutTest

## Tests for SfxLibrary path constants.

const SfxLib := preload("res://systems/sfx_library.gd")


func test_all_ui_paths_have_ogg_extension() -> void:
	for path: String in SfxLib.ALL_UI_PATHS:
		assert_true(
			path.ends_with(".ogg"),
			"UI path should end with .ogg: " + path,
		)


func test_all_combat_paths_have_ogg_extension() -> void:
	for path: String in SfxLib.ALL_COMBAT_PATHS:
		assert_true(
			path.ends_with(".ogg"),
			"Combat path should end with .ogg: " + path,
		)


func test_all_paths_start_with_res_prefix() -> void:
	for path: String in SfxLib.ALL_PATHS:
		assert_true(
			path.begins_with("res://assets/sfx/"),
			"Path should start with res://assets/sfx/: " + path,
		)


func test_all_paths_count_is_ten() -> void:
	assert_eq(SfxLib.ALL_PATHS.size(), 10)


func test_no_duplicate_paths() -> void:
	var seen := {}
	for path: String in SfxLib.ALL_PATHS:
		assert_false(
			seen.has(path),
			"Duplicate path found: " + path,
		)
		seen[path] = true


func test_ui_paths_in_ui_subdirectory() -> void:
	for path: String in SfxLib.ALL_UI_PATHS:
		assert_true(
			"/ui/" in path,
			"UI path should contain /ui/: " + path,
		)


func test_combat_paths_in_combat_subdirectory() -> void:
	for path: String in SfxLib.ALL_COMBAT_PATHS:
		assert_true(
			"/combat/" in path,
			"Combat path should contain /combat/: " + path,
		)
