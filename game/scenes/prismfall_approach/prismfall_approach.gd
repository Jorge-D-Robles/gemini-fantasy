extends Node2D

## Prismfall Approach — rocky Crystalline Steppes connecting Verdant Forest
## south toward the Prismfall canyon. Features random encounters along the
## cobbled steppe road.

const SP = preload("res://systems/scene_paths.gd")

const GALE_HARPY_PATH: String = "res://data/enemies/gale_harpy.tres"
const CINDER_WISP_PATH: String = "res://data/enemies/cinder_wisp.tres"
const HOLLOW_SPECTER_PATH: String = "res://data/enemies/hollow_specter.tres"
const ANCIENT_SENTINEL_PATH: String = "res://data/enemies/ancient_sentinel.tres"
const EMBER_HOUND_PATH: String = "res://data/enemies/ember_hound.tres"
const SCENE_BGM_PATH: String = "res://assets/music/Wandering Through Quiet Lands.ogg"

@onready var _ground_layer: TileMapLayer = $Ground
@onready var _ground_detail_layer: TileMapLayer = $GroundDetail
@onready var _paths_layer: TileMapLayer = $Paths
@onready var _spawn_from_forest: Marker2D = $Entities/SpawnFromForest
@onready var _encounter_system: EncounterSystem = $EncounterSystem
@onready var _exit_to_forest: Area2D = $Triggers/ExitToForest


func _ready() -> void:
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 384)
	_start_scene_music()

	UILayer.hud.location_name = "Crystalline Steppes"

	_spawn_from_forest.add_to_group("spawn_from_forest")
	$Entities/SpawnFromPrismfall.add_to_group("spawn_from_prismfall")

	_exit_to_forest.body_entered.connect(_on_exit_to_forest_entered)

	_spawn_zone_markers()

	var pool := PrismfallApproachEncounters.build_pool(
		load(GALE_HARPY_PATH) as Resource,
		load(CINDER_WISP_PATH) as Resource,
		load(HOLLOW_SPECTER_PATH) as Resource,
		load(ANCIENT_SENTINEL_PATH) as Resource,
		load(EMBER_HOUND_PATH) as Resource,
	)
	_encounter_system.setup(pool)
	_encounter_system.encounter_triggered.connect(_on_encounter_triggered)
	_encounter_system.encounter_warning.connect(_on_encounter_warning)

	var player_node := get_tree().get_first_node_in_group("player") as Node2D
	if player_node:
		var companion_ctrl := CompanionController.new()
		companion_ctrl.setup(player_node)
		$Entities.add_child(companion_ctrl)


func _spawn_zone_markers() -> void:
	var top_marker := ZoneMarker.new()
	top_marker.direction = ZoneMarker.Direction.UP
	top_marker.destination_name = "Verdant Forest"
	top_marker.position = _exit_to_forest.position + Vector2(0, 12)
	add_child(top_marker)


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
		SP.VERDANT_FOREST,
		GameManager.FADE_DURATION,
		"spawn_from_prismfall",
	)


func _on_encounter_warning() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.3, 1.3, 0.9), 0.15)
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


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
		MapBuilder.FAIRY_FOREST_A5_A,  # source 0 — ground, path
		MapBuilder.STONE_OBJECTS,      # source 1 — scattered rocks (detail)
	]
	MapBuilder.apply_tileset(
		[_ground_layer, _ground_detail_layer, _paths_layer] as Array[TileMapLayer],
		atlas_paths,
		{},
	)

	# Procedural ground — organic rocky steppe distribution
	var ground_noise := FastNoiseLite.new()
	ground_noise.seed = PrismfallApproachMap.GROUND_NOISE_SEED
	ground_noise.frequency = PrismfallApproachMap.GROUND_NOISE_FREQ
	ground_noise.fractal_octaves = PrismfallApproachMap.GROUND_NOISE_OCTAVES
	MapBuilder.build_noise_layer(
		_ground_layer,
		PrismfallApproachMap.COLS, PrismfallApproachMap.ROWS,
		ground_noise, PrismfallApproachMap.GROUND_ENTRIES,
	)
	MapBuilder.disable_collision(_ground_layer)

	# Procedural detail — scattered rock decorations (source 1)
	var detail_noise := FastNoiseLite.new()
	detail_noise.seed = PrismfallApproachMap.GROUND_NOISE_SEED + 1
	detail_noise.frequency = 0.15
	MapBuilder.scatter_decorations(
		_ground_detail_layer,
		PrismfallApproachMap.COLS, PrismfallApproachMap.ROWS,
		detail_noise, PrismfallApproachMap.DETAIL_ENTRIES,
	)
	MapBuilder.disable_collision(_ground_detail_layer)

	# Authored path — amber cobble road (structural)
	MapBuilder.build_layer(
		_paths_layer,
		PrismfallApproachMap.PATH_MAP,
		PrismfallApproachMap.PATH_LEGEND,
	)
	MapBuilder.disable_collision(_paths_layer)
