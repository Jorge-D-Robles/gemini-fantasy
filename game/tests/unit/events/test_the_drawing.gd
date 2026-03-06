# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Ash's "The Drawing" character quest:
## 4 stages spanning Acts II-III.
##   Stage 1: The Image — Ash draws a pre-Severance facility blueprint.
##   Stage 2: Following the Drawing — discover the Chrysalis facility.
##   Stage 3: What Ash Is — the party processes the revelation.
##   Stage 4: What We Carry — decide how to handle the truth.


# --- Flag constant ---


func test_flag_prefix() -> void:
	assert_eq(
		TheDrawing.FLAG_PREFIX,
		"drawing_stage_",
		"Flag prefix should be drawing_stage_",
	)


# --- Stage 1: The Image ---


func test_image_lines_not_empty() -> void:
	var lines := TheDrawing.compute_image_lines()
	assert_gt(lines.size(), 0, "Stage 1 should have lines")


func test_image_includes_kael() -> void:
	var found := false
	for line in TheDrawing.compute_image_lines():
		if line.speaker == "Kael":
			found = true
			break
	assert_true(found, "Image should include Kael")


func test_image_mentions_drawing() -> void:
	var found := false
	for line in TheDrawing.compute_image_lines():
		var lower := line.text.to_lower()
		if "draw" in lower or "blueprint" in lower:
			found = true
			break
	assert_true(found, "Image should mention drawing or blueprint")


func test_image_includes_sienna() -> void:
	var found := false
	for line in TheDrawing.compute_image_lines():
		if line.speaker == "Sienna":
			found = true
			break
	assert_true(found, "Image should include Sienna")


# --- Stage 2: Following the Drawing ---


func test_chrysalis_lines_not_empty() -> void:
	var lines := TheDrawing.compute_chrysalis_lines()
	assert_gt(lines.size(), 0, "Stage 2 should have lines")


func test_chrysalis_includes_lyra() -> void:
	var found := false
	for line in TheDrawing.compute_chrysalis_lines():
		if line.speaker == "Lyra":
			found = true
			break
	assert_true(found, "Chrysalis should include Lyra")


func test_chrysalis_mentions_nursery() -> void:
	var found := false
	for line in TheDrawing.compute_chrysalis_lines():
		var lower := line.text.to_lower()
		if "nursery" in lower or "chrysalis" in lower:
			found = true
			break
	assert_true(found, "Chrysalis should mention nursery")


func test_chrysalis_includes_kael() -> void:
	var found := false
	for line in TheDrawing.compute_chrysalis_lines():
		if line.speaker == "Kael":
			found = true
			break
	assert_true(found, "Chrysalis should include Kael")


# --- Stage 3: What Ash Is ---


func test_what_ash_is_lines_not_empty() -> void:
	var lines := TheDrawing.compute_what_ash_is_lines()
	assert_gt(lines.size(), 0, "Stage 3 should have lines")


func test_what_ash_is_includes_sienna() -> void:
	var found := false
	for line in TheDrawing.compute_what_ash_is_lines():
		if line.speaker == "Sienna":
			found = true
			break
	assert_true(found, "What Ash Is should include Sienna")


func test_what_ash_is_includes_garrick() -> void:
	var found := false
	for line in TheDrawing.compute_what_ash_is_lines():
		if line.speaker == "Garrick":
			found = true
			break
	assert_true(found, "What Ash Is should include Garrick")


func test_what_ash_is_mentions_seed_or_new() -> void:
	var found := false
	for line in TheDrawing.compute_what_ash_is_lines():
		var lower := line.text.to_lower()
		if "seed" in lower or "new" in lower:
			found = true
			break
	assert_true(found, "Should mention seed or new life")


# --- Stage 4: What We Carry ---


func test_carry_lines_not_empty() -> void:
	var lines := TheDrawing.compute_carry_lines()
	assert_gt(lines.size(), 0, "Stage 4 should have lines")


func test_carry_includes_cipher() -> void:
	var found := false
	for line in TheDrawing.compute_carry_lines():
		if line.speaker == "Cipher":
			found = true
			break
	assert_true(found, "Carry should include Cipher")


func test_carry_includes_lyra() -> void:
	var found := false
	for line in TheDrawing.compute_carry_lines():
		if line.speaker == "Lyra":
			found = true
			break
	assert_true(found, "Carry should include Lyra")


func test_carry_mentions_child_or_protect() -> void:
	var found := false
	for line in TheDrawing.compute_carry_lines():
		var lower := line.text.to_lower()
		if "child" in lower or "protect" in lower:
			found = true
			break
	assert_true(found, "Carry should mention child or protect")


# --- Ash never speaks ---


func test_ash_never_speaks() -> void:
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(TheDrawing.compute_image_lines())
	all_lines.append_array(
		TheDrawing.compute_chrysalis_lines(),
	)
	all_lines.append_array(
		TheDrawing.compute_what_ash_is_lines(),
	)
	all_lines.append_array(TheDrawing.compute_carry_lines())
	for line in all_lines:
		assert_ne(
			line.speaker, "Ash",
			"Ash should never have dialogue lines",
		)


# --- Cross-stage checks ---


func test_total_line_count_minimum() -> void:
	var total := (
		TheDrawing.compute_image_lines().size()
		+ TheDrawing.compute_chrysalis_lines().size()
		+ TheDrawing.compute_what_ash_is_lines().size()
		+ TheDrawing.compute_carry_lines().size()
	)
	assert_gt(
		total, 40,
		"Total lines across all stages should exceed 40",
	)


func test_all_speakers_valid() -> void:
	var valid_speakers := [
		"Kael", "Sienna", "Iris", "Cipher",
		"Lyra", "Garrick", "Nyx",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(TheDrawing.compute_image_lines())
	all_lines.append_array(
		TheDrawing.compute_chrysalis_lines(),
	)
	all_lines.append_array(
		TheDrawing.compute_what_ash_is_lines(),
	)
	all_lines.append_array(TheDrawing.compute_carry_lines())
	for line in all_lines:
		assert_has(
			valid_speakers, line.speaker,
			"Speaker '%s' should be valid" % line.speaker,
		)


func test_stage_gating_stage_1_available() -> void:
	assert_true(
		TheDrawing.compute_can_trigger_stage(1, {}),
		"Stage 1 has no prerequisites",
	)


func test_stage_gating_requires_previous() -> void:
	assert_false(
		TheDrawing.compute_can_trigger_stage(2, {}),
		"Stage 2 requires stage 1 complete",
	)
	assert_true(
		TheDrawing.compute_can_trigger_stage(
			2, {"drawing_stage_1": true},
		),
		"Stage 2 unlocked after stage 1",
	)


func test_stage_gating_prevents_replay() -> void:
	assert_false(
		TheDrawing.compute_can_trigger_stage(
			1, {"drawing_stage_1": true},
		),
		"Completed stage should not re-trigger",
	)


func test_stage_4_requires_stage_3() -> void:
	var flags := {
		"drawing_stage_1": true,
		"drawing_stage_2": true,
		"drawing_stage_3": true,
	}
	assert_true(
		TheDrawing.compute_can_trigger_stage(4, flags),
		"Stage 4 should unlock after stages 1-3",
	)
