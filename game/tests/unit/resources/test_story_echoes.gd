extends GutTest

## Tests for T-0197: Story Echo .tres files — Morning Commute, Family Dinner,
## Warning Ignored, The First Crack. Verifies id, rarity, and non-combat
## classification (uses_per_battle == 0) for each file.


func _load_echo(path: String) -> EchoData:
	return load(path) as EchoData


# -- morning_commute --


func test_morning_commute_loads() -> void:
	assert_not_null(_load_echo("res://data/echoes/morning_commute.tres"))


func test_morning_commute_id_and_rarity() -> void:
	var e := _load_echo("res://data/echoes/morning_commute.tres")
	assert_eq(e.id, &"morning_commute")
	assert_eq(e.rarity, EchoData.Rarity.COMMON)


func test_morning_commute_is_story_echo() -> void:
	var e := _load_echo("res://data/echoes/morning_commute.tres")
	assert_eq(e.echo_type, EchoData.EchoType.UNIQUE_ECHO)
	assert_eq(e.uses_per_battle, 0)


# -- family_dinner --


func test_family_dinner_loads() -> void:
	assert_not_null(_load_echo("res://data/echoes/family_dinner.tres"))


func test_family_dinner_id_and_rarity() -> void:
	var e := _load_echo("res://data/echoes/family_dinner.tres")
	assert_eq(e.id, &"family_dinner")
	assert_eq(e.rarity, EchoData.Rarity.COMMON)


func test_family_dinner_is_story_echo() -> void:
	var e := _load_echo("res://data/echoes/family_dinner.tres")
	assert_eq(e.echo_type, EchoData.EchoType.UNIQUE_ECHO)
	assert_eq(e.uses_per_battle, 0)


# -- warning_ignored --


func test_warning_ignored_loads() -> void:
	assert_not_null(_load_echo("res://data/echoes/warning_ignored.tres"))


func test_warning_ignored_id_and_rarity() -> void:
	var e := _load_echo("res://data/echoes/warning_ignored.tres")
	assert_eq(e.id, &"warning_ignored")
	assert_eq(e.rarity, EchoData.Rarity.UNCOMMON)


func test_warning_ignored_is_story_echo() -> void:
	var e := _load_echo("res://data/echoes/warning_ignored.tres")
	assert_eq(e.echo_type, EchoData.EchoType.UNIQUE_ECHO)
	assert_eq(e.uses_per_battle, 0)


# -- the_first_crack --


func test_the_first_crack_loads() -> void:
	assert_not_null(_load_echo("res://data/echoes/the_first_crack.tres"))


func test_the_first_crack_id_and_rarity() -> void:
	var e := _load_echo("res://data/echoes/the_first_crack.tres")
	assert_eq(e.id, &"the_first_crack")
	assert_eq(e.rarity, EchoData.Rarity.RARE)


func test_the_first_crack_is_story_echo() -> void:
	var e := _load_echo("res://data/echoes/the_first_crack.tres")
	assert_eq(e.echo_type, EchoData.EchoType.UNIQUE_ECHO)
	assert_eq(e.uses_per_battle, 0)
