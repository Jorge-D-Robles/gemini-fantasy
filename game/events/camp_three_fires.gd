class_name CampThreeFires
extends Node

## Camp scene: "Three Around a Fire" — Garrick, Iris, and Kael share a
## meal and plan the Overgrown Capital run. Triggers from Roothollow inn
## after garrick_recruited flag. Implements Chapter 4 Camp Scene from
## docs/story/act1/04-old-iron.md.
## Emotional beat: Iris accepts Garrick through a bowl of stew; Garrick
## earns his place not through combat but through cooking and steady sense.

signal sequence_completed

const FLAG_NAME: String = "camp_scene_three_fires"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var lines: Array[DialogueLine] = _build_dialogue()

	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()


func _build_dialogue() -> Array[DialogueLine]:
	return [
		# Garrick is cooking — nobody asked him to
		DialogueLine.create(
			"Kael",
			"You cook.",
		),
		DialogueLine.create(
			"Garrick",
			"Forty years on the road. You learn or you starve.",
		),
		DialogueLine.create(
			"Iris",
			"What is that? It smells like--",
		),
		DialogueLine.create(
			"Garrick",
			"Traveler's stew. Root vegetables, whatever herb I"
			+ " could find, and a piece of that dried meat from"
			+ " your pack. Hope you don't mind.",
		),
		DialogueLine.create(
			"Iris",
			"That was my emergency ration.",
		),
		DialogueLine.create(
			"Garrick",
			"It is an emergency. Neither of you have eaten"
			+ " properly in days. Eat. You're too thin for"
			+ " someone who fights as hard as you do.",
		),
		# Iris accepts him into the party through the simplest gesture
		DialogueLine.create(
			"Iris",
			"...Okay. You can stay.",
		),
		# Planning the Capital run
		DialogueLine.create(
			"Kael",
			"Tomorrow we head into the Overgrown Capital."
			+ " Research quarter -- that's where Lyra's"
			+ " strongest fragment should be.",
		),
		DialogueLine.create(
			"Garrick",
			"Entry points?",
		),
		DialogueLine.create(
			"Kael",
			"Main entrance through the market district. Crystal"
			+ " growth has shifted things, but the path I used"
			+ " two days ago should still hold.",
		),
		DialogueLine.create(
			"Iris",
			"Signal is strongest from the northeast. Market"
			+ " district, cut through the entertainment district,"
			+ " approach from the south.",
		),
		DialogueLine.create(
			"Garrick",
			"Then I go first at the chokepoints. Shield up, eyes"
			+ " forward. You two watch the flanks. This is what"
			+ " I do. Let me do it.",
		),
		# The trio's dynamic crystallises
		DialogueLine.create(
			"Kael",
			"We're not a military unit, Garrick.",
		),
		DialogueLine.create(
			"Garrick",
			"No. You're two young people heading into dangerous"
			+ " territory with no tactical structure and more"
			+ " courage than sense. Take it as a compliment."
			+ " Sense keeps you safe. Courage gets things done.",
		),
		# Kael's quiet acceptance — the scene's emotional close
		DialogueLine.create(
			"Kael",
			"...The stew's good.",
		),
	]
