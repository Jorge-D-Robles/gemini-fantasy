extends Node

## Manages game state and scene transitions with fade effects.

signal game_state_changed(old_state: GameState, new_state: GameState)
signal scene_changed(scene_path: String)
signal transition_started
signal transition_midpoint
signal transition_finished

enum GameState {
	OVERWORLD,
	BATTLE,
	DIALOGUE,
	MENU,
	CUTSCENE,
}

const FADE_DURATION: float = 0.5

var current_state: GameState = GameState.OVERWORLD
var _state_stack: Array[GameState] = []
var _is_transitioning: bool = false

var _transition_layer: CanvasLayer = null
var _fade_rect: ColorRect = null


func _ready() -> void:
	_setup_transition_layer()


func push_state(new_state: GameState) -> void:
	_state_stack.push_back(current_state)
	var old_state := current_state
	current_state = new_state
	game_state_changed.emit(old_state, new_state)


func pop_state() -> void:
	if _state_stack.is_empty():
		push_warning("GameManager: state stack is empty.")
		return
	var old_state := current_state
	current_state = _state_stack.pop_back()
	game_state_changed.emit(old_state, current_state)


func change_scene(
	scene_path: String,
	fade_duration: float = FADE_DURATION,
	spawn_point: String = "",
) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	transition_started.emit()

	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, fade_duration)
	await tween.finished

	transition_midpoint.emit()
	get_tree().change_scene_to_file(scene_path)
	# SceneTree.scene_changed fires after the new scene is fully added to the
	# tree and _ready() has run on all nodes — unlike tree_changed, which fires
	# on the first hierarchy mutation (old scene removal) before _ready() runs.
	# Awaiting scene_changed ensures that scene_changed.emit() below is called
	# after the new scene's _ready() completes, so listeners such as
	# BattleManager._restore_player_position() can reliably find nodes by group.
	await get_tree().scene_changed

	if spawn_point:
		var player := get_tree().get_first_node_in_group("player")
		var marker := get_tree().get_first_node_in_group(spawn_point)
		if player and marker:
			player.global_position = marker.global_position

	scene_changed.emit(scene_path)

	tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 0.0, fade_duration)
	await tween.finished

	_is_transitioning = false
	transition_finished.emit()


func is_transitioning() -> bool:
	return _is_transitioning


func _setup_transition_layer() -> void:
	_transition_layer = CanvasLayer.new()
	_fade_rect = ColorRect.new()
	_transition_layer.layer = 100
	_transition_layer.name = "TransitionLayer"
	add_child(_transition_layer)

	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_layer.add_child(_fade_rect)
