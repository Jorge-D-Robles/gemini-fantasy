class_name SignStrategy
extends InteractionStrategy

## Displays a text message when interacted with.

@export_multiline var text: String = ""


func execute(_owner: Node) -> void:
	if text.is_empty():
		return
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", text),
	]
	DialogueManager.start_dialogue(lines)
