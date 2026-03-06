# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Cipher's "Ghost in the Machine" character quest:
## 5 stages spanning Acts II-III.
##   Stage 1: Breadcrumbs — safehouse discovery of Anchor Control Protocol.
##   Stage 2: The Kennel — infiltrate the Initiative facility.
##   Stage 3: Hijacked — Vex takes control of Cipher remotely.
##   Stage 4: The Room Inside the Room — mindscape dungeon, purge Protocol.
##   Stage 5: Unshackled — return to destroy the device.


# --- Flag constant ---


func test_flag_prefix() -> void:
	assert_eq(
		GhostInMachine.FLAG_PREFIX,
		"ghost_stage_",
		"Flag prefix should be ghost_stage_",
	)


# --- Stage 1: Breadcrumbs ---


func test_breadcrumbs_lines_not_empty() -> void:
	var lines := GhostInMachine.compute_breadcrumbs_lines()
	assert_gt(lines.size(), 0, "Stage 1 should have lines")


func test_breadcrumbs_includes_cipher() -> void:
	var found := false
	for line in GhostInMachine.compute_breadcrumbs_lines():
		if line.speaker == "Cipher":
			found = true
			break
	assert_true(found, "Breadcrumbs should include Cipher")


func test_breadcrumbs_mentions_protocol() -> void:
	var found := false
	for line in GhostInMachine.compute_breadcrumbs_lines():
		var lower := line.text.to_lower()
		if "protocol" in lower or "control" in lower:
			found = true
			break
	assert_true(
		found,
		"Breadcrumbs should mention protocol or control",
	)


func test_breadcrumbs_includes_iris() -> void:
	var found := false
	for line in GhostInMachine.compute_breadcrumbs_lines():
		if line.speaker == "Iris":
			found = true
			break
	assert_true(found, "Breadcrumbs should include Iris")


# --- Stage 2: The Kennel ---


func test_kennel_lines_not_empty() -> void:
	var lines := GhostInMachine.compute_kennel_lines()
	assert_gt(lines.size(), 0, "Stage 2 should have lines")


func test_kennel_includes_cipher() -> void:
	var found := false
	for line in GhostInMachine.compute_kennel_lines():
		if line.speaker == "Cipher":
			found = true
			break
	assert_true(found, "Kennel should include Cipher")


func test_kennel_mentions_facility() -> void:
	var found := false
	for line in GhostInMachine.compute_kennel_lines():
		var lower := line.text.to_lower()
		if "facility" in lower or "cell" in lower or "subject" in lower:
			found = true
			break
	assert_true(found, "Kennel should mention facility or cells")


func test_kennel_includes_kael() -> void:
	var found := false
	for line in GhostInMachine.compute_kennel_lines():
		if line.speaker == "Kael":
			found = true
			break
	assert_true(found, "Kennel should include Kael")


# --- Stage 3: Hijacked ---


func test_hijacked_lines_not_empty() -> void:
	var lines := GhostInMachine.compute_hijacked_lines()
	assert_gt(lines.size(), 0, "Stage 3 should have lines")


func test_hijacked_includes_cipher_vex() -> void:
	var found := false
	for line in GhostInMachine.compute_hijacked_lines():
		if line.speaker == "Cipher/Vex":
			found = true
			break
	assert_true(found, "Hijacked should include Cipher/Vex")


func test_hijacked_mentions_override() -> void:
	var found := false
	for line in GhostInMachine.compute_hijacked_lines():
		var lower := line.text.to_lower()
		if (
			"control" in lower
			or "override" in lower
			or "puppet" in lower
			or "hijack" in lower
		):
			found = true
			break
	assert_true(found, "Hijacked should reference control or override")


func test_hijacked_includes_garrick() -> void:
	var found := false
	for line in GhostInMachine.compute_hijacked_lines():
		if line.speaker == "Garrick":
			found = true
			break
	assert_true(found, "Hijacked should include Garrick")


# --- Stage 4: The Room Inside the Room ---


func test_room_lines_not_empty() -> void:
	var lines := GhostInMachine.compute_room_lines()
	assert_gt(lines.size(), 0, "Stage 4 should have lines")


