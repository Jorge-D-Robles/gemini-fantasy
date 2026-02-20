extends GutTest

## Tests for T-0244: EventFlagRegistry — centralized flag string constants.
## Verifies constants are non-empty, unique, and match the values used
## by their corresponding event classes.

const Registry = preload("res://events/event_flag_registry.gd")


func test_recruitment_flags_are_non_empty() -> void:
	assert_false(Registry.OPENING_LYRA_DISCOVERED.is_empty())
	assert_false(Registry.IRIS_RECRUITED.is_empty())
	assert_false(Registry.GARRICK_RECRUITED.is_empty())
	assert_false(Registry.NYX_MET.is_empty())


func test_story_flags_are_non_empty() -> void:
	assert_false(Registry.GARRICK_MET_LYRA.is_empty())
	assert_false(Registry.GARRICK_NIGHT_SCENE.is_empty())
	assert_false(Registry.CAMP_SCENE_THREE_FIRES.is_empty())
	assert_false(Registry.BOSS_DEFEATED.is_empty())
	assert_false(Registry.DEMO_COMPLETE.is_empty())
	assert_false(Registry.AFTER_CAPITAL_CAMP_SEEN.is_empty())
	assert_false(Registry.LEAVING_CAPITAL_SEEN.is_empty())
	assert_false(Registry.LYRA_FRAGMENT_2_COLLECTED.is_empty())


func test_gardener_flags_are_non_empty() -> void:
	assert_false(Registry.GARDENER_ENCOUNTERED.is_empty())
	assert_false(Registry.GARDENER_RESOLUTION_PEACEFUL.is_empty())
	assert_false(Registry.GARDENER_RESOLUTION_QUEST.is_empty())
	assert_false(Registry.GARDENER_RESOLUTION_DEFEATED.is_empty())


func test_registry_matches_event_class_flag_names() -> void:
	const OpeningSeq = preload("res://events/opening_sequence.gd")
	const GarrickRec = preload("res://events/garrick_recruitment.gd")
	const IrisRec = preload("res://events/iris_recruitment.gd")
	const GarrickLyra = preload("res://events/garrick_meets_lyra.gd")
	const CampFires = preload("res://events/camp_three_fires.gd")
	const Boss = preload("res://events/boss_encounter.gd")

	assert_eq(Registry.OPENING_LYRA_DISCOVERED, OpeningSeq.FLAG_NAME)
	assert_eq(Registry.GARRICK_RECRUITED, GarrickRec.FLAG_NAME)
	assert_eq(Registry.IRIS_RECRUITED, IrisRec.FLAG_NAME)
	assert_eq(Registry.GARRICK_MET_LYRA, GarrickLyra.FLAG_NAME)
	assert_eq(Registry.CAMP_SCENE_THREE_FIRES, CampFires.FLAG_NAME)
	assert_eq(Registry.BOSS_DEFEATED, Boss.FLAG_NAME)


func test_all_flags_are_unique() -> void:
	var all_flags: Array[String] = [
		Registry.OPENING_LYRA_DISCOVERED,
		Registry.IRIS_RECRUITED,
		Registry.GARRICK_RECRUITED,
		Registry.NYX_MET,
		Registry.NYX_INTRODUCTION_SEEN,
		Registry.GARRICK_MET_LYRA,
		Registry.GARRICK_NIGHT_SCENE,
		Registry.CAMP_SCENE_THREE_FIRES,
		Registry.BOSS_DEFEATED,
		Registry.DEMO_COMPLETE,
		Registry.AFTER_CAPITAL_CAMP_SEEN,
		Registry.LEAVING_CAPITAL_SEEN,
		Registry.LYRA_FRAGMENT_2_COLLECTED,
		Registry.GARDENER_ENCOUNTERED,
		Registry.GARDENER_RESOLUTION_PEACEFUL,
		Registry.GARDENER_RESOLUTION_QUEST,
		Registry.GARDENER_RESOLUTION_DEFEATED,
	]
	var unique_flags: Dictionary = {}
	for flag: String in all_flags:
		assert_false(
			unique_flags.has(flag),
			"Flag '%s' appears more than once in the registry" % flag,
		)
		unique_flags[flag] = true
