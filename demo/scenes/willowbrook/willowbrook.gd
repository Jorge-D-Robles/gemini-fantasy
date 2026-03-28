extends Node2D
## The town of Willowbrook, Crystal Saga's starting village.

@onready var _dialogue_box: CanvasLayer = $DialogueBox


func _ready() -> void:
	_dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	for npc in get_tree().get_nodes_in_group("npcs"):
		npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: CharacterBody2D) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("start_interaction"):
		player.start_interaction()

	var dialogue_lines := _get_dialogue_for_npc(npc)
	if not dialogue_lines.is_empty():
		_dialogue_box.start_dialogue(dialogue_lines)

	# Lira recruitment
	if npc.npc_data.id == "lira" and GameManager.has_flag("talked_to_lira") and not GameManager.has_flag("lira_joined"):
		_dialogue_box.dialogue_finished.connect(_recruit_lira, CONNECT_ONE_SHOT)

	# Main quest start
	if npc.npc_data.id == "elder":
		GameManager.set_flag("talked_to_elder")
		if not QuestManager.is_quest_active("crystal_resonance"):
			var quest: QuestData = load("res://data/quests/crystal_resonance.tres")
			if quest:
				QuestManager.start_quest(quest)


func _on_dialogue_finished() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("end_interaction"):
		player.end_interaction()


func _recruit_lira() -> void:
	GameManager.set_flag("lira_joined")
	var lira: CharacterData = load("res://data/characters/lira.tres")
	if lira:
		PartyManager.add_member(lira)
		print("Lira joined the party!")


func _get_dialogue_for_npc(npc: CharacterBody2D) -> Array[DialogueLine]:
	match npc.npc_data.id:
		"traveler_fynn":
			return _get_fynn_dialogue()
		"lira":
			return _get_lira_dialogue()
		_:
			return npc.npc_data.dialogue


func _get_fynn_dialogue() -> Array[DialogueLine]:
	if GameManager.has_flag("pendant_returned"):
		return _make_lines("Fynn", ["Thank you again for finding my pendant!"])
	elif GameManager.has_flag("pendant_found"):
		return _make_lines("Fynn", [
			"You found it! My pendant! Thank you so much!",
			"Please, take this as a reward.",
		])
	elif GameManager.has_flag("talked_to_fynn"):
		return _make_lines("Fynn", ["Any luck finding my pendant in the Whisperwood?"])
	else:
		GameManager.set_flag("talked_to_fynn")
		var quest: QuestData = load("res://data/quests/lost_pendant.tres")
		if quest:
			QuestManager.start_quest(quest)
		return _make_lines("Fynn", [
			"I lost something precious in the Whisperwood...",
			"A pendant, silver with a blue stone.",
			"If you find it, I'd be forever grateful.",
		])


func _get_lira_dialogue() -> Array[DialogueLine]:
	if GameManager.has_flag("lira_joined"):
		return _make_lines("Lira", ["Ready to go when you are!"])
	if GameManager.has_flag("talked_to_lira"):
		return _make_lines("Lira", [
			"I've been studying the crystal formations nearby.",
			"They resonate with a strange energy...",
			"If you're heading to the Crystal Cavern, I'd like to come along.",
			"My magic could be useful!",
		])
	GameManager.set_flag("talked_to_lira")
	return _make_lines("Lira", [
		"Oh, hello! I'm Lira, a scholar from the capital.",
		"I came to Willowbrook to study the ancient crystals.",
		"Talk to me again if you're interested in what I've found.",
	])


func _make_lines(speaker: String, texts: Array[String]) -> Array[DialogueLine]:
	var lines: Array[DialogueLine] = []
	for text in texts:
		var line := DialogueLine.new()
		line.speaker_name = speaker
		line.text = text
		lines.append(line)
	return lines
