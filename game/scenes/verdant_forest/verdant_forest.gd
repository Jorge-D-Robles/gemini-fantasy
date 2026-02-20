extends Node2D

## Verdant Forest — overworld area between Overgrown Ruins and Roothollow.
## Features random encounters, the Iris recruitment event, and
## scene transitions to both adjacent areas.

const SP = preload("res://systems/scene_paths.gd")
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const ASH_STALKER_PATH: String = "res://data/enemies/ash_stalker.tres"
const HOLLOW_SPECTER_PATH: String = "res://data/enemies/hollow_specter.tres"
const ANCIENT_SENTINEL_PATH: String = "res://data/enemies/ancient_sentinel.tres"
const GALE_HARPY_PATH: String = "res://data/enemies/gale_harpy.tres"
const EMBER_HOUND_PATH: String = "res://data/enemies/ember_hound.tres"
const SCENE_BGM_PATH: String = "res://assets/music/Overgrown Memories.ogg"

# ---------- TILE LEGENDS ----------

# Ground layer — organic multi-terrain patches (A5_A, source 0)
# G = bright green vegetation (dominant ~50%), open clearings
# g = muted green variant (row 9), adds variety without seam artifacts
# D = dirt/earth (20%), flanking paths, around tree trunk bases
# E = dark earth/roots (15%), under dense forest canopy, transition zones
const GROUND_LEGEND: Dictionary = {
	"G": Vector2i(0, 8),
	"g": Vector2i(0, 9),
	"D": Vector2i(0, 2),
	"E": Vector2i(0, 6),
}

# Path layer — single dirt path tile (A5_A row 4, source 0)
const PATH_LEGEND: Dictionary = {
	"P": Vector2i(0, 4),
}

# Dense forest fill — canopy center for impenetrable borders
# (FOREST_OBJECTS, source 1)
const TREE_LEGEND: Dictionary = {
	"T": Vector2i(1, 1),
}

# Individual tree trunks — 4 variants (FOREST_OBJECTS, source 1)
# Placed in clearings and transition zones for distinct silhouettes
const TRUNK_LEGEND: Dictionary = {
	"A": Vector2i(8, 7),   # Tree type A — trunk base
	"B": Vector2i(10, 7),  # Tree type B — trunk base variant
	"C": Vector2i(8, 5),   # Tree type C — trunk mid-segment
	"D": Vector2i(10, 5),  # Tree type D — trunk mid-segment variant
}

# Tree canopies — 8 types x 4 tiles each (FOREST_OBJECTS, source 1)
# Rows 0-1: Types A-D (darker, rounder canopies)
# Rows 2-3: Types E-H (lighter, rounder canopy variants)
# Each 2x2 canopy sits 2 rows above its trunk on AbovePlayer layer.
const CANOPY_LEGEND: Dictionary = {
	# Type A canopy (2x2) — round dark-edged crown
	"1": Vector2i(0, 0),   # top-left
	"2": Vector2i(1, 0),   # top-right
	"3": Vector2i(0, 1),   # bottom-left
	"4": Vector2i(1, 1),   # bottom-right
	# Type B canopy (2x2) — broad crown variant
	"5": Vector2i(2, 0),
	"6": Vector2i(3, 0),
	"7": Vector2i(2, 1),
	"8": Vector2i(3, 1),
	# Type C canopy (2x2) — wide spread crown
	"a": Vector2i(4, 0),
	"b": Vector2i(5, 0),
	"c": Vector2i(4, 1),
	"d": Vector2i(5, 1),
	# Type D canopy (2x2) — dense leaf cluster
	"e": Vector2i(6, 0),
	"f": Vector2i(7, 0),
	"g": Vector2i(6, 1),
	"h": Vector2i(7, 1),
	# Type E canopy (2x2) — lighter round crown (rows 2-3)
	"i": Vector2i(0, 2),
	"j": Vector2i(1, 2),
	"k": Vector2i(0, 3),
	"l": Vector2i(1, 3),
	# Type F canopy (2x2) — lighter broad crown
	"m": Vector2i(2, 2),
	"n": Vector2i(3, 2),
	"o": Vector2i(2, 3),
	"p": Vector2i(3, 3),
	# Type G canopy (2x2) — lighter spread crown
	"q": Vector2i(4, 2),
	"r": Vector2i(5, 2),
	"s": Vector2i(4, 3),
	"t": Vector2i(5, 3),
	# Type H canopy (2x2) — lighter dense cluster
	"u": Vector2i(6, 2),
	"v": Vector2i(7, 2),
	"w": Vector2i(6, 3),
	"x": Vector2i(7, 3),
}

