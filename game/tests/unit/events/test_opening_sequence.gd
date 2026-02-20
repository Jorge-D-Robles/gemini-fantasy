extends GutTest

## Tests for OpeningSequence event script.

var _sequence: Node


func before_each() -> void:
	_sequence = load("res://events/opening_sequence.gd").new()
	add_child_autofree(_sequence)


func test_build_dialogue_returns_array() -> void:
	var lines: Array[DialogueLine] = _sequence._build_dialogue()
	assert_gt(lines.size(), 0, "Should have dialogue lines")
