# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Chapter 11 "Rogue" event:
## Party goes rogue after escape from Initiative facility.
## 7 scenes covering shell-shock through fragile resolve.


# --- Gate ---


func test_can_trigger_requires_anchor_revealed() -> void:
	var flags := {}
	assert_false(
		Rogue.compute_can_trigger(flags),
		"Should not trigger without kael_anchor_revealed",
	)


func test_can_trigger_true_when_anchor_revealed() -> void:
	var flags := {"kael_anchor_revealed": true}
	assert_true(
		Rogue.compute_can_trigger(flags),
		"Should trigger when kael_anchor_revealed is set",
	)


func test_can_trigger_false_when_already_decided() -> void:
	var flags := {
		"kael_anchor_revealed": true,
		"rogue_decided": true,
	}
	assert_false(
		Rogue.compute_can_trigger(flags),
		"Should not trigger if rogue_decided already set",
	)


# --- Scene 1: What We Carried Out ---


func test_silence_lines_not_empty() -> void:
	var lines := Rogue.compute_silence_lines()
	assert_gt(lines.size(), 0, "Scene 1 should have lines")


func test_silence_includes_nyx_smoke() -> void:
	var found := false
	for line in Rogue.compute_silence_lines():
		if line.speaker == "Nyx" and "smell" in line.text:
			found = true
			break
	assert_true(found, "Nyx should ask about the smoke smell")


# --- Scene 2: What We're Running From ---


func test_dawn_lines_not_empty() -> void:
	var lines := Rogue.compute_dawn_lines()
	assert_gt(lines.size(), 0, "Scene 2 should have lines")


func test_dawn_includes_terrible_plan() -> void:
	var found := false
	for line in Rogue.compute_dawn_lines():
		if line.speaker == "Iris" and "terrible plan" in line.text:
			found = true
			break
	assert_true(found, "Iris should say 'terrible plan'")


# --- Scene 3: The Waystation ---


func test_waystation_lines_not_empty() -> void:
	var lines := Rogue.compute_waystation_lines()
	assert_gt(lines.size(), 0, "Scene 3 should have lines")


func test_waystation_includes_soldering_pick() -> void:
	var found := false
	for line in Rogue.compute_waystation_lines():
		if "soldering" in line.text:
			found = true
			break
	assert_true(found, "Waystation should mention soldering pick")


# --- Scene 4: The Border ---


func test_border_lines_not_empty() -> void:
	var lines := Rogue.compute_border_lines()
	assert_gt(lines.size(), 0, "Scene 4 should have lines")


func test_border_includes_gearhaven() -> void:
	var found := false
	for line in Rogue.compute_border_lines():
		if "Gearhaven" in line.text:
			found = true
			break
	assert_true(found, "Border scene should mention Gearhaven")


# --- Camp: What Nobody Asked ---


func test_camp_lines_not_empty() -> void:
	var lines := Rogue.compute_camp_lines()
	assert_gt(lines.size(), 0, "Camp scene should have lines")


func test_camp_includes_nyx_lyra_bond() -> void:
	var found := false
	for line in Rogue.compute_camp_lines():
		if line.speaker == "Nyx" and "hold your pieces" in line.text:
			found = true
			break
	assert_true(
		found, "Nyx should offer to hold Lyra's pieces",
	)


# --- Scene 5: Ghost Protocol ---


func test_harbor_lines_not_empty() -> void:
	var lines := Rogue.compute_harbor_lines()
	assert_gt(lines.size(), 0, "Scene 5 should have lines")


func test_harbor_includes_zen() -> void:
	var found := false
	for line in Rogue.compute_harbor_lines():
		if line.speaker == "Zen":
			found = true
			break
	assert_true(found, "Harbor scene should include Zen")


# --- Scene 6: The Weight of Names ---


func test_planning_lines_not_empty() -> void:
	var lines := Rogue.compute_planning_lines()
	assert_gt(lines.size(), 0, "Scene 6 should have lines")


func test_planning_includes_broken_clock() -> void:
	var found := false
	for line in Rogue.compute_planning_lines():
		if "Broken Clock" in line.text:
			found = true
			break
	assert_true(
		found, "Planning should mention The Broken Clock bar",
	)


# --- Cross-scene ---


func test_total_line_count() -> void:
	var total := (
		Rogue.compute_silence_lines().size()
		+ Rogue.compute_dawn_lines().size()
		+ Rogue.compute_waystation_lines().size()
		+ Rogue.compute_border_lines().size()
		+ Rogue.compute_camp_lines().size()
		+ Rogue.compute_harbor_lines().size()
		+ Rogue.compute_planning_lines().size()
	)
	assert_gte(total, 50, "Should have 50+ total lines")


func test_all_speakers_valid() -> void:
	var valid := [
		"Kael", "Lyra", "Iris", "Garrick", "Nyx",
		"Zen",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(Rogue.compute_silence_lines())
	all_lines.append_array(Rogue.compute_dawn_lines())
	all_lines.append_array(Rogue.compute_waystation_lines())
	all_lines.append_array(Rogue.compute_border_lines())
	all_lines.append_array(Rogue.compute_camp_lines())
	all_lines.append_array(Rogue.compute_harbor_lines())
	all_lines.append_array(Rogue.compute_planning_lines())
	for line in all_lines:
		assert_has(valid, line.speaker,
			"Speaker '%s' should be valid" % line.speaker)


func test_flag_constant() -> void:
	assert_eq(
		Rogue.FLAG_NAME, "rogue_decided",
		"Flag should be rogue_decided",
	)
