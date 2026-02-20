extends GutTest

## Tests for T-0201: childs_laughter echo interactable placement in Verdant Forest.
## Verifies static helpers and echo strategy configuration without live autoloads.

const VFScene = preload("res://scenes/verdant_forest/verdant_forest.gd")
const MemorialStrat = preload(
	"res://entities/interactable/strategies/memorial_echo_strategy.gd"
)

const MAP_WIDTH_PX: float = 640.0
const MAP_HEIGHT_PX: float = 400.0
const TILE_MARGIN_PX: float = 32.0


func test_compute_forest_echo_position_returns_vector2() -> void:
	var pos: Vector2 = VFScene.compute_forest_echo_position()
	assert_true(pos is Vector2, "compute_forest_echo_position() must return a Vector2")


func test_forest_echo_x_within_map_bounds() -> void:
	var pos: Vector2 = VFScene.compute_forest_echo_position()
	assert_true(
		pos.x >= TILE_MARGIN_PX and pos.x <= MAP_WIDTH_PX - TILE_MARGIN_PX,
		"Echo X must be within map interior",
	)


func test_forest_echo_y_within_map_bounds() -> void:
	var pos: Vector2 = VFScene.compute_forest_echo_position()
	assert_true(
		pos.y >= TILE_MARGIN_PX and pos.y <= MAP_HEIGHT_PX - TILE_MARGIN_PX,
		"Echo Y must be within map interior",
	)


func test_forest_echo_position_differs_from_campfire() -> void:
	var echo_pos: Vector2 = VFScene.compute_forest_echo_position()
	var camp_pos: Vector2 = VFScene.compute_campfire_position()
	assert_true(
		echo_pos.distance_to(camp_pos) >= 8.0,
		"Echo must not overlap the campfire position",
	)


func test_childs_laughter_echo_id_constant() -> void:
	assert_eq(
		VFScene.CHILDS_LAUGHTER_ECHO_ID,
		&"childs_laughter",
		"CHILDS_LAUGHTER_ECHO_ID must match the .tres file id",
	)


func test_memorial_strategy_instantiable_with_echo_id() -> void:
	var strat := MemorialStrat.new()
	strat.echo_id = VFScene.CHILDS_LAUGHTER_ECHO_ID
	strat.require_quest_id = &""
	assert_eq(strat.echo_id, &"childs_laughter")
	assert_eq(strat.require_quest_id, &"")
