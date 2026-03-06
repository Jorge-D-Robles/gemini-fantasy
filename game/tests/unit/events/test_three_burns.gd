# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Garrick's "Three Burns" character quest:
## 3 stages spanning Acts I-III.
##   Stage 1: The Name on the Wall — memorial wall in Emberhearth.
##   Stage 2: Following Smoke — Ashpyre ruins, three memory fragments.
##   Stage 3: The Echo of Mara — face-to-face with Mara's Echo.


# --- Flag constant ---


func test_flag_prefix() -> void:
	assert_eq(
		ThreeBurns.FLAG_PREFIX,
		"three_burns_stage_",
		"Flag prefix should be three_burns_stage_",
	)


# --- Stage 1: The Name on the Wall ---


func test_wall_lines_not_empty() -> void:
	var lines := ThreeBurns.compute_wall_lines()
	assert_gt(lines.size(), 0, "Stage 1 should have lines")


func test_wall_includes_garrick() -> void:
	var found := false
	for line in ThreeBurns.compute_wall_lines():
		if line.speaker == "Garrick":
			found = true
			break
	assert_true(found, "Wall scene should include Garrick")


func test_wall_mentions_mara() -> void:
	var found := false
	for line in ThreeBurns.compute_wall_lines():
		if "mara" in line.text.to_lower() or "Mara" in line.text:
			found = true
			break
	assert_true(found, "Wall scene should mention Mara")


func test_wall_mentions_daughter() -> void:
	var found := false
	for line in ThreeBurns.compute_wall_lines():
		if "daughter" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Wall scene should mention daughter")


# --- Stage 2: Following Smoke ---


func test_smoke_lines_not_empty() -> void:
	var lines := ThreeBurns.compute_smoke_lines()
	assert_gt(lines.size(), 0, "Stage 2 should have lines")


func test_smoke_includes_garrick() -> void:
	var found := false
	for line in ThreeBurns.compute_smoke_lines():
		if line.speaker == "Garrick":
			found = true
			break
	assert_true(found, "Smoke scene should include Garrick")


func test_smoke_includes_mara() -> void:
	var found := false
	for line in ThreeBurns.compute_smoke_lines():
		if line.speaker == "Mara":
			found = true
			break
	assert_true(found, "Smoke scene should include Mara (fragment)")


func test_smoke_mentions_village_or_burn() -> void:
	var found := false
	for line in ThreeBurns.compute_smoke_lines():
		var lower := line.text.to_lower()
		if "village" in lower or "burn" in lower or "purge" in lower:
			found = true
			break
	assert_true(found, "Smoke should reference village or burning")


# --- Stage 3: The Echo of Mara ---


func test_echo_lines_not_empty() -> void:
	var lines := ThreeBurns.compute_echo_lines()
	assert_gt(lines.size(), 0, "Stage 3 should have lines")


func test_echo_includes_mara() -> void:
	var found := false
	for line in ThreeBurns.compute_echo_lines():
		if line.speaker == "Mara":
			found = true
			break
	assert_true(found, "Echo scene should include Mara")


func test_echo_includes_garrick() -> void:
	var found := false
	for line in ThreeBurns.compute_echo_lines():
		if line.speaker == "Garrick":
			found = true
			break
	assert_true(found, "Echo scene should include Garrick")


func test_echo_mentions_forgive_or_guilt() -> void:
	var found := false
	for line in ThreeBurns.compute_echo_lines():
		var lower := line.text.to_lower()
		if "forgive" in lower or "guilt" in lower:
			found = true
			break
	assert_true(found, "Echo should reference forgiveness or guilt")


func test_echo_mentions_shield() -> void:
	var found := false
	for line in ThreeBurns.compute_echo_lines():
		if "shield" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Echo should reference the shield")


# --- Cross-stage checks ---


func test_total_line_count_minimum() -> void:
	var total := (
		ThreeBurns.compute_wall_lines().size()
		+ ThreeBurns.compute_smoke_lines().size()
		+ ThreeBurns.compute_echo_lines().size()
	)
	assert_gt(total, 30, "Total lines across all stages should exceed 30")


func test_all_speakers_valid() -> void:
	var valid_speakers := [
		"Kael", "Garrick", "Mara", "Elder",
		"Boy", "Garrick's Echo",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(ThreeBurns.compute_wall_lines())
	all_lines.append_array(ThreeBurns.compute_smoke_lines())
	all_lines.append_array(ThreeBurns.compute_echo_lines())
	for line in all_lines:
		assert_has(
			valid_speakers, line.speaker,
			"Speaker '%s' should be valid" % line.speaker,
		)


func test_stage_gating_stage_1_available() -> void:
	assert_true(
		ThreeBurns.compute_can_trigger_stage(1, {}),
		"Stage 1 has no prerequisites",
	)


func test_stage_gating_requires_previous() -> void:
	assert_false(
		ThreeBurns.compute_can_trigger_stage(2, {}),
		"Stage 2 requires stage 1 complete",
	)
	assert_true(
		ThreeBurns.compute_can_trigger_stage(
			2, {"three_burns_stage_1": true}
		),
		"Stage 2 unlocked after stage 1",
	)


func test_stage_gating_prevents_replay() -> void:
	assert_false(
		ThreeBurns.compute_can_trigger_stage(
			1, {"three_burns_stage_1": true}
		),
		"Completed stage should not re-trigger",
	)


func test_stage_3_requires_stage_2() -> void:
	var flags := {
		"three_burns_stage_1": true,
		"three_burns_stage_2": true,
	}
	assert_true(
		ThreeBurns.compute_can_trigger_stage(3, flags),
		"Stage 3 should unlock after stages 1-2",
	)
