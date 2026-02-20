extends Node2D

## Overgrown Capital — Chapter 5 dungeon.
## The party explores the crystal-vine-overgrown ruins of the pre-Severance
## capital city. Three districts: Market, Entertainment, Research/Residential.
## Story events (Lyra Fragment 2, Last Gardener, camp scenes) live in T-0191–T-0195.

const SP = preload("res://systems/scene_paths.gd")
const MEMORY_BLOOM_PATH: String = "res://data/enemies/memory_bloom.tres"
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const ECHO_NOMAD_PATH: String = "res://data/enemies/echo_nomad.tres"
const SCENE_BGM_PATH: String = "res://assets/music/Echoes of the Capital.ogg"

# Tilemap data (legends + maps) lives in OvergrownCapitalMap.
# Encounter pool builder lives in OvergrownCapitalEncounters.

var _ground_debris_layer: TileMapLayer = null

@onready var _ground_layer: TileMapLayer = $Ground
@onready var _ground_detail_layer: TileMapLayer = $GroundDetail
@onready var _walls_layer: TileMapLayer = $Walls
@onready var _objects_layer: TileMapLayer = $Objects
@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_from_ruins: Marker2D = $Entities/SpawnFromRuins
@onready var _encounter_system: EncounterSystem = $EncounterSystem
@onready var _exit_to_ruins: Area2D = $Triggers/ExitToRuins


static func compute_spawn_from_ruins_position() -> Vector2:
	## Entry spawn point at col 20, row 25 — bottom-center Market District.
	## Matches SpawnFromRuins Marker2D position in the scene tree.
	return Vector2(320.0, 400.0)


static func compute_market_save_point_position() -> Vector2:
	## Save point in the Market District entry area — col 10, row 23.
	return Vector2(160.0, 368.0)


func _ready() -> void:
	# Explicit z-index hierarchy matching existing scene pattern.
	$Ground.z_index = 0
	$GroundDetail.z_index = 0
	$Walls.z_index = 0
	$Objects.z_index = 0
	$Entities.z_index = 1

	# Dedicated debris layer — separates ground debris from ornate floor detail.
	# Inserted between GroundDetail and Walls, matching Overgrown Ruins pattern.
	_ground_debris_layer = TileMapLayer.new()
	_ground_debris_layer.name = "GroundDebris"
	_ground_debris_layer.z_index = 0
	add_child(_ground_debris_layer)
	move_child(_ground_debris_layer, $GroundDetail.get_index() + 1)

	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 448)
	_start_scene_music()
	_setup_camera_limits()
	_setup_encounters()

	UILayer.hud.location_name = "Overgrown Capital"

	# Register spawn group — GameManager.change_scene() looks for this group
	# when transitioning from Overgrown Ruins (wired via T-0216).
	_spawn_from_ruins.add_to_group("spawn_from_ruins")

	# Set default spawn position — overridden by GameManager after _ready()
	# if a specific spawn group was requested.
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.global_position = _spawn_from_ruins.global_position

	_exit_to_ruins.body_entered.connect(_on_exit_to_ruins_entered)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.FAIRY_FOREST_A5_A,
		MapBuilder.RUINS_A5,
		MapBuilder.OVERGROWN_RUINS_OBJECTS,
	]
	var solid: Dictionary = {
		1: [
			Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4),
			Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4),
			Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5),
			Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5), Vector2i(7, 5),
			Vector2i(0, 8), Vector2i(1, 8), Vector2i(2, 8), Vector2i(3, 8),
			Vector2i(4, 8), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8),
			Vector2i(0, 9), Vector2i(1, 9), Vector2i(2, 9), Vector2i(3, 9),
			Vector2i(4, 9), Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9),
		],
		2: [
			Vector2i(0, 0), Vector2i(2, 0), Vector2i(4, 0),
			Vector2i(0, 4), Vector2i(1, 4),
			Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2),
			Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3),
			Vector2i(8, 2), Vector2i(9, 2),
			Vector2i(8, 3), Vector2i(9, 3),
		],
	}
	MapBuilder.apply_tileset(
		[_ground_layer, _ground_detail_layer, _ground_debris_layer,
		_walls_layer, _objects_layer] as Array[TileMapLayer],
		atlas_paths,
		solid,
	)
	MapBuilder.build_layer(
		_ground_layer, OvergrownCapitalMap.GROUND_MAP, OvergrownCapitalMap.GROUND_LEGEND, 0
	)
	MapBuilder.build_layer(
		_ground_detail_layer, OvergrownCapitalMap.DETAIL_MAP, OvergrownCapitalMap.DETAIL_LEGEND, 1
	)
	MapBuilder.build_layer(
		_ground_debris_layer, OvergrownCapitalMap.DEBRIS_MAP, OvergrownCapitalMap.DEBRIS_LEGEND, 2
	)
	MapBuilder.build_layer(
		_walls_layer, OvergrownCapitalMap.WALL_MAP, OvergrownCapitalMap.WALL_LEGEND, 1
	)
	MapBuilder.build_layer(
		_objects_layer, OvergrownCapitalMap.OBJECTS_MAP, OvergrownCapitalMap.OBJECTS_LEGEND, 2
	)


func _start_scene_music() -> void:
	var bgm := load(SCENE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 1.5)
	else:
		push_warning("Scene BGM not found: " + SCENE_BGM_PATH)


func _setup_camera_limits() -> void:
	var cam: Camera2D = _player.get_node("Camera2D") as Camera2D
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 640
		cam.limit_bottom = 448


func _setup_encounters() -> void:
	var memory_bloom := load(MEMORY_BLOOM_PATH) as Resource
	var creeping_vine := load(CREEPING_VINE_PATH) as Resource
	var echo_nomad := load(ECHO_NOMAD_PATH) as Resource
	var pool := OvergrownCapitalEncounters.build_pool(memory_bloom, creeping_vine, echo_nomad)
	_encounter_system.setup(pool)


func _on_exit_to_ruins_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	GameManager.change_scene(SP.OVERGROWN_RUINS, GameManager.FADE_DURATION, "spawn_from_capital")
