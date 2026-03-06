# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Chapter 14 "Fire and Ash" event:
## Party reaches Emberhearth, finds Ash, Shepherd army arrives.
## 8 scenes (7 + camp).


# --- Gate ---


func test_can_trigger_requires_sienna_defected() -> void:
	var flags := {}
	assert_false(
		FireAndAsh.compute_can_trigger(flags),
		"Should not trigger without sienna_defected",
	)


func test_can_trigger_true_when_sienna_defected() -> void:
	var flags := {"sienna_defected": true}
	assert_true(
		FireAndAsh.compute_can_trigger(flags),
		"Should trigger when sienna_defected is set",
	)


func test_can_trigger_false_when_already_done() -> void:
	var flags := {
		"sienna_defected": true,
		"ash_found": true,
	}
	assert_false(
		FireAndAsh.compute_can_trigger(flags),
		"Should not trigger if ash_found already set",
	)


# --- Scene 1: Homecoming ---


func test_homecoming_lines_not_empty() -> void:
	var lines := FireAndAsh.compute_homecoming_lines()
	assert_gt(lines.size(), 0, "Scene 1 should have lines")


func test_homecoming_includes_three_burns() -> void:
	var found := false
	for line in FireAndAsh.compute_homecoming_lines():
		if "burned" in line.text or "shrine" in line.text:
			found = true
			break
	assert_true(
		found, "Garrick should mention burning the shrine",
	)


# --- Scene 2: Through the Gates ---


func test_gates_lines_not_empty() -> void:
	var lines := FireAndAsh.compute_gates_lines()
	assert_gt(lines.size(), 0, "Scene 2 should have lines")


func test_gates_includes_gate_guard() -> void:
	var found := false
	for line in FireAndAsh.compute_gates_lines():
		if line.speaker == "Gate Guard":
			found = true
			break
	assert_true(found, "Gate scene should include Gate Guard")


# --- Scene 3: The Ash Walkers' Fire ---


func test_elders_lines_not_empty() -> void:
	var lines := FireAndAsh.compute_elders_lines()
	assert_gt(lines.size(), 0, "Scene 3 should have lines")


func test_elders_includes_kamara() -> void:
	var found := false
	for line in FireAndAsh.compute_elders_lines():
		if line.speaker == "Kamara":
			found = true
			break
	assert_true(found, "Elders scene should include Kamara")


# --- Scene 4: Ash ---


func test_meeting_lines_not_empty() -> void:
	var lines := FireAndAsh.compute_meeting_lines()
	assert_gt(lines.size(), 0, "Scene 4 should have lines")


func test_meeting_includes_ash_drawing() -> void:
	var found := false
	for line in FireAndAsh.compute_meeting_lines():
		if "drawing" in line.text or "drew" in line.text:
			found = true
			break
	assert_true(found, "Meeting should mention Ash's drawing")


# --- Scene 5: The Warning ---


func test_warning_lines_not_empty() -> void:
	var lines := FireAndAsh.compute_warning_lines()
	assert_gt(lines.size(), 0, "Scene 5 should have lines")


func test_warning_includes_shepherd_army() -> void:
	var found := false
	for line in FireAndAsh.compute_warning_lines():
		if "Shepherd" in line.text and "army" in line.text:
			found = true
			break
	assert_true(found, "Warning should mention Shepherd army")


# --- Scene 6: Two Days ---


func test_preparation_lines_not_empty() -> void:
	var lines := FireAndAsh.compute_preparation_lines()
	assert_gt(lines.size(), 0, "Scene 6 should have lines")


func test_preparation_includes_iris_fortification() -> void:
	var found := false
	for line in FireAndAsh.compute_preparation_lines():
		if line.speaker == "Iris" and "analog" in line.text:
			found = true
			break
	assert_true(
		found, "Iris should mention going analog",
	)


# --- Scene 7: The Horizon ---


func test_horizon_lines_not_empty() -> void:
	var lines := FireAndAsh.compute_horizon_lines()
	assert_gt(lines.size(), 0, "Scene 7 should have lines")


func test_horizon_includes_markus() -> void:
	var found := false
	for line in FireAndAsh.compute_horizon_lines():
		if "Markus" in line.text:
			found = true
			break
	assert_true(
		found, "Horizon should mention Inquisitor Markus",
	)


# --- Camp: What Fire Means ---


func test_camp_lines_not_empty() -> void:
	var lines := FireAndAsh.compute_camp_lines()
	assert_gt(lines.size(), 0, "Camp scene should have lines")


func test_camp_includes_kael_ash_connection() -> void:
	var found := false
	for line in FireAndAsh.compute_camp_lines():
		if line.speaker == "Kael" and "protect" in line.text:
			found = true
			break
	assert_true(
		found, "Kael should promise to protect Ash",
	)


# --- Cross-scene ---


func test_total_line_count() -> void:
	var total := (
		FireAndAsh.compute_homecoming_lines().size()
		+ FireAndAsh.compute_gates_lines().size()
		+ FireAndAsh.compute_elders_lines().size()
		+ FireAndAsh.compute_meeting_lines().size()
		+ FireAndAsh.compute_warning_lines().size()
		+ FireAndAsh.compute_preparation_lines().size()
		+ FireAndAsh.compute_horizon_lines().size()
		+ FireAndAsh.compute_camp_lines().size()
	)
	assert_gte(total, 60, "Should have 60+ total lines")


func test_all_speakers_valid() -> void:
	var valid := [
		"Kael", "Lyra", "Iris", "Garrick", "Nyx",
		"Cipher", "Sienna", "Kamara", "Gate Guard",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(FireAndAsh.compute_homecoming_lines())
	all_lines.append_array(FireAndAsh.compute_gates_lines())
	all_lines.append_array(FireAndAsh.compute_elders_lines())
	all_lines.append_array(FireAndAsh.compute_meeting_lines())
	all_lines.append_array(FireAndAsh.compute_warning_lines())
	all_lines.append_array(
		FireAndAsh.compute_preparation_lines()
	)
	all_lines.append_array(FireAndAsh.compute_horizon_lines())
	all_lines.append_array(FireAndAsh.compute_camp_lines())
	for line in all_lines:
		assert_has(valid, line.speaker,
			"Speaker '%s' should be valid" % line.speaker)


func test_flag_constant() -> void:
	assert_eq(
		FireAndAsh.FLAG_NAME, "ash_found",
		"Flag should be ash_found",
	)
