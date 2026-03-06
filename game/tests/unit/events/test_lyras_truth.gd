extends GutTest

## Tests for LyrasTruth — full Chapter 9 "Beneath Prismfall" event.
## Covers all 7 dialogue scene methods: descent, gallery, deep, warden,
## scene5 (Lyra's Truth), camp, and watchers.


func test_compute_can_trigger_false_without_prismfall_arrived() -> void:
	var flags := {"lyras_truth_seen": false}
	assert_false(
		LyrasTruth.compute_can_trigger(flags),
		"Must need prismfall_arrived",
	)


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags := {"prismfall_arrived": true, "lyras_truth_seen": true}
	assert_false(
		LyrasTruth.compute_can_trigger(flags),
		"Must not re-trigger when lyras_truth_seen is set",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags := {"prismfall_arrived": true, "lyras_truth_seen": false}
	assert_true(
		LyrasTruth.compute_can_trigger(flags),
		"Must trigger when prismfall_arrived and NOT lyras_truth_seen",
	)


# --- Scene 1: The Descent ---

func test_descent_lines_not_empty() -> void:
	var lines := LyrasTruth.compute_descent_lines()
	assert_gt(lines.size(), 0, "Descent scene must have lines")


func test_descent_includes_nyx_crystal_patience() -> void:
	var lines := LyrasTruth.compute_descent_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Nyx" and line.text.contains("Patience"):
			found = true
			break
	assert_true(found, "Nyx must describe the crystals feeling 'Patience'")


func test_descent_includes_sixty_million_years() -> void:
	var lines := LyrasTruth.compute_descent_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("sixty million"):
			found = true
			break
	assert_true(found, "Descent must mention sixty million year old formations")


# --- Scene 2: The Living Gallery ---

func test_gallery_lines_not_empty() -> void:
	var lines := LyrasTruth.compute_gallery_lines()
	assert_gt(lines.size(), 0, "Gallery scene must have lines")


func test_gallery_includes_resonance_imprints() -> void:
	var lines := LyrasTruth.compute_gallery_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("imprint"):
			found = true
			break
	assert_true(found, "Gallery must reference Resonance imprints in crystal")


func test_gallery_includes_nyx_graveyard() -> void:
	var lines := LyrasTruth.compute_gallery_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Nyx" and line.text.contains("graveyard"):
			found = true
			break
	assert_true(found, "Nyx must call the gallery a 'beautiful graveyard'")


# --- Scene 3: The Deep ---

func test_deep_lines_not_empty() -> void:
	var lines := LyrasTruth.compute_deep_lines()
	assert_gt(lines.size(), 0, "Deep scene must have lines")


func test_deep_includes_warden_watching() -> void:
	var lines := LyrasTruth.compute_deep_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("watching") or line.text.contains("deciding"):
			found = true
			break
	assert_true(found, "Deep scene must mention the Warden watching/deciding")


# --- Scene 4: The Crystalline Warden ---

func test_warden_lines_not_empty() -> void:
	var lines := LyrasTruth.compute_warden_lines()
	assert_gt(lines.size(), 0, "Warden scene must have lines")


func test_warden_includes_identity_question() -> void:
	var lines := LyrasTruth.compute_warden_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("what you are") or line.text.contains("INCOMPLETE"):
			found = true
			break
	assert_true(found, "Warden must ask about Kael's identity or call them incomplete")


func test_warden_includes_kael_honest_answer() -> void:
	var lines := LyrasTruth.compute_warden_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Kael" and line.text.contains("understand"):
			found = true
			break
	assert_true(found, "Kael must say they're here to understand")


# --- Scene 5: Lyra's Truth (existing, verify expansion) ---

func test_scene5_includes_eight_hundred_million() -> void:
	var lines := LyrasTruth.compute_scene5_lines()
	var has_count: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("eight hundred million"):
			has_count = true
			break
	assert_true(has_count, "Scene 5 must reference the eight hundred million death toll")


func test_scene5_includes_nyx_splinter_revelation() -> void:
	var lines := LyrasTruth.compute_scene5_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Nyx" and line.text.contains("shard"):
			found = true
			break
	assert_true(found, "Scene 5 must include Nyx identifying as a Convergence shard")


func test_scene5_includes_garrick_impossible_choice() -> void:
	var lines := LyrasTruth.compute_scene5_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and line.text.contains("less wrong"):
			found = true
			break
	assert_true(found, "Garrick must acknowledge the impossible choice")


# --- Camp Scene ---

func test_camp_includes_nyx_splinter_line() -> void:
	var lines := LyrasTruth.compute_camp_lines()
	var has_nyx: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Nyx" and line.text.contains("Convergence"):
			has_nyx = true
			break
	assert_true(has_nyx, "Camp scene must include Nyx's line about the Convergence")


func test_camp_includes_garrick_no_good_answer() -> void:
	var lines := LyrasTruth.compute_camp_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and line.text.contains("good answer"):
			found = true
			break
	assert_true(found, "Garrick must say nobody has a good answer")


# --- Scene 6: The Watchers ---

func test_watchers_lines_not_empty() -> void:
	var lines := LyrasTruth.compute_watchers_lines()
	assert_gt(lines.size(), 0, "Watchers scene must have lines")


func test_watchers_includes_initiative_surveillance() -> void:
	var lines := LyrasTruth.compute_watchers_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("Initiative") or line.text.contains("tactical"):
			found = true
			break
	assert_true(found, "Watchers must reference Initiative operatives")


func test_watchers_includes_lorne() -> void:
	var lines := LyrasTruth.compute_watchers_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Lorne":
			found = true
			break
	assert_true(found, "Watchers scene must include Lorne")


func test_watchers_includes_urgency_to_leave() -> void:
	var lines := LyrasTruth.compute_watchers_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("leave") or line.text.contains("tonight"):
			found = true
			break
	assert_true(found, "Watchers must convey urgency to leave Prismfall")


# --- Cross-scene checks ---

func test_total_line_count_at_least_60() -> void:
	var total: int = (
		LyrasTruth.compute_descent_lines().size()
		+ LyrasTruth.compute_gallery_lines().size()
		+ LyrasTruth.compute_deep_lines().size()
		+ LyrasTruth.compute_warden_lines().size()
		+ LyrasTruth.compute_scene5_lines().size()
		+ LyrasTruth.compute_camp_lines().size()
		+ LyrasTruth.compute_watchers_lines().size()
	)
	assert_gte(total, 60, "Full Chapter 9 must have at least 60 dialogue lines")


func test_all_scenes_have_valid_speakers() -> void:
	var valid_speakers := [
		"Kael", "Iris", "Garrick", "Nyx", "Lyra", "Lorne",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(LyrasTruth.compute_descent_lines())
	all_lines.append_array(LyrasTruth.compute_gallery_lines())
	all_lines.append_array(LyrasTruth.compute_deep_lines())
	all_lines.append_array(LyrasTruth.compute_warden_lines())
	all_lines.append_array(LyrasTruth.compute_scene5_lines())
	all_lines.append_array(LyrasTruth.compute_camp_lines())
	all_lines.append_array(LyrasTruth.compute_watchers_lines())
	for line: DialogueLine in all_lines:
		assert_has(valid_speakers, line.speaker, "Unknown speaker: " + line.speaker)
