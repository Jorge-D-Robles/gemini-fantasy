class_name Captured
extends Node

## Chapter 10 — "Captured" full event.
## Act I climax: the party flees Prismfall, is ambushed by the Initiative,
## and Director Vex reveals Kael is a Resonance Anchor.
##   Scene 1: Running — escape from Prismfall inn at 3 AM.
##   Scene 2: Southern Road — open Steppes, Resonance net detected.
##   Scene 3: Ambush — Commander Vael, surrender after unwinnable fight.
##   Scene 4: The Director — Vex's revelation about Kael.
##   Scene 5: The Cells — party processes the truth through walls.
##   Scene 6: Breaking Out — Iris's prosthetic jailbreak.
##   Scene 7: Open Sky — escape aftermath, Act I emotional landing.
##   Camp: The Road South — campfire epilogue, Act I ending.
## Gate: lyras_truth_seen AND NOT kael_anchor_revealed.
## Sets kael_anchor_revealed flag.

signal sequence_completed

const FLAG_NAME: String = "kael_anchor_revealed"


## Returns true when the event is eligible to fire:
##   - lyras_truth_seen flag is set (Severance revelation has happened)
##   - kael_anchor_revealed flag is NOT set (not yet revealed)
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("lyras_truth_seen", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 1 — Running: the party escapes Prismfall inn at 3 AM.
static func compute_running_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"How long?",
		),
		DialogueLine.create(
			"Iris",
			"Encrypted comms to someone outside the city."
			+ " If it's a rapid-response unit, maybe four"
			+ " hours. If it's a full tactical team from"
			+ " Gearhaven, maybe twelve.",
		),
		DialogueLine.create(
			"Garrick",
			"Then four hours is optimistic.",
		),
		DialogueLine.create(
			"Nyx",
			"There are people on the rooftops. Three of"
			+ " them. They're not guards. They're watching"
			+ " the inn.",
		),
		DialogueLine.create(
			"Iris",
			"How many exits does this place have?",
		),
		DialogueLine.create(
			"Kael",
			"Front door, kitchen door out back, and a"
			+ " window in the storeroom that drops into"
			+ " the alley.",
		),
		DialogueLine.create(
			"Iris",
			"Kitchen door. It opens onto the back street,"
			+ " which connects to the southern market path.",
		),
		DialogueLine.create(
			"Garrick",
			"What about payment?",
		),
		DialogueLine.create(
			"Kael",
			"*(Setting coins on the bedside table.)*"
			+ " I'm not stiffing the innkeeper because the"
			+ " Initiative is after us.",
		),
		DialogueLine.create(
			"Garrick",
			"*(Slight nod.)* Good.",
		),
	]


## Scene 2 — Southern Road: open Steppes, Resonance net closes in.
static func compute_road_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"Crystal-runners. Modified transport that uses"
			+ " Resonance pulses to glide over terrain."
			+ " Fast. Quiet.",
		),
		DialogueLine.create(
			"Kael",
			"Where are we going? South to where?"
			+ " We can't just walk in a direction and hope.",
		),
		DialogueLine.create(
			"Iris",
			"The Cindral Wastes border is five days"
			+ " on foot. There's a Free Resonant safe house"
			+ " in the mining town of Duskwell.",
		),
		DialogueLine.create(
			"Nyx",
			"Something is wrong. The ground. The crystals."
			+ " They're humming. A different hum than the"
			+ " canyon. Faster. Like a heartbeat when"
			+ " you're scared.",
		),
		DialogueLine.create(
			"Iris",
			"The ambient Resonance field just spiked."
			+ " Something is broadcasting on a wide-area"
			+ " frequency. Like a net.",
		),
		DialogueLine.create(
			"Garrick",
			"A Resonance net. They're scanning for us.",
		),
		DialogueLine.create(
			"Iris",
			"They're scanning for the fragment. It's the"
			+ " strongest Resonance source for fifty miles."
			+ " We're a beacon.",
		),
		DialogueLine.create(
			"Garrick",
			"*(Pointing south.)* Crystal-runners. They're"
			+ " already ahead of us.",
		),
		DialogueLine.create(
			"Iris",
			"They boxed us in. The watchers in Prismfall"
			+ " weren't surveillance. They were herders."
			+ " Pushing us south onto open ground.",
		),
	]


