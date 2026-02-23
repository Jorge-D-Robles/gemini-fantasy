extends GutTest

## Tests for T-0264: Autosave and slot summary features in SaveManager.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const SaveManagerScript := preload("res://autoloads/save_manager.gd")
const SP = preload("res://systems/scene_paths.gd")
const TEST_SLOT_BASE: int = 90

var _save: Node
var _party: Node
var _inventory: Node
var _flags: Node


func before_each() -> void:
	_save = SaveManagerScript.new()
	add_child_autofree(_save)
	_party = load("res://autoloads/party_manager.gd").new()
	add_child_autofree(_party)
	_inventory = load("res://autoloads/inventory_manager.gd").new()
	add_child_autofree(_inventory)
	_flags = load("res://events/event_flags.gd").new()
	add_child_autofree(_flags)


func after_each() -> void:
	for i in 4:
		_save.delete_save(TEST_SLOT_BASE + i)
	# Clean up any real slots used in any_save_exists tests
	for i in SaveManagerScript.TOTAL_SLOTS:
		_save.delete_save(i)


# --- get_slot_summary ---

func test_get_slot_summary_empty_slot() -> void:
	var summary: Dictionary = _save.get_slot_summary(TEST_SLOT_BASE)
	assert_true(summary["empty"], "Empty slot should have empty=true")


func test_get_slot_summary_populated_slot() -> void:
	var kael := Helpers.make_battler_data({"id": &"kael"})
	_party.add_character(kael)
	_save.save_game(
		TEST_SLOT_BASE, _party, _inventory, _flags,
		SP.ROOTHOLLOW, Vector2(10, 20),
		null, null, 3661.0,
	)
	var summary: Dictionary = _save.get_slot_summary(TEST_SLOT_BASE)
	assert_false(summary["empty"], "Populated slot should have empty=false")
	assert_true(summary["timestamp"] > 0, "Should have a timestamp")


func test_get_slot_summary_includes_playtime() -> void:
	var kael := Helpers.make_battler_data({"id": &"kael"})
	_party.add_character(kael)
	_save.save_game(
		TEST_SLOT_BASE, _party, _inventory, _flags,
		SP.ROOTHOLLOW, Vector2.ZERO,
		null, null, 7200.0,
	)
	var summary: Dictionary = _save.get_slot_summary(TEST_SLOT_BASE)
	assert_eq(summary["playtime_str"], "02:00", "2 hours = 02:00")


# --- get_all_slot_summaries ---

func test_get_all_slot_summaries_returns_four_entries() -> void:
	var summaries: Array[Dictionary] = _save.get_all_slot_summaries()
	assert_eq(summaries.size(), 4, "Should return 4 slot summaries (0-3)")


# --- autosave exclusion ---

func test_is_autosave_excluded_title_screen() -> void:
	assert_true(
		_save.is_autosave_excluded(SP.TITLE_SCREEN),
		"Title screen should be excluded from autosave",
	)


func test_is_autosave_excluded_demo_end() -> void:
	assert_true(
		_save.is_autosave_excluded(SP.DEMO_END_SCREEN),
		"Demo end screen should be excluded from autosave",
	)


func test_is_autosave_excluded_overworld_false() -> void:
	assert_false(
		_save.is_autosave_excluded(SP.ROOTHOLLOW),
		"Overworld scenes should NOT be excluded from autosave",
	)


func test_is_autosave_excluded_ruins_false() -> void:
	assert_false(
		_save.is_autosave_excluded(SP.OVERGROWN_RUINS),
		"Overgrown Ruins should NOT be excluded from autosave",
	)


# --- any_save_exists ---

func test_any_save_exists_false_when_empty() -> void:
	assert_false(
		_save.any_save_exists(),
		"Should be false when no saves exist",
	)


func test_any_save_exists_true_after_save() -> void:
	var kael := Helpers.make_battler_data({"id": &"kael"})
	_party.add_character(kael)
	_save.save_game(
		1, _party, _inventory, _flags,
		SP.ROOTHOLLOW, Vector2.ZERO,
	)
	assert_true(
		_save.any_save_exists(),
		"Should be true after saving to slot 1",
	)
