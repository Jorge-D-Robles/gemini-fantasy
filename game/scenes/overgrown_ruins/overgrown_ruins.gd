extends Node2D

## Overgrown Ruins — the game's starting area.
## Kael explores ancient ruins and discovers Lyra (opening cutscene).
## Contains random encounters (Memory Blooms, Creeping Vines) and
## an exit to the Verdant Forest.

const VERDANT_FOREST_PATH: String = "res://scenes/verdant_forest/verdant_forest.tscn"
const MEMORY_BLOOM_PATH: String = "res://data/enemies/memory_bloom.tres"
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const LAST_GARDENER_PATH: String = "res://data/enemies/last_gardener.tres"
const KAEL_DATA_PATH: String = "res://data/characters/kael.tres"

# Source 0: FAIRY_FOREST_A5_A (opaque ground tiles)
# Source 1: RUINS_A5 (ruins2 — opaque golden walls)
# Source 2: OVERGROWN_RUINS_OBJECTS (B-sheet — objects)

# Ground layer — gray stone fill (fairy forest source 0, row 10 = opaque)
const GROUND_LEGEND: Dictionary = {
	"F": Vector2i(0, 10),  # Gray stone floor (confirmed opaque)
}

# Ground detail — ornate golden floor (ruins2 source 1)
const DETAIL_LEGEND: Dictionary = {
	"O": Vector2i(0, 2),   # Ornate golden floor tile
}

# Ground debris — small rubble from B-sheet (source 2, on GroundDetail)
const DEBRIS_LEGEND: Dictionary = {
	"p": Vector2i(0, 2),   # Small pebbles
	"r": Vector2i(1, 2),   # Scattered rocks
}

# Wall layer — structural walls (ruins2 source 1)
const WALL_LEGEND: Dictionary = {
	"W": Vector2i(0, 4),   # Golden Egyptian wall (opaque)
	"G": Vector2i(0, 8),   # Dark ornamental border (opaque)
}

# Objects layer — B-sheet ruins objects (source 2)
const OBJECTS_LEGEND: Dictionary = {
	"a": Vector2i(2, 0),   # Carved stone block
	"b": Vector2i(0, 4),   # Green bush
	"c": Vector2i(4, 0),   # Dark carved ornament
	"d": Vector2i(0, 0),   # Stone rubble
	"e": Vector2i(1, 4),   # Green bush variant
	"f": Vector2i(3, 0),   # Small rubble piece
	"g": Vector2i(2, 4),   # Vine growth
	"h": Vector2i(3, 4),   # Moss patch
	"i": Vector2i(5, 0),   # Crumbled pillar
	"1": Vector2i(4, 2),   # Teal face top-left
	"2": Vector2i(5, 2),   # Teal face top-center
	"3": Vector2i(6, 2),   # Teal face top-right
	"4": Vector2i(4, 3),   # Teal face bottom-left
	"5": Vector2i(5, 3),   # Teal face bottom-center
	"6": Vector2i(6, 3),   # Teal face bottom-right
	"7": Vector2i(8, 2),   # Gold face top-left
	"8": Vector2i(9, 2),   # Gold face top-right
	"9": Vector2i(8, 3),   # Gold face bottom-left
	"0": Vector2i(9, 3),   # Gold face bottom-right
}

# 40 cols x 24 rows — uniform mossy stone fill (no empty tiles)
const GROUND_MAP: Array[String] = [
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
]

# Ornate golden floor accents — ruins2 decorative tiles in key areas
const DETAIL_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                 OOOOOOOOOOOO           ",
	"                 OOOOOOOOOOOO           ",
	"                 OOOOOOOOOOOO           ",
	"                 OOOOOOOOOOOO           ",
	"                                        ",
	"                                        ",
	"   OOO                           OO     ",
	"   OO                                   ",
	"                                 OO     ",
	"                                        ",
	"   OO                           OOO     ",
	"   OOOO                          OO     ",
	"                                        ",
	"  OOOO                           OO     ",
	"  OO                                    ",
	"                                        ",
	"                                        ",
	"  OO                             OOO    ",
	"   OOO                           OO     ",
	"                                        ",
	"                                        ",
]

# Small scattered debris from B-sheet (on GroundDetail layer)
const DEBRIS_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                  r        p            ",
	"                      p        r        ",
	"                                        ",
	"                  p        r            ",
	"                                        ",
	"                                        ",
	"       p                           r    ",
	"               r           p            ",
	"         p                       r      ",
	"     r                 p                ",
	"               p           r            ",
	"       r                           p    ",
	"                                        ",
	"     p                           r      ",
	"                                        ",
	"             p                r         ",
	"                                        ",
	"     r                           p      ",
	"          p                r            ",
	"                                        ",
	"                                        ",
]

