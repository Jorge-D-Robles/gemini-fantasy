class_name MemorialEchoStrategy
extends InteractionStrategy

## Interaction strategy for echo-bearing memorials and interactables.
##
## Generic mode (require_quest_id == &""): shows vision_lines dialogue (or
## fallback text) then collects the echo immediately. Guarded by has_been_used
## so the player cannot collect the same echo twice in a session.
##
## Quest-gated mode (require_quest_id != &""): preserves the original
## elder_wisdom behaviour — only collects when the named quest is active and
## objective 0 is incomplete.

const ECHO_BGM_PATH: String = "res://assets/music/Echo Captured — Memory Preserved.ogg"
const ECHO_BGM_DURATION: float = 4.0

@export_multiline var text: String = ""
@export var echo_id: StringName = &""
@export var vision_lines: Array[String] = []
@export var require_quest_id: StringName = &""


static func compute_should_collect(
	_echo_id: StringName,
	p_require_quest_id: StringName,
	echo_already_collected: bool,
	quest_active: bool,
	obj_done: bool,
) -> bool:
	if echo_already_collected:
		return false
	if p_require_quest_id == &"":
		return true
	return quest_active and not obj_done


func execute(owner: Node) -> void:
	if owner.has_been_used:
		return
	var quest_active := false
	var obj_done := false
	if require_quest_id != &"":
		quest_active = QuestManager.is_quest_active(require_quest_id)
		var objectives := QuestManager.get_objective_status(require_quest_id)
		obj_done = not objectives.is_empty() and objectives[0]

	var echo_already_collected := (
		echo_id != &""
		and EchoManager.has_echo(echo_id)
	)

	var should_collect := compute_should_collect(
		echo_id,
		require_quest_id,
		echo_already_collected,
		quest_active,
		obj_done,
	)

	if should_collect:
		var lines: Array[DialogueLine] = _build_vision_lines()
		DialogueManager.start_dialogue(lines)
		await DialogueManager.dialogue_ended
		if require_quest_id != &"":
			QuestManager.complete_objective(require_quest_id, 0)
		if echo_id != &"":
			EchoManager.collect_echo(echo_id)
		owner.has_been_used = true
		# Play echo capture sting, then restore area BGM after it finishes.
		AudioManager.push_bgm()
		var echo_bgm := load(ECHO_BGM_PATH) as AudioStream
		if echo_bgm:
			AudioManager.play_bgm(echo_bgm, 0.5)
			await owner.get_tree().create_timer(ECHO_BGM_DURATION).timeout
		AudioManager.pop_bgm(1.0)
	else:
		var message: String = text if not text.is_empty() else (
			"A weathered memorial stone, etched with the"
			+ " names of Roothollow's founders."
		)
		var lines: Array[DialogueLine] = [
			DialogueLine.create("", message),
		]
		DialogueManager.start_dialogue(lines)


func _build_vision_lines() -> Array[DialogueLine]:
	if not vision_lines.is_empty():
		if vision_lines.size() % 2 != 0:
			push_warning(
				"MemorialEchoStrategy: vision_lines has odd count (%d); last entry ignored."
				% vision_lines.size()
			)
		var result: Array[DialogueLine] = []
		var i := 0
		while i + 1 < vision_lines.size():
			result.append(DialogueLine.create(vision_lines[i], vision_lines[i + 1]))
			i += 2
		return result
	# Fallback: original memorial text
	return [
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
