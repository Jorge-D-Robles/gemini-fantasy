extends GutTest

## Tests for FastTravelUI.compute_beacon_entries — pure static helper.

const FastTravelUIScript = preload("res://ui/fast_travel_ui/fast_travel_ui.gd")
const SP = preload("res://systems/scene_paths.gd")


func test_compute_beacon_entries_all_locked() -> void:
	var flags: Dictionary = {}
	var entries: Array[Dictionary] = FastTravelUIScript.compute_beacon_entries(
		flags, SP.ROOTHOLLOW,
	)
	assert_eq(entries.size(), 0, "No beacons unlocked → empty entries")


func test_compute_beacon_entries_one_unlocked() -> void:
	var flags: Dictionary = {"fast_travel_roothollow": true}
	var entries: Array[Dictionary] = FastTravelUIScript.compute_beacon_entries(
		flags, SP.VERDANT_FOREST,
	)
	assert_eq(entries.size(), 1)
	assert_eq(entries[0]["name"], "Roothollow")
	assert_false(entries[0]["is_current"])


func test_compute_beacon_entries_excludes_current_scene() -> void:
	var flags: Dictionary = {"fast_travel_roothollow": true}
	var entries: Array[Dictionary] = FastTravelUIScript.compute_beacon_entries(
		flags, SP.ROOTHOLLOW,
	)
	assert_eq(entries.size(), 1)
	assert_true(entries[0]["is_current"], "Current scene beacon should be marked")


func test_compute_beacon_entries_multiple_unlocked() -> void:
	var flags: Dictionary = {
		"fast_travel_roothollow": true,
		"fast_travel_verdant_forest": true,
		"fast_travel_overgrown_ruins": true,
	}
	var entries: Array[Dictionary] = FastTravelUIScript.compute_beacon_entries(
		flags, SP.ROOTHOLLOW,
	)
	assert_eq(entries.size(), 3, "Three unlocked beacons")
	# First entry is current scene, should be marked
	var current_entries := entries.filter(
		func(e: Dictionary) -> bool: return e["is_current"]
	)
	assert_eq(current_entries.size(), 1)
	assert_eq(current_entries[0]["name"], "Roothollow")


func test_compute_beacon_entries_dungeon_not_in_list() -> void:
	# Capital is a dungeon — never appears as a beacon destination
	var flags: Dictionary = {
		"fast_travel_roothollow": true,
	}
	var entries: Array[Dictionary] = FastTravelUIScript.compute_beacon_entries(
		flags, SP.OVERGROWN_CAPITAL,
	)
	assert_eq(entries.size(), 1)
	assert_eq(entries[0]["name"], "Roothollow")


func test_compute_beacon_entries_returns_scene_and_spawn() -> void:
	var flags: Dictionary = {"fast_travel_roothollow": true}
	var entries: Array[Dictionary] = FastTravelUIScript.compute_beacon_entries(
		flags, SP.VERDANT_FOREST,
	)
	assert_eq(entries[0]["scene"], SP.ROOTHOLLOW)
	assert_false(entries[0]["spawn"].is_empty(), "Spawn point should be set")
