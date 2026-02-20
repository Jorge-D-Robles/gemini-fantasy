extends GutTest

## Tests for T-0248: Nyx CharacterData .tres and NyxIntroduction party-join wiring.

const NyxIntroduction = preload("res://events/nyx_introduction.gd")

var _nyx: CharacterData


func before_each() -> void:
	_nyx = load("res://data/characters/nyx.tres")


# ---- nyx.tres resource ----

func test_nyx_tres_exists() -> void:
	assert_not_null(_nyx, "nyx.tres should exist and load successfully")


func test_nyx_is_character_data() -> void:
	assert_true(_nyx is CharacterData, "nyx.tres should be CharacterData")


func test_nyx_id() -> void:
	assert_eq(_nyx.id, &"nyx", "id should be 'nyx'")


func test_nyx_display_name() -> void:
	assert_false(_nyx.display_name.is_empty(), "display_name should not be empty")


func test_nyx_magic_is_highest_stat() -> void:
	assert_true(
		_nyx.magic >= _nyx.attack,
		"Nyx is a mage — magic should be >= attack",
	)


func test_nyx_has_weapon_types() -> void:
	assert_true(_nyx.allowed_weapon_types.size() > 0, "Nyx should have allowed weapon types")


func test_nyx_has_skill_trees() -> void:
	assert_eq(_nyx.skill_trees.size(), 3, "Nyx should have 3 skill tree paths")


# ---- NyxIntroduction party wiring ----

func test_nyx_introduction_has_nyx_resource_path() -> void:
	assert_true(
		NyxIntroduction.NYX_CHARACTER_PATH.length() > 0,
		"NYX_CHARACTER_PATH constant should be non-empty",
	)


func test_nyx_introduction_resource_path_points_to_nyx_tres() -> void:
	assert_true(
		ResourceLoader.exists(NyxIntroduction.NYX_CHARACTER_PATH),
		"NYX_CHARACTER_PATH should point to an existing resource",
	)