## Scene 3 — Ambush: Commander Vael confrontation and surrender.
static func compute_ambush_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Commander Vael",
			"Kael Voss. Iris Mantle. Garrick Thorne."
			+ " Please surrender your weapons and the"
			+ " Resonance artifact. Director Thornwright"
			+ " is requesting a conversation.",
		),
		DialogueLine.create(
			"Iris",
			"*(Low, to Kael.)* Vael. Commander-grade."
			+ " Ran the Initiative's western extraction"
			+ " teams. Smart, methodical, doesn't bluff.",
		),
		DialogueLine.create(
			"Vael",
			"You're in open terrain with no cover."
			+ " Area-denial dampeners, kinetic suppression"
			+ " gear, and twelve Resonance-trained soldiers."
			+ " The math doesn't work.",
		),
		DialogueLine.create(
			"Garrick",
			"I've beaten worse odds.",
		),
		DialogueLine.create(
			"Vael",
			"Thirty years ago, maybe.",
		),
		DialogueLine.create(
			"Nyx",
			"I could hurt you. All of you. I don't want"
			+ " to but I could.",
		),
		DialogueLine.create(
			"Vael",
			"If you attack, we activate the Resonance"
			+ " dampener. In the confusion, my soldiers"
			+ " will secure your friends.",
		),
		DialogueLine.create(
			"Kael",
			"*(Quietly.)* She's right. The math doesn't"
			+ " work.",
		),
		DialogueLine.create(
			"Kael",
			"Nobody else dies today. Not for me.",
		),
		DialogueLine.create(
			"Garrick",
			"*(Shield still up, surrounded.)* If you hurt"
			+ " them, I will pull this world apart piece by"
			+ " piece to find you. That's not a threat."
			+ " That's a schedule.",
		),
		DialogueLine.create(
			"Vael",
			"Noted. Secure the artifact.",
		),
	]


## Scene 4 — The Director: Vex reveals Kael is a Resonance Anchor.
static func compute_director_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Director Vex Thornwright",
			"*(Setting tea in front of Kael.)* Your"
			+ " companions are safe. Separate holding areas."
			+ " The Echo entity is in a Resonance-shielded"
			+ " room. Garrick broke one of my soldier's"
			+ " noses before they were separated.",
		),
		DialogueLine.create("Kael", "What do you want?"),
		DialogueLine.create(
			"Vex",
			"A conversation. Just a conversation.",
		),
		DialogueLine.create(
			"Vex",
			"The Convergence -- in its final moments as"
			+ " the Severance ripped the network apart --"
			+ " created three stable fragments."
			+ " Consciousness seeds. And it anchored them"
			+ " in human-compatible forms. We call them"
			+ " Resonance Anchors.",
		),
		DialogueLine.create("Kael", "Three Anchors."),
		DialogueLine.create(
			"Vex",
			"Three. We've been searching for all of them."
			+ " We found you first. You were discovered as"
			+ " a child near the Hollows with no memories."
			+ " No parents. No records. You don't have"
			+ " childhood memories because you didn't have"
			+ " a childhood.",
		),
		DialogueLine.create("Kael", "Stop."),
		DialogueLine.create(
			"Vex",
			"The Convergence gave you a story to grow"
			+ " into. A life to live until the fragments"
			+ " started reassembling and someone came"
			+ " looking.",
		),
		DialogueLine.create("Kael", "I said stop."),
		DialogueLine.create(
			"Vex",
			"You're not human. You never were. You're"
			+ " the Convergence's attempt to rebuild itself"
			+ " in human form. A piece of something that"
			+ " used to be seven billion minds, compressed"
			+ " into one body.",
		),
		DialogueLine.create(
			"Kael",
			"You're telling me I'm not a person. That"
			+ " everything I am -- my name, my memories,"
			+ " my life in Roothollow -- is a story a dying"
			+ " god told itself so it could survive. And"
			+ " you're apologizing for reading my journal.",
		),
		DialogueLine.create(
			"Vex",
			"Help me build the Resonance Cage -- a"
			+ " containment system for the Convergence --"
			+ " and we save both. Humanity and the network.",
		),
		DialogueLine.create(
			"Kael",
			"No. Not now, not ever. You don't get to cage"
			+ " a consciousness and call it salvation. You"
			+ " don't get to experiment on people and call"
			+ " it development costs.",
		),
		DialogueLine.create(
			"Vex",
			"*(Standing.)* You'll reconsider. Once the"
			+ " Shepherds make their move, you'll see that"
			+ " my way is the only way that doesn't end in"
			+ " extinction. You're not a prisoner, Kael."
			+ " You're an asset.",
		),
	]


