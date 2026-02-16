extends Node2D

## Roothollow — safe town hub. No random encounters.
## Features NPCs (innkeeper, shopkeeper, townfolk), Garrick recruitment,
## a save point, and an exit to the Verdant Forest.

const VERDANT_FOREST_PATH: String = "res://scenes/verdant_forest/verdant_forest.tscn"

@onready var _player: CharacterBody2D = $Entities/Player
@onready var _spawn_from_forest: Marker2D = $Entities/SpawnFromForest
@onready var _hud: CanvasLayer = $HUD
@onready var _exit_to_forest: Area2D = $Triggers/ExitToForest
@onready var _garrick_zone: Area2D = $Triggers/GarrickRecruitZone
@onready var _garrick_event: GarrickRecruitment = $GarrickRecruitment
@onready var _garrick_npc: StaticBody2D = $Entities/GarrickNPC


func _ready() -> void:
	_hud.location_name = "Roothollow"

	# Add spawn point to group for GameManager lookup
	_spawn_from_forest.add_to_group("spawn_from_forest")

	# Connect triggers
	_exit_to_forest.body_entered.connect(_on_exit_to_forest_entered)
	_garrick_zone.body_entered.connect(_on_garrick_zone_entered)

	# Connect innkeeper special interaction
	var innkeeper: StaticBody2D = $Entities/InnkeeperNPC
	innkeeper.interaction_ended.connect(_on_innkeeper_finished)

	# Hide Garrick recruitment zone if already recruited
	if EventFlags.has_flag(GarrickRecruitment.FLAG_NAME):
		_garrick_zone.monitoring = false
		_garrick_npc.visible = false
		_garrick_npc.process_mode = Node.PROCESS_MODE_DISABLED


func _on_exit_to_forest_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	GameManager.change_scene(
		VERDANT_FOREST_PATH,
		GameManager.FADE_DURATION,
		"spawn_from_town",
	)


func _on_garrick_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if EventFlags.has_flag(GarrickRecruitment.FLAG_NAME):
		return
	# Require Lyra discovery and Iris recruitment first
	if not EventFlags.has_flag("opening_lyra_discovered"):
		return
	if not EventFlags.has_flag("iris_recruited"):
		return
	_garrick_zone.monitoring = false
	_garrick_event.trigger()
	await _garrick_event.sequence_completed
	# Hide Garrick NPC after he joins party
	_garrick_npc.visible = false
	_garrick_npc.process_mode = Node.PROCESS_MODE_DISABLED


func _on_innkeeper_finished() -> void:
	# Heal the entire party to full HP and EE
	# TODO: Heal party HP/EE once persistent character state is added
	var heal_lines: Array[Dictionary] = [{
		"speaker": "Innkeeper",
		"text": "Rest well. Your party has been fully restored.",
	}]
	DialogueManager.start_dialogue(heal_lines)
