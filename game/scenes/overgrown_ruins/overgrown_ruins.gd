extends Node2D

## Overgrown Ruins — the game's starting area.
## Kael explores ancient ruins and discovers Lyra (opening cutscene).
## Contains random encounters (Memory Blooms, Creeping Vines) and
## an exit to the Verdant Forest.

const VERDANT_FOREST_PATH: String = "res://scenes/verdant_forest/verdant_forest.tscn"
const MEMORY_BLOOM_PATH: String = "res://data/enemies/memory_bloom.tres"
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const KAEL_DATA_PATH: String = "res://data/characters/kael.tres"

const GROUND_LEGEND: Dictionary = {
	"S": Vector2i(0, 0),   # Stone floor 1
	"s": Vector2i(1, 0),   # Stone floor 2
	"P": Vector2i(2, 0),   # Stone floor 3
	"p": Vector2i(3, 0),   # Stone floor 4
	"D": Vector2i(0, 2),   # Decorated floor 1
	"d": Vector2i(1, 2),   # Decorated floor 2
	"A": Vector2i(0, 14),  # Floor variant 1
	"a": Vector2i(1, 14),  # Floor variant 2
}

const WALL_LEGEND: Dictionary = {
	"W": Vector2i(0, 8),   # Dark wall 1
	"w": Vector2i(1, 8),   # Dark wall 2
	"X": Vector2i(2, 8),   # Dark wall 3
	"x": Vector2i(3, 8),   # Dark wall 4
	"G": Vector2i(0, 4),   # Gold wall 1
	"g": Vector2i(1, 4),   # Gold wall 2
	"H": Vector2i(2, 4),   # Gold wall 3
	"h": Vector2i(3, 4),   # Gold wall 4
}

const GROUND_MAP: Array[String] = [
	"SsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPp",
	"sSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPp",
	"PpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSs",
	"pSSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSs",
	"SsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPp",
	"sSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPp",
	"PpSsPpSsPpSsDdDdDdDdDdDdDdDdSsPpSsPpSsSs",
	"pSSsPpSsPpSsDdDdDdDdDdDdDdDdSsPpSsPpSsSs",
	"SsPpSsPpSsPpDdDdDdDdDdDdDdSsPpSsPpSsPpSs",
	"sSPpsSPpsSPpDdDdDdDdDdDdDdSsPpSsPpsSPpSs",
	"PpSsPpSsPpSsDdDdDdDdDdDdDdDdSsPpSsPpSsSs",
	"pSSsPpSsPpSsDdDdDdDdDdDdDdDdSsPpSsPpSsSs",
	"SsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPp",
	"sSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPp",
	"AaSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSs",
	"aASsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSs",
	"SsPpAaSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSs",
	"sSPpaASsPpSsPpSsPpSsPpSsPpSsPpSsPpsSPpSs",
	"PpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsSsSs",
	"pSSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsSsSs",
	"SsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPp",
	"sSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPpsSPp",
	"PpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsSsSs",
	"pSSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsPpSsSsSs",
]

const WALL_MAP: Array[String] = [
	"WwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXx",
	"WwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXx",
	"WwXx                                WwXx",
	"WwXx    WwXx       GgHhGgHhGgHh     WwXx",
	"WwXx    WwXx       Gh        gH     WwXx",
	"WwXx               Hg        hG     WwXx",
	"WwXx    WwXx       Gh        gH     WwXx",
	"WwXx    WwXx       GgHh    HhGg     WwXx",
	"WwXx                                WwXx",
	"WwXx                                WwXx",
	"WwXx                                    ",
	"WwXx                                    ",
	"WwXx                                    ",
	"WwXx                                    ",
	"WwXx                                WwXx",
	"WwXx    WwXxWwXxWw    WwXxWwXxWwXxWwWwXx",
	"WwXx          WwXx              WwXxWwXx",
	"WwXx          WwXx              WwXxWwXx",
	"WwXx          WwXx              WwXxWwXx",
	"WwXx          WwXx              WwXxWwXx",
	"WwXx                                WwXx",
	"WwXx                                WwXx",
	"WwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXx",
	"WwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXxWwXx",
]

