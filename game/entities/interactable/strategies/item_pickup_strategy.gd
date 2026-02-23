class_name ItemPickupStrategy
extends InteractionStrategy

## Picks up an item, displays a message, then removes the interactable.

@export var item_id: String = ""
@export var text: String = ""


func execute(owner: Node) -> void:
	if "has_been_used" in owner:
		owner.has_been_used = true
	if not item_id.is_empty():
		InventoryManager.add_item(StringName(item_id), 1)
	var message: String = text if not text.is_empty() else "Picked up %s!" % item_id
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", message),
	]
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended
	owner.queue_free()
