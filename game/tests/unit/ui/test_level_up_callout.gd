extends GutTest

## Tests for T-0126: BattleUIVictory level-up callout text helper.
## Validates compute_level_up_callout_text() format and edge cases.

const BattleUIVictory := preload("res://ui/battle_ui/battle_ui_victory.gd")
const Helpers := preload("res://tests/helpers/test_helpers.gd")


func _make_party(names: Array[String]) -> Array[Resource]:
	var party: Array[Resource] = []
	for n: String in names:
		party.append(Helpers.make_character_data({"display_name": n, "level": 1}))
	return party


func test_callout_includes_character_name() -> void:
	var text := BattleUIVictory.compute_level_up_callout_text(
		"Kael", 4, {}
	)
	assert_true(text.contains("Kael"), "Callout must include character name")


func test_callout_includes_level() -> void:
	var text := BattleUIVictory.compute_level_up_callout_text(
		"Kael", 4, {}
	)
	assert_true(text.contains("4"), "Callout must include the new level")


func test_callout_includes_stat_changes() -> void:
	var text := BattleUIVictory.compute_level_up_callout_text(
		"Iris", 3, {"max_hp": 8, "attack": 2}
	)
	assert_true(text.contains("HP"), "Should show HP stat abbreviation")
	assert_true(text.contains("ATK"), "Should show ATK stat abbreviation")


func test_callout_empty_changes_is_valid() -> void:
	var text := BattleUIVictory.compute_level_up_callout_text(
		"Garrick", 5, {}
	)
	assert_false(text.is_empty(), "Even with no stat changes, callout must be non-empty")


func test_callout_includes_positive_sign_on_gains() -> void:
	var text := BattleUIVictory.compute_level_up_callout_text(
		"Lyra", 6, {"magic": 5}
	)
	assert_true(text.contains("+"), "Stat gains should show '+' prefix")


func test_callout_text_for_multiple_stats() -> void:
	var text := BattleUIVictory.compute_level_up_callout_text(
		"Kael", 4, {"max_hp": 10, "attack": 2, "defense": 1}
	)
	# All three stat abbreviations must appear
	assert_true(text.contains("HP"), "Must show HP")
	assert_true(text.contains("ATK"), "Must show ATK")
	assert_true(text.contains("DEF"), "Must show DEF")


func test_level_up_messages_list_has_one_entry_per_leveled_character() -> void:
	var party := _make_party(["Kael", "Iris", "Garrick"] as Array[String])
	var level_ups: Array[Dictionary] = [
		{"character": "Kael", "level": 4, "changes": {"max_hp": 10}},
		{"character": "Garrick", "level": 3, "changes": {"defense": 2}},
	]
	var result := BattleUIVictory.compute_victory_display(
		party, 100, 0, [], level_ups,
	)
	var msgs: Array = result["level_up_messages"]
	assert_eq(msgs.size(), 2, "One message per leveled character")
