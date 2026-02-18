extends Node2D

## Verdant Forest — overworld area between Overgrown Ruins and Roothollow.
## Features random encounters, the Iris recruitment event, and
## scene transitions to both adjacent areas.

const OVERGROWN_RUINS_PATH: String = "res://scenes/overgrown_ruins/overgrown_ruins.tscn"
const ROOTHOLLOW_PATH: String = "res://scenes/roothollow/roothollow.tscn"
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const ASH_STALKER_PATH: String = "res://data/enemies/ash_stalker.tres"
const HOLLOW_SPECTER_PATH: String = "res://data/enemies/hollow_specter.tres"
const ANCIENT_SENTINEL_PATH: String = "res://data/enemies/ancient_sentinel.tres"
const GALE_HARPY_PATH: String = "res://data/enemies/gale_harpy.tres"
const EMBER_HOUND_PATH: String = "res://data/enemies/ember_hound.tres"

# Ground layer — bright green vegetation for lush forest floor
const GROUND_LEGEND: Dictionary = {
	"G": Vector2i(0, 8),   # Bright green (A5_A row 8)
}

# Tree layer — B-sheet canopy center tile for solid tree borders
const TREE_LEGEND: Dictionary = {
	"T": Vector2i(1, 1),   # Canopy center (B_forest, source 1)
}

# Path layer — single dirt path tile
const PATH_LEGEND: Dictionary = {
	"P": Vector2i(0, 4),   # Dirt path
}

# Detail layer — small foliage from FOREST_OBJECTS (source 1)
const DETAIL_LEGEND: Dictionary = {
	"g": Vector2i(0, 8),   # Small ground foliage
	"h": Vector2i(2, 8),   # Foliage variant
}

# Objects from STONE_OBJECTS — rocks and flowers in clearing
const ROCK_LEGEND: Dictionary = {
	"r": Vector2i(0, 0),   # Small rock
	"R": Vector2i(1, 0),   # Rock variant
	"q": Vector2i(2, 0),   # Pebble cluster
	"F": Vector2i(0, 1),   # Orange flower
	"L": Vector2i(2, 1),   # Flower variant
}

# Above player canopy from FOREST_OBJECTS — solid green overhang
const ABOVE_LEGEND: Dictionary = {
	"A": Vector2i(1, 1),   # Solid green canopy (same tile as tree)
}

# 40 cols x 25 rows — uniform grass fill
const GROUND_MAP: Array[String] = [
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
]

