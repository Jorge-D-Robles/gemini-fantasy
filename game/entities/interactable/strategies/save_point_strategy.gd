class_name SavePointStrategy
extends InteractionStrategy

## Saves the game and displays a confirmation message.

@export var text: String = "Progress saved."


func execute(_owner: Node) -> void:
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", text),
	]
	DialogueManager.start_dialogue(lines)
