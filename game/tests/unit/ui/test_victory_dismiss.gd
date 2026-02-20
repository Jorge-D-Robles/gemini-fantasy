extends GutTest

## Tests for T-0129: player-driven victory screen dismissal.
## Validates GRACE_PERIOD constant and dismiss prompt text helper.

const VictoryState := preload(
	"res://systems/battle/states/victory_state.gd"
)
const BattleUIVictory := preload(
	"res://ui/battle_ui/battle_ui_victory.gd"
)
const Helpers := preload("res://tests/helpers/test_helpers.gd")


func test_grace_period_constant_is_half_second() -> void:
	assert_eq(VictoryState.GRACE_PERIOD, 0.5, "Grace period should be 0.5s")


func test_grace_period_is_positive() -> void:
	assert_gt(
		VictoryState.GRACE_PERIOD, 0.0,
		"Grace period must be positive to prevent instant dismiss",
	)


func test_dismiss_prompt_text_contains_confirm() -> void:
	var text := BattleUIVictory.compute_dismiss_prompt_text()
	assert_true(
		text.to_lower().contains("confirm"),
		"Dismiss prompt should mention the confirm action",
	)


func test_dismiss_prompt_text_has_press_instruction() -> void:
	var text := BattleUIVictory.compute_dismiss_prompt_text()
	assert_true(
		text.to_lower().contains("press"),
		"Dismiss prompt should start with 'Press'",
	)


func test_dismiss_prompt_text_has_continue_instruction() -> void:
	var text := BattleUIVictory.compute_dismiss_prompt_text()
	assert_true(
		text.to_lower().contains("continue"),
		"Dismiss prompt should instruct player to continue",
	)


func test_dismiss_prompt_custom_action_name() -> void:
	# "interact" is a registered action — prompt now shows actual key binding,
	# not the raw action name string.
	var text := BattleUIVictory.compute_dismiss_prompt_text("interact")
	assert_true(
		text.to_lower().contains("press") and text.to_lower().contains("continue"),
		"Dismiss prompt should still have the 'Press [...] to continue' format",
	)


func test_dismiss_prompt_from_events_empty_returns_fallback() -> void:
	var events: Array[InputEvent] = []
	var text := BattleUIVictory.compute_dismiss_prompt_from_events(events, "fallback_key")
	assert_eq(text, "fallback_key", "Empty events array should return the fallback string")


func test_dismiss_prompt_from_events_keyboard_event_returns_key_name() -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_SPACE
	var events: Array[InputEvent] = [event]
	var text := BattleUIVictory.compute_dismiss_prompt_from_events(events, "fallback_key")
	assert_true(
		text.length() > 0 and text != "fallback_key",
		"Keyboard event should return a key label, not the fallback",
	)


func test_dismiss_prompt_from_events_joypad_a_returns_label() -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_A
	var events: Array[InputEvent] = [event]
	var text := BattleUIVictory.compute_dismiss_prompt_from_events(events, "fallback_key")
	assert_eq(text, "A", "JOY_BUTTON_A should produce label 'A'")


func test_apply_xp_rewards_regression_still_works() -> void:
	# Regression: verify apply_xp_rewards was not broken by dismiss refactor
	var c := Helpers.make_character_data({
		"id": &"hero",
		"current_xp": 0,
		"level": 1,
	})
	var party: Array[Resource] = [c]
	var result := VictoryState.apply_xp_rewards(party, 0)
	assert_eq(result.size(), 0, "Zero XP gives no level-up")
	assert_eq(c.current_xp, 0, "XP unchanged for zero reward")
