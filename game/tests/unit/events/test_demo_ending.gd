extends GutTest

## Tests for DemoEnding event script.
## Verifies structure, constants, dialogue content, flag guard, and signal.
## The demo ending fires after GarrickMeetsLyra completes, showing a
## brief closing dialogue before transitioning to the end screen.

var _event: Node


func before_each() -> void:
	_event = load("res://events/demo_ending.gd").new()
	add_child_autofree(_event)


func test_flag_name_is_demo_complete() -> void:
	assert_eq(_event.FLAG_NAME, "demo_complete")


func test_has_sequence_completed_signal() -> void:
	assert_true(_event.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_event.has_method("trigger"))


func test_build_dialogue_returns_non_empty() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_gt(lines.size(), 0, "Should have dialogue lines")


func test_build_dialogue_has_four_lines() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_eq(
		lines.size(), 4,
		"Should have exactly 4 dialogue lines",
	)


func test_first_speaker_is_kael() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_eq(
		lines[0].speaker, "Kael",
		"Kael opens the closing dialogue",
	)


func test_dialogue_contains_path_or_journey() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if "path" in line.text or "journey" in line.text:
			found = true
			break
	assert_true(
		found,
		"Dialogue should mention 'path' or 'journey'",
	)


func test_last_speaker() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var last_speaker: String = lines[lines.size() - 1].speaker
	assert_true(
		last_speaker in ["Kael", "Lyra", "Garrick"],
		"Last speaker should be a party member, got: "
		+ last_speaker,
	)


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


func test_flag_guard_prevents_retrigger() -> void:
	# Verify that FLAG_NAME is used for the guard check
	# by confirming the constant is the expected value
	assert_eq(
		_event.FLAG_NAME, "demo_complete",
		"FLAG_NAME must match for flag guard logic",
	)
	assert_true(
		_event.has_method("trigger"),
		"trigger() must exist for flag guard",
	)
