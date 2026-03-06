# gdlint:ignore = max-public-methods
extends GutTest

## Act I critical path flow test (T-0291).
## Verifies the full Act I game flow without live scene instantiation:
##   - All scene files exist and are loadable
##   - Scene transitions form a connected graph
##   - Event flag chains gate correctly (each chapter enables the next)
##   - Character data files exist for recruitment events
##   - ScenePaths constants are defined for every Act I location
##   - Each scene script references correct autoloads and events


# --- Scene file existence ---


func test_all_act1_scene_files_exist() -> void:
	var paths: Array[String] = [
		ScenePaths.OVERGROWN_RUINS,
		ScenePaths.VERDANT_FOREST,
		ScenePaths.ROOTHOLLOW,
		ScenePaths.OVERGROWN_CAPITAL,
		ScenePaths.PRISMFALL_APPROACH,
		ScenePaths.PRISMFALL,
		ScenePaths.BENEATH_PRISMFALL,
		ScenePaths.TITLE_SCREEN,
	]
	for path: String in paths:
		assert_true(
			FileAccess.file_exists(path),
			"Scene must exist: %s" % path,
		)


func test_all_act1_scene_scripts_exist() -> void:
	var scripts: Array[String] = [
		"res://scenes/overgrown_ruins/overgrown_ruins.gd",
		"res://scenes/verdant_forest/verdant_forest.gd",
		"res://scenes/roothollow/roothollow.gd",
		"res://scenes/overgrown_capital/overgrown_capital.gd",
		"res://scenes/prismfall_approach/prismfall_approach.gd",
		"res://scenes/prismfall/prismfall.gd",
		"res://scenes/beneath_prismfall/beneath_prismfall.gd",
	]
	for path: String in scripts:
		assert_true(
			FileAccess.file_exists(path),
			"Script must exist: %s" % path,
		)


# --- ScenePaths constants ---


func test_scene_paths_all_act1_constants_defined() -> void:
	assert_true(
		ScenePaths.OVERGROWN_RUINS.length() > 0,
		"OVERGROWN_RUINS must be defined",
	)
	assert_true(
		ScenePaths.VERDANT_FOREST.length() > 0,
		"VERDANT_FOREST must be defined",
	)
	assert_true(
		ScenePaths.ROOTHOLLOW.length() > 0,
		"ROOTHOLLOW must be defined",
	)
	assert_true(
		ScenePaths.OVERGROWN_CAPITAL.length() > 0,
		"OVERGROWN_CAPITAL must be defined",
	)
	assert_true(
		ScenePaths.PRISMFALL_APPROACH.length() > 0,
		"PRISMFALL_APPROACH must be defined",
	)
	assert_true(
		ScenePaths.PRISMFALL.length() > 0,
		"PRISMFALL must be defined",
	)
	assert_true(
		ScenePaths.BENEATH_PRISMFALL.length() > 0,
		"BENEATH_PRISMFALL must be defined",
	)


# --- Scene transition graph (bidirectional) ---


func _read_scene(path: String) -> String:
	return FileAccess.get_file_as_string(path)


func test_ruins_exits_to_forest() -> void:
	var src := _read_scene(
		"res://scenes/overgrown_ruins/overgrown_ruins.gd"
	)
	assert_true(
		src.contains("SP.VERDANT_FOREST"),
		"Ruins must exit to Verdant Forest",
	)


func test_forest_exits_to_ruins() -> void:
	var src := _read_scene(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		src.contains("SP.OVERGROWN_RUINS"),
		"Forest must exit to Overgrown Ruins",
	)


func test_forest_exits_to_roothollow() -> void:
	var src := _read_scene(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		src.contains("SP.ROOTHOLLOW"),
		"Forest must exit to Roothollow",
	)


func test_roothollow_exits_to_forest() -> void:
	var src := _read_scene("res://scenes/roothollow/roothollow.gd")
	assert_true(
		src.contains("SP.VERDANT_FOREST"),
		"Roothollow must exit to Verdant Forest",
	)


func test_forest_exits_to_capital() -> void:
	var src := _read_scene(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		src.contains("SP.OVERGROWN_CAPITAL"),
		"Forest must exit to Overgrown Capital",
	)


func test_capital_exits_to_forest() -> void:
	var src := _read_scene(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		src.contains("SP.VERDANT_FOREST"),
		"Capital must exit to Verdant Forest",
	)


