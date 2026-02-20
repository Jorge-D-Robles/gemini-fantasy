extends GutTest

## Tests for PurificationNodeStrategy — pure logic helpers.
## execute() requires live autoloads (EventFlags, DialogueManager) so is not tested here.
## Instead, we verify the static pure helpers and script-level wiring in the Capital scene.

const PurificationNodeStrategy = preload(
	"res://entities/interactable/strategies/purification_node_strategy.gd"
)


func test_compute_flag_name_format() -> void:
	var flag := PurificationNodeStrategy.compute_flag_name("market_north")
	assert_eq(flag, "node_market_north_cleared", "Flag name must follow node_<id>_cleared format")


func test_compute_flag_name_entertainment_node() -> void:
	var flag := PurificationNodeStrategy.compute_flag_name("entertainment_research")
	assert_eq(
		flag,
		"node_entertainment_research_cleared",
		"Entertainment node flag must follow same format",
	)


func test_compute_node_active_state_true_when_not_cleared() -> void:
	var flags := {}
	var active := PurificationNodeStrategy.compute_node_active_state(flags, "market_north")
	assert_true(active, "Node must be active (uncleared) when flag is absent")


func test_compute_node_active_state_false_when_cleared() -> void:
	var flags := {"node_market_north_cleared": true}
	var active := PurificationNodeStrategy.compute_node_active_state(flags, "market_north")
	assert_false(active, "Node must be inactive (cleared) when flag is present")


func test_compute_node_active_state_ignores_other_node_flags() -> void:
	var flags := {"node_entertainment_research_cleared": true}
	var active := PurificationNodeStrategy.compute_node_active_state(flags, "market_north")
	assert_true(active, "Clearing one node must not affect another node's active state")


func test_compute_node_active_state_with_empty_node_id() -> void:
	var flags := {}
	var active := PurificationNodeStrategy.compute_node_active_state(flags, "")
	assert_true(active, "Empty node_id with no flags must return active")


func test_capital_declares_purification_node_setup() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("_setup_purification_nodes"),
		"overgrown_capital.gd must declare _setup_purification_nodes()",
	)


func test_capital_declares_node_cleared_handler() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("_on_node_cleared"),
		"overgrown_capital.gd must declare _on_node_cleared handler",
	)


func test_capital_uses_market_north_node_id() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("market_north"),
		"Capital must wire a Purification Node with id 'market_north'",
	)


func test_capital_uses_entertainment_research_node_id() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("entertainment_research"),
		"Capital must wire a Purification Node with id 'entertainment_research'",
	)
