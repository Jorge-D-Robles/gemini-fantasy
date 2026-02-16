extends Node2D

## Overgrown Ruins — the game's starting area.
## Kael explores ancient ruins and discovers Lyra (opening cutscene).
## Contains random encounters (Memory Blooms, Creeping Vines) and
## an exit to the Verdant Forest.

const VERDANT_FOREST_PATH: String = "res://scenes/verdant_forest/verdant_forest.tscn"
const MEMORY_BLOOM_PATH: String = "res://data/enemies/memory_bloom.tres"
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const KAEL_DATA_PATH: String = "res://data/characters/kael.tres"

@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_point: Marker2D = $Entities/SpawnPoint
@onready var _hud: CanvasLayer = $HUD
@onready var _encounter_system: EncounterSystem = $EncounterSystem
@onready var _opening_sequence: OpeningSequence = $OpeningSequence
@onready var _exit_to_forest: Area2D = $Triggers/ExitToForest
@onready var _lyra_zone: Area2D = $Triggers/LyraDiscoveryZone


func _ready() -> void:
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
	_hud.location_name = "Overgrown Ruins"

	# Connect triggers
	_exit_to_forest.body_entered.connect(_on_exit_to_forest_entered)
	_lyra_zone.body_entered.connect(_on_lyra_zone_entered)

	# Setup encounter system with ruins enemy pool
	var memory_bloom := load(MEMORY_BLOOM_PATH) as Resource
	var creeping_vine := load(CREEPING_VINE_PATH) as Resource

	var pool: Array[Dictionary] = []
	if memory_bloom:
		pool.append({
			"enemies": [memory_bloom] as Array[Resource],
			"weight": 3.0,
		})
		pool.append({
			"enemies": [memory_bloom, memory_bloom] as Array[Resource],
			"weight": 1.5,
		})
	if creeping_vine:
		pool.append({
			"enemies": [creeping_vine] as Array[Resource],
			"weight": 1.0,
		})
		if memory_bloom:
			pool.append({
				"enemies": [memory_bloom, creeping_vine] as Array[Resource],
				"weight": 1.0,
			})

	_encounter_system.setup(pool)
	_encounter_system.encounter_triggered.connect(_on_encounter_triggered)


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
