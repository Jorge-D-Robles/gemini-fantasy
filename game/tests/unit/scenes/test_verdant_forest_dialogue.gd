extends GutTest

## Tests for T-0162: Verdant Forest traversal dialogue (full party, post-Garrick).

const VFDialogue = preload(
	"res://scenes/verdant_forest/verdant_forest_dialogue.gd"
)


func test_traversal_lines_returns_four_lines() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	assert_eq(lines.size(), 4, "Traversal dialogue should have exactly 4 lines")


func test_traversal_lines_each_have_speaker_key() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	for line: Dictionary in lines:
		assert_true(line.has("speaker"), "Each line must have a 'speaker' key")


func test_traversal_lines_each_have_text_key() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	for line: Dictionary in lines:
		assert_true(line.has("text"), "Each line must have a 'text' key")


func test_traversal_garrick_is_first_speaker() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	assert_eq(
		lines[0]["speaker"], "Garrick",
		"Garrick should speak first (crystal expert noting density)",
	)


func test_traversal_includes_iris_speaker() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	var speakers: Array = []
	for line: Dictionary in lines:
		speakers.append(line["speaker"])
	assert_true(speakers.has("Iris"), "Iris should appear in traversal dialogue")


func test_traversal_includes_kael_speaker() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	var speakers: Array = []
	for line: Dictionary in lines:
		speakers.append(line["speaker"])
	assert_true(speakers.has("Kael"), "Kael should appear in traversal dialogue")


func test_traversal_lines_text_is_non_empty() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	for line: Dictionary in lines:
		assert_true(
			(line["text"] as String).length() > 0,
			"Each line must have non-empty text",
		)


func test_traversal_flag_returns_correct_name() -> void:
	assert_eq(
		VFDialogue.get_traversal_flag(),
		"forest_traversal_full_party",
		"One-shot flag name should be 'forest_traversal_full_party'",
	)


func test_traversal_gate_flag_returns_correct_name() -> void:
	assert_eq(
		VFDialogue.get_traversal_gate_flag(),
		"garrick_recruited",
		"Gate flag should be 'garrick_recruited'",
	)