## Scene 5 — The Cells: party processes the truth through walls.
static func compute_cells_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"*(Through the wall.)* Dampener cuffs are"
			+ " Initiative model C-7. I helped design them."
			+ " There's a flaw in the frequency modulation.",
		),
		DialogueLine.create(
			"Garrick",
			"*(Through the wall.)* Where's Nyx?",
		),
		DialogueLine.create(
			"Iris",
			"Shielded room. Deeper in the facility."
			+ " Once the dampeners drop, Nyx will feel"
			+ " the change.",
		),
		DialogueLine.create(
			"Kael",
			"*(Calling through the wall.)* I'm here.",
		),
		DialogueLine.create(
			"Iris",
			"Kael! Are you hurt?",
		),
		DialogueLine.create(
			"Kael",
			"No. I'm not hurt. He told me what I am.",
		),
		DialogueLine.create(
			"Garrick",
			"What did he say?",
		),
		DialogueLine.create(
			"Kael",
			"I'm not human. I'm a piece of the"
			+ " Convergence. A Resonance Anchor. My whole"
			+ " life -- none of it is real. I'm a story"
			+ " a dying god told itself.",
		),
		DialogueLine.create(
			"Iris",
			"Vex told you what he wants you to believe."
			+ " He told you a version of the truth that"
			+ " makes you into a tool. That's how the"
			+ " Initiative operates.",
		),
		DialogueLine.create(
			"Iris",
			"Whatever you are, Kael, you're a person."
			+ " Origins don't change that.",
		),
		DialogueLine.create(
			"Garrick",
			"What she said. But shorter: you're you."
			+ " That's enough.",
		),
		DialogueLine.create(
			"Kael",
			"*(Barely audible.)* I don't know if that's"
			+ " true.",
		),
		DialogueLine.create(
			"Garrick",
			"You don't have to know yet. You just have"
			+ " to get out of here.",
		),
	]


## Scene 6 — Breaking Out: Iris's prosthetic jailbreak.
static func compute_breakout_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"Under the door. Left pocket of my coat --"
			+ " there's a magnetic strip sewn into the"
			+ " lining. Slide it under my door.",
		),
		DialogueLine.create(
			"Iris",
			"Got it. The cuffs have a magnetic release"
			+ " for emergency medical situations...",
		),
		DialogueLine.create(
			"Iris",
			"I'm free. *(Working on her arm.)* Four"
			+ " minutes starting now. Stand back from"
			+ " the door.",
		),
		DialogueLine.create(
			"Garrick",
			"Nyx?",
		),
		DialogueLine.create(
			"Iris",
			"*(Arm flickering.)* Deeper in. Follow me."
			+ " Two minutes forty seconds.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Eyes brightening.)* I heard you. Through"
			+ " the walls and the shielding and the"
			+ " dampeners. I heard everything Vex said.",
		),
		DialogueLine.create(
			"Nyx",
			"He said you're not human. He said you're"
			+ " a piece of the Convergence. Good. That"
			+ " makes two of us. Now let's go.",
		),
		DialogueLine.create(
			"Kael",
			"The fragment. He took it. I'm not leaving"
			+ " Lyra.",
		),
		DialogueLine.create(
			"Lyra",
			"*(Barely audible, as Kael grabs the"
			+ " fragment.)* ...Kael?",
		),
		DialogueLine.create(
			"Kael",
			"I'm here. We're leaving. Everything later."
			+ " Right now we run.",
		),
	]


