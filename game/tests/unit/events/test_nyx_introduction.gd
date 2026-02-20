extends GutTest

## Tests for NyxIntroduction event script.
## T-0225: Chapter 6 Nyx introduction — "Born from Nothing" Hollows border encounter.
## Verifies flag constants, gating logic, dialogue content, and signal contract.
## Source: docs/story/act1/06-born-from-nothing.md (Scenes 1-3)

var _event: Node


func before_each() -> void:
	_event = load("res://events/nyx_introduction.gd").new()
	add_child_autofree(_event)


func test_flag_name_is_nyx_introduction_seen() -> void:
	assert_eq(_event.FLAG_NAME, "nyx_introduction_seen")


func test_nyx_met_flag_constant() -> void:
	assert_eq(_event.NYX_MET_FLAG, "nyx_met")


func test_has_sequence_completed_signal() -> void:
	assert_true(_event.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_event.has_method("trigger"))


func test_compute_can_trigger_false_without_garrick_recruited() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
	}
	assert_false(
		NyxIntroduction.compute_can_trigger(flags),
		"Must be false when garrick_recruited is not set",
	)


func test_compute_can_trigger_false_without_lyra_fragment() -> void:
	var flags: Dictionary = {
		"garrick_recruited": true,
	}
	assert_false(
		NyxIntroduction.compute_can_trigger(flags),
		"Must be false when lyra_fragment_2_collected is not set",
	)


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags: Dictionary = {
		"garrick_recruited": true,
		"lyra_fragment_2_collected": true,
		"nyx_introduction_seen": true,
	}
	assert_false(
		NyxIntroduction.compute_can_trigger(flags),
		"Must be false when nyx_introduction_seen is already set",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags: Dictionary = {
		"garrick_recruited": true,
		"lyra_fragment_2_collected": true,
	}
	assert_true(
		NyxIntroduction.compute_can_trigger(flags),
		"Must be true when both gate flags set and event not yet seen",
	)


func test_nyx_intro_lines_returns_array() -> void:
	var lines: Array[DialogueLine] = NyxIntroduction.compute_nyx_intro_lines()
	assert_gt(lines.size(), 0, "Should return dialogue lines")


func test_nyx_intro_lines_minimum_count() -> void:
	var lines: Array[DialogueLine] = NyxIntroduction.compute_nyx_intro_lines()
	assert_gte(lines.size(), 20, "Should have at least 20 lines for Scenes 1-3")


func test_first_speaker_is_iris() -> void:
	var lines: Array[DialogueLine] = NyxIntroduction.compute_nyx_intro_lines()
	assert_eq(lines[0].speaker, "Iris", "Scene 1 opens with Iris noting Resonance spike")


func test_nyx_says_loud_line() -> void:
	var lines: Array[DialogueLine] = NyxIntroduction.compute_nyx_intro_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Nyx" and "loud" in line.text:
			found = true
			break
	assert_true(found, "Nyx must say something about the party being 'loud'")


func test_garrick_asks_what_are_you() -> void:
	var lines: Array[DialogueLine] = NyxIntroduction.compute_nyx_intro_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and "What are you" in line.text:
			found = true
			break
	assert_true(found, "Garrick must ask 'What are you?'")


func test_kael_invites_nyx() -> void:
	var lines: Array[DialogueLine] = NyxIntroduction.compute_nyx_intro_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Kael" and "come with us" in line.text:
			found = true
			break
	assert_true(found, "Kael must invite Nyx to come with the party")


func test_nyx_wanting_things_line() -> void:
	var lines: Array[DialogueLine] = NyxIntroduction.compute_nyx_intro_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Nyx" and "want" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Nyx must express wanting things (new organ metaphor)")