func test_forest_exits_to_prismfall_approach() -> void:
	var src := _read_scene(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		src.contains("SP.PRISMFALL_APPROACH"),
		"Forest must exit to Prismfall Approach",
	)


func test_approach_exits_to_forest() -> void:
	var src := _read_scene(
		"res://scenes/prismfall_approach/prismfall_approach.gd"
	)
	assert_true(
		src.contains("SP.VERDANT_FOREST"),
		"Approach must exit to Verdant Forest",
	)


func test_approach_exits_to_prismfall_town() -> void:
	var src := _read_scene(
		"res://scenes/prismfall_approach/prismfall_approach.gd"
	)
	assert_true(
		src.contains("SP.PRISMFALL"),
		"Approach must exit to Prismfall town",
	)


func test_prismfall_exits_to_approach() -> void:
	var src := _read_scene("res://scenes/prismfall/prismfall.gd")
	assert_true(
		src.contains("SP.PRISMFALL_APPROACH"),
		"Prismfall town must exit to Approach",
	)


func test_prismfall_exits_to_beneath() -> void:
	var src := _read_scene("res://scenes/prismfall/prismfall.gd")
	assert_true(
		src.contains("SP.BENEATH_PRISMFALL"),
		"Prismfall town must exit to Beneath Prismfall",
	)


func test_beneath_exits_to_prismfall() -> void:
	var src := _read_scene(
		"res://scenes/beneath_prismfall/beneath_prismfall.gd"
	)
	assert_true(
		src.contains("SP.PRISMFALL"),
		"Beneath Prismfall must exit to Prismfall town",
	)


# --- Event flag chain ---


func test_opening_sequence_flag() -> void:
	assert_eq(
		OpeningSequence.FLAG_NAME, "opening_lyra_discovered",
		"Opening sets opening_lyra_discovered",
	)


func test_iris_recruitment_flag() -> void:
	assert_eq(
		IrisRecruitment.FLAG_NAME, "iris_recruited",
		"Iris recruitment sets iris_recruited",
	)


func test_garrick_recruitment_flag() -> void:
	assert_eq(
		GarrickRecruitment.FLAG_NAME, "garrick_recruited",
		"Garrick recruitment sets garrick_recruited",
	)


func test_nyx_introduction_flag() -> void:
	assert_eq(
		NyxIntroduction.FLAG_NAME, "nyx_introduction_seen",
		"Nyx intro sets nyx_introduction_seen",
	)


func test_nyx_born_gate_requires_introduction() -> void:
	assert_false(
		NyxBornFromNothing.compute_can_trigger({}),
		"Born from Nothing requires nyx_introduction_seen",
	)
	assert_true(
		NyxBornFromNothing.compute_can_trigger(
			{"nyx_introduction_seen": true}
		),
		"Born from Nothing triggers after nyx_introduction_seen",
	)


func test_village_burns_gate() -> void:
	assert_false(
		VillageBurns.compute_can_trigger({}),
		"Village Burns requires lyra_fragment_2_collected + nyx_met",
	)
	assert_true(
		VillageBurns.compute_can_trigger(
			{
				"lyra_fragment_2_collected": true,
				"nyx_met": true,
			}
		),
		"Village Burns triggers after prerequisites met",
	)


func test_crystal_city_arrival_gate() -> void:
	assert_false(
		CrystalCityArrival.compute_can_trigger({}),
		"Crystal City requires village_burns_seen",
	)
	assert_true(
		CrystalCityArrival.compute_can_trigger(
			{"village_burns_seen": true}
		),
		"Crystal City triggers after village_burns_seen",
	)


func test_lyras_truth_gate() -> void:
	assert_false(
		LyrasTruth.compute_can_trigger({}),
		"Lyra's Truth requires prismfall_arrived",
	)
	assert_true(
		LyrasTruth.compute_can_trigger(
			{"prismfall_arrived": true}
		),
		"Lyra's Truth triggers after prismfall_arrived",
	)


func test_captured_gate() -> void:
	assert_false(
		Captured.compute_can_trigger({}),
		"Captured requires lyras_truth_seen",
	)
	assert_true(
		Captured.compute_can_trigger(
			{"lyras_truth_seen": true}
		),
		"Captured triggers after lyras_truth_seen",
	)


