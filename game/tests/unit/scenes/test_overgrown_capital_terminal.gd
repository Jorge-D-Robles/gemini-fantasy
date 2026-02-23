extends GutTest

## Tests for T-0214: Resonance terminal puzzle in Overgrown Capital.
## Verifies activation logic, crystal positions, and terminal position validity.

const TerminalStrategy = preload(
	"res://entities/interactable/strategies/resonance_terminal_strategy.gd"
)
const CapitalMap = preload("res://scenes/overgrown_capital/overgrown_capital_map.gd")
const Capital = preload("res://scenes/overgrown_capital/overgrown_capital.gd")
const Registry = preload("res://events/event_flag_registry.gd")


func test_compute_terminal_can_activate_both_present() -> void:
	var items: Dictionary = {
		TerminalStrategy.MARKET_CRYSTAL_ID: 1,
		TerminalStrategy.ENTERTAINMENT_CRYSTAL_ID: 1,
	}
	assert_true(TerminalStrategy.compute_terminal_can_activate(items))


func test_compute_terminal_can_activate_missing_market() -> void:
	var items: Dictionary = {
		TerminalStrategy.ENTERTAINMENT_CRYSTAL_ID: 1,
	}
	assert_false(TerminalStrategy.compute_terminal_can_activate(items))


func test_compute_terminal_can_activate_missing_entertainment() -> void:
	var items: Dictionary = {
		TerminalStrategy.MARKET_CRYSTAL_ID: 1,
	}
	assert_false(TerminalStrategy.compute_terminal_can_activate(items))


func test_compute_terminal_can_activate_empty_inventory() -> void:
	var items: Dictionary = {}
	assert_false(TerminalStrategy.compute_terminal_can_activate(items))


func test_terminal_activation_lines_even_count() -> void:
	var lines: Array[String] = TerminalStrategy.compute_terminal_activation_lines()
	assert_eq(
		lines.size() % 2, 0,
		"Activation lines must have even count (speaker/text pairs)",
	)
	assert_gt(lines.size(), 0, "Activation lines must not be empty")


func test_terminal_missing_lines_even_count() -> void:
	var lines: Array[String] = TerminalStrategy.compute_terminal_missing_lines()
	assert_eq(
		lines.size() % 2, 0,
		"Missing crystal lines must have even count",
	)
	assert_gt(lines.size(), 0, "Missing crystal lines must not be empty")


func test_terminal_already_active_lines_even_count() -> void:
	var lines: Array[String] = TerminalStrategy.compute_terminal_already_active_lines()
	assert_eq(
		lines.size() % 2, 0,
		"Already active lines must have even count",
	)
	assert_gt(lines.size(), 0, "Already active lines must not be empty")


func test_market_crystal_position_not_wall() -> void:
	var pos: Vector2 = Capital.compute_market_crystal_position()
	var col: int = int(pos.x / 16.0)
	var row: int = int(pos.y / 16.0)
	assert_true(
		col >= 0 and col < CapitalMap.COLS,
		"Market crystal col %d within bounds" % col,
	)
	assert_true(
		row >= 0 and row < CapitalMap.ROWS,
		"Market crystal row %d within bounds" % row,
	)
	var ch: String = CapitalMap.WALL_MAP[row][col]
	assert_ne(ch, "W", "Market crystal must not be on wall")
	assert_ne(ch, "G", "Market crystal must not be on border")


func test_entertainment_crystal_position_not_wall() -> void:
	var pos: Vector2 = Capital.compute_entertainment_crystal_position()
	var col: int = int(pos.x / 16.0)
	var row: int = int(pos.y / 16.0)
	assert_true(
		col >= 0 and col < CapitalMap.COLS,
		"Entertainment crystal col %d within bounds" % col,
	)
	assert_true(
		row >= 0 and row < CapitalMap.ROWS,
		"Entertainment crystal row %d within bounds" % row,
	)
	var ch: String = CapitalMap.WALL_MAP[row][col]
	assert_ne(ch, "W", "Entertainment crystal must not be on wall")
	assert_ne(ch, "G", "Entertainment crystal must not be on border")


func test_terminal_position_not_wall() -> void:
	var pos: Vector2 = Capital.compute_terminal_position()
	var col: int = int(pos.x / 16.0)
	var row: int = int(pos.y / 16.0)
	assert_true(
		col >= 0 and col < CapitalMap.COLS,
		"Terminal col %d within bounds" % col,
	)
	assert_true(
		row >= 0 and row < CapitalMap.ROWS,
		"Terminal row %d within bounds" % row,
	)
	var ch: String = CapitalMap.WALL_MAP[row][col]
	assert_ne(ch, "W", "Terminal must not be on wall")
	assert_ne(ch, "G", "Terminal must not be on border")


func test_terminal_position_in_palace_approach() -> void:
	var pos: Vector2 = Capital.compute_terminal_position()
	var row: int = int(pos.y / 16.0)
	assert_true(
		row >= 0 and row <= 5,
		"Terminal row %d should be in Palace Approach (rows 0-5)" % row,
	)


func test_registry_matches_terminal_flag_name() -> void:
	assert_eq(
		Registry.RESEARCH_TERMINAL_ACTIVATED,
		TerminalStrategy.FLAG_NAME,
		"Registry constant must match strategy FLAG_NAME",
	)
