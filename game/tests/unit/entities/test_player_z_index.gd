extends GutTest

## Regression test: player and battle visual scenes must have z_index = 1
## so they render above z=0 TileMapLayer nodes (Objects, Walls, Decorations).
## Bug: characters were hidden behind background tiles in both overworld
## and battle scenes because z_index defaulted to 0, competing with tile layers.


func test_player_z_index_is_one() -> void:
	var packed: PackedScene = load("res://entities/player/player.tscn")
	assert_not_null(packed, "player.tscn must load")
	var player: CharacterBody2D = packed.instantiate()
	add_child_autofree(player)
	assert_eq(
		player.z_index,
		1,
		"Player must have z_index=1 to render above z=0 tile layers",
	)


func test_party_battler_scene_z_index_is_one() -> void:
	var packed: PackedScene = load(
		"res://entities/battle/party_battler_scene.tscn"
	)
	assert_not_null(packed, "party_battler_scene.tscn must load")
	var scene: Node2D = packed.instantiate()
	add_child_autofree(scene)
	assert_eq(
		scene.z_index,
		1,
		"PartyBattlerScene must have z_index=1 to render above battle background",
	)


func test_enemy_battler_scene_z_index_is_one() -> void:
	var packed: PackedScene = load(
		"res://entities/battle/enemy_battler_scene.tscn"
	)
	assert_not_null(packed, "enemy_battler_scene.tscn must load")
	var scene: Node2D = packed.instantiate()
	add_child_autofree(scene)
	assert_eq(
		scene.z_index,
		1,
		"EnemyBattlerScene must have z_index=1 to render above battle background",
	)
