extends Node2D
## Orchestrates battle flow. Attached to the Battle scene root.

signal battle_started(party: Array[BattlerData], enemies: Array[BattlerData])
signal turn_started(battler: BattlerData)
signal action_executed(attacker: BattlerData, target: BattlerData, damage: int)
signal battle_won
signal battle_lost

var party: Array[BattlerData] = []
var enemies: Array[BattlerData] = []
var turn_queue: Array[BattlerData] = []
var current_battler: BattlerData

@onready var _state_machine: BattleStateMachine = $StateMachine
@onready var _party_positions: Node2D = $PartyPositions
@onready var _enemy_positions: Node2D = $EnemyPositions

const BattlerSpriteScene := preload("res://entities/battle/battler_sprite.tscn")


func _ready() -> void:
	for state in _state_machine.states.values():
		state.battle_manager = self


func initialize_battle(party_data: Array[BattlerData], enemy_data: Array[BattlerData]) -> void:
	party = party_data
	enemies = enemy_data

	for battler in party:
		battler.initialize_from_character()
	for battler in enemies:
		battler.initialize_from_character()

	_spawn_battler_sprites(party, _party_positions)
	_spawn_battler_sprites(enemies, _enemy_positions)

	battle_started.emit(party, enemies)
	_state_machine.start("Intro")


func _spawn_battler_sprites(battlers: Array[BattlerData], positions: Node2D) -> void:
	var slots := positions.get_children()
	for i in battlers.size():
		if i >= slots.size():
			break
		var sprite_node: Node2D = BattlerSpriteScene.instantiate()
		slots[i].add_child(sprite_node)
		sprite_node.setup(battlers[i])


func build_turn_queue() -> void:
	turn_queue.clear()
	var all_battlers: Array[BattlerData] = []
	for b in party:
		if b.is_alive():
			all_battlers.append(b)
	for b in enemies:
		if b.is_alive():
			all_battlers.append(b)
	all_battlers.sort_custom(func(a: BattlerData, b: BattlerData) -> bool:
		return a.current_speed > b.current_speed
	)
	turn_queue = all_battlers


func get_next_battler() -> BattlerData:
	if turn_queue.is_empty():
		return null
	return turn_queue.pop_front()


func is_party_alive() -> bool:
	return party.any(func(b: BattlerData) -> bool: return b.is_alive())


func is_enemy_alive() -> bool:
	return enemies.any(func(b: BattlerData) -> bool: return b.is_alive())


func get_alive_enemies() -> Array[BattlerData]:
	return enemies.filter(func(b: BattlerData) -> bool: return b.is_alive())


func get_alive_party() -> Array[BattlerData]:
	return party.filter(func(b: BattlerData) -> bool: return b.is_alive())
