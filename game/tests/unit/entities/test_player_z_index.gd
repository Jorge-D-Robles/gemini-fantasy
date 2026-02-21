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


func test_player_sprite_has_y_sort_offset() -> void:
	## AnimatedSprite2D must have offset to place Y-sort origin near feet.
	var content := FileAccess.get_file_as_string("res://entities/player/player.tscn")
	assert_false(content.is_empty(), "player.tscn must exist")
	assert_true(
		content.contains("offset = Vector2(0, -16)"),
		"AnimatedSprite2D must have offset = Vector2(0, -16) for correct Y-sort with 48px frames",
	)


func test_scene_roots_do_not_have_y_sort() -> void:
	## Scene roots must NOT have y_sort_enabled — it breaks z_index layering
	## and causes the player to render behind ground tiles.
	## y_sort belongs ONLY on the Entities node.
	var scenes: Array[String] = [
		"res://scenes/overgrown_ruins/overgrown_ruins.tscn",
		"res://scenes/verdant_forest/verdant_forest.tscn",
		"res://scenes/roothollow/roothollow.tscn",
		"res://scenes/overgrown_capital/overgrown_capital.tscn",
		"res://scenes/prismfall_approach/prismfall_approach.tscn",
	]
	for scene_path: String in scenes:
		var content := FileAccess.get_file_as_string(scene_path)
		assert_false(content.is_empty(), scene_path + " must exist")
		# Find root node section (first [node) and check it does NOT have y_sort
		var root_start := content.find("[node name=")
		assert_true(root_start >= 0, scene_path + " must have a root node")
		var next_node := content.find("\n[node", root_start + 1)
		var root_section: String
		if next_node >= 0:
			root_section = content.substr(root_start, next_node - root_start)
		else:
			root_section = content.substr(root_start)
		assert_false(
			root_section.contains("y_sort_enabled = true"),
			scene_path + " root must NOT have y_sort_enabled (breaks z_index layering)",
		)


func test_z0_tilemaplayers_do_not_have_y_sort() -> void:
	## z=0 TileMapLayers (Walls, Objects, Trees, TreesBorder) must NOT have
	## y_sort_enabled. Depth is handled by tree order within z=0, not y_sort.
	var scene_z0_layers: Dictionary = {
		"res://scenes/overgrown_ruins/overgrown_ruins.tscn": ["Walls", "Objects"],
		"res://scenes/verdant_forest/verdant_forest.tscn": ["Trees", "Objects"],
		"res://scenes/roothollow/roothollow.tscn": ["Objects", "TreesBorder"],
		"res://scenes/overgrown_capital/overgrown_capital.tscn": ["Walls", "Objects"],
	}
	for scene_path: String in scene_z0_layers.keys():
		var content := FileAccess.get_file_as_string(scene_path)
		assert_false(content.is_empty(), scene_path + " must exist")
		var layers: Array = scene_z0_layers[scene_path]
		for layer_name: String in layers:
			var node_marker := '[node name="' + layer_name + '"'
			var idx := content.find(node_marker)
			assert_true(
				idx >= 0,
				scene_path + " must contain node " + layer_name,
			)
			if idx < 0:
				continue
			var next_node := content.find("\n[node", idx + 1)
			var section: String
			if next_node >= 0:
				section = content.substr(idx, next_node - idx)
			else:
				section = content.substr(idx)
			assert_false(
				section.contains("y_sort_enabled = true"),
				scene_path + " node " + layer_name + " must NOT have y_sort_enabled",
			)


func test_entities_have_y_sort() -> void:
	## Entities nodes MUST have y_sort_enabled — this is the only place
	## where y_sort should be set, for player/NPC depth sorting.
	var scenes: Array[String] = [
		"res://scenes/overgrown_ruins/overgrown_ruins.tscn",
		"res://scenes/verdant_forest/verdant_forest.tscn",
		"res://scenes/roothollow/roothollow.tscn",
		"res://scenes/overgrown_capital/overgrown_capital.tscn",
		"res://scenes/prismfall_approach/prismfall_approach.tscn",
	]
	for scene_path: String in scenes:
		var content := FileAccess.get_file_as_string(scene_path)
		assert_false(content.is_empty(), scene_path + " must exist")
		var node_marker := '[node name="Entities"'
		var idx := content.find(node_marker)
		assert_true(idx >= 0, scene_path + " must contain Entities node")
		if idx < 0:
			continue
		var next_node := content.find("\n[node", idx + 1)
		var section: String
		if next_node >= 0:
			section = content.substr(idx, next_node - idx)
		else:
			section = content.substr(idx)
		assert_true(
			section.contains("y_sort_enabled = true"),
			scene_path + " Entities node must have y_sort_enabled = true",
		)


func test_player_frame_size_is_48x48() -> void:
	## Player sprite sheet is a single-character 3x4 grid.
	## Frame size must be width/3 x height/4 = 48x48, NOT 24x24.
	var source := FileAccess.get_file_as_string("res://entities/player/player.gd")
	assert_false(source.is_empty(), "player.gd must exist")
	assert_true(
		source.contains("texture.get_width() / 3"),
		"Player frame_w must use texture.get_width() / 3 (single-char sheet)",
	)
	assert_true(
		source.contains("texture.get_height() / 4"),
		"Player frame_h must use texture.get_height() / 4 (single-char sheet)",
	)
	assert_false(
		source.contains("chars_per_row"),
		"Player must not use multi-character sheet math (chars_per_row)",
	)


func test_companion_frame_size_is_48x48() -> void:
	## CompanionFollower.build_sprite_frames uses the same single-char layout.
	var source := FileAccess.get_file_as_string(
		"res://entities/companion/companion_follower.gd"
	)
	assert_false(source.is_empty(), "companion_follower.gd must exist")
	assert_true(
		source.contains("texture.get_width() / 3"),
		"Companion frame_w must use texture.get_width() / 3 (single-char sheet)",
	)
	assert_true(
		source.contains("texture.get_height() / 4"),
		"Companion frame_h must use texture.get_height() / 4 (single-char sheet)",
	)
	assert_false(
		source.contains("2 * 3"),
		"Companion must not use multi-character sheet math (2 * 3)",
	)
