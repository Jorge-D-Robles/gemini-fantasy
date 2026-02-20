extends GutTest

## Tests for T-0162: Verdant Forest traversal dialogue — structural contract.

const VFDialogue = preload(
	"res://scenes/verdant_forest/verdant_forest_dialogue.gd"
)


func test_traversal_lines_each_have_speaker_key() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	for line: Dictionary in lines:
		assert_true(line.has("speaker"), "Each line must have a 'speaker' key")


func test_traversal_lines_each_have_text_key() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	for line: Dictionary in lines:
		assert_true(line.has("text"), "Each line must have a 'text' key")


func test_traversal_lines_text_is_non_empty() -> void:
	var lines: Array = VFDialogue.get_traversal_lines()
	for line: Dictionary in lines:
		assert_true(
			(line["text"] as String).length() > 0,
			"Each line must have non-empty text",
		)
