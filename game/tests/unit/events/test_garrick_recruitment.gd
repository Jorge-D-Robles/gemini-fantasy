extends GutTest

## Tests for GarrickRecruitment event script — conditional logic only.

var _recruitment: Node


func before_each() -> void:
	_recruitment = load("res://events/garrick_recruitment.gd").new()
	add_child_autofree(_recruitment)


func test_compute_should_auto_accept_true_when_recruited() -> void:
	var flags := {"garrick_recruited": true}
	assert_true(
		_recruitment.compute_should_auto_accept_garrick_quest(flags),
		"Should auto-accept when garrick_recruited flag is set",
	)


func test_compute_should_auto_accept_false_when_not_recruited() -> void:
	assert_false(
		_recruitment.compute_should_auto_accept_garrick_quest({}),
		"Should not auto-accept when garrick_recruited flag is missing",
	)
