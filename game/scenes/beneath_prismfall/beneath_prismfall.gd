extends Node2D

## Beneath Prismfall — Crystal Canyon dungeon.
## Act I climax: descent through crystal formations to the Warden's chamber.
## LyrasTruth event triggers after reaching the deep section.
## Random encounters with crystal_sentinel, resonance_wisp.
##
## Modules:
##   beneath_prismfall_map.gd        — tilemap data constants
##   beneath_prismfall_encounters.gd — encounter pool builder

const Maps = preload("beneath_prismfall_map.gd")
const SP = preload("res://systems/scene_paths.gd")
const CRYSTAL_SENTINEL_PATH: String = (
	"res://data/enemies/crystal_sentinel.tres"
)
const RESONANCE_WISP_PATH: String = (
	"res://data/enemies/resonance_wisp.tres"
)
const SCENE_BGM_PATH: String = (
	"res://assets/music/The Sea of Static.ogg"
)

@onready var _ground: TileMapLayer = $Ground
@onready var _ground_detail: TileMapLayer = $GroundDetail
@onready var _objects: TileMapLayer = $Objects
@onready var _above_player: TileMapLayer = $AbovePlayer
@onready var _exit_to_prismfall: Area2D = $Triggers/ExitToPrismfall
@onready var _encounter_system: EncounterSystem = $EncounterSystem


func _ready() -> void:
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 448)
	_start_scene_music()
	UILayer.hud.location_name = "Crystal Canyon"

	# Spawn points
	$Entities/SpawnFromPrismfall.add_to_group(
		"spawn_from_dungeon",
	)

	# Triggers
	_exit_to_prismfall.body_entered.connect(
		_on_exit_to_prismfall_entered,
	)

	# Zone markers
	_spawn_zone_markers()

	# Save point
	_spawn_save_point_marker()

	# Encounters
	var pool := BeneathPrismfallEncounters.build_pool(
		load(CRYSTAL_SENTINEL_PATH) as Resource,
		load(RESONANCE_WISP_PATH) as Resource,
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

	# Story event: Lyra's Truth on first deep descent
	_maybe_trigger_lyras_truth.call_deferred()


func _maybe_trigger_lyras_truth() -> void:
	var flags := EventFlags.get_all_flags()
	if not LyrasTruth.compute_can_trigger(flags):
		return
	var event := LyrasTruth.new()
	add_child(event)
	event.trigger()
	await event.sequence_completed
	event.queue_free()


func _start_scene_music() -> void:
	var bgm := load(SCENE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 1.0)
	else:
		push_warning(
			"Scene BGM not found: " + SCENE_BGM_PATH,
		)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.TF_DUNGEON,       # source 0 — floor + walls
		MapBuilder.RUINS1_OBJECTS,   # source 1 — crystal pillars
		MapBuilder.STONE_OBJECTS,    # source 2 — rocks, detail
	]
	MapBuilder.apply_tileset(
		[
			_ground, _ground_detail,
			_objects, _above_player,
		] as Array[TileMapLayer],
		atlas_paths,
		Maps.SOLID_TILES,
	)

	# Ground — position-hashed floor/wall from GROUND_MAP
	_fill_ground_from_map(_ground)
	MapBuilder.disable_collision(_ground)

	# Detail scatter
	var detail_noise := FastNoiseLite.new()
	detail_noise.seed = Maps.FLOOR_HASH_SEED + 1
	detail_noise.frequency = 0.15
	MapBuilder.scatter_decorations(
		_ground_detail,
		Maps.COLS, Maps.ROWS,
		detail_noise, Maps.DETAIL_ENTRIES,
	)
	MapBuilder.disable_collision(_ground_detail)

	# Crystal objects (source 1)
	MapBuilder.build_layer(
		_objects, Maps.OBJECTS_MAP, Maps.OBJECTS_LEGEND, 1,
	)

	# Above-player (source 1)
	MapBuilder.build_layer(
		_above_player, Maps.ABOVE_MAP, Maps.ABOVE_LEGEND, 1,
	)
	MapBuilder.disable_collision(_above_player)


func _fill_ground_from_map(layer: TileMapLayer) -> void:
	for y: int in range(Maps.ROWS):
		var row: String = Maps.GROUND_MAP[y]
		for x: int in range(Maps.COLS):
			if row[x] == "W":
				var atlas: Vector2i = Maps.pick_wall_tile(x, y)
				layer.set_cell(Vector2i(x, y), 0, atlas)
			else:
				var atlas: Vector2i = Maps.pick_floor_tile(x, y)
				layer.set_cell(Vector2i(x, y), 0, atlas)
	layer.update_internals()


func _on_exit_to_prismfall_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	if DialogueManager.is_active():
		return
	if BattleManager.is_in_battle():
		return
	GameManager.change_scene(
		SP.PRISMFALL,
		GameManager.FADE_DURATION,
		"spawn_from_dungeon",
	)


func _on_encounter_warning() -> void:
	var tween := create_tween()
	tween.tween_property(
		self, "modulate", Color(1.3, 1.3, 0.9), 0.15,
	)
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func _on_encounter_triggered(
	enemy_group: Array[Resource],
) -> void:
	if GameManager.current_state != GameManager.GameState.OVERWORLD:
		return
	if DialogueManager.is_active():
		return
	BattleManager.start_battle(enemy_group)


func _spawn_zone_markers() -> void:
	var north_marker := ZoneMarker.new()
	north_marker.direction = ZoneMarker.Direction.UP
	north_marker.destination_name = "Prismfall"
	north_marker.position = (
		_exit_to_prismfall.position + Vector2(0, 12)
	)
	add_child(north_marker)


func _spawn_save_point_marker() -> void:
	var save_point: Node = $Entities/SavePoint
	if not save_point:
		return
	save_point.indicator_type = Interactable.IndicatorType.SAVE
	var marker := SavePointMarker.new()
	save_point.add_child(marker)
