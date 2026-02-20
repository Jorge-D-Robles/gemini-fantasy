extends GutTest

## Tests for DemoEnding event script.

var _event: Node


func before_each() -> void:
	_event = load("res://events/demo_ending.gd").new()
	add_child_autofree(_event)


func test_build_dialogue_returns_non_empty() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_gt(lines.size(), 0, "Should have dialogue lines")


func test_all_speakers_are_valid() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var valid_speakers: Array[String] = [
		"Kael", "Lyra", "Garrick",
	]
	for line: DialogueLine in lines:
		assert_true(
			line.speaker in valid_speakers,
			"Invalid speaker: " + line.speaker,
		)
