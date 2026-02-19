extends Node

## Autoload that initiates and manages battle transitions.

signal battle_started
signal battle_ended(victory: bool)

const BATTLE_SCENE_PATH: String = "res://systems/battle/battle_scene.tscn"

var _battle_scene: Node = null
var _is_in_battle: bool = false
var _pre_battle_scene_path: String = ""
var _pre_battle_player_position: Vector2 = Vector2.ZERO


func start_battle(
	enemy_group: Array[Resource],
	can_escape: bool = true,
) -> void:
	if _is_in_battle:
		push_warning("BattleManager: already in battle.")
		return
	if DialogueManager.is_active():
		push_warning("BattleManager: blocked — dialogue is active.")
		return
	if GameManager.current_state != GameManager.GameState.OVERWORLD:
		push_warning("BattleManager: blocked — not in OVERWORLD state.")
		return
	if GameManager.is_transitioning():
		push_warning("BattleManager: blocked — scene transition active.")
		return
	_is_in_battle = true
	battle_started.emit()

	GameManager.push_state(GameManager.GameState.BATTLE)

	var party_data: Array[Resource] = PartyManager.get_active_party()

	var battle_packed := load(BATTLE_SCENE_PATH) as PackedScene
	if not battle_packed:
		push_error("BattleManager: failed to load battle scene.")
		_is_in_battle = false
		return

	var current_scene := get_tree().current_scene
	if current_scene:
		_pre_battle_scene_path = current_scene.scene_file_path
	else:
		_pre_battle_scene_path = ""

	var player := get_tree().get_first_node_in_group("player")
	if player:
		_pre_battle_player_position = player.global_position

	await GameManager.change_scene(BATTLE_SCENE_PATH)

	_battle_scene = get_tree().current_scene
	if "area_scene_path" in _battle_scene:
		_battle_scene.area_scene_path = _pre_battle_scene_path
	if _battle_scene.has_method("setup_battle"):
		_battle_scene.setup_battle(party_data, enemy_group, can_escape)
	if _battle_scene.has_signal("battle_finished"):
		_battle_scene.battle_finished.connect(_on_battle_finished)


func is_in_battle() -> bool:
	return _is_in_battle


func _on_battle_finished(victory: bool) -> void:
	_is_in_battle = false
	GameManager.pop_state()
	battle_ended.emit(victory)

	if not _pre_battle_scene_path.is_empty():
		GameManager.scene_changed.connect(
			_restore_player_position, CONNECT_ONE_SHOT,
		)
		await GameManager.change_scene(_pre_battle_scene_path)
	_pre_battle_scene_path = ""
	_battle_scene = null


func _restore_player_position(_scene_path: String) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = _pre_battle_player_position
