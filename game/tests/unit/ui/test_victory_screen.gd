extends GutTest

## Tests for BattleUIVictory.compute_victory_display() static method.
## Validates text formatting, member extraction, and level-up marking.

const BattleUI = preload("res://ui/battle_ui/battle_ui_victory.gd")
const Helpers = preload("res://tests/helpers/test_helpers.gd")


func _make_party(names: Array[String]) -> Array[Resource]:
	var party: Array[Resource] = []
	for n: String in names:
		var c := Helpers.make_character_data({
			"display_name": n, "level": 3,
		})
		c.portrait_path = "res://assets/portraits/%s.png" % n.to_lower()
		party.append(c)
	return party


func test_compute_victory_display_basic() -> void:
	var party := _make_party(["Kael"] as Array[String])
	var result := BattleUI.compute_victory_display(
		party, 120, 45, ["fire_potion"], [],
	)
	assert_eq(result["exp_text"], "EXP: +120")
	assert_eq(result["gold_text"], "Gold: +45")
	assert_eq(result["items_text"], "Items: fire_potion")


func test_compute_victory_display_no_items() -> void:
	var party := _make_party(["Kael"] as Array[String])
	var result := BattleUI.compute_victory_display(
		party, 50, 10, [], [],
	)
	assert_eq(result["items_text"], "Items: None")


func test_compute_victory_display_members() -> void:
	var party := _make_party(
		["Kael", "Iris"] as Array[String],
	)
	var result := BattleUI.compute_victory_display(
		party, 100, 20, [], [],
	)
	var members: Array = result["members"]
	assert_eq(members.size(), 2)
	assert_eq(members[0]["name"], "Kael")
	assert_eq(members[0]["level"], 3)
	assert_true(
		members[0]["portrait_path"].length() > 0,
		"Should have portrait path",
	)
	assert_eq(members[1]["name"], "Iris")


func test_compute_victory_display_level_up() -> void:
	var party := _make_party(["Kael"] as Array[String])
	var level_ups: Array[Dictionary] = [{
		"character": "Kael",
		"level": 4,
		"changes": {"max_hp": 10, "attack": 2},
	}]
	var result := BattleUI.compute_victory_display(
		party, 100, 20, [], level_ups,
	)
	var members: Array = result["members"]
	assert_true(members[0]["leveled_up"], "Should be marked leveled")
	assert_eq(members[0]["level"], 4)
	var msgs: Array = result["level_up_messages"]
	assert_true(msgs.size() > 0, "Should have level-up message")


func test_compute_victory_display_no_level_ups() -> void:
	var party := _make_party(["Kael"] as Array[String])
	var result := BattleUI.compute_victory_display(
		party, 50, 10, [], [],
	)
	var members: Array = result["members"]
	assert_false(
		members[0]["leveled_up"],
		"Should not be marked leveled",
	)
	var msgs: Array = result["level_up_messages"]
	assert_eq(msgs.size(), 0)


func test_compute_victory_display_empty_party() -> void:
	var result := BattleUI.compute_victory_display(
		[], 50, 10, [], [],
	)
	assert_eq(result["members"].size(), 0)
	assert_eq(result["exp_text"], "EXP: +50")


func test_compute_victory_display_multiple_level_ups() -> void:
	var party := _make_party(
		["Kael", "Iris", "Garrick"] as Array[String],
	)
	var level_ups: Array[Dictionary] = [
		{
			"character": "Kael",
			"level": 4,
			"changes": {"max_hp": 10},
		},
		{
			"character": "Garrick",
			"level": 4,
			"changes": {"defense": 3},
		},
	]
	var result := BattleUI.compute_victory_display(
		party, 200, 60, ["herb"], level_ups,
	)
	var members: Array = result["members"]
	assert_true(members[0]["leveled_up"], "Kael leveled")
	assert_false(members[1]["leveled_up"], "Iris did not level")
	assert_true(members[2]["leveled_up"], "Garrick leveled")
	var msgs: Array = result["level_up_messages"]
	assert_eq(msgs.size(), 2, "Two level-up messages")
