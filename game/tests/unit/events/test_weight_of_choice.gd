# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Chapter 16 "The Weight of Choice" event:
## Post-siege character moments — breathing chapter.
## 6 scenes.


# --- Gate ---


func test_can_trigger_requires_siege_survived() -> void:
	var flags := {}
	assert_false(
		WeightOfChoice.compute_can_trigger(flags),
		"Should not trigger without siege_survived",
	)


func test_can_trigger_true_when_siege_survived() -> void:
	var flags := {"siege_survived": true}
	assert_true(
		WeightOfChoice.compute_can_trigger(flags),
		"Should trigger when siege_survived is set",
	)


func test_can_trigger_false_when_already_done() -> void:
	var flags := {
		"siege_survived": true,
		"weight_chosen": true,
	}
	assert_false(
		WeightOfChoice.compute_can_trigger(flags),
		"Should not trigger if weight_chosen already set",
	)


# --- Scene 1: Recovery ---


func test_recovery_lines_not_empty() -> void:
	var lines := WeightOfChoice.compute_recovery_lines()
	assert_gt(lines.size(), 0, "Scene 1 should have lines")


func test_recovery_includes_rebuilding() -> void:
	var found := false
	for line in WeightOfChoice.compute_recovery_lines():
		if "rebuild" in line.text.to_lower() or "reconstruction" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Recovery should mention rebuilding")


# --- Scene 2: Iris's Silence ---


func test_iris_lines_not_empty() -> void:
	var lines := WeightOfChoice.compute_iris_lines()
	assert_gt(lines.size(), 0, "Scene 2 should have lines")


func test_iris_includes_dane() -> void:
	var found := false
	for line in WeightOfChoice.compute_iris_lines():
		if "Dane" in line.text:
			found = true
			break
	assert_true(found, "Iris scene should mention Dane")


# --- Scene 3: The Book of Names ---


func test_names_lines_not_empty() -> void:
	var lines := WeightOfChoice.compute_names_lines()
	assert_gt(lines.size(), 0, "Scene 3 should have lines")


func test_names_includes_sienna_and_garrick() -> void:
	var speakers := {}
	for line in WeightOfChoice.compute_names_lines():
		speakers[line.speaker] = true
	assert_true(
		speakers.has("Sienna") and speakers.has("Garrick"),
		"Names scene should have both Sienna and Garrick",
	)


# --- Scene 4: What Nyx Learned ---


func test_nyx_lines_not_empty() -> void:
	var lines := WeightOfChoice.compute_nyx_lines()
	assert_gt(lines.size(), 0, "Scene 4 should have lines")


func test_nyx_includes_soup() -> void:
	var found := false
	for line in WeightOfChoice.compute_nyx_lines():
		if "soup" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Nyx scene should mention soup")


# --- Scene 5: Cipher Can't Sleep ---


func test_cipher_lines_not_empty() -> void:
	var lines := WeightOfChoice.compute_cipher_lines()
	assert_gt(lines.size(), 0, "Scene 5 should have lines")


func test_cipher_includes_lyra() -> void:
	var found := false
	for line in WeightOfChoice.compute_cipher_lines():
		if line.speaker == "Lyra":
			found = true
			break
	assert_true(found, "Cipher scene should include Lyra")


# --- Scene 6: Departure ---


func test_departure_lines_not_empty() -> void:
	var lines := WeightOfChoice.compute_departure_lines()
	assert_gt(lines.size(), 0, "Scene 6 should have lines")


func test_departure_includes_kamara() -> void:
	var found := false
	for line in WeightOfChoice.compute_departure_lines():
		if line.speaker == "Kamara":
			found = true
			break
	assert_true(found, "Departure should include Elder Kamara")


# --- Cross-scene ---


func test_total_line_count() -> void:
	var total := (
		WeightOfChoice.compute_recovery_lines().size()
		+ WeightOfChoice.compute_iris_lines().size()
		+ WeightOfChoice.compute_names_lines().size()
		+ WeightOfChoice.compute_nyx_lines().size()
		+ WeightOfChoice.compute_cipher_lines().size()
		+ WeightOfChoice.compute_departure_lines().size()
	)
	assert_gte(total, 50, "Should have 50+ total lines")


func test_all_speakers_valid() -> void:
	var valid := [
		"Kael", "Lyra", "Iris", "Garrick", "Nyx",
		"Cipher", "Sienna", "Kamara",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(WeightOfChoice.compute_recovery_lines())
	all_lines.append_array(WeightOfChoice.compute_iris_lines())
	all_lines.append_array(WeightOfChoice.compute_names_lines())
	all_lines.append_array(WeightOfChoice.compute_nyx_lines())
	all_lines.append_array(WeightOfChoice.compute_cipher_lines())
	all_lines.append_array(WeightOfChoice.compute_departure_lines())
	for line in all_lines:
		assert_has(valid, line.speaker,
			"Speaker '%s' should be valid" % line.speaker)


func test_flag_constant() -> void:
	assert_eq(
		WeightOfChoice.FLAG_NAME, "weight_chosen",
		"Flag should be weight_chosen",
	)