# Ground detail — rocks, flowers, leaves (STONE_OBJECTS, source 2)
const DETAIL_LEGEND: Dictionary = {
	"r": Vector2i(0, 0),   # Small rock
	"R": Vector2i(1, 0),   # Rock variant
	"s": Vector2i(2, 0),   # Pebble cluster
	"f": Vector2i(0, 1),   # Orange flower
	"F": Vector2i(2, 1),   # Flower variant
	"l": Vector2i(0, 2),   # Green leaf
	"L": Vector2i(1, 2),   # Green leaf variant
	"p": Vector2i(3, 0),   # Pebble variant
	"o": Vector2i(1, 1),   # Flower cluster
}

# ---------- MAP DATA (40 cols x 25 rows) ----------

# Ground: organic multi-terrain patches
# G = bright green vegetation, D = dirt/earth, E = dark earth/roots
# North/south forest edges = E, clearings = G, paths/dirt zones = D
const GROUND_MAP: Array[String] = [
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEGGEEEEEEEEGGGGGGGEEEGGEEEEEEEEE",
	"EEEEEEEGGGDGGGEEEGGGGGDGGGGGGGGGGEEEEEEE",
	"EEEEEEDGGGGGGGGDGGGGGGGGGGGDGGGGGDEEEEEE",
	"EEEEEGGGgGGGGGGGDDDDDDGGGGGGGGGgGGGGEEEE",
	"EEEEGGGGGGGGgGGGDDDDDDGGGGgGGGGGGGGGEEEE",
	"EEEEGDGGGGGGGGGGGDDDDDDGGGGGGGGGgDGGEEEE",
	"EEEEEGGDGGGEEEGDDDDDDGGGEEEEDGGGgGEEEEEE",
	"GDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDG",
	"GDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDG",
	"EEEEEGGDGGGEEEGGGGGGGGGGGGEEDGGGgGEEEEEE",
	"EEEEEEEGGGEEEEEGGEEEEGGEEEEEGGGEEEEEEEEE",
	"EEEEEEEEEDDEEEEEEEEEEEEEEEEEEDDEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEGGGGGGGGGGGGGGGGEEEEEEEEEEEE",
	"EEEEEEEEEEGGGgGGDDDDDDDDGGGGgGEEEEEEEEEE",
	"EEEEEEEEEGGGgGGDDDDDDDDGGGgGGEEEEEEEEEEE",
	"EEEEEEEEGGGgGGDDDDDDDDDDGGGgGGEEEEEEEEEE",
	"EEEEEEEEGGGGgGGGGGGgGGGGGgGGGGEEEEEEEEEE",
	"EEEEEEEEEEGGGGgGGGGgGGGGGEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
]

