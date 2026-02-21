class_name Captured
extends Node

## Chapter 10 — "Captured" story event scaffold.
## Director Vex Thornwright reveals Kael is a Resonance Anchor — not human.
## Scenes 4 + 7 from docs/story/act1/10-captured.md:
##   Scene 4: The Director — Vex's revelation in the Initiative mobile facility.
##   Scene 7: Open Sky — escape aftermath, Act I emotional landing.
## Gate: lyras_truth_seen AND NOT kael_anchor_revealed.
## Sets kael_anchor_revealed flag.

signal sequence_completed

const FLAG_NAME: String = "kael_anchor_revealed"


## Returns true when the event is eligible to fire:
##   - lyras_truth_seen flag is set (Severance revelation has happened)
##   - kael_anchor_revealed flag is NOT set (Kael's identity not yet revealed)
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("lyras_truth_seen", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 4 — The Director: Vex Thornwright tells Kael they are a Resonance Anchor.
## ~14 lines from docs/story/act1/10-captured.md Scene 4.
static func compute_director_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Director Vex Thornwright",
			"*(Setting tea in front of Kael.)* Your companions are safe."
			+ " Separate holding areas. The Echo entity is in a Resonance-shielded"
			+ " room. Garrick broke one of my soldier's noses before they were"
			+ " separated.",
		),
		DialogueLine.create("Kael", "What do you want?"),
		DialogueLine.create("Vex", "A conversation. Just a conversation."),
		DialogueLine.create(
			"Vex",
			"The Convergence -- in its final moments as the Severance ripped"
			+ " the network apart -- created three stable fragments. Consciousness"
			+ " seeds. And it anchored them in human-compatible forms. Three people"
			+ " who carry a piece of the Convergence's core consciousness."
			+ " We call them Resonance Anchors.",
		),
		DialogueLine.create("Kael", "Three Anchors."),
		DialogueLine.create(
			"Vex",
			"Three. We've been searching for all of them. We found you first."
			+ " You were discovered as a child near the Hollows with no memories."
			+ " No parents. No records. You don't have childhood memories"
			+ " because you didn't have a childhood.",
		),
		DialogueLine.create("Kael", "Stop."),
		DialogueLine.create(
			"Vex",
			"The Convergence gave you a story to grow into. A life to live"
			+ " until the fragments started reassembling and someone came looking.",
		),
		DialogueLine.create("Kael", "I said stop."),
		DialogueLine.create(
			"Vex",
			"You're not human. You never were. You're the Convergence's attempt"
			+ " to rebuild itself in human form. A piece of something that used"
			+ " to be seven billion minds, compressed into one body, given a name"
			+ " and a life and a desperate, unbearable need to find the rest of itself.",
		),
		DialogueLine.create(
			"Kael",
			"You're telling me I'm not a person. That everything I am -- my name,"
			+ " my memories, my life in Roothollow, the people I care about --"
			+ " is a story a dying god told itself so it could survive."
			+ " And you're apologizing for reading my journal.",
		),
		DialogueLine.create(
			"Vex",
			"Help me build the Resonance Cage -- a containment system for the"
			+ " Convergence -- and we save both. Humanity and the network."
			+ " Neither destroyed. Neither consuming the other.",
		),
		DialogueLine.create(
			"Kael",
			"No. Not now, not ever. You don't get to cage a consciousness and"
			+ " call it salvation. You don't get to experiment on people and"
			+ " call it development costs. And you don't get to tell me what"
			+ " I am and then ask me to work for you.",
		),
		DialogueLine.create(
			"Vex",
			"*(Standing.)* You'll reconsider. Once the Shepherds make their move,"
			+ " you'll see that my way is the only way that doesn't end in extinction."
			+ " You're not a prisoner, Kael. You're an asset.",
		),
	]


## Scene 7 — Open Sky: the party escapes into the Steppes night. Act I landing.
## ~10 lines from docs/story/act1/10-captured.md Scene 7 + Camp Scene.
static func compute_escape_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"What he said. About me. About what I am. If it's true --"
			+ " if I'm really just a piece of the Convergence wearing a body"
			+ " -- does that change anything?",
		),
		DialogueLine.create(
			"Garrick",
			"When I was a Shepherd, I believed the human soul was sacred."
			+ " Then I watched my brothers purify a village of innocent people."
			+ " I learned something that day. The soul isn't what you're made of."
			+ " It's what you choose to do.",
		),
		DialogueLine.create(
			"Garrick",
			"You chose to leave money for an innkeeper while running for your life."
			+ " You chose to break back into an enemy facility for a fragment"
			+ " of a dead woman. That's a soul, Kael. Whatever it's made of.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Leaning against Kael.)* I don't know what I am either. Nobody"
			+ " made me on purpose. I just happened. And you're the first person"
			+ " who told me that was okay. So it's okay for you too.",
		),
		DialogueLine.create(
			"Iris",
			"We can have the existential crisis on the road. Both sides are"
			+ " going to come for us. *(Firmly.)* For us. You don't get to be"
			+ " alone in this. We already decided that back in Roothollow.",
		),
		DialogueLine.create("Kael", "We find the other Anchors before the Initiative does."),
		DialogueLine.create("Iris", "And then we find a way through this that doesn't end"
			+ " with anyone building a cage or a bomb.",
		),
		DialogueLine.create(
			"Lyra",
			"*(Through fragment, faint.)* I know who the other Anchors are."
			+ " When you're ready... I'll tell you.",
		),
		DialogueLine.create(
			"Kael",
			"Not tonight. Tonight we run.",
		),
		DialogueLine.create(
			"Kael",
			"*(Looking up at the stars, barely audible.)*"
			+ " 'We were almost something beautiful.'"
			+ " *(A breath.)* Maybe we still can be.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	DialogueManager.start_dialogue(compute_director_lines())
	await DialogueManager.dialogue_ended

	DialogueManager.start_dialogue(compute_escape_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()
