extends GutTest

## Tests for T-0282: Verdant Forest → Prismfall Approach transition wiring.
## Verifies ExitToPrismfall in Forest, SpawnFromPrismfall in Forest,
## and bidirectional scene change destinations.


func test_forest_declares_exit_to_prismfall() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		source.contains("ExitToPrismfall"),
		"verdant_forest.gd must declare ExitToPrismfall",
	)


func test_forest_declares_spawn_from_prismfall() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		source.contains("SpawnFromPrismfall"),
		"verdant_forest.gd must declare SpawnFromPrismfall",
	)


func test_forest_registers_spawn_from_prismfall_group() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		source.contains("spawn_from_prismfall"),
		"Forest must register 'spawn_from_prismfall' group",
	)


func test_forest_exit_targets_prismfall_approach() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		source.contains("SP.PRISMFALL_APPROACH"),
		"Exit handler must change_scene to SP.PRISMFALL_APPROACH",
	)


func test_forest_tscn_has_exit_to_prismfall() -> void:
	var tscn := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.tscn"
	)
	assert_true(
		tscn.contains("ExitToPrismfall"),
		"verdant_forest.tscn must contain ExitToPrismfall Area2D",
	)


func test_forest_tscn_has_spawn_from_prismfall() -> void:
	var tscn := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.tscn"
	)
	assert_true(
		tscn.contains("SpawnFromPrismfall"),
		"verdant_forest.tscn must contain SpawnFromPrismfall Marker2D",
	)


func test_prismfall_exit_targets_verdant_forest() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/prismfall_approach/prismfall_approach.gd"
	)
	assert_true(
		source.contains("SP.VERDANT_FOREST"),
		"Prismfall exit must target SP.VERDANT_FOREST",
	)


func test_prismfall_registers_spawn_from_forest_group() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/prismfall_approach/prismfall_approach.gd"
	)
	assert_true(
		source.contains("spawn_from_forest"),
		"Prismfall must register 'spawn_from_forest' group",
	)


# -- Approach → Prismfall town transition (T-0280) --


func test_approach_declares_exit_to_prismfall() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/prismfall_approach/prismfall_approach.gd"
	)
	assert_true(
		source.contains("ExitToPrismfall"),
		"approach must declare ExitToPrismfall",
	)


func test_approach_exit_targets_prismfall_town() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/prismfall_approach/prismfall_approach.gd"
	)
	assert_true(
		source.contains("SP.PRISMFALL"),
		"Exit handler must change_scene to SP.PRISMFALL",
	)


func test_approach_exit_uses_spawn_from_approach_group() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/prismfall_approach/prismfall_approach.gd"
	)
	assert_true(
		source.contains("spawn_from_approach"),
		"Exit must target spawn_from_approach group",
	)


func test_approach_tscn_has_exit_to_prismfall() -> void:
	var tscn := FileAccess.get_file_as_string(
		"res://scenes/prismfall_approach/prismfall_approach.tscn"
	)
	assert_true(
		tscn.contains("ExitToPrismfall"),
		"approach.tscn must contain ExitToPrismfall Area2D",
	)


func test_prismfall_town_registers_spawn_from_approach() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/prismfall/prismfall.gd"
	)
	assert_true(
		source.contains("spawn_from_approach"),
		"Prismfall town must register spawn_from_approach group",
	)


func test_prismfall_town_exit_targets_approach() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/prismfall/prismfall.gd"
	)
	assert_true(
		source.contains("SP.PRISMFALL_APPROACH"),
		"Prismfall town exit must target SP.PRISMFALL_APPROACH",
	)
