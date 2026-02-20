extends GutTest

## Tests for T-0099: GameManager zone transition type selection.
## Verifies compute_transition_type() pure static helper only.
## Actual slide animation is verified visually via /scene-preview.

var _gm: Node


func before_each() -> void:
	_gm = load("res://autoloads/game_manager.gd").new()
	add_child_autofree(_gm)


func test_slide_duration_is_positive() -> void:
	assert_true(
		_gm.SLIDE_DURATION > 0.0,
		"SLIDE_DURATION must be positive",
	)


func test_compute_transition_roothollow_to_verdant_is_slide_right() -> void:
	var t: int = _gm.compute_transition_type(
		"res://scenes/roothollow/roothollow.tscn",
		"res://scenes/verdant_forest/verdant_forest.tscn",
	)
	assert_eq(
		t, _gm.TransitionType.SLIDE_RIGHT,
		"Roothollow -> Verdant Forest should slide right",
	)


func test_compute_transition_verdant_to_roothollow_is_slide_left() -> void:
	var t: int = _gm.compute_transition_type(
		"res://scenes/verdant_forest/verdant_forest.tscn",
		"res://scenes/roothollow/roothollow.tscn",
	)
	assert_eq(
		t, _gm.TransitionType.SLIDE_LEFT,
		"Verdant Forest -> Roothollow should slide left",
	)


func test_compute_transition_verdant_to_ruins_is_slide_right() -> void:
	var t: int = _gm.compute_transition_type(
		"res://scenes/verdant_forest/verdant_forest.tscn",
		"res://scenes/overgrown_ruins/overgrown_ruins.tscn",
	)
	assert_eq(
		t, _gm.TransitionType.SLIDE_RIGHT,
		"Verdant Forest -> Overgrown Ruins should slide right",
	)


func test_compute_transition_ruins_to_verdant_is_slide_left() -> void:
	var t: int = _gm.compute_transition_type(
		"res://scenes/overgrown_ruins/overgrown_ruins.tscn",
		"res://scenes/verdant_forest/verdant_forest.tscn",
	)
	assert_eq(
		t, _gm.TransitionType.SLIDE_LEFT,
		"Overgrown Ruins -> Verdant Forest should slide left",
	)


func test_compute_transition_unknown_pair_is_fade() -> void:
	var t: int = _gm.compute_transition_type(
		"res://scenes/roothollow/roothollow.tscn",
		"res://scenes/overgrown_ruins/overgrown_ruins.tscn",
	)
	assert_eq(
		t, _gm.TransitionType.FADE,
		"Non-adjacent scene pair should default to FADE",
	)


func test_compute_transition_empty_strings_is_fade() -> void:
	var t: int = _gm.compute_transition_type("", "")
	assert_eq(t, _gm.TransitionType.FADE, "Empty strings should return FADE")
