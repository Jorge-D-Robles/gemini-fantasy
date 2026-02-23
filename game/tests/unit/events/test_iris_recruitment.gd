extends GutTest

## Tests for IrisRecruitment event script — conditional logic only.

var _recruitment: Node


func before_each() -> void:
	_recruitment = load("res://events/iris_recruitment.gd").new()
	add_child_autofree(_recruitment)


func test_compute_should_auto_accept_true_when_recruited() -> void:
	var flags := {"iris_recruited": true}
	assert_true(
		IrisRecruitment.compute_should_auto_accept_iris_quest(flags),
		"Should auto-accept when iris_recruited flag is set",
	)


func test_compute_should_auto_accept_false_when_not_recruited() -> void:
	assert_false(
		IrisRecruitment.compute_should_auto_accept_iris_quest({}),
		"Should not auto-accept when iris_recruited flag is missing",
	)
