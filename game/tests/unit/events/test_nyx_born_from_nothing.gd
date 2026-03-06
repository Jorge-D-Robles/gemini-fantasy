extends GutTest

## Tests for NyxBornFromNothing event — Chapter 6 expanded scenes.
## Scenes 4-5 + Camp: Nyx discovers the world, reveals Hollows lore,
## and bonds with Garrick at night.

var _event: Node


func before_each() -> void:
	_event = load("res://events/nyx_born_from_nothing.gd").new()
	add_child_autofree(_event)


func test_compute_can_trigger_false_without_nyx_introduction() -> void:
	var flags: Dictionary = {}
	assert_false(
		NyxBornFromNothing.compute_can_trigger(flags),
		"Must be false when nyx_introduction_seen is not set",
	)


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags: Dictionary = {
		"nyx_introduction_seen": true,
		"nyx_born_from_nothing_seen": true,
	}
	assert_false(
		NyxBornFromNothing.compute_can_trigger(flags),
		"Must be false when event already seen",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags: Dictionary = {
		"nyx_introduction_seen": true,
	}
	assert_true(
		NyxBornFromNothing.compute_can_trigger(flags),
		"Must be true when nyx_introduction_seen set and event not yet seen",
	)


func test_discovery_lines_not_empty() -> void:
	var lines := NyxBornFromNothing.compute_discovery_lines()
	assert_gt(lines.size(), 0, "Discovery lines should not be empty")


func test_discovery_lines_contain_butterfly_scene() -> void:
	var lines := NyxBornFromNothing.compute_discovery_lines()
	var found := false
	for line: DialogueLine in lines:
		if "butterfly" in line.text.to_lower() or "colors" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Should contain butterfly/colors discovery")


func test_campfire_lines_not_empty() -> void:
	var lines := NyxBornFromNothing.compute_campfire_lines()
	assert_gt(lines.size(), 0, "Campfire lines should not be empty")


func test_campfire_lines_contain_hollows_lore() -> void:
	var lines := NyxBornFromNothing.compute_campfire_lines()
	var found := false
	for line: DialogueLine in lines:
		if "hollows" in line.text.to_lower() or "voices" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Campfire scene should reference the Hollows")


func test_camp_scene_lines_not_empty() -> void:
	var lines := NyxBornFromNothing.compute_camp_scene_lines()
	assert_gt(lines.size(), 0, "Camp scene lines should not be empty")


func test_camp_scene_features_garrick_and_nyx() -> void:
	var lines := NyxBornFromNothing.compute_camp_scene_lines()
	var has_garrick := false
	var has_nyx := false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick":
			has_garrick = true
		if line.speaker == "Nyx":
			has_nyx = true
	assert_true(has_garrick, "Camp scene should feature Garrick")
	assert_true(has_nyx, "Camp scene should feature Nyx")


func test_total_line_count() -> void:
	var total: int = (
		NyxBornFromNothing.compute_discovery_lines().size()
		+ NyxBornFromNothing.compute_campfire_lines().size()
		+ NyxBornFromNothing.compute_camp_scene_lines().size()
	)
	assert_gte(total, 30, "Full event should have 30+ dialogue lines")
