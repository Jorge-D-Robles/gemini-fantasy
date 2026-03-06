extends Node2D

## The Scorched Road — ancient highway through the Cindral Wastes.
## Route scene connecting Emberhearth north to future southern areas.
## Features volcanic terrain, ashlands rock borders, random encounters
## with Cindral Wastes enemies.
##
## Modules:
##   scorched_road_map.gd        — tilemap data constants
##   scorched_road_encounters.gd — encounter pool builder

const Maps = preload("scorched_road_map.gd")
const Enc = preload("scorched_road_encounters.gd")
const SP = preload("res://systems/scene_paths.gd")

const MAGMA_CRAWLER_PATH: String = (
	"res://data/enemies/magma_crawler.tres"
)
const LAVA_ELEMENTAL_PATH: String = (
	"res://data/enemies/lava_elemental.tres"
)
const ASH_STALKER_PATH: String = (
	"res://data/enemies/ash_stalker.tres"
)
const SCENE_BGM_PATH: String = (
	"res://assets/music/Three Burns Heavy.ogg"
)

@onready var _ground: TileMapLayer = $Ground
@onready var _ground_detail: TileMapLayer = $GroundDetail
@onready var _paths: TileMapLayer = $Paths
@onready var _objects: TileMapLayer = $Objects
@onready var _exit_to_emberhearth: Area2D = (
	$Triggers/ExitToEmberhearth
)
@onready var _exit_to_south: Area2D = $Triggers/ExitToSouth
@onready var _encounter_system: EncounterSystem = $EncounterSystem


func _ready() -> void:
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 384)
	_start_scene_music()
	UILayer.hud.location_name = "The Scorched Road"

	# Spawn points
	$Entities/SpawnFromEmberhearth.add_to_group(
		"spawn_from_emberhearth",
	)
	$Entities/SpawnFromSouth.add_to_group("spawn_from_south")

	# Connect exit triggers
	_exit_to_emberhearth.body_entered.connect(
		_on_exit_to_emberhearth_entered,
	)
	_exit_to_south.body_entered.connect(
		_on_exit_to_south_entered,
	)

	# Zone markers
	_spawn_zone_markers()

	# Encounter system
	var pool := Enc.build_pool(
		load(MAGMA_CRAWLER_PATH) as Resource,
		load(LAVA_ELEMENTAL_PATH) as Resource,
		load(ASH_STALKER_PATH) as Resource,
	)
	_encounter_system.setup(pool)
	_encounter_system.encounter_triggered.connect(
		_on_encounter_triggered,
	)
	_encounter_system.encounter_warning.connect(
		_on_encounter_warning,
	)

	# Companion followers
	var player_node := get_tree().get_first_node_in_group(
		"player",
	) as Node2D
	if player_node:
		var companion_ctrl := CompanionController.new()
		companion_ctrl.setup(player_node)
		$Entities.add_child(companion_ctrl)


func _spawn_zone_markers() -> void:
	var north_marker := ZoneMarker.new()
	north_marker.direction = ZoneMarker.Direction.UP
	north_marker.destination_name = "Emberhearth"
	north_marker.position = (
		_exit_to_emberhearth.position + Vector2(0, 12)
	)
	add_child(north_marker)

	var south_marker := ZoneMarker.new()
	south_marker.direction = ZoneMarker.Direction.DOWN
	south_marker.destination_name = "South"
	south_marker.position = (
		_exit_to_south.position + Vector2(0, -12)
	)
	add_child(south_marker)


func _on_exit_to_emberhearth_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	GameManager.change_scene(
		SP.EMBERHEARTH,
		GameManager.FADE_DURATION,
		"spawn_from_scorched_road",
	)


func _on_exit_to_south_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return


func _on_encounter_warning() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.3, 1.3, 0.9), 0.15)
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func _on_encounter_triggered(
	enemy_group: Array[Resource],
) -> void:
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
		MapBuilder.TF_TERRAIN,       # source 0 — ground, path
		MapBuilder.ASHLANDS_OBJECTS,  # source 1 — ashlands rocks
	]
	MapBuilder.apply_tileset(
		[
			_ground, _ground_detail, _paths, _objects,
		] as Array[TileMapLayer],
		atlas_paths,
		Maps.SOLID_TILES,
	)

	# Procedural ground — volcanic biome noise + position hash
	var ground_noise := FastNoiseLite.new()
	ground_noise.seed = Maps.GROUND_NOISE_SEED
	ground_noise.frequency = Maps.GROUND_NOISE_FREQ
	ground_noise.fractal_octaves = Maps.GROUND_NOISE_OCTAVES
	_fill_ground_with_variants(_ground, ground_noise)
	MapBuilder.disable_collision(_ground)

	# Ground detail — scattered ashlands rocks (source 1)
	var detail_noise := FastNoiseLite.new()
	detail_noise.seed = Maps.GROUND_NOISE_SEED + 1
	detail_noise.frequency = 0.15
	MapBuilder.scatter_decorations(
		_ground_detail, Maps.COLS, Maps.ROWS,
		detail_noise, Maps.DETAIL_ENTRIES,
	)
	MapBuilder.disable_collision(_ground_detail)

	# Path — sandy/tan road with position-hashed variety
	_fill_paths_with_variants(_paths)
	MapBuilder.disable_collision(_paths)

	# Border rocks — ashlands (source 1) with variants
	MapBuilder.fill_layer_with_variants(
		_objects, Maps.BORDER_MAP,
		Maps.BORDER_VARIANT_LEGEND, 1,
		Maps.BORDER_HASH_SEED,
	)


func _fill_ground_with_variants(
	layer: TileMapLayer,
	noise: FastNoiseLite,
) -> void:
	for y: int in range(Maps.ROWS):
		for x: int in range(Maps.COLS):
			var noise_val: float = noise.get_noise_2d(
				float(x), float(y),
			)
			var atlas: Vector2i = Maps.pick_tile(noise_val, x, y)
			layer.set_cell(Vector2i(x, y), 0, atlas)
	layer.update_internals()


func _fill_paths_with_variants(layer: TileMapLayer) -> void:
	for y: int in range(Maps.PATH_MAP.size()):
		var row: String = Maps.PATH_MAP[y]
		for x: int in range(row.length()):
			if row[x] == "P":
				var atlas: Vector2i = Maps.pick_path_tile(x, y)
				layer.set_cell(Vector2i(x, y), 0, atlas)
	layer.update_internals()
