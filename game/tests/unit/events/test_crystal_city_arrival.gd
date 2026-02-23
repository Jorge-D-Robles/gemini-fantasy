extends GutTest

## Tests for CrystalCityArrival.compute_can_trigger() and dialogue line factories.


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


func test_scene3_includes_lyra_confession_content() -> void:
	var lines := CrystalCityArrival.compute_scene3_lines()
	var has_anchor_mention: bool = false
	for line: DialogueLine in lines:
		if line.text.contains("Resonance anchoring") or line.text.contains("anchoring points"):
			has_anchor_mention = true
			break
	assert_true(has_anchor_mention, "Scene 3 must reference Lyra's anchoring points confession")


