class_name ChestStrategy
extends InteractionStrategy

## Opens a chest and displays a message about the obtained item.

@export var item_id: String = ""
@export var text: String = ""


func execute(owner: Node) -> void:
	if "has_been_used" in owner:
		owner.has_been_used = true
	var message: String = text if not text.is_empty() else "Obtained %s!" % item_id
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", message),
	]
	DialogueManager.start_dialogue(lines)
