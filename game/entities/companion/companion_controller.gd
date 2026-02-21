class_name CompanionController
extends Node

## Manages companion followers that trail behind the player.
## Records player position history and assigns follower positions
## directly from the buffer for smooth path-tracing.

const FOLLOW_OFFSET: int = 15
const MAX_HISTORY: int = 200
const KAEL_ID: StringName = &"kael"

var _player: Node2D = null
var _followers: Array[CompanionFollower] = []
var _position_history: Array[Dictionary] = []
var _is_active: bool = true


func _ready() -> void:
	# Ensure CompanionController (and its follower children) render behind
	# the Player by being the first child of Entities (tree order: earlier = behind).
	var parent := get_parent()
	if parent:
		parent.move_child(self, 0)


func setup(player: Node2D) -> void:
	_player = player
	_reset_history()
	_rebuild_followers()
	var pm := _get_party_manager()
	if pm:
		pm.party_changed.connect(_on_party_changed)
	var gm := _get_game_manager()
	if gm:
		gm.game_state_changed.connect(_on_state_changed)


func _physics_process(_delta: float) -> void:
	if not _is_active or _player == null:
		return

	var entry := {
		"pos": _player.global_position,
		"facing": _player.facing if _player.has_method("get_facing_direction") else 0,
	}
	_position_history.append(entry)
	if _position_history.size() > MAX_HISTORY:
		_position_history.pop_front()

	for i: int in _followers.size():
		var idx: int = compute_history_index(
			i, _position_history.size(), FOLLOW_OFFSET,
		)
		var hist: Dictionary = _position_history[idx]
		var prev_pos: Vector2 = _followers[i].global_position
		_followers[i].global_position = hist["pos"]

		var new_facing: int = hist["facing"]
		_followers[i].set_facing(new_facing)

		var moved: bool = prev_pos.distance_to(hist["pos"]) > 0.5
		_followers[i].set_moving(moved)


func _on_party_changed() -> void:
	_rebuild_followers()


func _on_state_changed(
	_old_state: int,
	new_state: int,
) -> void:
	# GameManager.GameState.OVERWORLD == 0
	_is_active = (new_state == 0)
	if _is_active:
		_reset_history()
		for follower: CompanionFollower in _followers:
			follower.set_moving(false)
	else:
		for follower: CompanionFollower in _followers:
			follower.set_moving(false)


func _rebuild_followers() -> void:
	for follower: CompanionFollower in _followers:
		follower.queue_free()
	_followers.clear()

	var pm := _get_party_manager()
	if pm == null:
		return
	var party: Array[Resource] = pm.get_active_party()
	var needed: Array[Resource] = compute_followers_needed(party)

	for data: Resource in needed:
		var follower := CompanionFollower.new()
		var char_data := data as CharacterData
		if char_data:
			follower.setup(char_data.sprite_path, char_data.id)
		follower.global_position = _player.global_position
		_followers.append(follower)
		add_child(follower)

	_reset_history()


func _reset_history() -> void:
	_position_history.clear()
	if _player == null:
		return
	var entry := {
		"pos": _player.global_position,
		"facing": _player.facing if _player.has_method("get_facing_direction") else 0,
	}
	for i: int in MAX_HISTORY:
		_position_history.append(entry.duplicate())


func _exit_tree() -> void:
	var pm := _get_party_manager()
	if pm and pm.party_changed.is_connected(_on_party_changed):
		pm.party_changed.disconnect(_on_party_changed)
	var gm := _get_game_manager()
	if gm and gm.game_state_changed.is_connected(_on_state_changed):
		gm.game_state_changed.disconnect(_on_state_changed)


func _get_party_manager() -> Node:
	return get_node_or_null("/root/PartyManager")


func _get_game_manager() -> Node:
	return get_node_or_null("/root/GameManager")


static func compute_followers_needed(
	active_party: Array[Resource],
) -> Array[Resource]:
	var result: Array[Resource] = []
	for data: Resource in active_party:
		var bd := data as BattlerData
		if bd and bd.id != KAEL_ID:
			result.append(data)
	return result


static func compute_history_index(
	follower_idx: int,
	history_size: int,
	offset: int,
) -> int:
	if history_size <= 0:
		return 0
	var target: int = history_size - 1 - (follower_idx + 1) * offset
	return maxi(0, target)
