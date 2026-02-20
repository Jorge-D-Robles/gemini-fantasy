class_name MemorialEchoStrategy
extends InteractionStrategy

## Interaction for the old village memorial in the Verdant Forest.
## If the elder_wisdom quest is active and objective 0 is incomplete,
## completes it and shows special dialogue.

@export_multiline var text: String = ""
@export var echo_id: StringName = &""


func execute(_owner: Node) -> void:
	var quest_active := QuestManager.is_quest_active(&"elder_wisdom")
	var objectives := QuestManager.get_objective_status(&"elder_wisdom")
	var need_echo: bool = (
		quest_active
		and not objectives.is_empty()
		and not objectives[0]
	)

	if need_echo:
		var lines: Array[DialogueLine] = [
			DialogueLine.create(
				"",
				"A weathered memorial stone, etched with the"
				+ " names of Roothollow's founders. An Echo"
				+ " Fragment glimmers within the inscription.",
			),
			DialogueLine.create(
				"Kael",
				"This must be the Echo Elder Thessa mentioned."
				+ " I can feel the memories resonating...",
			),
		]
		DialogueManager.start_dialogue(lines)
		await DialogueManager.dialogue_ended
		QuestManager.complete_objective(&"elder_wisdom", 0)
		if echo_id != &"":
			EchoManager.collect_echo(echo_id)
	else:
		var message: String = text if not text.is_empty() else (
			"A weathered memorial stone, etched with the"
			+ " names of Roothollow's founders."
		)
		var lines: Array[DialogueLine] = [
			DialogueLine.create("", message),
		]
		DialogueManager.start_dialogue(lines)
