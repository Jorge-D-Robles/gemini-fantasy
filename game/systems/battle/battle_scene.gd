extends Node2D

## Main battle scene. Orchestrates battlers, turn queue, and state machine.

signal battle_finished(victory: bool)

var party_battlers: Array[PartyBattler] = []
var enemy_battlers: Array[EnemyBattler] = []
var all_battlers: Array[Battler] = []
var current_battler: Battler = null
var can_escape: bool = true
var _battle_result: bool = false

@onready var party_node: Node2D = $Battlers/PartyBattlers
@onready var enemy_node: Node2D = $Battlers/EnemyBattlers
@onready var turn_queue: TurnQueue = $TurnQueue
@onready var state_machine: BattleStateMachine = $BattleStateMachine


func _ready() -> void:
	state_machine.setup(self)


func setup_battle(
	party_data: Array[Resource],
	enemy_data: Array[Resource],
	escapable: bool = true,
) -> void:
	can_escape = escapable
	_spawn_party(party_data)
	_spawn_enemies(enemy_data)
	_build_battler_list()
	turn_queue.initialize(all_battlers)
	state_machine.transition_to("BattleStart")


func get_living_party() -> Array[Battler]:
	var living: Array[Battler] = []
	for b in party_battlers:
		if b.is_alive:
			living.append(b)
	return living


func get_living_enemies() -> Array[Battler]:
	var living: Array[Battler] = []
	for b in enemy_battlers:
		if b.is_alive:
			living.append(b)
	return living


func check_battle_end() -> int:
	## Returns: 0 = ongoing, 1 = victory, -1 = defeat
	if get_living_enemies().is_empty():
		return 1
	if get_living_party().is_empty():
		return -1
	return 0


func end_battle(victory: bool) -> void:
	_battle_result = victory
	battle_finished.emit(victory)


func _spawn_party(party_data: Array[Resource]) -> void:
	var positions: Array[Vector2] = [
		Vector2(450, 100),
		Vector2(470, 150),
		Vector2(450, 200),
		Vector2(470, 250),
	]
	for i in party_data.size():
		var battler := PartyBattler.new()
		battler.data = party_data[i]
		battler.initialize_from_data()
		if i < positions.size():
			battler.position = positions[i]
		party_node.add_child(battler)
		party_battlers.append(battler)
		battler.defeated.connect(_on_battler_defeated.bind(battler))


func _spawn_enemies(enemy_data: Array[Resource]) -> void:
	var positions: Array[Vector2] = [
		Vector2(150, 100),
		Vector2(130, 150),
		Vector2(150, 200),
		Vector2(130, 250),
	]
	for i in enemy_data.size():
		var battler := EnemyBattler.new()
		battler.data = enemy_data[i]
		battler.initialize_from_data()
		if i < positions.size():
			battler.position = positions[i]
		enemy_node.add_child(battler)
		enemy_battlers.append(battler)
		battler.defeated.connect(_on_battler_defeated.bind(battler))


func _build_battler_list() -> void:
	all_battlers.clear()
	for b in party_battlers:
		all_battlers.append(b)
	for b in enemy_battlers:
		all_battlers.append(b)


func _on_battler_defeated(battler: Battler) -> void:
	turn_queue.remove_battler(battler)
