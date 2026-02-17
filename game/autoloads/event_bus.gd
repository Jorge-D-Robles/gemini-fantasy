extends Node

## NOTE: No class_name — autoloads are already global singletons.
## Central signal hub for gameplay events. Entities emit local signals
## AND relay through EventBus so decoupled systems (QuestManager, UI,
## analytics) can listen without knowing the source.

## Emitted when the player interacts with any target (NPC, chest, sign).
signal player_interacted(target: Node)

## Emitted when an NPC's dialogue starts.
signal npc_talked_to(npc_name: String)

## Emitted when an NPC's dialogue ends.
signal npc_interaction_ended(npc_name: String)

## Emitted when an Interactable's strategy executes.
signal interactable_used(interactable_name: String)

## Emitted when an enemy is defeated in battle.
signal enemy_defeated(enemy_id: StringName)

## Emitted when an item is added to inventory.
signal item_acquired(item_id: StringName, quantity: int)

## Emitted when the player enters a new area/scene.
signal area_entered(area_name: String)


func emit_player_interacted(target: Node) -> void:
	player_interacted.emit(target)


func emit_npc_talked_to(npc_name_val: String) -> void:
	npc_talked_to.emit(npc_name_val)


func emit_npc_interaction_ended(npc_name_val: String) -> void:
	npc_interaction_ended.emit(npc_name_val)


func emit_interactable_used(interactable_name: String) -> void:
	interactable_used.emit(interactable_name)


func emit_enemy_defeated(enemy_id: StringName) -> void:
	enemy_defeated.emit(enemy_id)


func emit_item_acquired(
	item_id: StringName,
	quantity: int,
) -> void:
	item_acquired.emit(item_id, quantity)


func emit_area_entered(area_name: String) -> void:
	area_entered.emit(area_name)


func _ready() -> void:
	GameManager.scene_changed.connect(_on_scene_changed)


func _on_scene_changed(scene_path: String) -> void:
	var area_name := scene_path.get_file().get_basename()
	emit_area_entered(area_name)