# Dense forest borders with organic clearing and chokepoint exits
# Rows 0-2:  solid forest wall (north border)
# Rows 3-4:  forest thins — scattered gaps appear
# Rows 5-8:  clearing for Iris zone — open interior, tree edges
# Row 9:     scattered tree clusters below clearing
# Rows 10-11: main east-west corridor (fully open, passage to edges)
# Row 12:    scattered tree clusters above south forest
# Rows 13-14: forest returns, dense transition
# Rows 15-24: solid forest wall (south border)
const TREE_MAP: Array[String] = [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTT  TT  TTTT       TTT  TTTTTTTTT",
	"TTTTTTT        TT                TTTTTTT",
	"TTTTT                              TTTTT",
	"TTTTT                               TTTT",
	"TTTT                                TTTT",
	"TTTT                                TTTT",
	"TTTTT       TT            TT       TTTTT",
	"                                        ",
	"                                        ",
	"TTTTT       TT            TT       TTTTT",
	"TTTTTTT   TTTTT  TTTT  TTTTT   TTTTTTTTT",
	"TTTTTTTTT  TTTTTTTTTTTTTTTTTT  TTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTT  TTTTTTTTTTTTTTT  TTTTTTTTTTTT",
	"TTTTTTT   TTTTT  TTTT  TTTTT   TTTTTTTTT",
	"TTTTTT       TT            TT       TTTT",
	"TTTT                                TTTT",
	"TTTTT                              TTTTT",
	"TTTTT       TT            TT       TTTTT",
	"TTTTTTT        TT                TTTTTTT",
	"TTTTTTTTT  TT  TTTT       TTT  TTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]

# Individual tree trunks at clearing edges (FOREST_OBJECTS, source 1)
# 4 variants (A-D) for visual variety. Collision blocks player.
# Vertical alignment: trunk row Y sits below canopy rows Y-2, Y-1.
const TRUNK_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"  A    B    C    D    A    B    C    D  ",
	"    B         D              A     C    ",
	"           A           C                ",
	"      A         B           D     C     ",
	"                                        ",
	"                      A                 ",
	"      B                           D     ",
	"        B                    C          ",
	"                                        ",
	"                                        ",
	"        B                    D          ",
	"                                        ",
	"          A                   C         ",
	"                                        ",
	"                                        ",
	"   B       C    D       A        B      ",
	"     D   A          B         C         ",
	"            A         D         B       ",
	"              C           A             ",
	"        D          B                    ",
	"          A              C              ",
	"    D           B          A       C    ",
	"                                        ",
]

# Tree canopies on AbovePlayer — 4 types (FOREST_OBJECTS, source 1)
# Each 2x2 canopy sits 1-2 rows above its trunk position.
# Player walks under these for depth effect.
const CANOPY_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"          12          ab                ",
	"     12   34   56     cd   ef    ab     ",
	"     34        78          gh    cd     ",
	"                     12                 ",
	"     56              34          ef     ",
	"     7856                   ab   gh     ",
	"       78                   cd          ",
	"                                        ",
	"       56                   ef          ",
	"       78                   gh          ",
	"         12                  ab         ",
	"         34                  cd         ",
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

# Dirt path — branches from corridor up to Iris clearing
const PATH_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                  PP                    ",
	"                  PPP                   ",
	"                 PPPP                   ",
	"                PPPPP                   ",
	" PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP ",
	" PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP ",
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
	"                                        ",
]

# Ground detail — scattered rocks, flowers, leaves (STONE_OBJECTS, source 2)
# ~72 tiles for ~23% coverage in open areas — dense in clearings, sparse near edges
const DETAIL_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                    l  r     l          ",
	"        F   r     l  f   R  l F         ",
	"       f R  l F   r  f  p l   o r       ",
	"      l f R  p l      F r  f l o R      ",
	"     r F  l s f         L r F  p l      ",
	"        f R l o        s F  l r f       ",
	"      r   l           F pl     r f      ",
	"                                        ",
	"                                        ",
	"      l   F    r f  p l Ro     f s      ",
	"        r      l      f      R          ",
	"         l                              ",
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

