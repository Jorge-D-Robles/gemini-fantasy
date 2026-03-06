extends GutTest

## Tests for T-0281: Overgrown Capital → Verdant Forest return path.
## Verifies the exit wiring already exists and targets the correct scene/group.


func test_capital_exit_targets_verdant_forest() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("SP.VERDANT_FOREST"),
		"Capital exit must target SP.VERDANT_FOREST",
	)


func test_capital_exit_uses_spawn_from_capital_group() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("spawn_from_capital"),
		"Capital exit must use 'spawn_from_capital' spawn group",
	)


func test_capital_registers_spawn_from_forest_group() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("spawn_from_forest"),
		"Capital must register 'spawn_from_forest' group",
	)
