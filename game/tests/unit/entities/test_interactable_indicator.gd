extends GutTest

## Tests for T-0111: interaction indicators on Interactable objects.
## Validates IndicatorType enum, static helpers, and visibility logic.

const InteractableScript := preload("res://entities/interactable/interactable.gd")


func test_indicator_hidden_when_player_not_in_range() -> void:
	var visible := InteractableScript.compute_indicator_visible(
		false, false, false
	)
	assert_false(visible, "Not in range → indicator hidden")


func test_indicator_visible_when_player_in_range_unused() -> void:
	var visible := InteractableScript.compute_indicator_visible(
		true, false, false
	)
	assert_true(visible, "In range, not used → indicator visible")


func test_indicator_hidden_after_one_time_use_in_range() -> void:
	var visible := InteractableScript.compute_indicator_visible(
		true, true, true
	)
	assert_false(visible, "One-time used while in range → indicator hidden")


func test_indicator_visible_after_multi_use_interact_in_range() -> void:
	var visible := InteractableScript.compute_indicator_visible(
		true, true, false
	)
	assert_true(visible, "Multi-use used while in range → indicator still visible")


func test_indicator_hidden_when_not_in_range_even_if_unused() -> void:
	var visible := InteractableScript.compute_indicator_visible(
		false, false, true
	)
	assert_false(visible, "Not in range, unused one-time → indicator hidden")
