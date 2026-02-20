extends GutTest

## Tests for T-0102: HudCompass static helpers — zone adjacency compass display.
## Verifies compute_compass_text() and compute_compass_visible() pure logic only.
## Visual placement is verified via /scene-preview.

const HC = preload("res://ui/hud/hud_compass.gd")
const SP = preload("res://systems/scene_paths.gd")


func test_compass_text_roothollow_shows_east_neighbor() -> void:
	var text := HC.compute_compass_text(SP.ROOTHOLLOW)
	assert_true(
		text.contains("Verdant Forest"),
		"Roothollow compass should show Verdant Forest to the east",
	)


func test_compass_text_roothollow_has_no_west_arrow() -> void:
	var text := HC.compute_compass_text(SP.ROOTHOLLOW)
	assert_false(
		text.begins_with("\u2190"),
		"Roothollow should not show a west arrow (no neighbor to the west)",
	)


func test_compass_text_verdant_forest_shows_both_neighbors() -> void:
	var text := HC.compute_compass_text(SP.VERDANT_FOREST)
	assert_true(
		text.contains("Roothollow"),
		"Verdant Forest compass should show Roothollow to the west",
	)
	assert_true(
		text.contains("Overgrown Ruins"),
		"Verdant Forest compass should show Overgrown Ruins to the east",
	)


func test_compass_text_overgrown_ruins_shows_west_neighbor() -> void:
	var text := HC.compute_compass_text(SP.OVERGROWN_RUINS)
	assert_true(
		text.contains("Verdant Forest"),
		"Overgrown Ruins compass should show Verdant Forest to the west",
	)


func test_compass_text_overgrown_ruins_has_no_east_arrow() -> void:
	var text := HC.compute_compass_text(SP.OVERGROWN_RUINS)
	assert_false(
		text.contains(HC.ARROW_EAST),
		"Overgrown Ruins has no east neighbor — east arrow must not appear",
	)


func test_compass_text_unknown_scene_returns_empty() -> void:
	var text := HC.compute_compass_text("")
	assert_eq(text, "", "Unknown scene should return empty compass text")


func test_compass_text_battle_scene_returns_empty() -> void:
	var text := HC.compute_compass_text(SP.BATTLE_SCENE)
	assert_eq(text, "", "Battle scene should return empty compass text")


func test_compass_visible_roothollow() -> void:
	assert_true(
		HC.compute_compass_visible(SP.ROOTHOLLOW),
		"Compass should be visible in Roothollow",
	)


func test_compass_visible_verdant_forest() -> void:
	assert_true(
		HC.compute_compass_visible(SP.VERDANT_FOREST),
		"Compass should be visible in Verdant Forest",
	)


func test_compass_visible_overgrown_ruins() -> void:
	assert_true(
		HC.compute_compass_visible(SP.OVERGROWN_RUINS),
		"Compass should be visible in Overgrown Ruins",
	)


func test_compass_visible_false_for_battle_scene() -> void:
	assert_false(
		HC.compute_compass_visible(SP.BATTLE_SCENE),
		"Compass should not be visible during battle",
	)


func test_compass_visible_false_for_title_screen() -> void:
	assert_false(
		HC.compute_compass_visible(SP.TITLE_SCREEN),
		"Compass should not be visible on the title screen",
	)
