extends Node

## Manages game state and scene transitions with fade and slide effects.

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

enum TransitionType {
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
}

const FADE_DURATION: float = 0.5
const SLIDE_DURATION: float = 0.4

var current_state: GameState = GameState.OVERWORLD
var playtime_seconds: float = 0.0
var _state_stack: Array[GameState] = []
var _is_transitioning: bool = false
var _transition_layer: CanvasLayer = null
var _fade_rect: ColorRect = null
var _slide_rect: ColorRect = null


func _ready() -> void:
	_setup_transition_layer()


func _process(delta: float) -> void:
	if compute_should_tick_playtime(current_state):
		playtime_seconds += delta


## Returns true when playtime should accumulate (player is in control).
## Excludes BATTLE and CUTSCENE to prevent inflating reported time.
static func compute_should_tick_playtime(state: GameState) -> bool:
	return state == GameState.OVERWORLD or state == GameState.MENU


## Returns the transition type to use when moving between two scene paths.
## Adjacent overworld scenes slide; all others fade.
static func compute_transition_type(from_scene: String, to_scene: String) -> TransitionType:
	if from_scene == ScenePaths.ROOTHOLLOW and to_scene == ScenePaths.VERDANT_FOREST:
		return TransitionType.SLIDE_RIGHT
	if from_scene == ScenePaths.VERDANT_FOREST and to_scene == ScenePaths.ROOTHOLLOW:
		return TransitionType.SLIDE_LEFT
	if from_scene == ScenePaths.VERDANT_FOREST and to_scene == ScenePaths.OVERGROWN_RUINS:
		return TransitionType.SLIDE_RIGHT
	if from_scene == ScenePaths.OVERGROWN_RUINS and to_scene == ScenePaths.VERDANT_FOREST:
		return TransitionType.SLIDE_LEFT
	return TransitionType.FADE


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

	var from_path := ""
	if get_tree().current_scene:
		from_path = get_tree().current_scene.scene_file_path
	var transition := compute_transition_type(from_path, scene_path)

	if transition == TransitionType.FADE:
		await _run_fade_transition(scene_path, fade_duration, spawn_point)
	else:
		await _run_slide_transition(scene_path, transition, spawn_point)

	_is_transitioning = false
	transition_finished.emit()


func is_transitioning() -> bool:
	return _is_transitioning


func _run_fade_transition(
	scene_path: String,
	fade_duration: float,
	spawn_point: String,
) -> void:
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

	_apply_spawn_point(spawn_point)
	scene_changed.emit(scene_path)

	tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 0.0, fade_duration)
	await tween.finished


func _run_slide_transition(
	scene_path: String,
	direction: TransitionType,
	spawn_point: String,
) -> void:
	var vp_size := get_viewport().get_visible_rect().size
	_slide_rect.size = vp_size
	_slide_rect.visible = true

	var in_start_x: float = (
		vp_size.x if direction == TransitionType.SLIDE_LEFT else -vp_size.x
	)
	var out_end_x: float = (
		-vp_size.x if direction == TransitionType.SLIDE_LEFT else vp_size.x
	)

	_slide_rect.position = Vector2(in_start_x, 0.0)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_slide_rect, "position:x", 0.0, SLIDE_DURATION)
	await tween.finished

	transition_midpoint.emit()
	get_tree().change_scene_to_file(scene_path)
	# Same rationale as _run_fade_transition: await scene_changed (not
	# tree_changed) so the new scene's _ready() has fully run before we emit.
	await get_tree().scene_changed

	_apply_spawn_point(spawn_point)
	scene_changed.emit(scene_path)

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_slide_rect, "position:x", out_end_x, SLIDE_DURATION)
	await tween.finished

	_slide_rect.visible = false
	_slide_rect.position = Vector2.ZERO


func _apply_spawn_point(spawn_point: String) -> void:
	if spawn_point.is_empty():
		return
	var player := get_tree().get_first_node_in_group("player")
	var marker := get_tree().get_first_node_in_group(spawn_point)
	if player and marker:
		player.global_position = marker.global_position


func _setup_transition_layer() -> void:
	_transition_layer = CanvasLayer.new()
	_fade_rect = ColorRect.new()
	_transition_layer.layer = 100
	_transition_layer.name = "TransitionLayer"
	add_child(_transition_layer)

	_fade_rect.color = Color.TRANSPARENT
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_layer.add_child(_fade_rect)

	_slide_rect = ColorRect.new()
	_slide_rect.color = Color.BLACK
	_slide_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_slide_rect.visible = false
	_transition_layer.add_child(_slide_rect)
