class_name NyxBornFromNothing
extends Node

## Chapter 6 expanded — "Born from Nothing" Scenes 4-5 + camp.
## Fires after nyx_introduction_seen, at the next camp/rest point.
## Scene 4: Nyx discovers butterflies, bread, shadows.
## Scene 5: Campfire — Nyx reveals Hollows lore, Kael's "loudness."
## Camp: Late-night Garrick/Nyx bonding.
## Sets nyx_born_from_nothing_seen flag.

signal sequence_completed

const FLAG_NAME: String = "nyx_born_from_nothing_seen"


static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("nyx_introduction_seen", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 4: Nyx discovers the mundane world — butterfly, bread, shadow.
static func compute_discovery_lines() -> Array[DialogueLine]:
	return [
		# Butterfly
		DialogueLine.create(
			"Nyx",
			"Oh! Something landed on my hand. It has"
			+ " colors on its outside. How does it carry"
			+ " them?",
		),
		DialogueLine.create(
			"Kael",
			"It's a butterfly. The patterns are part of"
			+ " its body — like crystal formations, but"
			+ " alive.",
		),
		DialogueLine.create(
			"Nyx",
			"Is it thinking?",
		),
		DialogueLine.create(
			"Kael",
			"Not like you or me. It acts on instinct."
			+ " Automatic.",
		),
		DialogueLine.create(
			"Nyx",
			"It's beautiful. Is everything here like"
			+ " this? Made of colors and instinct?",
		),
		DialogueLine.create(
			"Garrick",
			"A lot of things are. There are always"
			+ " more butterflies.",
		),
		DialogueLine.create(
			"Nyx",
			"Always more? That's the best thing"
			+ " anyone has ever said to me.",
		),

		# Bread
		DialogueLine.create(
			"Garrick",
			"Here. Try this. It's bread.",
		),
		DialogueLine.create(
			"Nyx",
			"What do I do with it?",
		),
		DialogueLine.create(
			"Iris",
			"You eat it. You put it inside through"
			+ " the— oh.",
		),
		DialogueLine.create(
			"Nyx",
			"I don't have one of those openings."
			+ " Is that bad?",
		),
		DialogueLine.create(
			"Garrick",
			"No. You're just built different.",
		),
		DialogueLine.create(
			"Nyx",
			"Can I hold it anyway? It smells nice.",
		),

		# Shadow
		DialogueLine.create(
			"Nyx",
			"There's a dark me on the ground! It moves"
			+ " when I move!",
		),
		DialogueLine.create(
			"Iris",
			"That's your shadow. Everything that blocks"
			+ " light casts one.",
		),
		DialogueLine.create(
			"Nyx",
			"Hello, dark me. Are you me?",
		),
		DialogueLine.create(
			"Nyx",
			"...It's not very talkative.",
		),
		DialogueLine.create(
			"Iris",
			"This is what our team looks like. A child"
			+ " who just discovered shadows.",
		),
		DialogueLine.create(
			"Kael",
			"Could be worse.",
		),
		DialogueLine.create(
			"Iris",
			"How?",
		),
		DialogueLine.create(
			"Kael",
			"Could be two kids.",
		),
	]


## Scene 5: Evening campfire — Nyx reveals what the Hollows are like.
static func compute_campfire_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Nyx. Can I ask you about the Hollows?",
		),
		DialogueLine.create(
			"Nyx",
			"Yes! I like questions. They're like shapes"
			+ " that need filling in.",
		),
		DialogueLine.create(
			"Kael",
			"You said everything there happens at the"
			+ " same time. What does that mean?",
		),
		DialogueLine.create(
			"Nyx",
			"Here, things go: before, now, after. In a"
			+ " line. In the other place, before and now"
			+ " and after are all the same thing.",
		),
		DialogueLine.create(
			"Nyx",
			"Inside the other place, there are so many"
			+ " voices. Millions and millions. They talk"
			+ " and talk, all at once, and none of them"
			+ " listen anymore. They're just... echoing.",
		),
		DialogueLine.create(
			"Kael",
			"The Echoes. The memory fragments. You can"
			+ " hear them from inside the Hollows?",
		),
		DialogueLine.create(
			"Nyx",
			"I can hear everything from inside the"
			+ " Hollows. That's why I left. It was too"
			+ " loud and too still at the same time.",
		),
		DialogueLine.create(
			"Nyx",
			"None of the voices were new. Then I heard"
			+ " you. You were the first new thing."
			+ " A voice going somewhere instead of"
			+ " in circles. So I followed it out.",
		),
		DialogueLine.create(
			"Garrick",
			"You came into existence because of Kael.",
		),
		DialogueLine.create(
			"Nyx",
			"I came into existence because I wanted"
			+ " to. Kael was the reason I wanted to.",
		),
		DialogueLine.create(
			"Iris",
			"A consciousness born from the desire to"
			+ " experience something new. The opposite"
			+ " of an Echo.",
		),
		DialogueLine.create(
			"Nyx",
			"Is that okay? Being present tense?",
		),
		DialogueLine.create(
			"Kael",
			"It's the best tense there is.",
		),
	]


## Camp scene: Late-night Garrick/Nyx bonding.
static func compute_camp_scene_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Nyx",
			"Garrick.",
		),
		DialogueLine.create(
			"Garrick",
			"Hmm.",
		),
		DialogueLine.create(
			"Nyx",
			"Do you sleep?",
		),
		DialogueLine.create(
			"Garrick",
			"Sometimes. Not well.",
		),
		DialogueLine.create(
			"Nyx",
			"What happens when you sleep badly?",
		),
		DialogueLine.create(
			"Garrick",
			"Dreams. Old ones.",
		),
		DialogueLine.create(
			"Nyx",
			"Are dreams Echoes? They sound like Echoes."
			+ " Memories that replay.",
		),
		DialogueLine.create(
			"Garrick",
			"That's not a bad way to think about it.",
		),
		DialogueLine.create(
			"Nyx",
			"If I could eat your bad dreams, would"
			+ " that help?",
		),
		DialogueLine.create(
			"Garrick",
			"I don't think that's how it works,"
			+ " little one.",
		),
		DialogueLine.create(
			"Nyx",
			"But what if it was?",
		),
		DialogueLine.create(
			"Garrick",
			"Then I'd let you. But I'd worry about"
			+ " what they'd do to you.",
		),
		DialogueLine.create(
			"Nyx",
			"Things can hurt me?",
		),
		DialogueLine.create(
			"Garrick",
			"Things can hurt anyone. Even people made"
			+ " of shadow and starlight.",
		),
		DialogueLine.create(
			"Nyx",
			"I don't like that. In the other place,"
			+ " nothing could hurt. Here, everything"
			+ " can be a weapon. Even memories.",
		),
		DialogueLine.create(
			"Garrick",
			"Especially memories.",
		),
		DialogueLine.create(
			"Nyx",
			"Can I sit next to you? Your sadness is"
			+ " quieter when I'm close.",
		),
		DialogueLine.create(
			"Garrick",
			"...Yeah. You can sit next to me.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 4: Discoveries
	var discovery_lines := compute_discovery_lines()
	DialogueManager.start_dialogue(discovery_lines)
	await DialogueManager.dialogue_ended

	# Scene 5: Campfire lore
	var campfire_lines := compute_campfire_lines()
	DialogueManager.start_dialogue(campfire_lines)
	await DialogueManager.dialogue_ended

	# Camp scene: Garrick/Nyx night bonding
	var camp_lines := compute_camp_scene_lines()
	DialogueManager.start_dialogue(camp_lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()