func test_room_includes_cipher() -> void:
	var found := false
	for line in GhostInMachine.compute_room_lines():
		if line.speaker == "Cipher":
			found = true
			break
	assert_true(found, "Room should include Cipher")


func test_room_mentions_memory() -> void:
	var found := false
	for line in GhostInMachine.compute_room_lines():
		var lower := line.text.to_lower()
		if "memory" in lower or "mind" in lower or "head" in lower:
			found = true
			break
	assert_true(found, "Room should reference memory or mind")


func test_room_includes_kael() -> void:
	var found := false
	for line in GhostInMachine.compute_room_lines():
		if line.speaker == "Kael":
			found = true
			break
	assert_true(found, "Room should include Kael")


# --- Stage 5: Unshackled ---


func test_unshackled_lines_not_empty() -> void:
	var lines := GhostInMachine.compute_unshackled_lines()
	assert_gt(lines.size(), 0, "Stage 5 should have lines")


func test_unshackled_includes_cipher() -> void:
	var found := false
	for line in GhostInMachine.compute_unshackled_lines():
		if line.speaker == "Cipher":
			found = true
			break
	assert_true(found, "Unshackled should include Cipher")


func test_unshackled_mentions_device_or_destroy() -> void:
	var found := false
	for line in GhostInMachine.compute_unshackled_lines():
		var lower := line.text.to_lower()
		if (
			"device" in lower
			or "destroy" in lower
			or "break" in lower
		):
			found = true
			break
	assert_true(
		found,
		"Unshackled should mention device or destruction",
	)


func test_unshackled_includes_vex() -> void:
	var found := false
	for line in GhostInMachine.compute_unshackled_lines():
		if line.speaker == "Vex":
			found = true
			break
	assert_true(found, "Unshackled should include Vex")


# --- Cross-stage checks ---


func test_total_line_count_minimum() -> void:
	var total := (
		GhostInMachine.compute_breadcrumbs_lines().size()
		+ GhostInMachine.compute_kennel_lines().size()
		+ GhostInMachine.compute_hijacked_lines().size()
		+ GhostInMachine.compute_room_lines().size()
		+ GhostInMachine.compute_unshackled_lines().size()
	)
	assert_gt(
		total, 50,
		"Total lines across all stages should exceed 50",
	)


func test_all_speakers_valid() -> void:
	var valid_speakers := [
		"Cipher", "Kael", "Iris", "Garrick", "Nyx",
		"Cipher/Vex", "Vex", "Technician", "Scientist",
		"Reflection",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(
		GhostInMachine.compute_breadcrumbs_lines(),
	)
	all_lines.append_array(
		GhostInMachine.compute_kennel_lines(),
	)
	all_lines.append_array(
		GhostInMachine.compute_hijacked_lines(),
	)
	all_lines.append_array(
		GhostInMachine.compute_room_lines(),
	)
	all_lines.append_array(
		GhostInMachine.compute_unshackled_lines(),
	)
	for line in all_lines:
		assert_has(
			valid_speakers, line.speaker,
			"Speaker '%s' should be valid" % line.speaker,
		)


func test_stage_gating_stage_1_available() -> void:
	assert_true(
		GhostInMachine.compute_can_trigger_stage(1, {}),
		"Stage 1 has no prerequisites",
	)


func test_stage_gating_requires_previous() -> void:
	assert_false(
		GhostInMachine.compute_can_trigger_stage(2, {}),
		"Stage 2 requires stage 1 complete",
	)
	assert_true(
		GhostInMachine.compute_can_trigger_stage(
			2, {"ghost_stage_1": true},
		),
		"Stage 2 unlocked after stage 1",
	)


func test_stage_gating_prevents_replay() -> void:
	assert_false(
		GhostInMachine.compute_can_trigger_stage(
			1, {"ghost_stage_1": true},
		),
		"Completed stage should not re-trigger",
	)


func test_stage_5_requires_stage_4() -> void:
	var flags := {
		"ghost_stage_1": true,
		"ghost_stage_2": true,
		"ghost_stage_3": true,
		"ghost_stage_4": true,
	}
	assert_true(
		GhostInMachine.compute_can_trigger_stage(5, flags),
		"Stage 5 should unlock after stages 1-4",
	)
