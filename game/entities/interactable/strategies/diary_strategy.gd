class_name DiaryStrategy
extends InteractionStrategy

## Shows multi-line diary dialogue and sets an EventFlags flag on completion.
## diary_lines uses alternating speaker/text pairs (even count).

@export var diary_lines: Array[String] = []
@export var flag_name: String = ""


func execute(owner: Node) -> void:
	if owner.has_been_used:
		return
	var lines: Array[DialogueLine] = _build_lines()
	if lines.is_empty():
		return
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended
	if not flag_name.is_empty():
		EventFlags.set_flag(flag_name)
	owner.has_been_used = true


func _build_lines() -> Array[DialogueLine]:
	if diary_lines.size() % 2 != 0:
		push_warning(
			"DiaryStrategy: diary_lines has odd count (%d); last entry ignored."
			% diary_lines.size()
		)
	var result: Array[DialogueLine] = []
	var i := 0
	while i + 1 < diary_lines.size():
		result.append(DialogueLine.create(diary_lines[i], diary_lines[i + 1]))
		i += 2
	return result
