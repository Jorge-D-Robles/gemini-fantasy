class_name DiaryStrategy
extends InteractionStrategy

## Shows multi-line diary dialogue and sets an EventFlags flag on completion.
## diary_lines uses alternating speaker/text pairs (even count).

@export var diary_lines: Array[String] = []
@export var flag_name: String = ""


func execute(owner: Node) -> void:
	if owner.has_been_used:
		return
	var lines: Array[DialogueLine] = DialogueLine.build_from_pairs(
		diary_lines, "DiaryStrategy"
	)
	if lines.is_empty():
		return
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended
	if not flag_name.is_empty():
		EventFlags.set_flag(flag_name)
	owner.has_been_used = true
