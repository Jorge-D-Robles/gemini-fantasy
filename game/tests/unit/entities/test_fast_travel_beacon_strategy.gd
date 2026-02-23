extends GutTest

## Tests for FastTravelBeaconStrategy — unlock text and flag logic.

const StrategyScript = preload(
	"res://entities/interactable/strategies/fast_travel_beacon_strategy.gd"
)


func test_compute_unlock_text_new_beacon() -> void:
	var text: String = StrategyScript.compute_unlock_text(
		"Roothollow", false,
	)
	assert_string_contains(text, "Roothollow")
	assert_string_contains(text, "activated")


func test_compute_unlock_text_already_unlocked() -> void:
	var text: String = StrategyScript.compute_unlock_text(
		"Roothollow", true,
	)
	assert_string_contains(text, "Roothollow")
	# Should not say "activated" for already-unlocked beacons
	assert_false(
		text.contains("activated"),
		"Already-unlocked beacon text should not say 'activated'",
	)


func test_compute_unlock_text_different_name() -> void:
	var text: String = StrategyScript.compute_unlock_text(
		"Verdant Forest", false,
	)
	assert_string_contains(text, "Verdant Forest")
