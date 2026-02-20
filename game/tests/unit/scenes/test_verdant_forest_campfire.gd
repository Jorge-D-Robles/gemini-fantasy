extends GutTest

## Tests for T-0180: Campfire interactable placement in Verdant Forest.
## Verifies static helpers and CampStrategy instantiation without live autoloads.

const VFScene = preload("res://scenes/verdant_forest/verdant_forest.gd")
const CampStrat = preload(
	"res://entities/interactable/strategies/camp_strategy.gd"
)

const MAP_WIDTH_PX: float = 640.0
const MAP_HEIGHT_PX: float = 400.0
const TILE_MARGIN_PX: float = 32.0  # At least 2 tiles from any edge


func test_compute_campfire_position_returns_vector2() -> void:
	var pos: Vector2 = VFScene.compute_campfire_position()
	assert_true(pos is Vector2, "compute_campfire_position() must return a Vector2")


func test_campfire_x_within_map_bounds() -> void:
	var pos: Vector2 = VFScene.compute_campfire_position()
	assert_true(
		pos.x >= TILE_MARGIN_PX and pos.x <= MAP_WIDTH_PX - TILE_MARGIN_PX,
		"Campfire X must be within map interior (margin=%d px)" % int(TILE_MARGIN_PX),
	)


func test_campfire_y_within_map_bounds() -> void:
	var pos: Vector2 = VFScene.compute_campfire_position()
	assert_true(
		pos.y >= TILE_MARGIN_PX and pos.y <= MAP_HEIGHT_PX - TILE_MARGIN_PX,
		"Campfire Y must be within map interior (margin=%d px)" % int(TILE_MARGIN_PX),
	)


func test_campfire_name_is_non_empty_string() -> void:
	var name_val: String = VFScene.compute_campfire_name()
	assert_true(
		name_val.length() > 0,
		"compute_campfire_name() must return a non-empty string",
	)


func test_camp_strategy_is_instantiable() -> void:
	var strategy := CampStrat.new()
	assert_not_null(strategy, "CampStrategy must be instantiable")


func test_camp_strategy_has_execute_method() -> void:
	var strategy := CampStrat.new()
	assert_true(
		strategy.has_method("execute"),
		"CampStrategy must have an execute() method",
	)
