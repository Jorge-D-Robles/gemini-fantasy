extends GutTest

## Tests for T-0187: Echo Collection Journal UI.
## Covers compute_echo_list() and compute_echo_detail() static helpers.

const EchoJournalScript := preload("res://ui/echo_journal/echo_journal.gd")
const EchoManagerScript := preload("res://autoloads/echo_manager.gd")
const EchoData := preload("res://resources/echo_data.gd")

var _echo_mgr: Node


func before_each() -> void:
	_echo_mgr = EchoManagerScript.new()
	add_child_autofree(_echo_mgr)


# --- compute_echo_list ---


func test_compute_echo_list_empty_when_no_echoes_collected() -> void:
	var result: Array[Dictionary] = EchoJournalScript.compute_echo_list(
		_echo_mgr, []
	)
	assert_eq(result.size(), 0, "Empty echo manager returns empty list")


func test_compute_echo_list_returns_entry_for_each_collected_echo() -> void:
	_echo_mgr.collect_echo(&"burning_village")
	_echo_mgr.collect_echo(&"childs_laughter")
	var result: Array[Dictionary] = EchoJournalScript.compute_echo_list(
		_echo_mgr, []
	)
	assert_eq(result.size(), 2, "Two collected echoes returns two entries")


func test_compute_echo_list_entry_has_required_keys() -> void:
	_echo_mgr.collect_echo(&"burning_village")
	var result: Array[Dictionary] = EchoJournalScript.compute_echo_list(
		_echo_mgr, []
	)
	assert_eq(result.size(), 1)
	var entry: Dictionary = result[0]
	assert_true(entry.has("id"), "Entry has 'id' key")
	assert_true(entry.has("display_name"), "Entry has 'display_name' key")
	assert_true(entry.has("rarity"), "Entry has 'rarity' key")


func test_compute_echo_list_id_matches_collected_id() -> void:
	_echo_mgr.collect_echo(&"soldiers_fear")
	var result: Array[Dictionary] = EchoJournalScript.compute_echo_list(
		_echo_mgr, []
	)
	assert_eq(result.size(), 1)
	assert_eq(result[0]["id"], &"soldiers_fear", "Entry id matches collected id")


func test_compute_echo_list_uncollected_echoes_not_included() -> void:
	_echo_mgr.collect_echo(&"burning_village")
	var result: Array[Dictionary] = EchoJournalScript.compute_echo_list(
		_echo_mgr, []
	)
	for entry: Dictionary in result:
		assert_ne(
			entry["id"], &"childs_laughter",
			"Uncollected echo must not appear in list",
		)


# --- compute_echo_detail ---


func test_compute_echo_detail_empty_id_returns_empty_dict() -> void:
	var result: Dictionary = EchoJournalScript.compute_echo_detail(&"", [])
	assert_true(result.is_empty(), "Empty id returns empty dict")


func test_compute_echo_detail_unknown_id_returns_empty_dict() -> void:
	var result: Dictionary = EchoJournalScript.compute_echo_detail(
		&"nonexistent_echo_id_xyz", []
	)
	assert_true(result.is_empty(), "Unknown id returns empty dict")


# --- compute_echo_count_label ---


func test_compute_echo_count_label_zero() -> void:
	var text: String = EchoJournalScript.compute_echo_count_label(0, 42)
	assert_eq(text, "Echoes: 0 / 42", "Zero echoes label format")


func test_compute_echo_count_label_some_collected() -> void:
	var text: String = EchoJournalScript.compute_echo_count_label(3, 42)
	assert_eq(text, "Echoes: 3 / 42", "Partial collection label format")


func test_compute_echo_count_label_all_collected() -> void:
	var text: String = EchoJournalScript.compute_echo_count_label(42, 42)
	assert_eq(text, "Echoes: 42 / 42", "Full collection label format")
