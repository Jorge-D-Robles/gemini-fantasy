extends GutTest

## Regression tests: player and battle visual scenes render correctly above tiles.
## Design: player.z_index=0 with z_as_relative=true; Entities parent sets z_index=1
## in each overworld scene so the player's effective z = 1 (above z=0 tile layers).
## Battle scenes (party/enemy) set z_index=1 directly on their scene root.
## NOTE: We parse .tscn files directly to avoid headless INTEGER_DIVISION engine
## errors caused by instantiating scenes with Camera2D or ProgressBar nodes.


func test_player_z_index_is_zero_relative_to_parent() -> void:
	# Player's own z_index is 0 (Godot default — not explicitly written in .tscn).
	# The containing Entities Node2D in each overworld scene sets z_index=1,
	# giving an effective z=1 above the z=0 tile layers.
	var content := FileAccess.get_file_as_string("res://entities/player/player.tscn")
	assert_false(content.is_empty(), "player.tscn must exist")
	# The root node must NOT have z_index set to a non-zero value.
	var found_nonzero_z := false
	for line: String in content.split("\n"):
		var stripped := line.strip_edges()
		if stripped.begins_with("z_index") and not (stripped == "z_index = 0"):
			found_nonzero_z = true
			break
	assert_false(
		found_nonzero_z,
		"Player z_index must be 0 (Godot default); parent Entities sets z_index=1 in each scene",
	)


func test_party_battler_scene_z_index_is_one() -> void:
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
