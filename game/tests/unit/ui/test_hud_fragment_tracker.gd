extends GutTest

## Tests for HudFragmentTracker — static compass/signal direction helper.
## Verifies visibility rules and directional hints per story flag state.

const HudFragmentTracker = preload(
	"res://ui/hud/hud_fragment_tracker.gd"
)

# Scene path constants (mirror ScenePaths to avoid preload coupling in test)
const SP = preload("res://systems/scene_paths.gd")


# ---------- visibility rules ----------

func test_hidden_before_opening_sequence() -> void:
	var result: Dictionary = HudFragmentTracker.compute_tracker_display(
		{}, SP.OVERGROWN_RUINS,
	)
	assert_false(result["visible"], "Tracker must be hidden before Lyra is found")


func test_visible_after_opening_sequence() -> void:
	var flags: Dictionary = {"opening_lyra_discovered": true}
	var result: Dictionary = HudFragmentTracker.compute_tracker_display(
		flags, SP.VERDANT_FOREST,
	)
	# Forest solo: Iris is here — direction is empty, tracker hides
	# (player is in the right place already)
	# Test that it is visible somewhere (e.g., ruins solo → east)
	var result_ruins: Dictionary = HudFragmentTracker.compute_tracker_display(
		flags, SP.OVERGROWN_RUINS,
	)
	assert_true(result_ruins["visible"], "Tracker must be visible from ruins after opening")


func test_hidden_after_garrick_met_lyra() -> void:
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
		"garrick_recruited": true,
		"garrick_met_lyra": true,
	}
	var result: Dictionary = HudFragmentTracker.compute_tracker_display(
		flags, SP.OVERGROWN_RUINS,
	)
	assert_false(result["visible"], "Tracker must hide after garrick_met_lyra — demo end")


# ---------- direction: solo (opening done, no recruits) ----------

func test_direction_east_from_ruins_solo() -> void:
	var flags: Dictionary = {"opening_lyra_discovered": true}
	var dir: String = HudFragmentTracker.compute_signal_direction(
		flags, SP.OVERGROWN_RUINS,
	)
	assert_eq(dir, HudFragmentTracker.DIR_EAST,
		"Solo: head east from ruins toward Verdant Forest")


func test_direction_none_from_forest_solo() -> void:
	# Iris recruitment event fires in the forest — player is in the right place
	var flags: Dictionary = {"opening_lyra_discovered": true}
	var dir: String = HudFragmentTracker.compute_signal_direction(
		flags, SP.VERDANT_FOREST,
	)
	assert_eq(dir, HudFragmentTracker.DIR_NONE,
		"Solo in forest: Iris event fires here — no direction needed")


func test_direction_west_from_town_solo() -> void:
	var flags: Dictionary = {"opening_lyra_discovered": true}
	var dir: String = HudFragmentTracker.compute_signal_direction(
		flags, SP.ROOTHOLLOW,
	)
	assert_eq(dir, HudFragmentTracker.DIR_WEST,
		"Solo in Roothollow: head west to Verdant Forest for Iris")


# ---------- direction: iris recruited, no garrick ----------

func test_direction_east_from_ruins_iris_no_garrick() -> void:
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
	}
	var dir: String = HudFragmentTracker.compute_signal_direction(
		flags, SP.OVERGROWN_RUINS,
	)
	assert_eq(dir, HudFragmentTracker.DIR_EAST,
		"Iris recruited: head east from ruins toward Roothollow")


func test_direction_east_from_forest_iris_no_garrick() -> void:
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
	}
	var dir: String = HudFragmentTracker.compute_signal_direction(
		flags, SP.VERDANT_FOREST,
	)
	assert_eq(dir, HudFragmentTracker.DIR_EAST,
		"Iris recruited: head east through forest toward Roothollow")


func test_direction_none_from_town_iris_no_garrick() -> void:
	# Garrick recruitment fires in Roothollow — player is in the right place
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
	}
	var dir: String = HudFragmentTracker.compute_signal_direction(
		flags, SP.ROOTHOLLOW,
	)
	assert_eq(dir, HudFragmentTracker.DIR_NONE,
		"Iris in Roothollow: Garrick event fires here — no direction needed")


# ---------- direction: garrick recruited (full party) ----------

func test_direction_northeast_from_ruins_garrick() -> void:
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
		"garrick_recruited": true,
	}
	var dir: String = HudFragmentTracker.compute_signal_direction(
		flags, SP.OVERGROWN_RUINS,
	)
	assert_eq(dir, HudFragmentTracker.DIR_NORTHEAST,
		"Full party in ruins: research quarter is northeast")


func test_direction_west_from_forest_garrick() -> void:
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
		"garrick_recruited": true,
	}
	var dir: String = HudFragmentTracker.compute_signal_direction(
		flags, SP.VERDANT_FOREST,
	)
	assert_eq(dir, HudFragmentTracker.DIR_WEST,
		"Full party in forest: head west back to ruins")


func test_direction_west_from_town_garrick() -> void:
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
		"garrick_recruited": true,
	}
	var dir: String = HudFragmentTracker.compute_signal_direction(
		flags, SP.ROOTHOLLOW,
	)
	assert_eq(dir, HudFragmentTracker.DIR_WEST,
		"Full party in Roothollow: head west through forest to ruins")


# ---------- label format ----------

func test_label_contains_direction_arrow() -> void:
	var flags: Dictionary = {
		"opening_lyra_discovered": true,
		"iris_recruited": true,
		"garrick_recruited": true,
	}
	var label: String = HudFragmentTracker.compute_tracker_label(
		flags, SP.OVERGROWN_RUINS,
	)
	assert_true(
		HudFragmentTracker.DIR_NORTHEAST in label,
		"Label must include the direction arrow",
	)


func test_label_empty_when_not_visible() -> void:
	var label: String = HudFragmentTracker.compute_tracker_label(
		{}, SP.OVERGROWN_RUINS,
	)
	assert_eq(label, "", "Label must be empty when tracker is not visible")


func test_compute_tracker_display_returns_dict() -> void:
	var result: Dictionary = HudFragmentTracker.compute_tracker_display(
		{"opening_lyra_discovered": true}, SP.OVERGROWN_RUINS,
	)
	assert_true(result.has("visible"), "Must have 'visible' key")
	assert_true(result.has("label"), "Must have 'label' key")