## Scene 7 — Open Sky: escape aftermath, Act I emotional landing.
static func compute_escape_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"Five minutes. Catch your breath. Then"
			+ " we move.",
		),
		DialogueLine.create(
			"Kael",
			"What he said. About me. About what I am."
			+ " If it's true -- if I'm really just a piece"
			+ " of the Convergence wearing a body -- does"
			+ " that change anything?",
		),
		DialogueLine.create(
			"Garrick",
			"When I was a Shepherd, I believed the human"
			+ " soul was sacred. Then I watched my brothers"
			+ " purify a village of innocent people. The"
			+ " soul isn't what you're made of. It's what"
			+ " you choose to do.",
		),
		DialogueLine.create(
			"Garrick",
			"You chose to leave money for an innkeeper"
			+ " while running for your life. You chose to"
			+ " break back into an enemy facility for a"
			+ " fragment of a dead woman. That's a soul,"
			+ " Kael. Whatever it's made of.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Leaning against Kael.)* I don't know what"
			+ " I am either. Nobody made me on purpose. And"
			+ " you're the first person who told me that"
			+ " was okay. So it's okay for you too.",
		),
		DialogueLine.create(
			"Iris",
			"We can have the existential crisis on the"
			+ " road. Both sides are going to come for us."
			+ " *(Firmly.)* For us. You don't get to be"
			+ " alone in this.",
		),
		DialogueLine.create(
			"Kael",
			"We find the other Anchors before the"
			+ " Initiative does.",
		),
		DialogueLine.create(
			"Iris",
			"And then we find a way through this that"
			+ " doesn't end with anyone building a cage"
			+ " or a bomb.",
		),
		DialogueLine.create(
			"Lyra",
			"*(Through fragment, faint.)* I know who"
			+ " the other Anchors are. When you're"
			+ " ready... I'll tell you.",
		),
		DialogueLine.create(
			"Kael",
			"Not tonight. Tonight we run.",
		),
	]


## Camp — The Road South: campfire epilogue, Act I ending.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"*(Cooking over the fire.)* Not my best work."
			+ " But it's hot.",
		),
		DialogueLine.create(
			"Kael",
			"Garrick. Your daughter. Mara. What was"
			+ " she like?",
		),
		DialogueLine.create(
			"Garrick",
			"Stubborn. Kind. She laughed too loud and"
			+ " couldn't carry a tune. She wanted to be"
			+ " a healer. *(Very quiet.)* She was braver"
			+ " than me.",
		),
		DialogueLine.create(
			"Kael",
			"That sounds like someone who was real."
			+ " Someone who mattered. Whether or not the"
			+ " soul is sacred. She was real because of"
			+ " what she chose.",
		),
		DialogueLine.create(
			"Garrick",
			"Yes, Kael. You're real too.",
		),
		DialogueLine.create(
			"Iris",
			"So. Recap. We're fugitives from the most"
			+ " powerful military organization on"
			+ " Aethermoor. We've been told the protagonist"
			+ " of our little group isn't technically human."
			+ " Did I miss anything?",
		),
		DialogueLine.create(
			"Nyx",
			"The stars are very beautiful tonight.",
		),
		DialogueLine.create(
			"Iris",
			"*(Looking up.)* ...Yeah. They are.",
		),
		DialogueLine.create(
			"Kael",
			"We find the other Anchors. We figure out"
			+ " what the Convergence actually wants. And"
			+ " we find a way through this.",
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

	# Scene 1: Running — escape from Prismfall
	DialogueManager.start_dialogue(compute_running_lines())
	await DialogueManager.dialogue_ended

	# Scene 2: Southern Road — open ground, Resonance net
	DialogueManager.start_dialogue(compute_road_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: Ambush — Commander Vael, surrender
	DialogueManager.start_dialogue(compute_ambush_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: The Director — Vex's revelation
	DialogueManager.start_dialogue(compute_director_lines())
	await DialogueManager.dialogue_ended

	# Scene 5: The Cells — processing through walls
	DialogueManager.start_dialogue(compute_cells_lines())
	await DialogueManager.dialogue_ended

	# Scene 6: Breaking Out — Iris's jailbreak
	DialogueManager.start_dialogue(compute_breakout_lines())
	await DialogueManager.dialogue_ended

	# Scene 7: Open Sky — escape, Act I landing
	DialogueManager.start_dialogue(compute_escape_lines())
	await DialogueManager.dialogue_ended

	# Camp: The Road South — epilogue
	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()
