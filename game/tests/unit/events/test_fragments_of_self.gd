# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Kael's "Fragments of Self" character quest:
## 5 stages spanning Acts I-III.
##   Stage 1: The Locket — discovery of false childhood memory.
##   Stage 2: The Scientist — contradicting pre-Severance memory.
##   Stage 3: The Chorus — all false memories at once, choice moment.
##   Stage 4: What Remains — Garrick fireside conversation.
##   Stage 5: Gallery of Selves — final trial and resolution.


# --- Flag constant ---


func test_flag_name_is_fragments_stage() -> void:
	assert_eq(
		FragmentsOfSelf.FLAG_PREFIX,
		"fragments_stage_",
		"Flag prefix should be fragments_stage_",
	)


# --- Stage 1: The Locket ---


func test_locket_lines_not_empty() -> void:
	var lines := FragmentsOfSelf.compute_locket_lines()
	assert_gt(lines.size(), 0, "Stage 1 should have lines")


func test_locket_includes_kael() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_locket_lines():
		if line.speaker == "Kael":
			found = true
			break
	assert_true(found, "Locket scene should include Kael")


func test_locket_mentions_parents_or_mother() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_locket_lines():
		var lower := line.text.to_lower()
		if "parent" in lower or "mother" in lower or "father" in lower:
			found = true
			break
	assert_true(found, "Locket should reference parents")


func test_locket_mentions_locket() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_locket_lines():
		if "locket" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Locket scene should mention locket")


# --- Stage 2: The Scientist ---


func test_scientist_lines_not_empty() -> void:
	var lines := FragmentsOfSelf.compute_scientist_lines()
	assert_gt(lines.size(), 0, "Stage 2 should have lines")


func test_scientist_includes_kael() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_scientist_lines():
		if line.speaker == "Kael":
			found = true
			break
	assert_true(found, "Scientist scene should include Kael")


func test_scientist_mentions_nexus_or_lab() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_scientist_lines():
		var lower := line.text.to_lower()
		if "nexus" in lower or "lab" in lower or "scientist" in lower:
			found = true
			break
	assert_true(found, "Scientist should reference the lab or Nexus")


# --- Stage 3: The Chorus ---


func test_chorus_lines_not_empty() -> void:
	var lines := FragmentsOfSelf.compute_chorus_lines()
	assert_gt(lines.size(), 0, "Stage 3 should have lines")


func test_chorus_includes_nyx() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_chorus_lines():
		if line.speaker == "Nyx":
			found = true
			break
	assert_true(found, "Chorus scene should include Nyx")


func test_chorus_mentions_singing_or_crystal() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_chorus_lines():
		var lower := line.text.to_lower()
		if "singing" in lower or "crystal" in lower or "song" in lower:
			found = true
			break
	assert_true(found, "Chorus should reference singing or crystal")


func test_chorus_mentions_present_tense() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_chorus_lines():
		if "present tense" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Chorus should reference present tense")


# --- Stage 4: What Remains ---


func test_remains_lines_not_empty() -> void:
	var lines := FragmentsOfSelf.compute_remains_lines()
	assert_gt(lines.size(), 0, "Stage 4 should have lines")


func test_remains_includes_garrick() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_remains_lines():
		if line.speaker == "Garrick":
			found = true
			break
	assert_true(found, "Remains scene should include Garrick")


func test_remains_mentions_wall_or_brick() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_remains_lines():
		var lower := line.text.to_lower()
		if "wall" in lower or "brick" in lower:
			found = true
			break
	assert_true(found, "Remains should reference wall or brick")


# --- Stage 5: Gallery of Selves ---


func test_gallery_lines_not_empty() -> void:
	var lines := FragmentsOfSelf.compute_gallery_lines()
	assert_gt(lines.size(), 0, "Stage 5 should have lines")


func test_gallery_includes_fragment_voice() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_gallery_lines():
		if line.speaker == "The Fragment":
			found = true
			break
	assert_true(found, "Gallery should include The Fragment voice")


func test_gallery_mentions_stay_or_name() -> void:
	var found := false
	for line in FragmentsOfSelf.compute_gallery_lines():
		var lower := line.text.to_lower()
		if "stay" in lower or "name" in lower or "kael" in lower:
			found = true
			break
	assert_true(found, "Gallery should reference staying or the name")


# --- Cross-stage checks ---


func test_total_line_count_minimum() -> void:
	var total := (
		FragmentsOfSelf.compute_locket_lines().size()
		+ FragmentsOfSelf.compute_scientist_lines().size()
		+ FragmentsOfSelf.compute_chorus_lines().size()
		+ FragmentsOfSelf.compute_remains_lines().size()
		+ FragmentsOfSelf.compute_gallery_lines().size()
	)
	assert_gt(total, 40, "Total lines across all stages should exceed 40")


func test_all_speakers_valid() -> void:
	var valid_speakers := [
		"Kael", "Nyx", "Garrick", "Iris", "Lyra",
		"Woman", "Colleague", "The Fragment",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(FragmentsOfSelf.compute_locket_lines())
	all_lines.append_array(FragmentsOfSelf.compute_scientist_lines())
	all_lines.append_array(FragmentsOfSelf.compute_chorus_lines())
	all_lines.append_array(FragmentsOfSelf.compute_remains_lines())
	all_lines.append_array(FragmentsOfSelf.compute_gallery_lines())
	for line in all_lines:
		assert_has(
			valid_speakers, line.speaker,
			"Speaker '%s' should be valid" % line.speaker,
		)


func test_stage_gating_requires_previous() -> void:
	assert_false(
		FragmentsOfSelf.compute_can_trigger_stage(2, {}),
		"Stage 2 requires stage 1 complete",
	)
	assert_true(
		FragmentsOfSelf.compute_can_trigger_stage(
			2, {"fragments_stage_1": true}
		),
		"Stage 2 unlocked after stage 1",
	)


func test_stage_gating_stage_1_always_available() -> void:
	assert_true(
		FragmentsOfSelf.compute_can_trigger_stage(1, {}),
		"Stage 1 has no prerequisites",
	)


func test_stage_gating_prevents_replay() -> void:
	assert_false(
		FragmentsOfSelf.compute_can_trigger_stage(
			1, {"fragments_stage_1": true}
		),
		"Completed stage should not re-trigger",
	)


func test_stage_5_requires_stage_4() -> void:
	var flags := {
		"fragments_stage_1": true,
		"fragments_stage_2": true,
		"fragments_stage_3": true,
		"fragments_stage_4": true,
	}
	assert_true(
		FragmentsOfSelf.compute_can_trigger_stage(5, flags),
		"Stage 5 should unlock after all prior stages",
	)
