extends GutTest

## Tests for Captured.compute_can_trigger() and dialogue line factories.


func test_compute_can_trigger_false_without_lyras_truth() -> void:
	var flags := {"kael_anchor_revealed": false}
	assert_false(
		Captured.compute_can_trigger(flags),
		"Must need lyras_truth_seen",
	)


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags := {"lyras_truth_seen": true, "kael_anchor_revealed": true}
	assert_false(
		Captured.compute_can_trigger(flags),
		"Must not re-trigger when kael_anchor_revealed is set",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags := {"lyras_truth_seen": true, "kael_anchor_revealed": false}
	assert_true(
		Captured.compute_can_trigger(flags),
		"Must trigger when lyras_truth_seen and NOT kael_anchor_revealed",
	)


func test_compute_director_lines_returns_nonempty() -> void:
	var lines := Captured.compute_director_lines()
	assert_gt(lines.size(), 0, "Director scene must have dialogue lines")


func test_director_scene_includes_resonance_anchor_revelation() -> void:
	var lines := Captured.compute_director_lines()
	var has_anchor: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("Resonance Anchor") or line.text.contains("Resonance Anchors"):
			has_anchor = true
			break
	assert_true(has_anchor, "Director scene must reveal the Resonance Anchor concept")


func test_director_scene_has_kael_refusal() -> void:
	var lines := Captured.compute_director_lines()
	var has_refusal: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Kael" and line.text.begins_with("No."):
			has_refusal = true
			break
	assert_true(has_refusal, "Kael must refuse Vex's offer in the director scene")


func test_compute_escape_lines_returns_nonempty() -> void:
	var lines := Captured.compute_escape_lines()
	assert_gt(lines.size(), 0, "Escape scene must have dialogue lines")


func test_escape_scene_includes_convergence_epitaph() -> void:
	var lines := Captured.compute_escape_lines()
	var has_epitaph: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("We were almost something beautiful"):
			has_epitaph = true
			break
	assert_true(has_epitaph, "Escape scene must include the Convergence's final words")


func test_flag_name_is_correct() -> void:
	assert_eq(Captured.FLAG_NAME, "kael_anchor_revealed", "FLAG_NAME must match the flag string")
