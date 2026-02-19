extends GutTest

## Tests for TutorialHints static utility.
## Verifies hint display logic, text retrieval, and flag naming.

var _th: GDScript


func before_each() -> void:
	_th = load("res://ui/hud/tutorial_hints.gd")


# -- should_show --

func test_should_show_returns_true_when_no_flag() -> void:
	assert_true(_th.should_show("interact", {}))


func test_should_show_returns_false_when_flag_set() -> void:
	var flags := {"tutorial_interact": true}
	assert_false(_th.should_show("interact", flags))


func test_should_show_returns_false_for_unknown_id() -> void:
	assert_false(_th.should_show("nonexistent", {}))


func test_should_show_ignores_unrelated_flags() -> void:
	var flags := {"tutorial_menu": true}
	assert_true(_th.should_show("interact", flags))


# -- get_hint_text --

func test_get_hint_text_returns_text_for_valid_id() -> void:
	var text: String = _th.get_hint_text("interact")
	assert_string_contains(text, "talk")


func test_get_hint_text_returns_empty_for_unknown_id() -> void:
	assert_eq(_th.get_hint_text("nonexistent"), "")


func test_get_hint_text_menu() -> void:
	var text: String = _th.get_hint_text("menu")
	assert_string_contains(text, "menu")


func test_get_hint_text_zone_travel() -> void:
	var text: String = _th.get_hint_text("zone_travel")
	assert_string_contains(text, "glowing")


# -- get_flag_name --

func test_get_flag_name_returns_prefixed_name() -> void:
	assert_eq(_th.get_flag_name("interact"), "tutorial_interact")


func test_get_flag_name_menu() -> void:
	assert_eq(_th.get_flag_name("menu"), "tutorial_menu")


# -- Completeness --

func test_all_hints_have_text() -> void:
	for hint_id: String in _th.HINTS:
		var text: String = _th.HINTS[hint_id]
		assert_true(
			text.length() > 0,
			"Hint '%s' should have non-empty text" % hint_id,
		)
