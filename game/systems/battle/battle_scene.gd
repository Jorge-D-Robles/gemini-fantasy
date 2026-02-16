extends Node2D

## Main battle scene. Orchestrates battlers, turn queue, and state machine.

## Emitted when the battle ends. [param victory] is true if party won.
signal battle_finished(victory: bool)

const PARTY_BATTLER_SCENE_PATH: String = "res://entities/battle/party_battler_scene.tscn"
const ENEMY_BATTLER_SCENE_PATH: String = "res://entities/battle/enemy_battler_scene.tscn"

var party_battlers: Array[PartyBattler] = []
var enemy_battlers: Array[EnemyBattler] = []
var all_battlers: Array[Battler] = []
var current_battler: Battler = null
var current_action: BattleAction = null
var can_escape: bool = true
var _battle_result: bool = false

@onready var party_node: Node2D = $Battlers/PartyBattlers
@onready var enemy_node: Node2D = $Battlers/EnemyBattlers
@onready var turn_queue: TurnQueue = $TurnQueue
@onready var state_machine: BattleStateMachine = $BattleStateMachine


func _ready() -> void:
	state_machine.setup(self)


## Initializes the battle with the given party and enemy data resources.
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


## Returns all party battlers that are still alive.
func get_living_party() -> Array[Battler]:
	var living: Array[Battler] = []
	for b in party_battlers:
		if b.is_alive:
			living.append(b)
	return living


## Returns all enemy battlers that are still alive.
func get_living_enemies() -> Array[Battler]:
	var living: Array[Battler] = []
	for b in enemy_battlers:
		if b.is_alive:
			living.append(b)
	return living


## Checks if the battle is over. Returns 0 (ongoing), 1 (victory), or -1 (defeat).
func check_battle_end() -> int:
	if get_living_enemies().is_empty():
		return 1
	if get_living_party().is_empty():
		return -1
	return 0


## Ends the battle and emits [signal battle_finished].
func end_battle(victory: bool) -> void:
	_battle_result = victory
	battle_finished.emit(victory)


## Returns the visual scene node for a battler, or null.
func get_visual_scene(battler: Battler) -> Node2D:
	for child in battler.get_children():
		if child is PartyBattlerScene or child is EnemyBattlerScene:
			return child
	return null


## Updates UI with current party status, resonance, and turn order.
func refresh_battle_ui() -> void:
	var battle_ui: Node = get_node_or_null("BattleUI")
	if not battle_ui:
		return
	battle_ui.update_party_status(get_living_party())
	if current_battler:
		battle_ui.update_resonance(
			current_battler.resonance_gauge,
			current_battler.resonance_state,
		)
	battle_ui.update_turn_order(turn_queue.peek_order())


func _spawn_party(party_data: Array[Resource]) -> void:
	var slots := _get_marker_positions(party_node)
	var visual_scene := load(PARTY_BATTLER_SCENE_PATH) as PackedScene
	for i in party_data.size():
		var battler := PartyBattler.new()
		battler.data = party_data[i]
		battler.initialize_from_data()
		if i < slots.size():
			battler.position = slots[i]
		party_node.add_child(battler)
		party_battlers.append(battler)
		battler.defeated.connect(_on_battler_defeated.bind(battler))
		# Instantiate visual scene and bind to logic battler
		if visual_scene:
			var visual: PartyBattlerScene = visual_scene.instantiate()
			var char_data := party_data[i] as CharacterData
			if char_data:
				visual.character_data = char_data
			battler.add_child(visual)
			visual.bind_battler(battler)


func _spawn_enemies(enemy_data_arr: Array[Resource]) -> void:
	var slots := _get_marker_positions(enemy_node)
	var visual_scene := load(ENEMY_BATTLER_SCENE_PATH) as PackedScene
	for i in enemy_data_arr.size():
		var battler := EnemyBattler.new()
		battler.data = enemy_data_arr[i]
		battler.initialize_from_data()
		if i < slots.size():
			battler.position = slots[i]
		enemy_node.add_child(battler)
		enemy_battlers.append(battler)
		battler.defeated.connect(_on_battler_defeated.bind(battler))
		# Instantiate visual scene and bind to logic battler
		if visual_scene:
			var visual: EnemyBattlerScene = visual_scene.instantiate()
			var e_data := enemy_data_arr[i] as EnemyData
			if e_data:
				visual.enemy_data = e_data
			battler.add_child(visual)
			visual.bind_battler(battler)


func _build_battler_list() -> void:
	all_battlers.clear()
	for b in party_battlers:
		all_battlers.append(b)
	for b in enemy_battlers:
		all_battlers.append(b)


func _get_marker_positions(parent: Node2D) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for child: Node in parent.get_children():
		if child is Marker2D:
			positions.append(child.position)
	return positions


func _on_battler_defeated(battler: Battler) -> void:
	turn_queue.remove_battler(battler)
