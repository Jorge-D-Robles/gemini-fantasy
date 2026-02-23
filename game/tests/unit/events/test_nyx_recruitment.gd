extends GutTest

## Tests for T-0248: Nyx CharacterData .tres and NyxIntroduction party-join wiring.

const NyxIntroduction = preload("res://events/nyx_introduction.gd")

var _nyx: CharacterData


func before_each() -> void:
	_nyx = load("res://data/characters/nyx.tres")


# ---- nyx.tres resource ----

func test_nyx_magic_is_highest_stat() -> void:
	assert_true(
		_nyx.magic >= _nyx.attack,
		"Nyx is a mage — magic should be >= attack",
	)


# ---- NyxIntroduction party wiring ----

func test_nyx_introduction_resource_path_points_to_nyx_tres() -> void:
	assert_true(
		ResourceLoader.exists(NyxIntroduction.NYX_CHARACTER_PATH),
		"NYX_CHARACTER_PATH should point to an existing resource",
	)
