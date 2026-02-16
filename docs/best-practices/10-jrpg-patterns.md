# JRPG-Specific Patterns

Architecture patterns specifically for Gemini Fantasy.

## Turn-Based Battle System Architecture

```
BattleScene (Node2D)
  ├── BattleBackground (Sprite2D)
  ├── Battlers (Node2D)
  │     ├── PartyBattlers (Node2D)  # Player characters
  │     └── EnemyBattlers (Node2D)  # Enemy instances
  ├── BattleStateMachine (StateMachine)
  │     ├── BattleStartState
  │     ├── TurnQueueState
  │     ├── PlayerTurnState
  │     ├── ActionSelectState
  │     ├── TargetSelectState
  │     ├── ActionExecuteState
  │     ├── EnemyTurnState
  │     ├── TurnEndState
  │     ├── BattleWonState
  │     └── BattleLostState
  ├── BattleUI (CanvasLayer)
  │     ├── TurnOrderDisplay
  │     ├── ActionMenu
  │     ├── TargetCursor
  │     ├── DamageNumbers
  │     └── StatusDisplay
  └── BattleCamera (Camera2D)
```

### Battler Component Pattern

```gdscript
class_name Battler
extends Node2D

## Represents a single combatant in battle.

signal action_selected(action: BattleAction)
signal action_finished
signal defeated
signal resonance_changed(new_value: float)

@export var stats: CharacterStats
@export var skills: Array[SkillData] = []

var current_hp: int
var current_mp: int
var resonance: float = 0.0
var status_effects: Array[StatusEffect] = []
var is_defending: bool = false


func take_damage(amount: int, element: StringName = &"") -> int:
	var final_damage := _calculate_damage(amount, element)
	current_hp = maxi(current_hp - final_damage, 0)
	resonance += final_damage * 0.1  # Build resonance from damage
	resonance_changed.emit(resonance)
	if current_hp <= 0:
		defeated.emit()
	return final_damage


func _calculate_damage(base: int, element: StringName) -> int:
	var defense_mod := 1.0 - (stats.defense / 200.0)
	if is_defending:
		defense_mod *= 0.5
	return int(base * defense_mod)
```

## Turn Queue System

```gdscript
class_name TurnQueue
extends Node

## Manages turn order based on character speed/ATB.

signal turn_ready(battler: Battler)

var _battlers: Array[Battler] = []
var _turn_order: Array[Battler] = []


func initialize(battlers: Array[Battler]) -> void:
	_battlers = battlers
	_calculate_turn_order()


func advance() -> Battler:
	if _turn_order.is_empty():
		_calculate_turn_order()
	var next := _turn_order.pop_front()
	turn_ready.emit(next)
	return next


func _calculate_turn_order() -> void:
	_turn_order = _battlers.filter(func(b: Battler) -> bool: return b.current_hp > 0)
	_turn_order.sort_custom(func(a: Battler, b: Battler) -> bool:
		return a.stats.speed > b.stats.speed
	)
```

## Overworld Architecture

```
Overworld (Node2D)
  ├── TileMapLayer (ground)
  ├── TileMapLayer (decorations)
  ├── Entities (YSort via Node2D)
  │     ├── Player (CharacterBody2D)
  │     ├── NPCs (Node2D)
  │     │     ├── NPC1
  │     │     └── NPC2
  │     └── Interactables (Node2D)
  │           ├── Chest1
  │           └── SavePoint1
  ├── Triggers (Node2D)
  │     ├── SceneTransition (Area2D)
  │     └── BattleZone (Area2D)
  └── Camera (Camera2D)
```

## Interaction System

```gdscript
class_name Interactable
extends Area2D

## Base class for interactive objects (NPCs, chests, signs).

signal interacted

@export var interaction_prompt: String = "Talk"
@export var one_shot: bool = false

var _has_been_used: bool = false


func interact() -> void:
	if one_shot and _has_been_used:
		return
	_has_been_used = true
	interacted.emit()
	_on_interact()


func _on_interact() -> void:
	pass  # Override in subclass
```

## Random Encounter Pattern

```gdscript
## Attach to the player or a battle zone Area2D.

@export var encounter_rate: float = 0.05  ## Per step
@export var enemy_groups: Array[EnemyGroupData] = []

var _steps_since_encounter: int = 0
var _min_steps: int = 10


func _on_player_stepped() -> void:
	_steps_since_encounter += 1
	if _steps_since_encounter < _min_steps:
		return
	if randf() < encounter_rate:
		_steps_since_encounter = 0
		var group := _select_enemy_group()
		SceneManager.start_battle(group)


func _select_enemy_group() -> EnemyGroupData:
	# Weighted random selection
	var total_weight := 0.0
	for group in enemy_groups:
		total_weight += group.weight
	var roll := randf() * total_weight
	for group in enemy_groups:
		roll -= group.weight
		if roll <= 0:
			return group
	return enemy_groups[-1]
```

## Party Management

```gdscript
class_name PartyManager
extends Node

## Manages the player's party globally.

signal party_changed
signal member_added(member: PartyMemberData)
signal member_removed(member: PartyMemberData)

const MAX_ACTIVE := 4
const MAX_RESERVE := 4

var active_members: Array[PartyMemberData] = []
var reserve_members: Array[PartyMemberData] = []


func add_member(member: PartyMemberData) -> void:
	if active_members.size() < MAX_ACTIVE:
		active_members.append(member)
	else:
		reserve_members.append(member)
	member_added.emit(member)
	party_changed.emit()


func swap_member(active_index: int, reserve_index: int) -> void:
	var temp := active_members[active_index]
	active_members[active_index] = reserve_members[reserve_index]
	reserve_members[reserve_index] = temp
	party_changed.emit()
```

## Scene Transition Pattern

```gdscript
class_name SceneManager
extends Node

## Handles scene transitions with fade effects.

signal transition_started
signal transition_midpoint  ## Screen fully black
signal transition_finished

@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var color_rect: ColorRect = $TransitionLayer/ColorRect


func change_scene(
	scene_path: String,
	spawn_point: String = "",
	fade_duration: float = 0.5,
) -> void:
	transition_started.emit()
	var tween := create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, fade_duration)
	await tween.finished

	transition_midpoint.emit()
	get_tree().change_scene_to_file(scene_path)
	await get_tree().tree_changed

	# Set player position if spawn point specified
	if spawn_point:
		var player := get_tree().get_first_node_in_group("player")
		var marker := get_tree().get_first_node_in_group(spawn_point)
		if player and marker:
			player.global_position = marker.global_position

	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, fade_duration)
	await tween.finished
	transition_finished.emit()
```

## Anti-Patterns

- Battle logic in UI scripts (separate data/logic from presentation)
- Hard-coding enemy stats in scripts (use Resource data)
- Tight coupling between overworld and battle scenes
- Player script handling all interactions directly (use Area2D + signals)
- Storing inventory as raw arrays of strings (use typed Resources)
