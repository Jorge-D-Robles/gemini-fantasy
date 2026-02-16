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

# Ground layer — 8 grass variants from A5_A row 0
const GROUND_LEGEND: Dictionary = {
	"G": Vector2i(0, 0), "g": Vector2i(1, 0),
	"H": Vector2i(2, 0), "h": Vector2i(3, 0),
	"I": Vector2i(4, 0), "i": Vector2i(5, 0),
	"J": Vector2i(6, 0), "j": Vector2i(7, 0),
}

# Tree layer — 8 dense vegetation variants from A5_A rows 8-9
const TREE_LEGEND: Dictionary = {
	"T": Vector2i(0, 8), "t": Vector2i(1, 8),
	"U": Vector2i(2, 8), "u": Vector2i(3, 8),
	"V": Vector2i(4, 8), "v": Vector2i(5, 8),
	"W": Vector2i(6, 8), "w": Vector2i(7, 8),
}

# Path layer — 6 path/stone variants from A5_A rows 4-5
const PATH_LEGEND: Dictionary = {
	"P": Vector2i(0, 4), "p": Vector2i(1, 4),
	"Q": Vector2i(2, 4), "q": Vector2i(3, 4),
	"R": Vector2i(4, 4), "r": Vector2i(5, 4),
}

# Detail layer — flower/foliage accents from A5_A row 14
const DETAIL_LEGEND: Dictionary = {
	"f": Vector2i(0, 14), "F": Vector2i(1, 14),
	"b": Vector2i(2, 14), "B": Vector2i(3, 14),
}

# 40 cols x 24 rows — 8 tile variants, block-rotated for variety
const GROUND_MAP: Array[String] = [
	"GhIjgHiJjIgHhJGiHigjGIhJgJhIiGjHIjGhHgiJ",
	"hGjIJiHgiHgJjGhIGhIjgHiJJihGgIjHgJhIiGjH",
	"gJhIiGjHIjGhHgiJhGjIJiHgGhIjgHiJjIgHhJGi",
	"jIgHhJGiJihGgIjHiHgJjGhIIjGhHgiJHigjGIhJ",
	"HigjGIhJGhIjgHiJgJhIiGjHhGjIJiHgJihGgIjH",
	"IjGhHgiJgJhIiGjHJihGgIjHjIgHhJGiGhIjgHiJ",
	"JihGgIjHHigjGIhJjIgHhJGiiHgJjGhIhGjIJiHg",
	"iHgJjGhIhGjIJiHgIjGhHgiJHigjGIhJgJhIiGjH",
	"GhIjgHiJgJhIiGjHJihGgIjHhGjIJiHgjIgHhJGi",
	"gJhIiGjHiHgJjGhIHigjGIhJGhIjgHiJIjGhHgiJ",
	"IjGhHgiJjIgHhJGiGhIjgHiJJihGgIjHiHgJjGhI",
	"HigjGIhJhGjIJiHggJhIiGjHjIgHhJGiGhIjgHiJ",
	"hGjIJiHgGhIjgHiJiHgJjGhIgJhIiGjHHigjGIhJ",
	"jIgHhJGiIjGhHgiJhGjIJiHgiHgJjGhIJihGgIjH",
	"iHgJjGhIJihGgIjHGhIjgHiJIjGhHgiJgJhIiGjH",
	"JihGgIjHgJhIiGjHjIgHhJGiHigjGIhJhGjIJiHg",
	"GhIjgHiJHigjGIhJIjGhHgiJJihGgIjHjIgHhJGi",
	"gJhIiGjHhGjIJiHgJihGgIjHGhIjgHiJiHgJjGhI",
	"IjGhHgiJGhIjgHiJgJhIiGjHjIgHhJGiHigjGIhJ",
	"iHgJjGhIjIgHhJGihGjIJiHggJhIiGjHGhIjgHiJ",
	"HigjGIhJiHgJjGhIJihGgIjHIjGhHgiJhGjIJiHg",
	"JihGgIjHIjGhHgiJHigjGIhJhGjIJiHggJhIiGjH",
	"hGjIJiHgJihGgIjHjIgHhJGiGhIjgHiJIjGhHgiJ",
	"jIgHhJGiHigjGIhJiHgJjGhIJihGgIjHGhIjgHiJ",
]