@onready var _ground_layer: TileMapLayer = $Ground
@onready var _walls_layer: TileMapLayer = $Walls
@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_point: Marker2D = $Entities/SpawnPoint
@onready var _encounter_system: EncounterSystem = $EncounterSystem
@onready var _opening_sequence: OpeningSequence = $OpeningSequence
@onready var _exit_to_forest: Area2D = $Triggers/ExitToForest
@onready var _lyra_zone: Area2D = $Triggers/LyraDiscoveryZone
@onready var _spawn_from_forest: Marker2D = $Entities/SpawnFromForest


func _ready() -> void:
	_setup_tilemap()
	_setup_camera_limits()

	# Initialize Kael in party if not already there
	if PartyManager.get_roster().is_empty():
		var kael_data := load(KAEL_DATA_PATH) as Resource
		if kael_data:
			PartyManager.add_character(kael_data)

	# Place player at spawn if no spawn point group was set by GameManager
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node and player_node.global_position == Vector2.ZERO:
		player_node.global_position = _spawn_point.global_position

	# HUD setup
	UILayer.hud.location_name = "Overgrown Ruins"

	# Add spawn points to groups
	_spawn_from_forest.add_to_group("spawn_from_forest")

	# Connect triggers
	_exit_to_forest.body_entered.connect(_on_exit_to_forest_entered)
	_lyra_zone.body_entered.connect(_on_lyra_zone_entered)

	# Setup encounter system with ruins enemy pool
	var memory_bloom := load(MEMORY_BLOOM_PATH) as Resource
	var creeping_vine := load(CREEPING_VINE_PATH) as Resource

	var pool: Array[EncounterPoolEntry] = []
	if memory_bloom:
		pool.append(EncounterPoolEntry.create([memory_bloom] as Array[Resource], 3.0))
		pool.append(EncounterPoolEntry.create([memory_bloom, memory_bloom] as Array[Resource], 1.5))
	if creeping_vine:
		pool.append(EncounterPoolEntry.create([creeping_vine] as Array[Resource], 1.0))
		if memory_bloom:
			pool.append(EncounterPoolEntry.create([memory_bloom, creeping_vine] as Array[Resource], 1.0))

	_encounter_system.setup(pool)
	_encounter_system.encounter_triggered.connect(_on_encounter_triggered)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [MapBuilder.RUINS_A5]
	var solid: Dictionary = {
		0: [
			Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4),
			Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4),
			Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5),
			Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5), Vector2i(7, 5),
			Vector2i(0, 8), Vector2i(1, 8), Vector2i(2, 8), Vector2i(3, 8),
			Vector2i(4, 8), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8),
			Vector2i(0, 9), Vector2i(1, 9), Vector2i(2, 9), Vector2i(3, 9),
			Vector2i(4, 9), Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9),
		],
	}
	MapBuilder.apply_tileset(
		[_ground_layer, _walls_layer] as Array[TileMapLayer],
		atlas_paths,
		solid,
	)
	MapBuilder.build_layer(_ground_layer, GROUND_MAP, GROUND_LEGEND)
	MapBuilder.build_layer(_walls_layer, WALL_MAP, WALL_LEGEND)


func _setup_camera_limits() -> void:
	var cam: Camera2D = _player.get_node("Camera2D") as Camera2D
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 640
		cam.limit_bottom = 384


func _on_exit_to_forest_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	GameManager.change_scene(
		VERDANT_FOREST_PATH,
		GameManager.FADE_DURATION,
		"spawn_from_ruins",
	)


func _on_lyra_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if EventFlags.has_flag(OpeningSequence.FLAG_NAME):
		return
	_encounter_system.enabled = false
	_opening_sequence.trigger()
	await _opening_sequence.sequence_completed
	_encounter_system.enabled = true


func _on_encounter_triggered(enemy_group: Array[Resource]) -> void:
	BattleManager.start_battle(enemy_group)
