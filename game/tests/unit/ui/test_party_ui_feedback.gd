extends GutTest

## Tests for T-0163: compute_swap_feedback_text static helper in PartyUIData.
## Kept separate from test_party_ui.gd to stay within the 20-public-methods gdlint limit.

const PartyUIData := preload("res://ui/party_ui/party_ui_data.gd")


func test_swap_feedback_no_active_selected() -> void:
	var msg: String = PartyUIData.compute_swap_feedback_text(-1, 3, 2)
	assert_true(msg.length() > 0, "Negative active index should return non-empty feedback")


func test_swap_feedback_no_reserve_available() -> void:
	var msg: String = PartyUIData.compute_swap_feedback_text(0, 3, 0)
	assert_true(msg.length() > 0, "Zero reserve size should return non-empty feedback")


func test_swap_feedback_messages_differ_by_case() -> void:
	var no_selection: String = PartyUIData.compute_swap_feedback_text(-1, 3, 2)
	var no_reserve: String = PartyUIData.compute_swap_feedback_text(0, 3, 0)
	assert_ne(no_selection, no_reserve, "Different failure reasons should give different messages")


func test_swap_feedback_invalid_active_index_out_of_bounds() -> void:
	var msg: String = PartyUIData.compute_swap_feedback_text(5, 3, 2)
	assert_true(msg.length() > 0, "Out-of-bounds active index should return non-empty feedback")


func test_swap_feedback_returns_string_type() -> void:
	var msg: String = PartyUIData.compute_swap_feedback_text(-1, 0, 0)
	assert_true(msg is String, "Return value must be a String")
