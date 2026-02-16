extends GutTest

## Tests for DialogueLine resource — factory method and has_choices().


var _line: DialogueLine


func before_each() -> void:
	_line = DialogueLine.new()


func test_default_values() -> void:
	assert_eq(_line.speaker, "")
	assert_eq(_line.text, "")
	assert_null(_line.portrait)
	assert_eq(_line.choices.size(), 0)


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
