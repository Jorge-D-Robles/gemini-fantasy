extends GutTest

## Tests for DemoEndScreen UI.
## Verifies compute_party_summary() static method and screen type.

const DemoEndScreen = preload(
	"res://ui/demo_end_screen/demo_end_screen.gd"
)
const Helpers = preload("res://tests/helpers/test_helpers.gd")


func test_compute_party_summary_empty_roster() -> void:
	var result: Array[Dictionary] = (
		DemoEndScreen.compute_party_summary(
			[] as Array[Resource],
		)
	)
	assert_eq(
		result.size(), 0,
		"Empty roster should return empty array",
	)


func test_compute_party_summary_one_member_has_name() -> void:
	var char_data: Resource = Helpers.make_character_data({
		"display_name": "Kael",
		"level": 5,
	})
	var result: Array[Dictionary] = (
		DemoEndScreen.compute_party_summary(
			[char_data] as Array[Resource],
		)
	)
	assert_true(
		result[0].has("name"),
		"Result dict should have 'name' key",
	)


func test_compute_party_summary_one_member_has_level() -> void:
	var char_data: Resource = Helpers.make_character_data({
		"display_name": "Kael",
		"level": 5,
	})
	var result: Array[Dictionary] = (
		DemoEndScreen.compute_party_summary(
			[char_data] as Array[Resource],
		)
	)
	assert_true(
		result[0].has("level"),
		"Result dict should have 'level' key",
	)


func test_compute_party_summary_two_members() -> void:
	var kael: Resource = Helpers.make_character_data({
		"display_name": "Kael",
		"level": 5,
	})
	var lyra: Resource = Helpers.make_character_data({
		"display_name": "Lyra",
		"level": 4,
	})
	var result: Array[Dictionary] = (
		DemoEndScreen.compute_party_summary(
			[kael, lyra] as Array[Resource],
		)
	)
	assert_eq(
		result.size(), 2,
		"Two members should return 2-element array",
	)


func test_screen_is_control() -> void:
	var screen: Node = DemoEndScreen.new()
	add_child_autofree(screen)
	assert_true(
		screen is Control,
		"DemoEndScreen should extend Control",
	)


func test_compute_party_summary_extracts_display_name() -> void:
	var char_data: Resource = Helpers.make_character_data({
		"display_name": "Iris",
		"level": 3,
	})
	var result: Array[Dictionary] = (
		DemoEndScreen.compute_party_summary(
			[char_data] as Array[Resource],
		)
	)
	assert_eq(
		result[0]["name"], "Iris",
		"Should extract display_name correctly",
	)


func test_compute_party_summary_extracts_level() -> void:
	var char_data: Resource = Helpers.make_character_data({
		"display_name": "Garrick",
		"level": 7,
	})
	var result: Array[Dictionary] = (
		DemoEndScreen.compute_party_summary(
			[char_data] as Array[Resource],
		)
	)
	assert_eq(
		result[0]["level"], 7,
		"Should extract level correctly",
	)
