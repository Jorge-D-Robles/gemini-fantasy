extends GutTest

## Tests for ScenePaths — centralized scene path constants.
## Verifies all paths end with .tscn and match expected naming.

const SP := preload("res://systems/scene_paths.gd")


func test_roothollow_path_defined() -> void:
	assert_true(
		SP.ROOTHOLLOW.ends_with(".tscn"),
		"ROOTHOLLOW should be a .tscn path",
	)
	assert_true(
		SP.ROOTHOLLOW.contains("roothollow"),
		"ROOTHOLLOW path should contain 'roothollow'",
	)


func test_verdant_forest_path_defined() -> void:
	assert_true(
		SP.VERDANT_FOREST.ends_with(".tscn"),
		"VERDANT_FOREST should be a .tscn path",
	)
	assert_true(
		SP.VERDANT_FOREST.contains("verdant_forest"),
		"VERDANT_FOREST path should contain 'verdant_forest'",
	)


func test_overgrown_ruins_path_defined() -> void:
	assert_true(
		SP.OVERGROWN_RUINS.ends_with(".tscn"),
		"OVERGROWN_RUINS should be a .tscn path",
	)
	assert_true(
		SP.OVERGROWN_RUINS.contains("overgrown_ruins"),
		"OVERGROWN_RUINS path should contain 'overgrown_ruins'",
	)


func test_title_screen_path_defined() -> void:
	assert_true(
		SP.TITLE_SCREEN.ends_with(".tscn"),
		"TITLE_SCREEN should be a .tscn path",
	)
	assert_true(
		SP.TITLE_SCREEN.contains("title_screen"),
		"TITLE_SCREEN path should contain 'title_screen'",
	)


func test_battle_scene_path_defined() -> void:
	assert_true(
		SP.BATTLE_SCENE.ends_with(".tscn"),
		"BATTLE_SCENE should be a .tscn path",
	)
	assert_true(
		SP.BATTLE_SCENE.contains("battle_scene"),
		"BATTLE_SCENE path should contain 'battle_scene'",
	)


func test_overgrown_capital_path_defined() -> void:
	assert_true(
		SP.OVERGROWN_CAPITAL.ends_with(".tscn"),
		"OVERGROWN_CAPITAL should be a .tscn path",
	)
	assert_true(
		SP.OVERGROWN_CAPITAL.contains("overgrown_capital"),
		"OVERGROWN_CAPITAL path should contain 'overgrown_capital'",
	)


func test_all_paths_start_with_res() -> void:
	var paths: Array[String] = [
		SP.ROOTHOLLOW,
		SP.VERDANT_FOREST,
		SP.OVERGROWN_RUINS,
		SP.OVERGROWN_CAPITAL,
		SP.TITLE_SCREEN,
		SP.BATTLE_SCENE,
	]
	for p: String in paths:
		assert_true(
			p.begins_with("res://"),
			p + " should start with res://",
		)


func test_paths_are_unique() -> void:
	var paths: Array[String] = [
		SP.ROOTHOLLOW,
		SP.VERDANT_FOREST,
		SP.OVERGROWN_RUINS,
		SP.OVERGROWN_CAPITAL,
		SP.TITLE_SCREEN,
		SP.BATTLE_SCENE,
	]
	var seen: Dictionary = {}
	for p: String in paths:
		assert_false(seen.has(p), p + " should be unique")
		seen[p] = true
