class_name LastGardenerEncounter
extends Node

## The Last Gardener encounter — optional three-choice event in the Overgrown Capital.
## The party encounters the palace's caretaker Echo fused with the crystal garden.
## Choice A: peaceful pass. Choice B: unlock Greenhouse Seed quest.
## Choice C: boss battle. Fires once after lyra_fragment_2_collected is set.
## Source: docs/story/act1/05-into-the-capital.md (Scene 5)

signal sequence_completed

const FLAG_NAME: String = "gardener_encountered"
const GATE_FLAG: String = "lyra_fragment_2_collected"
const LAST_GARDENER_PATH: String = "res://data/enemies/last_gardener.tres"
const GREENHOUSE_QUEST_PATH: String = "res://data/quests/greenhouse_seed.tres"


## Returns true when the encounter is eligible to fire:
##   - lyra_fragment_2_collected flag is set
##   - gardener_encountered flag is NOT set
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get(GATE_FLAG, false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Returns the 6-line approach sequence; the final line presents the three-choice prompt.
static func compute_approach_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"The Last Gardener",
			"...You're taking pieces away.",
		),
		DialogueLine.create(
			"Kael",
			"We're helping someone. A Conscious Echo. These fragments are hers.",
		),
		DialogueLine.create(
			"The Last Gardener",
			"The woman in the lab. I remember her."
				+ " She brought me tea sometimes, when the late shifts ran long."
				+ " Jasmine. No sugar.",
		),
		DialogueLine.create(
			"Kael",
			"You knew Lyra?",
		),
		DialogueLine.create(
			"The Last Gardener",
			"I knew everyone. I tended the gardens."
				+ " The gardens were between the buildings,"
				+ " and the buildings were full of people,"
				+ " and the people were full of stories. I knew them all.",
		),
		DialogueLine.create(
			"The Last Gardener",
			"Now I tend this. The overgrowth. The memory."
				+ " It's a garden, of a sort. Just not the kind I planted.",
			null,
			[
				"We don't want to fight you. Can we pass?",
				"Lyra would want us to help you too."
					+ " Is there anything we can do?",
				"Stand aside, or we go through you.",
			],
		),
	]


## Outcome lines for the peaceful resolution — choice A.
static func compute_peaceful_outcome_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"The Last Gardener",
			"You may pass. But the garden stays. Someone has to tend it.",
		),
		DialogueLine.create(
			"Kael",
			"Some Echoes aren't monsters."
				+ " They're just doing their job in a world that moved on without them.",
		),
	]


## Outcome lines for the quest resolution — choice B.
static func compute_quest_outcome_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"The Last Gardener",
			"There was a seed. In the greenhouse, behind the palace."
				+ " Before all this grew."
				+ " If you could find it... I'd like to plant something new."
				+ " Something that isn't memory. Something that's just a flower.",
		),
		DialogueLine.create(
			"Kael",
			"We'll find it.",
		),
	]


## Post-battle lines after defeating The Last Gardener — choice C, player victory.
static func compute_defeated_outcome_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"The Last Gardener",
			"Thank you. I was so tired of tending nothing.",
		),
	]


## Maps a choice index to a resolution string.
## 0 = "peaceful", 1 = "quest", 2 = "fight"
static func compute_choice_result(choice_index: int) -> String:
	match choice_index:
		0:
			return "peaceful"
		1:
			return "quest"
		2:
			return "fight"
		_:
			return "peaceful"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	DialogueManager.start_dialogue(compute_approach_lines())
	var choice_idx: int = await DialogueManager.choice_selected
	await DialogueManager.dialogue_ended

	var resolution: String = compute_choice_result(choice_idx)

	match resolution:
		"peaceful":
			EventFlags.set_flag("gardener_resolution_peaceful")
			DialogueManager.start_dialogue(compute_peaceful_outcome_lines())
			await DialogueManager.dialogue_ended
			GameManager.pop_state()
			sequence_completed.emit()
		"quest":
			EventFlags.set_flag("gardener_resolution_quest")
			_unlock_greenhouse_quest()
			DialogueManager.start_dialogue(compute_quest_outcome_lines())
			await DialogueManager.dialogue_ended
			GameManager.pop_state()
			sequence_completed.emit()
		"fight":
			GameManager.pop_state()
			_start_gardener_battle()
			# Emit before the battle scene loads so the caller can free this node.
			# The static _on_gardener_battle_ended handles post-battle dialogue
			# independently via autoloads only — no instance reference needed.
			sequence_completed.emit()


func _unlock_greenhouse_quest() -> void:
	var quest := load(GREENHOUSE_QUEST_PATH) as Resource
	if quest:
		QuestManager.accept_quest(quest)
	else:
		push_warning(
			"LastGardenerEncounter: greenhouse_seed.tres not found"
				+ " — Greenhouse Seed quest not accepted."
		)


func _start_gardener_battle() -> void:
	var last_gardener := load(LAST_GARDENER_PATH) as Resource
	if not last_gardener:
		push_error("LastGardenerEncounter: failed to load last_gardener.tres.")
		return
	BattleManager.battle_ended.connect(
		_on_gardener_battle_ended,
		CONNECT_ONE_SHOT,
	)
	BattleManager.start_battle([last_gardener] as Array[Resource], false)


static func _on_gardener_battle_ended(victory: bool) -> void:
	if not victory:
		return
	EventFlags.set_flag("gardener_resolution_defeated")
	GameManager.push_state(GameManager.GameState.CUTSCENE)
	DialogueManager.start_dialogue(
		LastGardenerEncounter.compute_defeated_outcome_lines()
	)
	await DialogueManager.dialogue_ended
	GameManager.pop_state()
