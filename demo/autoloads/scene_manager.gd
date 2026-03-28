extends Node
## Manages scene transitions with fade effects. Autoload as SceneManager.

signal transition_started
signal transition_finished

@onready var _color_rect: ColorRect = $TransitionLayer/ColorRect
@onready var _anim_player: AnimationPlayer = $TransitionLayer/AnimationPlayer

var _target_scene_path: String = ""
var _target_spawn_point: String = ""
var _is_transitioning: bool = false
var _previous_scene_path: String = ""
var _previous_player_position: Vector2 = Vector2.ZERO


func change_scene(scene_path: String, spawn_point: String = "default") -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	_target_scene_path = scene_path
	_target_spawn_point = spawn_point

	transition_started.emit()
	_anim_player.play("fade_out")
	await _anim_player.animation_finished

	get_tree().change_scene_to_file(_target_scene_path)
	await get_tree().tree_changed

	_place_player_at_spawn()

	_anim_player.play("fade_in")
	await _anim_player.animation_finished

	_is_transitioning = false
	transition_finished.emit()


func _place_player_at_spawn() -> void:
	var spawn_markers := get_tree().get_nodes_in_group("spawn_points")
	for marker in spawn_markers:
		if marker.name == _target_spawn_point:
			var player := get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marker.global_position
			return

	for marker in spawn_markers:
		if marker.name == "default":
			var player := get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marker.global_position
			return


func start_battle(encounter_data: Dictionary) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true

	var player := get_tree().get_first_node_in_group("player")
	if player:
		_previous_player_position = player.global_position
	_previous_scene_path = get_tree().current_scene.scene_file_path

	MusicManager.remember_track()
	MusicManager.play_music("res://audio/music/battle_theme.ogg")

	transition_started.emit()
	_anim_player.play("fade_out")
	await _anim_player.animation_finished

	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
	await get_tree().tree_changed

	var battle_scene := get_tree().current_scene
	if battle_scene.has_method("initialize_battle"):
		battle_scene.initialize_battle(
			encounter_data.get("party", []),
			encounter_data.get("enemies", []),
		)

	_anim_player.play("fade_in")
	await _anim_player.animation_finished
	_is_transitioning = false
	transition_finished.emit()


func return_from_battle() -> void:
	if _previous_scene_path.is_empty():
		return

	MusicManager.resume_previous_track()

	change_scene(_previous_scene_path, "default")
	await transition_finished
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = _previous_player_position
