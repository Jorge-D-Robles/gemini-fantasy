extends GutTest

## Tests for OvergrownRuinsEntryDialogue — static gate dialogue module.
## Verifies structure, flag names, and story content of the entry scene.

const EntryDialogue = preload(
	"res://scenes/overgrown_ruins/overgrown_ruins_entry_dialogue.gd"
)


func test_entry_flag_is_string() -> void:
	var flag: String = EntryDialogue.get_entry_flag()
	assert_true(flag is String, "Entry flag must be a String")
	assert_gt(flag.length(), 0, "Entry flag must not be empty")


func test_entry_flag_value() -> void:
	assert_eq(
		EntryDialogue.get_entry_flag(),
		"overgrown_capital_entry_seen",
		"Entry flag must match expected constant",
	)


func test_gate_flag_is_string() -> void:
	var flag: String = EntryDialogue.get_entry_gate_flag()
	assert_true(flag is String, "Gate flag must be a String")
	assert_gt(flag.length(), 0, "Gate flag must not be empty")


func test_gate_flag_value() -> void:
	assert_eq(
		EntryDialogue.get_entry_gate_flag(),
		"garrick_recruited",
		"Gate flag must be garrick_recruited",
	)


func test_get_entry_lines_returns_array() -> void:
	var lines: Array = EntryDialogue.get_entry_lines()
	assert_true(lines is Array, "get_entry_lines must return an Array")


func test_entry_lines_has_minimum_count() -> void:
	var lines: Array = EntryDialogue.get_entry_lines()
	assert_gte(lines.size(), 5, "Entry dialogue must have at least 5 lines")


func test_garrick_is_speaker() -> void:
	var lines: Array = EntryDialogue.get_entry_lines()
	var has_garrick := false
	for entry: Dictionary in lines:
		if entry.get("speaker", "") == "Garrick":
			has_garrick = true
			break
	assert_true(has_garrick, "Garrick must appear as a speaker")


func test_kael_is_speaker() -> void:
	var lines: Array = EntryDialogue.get_entry_lines()
	var has_kael := false
	for entry: Dictionary in lines:
		if entry.get("speaker", "") == "Kael":
			has_kael = true
			break
	assert_true(has_kael, "Kael must appear as a speaker")


func test_iris_is_speaker() -> void:
	var lines: Array = EntryDialogue.get_entry_lines()
	var has_iris := false
	for entry: Dictionary in lines:
		if entry.get("speaker", "") == "Iris":
			has_iris = true
			break
	assert_true(has_iris, "Iris must appear as a speaker")


func test_people_mentioned() -> void:
	var lines: Array = EntryDialogue.get_entry_lines()
	var combined := ""
	for entry: Dictionary in lines:
		combined += entry.get("text", "").to_lower()
	assert_true(
		"people" in combined,
		"Dialogue must reference the people who once lived here",
	)


func test_two_million_mentioned() -> void:
	var lines: Array = EntryDialogue.get_entry_lines()
	var combined := ""
	for entry: Dictionary in lines:
		combined += entry.get("text", "").to_lower()
	assert_true(
		"million" in combined,
		"Dialogue must reference the population figure (two million)",
	)


func test_take_point_mentioned() -> void:
	var lines: Array = EntryDialogue.get_entry_lines()
	var combined := ""
	for entry: Dictionary in lines:
		combined += entry.get("text", "").to_lower()
	assert_true(
		"point" in combined,
		"Garrick must call 'take point' to establish leadership",
	)


func test_each_entry_has_speaker_and_text() -> void:
	var lines: Array = EntryDialogue.get_entry_lines()
	for i: int in lines.size():
		var entry: Dictionary = lines[i]
		assert_true(
			entry.has("speaker"),
			"Line %d must have a speaker key" % i,
		)
		assert_true(
			entry.has("text"),
			"Line %d must have a text key" % i,
		)
		assert_gt(
			entry.get("text", "").length(), 0,
			"Line %d must have non-empty text" % i,
		)
