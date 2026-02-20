extends GutTest

## Tests for T-0212: Verdant Forest → Overgrown Capital scene transition wiring.
## Verifies ExitToCapital trigger in Forest, SpawnFromCapital Marker2D in Forest,
## and bidirectional scene change destinations (Forest→Capital and Capital→Forest).


func test_verdant_forest_declares_exit_to_capital() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		source.contains("ExitToCapital"),
		"verdant_forest.gd must declare the ExitToCapital onready node",
	)


func test_verdant_forest_declares_spawn_from_capital() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		source.contains("SpawnFromCapital"),
		"verdant_forest.gd must declare the SpawnFromCapital onready node",
	)


func test_verdant_forest_registers_spawn_from_capital_group() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		source.contains("spawn_from_capital"),
		"verdant_forest.gd must register 'spawn_from_capital' group",
	)


func test_verdant_forest_exit_targets_overgrown_capital() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		source.contains("SP.OVERGROWN_CAPITAL"),
		"ExitToCapital handler must change_scene to SP.OVERGROWN_CAPITAL",
	)


func test_verdant_forest_capital_transition_uses_spawn_from_forest_group() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	## When entering the Capital from the Forest, the spawn group in Capital is
	## "spawn_from_forest" (consistent with other scene → forest-connected spawn groups).
	assert_true(
		source.contains("\"spawn_from_forest\""),
		"Forest→Capital transition must request 'spawn_from_forest' group in Capital",
	)


func test_verdant_forest_tscn_has_exit_to_capital() -> void:
	var tscn := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.tscn"
	)
	assert_true(
		tscn.contains("ExitToCapital"),
		"verdant_forest.tscn must contain ExitToCapital Area2D node",
	)


func test_verdant_forest_tscn_has_spawn_from_capital() -> void:
	var tscn := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.tscn"
	)
	assert_true(
		tscn.contains("SpawnFromCapital"),
		"verdant_forest.tscn must contain SpawnFromCapital Marker2D node",
	)


func test_capital_exit_targets_verdant_forest() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("SP.VERDANT_FOREST"),
		"Overgrown Capital exit must target SP.VERDANT_FOREST (not Overgrown Ruins)",
	)


func test_capital_registers_spawn_from_forest_group() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("spawn_from_forest"),
		"Capital _ready() must register 'spawn_from_forest' group for Forest entry point",
	)


func test_capital_uses_spawn_from_capital_group_for_forest_exit() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	## When player leaves Capital back to Forest, the spawn group in Forest is
	## "spawn_from_capital" — matching the SpawnFromCapital Marker2D in verdant_forest.tscn.
	assert_true(
		source.contains("spawn_from_capital"),
		"Capital exit handler must request 'spawn_from_capital' group in Verdant Forest",
	)
