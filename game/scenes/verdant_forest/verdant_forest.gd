extends Node2D

## Verdant Forest — overworld area between Overgrown Ruins and Roothollow.
## Features random encounters, the Iris recruitment event, and
## scene transitions to both adjacent areas.

const SP = preload("res://systems/scene_paths.gd")
const Dialogue = preload("res://scenes/verdant_forest/verdant_forest_dialogue.gd")
const Bond01 = preload("res://scenes/verdant_forest/verdant_forest_bond01_dialogue.gd")
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const ASH_STALKER_PATH: String = "res://data/enemies/ash_stalker.tres"
const HOLLOW_SPECTER_PATH: String = "res://data/enemies/hollow_specter.tres"
const ANCIENT_SENTINEL_PATH: String = "res://data/enemies/ancient_sentinel.tres"
const GALE_HARPY_PATH: String = "res://data/enemies/gale_harpy.tres"
const EMBER_HOUND_PATH: String = "res://data/enemies/ember_hound.tres"
const SCENE_BGM_PATH: String = "res://assets/music/Overgrown Memories.ogg"

# Tilemap data (legends + maps) lives in VerdantForestMap.
# Encounter pool builder lives in VerdantForestEncounters.

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
	var pool := VerdantForestEncounters.build_pool(
		load(CREEPING_VINE_PATH) as Resource,
		load(ASH_STALKER_PATH) as Resource,
		load(HOLLOW_SPECTER_PATH) as Resource,
		load(ANCIENT_SENTINEL_PATH) as Resource,
		load(GALE_HARPY_PATH) as Resource,
		load(EMBER_HOUND_PATH) as Resource,
	)
	_encounter_system.setup(pool)
	_encounter_system.encounter_triggered.connect(_on_encounter_triggered)
	_encounter_system.encounter_warning.connect(_on_encounter_warning)

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

	# Full-party traversal dialogue (fires once after garrick_recruited)
	_maybe_trigger_traversal_dialogue.call_deferred()
	# BOND-01: Iris-Kael knife lesson banter (fires once after iris_recruited)
	_maybe_trigger_bond01_dialogue.call_deferred()


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


func _maybe_trigger_traversal_dialogue() -> void:
	if not EventFlags.has_flag(Dialogue.get_traversal_gate_flag()):
		return
	if EventFlags.has_flag(Dialogue.get_traversal_flag()):
		return
	EventFlags.set_flag(Dialogue.get_traversal_flag())
	var raw: Array = Dialogue.get_traversal_lines()
	var lines: Array[DialogueLine] = []
	for entry: Dictionary in raw:
		lines.append(DialogueLine.create(entry["speaker"], entry["text"]))
	DialogueManager.start_dialogue(lines)


func _maybe_trigger_bond01_dialogue() -> void:
	var party_ids: Array = []
	for data: Resource in PartyManager.get_active_party():
		party_ids.append(data.id)
	if not Bond01.compute_bond01_eligible(EventFlags.get_all_flags(), party_ids):
		return
	EventFlags.set_flag(Bond01.get_bond01_flag())
	var raw: Array = Bond01.get_bond01_lines()
	var lines: Array[DialogueLine] = []
	for entry: Dictionary in raw:
		lines.append(DialogueLine.create(entry["speaker"], entry["text"]))
	DialogueManager.start_dialogue(lines)


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
	MapBuilder.build_layer(_ground_layer, VerdantForestMap.GROUND_MAP, VerdantForestMap.GROUND_LEGEND)
	# Paths: dirt path overlay (source 0)
	MapBuilder.build_layer(_paths_layer, VerdantForestMap.PATH_MAP, VerdantForestMap.PATH_LEGEND)
	# Trees: dense canopy fill for impenetrable borders (source 1)
	MapBuilder.build_layer(_trees_layer, VerdantForestMap.TREE_MAP, VerdantForestMap.TREE_LEGEND, 1)
	# Objects: individual tree trunks with collision (source 1)
	MapBuilder.build_layer(
		_objects_layer, VerdantForestMap.TRUNK_MAP, VerdantForestMap.TRUNK_LEGEND, 1
	)
	# Ground detail: scattered rocks and flowers (source 2)
	MapBuilder.build_layer(
		_ground_detail_layer, VerdantForestMap.DETAIL_MAP, VerdantForestMap.DETAIL_LEGEND, 2
	)
	# Above player: tree canopies for walk-under depth (source 1)
	MapBuilder.build_layer(
		_above_player_layer, VerdantForestMap.CANOPY_MAP, VerdantForestMap.CANOPY_LEGEND, 1
	)
