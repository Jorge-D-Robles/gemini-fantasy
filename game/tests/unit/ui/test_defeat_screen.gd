extends GutTest

## Tests for T-0136: player-driven defeat screen recovery options.
## Validates compute_defeat_options pure function and signal API design.

const BattleUIDefeat := preload("res://ui/battle_ui/battle_ui_defeat.gd")


func test_compute_defeat_options_with_save_returns_two_options() -> void:
	var opts := BattleUIDefeat.compute_defeat_options(true)
	assert_eq(opts.size(), 2, "Two options when a save exists")


func test_compute_defeat_options_no_save_returns_one_option() -> void:
	var opts := BattleUIDefeat.compute_defeat_options(false)
	assert_eq(opts.size(), 1, "One option when no save exists")


func test_compute_defeat_options_default_is_no_save() -> void:
	var opts := BattleUIDefeat.compute_defeat_options()
	assert_eq(opts.size(), 1, "Default (no args) treats has_save=false")


func test_compute_defeat_options_quit_always_present_with_save() -> void:
	var opts := BattleUIDefeat.compute_defeat_options(true)
	var has_quit := false
	for opt: Dictionary in opts:
		if opt.get("action", "") == "quit":
			has_quit = true
	assert_true(has_quit, "Quit action is present when save exists")


func test_compute_defeat_options_quit_always_present_without_save() -> void:
	var opts := BattleUIDefeat.compute_defeat_options(false)
	var has_quit := false
	for opt: Dictionary in opts:
		if opt.get("action", "") == "quit":
			has_quit = true
	assert_true(has_quit, "Quit action is present when no save exists")


func test_compute_defeat_options_load_present_with_save() -> void:
	var opts := BattleUIDefeat.compute_defeat_options(true)
	var has_load := false
	for opt: Dictionary in opts:
		if opt.get("action", "") == "load":
			has_load = true
	assert_true(has_load, "Load action is present when save exists")


func test_compute_defeat_options_load_absent_without_save() -> void:
	var opts := BattleUIDefeat.compute_defeat_options(false)
	var has_load := false
	for opt: Dictionary in opts:
		if opt.get("action", "") == "load":
			has_load = true
	assert_false(has_load, "Load action is absent when no save exists")


func test_compute_defeat_options_load_label_is_descriptive() -> void:
	var opts := BattleUIDefeat.compute_defeat_options(true)
	var load_opt: Dictionary = {}
	for opt: Dictionary in opts:
		if opt.get("action", "") == "load":
			load_opt = opt
	var label: String = load_opt.get("label", "")
	assert_true(label.length() > 0, "Load option has non-empty label")
	var label_lower := label.to_lower()
	assert_true(
		label_lower.contains("load") or label_lower.contains("save"),
		"Load label references 'load' or 'save'",
	)


func test_compute_defeat_options_all_entries_have_label_and_action() -> void:
	var opts := BattleUIDefeat.compute_defeat_options(true)
	for opt: Dictionary in opts:
		assert_true(opt.has("label"), "Each option has a label key")
		assert_true(opt.has("action"), "Each option has an action key")
		assert_true((opt.label as String).length() > 0, "Label is non-empty")
		assert_true((opt.action as String).length() > 0, "Action is non-empty")
