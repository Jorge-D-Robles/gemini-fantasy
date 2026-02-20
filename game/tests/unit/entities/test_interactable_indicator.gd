extends GutTest

## Tests for T-0111: interaction indicators on Interactable objects.
## Validates IndicatorType enum, static helpers, and visibility logic.

const InteractableScript := preload("res://entities/interactable/interactable.gd")


func test_indicator_type_none_exists() -> void:
	assert_eq(
		InteractableScript.IndicatorType.NONE,
		0,
		"IndicatorType.NONE should be 0",
	)


func test_indicator_type_interact_exists() -> void:
	assert_true(
		InteractableScript.IndicatorType.has("INTERACT"),
		"IndicatorType.INTERACT must exist",
	)


func test_indicator_type_save_exists() -> void:
	assert_true(
		InteractableScript.IndicatorType.has("SAVE"),
		"IndicatorType.SAVE must exist",
	)


func test_compute_indicator_text_none_is_empty() -> void:
	var text := InteractableScript.compute_indicator_text(
		InteractableScript.IndicatorType.NONE
	)
	assert_eq(text, "", "NONE indicator has empty text")


func test_compute_indicator_text_interact_is_nonempty() -> void:
	var text := InteractableScript.compute_indicator_text(
		InteractableScript.IndicatorType.INTERACT
	)
	assert_false(text.is_empty(), "INTERACT indicator has visible text")


func test_compute_indicator_text_save_is_nonempty() -> void:
	var text := InteractableScript.compute_indicator_text(
		InteractableScript.IndicatorType.SAVE
	)
	assert_false(text.is_empty(), "SAVE indicator has visible text")


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
