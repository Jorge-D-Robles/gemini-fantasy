# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Chapter 13 "Sister's Shadow" event:
## Party infiltrates Station Theta, meets Sienna Vex,
## witnesses Resonance battery horrors. Sienna defects.
## 8 scenes (7 + camp).


# --- Gate ---


func test_can_trigger_requires_cipher_recruited() -> void:
	var flags := {}
	assert_false(
		SistersShadow.compute_can_trigger(flags),
		"Should not trigger without cipher_recruited",
	)


func test_can_trigger_true_when_cipher_recruited() -> void:
	var flags := {"cipher_recruited": true}
	assert_true(
		SistersShadow.compute_can_trigger(flags),
		"Should trigger when cipher_recruited is set",
	)


func test_can_trigger_false_when_already_done() -> void:
	var flags := {
		"cipher_recruited": true,
		"sienna_defected": true,
	}
	assert_false(
		SistersShadow.compute_can_trigger(flags),
		"Should not trigger if sienna_defected already set",
	)


# --- Scene 1: The Signal ---


func test_signal_lines_not_empty() -> void:
	var lines := SistersShadow.compute_signal_lines()
	assert_gt(lines.size(), 0, "Scene 1 should have lines")


func test_signal_includes_protocol_nine() -> void:
	var found := false
	for line in SistersShadow.compute_signal_lines():
		if "Protocol Nine" in line.text:
			found = true
			break
	assert_true(found, "Signal should mention Protocol Nine")


# --- Scene 2: Station Theta ---


func test_approach_lines_not_empty() -> void:
	var lines := SistersShadow.compute_approach_lines()
	assert_gt(lines.size(), 0, "Scene 2 should have lines")


func test_approach_includes_cipher_hack() -> void:
	var found := false
	for line in SistersShadow.compute_approach_lines():
		if line.speaker == "Cipher" and "four seconds" in line.text:
			found = true
			break
	assert_true(found, "Cipher should mention four seconds")


# --- Scene 3: What They Built Here ---


func test_admin_lines_not_empty() -> void:
	var lines := SistersShadow.compute_admin_lines()
	assert_gt(lines.size(), 0, "Scene 3 should have lines")


func test_admin_includes_subject_files() -> void:
	var found := false
	for line in SistersShadow.compute_admin_lines():
		if "subjects" in line.text or "personnel files" in line.text:
			found = true
			break
	assert_true(found, "Admin should mention test subjects")


# --- Scene 4: The Containment Wing ---


func test_containment_lines_not_empty() -> void:
	var lines := SistersShadow.compute_containment_lines()
	assert_gt(lines.size(), 0, "Scene 4 should have lines")


func test_containment_includes_iris_confession() -> void:
	var found := false
	for line in SistersShadow.compute_containment_lines():
		if line.speaker == "Iris" and "transported" in line.text:
			found = true
			break
	assert_true(
		found, "Iris should confess about transporting subjects",
	)


# --- Scene 5: Sienna ---


func test_sienna_lines_not_empty() -> void:
	var lines := SistersShadow.compute_sienna_lines()
	assert_gt(lines.size(), 0, "Scene 5 should have lines")


func test_sienna_includes_self_condemnation() -> void:
	var found := false
	for line in SistersShadow.compute_sienna_lines():
		if line.speaker == "Sienna" and "not a good person" in line.text:
			found = true
			break
	assert_true(
		found, "Sienna should condemn herself",
	)


# --- Scene 6: The Escape ---


func test_escape_lines_not_empty() -> void:
	var lines := SistersShadow.compute_escape_lines()
	assert_gt(lines.size(), 0, "Scene 6 should have lines")


# --- Scene 7: Outside ---


func test_outside_lines_not_empty() -> void:
	var lines := SistersShadow.compute_outside_lines()
	assert_gt(lines.size(), 0, "Scene 7 should have lines")


func test_outside_includes_cage_data() -> void:
	var found := false
	for line in SistersShadow.compute_outside_lines():
		if "Cage" in line.text and "schematics" in line.text:
			found = true
			break
	assert_true(
		found, "Outside should mention Cage schematics",
	)


# --- Camp: The Space Between Sisters ---


func test_camp_lines_not_empty() -> void:
	var lines := SistersShadow.compute_camp_lines()
	assert_gt(lines.size(), 0, "Camp scene should have lines")


func test_camp_includes_nyx_healing() -> void:
	var found := false
	for line in SistersShadow.compute_camp_lines():
		if line.speaker == "Nyx" and "quiet place" in line.text:
			found = true
			break
	assert_true(
		found, "Nyx should help Sienna find the quiet place",
	)


# --- Cross-scene ---


func test_total_line_count() -> void:
	var total := (
		SistersShadow.compute_signal_lines().size()
		+ SistersShadow.compute_approach_lines().size()
		+ SistersShadow.compute_admin_lines().size()
		+ SistersShadow.compute_containment_lines().size()
		+ SistersShadow.compute_sienna_lines().size()
		+ SistersShadow.compute_escape_lines().size()
		+ SistersShadow.compute_outside_lines().size()
		+ SistersShadow.compute_camp_lines().size()
	)
	assert_gte(total, 70, "Should have 70+ total lines")


func test_all_speakers_valid() -> void:
	var valid := [
		"Kael", "Lyra", "Iris", "Garrick", "Nyx",
		"Cipher", "Sienna",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(SistersShadow.compute_signal_lines())
	all_lines.append_array(SistersShadow.compute_approach_lines())
	all_lines.append_array(SistersShadow.compute_admin_lines())
	all_lines.append_array(
		SistersShadow.compute_containment_lines()
	)
	all_lines.append_array(SistersShadow.compute_sienna_lines())
	all_lines.append_array(SistersShadow.compute_escape_lines())
	all_lines.append_array(SistersShadow.compute_outside_lines())
	all_lines.append_array(SistersShadow.compute_camp_lines())
	for line in all_lines:
		assert_has(valid, line.speaker,
			"Speaker '%s' should be valid" % line.speaker)


func test_flag_constant() -> void:
	assert_eq(
		SistersShadow.FLAG_NAME, "sienna_defected",
		"Flag should be sienna_defected",
	)
