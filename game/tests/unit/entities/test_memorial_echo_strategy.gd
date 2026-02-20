extends GutTest

## Tests for T-0198: MemorialEchoStrategy generic echo placement refactor.
## Verifies compute_should_collect() pure logic for both generic and quest-gated paths.

const StrategyScript = preload(
	"res://entities/interactable/strategies/memorial_echo_strategy.gd"
)


# -- Default export values --


func test_require_quest_id_defaults_to_empty() -> void:
	var strategy := StrategyScript.new()
	assert_eq(
		strategy.require_quest_id,
		&"",
		"require_quest_id must default to empty StringName (generic placement)",
	)


func test_vision_lines_defaults_to_empty_array() -> void:
	var strategy := StrategyScript.new()
	assert_eq(
		strategy.vision_lines.size(),
		0,
		"vision_lines must default to empty array",
	)


# -- compute_should_collect: generic path (require_quest_id == &"") --


func test_generic_not_collected_returns_true() -> void:
	var result := StrategyScript.compute_should_collect(
		&"some_echo",
		&"",       # require_quest_id empty → generic
		false,     # echo not yet collected
		false,     # quest_active irrelevant on generic path
		false,     # obj_done irrelevant on generic path
	)
	assert_true(result, "Generic echo should be collected when not yet collected")


func test_generic_already_collected_returns_false() -> void:
	var result := StrategyScript.compute_should_collect(
		&"some_echo",
		&"",
		true,      # already collected
		false,
		false,
	)
	assert_false(result, "Generic echo must not be re-collected when already collected")


# -- compute_should_collect: quest-gated path (require_quest_id != &"") --


func test_quest_gated_active_and_incomplete_returns_true() -> void:
	var result := StrategyScript.compute_should_collect(
		&"elder_echo",
		&"elder_wisdom",  # quest-gated
		false,             # not yet collected
		true,              # quest active
		false,             # objective not done
	)
	assert_true(result, "Quest-gated echo should be collected when quest active and obj incomplete")


func test_quest_gated_quest_not_active_returns_false() -> void:
	var result := StrategyScript.compute_should_collect(
		&"elder_echo",
		&"elder_wisdom",
		false,
		false,  # quest NOT active
		false,
	)
	assert_false(result, "Quest-gated echo must not collect when quest is not active")


func test_quest_gated_objective_already_done_returns_false() -> void:
	var result := StrategyScript.compute_should_collect(
		&"elder_echo",
		&"elder_wisdom",
		false,
		true,   # quest active
		true,   # objective already done
	)
	assert_false(result, "Quest-gated echo must not re-collect when objective already completed")


func test_quest_gated_already_collected_returns_false() -> void:
	var result := StrategyScript.compute_should_collect(
		&"elder_echo",
		&"elder_wisdom",
		true,  # already collected — idempotent even if quest is active + incomplete
		true,
		false,
	)
	assert_false(result, "Quest-gated echo must not re-collect when echo already in collection")
