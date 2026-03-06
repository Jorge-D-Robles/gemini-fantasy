extends GutTest

## Tests for compute_swap_feedback_text static helper in PartyUIData.

const PartyUIData := preload("res://ui/party_ui/party_ui_data.gd")


func test_swap_feedback_messages_differ_by_case() -> void:
	var no_selection: String = PartyUIData.compute_swap_feedback_text(-1, 3, 2)
	var no_reserve: String = PartyUIData.compute_swap_feedback_text(0, 3, 0)
	assert_ne(no_selection, no_reserve, "Different failure reasons should give different messages")
