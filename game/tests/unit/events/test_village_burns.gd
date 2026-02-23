extends GutTest

## Tests for VillageBurns event — T-0249 Chapter 7 "A Village Burns" scaffold.


func test_compute_can_trigger_false_without_lyra_fragment() -> void:
	var flags: Dictionary = {
		"nyx_met": true,
	}
	assert_false(
		VillageBurns.compute_can_trigger(flags),
		"Must be false when lyra_fragment_2_collected is not set",
	)


func test_compute_can_trigger_false_without_nyx_met() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
	}
	assert_false(
		VillageBurns.compute_can_trigger(flags),
		"Must be false when nyx_met is not set",
	)


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
		"nyx_met": true,
		"village_burns_seen": true,
	}
	assert_false(
		VillageBurns.compute_can_trigger(flags),
		"Must be false when village_burns_seen flag is already set",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
		"nyx_met": true,
	}
	assert_true(
		VillageBurns.compute_can_trigger(flags),
		"Must be true when gate flags set and event not yet seen",
	)


