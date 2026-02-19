# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Roothollow quest-offering logic, quest completion conditions,
## and shop wiring helpers. Calls static helper functions on the script.

var _rh: GDScript


func before_each() -> void:
	_rh = load("res://scenes/roothollow/roothollow.gd")


# -- should_offer_quest (pure logic) --

func test_should_offer_returns_true_when_not_started() -> void:
	assert_true(_rh.should_offer_quest(
		&"herb_gathering", [], [],
	))


func test_should_offer_returns_false_when_active() -> void:
	assert_false(_rh.should_offer_quest(
		&"herb_gathering",
		[&"herb_gathering"],
		[],
	))


func test_should_offer_returns_false_when_completed() -> void:
	assert_false(_rh.should_offer_quest(
		&"herb_gathering",
		[],
		[&"herb_gathering"],
	))


func test_should_offer_true_for_different_quest() -> void:
	assert_true(_rh.should_offer_quest(
		&"scouts_report",
		[&"herb_gathering"],
		[],
	))


func test_should_offer_false_when_active_and_completed() -> void:
	assert_false(_rh.should_offer_quest(
		&"herb_gathering",
		[&"herb_gathering"],
		[&"herb_gathering"],
	))


# -- Quest offer text --

func test_herb_quest_offer_not_empty() -> void:
	var text: String = _rh._get_quest_offer(&"herb_gathering")
	assert_true(text.length() > 0)


func test_herb_quest_offer_mentions_herbs() -> void:
	var text: String = _rh._get_quest_offer(&"herb_gathering")
	assert_string_contains(text, "herb")


func test_scouts_quest_offer_not_empty() -> void:
	var text: String = _rh._get_quest_offer(&"scouts_report")
	assert_true(text.length() > 0)


func test_scouts_quest_offer_mentions_ruins() -> void:
	var text: String = _rh._get_quest_offer(&"scouts_report")
	assert_string_contains(text, "ruins")


func test_elder_quest_offer_not_empty() -> void:
	var text: String = _rh._get_quest_offer(&"elder_wisdom")
	assert_true(text.length() > 0)


func test_elder_quest_offer_mentions_memorial() -> void:
	var text: String = _rh._get_quest_offer(&"elder_wisdom")
	assert_string_contains(text, "memorial")


func test_unknown_quest_offer_returns_empty() -> void:
	var text: String = _rh._get_quest_offer(&"nonexistent")
	assert_eq(text, "")


# -- Quest turnin text --

func test_herb_turnin_not_empty() -> void:
	var text: String = _rh._get_quest_turnin(&"herb_gathering")
	assert_true(text.length() > 0)


func test_scouts_turnin_not_empty() -> void:
	var text: String = _rh._get_quest_turnin(&"scouts_report")
	assert_true(text.length() > 0)


func test_elder_turnin_not_empty() -> void:
	var text: String = _rh._get_quest_turnin(&"elder_wisdom")
	assert_true(text.length() > 0)


func test_unknown_turnin_returns_empty() -> void:
	var text: String = _rh._get_quest_turnin(&"nonexistent")
	assert_eq(text, "")


# -- Quest line wrappers --

func test_maren_quest_lines_not_empty() -> void:
	var l: PackedStringArray = _rh.get_quest_offer_lines(&"herb_gathering")
	assert_true(l.size() > 0)


func test_wren_quest_lines_not_empty() -> void:
	var l: PackedStringArray = _rh.get_quest_offer_lines(&"scouts_report")
	assert_true(l.size() > 0)


func test_thessa_quest_lines_not_empty() -> void:
	var l: PackedStringArray = _rh.get_quest_offer_lines(&"elder_wisdom")
	assert_true(l.size() > 0)


func test_maren_quest_complete_not_empty() -> void:
	var l: PackedStringArray = _rh.get_quest_complete_lines(&"herb_gathering")
	assert_true(l.size() > 0)


func test_wren_quest_complete_not_empty() -> void:
	var l: PackedStringArray = _rh.get_quest_complete_lines(&"scouts_report")
	assert_true(l.size() > 0)


func test_thessa_quest_complete_not_empty() -> void:
	var l: PackedStringArray = _rh.get_quest_complete_lines(&"elder_wisdom")
	assert_true(l.size() > 0)


# -- Quest completion conditions --

func test_can_complete_herb_with_enough_items() -> void:
	assert_true(_rh.can_complete_herb_quest(3))


func test_can_complete_herb_with_extra_items() -> void:
	assert_true(_rh.can_complete_herb_quest(5))


func test_cannot_complete_herb_with_too_few() -> void:
	assert_false(_rh.can_complete_herb_quest(2))


func test_cannot_complete_herb_with_zero() -> void:
	assert_false(_rh.can_complete_herb_quest(0))


func test_can_complete_elder_with_obj0_done() -> void:
	var status: Array = [true, false]
	assert_true(_rh.can_complete_elder_quest(status))


func test_cannot_complete_elder_without_obj0() -> void:
	var status: Array = [false, false]
	assert_false(_rh.can_complete_elder_quest(status))


func test_cannot_complete_elder_already_done() -> void:
	var status: Array = [true, true]
	assert_false(_rh.can_complete_elder_quest(status))


func test_cannot_complete_elder_empty_status() -> void:
	var status: Array = []
	assert_false(_rh.can_complete_elder_quest(status))


func test_can_complete_scouts_with_ruins_visited() -> void:
	assert_true(_rh.can_complete_scouts_quest(true))


func test_cannot_complete_scouts_without_ruins() -> void:
	assert_false(_rh.can_complete_scouts_quest(false))
