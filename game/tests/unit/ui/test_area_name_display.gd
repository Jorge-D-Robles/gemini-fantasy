extends GutTest

## Tests for HUD.compute_area_display_name() static method.
## Validates scene path to display name mapping.

const HUD = preload("res://ui/hud/hud.gd")
const SP = preload("res://systems/scene_paths.gd")


func test_area_display_name_roothollow() -> void:
	var name := HUD.compute_area_display_name(SP.ROOTHOLLOW)
	assert_eq(name, "Roothollow")


func test_area_display_name_verdant_forest() -> void:
	var name := HUD.compute_area_display_name(SP.VERDANT_FOREST)
	assert_eq(name, "Verdant Forest")


func test_area_display_name_overgrown_ruins() -> void:
	var name := HUD.compute_area_display_name(SP.OVERGROWN_RUINS)
	assert_eq(name, "Overgrown Ruins")


func test_area_display_name_title_screen_empty() -> void:
	var name := HUD.compute_area_display_name(SP.TITLE_SCREEN)
	assert_eq(name, "")


func test_area_display_name_battle_scene_empty() -> void:
	var name := HUD.compute_area_display_name(SP.BATTLE_SCENE)
	assert_eq(name, "")