# ---------- NODE REFERENCES ----------

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
	# Force z_index at runtime — .tscn value may be stale in editor cache.
	# Push walkable layers below z=0 so Entities (z=1) always renders on top.
	$Objects.z_index = -1
	$Entities.z_index = 1
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 400)
	_start_scene_music()

	# Set HUD location name
	UILayer.hud.location_name = "Verdant Forest"

	# Add spawn points to groups so GameManager.change_scene can find them
	_spawn_from_ruins.add_to_group("spawn_from_ruins")
	_spawn_from_town.add_to_group("spawn_from_town")

	# Connect trigger areas
	_exit_to_ruins.body_entered.connect(_on_exit_to_ruins_entered)
	_exit_to_town.body_entered.connect(_on_exit_to_town_entered)
	_iris_zone.body_entered.connect(_on_iris_zone_entered)

	# Zone transition markers
	_spawn_zone_markers()

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

	# Companion followers
	var player_node := get_tree().get_first_node_in_group(
		"player",
	) as Node2D
	if player_node:
		var companion_ctrl := CompanionController.new()
		companion_ctrl.setup(player_node)
		$Entities.add_child(companion_ctrl)


func _spawn_zone_markers() -> void:
	var left_marker := ZoneMarker.new()
	left_marker.direction = ZoneMarker.Direction.LEFT
	left_marker.destination_name = "Overgrown Ruins"
	left_marker.position = (
		_exit_to_ruins.position + Vector2(12, 0)
	)
	add_child(left_marker)

	var right_marker := ZoneMarker.new()
	right_marker.direction = ZoneMarker.Direction.RIGHT
	right_marker.destination_name = "Roothollow"
	right_marker.position = (
		_exit_to_town.position + Vector2(-12, 0)
	)
	add_child(right_marker)


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
		SP.OVERGROWN_RUINS,
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
		SP.ROOTHOLLOW,
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


func _start_scene_music() -> void:
	var bgm := load(SCENE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 1.5)
	else:
		push_warning("Scene BGM not found: " + SCENE_BGM_PATH)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.FAIRY_FOREST_A5_A,   # source 0 — ground, path
		MapBuilder.FOREST_OBJECTS,       # source 1 — trees, trunks, canopies
		MapBuilder.STONE_OBJECTS,        # source 2 — detail: rocks, flowers
		MapBuilder.TREE_OBJECTS,         # source 3 — reserved for pine trees
	]
	var solid: Dictionary = {
		1: [
			Vector2i(1, 1),    # Dense canopy fill (tree borders)
			Vector2i(8, 7),    # Tree A trunk base
			Vector2i(10, 7),   # Tree B trunk base
			Vector2i(8, 5),    # Tree C trunk segment
			Vector2i(10, 5),   # Tree D trunk segment
		],
	}
	MapBuilder.apply_tileset(
		[_ground_layer, _ground_detail_layer, _trees_layer,
		_paths_layer, _objects_layer, _above_player_layer,
		] as Array[TileMapLayer],
		atlas_paths,
		solid,
	)
	# Ground: organic multi-terrain patches (source 0)
	MapBuilder.build_layer(_ground_layer, GROUND_MAP, GROUND_LEGEND)
	# Paths: dirt path overlay (source 0)
	MapBuilder.build_layer(_paths_layer, PATH_MAP, PATH_LEGEND)
	# Trees: dense canopy fill for impenetrable borders (source 1)
	MapBuilder.build_layer(_trees_layer, TREE_MAP, TREE_LEGEND, 1)
	# Objects: individual tree trunks with collision (source 1)
	MapBuilder.build_layer(_objects_layer, TRUNK_MAP, TRUNK_LEGEND, 1)
	# Ground detail: scattered rocks and flowers (source 2)
	MapBuilder.build_layer(
		_ground_detail_layer, DETAIL_MAP, DETAIL_LEGEND, 2
	)
	# Above player: tree canopies for walk-under depth (source 1)
	MapBuilder.build_layer(
		_above_player_layer, CANOPY_MAP, CANOPY_LEGEND, 1
	)
