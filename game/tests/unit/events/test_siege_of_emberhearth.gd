# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Chapter 15 "Siege of Emberhearth" event:
## Major battle sequence — Shepherd army besieges Emberhearth.
## 6 scenes (5 + camp).


# --- Gate ---


func test_can_trigger_requires_ash_found() -> void:
	var flags := {}
	assert_false(
		SiegeOfEmberhearth.compute_can_trigger(flags),
		"Should not trigger without ash_found",
	)


func test_can_trigger_true_when_ash_found() -> void:
	var flags := {"ash_found": true}
	assert_true(
		SiegeOfEmberhearth.compute_can_trigger(flags),
		"Should trigger when ash_found is set",
	)


func test_can_trigger_false_when_already_done() -> void:
	var flags := {
		"ash_found": true,
		"siege_survived": true,
	}
	assert_false(
		SiegeOfEmberhearth.compute_can_trigger(flags),
		"Should not trigger if siege_survived already set",
	)


# --- Scene 1: Dawn ---


func test_dawn_lines_not_empty() -> void:
	var lines := SiegeOfEmberhearth.compute_dawn_lines()
	assert_gt(lines.size(), 0, "Scene 1 should have lines")


func test_dawn_includes_cannon_range() -> void:
	var found := false
	for line in SiegeOfEmberhearth.compute_dawn_lines():
		if "cannon" in line.text.to_lower() or "range" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Dawn should mention cannon range")


# --- Scene 2: Parley ---


func test_parley_lines_not_empty() -> void:
	var lines := SiegeOfEmberhearth.compute_parley_lines()
	assert_gt(lines.size(), 0, "Scene 2 should have lines")


func test_parley_includes_hale() -> void:
	var found := false
	for line in SiegeOfEmberhearth.compute_parley_lines():
		if line.speaker == "Hale":
			found = true
			break
	assert_true(found, "Parley should include Hale as speaker")


# --- Scene 3: The Siege ---


func test_siege_lines_not_empty() -> void:
	var lines := SiegeOfEmberhearth.compute_siege_lines()
	assert_gt(lines.size(), 0, "Scene 3 should have lines")


func test_siege_includes_cannon_fire() -> void:
	var found := false
	for line in SiegeOfEmberhearth.compute_siege_lines():
		if "cannon" in line.text.to_lower() or "purification" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Siege should mention cannon or purification")


# --- Scene 4: The Turn ---


func test_turn_lines_not_empty() -> void:
	var lines := SiegeOfEmberhearth.compute_turn_lines()
	assert_gt(lines.size(), 0, "Scene 4 should have lines")


func test_turn_includes_hale_negotiation() -> void:
	var found := false
	for line in SiegeOfEmberhearth.compute_turn_lines():
		if line.speaker == "Hale":
			found = true
			break
	assert_true(found, "Turn should include Hale negotiating")


# --- Scene 5: After ---


func test_after_lines_not_empty() -> void:
	var lines := SiegeOfEmberhearth.compute_after_lines()
	assert_gt(lines.size(), 0, "Scene 5 should have lines")


func test_after_includes_nyx_first_kill() -> void:
	var found := false
	for line in SiegeOfEmberhearth.compute_after_lines():
		if line.speaker == "Nyx" and "killed" in line.text:
			found = true
			break
	assert_true(found, "After should include Nyx's first kill")


# --- Camp: What the Shepherds Said ---


func test_camp_lines_not_empty() -> void:
	var lines := SiegeOfEmberhearth.compute_camp_lines()
	assert_gt(lines.size(), 0, "Camp scene should have lines")


func test_camp_includes_hollows_plan() -> void:
	var found := false
	for line in SiegeOfEmberhearth.compute_camp_lines():
		if "Hollows" in line.text:
			found = true
			break
	assert_true(found, "Camp should mention the Hollows")


# --- Cross-scene ---


func test_total_line_count() -> void:
	var total := (
		SiegeOfEmberhearth.compute_dawn_lines().size()
		+ SiegeOfEmberhearth.compute_parley_lines().size()
		+ SiegeOfEmberhearth.compute_siege_lines().size()
		+ SiegeOfEmberhearth.compute_turn_lines().size()
		+ SiegeOfEmberhearth.compute_after_lines().size()
		+ SiegeOfEmberhearth.compute_camp_lines().size()
	)
	assert_gte(total, 60, "Should have 60+ total lines")


func test_all_speakers_valid() -> void:
	var valid := [
		"Kael", "Lyra", "Iris", "Garrick", "Nyx",
		"Cipher", "Sienna", "Hale", "Shepherd Soldier",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(SiegeOfEmberhearth.compute_dawn_lines())
	all_lines.append_array(SiegeOfEmberhearth.compute_parley_lines())
	all_lines.append_array(SiegeOfEmberhearth.compute_siege_lines())
	all_lines.append_array(SiegeOfEmberhearth.compute_turn_lines())
	all_lines.append_array(SiegeOfEmberhearth.compute_after_lines())
	all_lines.append_array(SiegeOfEmberhearth.compute_camp_lines())
	for line in all_lines:
		assert_has(valid, line.speaker,
			"Speaker '%s' should be valid" % line.speaker)


func test_flag_constant() -> void:
	assert_eq(
		SiegeOfEmberhearth.FLAG_NAME, "siege_survived",
		"Flag should be siege_survived",
	)
