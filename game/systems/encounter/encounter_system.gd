class_name EncounterSystem
extends Node

## Step-based random encounter trigger for overworld and dungeon areas.
## Add as a child node of a level scene. Connect to the player's movement
## to count steps, then rolls for encounters based on configurable rates.

signal encounter_triggered(enemy_group: Array[Resource])
signal encounter_warning

@export var encounter_rate: float = 0.1
@export var min_steps_between: int = 5
@export var step_distance: float = 16.0
@export var enabled: bool = true
@export var warning_delay: float = 0.8

## Array of weighted encounter group definitions.
var enemy_pool: Array[EncounterPoolEntry] = []

var _step_counter: int = 0
var _distance_accumulator: float = 0.0
var _player: CharacterBody2D = null
var _previous_position := Vector2.ZERO
var _warning_in_progress: bool = false
var _pending_group: Array[Resource] = []


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


func setup(pool: Array[EncounterPoolEntry]) -> void:
	enemy_pool = pool


func reset_steps() -> void:
	_step_counter = 0
	_distance_accumulator = 0.0


func _on_step() -> void:
	if _warning_in_progress:
		return
	_step_counter += 1
	if _step_counter < min_steps_between:
		return
	if randf() < encounter_rate:
		_step_counter = 0
		var group := _select_enemy_group()
		if not group.is_empty():
			_pending_group = group
			_warning_in_progress = true
			encounter_warning.emit()
			get_tree().create_timer(warning_delay).timeout.connect(
				_on_warning_timeout, CONNECT_ONE_SHOT,
			)


func _on_warning_timeout() -> void:
	_warning_in_progress = false
	var group := _pending_group
	_pending_group = []
	if not group.is_empty():
		encounter_triggered.emit(group)


func _select_enemy_group() -> Array[Resource]:
	if enemy_pool.is_empty():
		return []

	var total_weight: float = 0.0
	for entry in enemy_pool:
		total_weight += entry.weight

	var roll := randf() * total_weight
	for entry in enemy_pool:
		roll -= entry.weight
		if roll <= 0.0:
			return entry.enemies

	return enemy_pool[-1].enemies


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if _player:
		_previous_position = _player.global_position
		set_physics_process(true)
	else:
		push_warning("EncounterSystem: no player found in group 'player'.")