func test_full_flag_chain_enables_captured() -> void:
	# Simulate progressing through all Act I flags
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
		"garrick_recruited": true,
		"nyx_introduction_seen": true,
		"nyx_born_from_nothing_seen": true,
		"nyx_met": true,
		"lyra_fragment_2_collected": true,
		"village_burns_seen": true,
		"prismfall_arrived": true,
		"lyras_truth_seen": true,
	}
	assert_true(
		Captured.compute_can_trigger(flags),
		"Full Act I flag chain must enable Captured",
	)


func test_full_flag_chain_disables_earlier_events() -> void:
	# After all flags are set, earlier events should not re-trigger
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
		"garrick_recruited": true,
		"nyx_introduction_seen": true,
		"nyx_born_from_nothing_seen": true,
		"nyx_met": true,
		"lyra_fragment_2_collected": true,
		"village_burns_seen": true,
		"prismfall_arrived": true,
		"lyras_truth_seen": true,
		"kael_anchor_revealed": true,
	}
	assert_false(
		VillageBurns.compute_can_trigger(flags),
		"Village Burns must not re-trigger",
	)
	assert_false(
		CrystalCityArrival.compute_can_trigger(flags),
		"Crystal City must not re-trigger",
	)
	assert_false(
		LyrasTruth.compute_can_trigger(flags),
		"Lyra's Truth must not re-trigger",
	)
	assert_false(
		Captured.compute_can_trigger(flags),
		"Captured must not re-trigger",
	)


# --- Character data files for recruitment ---


func test_party_character_data_files_exist() -> void:
	var characters: Array[String] = [
		"res://data/characters/kael.tres",
		"res://data/characters/lyra.tres",
		"res://data/characters/iris.tres",
		"res://data/characters/garrick.tres",
		"res://data/characters/nyx.tres",
	]
	for path: String in characters:
		assert_true(
			FileAccess.file_exists(path),
			"Character data must exist: %s" % path,
		)


# --- Event script files exist ---


func test_all_act1_event_scripts_exist() -> void:
	var events: Array[String] = [
		"res://events/opening_sequence.gd",
		"res://events/iris_recruitment.gd",
		"res://events/garrick_recruitment.gd",
		"res://events/nyx_introduction.gd",
		"res://events/nyx_born_from_nothing.gd",
		"res://events/village_burns.gd",
		"res://events/crystal_city_arrival.gd",
		"res://events/lyras_truth.gd",
		"res://events/captured.gd",
	]
	for path: String in events:
		assert_true(
			FileAccess.file_exists(path),
			"Event script must exist: %s" % path,
		)


# --- Scene scripts reference their events ---


func test_ruins_references_opening_sequence() -> void:
	var src := _read_scene(
		"res://scenes/overgrown_ruins/overgrown_ruins.gd"
	)
	assert_true(
		src.contains("OpeningSequence"),
		"Ruins must reference OpeningSequence event",
	)


func test_forest_references_iris_recruitment() -> void:
	var src := _read_scene(
		"res://scenes/verdant_forest/verdant_forest.gd"
	)
	assert_true(
		src.contains("IrisRecruitment"),
		"Forest must reference IrisRecruitment event",
	)


func test_roothollow_references_garrick_recruitment() -> void:
	var src := _read_scene("res://scenes/roothollow/roothollow.gd")
	assert_true(
		src.contains("GarrickRecruitment"),
		"Roothollow must reference GarrickRecruitment event",
	)


func test_prismfall_references_crystal_city_arrival() -> void:
	var src := _read_scene("res://scenes/prismfall/prismfall.gd")
	assert_true(
		src.contains("CrystalCityArrival"),
		"Prismfall must reference CrystalCityArrival event",
	)


func test_beneath_references_lyras_truth() -> void:
	var src := _read_scene(
		"res://scenes/beneath_prismfall/beneath_prismfall.gd"
	)
	assert_true(
		src.contains("LyrasTruth"),
		"Beneath Prismfall must reference LyrasTruth event",
	)


# --- Encounter data files ---


func test_encounter_enemies_data_exist() -> void:
	var enemies: Array[String] = [
		"res://data/enemies/memory_bloom.tres",
		"res://data/enemies/creeping_vine.tres",
		"res://data/enemies/ash_stalker.tres",
		"res://data/enemies/crystal_sentinel.tres",
		"res://data/enemies/resonance_wisp.tres",
	]
	for path: String in enemies:
		assert_true(
			FileAccess.file_exists(path),
			"Enemy data must exist: %s" % path,
		)
