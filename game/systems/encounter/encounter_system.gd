class_name EncounterSystem
extends Node

## Step-based random encounter trigger for overworld and dungeon areas.
## Add as a child node of a level scene. Connect to the player's movement
## to count steps, then rolls for encounters based on configurable rates.

signal encounter_triggered(enemy_group: Array[Resource])

@export var encounter_rate: float = 0.1
@export var min_steps_between: int = 5
@export var step_distance: float = 16.0
@export var enabled: bool = true

## Array of encounter group definitions.
## Each entry is a Dictionary: { "enemies": Array[Resource], "weight": float }
var enemy_pool: Array[Dictionary] = []

var _step_counter: int = 0
var _distance_accumulator: float = 0.0
var _player: CharacterBody2D = null
var _previous_position := Vector2.ZERO


func _ready() -> void:
	set_physics_process(false)
	_find_player.call_deferred()


func _physics_process(_delta: float) -> void:
	if not enabled or not _player:
		return
	if GameManager.current_state != GameManager.GameState.OVERWORLD:
		return
	if BattleManager.is_in_battle():
		return

	var current_pos := _player.global_position
	var distance := current_pos.distance_to(_previous_position)
	_previous_position = current_pos

	if distance < 0.1 or distance > 100.0:
		return

	_distance_accumulator += distance
	if _distance_accumulator >= step_distance:
		_distance_accumulator -= step_distance
		_on_step()


func setup(pool: Array[Dictionary]) -> void:
	enemy_pool = pool


func reset_steps() -> void:
	_step_counter = 0
	_distance_accumulator = 0.0


func _on_step() -> void:
	_step_counter += 1
	if _step_counter < min_steps_between:
		return
	if randf() < encounter_rate:
		_step_counter = 0
		var group := _select_enemy_group()
		if not group.is_empty():
			encounter_triggered.emit(group)


func _select_enemy_group() -> Array[Resource]:
	if enemy_pool.is_empty():
		return []

	var total_weight: float = 0.0
	for entry in enemy_pool:
		total_weight += entry.get("weight", 1.0) as float

	var roll := randf() * total_weight
	for entry in enemy_pool:
		roll -= entry.get("weight", 1.0) as float
		if roll <= 0.0:
			return entry.get("enemies", []) as Array[Resource]

	return enemy_pool[-1].get("enemies", []) as Array[Resource]


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if _player:
		_previous_position = _player.global_position
		set_physics_process(true)
	else:
		push_warning("EncounterSystem: no player found in group 'player'.")
