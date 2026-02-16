extends Node2D

## Verdant Forest — overworld area between Overgrown Ruins and Roothollow.
## Features random encounters, the Iris recruitment event, and
## scene transitions to both adjacent areas.

const OVERGROWN_RUINS_PATH: String = "res://scenes/overgrown_ruins/overgrown_ruins.tscn"
const ROOTHOLLOW_PATH: String = "res://scenes/roothollow/roothollow.tscn"
const CREEPING_VINE_PATH: String = "res://data/enemies/creeping_vine.tres"
const ASH_STALKER_PATH: String = "res://data/enemies/ash_stalker.tres"

@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_from_ruins: Marker2D = $Entities/SpawnFromRuins
@onready var _spawn_from_town: Marker2D = $Entities/SpawnFromTown
@onready var _hud: CanvasLayer = $HUD
@onready var _encounter_system: EncounterSystem = $EncounterSystem
@onready var _iris_event: IrisRecruitment = $IrisRecruitment
@onready var _exit_to_ruins: Area2D = $Triggers/ExitToRuins
@onready var _exit_to_town: Area2D = $Triggers/ExitToTown
@onready var _iris_zone: Area2D = $Triggers/IrisEventZone


func _ready() -> void:
	# Set HUD location name
	_hud.location_name = "Verdant Forest"

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

	var pool: Array[Dictionary] = []
	if creeping_vine:
		pool.append({
			"enemies": [creeping_vine] as Array[Resource],
			"weight": 2.0,
		})
		pool.append({
			"enemies": [creeping_vine, creeping_vine] as Array[Resource],
			"weight": 1.5,
		})
	if ash_stalker:
		pool.append({
			"enemies": [ash_stalker] as Array[Resource],
			"weight": 2.0,
		})
	if creeping_vine and ash_stalker:
		pool.append({
			"enemies": [creeping_vine, ash_stalker] as Array[Resource],
			"weight": 1.0,
		})

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
	GameManager.change_scene(OVERGROWN_RUINS_PATH)


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
