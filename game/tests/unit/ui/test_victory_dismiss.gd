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
	var text := BattleUIVictory.compute_dismiss_prompt_text("interact")
	assert_true(
		text.contains("interact"),
		"Dismiss prompt should include the provided action name",
	)


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
