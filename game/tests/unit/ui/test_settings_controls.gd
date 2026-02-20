extends GutTest

## Tests for SettingsData.compute_control_bindings() —
## read-only control bindings display for the settings menu.

const SD := preload("res://ui/settings_menu/settings_data.gd")


# -- compute_control_bindings --


func test_returns_nonempty_array() -> void:
	var bindings := SD.compute_control_bindings()
	assert_true(
		bindings.size() > 0,
		"compute_control_bindings() should return at least one entry",
	)


func test_each_entry_has_label_key() -> void:
	var bindings := SD.compute_control_bindings()
	for entry: Dictionary in bindings:
		assert_true(
			entry.has("label"),
			"Each binding entry must have a 'label' key",
		)
		assert_true(
			entry.has("key"),
			"Each binding entry must have a 'key' key",
		)


func test_interact_entry_present() -> void:
	var bindings := SD.compute_control_bindings()
	var labels: Array[String] = []
	for entry: Dictionary in bindings:
		labels.append(entry["label"] as String)
	assert_true(
		labels.has("Interact"),
		"Bindings should include an 'Interact' entry",
	)


func test_interact_entry_has_nonempty_key() -> void:
	var bindings := SD.compute_control_bindings()
	for entry: Dictionary in bindings:
		if (entry["label"] as String) == "Interact":
			assert_true(
				(entry["key"] as String).length() > 0,
				"Interact key should not be empty when action is defined",
			)
			return
	fail_test("No 'Interact' entry found in bindings")


func test_move_up_label_is_correct() -> void:
	var bindings := SD.compute_control_bindings()
	var found := false
	for entry: Dictionary in bindings:
		if (entry["label"] as String) == "Move Up":
			found = true
			break
	assert_true(found, "Should have an entry with label 'Move Up'")


func test_action_name_to_label_known() -> void:
	var label := SD.compute_action_label("interact")
	assert_eq(label, "Interact", "interact action should map to 'Interact'")


func test_action_name_to_label_unknown_returns_titlecase() -> void:
	var label := SD.compute_action_label("some_action")
	assert_true(
		label.length() > 0,
		"Unknown action should still return a non-empty label",
	)


func test_action_key_label_unknown_returns_fallback() -> void:
	var key := SD.compute_action_key_label("nonexistent_action_xyz")
	assert_eq(key, "—", "Unknown action should return '—' fallback")
