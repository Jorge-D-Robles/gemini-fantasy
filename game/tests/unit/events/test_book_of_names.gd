# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Sienna's "Book of Names" character quest:
## 4 stages spanning Acts II-III.
##   Stage 1: The Ledger — Sienna reveals her notebook of 53 victims.
##   Stage 2: Subject 14 — find Marcus Theel, the first subject.
##   Stage 3: The Reversal Protocol — attempt to free battery subjects.
##   Stage 4: The Reckoning — Sienna and Iris confront their guilt.


# --- Flag constant ---


func test_flag_prefix() -> void:
	assert_eq(
		BookOfNames.FLAG_PREFIX,
		"book_of_names_stage_",
		"Flag prefix should be book_of_names_stage_",
	)


# --- Stage 1: The Ledger ---


func test_ledger_lines_not_empty() -> void:
	var lines := BookOfNames.compute_ledger_lines()
	assert_gt(lines.size(), 0, "Stage 1 should have lines")


func test_ledger_includes_sienna() -> void:
	var found := false
	for line in BookOfNames.compute_ledger_lines():
		if line.speaker == "Sienna":
			found = true
			break
	assert_true(found, "Ledger should include Sienna")


func test_ledger_mentions_names_or_notebook() -> void:
	var found := false
	for line in BookOfNames.compute_ledger_lines():
		var lower := line.text.to_lower()
		if "name" in lower or "notebook" in lower:
			found = true
			break
	assert_true(found, "Ledger should mention names or notebook")


func test_ledger_mentions_fifty_three() -> void:
	var found := false
	for line in BookOfNames.compute_ledger_lines():
		if "fifty-three" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Ledger should mention fifty-three")


# --- Stage 2: Subject 14 ---


func test_subject_lines_not_empty() -> void:
	var lines := BookOfNames.compute_subject_lines()
	assert_gt(lines.size(), 0, "Stage 2 should have lines")


func test_subject_includes_sienna() -> void:
	var found := false
	for line in BookOfNames.compute_subject_lines():
		if line.speaker == "Sienna":
			found = true
			break
	assert_true(found, "Subject scene should include Sienna")


func test_subject_includes_calloway() -> void:
	var found := false
	for line in BookOfNames.compute_subject_lines():
		if line.speaker == "Calloway":
			found = true
			break
	assert_true(found, "Subject scene should include Calloway")


func test_subject_mentions_marcus() -> void:
	var found := false
	for line in BookOfNames.compute_subject_lines():
		if "marcus" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Subject scene should mention Marcus")


# --- Stage 3: The Reversal Protocol ---


func test_reversal_lines_not_empty() -> void:
	var lines := BookOfNames.compute_reversal_lines()
	assert_gt(lines.size(), 0, "Stage 3 should have lines")


func test_reversal_includes_sienna() -> void:
	var found := false
	for line in BookOfNames.compute_reversal_lines():
		if line.speaker == "Sienna":
			found = true
			break
	assert_true(found, "Reversal should include Sienna")


func test_reversal_mentions_protocol() -> void:
	var found := false
	for line in BookOfNames.compute_reversal_lines():
		var lower := line.text.to_lower()
		if "protocol" in lower or "reversal" in lower:
			found = true
			break
	assert_true(found, "Reversal should mention protocol")


func test_reversal_includes_iris() -> void:
	var found := false
	for line in BookOfNames.compute_reversal_lines():
		if line.speaker == "Iris":
			found = true
			break
	assert_true(found, "Reversal should include Iris")


# --- Stage 4: The Reckoning ---


func test_reckoning_lines_not_empty() -> void:
	var lines := BookOfNames.compute_reckoning_lines()
	assert_gt(lines.size(), 0, "Stage 4 should have lines")


func test_reckoning_includes_iris() -> void:
	var found := false
	for line in BookOfNames.compute_reckoning_lines():
		if line.speaker == "Iris":
			found = true
			break
	assert_true(found, "Reckoning should include Iris")


func test_reckoning_includes_sienna() -> void:
	var found := false
	for line in BookOfNames.compute_reckoning_lines():
		if line.speaker == "Sienna":
			found = true
			break
	assert_true(found, "Reckoning should include Sienna")


func test_reckoning_mentions_guilt_or_forgive() -> void:
	var found := false
	for line in BookOfNames.compute_reckoning_lines():
		var lower := line.text.to_lower()
		if "guilt" in lower or "forgive" in lower:
			found = true
			break
	assert_true(found, "Reckoning should mention guilt or forgiveness")


# --- Cross-stage checks ---


func test_total_line_count_minimum() -> void:
	var total := (
		BookOfNames.compute_ledger_lines().size()
		+ BookOfNames.compute_subject_lines().size()
		+ BookOfNames.compute_reversal_lines().size()
		+ BookOfNames.compute_reckoning_lines().size()
	)
	assert_gt(
		total, 40,
		"Total lines across all stages should exceed 40",
	)


func test_all_speakers_valid() -> void:
	var valid_speakers := [
		"Sienna", "Kael", "Iris", "Cipher",
		"Calloway",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(BookOfNames.compute_ledger_lines())
	all_lines.append_array(BookOfNames.compute_subject_lines())
	all_lines.append_array(
		BookOfNames.compute_reversal_lines(),
	)
	all_lines.append_array(
		BookOfNames.compute_reckoning_lines(),
	)
	for line in all_lines:
		assert_has(
			valid_speakers, line.speaker,
			"Speaker '%s' should be valid" % line.speaker,
		)


func test_stage_gating_stage_1_available() -> void:
	assert_true(
		BookOfNames.compute_can_trigger_stage(1, {}),
		"Stage 1 has no prerequisites",
	)


func test_stage_gating_requires_previous() -> void:
	assert_false(
		BookOfNames.compute_can_trigger_stage(2, {}),
		"Stage 2 requires stage 1 complete",
	)
	assert_true(
		BookOfNames.compute_can_trigger_stage(
			2, {"book_of_names_stage_1": true},
		),
		"Stage 2 unlocked after stage 1",
	)


func test_stage_gating_prevents_replay() -> void:
	assert_false(
		BookOfNames.compute_can_trigger_stage(
			1, {"book_of_names_stage_1": true},
		),
		"Completed stage should not re-trigger",
	)


func test_stage_4_requires_stage_3() -> void:
	var flags := {
		"book_of_names_stage_1": true,
		"book_of_names_stage_2": true,
		"book_of_names_stage_3": true,
	}
	assert_true(
		BookOfNames.compute_can_trigger_stage(4, flags),
		"Stage 4 should unlock after stages 1-3",
	)
