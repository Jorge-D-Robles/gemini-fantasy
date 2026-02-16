# gdlint:ignore = max-public-methods
extends GutTest

## Tests for SaveManager — save/load game state to JSON files.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const SaveManagerScript := preload("res://autoloads/save_manager.gd")
const TEST_SLOT: int = 99

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
	_save.delete_save(TEST_SLOT)


# --- gather_save_data ---

func test_gather_save_data_returns_dictionary() -> void:
	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://scenes/test.tscn", Vector2(10, 20),
	)
	assert_typeof(data, TYPE_DICTIONARY)


func test_gather_save_data_has_version() -> void:
	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://scenes/test.tscn", Vector2.ZERO,
	)
	assert_true(data.has("version"))
	assert_eq(data["version"], 1)


func test_gather_save_data_has_scene_and_position() -> void:
	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://scenes/roothollow.tscn", Vector2(100, 200),
	)
	assert_eq(data["scene_path"], "res://scenes/roothollow.tscn")
	assert_eq(data["player_position"]["x"], 100.0)
	assert_eq(data["player_position"]["y"], 200.0)


func test_gather_save_data_includes_party_ids() -> void:
	var kael := Helpers.make_battler_data({"id": &"kael"})
	var iris := Helpers.make_battler_data({"id": &"iris"})
	_party.add_character(kael)
	_party.add_character(iris)

	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	assert_eq(data["party"]["active"], ["kael", "iris"])
	assert_eq(data["party"]["reserve"], [])


func test_gather_save_data_includes_reserve_party() -> void:
	for i in 5:
		var c := Helpers.make_battler_data({
			"id": StringName("char_%d" % i),
		})
		_party.add_character(c)

	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	assert_eq(data["party"]["active"].size(), 4)
	assert_eq(data["party"]["reserve"].size(), 1)
	assert_eq(data["party"]["reserve"][0], "char_4")


func test_gather_save_data_includes_character_state() -> void:
	var kael := Helpers.make_battler_data({
		"id": &"kael",
		"max_hp": 100,
		"max_ee": 50,
	})
	_party.add_character(kael)
	_party.set_hp(&"kael", 75)
	_party.set_ee(&"kael", 30)

	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	var cs: Dictionary = data["character_state"]["kael"]
	assert_eq(cs["current_hp"], 75)
	assert_eq(cs["current_ee"], 30)


func test_gather_save_data_includes_character_level_xp() -> void:
	var cd := CharacterData.new()
	cd.id = &"kael"
	cd.display_name = "Kael"
	cd.max_hp = 100
	cd.max_ee = 50
	cd.level = 5
	cd.current_xp = 450
	_party.add_character(cd)

	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	var cs: Dictionary = data["character_state"]["kael"]
	assert_eq(cs["level"], 5)
	assert_eq(cs["current_xp"], 450)


func test_gather_save_data_includes_event_flags() -> void:
	_flags.set_flag("iris_recruited")
	_flags.set_flag("elder_spoke")

	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	assert_true(data["event_flags"]["iris_recruited"])
	assert_true(data["event_flags"]["elder_spoke"])


func test_gather_save_data_includes_inventory() -> void:
	_inventory.add_item(&"potion", 3)
	_inventory.add_item(&"ether", 1)
	_inventory.add_gold(250)

	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	assert_eq(data["inventory"]["gold"], 250)
	assert_eq(data["inventory"]["items"]["potion"], 3)
	assert_eq(data["inventory"]["items"]["ether"], 1)


func test_gather_save_data_empty_party() -> void:
	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	assert_eq(data["party"]["active"], [])
	assert_eq(data["party"]["reserve"], [])
	assert_eq(data["character_state"], {})


func test_gather_save_data_empty_inventory() -> void:
	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	assert_eq(data["inventory"]["gold"], 0)
	assert_eq(data["inventory"]["items"], {})


# --- save_game / has_save / load_save_data ---

func test_save_game_creates_file() -> void:
	var kael := Helpers.make_battler_data({"id": &"kael"})
	_party.add_character(kael)

	var ok: bool = _save.save_game(
		TEST_SLOT,
		_party, _inventory, _flags,
		"res://test.tscn", Vector2(50, 60),
	)
	assert_true(ok)
	assert_true(_save.has_save(TEST_SLOT))


func test_has_save_false_for_missing_slot() -> void:
	assert_false(_save.has_save(TEST_SLOT))


func test_load_save_data_returns_saved_data() -> void:
	var kael := Helpers.make_battler_data({
		"id": &"kael",
		"max_hp": 100,
		"max_ee": 50,
	})
	_party.add_character(kael)
	_party.set_hp(&"kael", 80)
	_inventory.add_item(&"potion", 2)
	_inventory.add_gold(100)
	_flags.set_flag("test_flag")

	_save.save_game(
		TEST_SLOT,
		_party, _inventory, _flags,
		"res://scenes/roothollow.tscn", Vector2(10, 20),
	)

	var loaded: Dictionary = _save.load_save_data(TEST_SLOT)
	assert_eq(loaded["version"], 1)
	assert_eq(loaded["scene_path"], "res://scenes/roothollow.tscn")
	assert_eq(loaded["player_position"]["x"], 10.0)
	assert_eq(loaded["player_position"]["y"], 20.0)
	assert_eq(loaded["party"]["active"], ["kael"])
	assert_eq(loaded["character_state"]["kael"]["current_hp"], 80)
	assert_eq(loaded["inventory"]["gold"], 100)
	assert_eq(loaded["inventory"]["items"]["potion"], 2)
	assert_true(loaded["event_flags"]["test_flag"])


