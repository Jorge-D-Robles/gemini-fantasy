extends GutTest

## Unit tests for PlaytestCapture — report building and filename formatting.

const PlaytestCapture := preload("res://tools/playtest_capture.gd")


# --- format_screenshot_filename ---

func test_format_single_digit_index_pads_to_three() -> void:
	var result := PlaytestCapture.format_screenshot_filename(1, "initial_spawn")
	assert_eq(result, "001_initial_spawn.png")


func test_format_double_digit_index_pads_to_three() -> void:
	var result := PlaytestCapture.format_screenshot_filename(42, "battle_started")
	assert_eq(result, "042_battle_started.png")


func test_format_three_digit_index_no_padding() -> void:
	var result := PlaytestCapture.format_screenshot_filename(100, "end")
	assert_eq(result, "100_end.png")


func test_format_empty_label_uses_placeholder() -> void:
	var result := PlaytestCapture.format_screenshot_filename(1, "")
	assert_true(result.begins_with("001_"))
	assert_true(result.ends_with(".png"))


# --- build_report ---

func test_build_report_success_true() -> void:
	var report := PlaytestCapture.build_report(
		true, 12.4, "res://scenes/roothollow/roothollow.tscn",
		[], [], 8, 8, {}
	)
	assert_true(report.get("success", false))


func test_build_report_success_false() -> void:
	var report := PlaytestCapture.build_report(
		false, 5.0, "res://scenes/s.tscn",
		[], ["error: something"], 3, 5, {}
	)
	assert_false(report.get("success", true))


func test_build_report_includes_duration() -> void:
	var report := PlaytestCapture.build_report(
		true, 12.4, "res://scenes/roothollow/roothollow.tscn",
		[], [], 8, 8, {}
	)
	assert_almost_eq(report.get("duration_seconds", 0.0), 12.4, 0.001)


func test_build_report_includes_scene_path() -> void:
	var report := PlaytestCapture.build_report(
		true, 5.0, "res://scenes/roothollow/roothollow.tscn",
		[], [], 0, 0, {}
	)
	assert_eq(report.get("scene"), "res://scenes/roothollow/roothollow.tscn")


func test_build_report_includes_screenshots() -> void:
	var screenshots := [
		{"index": 1, "label": "start", "file": "001_start.png"},
	]
	var report := PlaytestCapture.build_report(
		true, 5.0, "res://s.tscn", screenshots, [], 1, 1, {}
	)
	assert_eq(report.get("screenshots"), screenshots)


func test_build_report_includes_errors() -> void:
	var errors := ["Error: null reference at line 42"]
	var report := PlaytestCapture.build_report(
		false, 5.0, "res://s.tscn", [], errors, 0, 1, {}
	)
	assert_eq(report.get("errors"), errors)


func test_build_report_includes_actions_completed() -> void:
	var report := PlaytestCapture.build_report(
		true, 5.0, "res://s.tscn", [], [], 7, 10, {}
	)
	assert_eq(report.get("actions_completed"), 7)
	assert_eq(report.get("actions_total"), 10)


func test_build_report_includes_warnings_field() -> void:
	var report := PlaytestCapture.build_report(
		true, 5.0, "res://s.tscn", [], [], 0, 0, {}
	)
	assert_true(report.has("warnings"))


func test_build_report_includes_final_state() -> void:
	var final_state := {"game_state": "OVERWORLD", "party_count": 2}
	var report := PlaytestCapture.build_report(
		true, 5.0, "res://s.tscn", [], [], 0, 0, final_state
	)
	assert_eq(report.get("final_state"), final_state)


# --- collect_final_state ---

func test_collect_final_state_returns_dictionary() -> void:
	var result := PlaytestCapture.collect_final_state(null, null)
	assert_eq(typeof(result), TYPE_DICTIONARY)


func test_collect_final_state_has_required_keys() -> void:
	var result := PlaytestCapture.collect_final_state(null, null)
	assert_true(result.has("game_state"))
	assert_true(result.has("party_count"))
