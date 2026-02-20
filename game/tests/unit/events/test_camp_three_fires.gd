extends GutTest

## Tests for CampThreeFires event script.

var _event: Node


func before_each() -> void:
	_event = load("res://events/camp_three_fires.gd").new()
	add_child_autofree(_event)


func test_build_dialogue_returns_array() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_gt(lines.size(), 0, "Should have dialogue lines")
