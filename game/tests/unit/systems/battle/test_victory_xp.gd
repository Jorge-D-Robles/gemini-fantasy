extends GutTest

## Tests for XP application in victory_state.gd (T-0124 regression).
## Verifies that apply_xp_rewards() grants XP to all party members
## and returns level-up info.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const VictoryState := preload(
	"res://systems/battle/states/victory_state.gd"
)


# -- apply_xp_rewards: basic XP application --


func test_apply_xp_rewards_adds_xp_to_each_member() -> void:
	var c1 := Helpers.make_character_data({
		"id": &"hero_a",
		"current_xp": 0,
	})
	var c2 := Helpers.make_character_data({
		"id": &"hero_b",
		"current_xp": 0,
	})
	var party: Array[Resource] = [c1, c2]
	VictoryState.apply_xp_rewards(party, 200)
	assert_eq(c1.current_xp, 200, "Hero A should have 200 XP")
	assert_eq(c2.current_xp, 200, "Hero B should have 200 XP")


func test_apply_xp_rewards_triggers_level_up() -> void:
	var c := Helpers.make_character_data({
		"id": &"hero",
		"current_xp": 0,
		"level": 1,
	})
	var party: Array[Resource] = [c]
	# Level 2 requires 400 XP (100 * 2^2)
	VictoryState.apply_xp_rewards(party, 400)
	assert_eq(c.level, 2, "Hero should level up to 2")


func test_apply_xp_rewards_returns_level_up_info() -> void:
	var c := Helpers.make_character_data({
		"id": &"hero",
		"display_name": "Kael",
		"current_xp": 0,
		"level": 1,
	})
	var party: Array[Resource] = [c]
	var result := VictoryState.apply_xp_rewards(party, 400)
	assert_eq(result.size(), 1, "Should have 1 level-up entry")
	assert_eq(result[0]["character"], "Kael")
	assert_eq(result[0]["level"], 2)
	assert_has(result[0], "changes")


func test_apply_xp_rewards_no_level_up_returns_empty() -> void:
	var c := Helpers.make_character_data({
		"id": &"hero",
		"current_xp": 0,
	})
	var party: Array[Resource] = [c]
	var result := VictoryState.apply_xp_rewards(party, 100)
	assert_eq(result.size(), 0, "No level-ups below threshold")
	assert_eq(c.current_xp, 100)


func test_apply_xp_rewards_multiple_level_ups() -> void:
	var c := Helpers.make_character_data({
		"id": &"hero",
		"current_xp": 0,
		"level": 1,
	})
	var party: Array[Resource] = [c]
	# Level 2 = 400, Level 3 = 900
	var result := VictoryState.apply_xp_rewards(party, 1000)
	assert_eq(c.level, 3, "Hero should reach level 3")
	assert_eq(result.size(), 2, "Two level-ups total")


func test_apply_xp_rewards_skips_non_character_data() -> void:
	var battler := Helpers.make_battler_data({"id": &"generic"})
	var character := Helpers.make_character_data({
		"id": &"hero",
		"current_xp": 0,
	})
	var party: Array[Resource] = [battler, character]
	VictoryState.apply_xp_rewards(party, 200)
	assert_eq(character.current_xp, 200)


func test_apply_xp_rewards_empty_party() -> void:
	var party: Array[Resource] = []
	var result := VictoryState.apply_xp_rewards(party, 500)
	assert_eq(result.size(), 0)


func test_apply_xp_rewards_zero_exp() -> void:
	var c := Helpers.make_character_data({
		"id": &"hero",
		"current_xp": 0,
	})
	var party: Array[Resource] = [c]
	var result := VictoryState.apply_xp_rewards(party, 0)
	assert_eq(c.current_xp, 0)
	assert_eq(result.size(), 0)


func test_apply_xp_rewards_preserves_existing_xp() -> void:
	var c := Helpers.make_character_data({
		"id": &"hero",
		"current_xp": 300,
		"level": 1,
	})
	var party: Array[Resource] = [c]
	VictoryState.apply_xp_rewards(party, 200)
	assert_eq(c.current_xp, 500)
	assert_eq(c.level, 2, "300 + 200 = 500 >= 400 threshold")
