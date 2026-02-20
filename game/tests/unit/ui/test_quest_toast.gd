extends GutTest

## Tests for T-0120: Quest accept/complete toast notifications in HUD.
## Validates static compute_toast_text() helper and queue constants.

const HUD := preload("res://ui/hud/hud.gd")


func test_toast_text_quest_accepted_format() -> void:
	var text := HUD.compute_toast_text("accepted", "The Lost Shrine")
	assert_true(text.contains("The Lost Shrine"), "Must include quest name")
	assert_true(
		text.begins_with("New Quest"),
		"Accepted toast must start with 'New Quest'",
	)


func test_toast_text_quest_completed_format() -> void:
	var text := HUD.compute_toast_text("completed", "A Debt Repaid")
	assert_true(text.contains("A Debt Repaid"), "Must include quest name")
	assert_true(
		text.begins_with("Quest Complete"),
		"Completed toast must start with 'Quest Complete'",
	)


func test_toast_text_unknown_event_returns_quest_name() -> void:
	var text := HUD.compute_toast_text("unknown_event", "My Quest")
	assert_false(text.is_empty(), "Unknown event should still return non-empty text")


func test_toast_text_different_quest_names() -> void:
	var text1 := HUD.compute_toast_text("accepted", "Quest Alpha")
	var text2 := HUD.compute_toast_text("accepted", "Quest Beta")
	assert_ne(text1, text2, "Different quest names produce different text")


func test_toast_hold_duration_constant_exists() -> void:
	assert_true(
		HUD.TOAST_HOLD_DURATION > 0.0,
		"TOAST_HOLD_DURATION must be a positive value",
	)


func test_toast_hold_duration_is_at_least_two_seconds() -> void:
	assert_true(
		HUD.TOAST_HOLD_DURATION >= 2.0,
		"Toast should display for at least 2 seconds",
	)


func test_toast_slide_duration_constant_exists() -> void:
	assert_true(
		HUD.TOAST_SLIDE_DURATION > 0.0,
		"TOAST_SLIDE_DURATION must be a positive value",
	)