func test_load_save_data_returns_empty_for_missing() -> void:
	var loaded: Dictionary = _save.load_save_data(TEST_SLOT)
	assert_eq(loaded, {})


# --- apply_save_data ---

func test_apply_restores_inventory() -> void:
	var save_data := {
		"version": 1,
		"inventory": {
			"gold": 500,
			"items": {"potion": 5, "ether": 2},
		},
		"party": {"active": [], "reserve": []},
		"character_state": {},
		"event_flags": {},
		"scene_path": "res://test.tscn",
		"player_position": {"x": 0.0, "y": 0.0},
	}

	_save.apply_save_data(save_data, _party, _inventory, _flags)
	assert_eq(_inventory.gold, 500)
	assert_eq(_inventory.get_item_count(&"potion"), 5)
	assert_eq(_inventory.get_item_count(&"ether"), 2)


func test_apply_restores_event_flags() -> void:
	var save_data := {
		"version": 1,
		"inventory": {"gold": 0, "items": {}},
		"party": {"active": [], "reserve": []},
		"character_state": {},
		"event_flags": {"boss_defeated": true, "iris_recruited": true},
		"scene_path": "res://test.tscn",
		"player_position": {"x": 0.0, "y": 0.0},
	}

	_save.apply_save_data(save_data, _party, _inventory, _flags)
	assert_true(_flags.has_flag("boss_defeated"))
	assert_true(_flags.has_flag("iris_recruited"))


func test_apply_restores_runtime_hp_ee() -> void:
	var kael := Helpers.make_battler_data({
		"id": &"kael",
		"max_hp": 100,
		"max_ee": 50,
	})
	_party.add_character(kael)

	var save_data := {
		"version": 1,
		"inventory": {"gold": 0, "items": {}},
		"party": {"active": ["kael"], "reserve": []},
		"character_state": {
			"kael": {
				"current_hp": 42,
				"current_ee": 15,
				"level": 1,
				"current_xp": 0,
			},
		},
		"event_flags": {},
		"scene_path": "res://test.tscn",
		"player_position": {"x": 0.0, "y": 0.0},
	}

	_save.apply_save_data(save_data, _party, _inventory, _flags)
	assert_eq(_party.get_hp(&"kael"), 42)
	assert_eq(_party.get_ee(&"kael"), 15)


func test_apply_clears_previous_inventory() -> void:
	_inventory.add_item(&"old_item", 10)
	_inventory.add_gold(999)

	var save_data := {
		"version": 1,
		"inventory": {"gold": 50, "items": {"new_item": 1}},
		"party": {"active": [], "reserve": []},
		"character_state": {},
		"event_flags": {},
		"scene_path": "res://test.tscn",
		"player_position": {"x": 0.0, "y": 0.0},
	}

	_save.apply_save_data(save_data, _party, _inventory, _flags)
	assert_eq(_inventory.gold, 50)
	assert_false(_inventory.has_item(&"old_item"))
	assert_true(_inventory.has_item(&"new_item"))


# --- delete_save ---

func test_delete_save_removes_file() -> void:
	var kael := Helpers.make_battler_data({"id": &"kael"})
	_party.add_character(kael)
	_save.save_game(
		TEST_SLOT,
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	assert_true(_save.has_save(TEST_SLOT))
	_save.delete_save(TEST_SLOT)
	assert_false(_save.has_save(TEST_SLOT))


# --- round-trip ---

func test_round_trip_preserves_all_state() -> void:
	var kael := Helpers.make_battler_data({
		"id": &"kael",
		"max_hp": 120,
		"max_ee": 60,
	})
	var iris := Helpers.make_battler_data({
		"id": &"iris",
		"max_hp": 90,
		"max_ee": 80,
	})
	_party.add_character(kael)
	_party.add_character(iris)
	_party.set_hp(&"kael", 55)
	_party.set_ee(&"iris", 40)

	_inventory.add_item(&"potion", 3)
	_inventory.add_item(&"antidote", 1)
	_inventory.add_gold(777)

	_flags.set_flag("chest_opened")
	_flags.set_flag("npc_talked")

	_save.save_game(
		TEST_SLOT,
		_party, _inventory, _flags,
		"res://scenes/forest.tscn", Vector2(123, 456),
	)

	# Reset all state
	_party.set_hp(&"kael", 120)
	_party.set_ee(&"iris", 80)
	_inventory.remove_item(&"potion", 3)
	_inventory.remove_item(&"antidote", 1)
	_inventory.gold = 0
	_flags.clear_flag("chest_opened")
	_flags.clear_flag("npc_talked")

	# Reload
	var loaded: Dictionary = _save.load_save_data(TEST_SLOT)
	_save.apply_save_data(loaded, _party, _inventory, _flags)

	assert_eq(_party.get_hp(&"kael"), 55)
	assert_eq(_party.get_ee(&"iris"), 40)
	assert_eq(_inventory.get_item_count(&"potion"), 3)
	assert_eq(_inventory.get_item_count(&"antidote"), 1)
	assert_eq(_inventory.gold, 777)
	assert_true(_flags.has_flag("chest_opened"))
	assert_true(_flags.has_flag("npc_talked"))
	assert_eq(loaded["scene_path"], "res://scenes/forest.tscn")
	assert_eq(loaded["player_position"]["x"], 123.0)
	assert_eq(loaded["player_position"]["y"], 456.0)


# --- get_save_path ---

func test_get_save_path_returns_correct_path() -> void:
	var path: String = _save.get_save_path(0)
	assert_eq(path, "user://saves/save_0.json")


func test_get_save_path_slot_1() -> void:
	var path: String = _save.get_save_path(1)
	assert_eq(path, "user://saves/save_1.json")
