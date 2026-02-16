class_name BattleManager
extends Node

## Autoload that initiates and manages battle transitions.

signal battle_started
signal battle_ended(victory: bool)

const BATTLE_SCENE_PATH: String = "res://systems/battle/battle_scene.tscn"

var _battle_scene: Node = null
var _is_in_battle: bool = false
var _pre_battle_scene_path: String = ""


func start_battle(
	enemy_group: Array[Resource],
	can_escape: bool = true,
) -> void:
	if _is_in_battle:
		push_warning("BattleManager: already in battle.")
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

	_pre_battle_scene_path = get_tree().current_scene.scene_file_path

	await GameManager.change_scene(BATTLE_SCENE_PATH)

	_battle_scene = get_tree().current_scene
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
		await GameManager.change_scene(_pre_battle_scene_path)
	_pre_battle_scene_path = ""
	_battle_scene = null
