extends GutTest

## Tests for BattleBackground — area detection and gradient setup.

const BattleBackground = preload("res://systems/battle/battle_background.gd")

var _bg: Sprite2D


func before_each() -> void:
	_bg = BattleBackground.new()
	add_child_autofree(_bg)


# ---- Area Detection ----

func test_forest_scene_detected() -> void:
	var area: int = BattleBackground.area_from_scene_path(
		"res://scenes/verdant_forest/verdant_forest.tscn"
	)
	assert_eq(area, BattleBackground.AreaType.FOREST)


func test_ruins_scene_detected() -> void:
	var area: int = BattleBackground.area_from_scene_path(
		"res://scenes/overgrown_ruins/overgrown_ruins.tscn"
	)
	assert_eq(area, BattleBackground.AreaType.RUINS)


func test_town_scene_detected() -> void:
	var area: int = BattleBackground.area_from_scene_path(
		"res://scenes/roothollow/roothollow.tscn"
	)
	assert_eq(area, BattleBackground.AreaType.TOWN)


func test_cave_scene_detected() -> void:
	var area: int = BattleBackground.area_from_scene_path(
		"res://scenes/cave/dark_cave.tscn"
	)
	assert_eq(area, BattleBackground.AreaType.CAVE)


func test_unknown_scene_defaults_to_forest() -> void:
	var area: int = BattleBackground.area_from_scene_path(
		"res://scenes/unknown/place.tscn"
	)
	assert_eq(area, BattleBackground.AreaType.FOREST)


# ---- Gradient Setup ----

func test_setup_creates_texture() -> void:
	_bg.setup(BattleBackground.AreaType.FOREST)
	assert_not_null(_bg.texture, "Texture should be assigned after setup")


func test_setup_positions_correctly() -> void:
	_bg.setup(BattleBackground.AreaType.FOREST)
	assert_false(_bg.centered, "Background should not be centered")
	assert_eq(_bg.z_index, -10, "Background z_index should be behind everything")


func test_setup_creates_correct_size() -> void:
	_bg.setup(BattleBackground.AreaType.RUINS)
	var tex := _bg.texture as GradientTexture2D
	assert_not_null(tex, "Texture should be a GradientTexture2D")
	assert_eq(tex.width, 640)
	assert_eq(tex.height, 360)


func test_all_area_types_have_palettes() -> void:
	for area_type: int in BattleBackground.AreaType.values():
		assert_true(
			BattleBackground.AREA_PALETTES.has(area_type),
			"Missing palette for area type %d" % area_type,
		)


func test_each_area_creates_unique_gradient() -> void:
	var colors_by_area: Dictionary = {}
	for area_type: int in BattleBackground.AreaType.values():
		var bg: Sprite2D = BattleBackground.new()
		add_child_autofree(bg)
		bg.setup(area_type)
		var tex := bg.texture as GradientTexture2D
		assert_not_null(tex)
		colors_by_area[area_type] = tex.gradient.colors[0]

	assert_ne(
		colors_by_area[BattleBackground.AreaType.FOREST],
		colors_by_area[BattleBackground.AreaType.RUINS],
		"Forest and Ruins should have different gradients",
	)