# Organic forest borders — dense edges with irregular clearing
# Rows 0-2: solid forest
# Rows 3-5: forest thins with gaps
# Rows 6-9: large clearing for Iris zone
# Rows 10-12: main east-west path (fully open)
# Rows 13-16: forest returns with scattered clusters
# Rows 17-23: solid forest
const TREE_MAP: Array[String] = [
	"TtUvWuVwTtUvWuVwTtUvWuVwTtUvWuVwTtUvWuVw",
	"wVuWvUtTwVuWvUtTwVuWvUtTwVuWvUtTwVuWvUtT",
	"UvTwUvTwUvTwUvTwUvTwUvTwUvTwUvTwUvTwUvTw",
	"tWuVtWuVtW  uVtW       uVtWuVtWuVtWuVtWu",
	"TtUvWuVwTt    WuV          wTtUvWuVwTtUv",
	"wVuW  Vw      Wu            uWvUtTwVuWvU",
	"UvTw                                UvTw",
	"tW                                    Wu",
	"Uv                                    Tw",
	"wV                                    Ut",
	"                                        ",
	"                                        ",
	"                                        ",
	"wVuW        vU              Uw      WvUt",
	"UvTwUv        TwUv     UvTw     UvTwUvTw",
	"tWuVtWuVtW      VtWuVtWuVtWuVtW  VtWuVtW",
	"TtUvWuVwTtUv      TtUvWuVwTtUvWuVwTtUvWu",
	"wVuWvUtTwVuWvUtTwVuWvUtTwVuWvUtTwVuWvUtT",
	"UvTwUvTwUvTwUvTwUvTwUvTwUvTwUvTwUvTwUvTw",
	"tWuVtWuVtWuVtWuVtWuVtWuVtWuVtWuVtWuVtWuV",
	"TtUvWuVwTtUvWuVwTtUvWuVwTtUvWuVwTtUvWuVw",
	"wVuWvUtTwVuWvUtTwVuWvUtTwVuWvUtTwVuWvUtT",
	"UvTwUvTwUvTwUvTwUvTwUvTwUvTwUvTwUvTwUvTw",
	"tWuVtWuVtWuVtWuVtWuVtWuVtWuVtWuVtWuVtWuV",
]

# Meandering path — stub up to Iris zone, main east-west route
const PATH_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                   Pq                   ",
	"                   pR                   ",
	"                  QpRq                  ",
	"                 PqRpQr                 ",
	"    PqRpQrPqRpQrPqRpQrPqRpQrPqRpQrPqRp  ",
	"    qRpQrPqRpQrPqRpQrPqRpQrPqRpQrPqRpQ  ",
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
	"                                        ",
]

# Sparse flower accents in open areas (~5% coverage)
const DETAIL_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"            f         B                 ",
	"                                        ",
	"        f                          F    ",
	"                    b                   ",
	"                                        ",
	"                                        ",
	"                                        ",
	"        F                          b    ",
	"              f            b            ",
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
	_encounter_system.enabled = false
	_iris_zone.monitoring = false
	_iris_event.trigger()
	await _iris_event.sequence_completed
	_encounter_system.enabled = true


func _on_encounter_triggered(enemy_group: Array[Resource]) -> void:
	BattleManager.start_battle(enemy_group)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [MapBuilder.FAIRY_FOREST_A5_A]
	var solid: Dictionary = {
		0: [
			Vector2i(0, 8), Vector2i(1, 8), Vector2i(2, 8), Vector2i(3, 8),
			Vector2i(4, 8), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8),
			Vector2i(0, 9), Vector2i(1, 9), Vector2i(2, 9), Vector2i(3, 9),
			Vector2i(4, 9), Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9),
		],
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
		_ground_detail_layer, DETAIL_MAP, DETAIL_LEGEND
	)
	MapBuilder.build_layer(_trees_layer, TREE_MAP, TREE_LEGEND)
	MapBuilder.build_layer(_paths_layer, PATH_MAP, PATH_LEGEND)
