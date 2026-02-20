extends GutTest

## Tests for Lyra Fragment 2 collectible and Research Quarter vision sequence.
## T-0191: Add Lyra's Fragment 2 collectible and Chapter 5 Research Quarter vision sequence.

const OvergrownCapital = preload("res://scenes/overgrown_capital/overgrown_capital.gd")


func test_compute_research_quarter_lines_returns_even_count() -> void:
	var lines := OvergrownCapital.compute_research_quarter_lines()
	assert_eq(
		lines.size() % 2,
		0,
		"compute_research_quarter_lines must return an even-count array for DialogueLine pairing",
	)


func test_compute_research_quarter_lines_returns_at_least_eight_pairs() -> void:
	var lines := OvergrownCapital.compute_research_quarter_lines()
	assert_true(
		lines.size() >= 16,
		"Vision must include at least 8 speaker/text pairs (approach + memory)",
	)


func test_compute_research_quarter_lines_includes_iris_nameplate() -> void:
	var lines := OvergrownCapital.compute_research_quarter_lines()
	var combined := " ".join(PackedStringArray(lines))
	assert_true(
		combined.contains("Dr. L. Reyes"),
		"Vision lines must include Iris reading Lyra's nameplate",
	)


func test_compute_research_quarter_lines_includes_lyra_countdown() -> void:
	var lines := OvergrownCapital.compute_research_quarter_lines()
	var combined := " ".join(PackedStringArray(lines))
	assert_true(
		combined.contains("one hundred and forty") or combined.contains("140"),
		"Vision lines must reference the 140-day countdown from Lyra's memory",
	)


func test_compute_research_quarter_lines_includes_lyra_apology() -> void:
	var lines := OvergrownCapital.compute_research_quarter_lines()
	var combined := " ".join(PackedStringArray(lines))
	assert_true(
		combined.contains("I'm sorry"),
		"Vision lines must include Lyra's apology — her defining emotional beat",
	)


func test_compute_research_quarter_echo_position_within_map_bounds() -> void:
	var pos := OvergrownCapital.compute_research_quarter_echo_position()
	assert_true(pos.x > 0.0 and pos.x < 640.0, "Echo X must be within Capital map width (640)")
	assert_true(pos.y > 0.0 and pos.y < 448.0, "Echo Y must be within Capital map height (448)")


func test_capital_declares_lyra_fragment_echo_id() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("lyra_fragment_2"),
		"Capital must reference the lyra_fragment_2 echo ID",
	)


func test_capital_sets_lyra_fragment_2_collected_flag() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("lyra_fragment_2_collected"),
		"Capital must set the lyra_fragment_2_collected EventFlag on echo collection",
	)
