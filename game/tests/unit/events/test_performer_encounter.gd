extends GutTest

## Tests for T-0206: The Performer mini-boss encounter in Entertainment District.
## Verifies trigger gating, dialogue line counts, and zone position validity.

const PerformerEnc = preload("res://events/performer_encounter.gd")
const CapitalMap = preload("res://scenes/overgrown_capital/overgrown_capital_map.gd")
const Capital = preload("res://scenes/overgrown_capital/overgrown_capital.gd")


func test_compute_can_trigger_returns_true_when_gate_set_and_flag_unset() -> void:
	var flags: Dictionary = {PerformerEnc.GATE_FLAG: true}
	assert_true(PerformerEnc.compute_can_trigger(flags))


func test_compute_can_trigger_returns_false_when_gate_flag_missing() -> void:
	var flags: Dictionary = {}
	assert_false(PerformerEnc.compute_can_trigger(flags))


func test_compute_can_trigger_returns_false_when_already_encountered() -> void:
	var flags: Dictionary = {
		PerformerEnc.GATE_FLAG: true,
		PerformerEnc.FLAG_NAME: true,
	}
	assert_false(PerformerEnc.compute_can_trigger(flags))


func test_pre_battle_lines_count() -> void:
	var lines: Array[DialogueLine] = PerformerEnc.compute_pre_battle_lines()
	assert_eq(lines.size(), 4, "Pre-battle dialogue should have exactly 4 lines")


func test_post_battle_lines_count() -> void:
	var lines: Array[DialogueLine] = PerformerEnc.compute_post_battle_lines()
	assert_eq(lines.size(), 2, "Post-battle dialogue should have exactly 2 lines")


func test_performer_zone_position_within_map_bounds() -> void:
	var pos: Vector2 = Capital.compute_performer_zone_position()
	var col: int = int(pos.x / 16.0)
	var row: int = int(pos.y / 16.0)
	assert_true(
		col >= 0 and col < CapitalMap.COLS,
		"Performer zone col %d must be within [0, %d)" % [col, CapitalMap.COLS],
	)
	assert_true(
		row >= 0 and row < CapitalMap.ROWS,
		"Performer zone row %d must be within [0, %d)" % [row, CapitalMap.ROWS],
	)


func test_performer_zone_position_not_wall() -> void:
	var pos: Vector2 = Capital.compute_performer_zone_position()
	var col: int = int(pos.x / 16.0)
	var row: int = int(pos.y / 16.0)
	var ch: String = CapitalMap.WALL_MAP[row][col]
	assert_ne(ch, "W", "Performer zone must not be on a wall cell")
	assert_ne(ch, "G", "Performer zone must not be on a border cell")
