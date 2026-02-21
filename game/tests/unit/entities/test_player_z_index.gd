extends GutTest

## Regression tests: rendering order uses scene tree order, not z_index.
## Player renders above tiles because Entities comes after TileMapLayers
## in the scene tree. AbovePlayer comes after Entities for canopy walk-under.
## Companion renders behind player because CompanionController is the first
## child of Entities (tree order: earlier = behind).


func test_player_has_no_explicit_z_index() -> void:
	var content := FileAccess.get_file_as_string("res://entities/player/player.tscn")
	assert_false(content.is_empty(), "player.tscn must exist")
	for line: String in content.split("\n"):
		var stripped := line.strip_edges()
		assert_false(
			stripped.begins_with("z_index"),
			"Player must not set z_index — rendering uses scene tree order",
		)


func test_companion_follower_has_no_z_index() -> void:
	var source := FileAccess.get_file_as_string(
		"res://entities/companion/companion_follower.gd"
	)
	assert_false(source.is_empty(), "companion_follower.gd must exist")
	assert_false(
		source.contains("z_index"),
		"CompanionFollower must not set z_index — uses tree order (first child of Entities)",
	)


func test_companion_controller_moves_to_front() -> void:
	var source := FileAccess.get_file_as_string(
		"res://entities/companion/companion_controller.gd"
	)
	assert_false(source.is_empty(), "companion_controller.gd must exist")
	assert_true(
		source.contains("move_child"),
		"CompanionController must move itself to index 0 so followers render behind player",
	)


func test_party_battler_scene_z_index_is_one() -> void:
	# Battle scenes are independent — z_index=1 is still correct there
	var content := FileAccess.get_file_as_string(
		"res://entities/battle/party_battler_scene.tscn"
	)
	assert_false(content.is_empty(), "party_battler_scene.tscn must exist")
	assert_true(
		content.contains("z_index = 1"),
		"PartyBattlerScene must have z_index=1 to render above battle background",
	)


func test_enemy_battler_scene_z_index_is_one() -> void:
	var content := FileAccess.get_file_as_string(
		"res://entities/battle/enemy_battler_scene.tscn"
	)
	assert_false(content.is_empty(), "enemy_battler_scene.tscn must exist")
	assert_true(
		content.contains("z_index = 1"),
		"EnemyBattlerScene must have z_index=1 to render above battle background",
	)
