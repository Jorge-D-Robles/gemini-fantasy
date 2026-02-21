extends GutTest

## Regression tests: belt-and-suspenders rendering hierarchy.
## TileMapLayers use explicit z_index groups AND correct tree order:
##   Ground=-2, GroundDetail/Paths/Debris=-1, Walls/Objects=0,
##   Entities=0 (y_sort_enabled), AbovePlayer=1.
## Player has no z_index — renders via tree order within Entities.
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


func test_ground_tilemaplayer_has_z_index_minus_two() -> void:
	## Belt-and-suspenders: Ground must have z_index=-2 so it always
	## renders behind Entities regardless of tree-order subtleties.
	var content := FileAccess.get_file_as_string(
		"res://scenes/overgrown_ruins/overgrown_ruins.tscn"
	)
	assert_false(content.is_empty(), "overgrown_ruins.tscn must exist")
	assert_true(
		content.contains("z_index = -2"),
		"Ground TileMapLayer in overgrown_ruins.tscn must have z_index = -2",
	)


func test_above_player_tilemaplayer_has_z_index_one() -> void:
	## AbovePlayer must have z_index=1 to always render above Entities.
	var content := FileAccess.get_file_as_string(
		"res://scenes/verdant_forest/verdant_forest.tscn"
	)
	assert_false(content.is_empty(), "verdant_forest.tscn must exist")
	assert_true(
		content.contains("z_index = 1"),
		"AbovePlayer TileMapLayer in verdant_forest.tscn must have z_index = 1",
	)
