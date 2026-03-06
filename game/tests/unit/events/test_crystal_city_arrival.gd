extends GutTest

## Tests for CrystalCityArrival — Chapter 8 "The Crystal City" full event.


func test_compute_can_trigger_false_without_village_burns() -> void:
	var flags := {"prismfall_arrived": false}
	assert_false(
		CrystalCityArrival.compute_can_trigger(flags),
		"Must need village_burns_seen",
	)


func test_compute_can_trigger_false_when_already_arrived() -> void:
	var flags := {"village_burns_seen": true, "prismfall_arrived": true}
	assert_false(
		CrystalCityArrival.compute_can_trigger(flags),
		"Must not re-trigger when prismfall_arrived is set",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags := {"village_burns_seen": true, "prismfall_arrived": false}
	assert_true(
		CrystalCityArrival.compute_can_trigger(flags),
		"Must trigger when village_burns_seen and NOT prismfall_arrived",
	)


func test_scene1_not_empty() -> void:
	var lines := CrystalCityArrival.compute_scene1_lines()
	assert_gt(lines.size(), 0, "Scene 1 should have dialogue")


func test_scene1_has_nyx_crystal_singing() -> void:
	var lines := CrystalCityArrival.compute_scene1_lines()
	var found := false
	for line: DialogueLine in lines:
		if "singing" in line.text.to_lower() or "humming" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Scene 1 should have Nyx hearing crystals")


func test_scene3_includes_lyra_confession_content() -> void:
	var lines := CrystalCityArrival.compute_scene3_lines()
	var has_anchor_mention: bool = false
	for line: DialogueLine in lines:
		if "anchoring" in line.text:
			has_anchor_mention = true
			break
	assert_true(
		has_anchor_mention,
		"Scene 3 must reference Lyra's anchoring points",
	)


func test_scene3_features_lyra() -> void:
	var lines := CrystalCityArrival.compute_scene3_lines()
	var has_lyra := false
	for line: DialogueLine in lines:
		if line.speaker == "Lyra":
			has_lyra = true
			break
	assert_true(has_lyra, "Scene 3 should feature Lyra")


func test_evening_features_garrick_daughter() -> void:
	var lines := CrystalCityArrival.compute_evening_lines()
	var found := false
	for line: DialogueLine in lines:
		if "mara" in line.text.to_lower() or "daughter" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Evening should mention Garrick's daughter Mara")


func test_evening_features_initiative_agent() -> void:
	var lines := CrystalCityArrival.compute_evening_lines()
	var has_lorne := false
	for line: DialogueLine in lines:
		if line.speaker == "Lorne":
			has_lorne = true
			break
	assert_true(has_lorne, "Evening should feature Initiative agent Lorne")


func test_evening_nyx_reads_lorne() -> void:
	var lines := CrystalCityArrival.compute_evening_lines()
	var found := false
	for line: DialogueLine in lines:
		if line.speaker == "Nyx" and "lying" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Nyx should read Lorne as lying")


func test_camp_features_iris_kael() -> void:
	var lines := CrystalCityArrival.compute_camp_lines()
	var has_kael := false
	var has_iris := false
	for line: DialogueLine in lines:
		if line.speaker == "Kael":
			has_kael = true
		if line.speaker == "Iris":
			has_iris = true
	assert_true(has_kael, "Camp should feature Kael")
	assert_true(has_iris, "Camp should feature Iris")


func test_camp_references_guilt() -> void:
	var lines := CrystalCityArrival.compute_camp_lines()
	var found := false
	for line: DialogueLine in lines:
		if "guilt" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Camp should discuss guilt theme")


func test_total_line_count() -> void:
	var total: int = (
		CrystalCityArrival.compute_scene1_lines().size()
		+ CrystalCityArrival.compute_scene3_lines().size()
		+ CrystalCityArrival.compute_evening_lines().size()
		+ CrystalCityArrival.compute_camp_lines().size()
	)
	assert_gte(total, 50, "Full event should have 50+ dialogue lines")
