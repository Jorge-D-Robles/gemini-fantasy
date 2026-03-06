# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Captured event — Chapter 10, Act I ending.
## 8 scenes: running, road, ambush, director, cells, breakout, escape, camp.
## Gate: lyras_truth_seen AND NOT kael_anchor_revealed.

var _event: Node


func before_each() -> void:
	_event = load("res://events/captured.gd").new()
	add_child_autofree(_event)


# --- compute_can_trigger ---


func test_can_trigger_false_without_lyras_truth() -> void:
	var flags: Dictionary = {}
	assert_false(
		Captured.compute_can_trigger(flags),
		"Must be false when lyras_truth_seen not set",
	)


func test_can_trigger_false_when_already_revealed() -> void:
	var flags: Dictionary = {
		"lyras_truth_seen": true,
		"kael_anchor_revealed": true,
	}
	assert_false(
		Captured.compute_can_trigger(flags),
		"Must be false when kael_anchor_revealed already set",
	)


func test_can_trigger_true_when_eligible() -> void:
	var flags: Dictionary = {
		"lyras_truth_seen": true,
	}
	assert_true(
		Captured.compute_can_trigger(flags),
		"Must be true when lyras_truth_seen set and not revealed",
	)


# --- Scene 1: Running ---


func test_running_lines_not_empty() -> void:
	var lines := Captured.compute_running_lines()
	assert_gt(lines.size(), 0, "Running lines must not be empty")


func test_running_lines_start_with_garrick() -> void:
	var lines := Captured.compute_running_lines()
	assert_eq(
		lines[0].speaker, "Garrick",
		"Scene opens with Garrick's urgent question",
	)


# --- Scene 2: Southern Road ---


func test_road_lines_not_empty() -> void:
	var lines := Captured.compute_road_lines()
	assert_gt(lines.size(), 0, "Road lines must not be empty")


func test_road_lines_mention_resonance_net() -> void:
	var lines := Captured.compute_road_lines()
	var found := false
	for line: DialogueLine in lines:
		if "net" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Road scene should mention the Resonance net")


# --- Scene 3: Ambush ---


func test_ambush_lines_not_empty() -> void:
	var lines := Captured.compute_ambush_lines()
	assert_gt(lines.size(), 0, "Ambush lines must not be empty")


func test_ambush_features_vael() -> void:
	var lines := Captured.compute_ambush_lines()
	var has_vael := false
	for line: DialogueLine in lines:
		if "Vael" in line.speaker:
			has_vael = true
			break
	assert_true(has_vael, "Ambush scene must feature Commander Vael")


# --- Scene 4: The Director ---


func test_director_lines_not_empty() -> void:
	var lines := Captured.compute_director_lines()
	assert_gt(lines.size(), 0, "Director lines must not be empty")


func test_director_lines_mention_anchor() -> void:
	var lines := Captured.compute_director_lines()
	var found := false
	for line: DialogueLine in lines:
		if "anchor" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Director scene must reveal Resonance Anchor")


func test_director_has_kael_refusal() -> void:
	var lines := Captured.compute_director_lines()
	var has_refusal := false
	for line: DialogueLine in lines:
		if line.speaker == "Kael" and "no" in line.text.to_lower().left(5):
			has_refusal = true
			break
	assert_true(has_refusal, "Kael must refuse Vex's offer")


# --- Scene 5: The Cells ---


func test_cells_lines_not_empty() -> void:
	var lines := Captured.compute_cells_lines()
	assert_gt(lines.size(), 0, "Cells lines must not be empty")


func test_cells_feature_through_wall_dialogue() -> void:
	var lines := Captured.compute_cells_lines()
	var found := false
	for line: DialogueLine in lines:
		if "wall" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Cells scene should have through-wall dialogue")


# --- Scene 6: Breaking Out ---


func test_breakout_lines_not_empty() -> void:
	var lines := Captured.compute_breakout_lines()
	assert_gt(lines.size(), 0, "Breakout lines must not be empty")


func test_breakout_features_iris() -> void:
	var lines := Captured.compute_breakout_lines()
	var has_iris := false
	for line: DialogueLine in lines:
		if line.speaker == "Iris":
			has_iris = true
			break
	assert_true(has_iris, "Breakout scene must feature Iris")


# --- Scene 7: Open Sky ---


func test_escape_lines_not_empty() -> void:
	var lines := Captured.compute_escape_lines()
	assert_gt(lines.size(), 0, "Escape lines must not be empty")


func test_escape_features_lyra_fragment() -> void:
	var lines := Captured.compute_escape_lines()
	var has_lyra := false
	for line: DialogueLine in lines:
		if line.speaker == "Lyra":
			has_lyra = true
			break
	assert_true(has_lyra, "Escape scene must include Lyra's fragment")


# --- Camp: The Road South ---


func test_camp_lines_not_empty() -> void:
	var lines := Captured.compute_camp_lines()
	assert_gt(lines.size(), 0, "Camp lines must not be empty")


func test_camp_includes_convergence_epitaph() -> void:
	var lines := Captured.compute_camp_lines()
	var found := false
	for line: DialogueLine in lines:
		if "almost something beautiful" in line.text:
			found = true
			break
	assert_true(
		found,
		"Camp scene must include the Convergence epitaph",
	)


func test_camp_features_garrick_mara_memory() -> void:
	var lines := Captured.compute_camp_lines()
	var found := false
	for line: DialogueLine in lines:
		if "mara" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Camp scene should reference Garrick's daughter")


# --- Cross-scene checks ---


func test_total_line_count() -> void:
	var total: int = (
		Captured.compute_running_lines().size()
		+ Captured.compute_road_lines().size()
		+ Captured.compute_ambush_lines().size()
		+ Captured.compute_director_lines().size()
		+ Captured.compute_cells_lines().size()
		+ Captured.compute_breakout_lines().size()
		+ Captured.compute_escape_lines().size()
		+ Captured.compute_camp_lines().size()
	)
	assert_gte(total, 70, "Full event should have 70+ dialogue lines")


func test_all_speakers_valid() -> void:
	var valid_speakers: Array[String] = [
		"Kael", "Iris", "Garrick", "Nyx", "Lyra",
		"Commander Vael", "Vael",
		"Director Vex Thornwright", "Vex",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(Captured.compute_running_lines())
	all_lines.append_array(Captured.compute_road_lines())
	all_lines.append_array(Captured.compute_ambush_lines())
	all_lines.append_array(Captured.compute_director_lines())
	all_lines.append_array(Captured.compute_cells_lines())
	all_lines.append_array(Captured.compute_breakout_lines())
	all_lines.append_array(Captured.compute_escape_lines())
	all_lines.append_array(Captured.compute_camp_lines())
	for line: DialogueLine in all_lines:
		assert_true(
			line.speaker in valid_speakers,
			"Speaker '%s' must be in valid list" % line.speaker,
		)


func test_flag_name_constant() -> void:
	assert_eq(
		Captured.FLAG_NAME, "kael_anchor_revealed",
		"FLAG_NAME must be kael_anchor_revealed",
	)
