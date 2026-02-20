extends GutTest

## Tests for InteractionHint.compute_interaction_hint_text() —
## verifies the formatted prompt string for the HUD interaction cue.

const InteractionHintScript := preload("res://ui/hud/interaction_hint.gd")


func test_hint_text_is_non_empty_for_interact_action() -> void:
	var text := InteractionHintScript.compute_interaction_hint_text("interact")
	assert_false(text.is_empty(), "Hint text must not be empty for 'interact' action")


func test_hint_text_contains_interact_keyword() -> void:
	var text := InteractionHintScript.compute_interaction_hint_text("interact")
	assert_true(
		text.contains("Interact"),
		"Hint text must include the word 'Interact'",
	)


func test_hint_text_has_bracket_format() -> void:
	var text := InteractionHintScript.compute_interaction_hint_text("interact")
	assert_true(
		text.begins_with("["),
		"Hint text must start with '[' for the key label bracket",
	)
	assert_true(
		text.contains("]"),
		"Hint text must contain ']' to close the key label bracket",
	)


func test_hint_text_unknown_action_returns_fallback() -> void:
	var text := InteractionHintScript.compute_interaction_hint_text(
		"this_action_does_not_exist_xyz"
	)
	assert_eq(
		text,
		"[ ] Interact",
		"Unknown action should return '[ ] Interact' fallback",
	)


func test_hint_text_fallback_matches_expected_format() -> void:
	# When no key is bound or action is unknown, result is "[ ] Interact"
	var fallback := InteractionHintScript.compute_interaction_hint_text("")
	assert_eq(fallback, "[ ] Interact", "Empty action name returns fallback")
