extends GutTest

## Tests for Roothollow quest-offering logic, quest completion conditions,
## and shop wiring helpers. Calls static helper functions on the script.

var _rh: GDScript


func before_each() -> void:
	_rh = load("res://scenes/roothollow/roothollow_quests.gd")


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


# -- Quest offer/turnin boundary tests --

func test_unknown_quest_offer_returns_empty() -> void:
	var text: String = _rh.get_quest_offer(&"nonexistent")
	assert_eq(text, "")


func test_unknown_turnin_returns_empty() -> void:
	var text: String = _rh.get_quest_turnin(&"nonexistent")
	assert_eq(text, "")


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