# Organic forest borders — dense edges with irregular clearing
# Rows 0-2: solid forest
# Rows 3-5: forest thins with gaps
# Rows 6-9: large clearing for Iris zone
# Rows 10-12: main east-west path (fully open)
# Rows 13-16: forest returns with scattered clusters
# Rows 17-24: solid forest
const TREE_MAP: Array[String] = [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTT  TTTT       TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTT    TTT          TTTTTTTTTTTTT",
	"TTTT  TT      TT            TTTTTTTTTTTT",
	"TTTT                                TTTT",
	"TT                                    TT",
	"TT                                    TT",
	"TT                                    TT",
	"                                        ",
	"                                        ",
	"                                        ",
	"TTTT        TT              TT      TTTT",
	"TTTTTT        TTTT     TTTT     TTTTTTTT",
	"TTTTTTTTTT      TTTTTTTTTTTTTTT  TTTTTTT",
	"TTTTTTTTTTTT      TTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]

# Meandering path — stub up to Iris zone, main east-west route
const PATH_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                  PPP                   ",
	"                  PPPP                  ",
	"                 PPPPPP                 ",
	"                PPPPPPPP                ",
	"   PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP  ",
	"   PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP  ",
	"   PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP  ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Ground detail — sparse small foliage from FOREST_OBJECTS (source 1)
const DETAIL_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"            g                           ",
	"                                        ",
	"                         h              ",
	"                                        ",
	"        h                               ",
	"                                        ",
	"                                        ",
	"                    g                   ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Rocks and flowers scattered in clearing (STONE_OBJECTS, source 2)
const ROCK_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"        r           F                   ",
	"     F      R               r     L     ",
	"               q       F       R        ",
	"        r        L      R          F    ",
	"       F      q              L          ",
	" r                                    R ",
	"R          F                   L        ",
	"  q                  F                 r",
	"       r        L          R            ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Tree canopy overhang — solid green tiles one row inside tree border
# Creates depth: player walks UNDER these on the AbovePlayer layer
const ABOVE_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"          AA    AAA A                   ",
	"          AA A     AA                   ",
	"    AA         AA                       ",
	"    A                              A    ",
	"  A                                  A  ",
	"  A                                  A  ",
	"  A                                  A  ",
	"                                        ",
	"                                        ",
	"AAAA        AA              AA      AAAA",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

@onready var _ground_layer: TileMapLayer = $Ground
@onready var _ground_detail_layer: TileMapLayer = $GroundDetail
@onready var _trees_layer: TileMapLayer = $Trees
@onready var _paths_layer: TileMapLayer = $Paths
@onready var _objects_layer: TileMapLayer = $Objects
@onready var _above_player_layer: TileMapLayer = $AbovePlayer
@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_from_ruins: Marker2D = $Entities/SpawnFromRuins
@onready var _spawn_from_town: Marker2D = $Entities/SpawnFromTown
@onready var _encounter_system: EncounterSystem = $EncounterSystem
@onready var _iris_event: IrisRecruitment = $IrisRecruitment
@onready var _exit_to_ruins: Area2D = $Triggers/ExitToRuins
@onready var _exit_to_town: Area2D = $Triggers/ExitToTown
@onready var _iris_zone: Area2D = $Triggers/IrisEventZone


func _ready() -> void:
	_setup_tilemap()

	# Set HUD location name
	UILayer.hud.location_name = "Verdant Forest"

	# Add spawn points to groups so GameManager.change_scene can find them
	_spawn_from_ruins.add_to_group("spawn_from_ruins")
	_spawn_from_town.add_to_group("spawn_from_town")

	# Connect trigger areas
	_exit_to_ruins.body_entered.connect(_on_exit_to_ruins_entered)
	_exit_to_town.body_entered.connect(_on_exit_to_town_entered)
	_iris_zone.body_entered.connect(_on_iris_zone_entered)

	# Setup encounter system
	var creeping_vine := load(CREEPING_VINE_PATH) as Resource
	var ash_stalker := load(ASH_STALKER_PATH) as Resource
	var hollow_specter := load(HOLLOW_SPECTER_PATH) as Resource
	var ancient_sentinel := load(ANCIENT_SENTINEL_PATH) as Resource
	var gale_harpy := load(GALE_HARPY_PATH) as Resource
	var ember_hound := load(EMBER_HOUND_PATH) as Resource

	var pool: Array[EncounterPoolEntry] = []
	# Common encounters — basic forest enemies
	if creeping_vine:
		pool.append(EncounterPoolEntry.create([creeping_vine] as Array[Resource], 2.0))
		pool.append(EncounterPoolEntry.create([creeping_vine, creeping_vine] as Array[Resource], 1.5))
	if ash_stalker:
		pool.append(EncounterPoolEntry.create([ash_stalker] as Array[Resource], 2.0))
	if hollow_specter:
		pool.append(EncounterPoolEntry.create([hollow_specter] as Array[Resource], 1.5))
		pool.append(EncounterPoolEntry.create([hollow_specter, hollow_specter] as Array[Resource], 0.8))
	if ancient_sentinel:
		pool.append(EncounterPoolEntry.create([ancient_sentinel] as Array[Resource], 1.0))
	# Mixed encounters
	if creeping_vine and ash_stalker:
		pool.append(EncounterPoolEntry.create([creeping_vine, ash_stalker] as Array[Resource], 1.0))
	if hollow_specter and creeping_vine:
		pool.append(EncounterPoolEntry.create([hollow_specter, creeping_vine] as Array[Resource], 1.0))
	# Uncommon encounters — mid-tier enemies
	if gale_harpy:
		pool.append(EncounterPoolEntry.create([gale_harpy] as Array[Resource], 0.8))
	if ember_hound:
		pool.append(EncounterPoolEntry.create([ember_hound] as Array[Resource], 0.8))
	if gale_harpy and ember_hound:
		pool.append(EncounterPoolEntry.create([gale_harpy, ember_hound] as Array[Resource], 0.4))

	_encounter_system.setup(pool)
	_encounter_system.encounter_triggered.connect(_on_encounter_triggered)

	# Hide Iris event zone if already recruited
	if EventFlags.has_flag(IrisRecruitment.FLAG_NAME):
		_iris_zone.monitoring = false



func _on_exit_to_ruins_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	GameManager.change_scene(
		OVERGROWN_RUINS_PATH,
		GameManager.FADE_DURATION,
		"spawn_from_forest",
	)


func _on_exit_to_town_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	GameManager.change_scene(
		ROOTHOLLOW_PATH,
		GameManager.FADE_DURATION,
		"spawn_from_forest",
	)


func _on_iris_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if EventFlags.has_flag(IrisRecruitment.FLAG_NAME):
		return
	if BattleManager.is_in_battle():
		return
	if DialogueManager.is_active():
		return
	_encounter_system.enabled = false
	_iris_zone.monitoring = false
	_iris_event.trigger()
	await _iris_event.sequence_completed
	_encounter_system.enabled = true


func _on_encounter_triggered(enemy_group: Array[Resource]) -> void:
	if GameManager.current_state != GameManager.GameState.OVERWORLD:
		return
	if DialogueManager.is_active():
		return
	BattleManager.start_battle(enemy_group)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.FAIRY_FOREST_A5_A,   # source 0 — ground, path, detail
		MapBuilder.FOREST_OBJECTS,       # source 1 — tree canopy, bushes
		MapBuilder.STONE_OBJECTS,        # source 2 — rocks, flowers
		MapBuilder.TREE_OBJECTS,         # source 3 — pine trees, dead trees
	]
	var solid: Dictionary = {
		1: [Vector2i(1, 1)],   # B_forest canopy center — blocking
	}
	MapBuilder.apply_tileset(
		[_ground_layer, _ground_detail_layer, _trees_layer,
		_paths_layer, _objects_layer, _above_player_layer,
		] as Array[TileMapLayer],
		atlas_paths,
		solid,
	)
	MapBuilder.build_layer(_ground_layer, GROUND_MAP, GROUND_LEGEND)
	MapBuilder.build_layer(
		_ground_detail_layer, DETAIL_MAP, DETAIL_LEGEND, 1
	)
	MapBuilder.build_layer(_trees_layer, TREE_MAP, TREE_LEGEND, 1)
	MapBuilder.build_layer(_paths_layer, PATH_MAP, PATH_LEGEND)
	MapBuilder.build_layer(_objects_layer, ROCK_MAP, ROCK_LEGEND, 2)
	MapBuilder.build_layer(
		_above_player_layer, ABOVE_MAP, ABOVE_LEGEND, 1
	)
