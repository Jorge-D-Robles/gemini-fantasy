extends GutTest

## Tests for DialogueLine resource — factory method and has_choices().


var _line: DialogueLine


func before_each() -> void:
	_line = DialogueLine.new()


func test_has_choices_returns_false_when_empty() -> void:
	assert_false(_line.has_choices())


func test_has_choices_returns_true_with_choices() -> void:
	_line.choices = ["Yes", "No"]
	assert_true(_line.has_choices())


func test_create_with_required_params() -> void:
	var line := DialogueLine.create("Elder", "Welcome, traveler.")
	assert_eq(line.speaker, "Elder")
	assert_eq(line.text, "Welcome, traveler.")
	assert_null(line.portrait)
	assert_eq(line.choices.size(), 0)


func test_create_with_all_params() -> void:
	var choices: Array[String] = ["Accept", "Decline"]
	var line := DialogueLine.create("Elder", "Will you help?", null, choices)
	assert_eq(line.speaker, "Elder")
	assert_eq(line.text, "Will you help?")
	assert_null(line.portrait)
	assert_eq(line.choices.size(), 2)
	assert_eq(line.choices[0], "Accept")
	assert_eq(line.choices[1], "Decline")
	assert_true(line.has_choices())


func test_create_returns_new_instance_each_call() -> void:
	var a := DialogueLine.create("A", "First")
	var b := DialogueLine.create("B", "Second")
	assert_ne(a, b)
	assert_eq(a.speaker, "A")
	assert_eq(b.speaker, "B")


# --- build_from_pairs ---


func test_build_from_pairs_even_count() -> void:
	var raw: Array[String] = ["Kael", "Hello.", "Iris", "Hi there."]
	var lines := DialogueLine.build_from_pairs(raw)
	assert_eq(lines.size(), 2)
	assert_eq(lines[0].speaker, "Kael")
	assert_eq(lines[0].text, "Hello.")
	assert_eq(lines[1].speaker, "Iris")
	assert_eq(lines[1].text, "Hi there.")


func test_build_from_pairs_odd_count_ignores_last() -> void:
	var raw: Array[String] = ["Kael", "Hello.", "Orphan"]
	var lines := DialogueLine.build_from_pairs(raw, "TestSource")
	assert_eq(lines.size(), 1)
	assert_eq(lines[0].speaker, "Kael")


func test_build_from_pairs_empty_returns_empty() -> void:
	var raw: Array[String] = []
	var lines := DialogueLine.build_from_pairs(raw)
	assert_eq(lines.size(), 0)
