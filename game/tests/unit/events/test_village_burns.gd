extends GutTest

## Tests for VillageBurns event — Chapter 7 "A Village Burns" full event.


func test_compute_can_trigger_false_without_lyra_fragment() -> void:
	var flags: Dictionary = {
		"nyx_met": true,
	}
	assert_false(
		VillageBurns.compute_can_trigger(flags),
		"Must be false when lyra_fragment_2_collected is not set",
	)


func test_compute_can_trigger_false_without_nyx_met() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
	}
	assert_false(
		VillageBurns.compute_can_trigger(flags),
		"Must be false when nyx_met is not set",
	)


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
		"nyx_met": true,
		"village_burns_seen": true,
	}
	assert_false(
		VillageBurns.compute_can_trigger(flags),
		"Must be false when village_burns_seen flag is already set",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
		"nyx_met": true,
	}
	assert_true(
		VillageBurns.compute_can_trigger(flags),
		"Must be true when gate flags set and event not yet seen",
	)


func test_scene1_lines_not_empty() -> void:
	var lines := VillageBurns.compute_scene1_lines()
	assert_gt(lines.size(), 0, "Scene 1 should have dialogue")


func test_scene1_starts_with_alarm() -> void:
	var lines := VillageBurns.compute_scene1_lines()
	assert_eq(lines[0].speaker, "Kael")
	assert_true("sun" in lines[0].text.to_lower(), "Should start with fire sighting")


func test_scene2_features_sera() -> void:
	var lines := VillageBurns.compute_scene2_lines()
	var has_sera := false
	for line: DialogueLine in lines:
		if line.speaker == "Sera":
			has_sera = true
			break
	assert_true(has_sera, "Scene 2 should feature Sera")


func test_scene2_garrick_sera_history() -> void:
	var lines := VillageBurns.compute_scene2_lines()
	var found := false
	for line: DialogueLine in lines:
		if "willowmere" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Should reference Willowmere")


func test_aftermath_features_morin() -> void:
	var lines := VillageBurns.compute_aftermath_lines()
	var has_morin := false
	for line: DialogueLine in lines:
		if line.speaker == "Morin":
			has_morin = true
			break
	assert_true(has_morin, "Aftermath should feature Elder Morin")


func test_aftermath_references_regional_purge() -> void:
	var lines := VillageBurns.compute_aftermath_lines()
	var found := false
	for line: DialogueLine in lines:
		if "sixteen" in line.text.to_lower() or "purge" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Should reference the regional purge")


func test_leaving_lines_not_empty() -> void:
	var lines := VillageBurns.compute_leaving_lines()
	assert_gt(lines.size(), 0, "Leaving scene should have dialogue")


func test_leaving_features_maeve_and_yara() -> void:
	var lines := VillageBurns.compute_leaving_lines()
	var has_maeve := false
	var has_yara := false
	for line: DialogueLine in lines:
		if line.speaker == "Maeve":
			has_maeve = true
		if line.speaker == "Yara":
			has_yara = true
	assert_true(has_maeve, "Should include Maeve's goodbye")
	assert_true(has_yara, "Should include Yara's goodbye")


func test_camp_lines_feature_kael_iris() -> void:
	var lines := VillageBurns.compute_camp_lines()
	var has_kael := false
	var has_iris := false
	for line: DialogueLine in lines:
		if line.speaker == "Kael":
			has_kael = true
		if line.speaker == "Iris":
			has_iris = true
	assert_true(has_kael, "Camp scene should feature Kael")
	assert_true(has_iris, "Camp scene should feature Iris")


func test_camp_references_lost_echoes() -> void:
	var lines := VillageBurns.compute_camp_lines()
	var found := false
	for line: DialogueLine in lines:
		if "echoes" in line.text.to_lower() or "collection" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Camp scene should reference lost Echo collection")


func test_total_line_count() -> void:
	var total: int = (
		VillageBurns.compute_scene1_lines().size()
		+ VillageBurns.compute_scene2_lines().size()
		+ VillageBurns.compute_aftermath_lines().size()
		+ VillageBurns.compute_leaving_lines().size()
		+ VillageBurns.compute_camp_lines().size()
	)
	assert_gte(total, 45, "Full event should have 45+ dialogue lines")


func test_battle_choice_enum_exists() -> void:
	assert_eq(
		VillageBurns.BattleChoice.SAVE_VILLAGERS, 0,
		"SAVE_VILLAGERS should be 0",
	)
	assert_eq(
		VillageBurns.BattleChoice.ATTACK_SHEPHERDS, 1,
		"ATTACK_SHEPHERDS should be 1",
	)
	assert_eq(
		VillageBurns.BattleChoice.SPLIT_PARTY, 2,
		"SPLIT_PARTY should be 2",
	)
