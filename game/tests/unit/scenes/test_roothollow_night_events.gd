extends GutTest

## Tests for RootHollowNightEvents — innkeeper rest priority logic.
## GarrickNightScene (garrick_met_lyra gate) takes priority over
## CampThreeFires (garrick_recruited gate) when both are pending.

const NightEvents = preload(
	"res://scenes/roothollow/roothollow_night_events.gd"
)


func test_nothing_fires_when_no_flags() -> void:
	var result: StringName = NightEvents.compute_innkeeper_night_event({})
	assert_eq(
		result,
		NightEvents.EVENT_NONE,
		"No flags — no event should fire",
	)


func test_nothing_fires_when_garrick_not_recruited() -> void:
	var result: StringName = NightEvents.compute_innkeeper_night_event(
		{"garrick_met_lyra": false, "garrick_recruited": false}
	)
	assert_eq(result, NightEvents.EVENT_NONE)


func test_camp_fires_when_only_garrick_recruited() -> void:
	var result: StringName = NightEvents.compute_innkeeper_night_event(
		{"garrick_recruited": true}
	)
	assert_eq(
		result,
		NightEvents.EVENT_CAMP_THREE_FIRES,
		"garrick_recruited without garrick_met_lyra → CampThreeFires",
	)


func test_garrick_night_fires_when_garrick_met_lyra() -> void:
	var result: StringName = NightEvents.compute_innkeeper_night_event(
		{"garrick_recruited": true, "garrick_met_lyra": true}
	)
	assert_eq(
		result,
		NightEvents.EVENT_GARRICK_NIGHT,
		"garrick_met_lyra set → GarrickNightScene",
	)


func test_garrick_night_takes_priority_over_camp_when_both_pending() -> void:
	# Both gates are set, neither scene has played
	var flags := {
		"garrick_recruited": true,
		"garrick_met_lyra": true,
	}
	var result: StringName = NightEvents.compute_innkeeper_night_event(flags)
	assert_eq(
		result,
		NightEvents.EVENT_GARRICK_NIGHT,
		"GarrickNightScene takes priority when both events are pending",
	)


func test_camp_fires_after_garrick_night_already_done() -> void:
	# garrick_met_lyra set but GarrickNightScene already played
	var flags := {
		"garrick_recruited": true,
		"garrick_met_lyra": true,
		"garrick_night_scene": true,
	}
	var result: StringName = NightEvents.compute_innkeeper_night_event(flags)
	assert_eq(
		result,
		NightEvents.EVENT_CAMP_THREE_FIRES,
		"After GarrickNightScene is done, CampThreeFires becomes next",
	)


func test_nothing_fires_when_both_scenes_done() -> void:
	var flags := {
		"garrick_recruited": true,
		"garrick_met_lyra": true,
		"camp_scene_three_fires": true,
		"garrick_night_scene": true,
	}
	var result: StringName = NightEvents.compute_innkeeper_night_event(flags)
	assert_eq(
		result,
		NightEvents.EVENT_NONE,
		"Both events done — nothing fires",
	)


func test_camp_skipped_when_camp_flag_set() -> void:
	var flags := {
		"garrick_recruited": true,
		"camp_scene_three_fires": true,
	}
	var result: StringName = NightEvents.compute_innkeeper_night_event(flags)
	assert_eq(
		result,
		NightEvents.EVENT_NONE,
		"CampThreeFires already done — nothing fires",
	)


func test_garrick_night_fires_even_if_camp_done() -> void:
	var flags := {
		"garrick_recruited": true,
		"garrick_met_lyra": true,
		"camp_scene_three_fires": true,
	}
	var result: StringName = NightEvents.compute_innkeeper_night_event(flags)
	assert_eq(
		result,
		NightEvents.EVENT_GARRICK_NIGHT,
		"CampThreeFires done but GarrickNightScene still pending → fires",
	)


func test_garrick_night_requires_garrick_met_lyra_gate() -> void:
	# garrick_met_lyra not set — GarrickNightScene cannot fire
	var flags := {"garrick_recruited": true, "garrick_met_lyra": false}
	var result: StringName = NightEvents.compute_innkeeper_night_event(flags)
	assert_eq(
		result,
		NightEvents.EVENT_CAMP_THREE_FIRES,
		"garrick_met_lyra=false — GarrickNightScene ineligible, CampThreeFires fires",
	)


func test_event_constants_are_distinct() -> void:
	assert_ne(NightEvents.EVENT_GARRICK_NIGHT, NightEvents.EVENT_CAMP_THREE_FIRES)
	assert_ne(NightEvents.EVENT_GARRICK_NIGHT, NightEvents.EVENT_NONE)
	assert_ne(NightEvents.EVENT_CAMP_THREE_FIRES, NightEvents.EVENT_NONE)