# Sacred Chamber (north), Main Corridor (center), South Gallery
const WALL_MAP: Array[String] = [
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
	"WWWWWWWWWWWWWWWWGG            GGWWWWWWWW",
	"WWWWWWWWWWWWWWWWG              GWWWWWWWW",
	"WWWWWWWWWWWWWWWWG              GWWWWWWWW",
	"WWWWWWWWWWWWWWWWG              GWWWWWWWW",
	"WWWWWWWWWWWWWWWWG              GWWWWWWWW",
	"WWWWWWWWWWWWWWWWGG            GGWWWWWWWW",
	"WWWWWWWWWWWWWWWWWWWW      WWWWWWWWWWWWWW",
	"WW        WWWWWWWWWW      WWWWWWWWWWWWWW",
	"WW                                  WWWW",
	"WW                                    WW",
	"WW                                    WW",
	"WW                                  WWWW",
	"WW        WWWWWWWWWW      WWWWWWWWWWWWWW",
	"WWWW    WWWWWWWWWWWWWW  WWWWWWWWWW  WWWW",
	"WW                                    WW",
	"WW          WW              WW        WW",
	"WW                                    WW",
	"WW          WW              WW        WW",
	"WW                                    WW",
	"WW                                    WW",
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
]

# B-sheet objects: face statues, stone blocks, bushes, vegetation (source 1)
const OBJECTS_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                  d    123    f         ",
	"                       456              ",
	"                  f              d      ",
	"                       a                ",
	"                                        ",
	"                                        ",
	"     d  f                         f d   ",
	"   b       e                  e    b    ",
	"      f                          f      ",
	"                   f                    ",
	"   e       b                  b    e    ",
	"     d  f                         f d   ",
	"                                        ",
	"   b  f                             e   ",
	"         a    e             h    f      ",
	"      d          78       b      g      ",
	"            f    90    c          d     ",
	"   e     b                    i         ",
	"   b  f    d               e     f  d   ",
	"                                        ",
	"                                        ",
]

@onready var _ground_layer: TileMapLayer = $Ground
@onready var _ground_detail_layer: TileMapLayer = $GroundDetail
@onready var _walls_layer: TileMapLayer = $Walls
@onready var _objects_layer: TileMapLayer = $Objects
@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_point: Marker2D = $Entities/SpawnPoint
@onready var _encounter_system: EncounterSystem = $EncounterSystem
@onready var _opening_sequence: OpeningSequence = $OpeningSequence
@onready var _exit_to_forest: Area2D = $Triggers/ExitToForest
@onready var _lyra_zone: Area2D = $Triggers/LyraDiscoveryZone
@onready var _spawn_from_forest: Marker2D = $Entities/SpawnFromForest
@onready var _boss_zone: Area2D = $Triggers/BossZone
@onready var _boss_encounter: BossEncounter = $BossEncounter


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
	_boss_zone.body_entered.connect(_on_boss_zone_entered)

	# Hide Lyra discovery zone if already triggered
	if EventFlags.has_flag(OpeningSequence.FLAG_NAME):
		_lyra_zone.monitoring = false

	# Hide boss zone if already defeated
	if EventFlags.has_flag(BossEncounter.FLAG_NAME):
		_boss_zone.monitoring = false

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
		[_ground_layer, _ground_detail_layer, _walls_layer,
		_objects_layer] as Array[TileMapLayer],
		atlas_paths,
		solid,
	)
	MapBuilder.build_layer(_ground_layer, GROUND_MAP, GROUND_LEGEND, 0)
	MapBuilder.build_layer(
		_ground_detail_layer, DETAIL_MAP, DETAIL_LEGEND, 1
	)
	MapBuilder.build_layer(
		_ground_detail_layer, DEBRIS_MAP, DEBRIS_LEGEND, 2
	)
	MapBuilder.build_layer(_walls_layer, WALL_MAP, WALL_LEGEND, 1)
	MapBuilder.build_layer(
		_objects_layer, OBJECTS_MAP, OBJECTS_LEGEND, 2
	)


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
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	GameManager.change_scene(
		VERDANT_FOREST_PATH,
		GameManager.FADE_DURATION,
		"spawn_from_forest",
	)


func _on_lyra_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if EventFlags.has_flag(OpeningSequence.FLAG_NAME):
		return
	if BattleManager.is_in_battle():
		return
	if DialogueManager.is_active():
		return
	if GameManager.is_transitioning():
		return
	_encounter_system.enabled = false
	_lyra_zone.monitoring = false
	_opening_sequence.trigger()
	await _opening_sequence.sequence_completed
	_encounter_system.enabled = true


func _on_boss_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if EventFlags.has_flag(BossEncounter.FLAG_NAME):
		return
	if not EventFlags.has_flag(OpeningSequence.FLAG_NAME):
		return
	if BattleManager.is_in_battle():
		return
	if DialogueManager.is_active():
		return
	if GameManager.is_transitioning():
		return
	_encounter_system.enabled = false
	_boss_zone.monitoring = false
	_boss_encounter.trigger()


func _on_encounter_triggered(enemy_group: Array[Resource]) -> void:
	if GameManager.current_state != GameManager.GameState.OVERWORLD:
		return
	if DialogueManager.is_active():
		return
	BattleManager.start_battle(enemy_group)
