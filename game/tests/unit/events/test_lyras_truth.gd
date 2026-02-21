extends GutTest

## Tests for LyrasTruth.compute_can_trigger() and dialogue line factories.


func test_compute_can_trigger_false_without_prismfall_arrived() -> void:
	var flags := {"lyras_truth_seen": false}
	assert_false(
		LyrasTruth.compute_can_trigger(flags),
		"Must need prismfall_arrived",
	)


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags := {"prismfall_arrived": true, "lyras_truth_seen": true}
	assert_false(
		LyrasTruth.compute_can_trigger(flags),
		"Must not re-trigger when lyras_truth_seen is set",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags := {"prismfall_arrived": true, "lyras_truth_seen": false}
	assert_true(
		LyrasTruth.compute_can_trigger(flags),
		"Must trigger when prismfall_arrived and NOT lyras_truth_seen",
	)


func test_compute_scene5_lines_returns_nonempty() -> void:
	var lines := LyrasTruth.compute_scene5_lines()
	assert_gt(lines.size(), 0, "Scene 5 must have dialogue lines")


func test_scene5_includes_eight_hundred_million() -> void:
	var lines := LyrasTruth.compute_scene5_lines()
	var has_count: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("eight hundred million"):
			has_count = true
			break
	assert_true(has_count, "Scene 5 must reference the eight hundred million death toll")


func test_compute_camp_lines_returns_nonempty() -> void:
	var lines := LyrasTruth.compute_camp_lines()
	assert_gt(lines.size(), 0, "Camp scene must have dialogue lines")


func test_camp_includes_nyx_splinter_line() -> void:
	var lines := LyrasTruth.compute_camp_lines()
	var has_nyx: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Nyx" and line.text.contains("Convergence"):
			has_nyx = true
			break
	assert_true(has_nyx, "Camp scene must include Nyx's line about the Convergence")


func test_flag_name_is_correct() -> void:
	assert_eq(LyrasTruth.FLAG_NAME, "lyras_truth_seen", "FLAG_NAME must match the flag string")
