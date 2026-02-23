extends GutTest

## Tests for T-0264: SaveSlotDialog pure logic (compute_slot_entries).

const SaveSlotDialogScript := preload(
	"res://ui/save_slot_dialog/save_slot_dialog.gd"
)


func _make_empty_summary() -> Dictionary:
	return {"empty": true, "location": "", "playtime_str": "", "time_str": "", "timestamp": 0}


func _make_populated_summary(
	location: String = "Roothollow",
	playtime: String = "01:30",
	time: String = "22 Feb, 14:30",
	timestamp: int = 1000,
) -> Dictionary:
	return {
		"empty": false,
		"location": location,
		"playtime_str": playtime,
		"time_str": time,
		"timestamp": timestamp,
	}


# --- compute_slot_entries SAVE mode (no autosave) ---

func test_compute_slot_entries_all_empty_save_mode() -> void:
	var summaries: Array[Dictionary] = [
		_make_empty_summary(),
		_make_empty_summary(),
		_make_empty_summary(),
		_make_empty_summary(),
	]
	var entries: Array[Dictionary] = (
		SaveSlotDialogScript.compute_slot_entries(summaries, false)
	)
	assert_eq(entries.size(), 3, "Save mode shows slots 1-3 only")
	for entry in entries:
		assert_true(entry["empty"], "All entries should be empty")


func test_compute_slot_entries_with_data_save_mode() -> void:
	var summaries: Array[Dictionary] = [
		_make_empty_summary(),
		_make_populated_summary("Roothollow", "01:30", "22 Feb, 14:30"),
		_make_empty_summary(),
		_make_populated_summary("Verdant Forest", "03:00", "22 Feb, 16:00"),
	]
	var entries: Array[Dictionary] = (
		SaveSlotDialogScript.compute_slot_entries(summaries, false)
	)
	assert_eq(entries.size(), 3)
	assert_false(entries[0]["empty"])
	assert_eq(entries[0]["location"], "Roothollow")
	assert_true(entries[1]["empty"])
	assert_false(entries[2]["empty"])
	assert_eq(entries[2]["location"], "Verdant Forest")


# --- compute_slot_entries LOAD mode (with autosave) ---

func test_compute_slot_entries_include_autosave() -> void:
	var summaries: Array[Dictionary] = [
		_make_populated_summary("Overgrown Ruins", "00:15", "22 Feb, 10:00"),
		_make_empty_summary(),
		_make_empty_summary(),
		_make_empty_summary(),
	]
	var entries: Array[Dictionary] = (
		SaveSlotDialogScript.compute_slot_entries(summaries, true)
	)
	assert_eq(entries.size(), 4, "Load mode with autosave shows all 4 slots")


func test_compute_slot_entries_autosave_labeled() -> void:
	var summaries: Array[Dictionary] = [
		_make_populated_summary("Overgrown Ruins"),
		_make_empty_summary(),
		_make_empty_summary(),
		_make_empty_summary(),
	]
	var entries: Array[Dictionary] = (
		SaveSlotDialogScript.compute_slot_entries(summaries, true)
	)
	assert_eq(entries[0]["label"], "Autosave", "Slot 0 should be labeled Autosave")
	assert_eq(entries[1]["label"], "Slot 1")
	assert_eq(entries[2]["label"], "Slot 2")
	assert_eq(entries[3]["label"], "Slot 3")


func test_compute_slot_entries_excludes_autosave_in_save_mode() -> void:
	var summaries: Array[Dictionary] = [
		_make_populated_summary("Overgrown Ruins"),
		_make_empty_summary(),
		_make_empty_summary(),
		_make_empty_summary(),
	]
	var entries: Array[Dictionary] = (
		SaveSlotDialogScript.compute_slot_entries(summaries, false)
	)
	assert_eq(entries.size(), 3, "Save mode excludes autosave slot")
	assert_eq(entries[0]["label"], "Slot 1", "First entry is Slot 1, not Autosave")
