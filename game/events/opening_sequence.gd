class_name OpeningSequence
extends Node

## Opening story event: Kael discovers Lyra in the Overgrown Ruins.
## Triggered when the player enters the LyraDiscoveryZone.
## Compresses Chapter 1 Scene 5 ("The Anomaly") and Chapter 2 Scene 2
## ("The Preserved Room") into a single trigger for demo game flow.
## Source: docs/story/act1/01-the-collector.md, 02-a-voice-in-the-crystal.md
## After the dialogue, Lyra joins the party.

signal sequence_completed

const FLAG_NAME: String = "opening_lyra_discovered"
const LYRA_DATA_PATH: String = "res://data/characters/lyra.tres"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var lines: Array[DialogueLine] = _build_dialogue()

	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	# Add Lyra to the party
	var lyra_data := load(LYRA_DATA_PATH) as Resource
	if lyra_data:
		PartyManager.add_character(lyra_data)

	GameManager.pop_state()
	sequence_completed.emit()


func _build_dialogue() -> Array[DialogueLine]:
	return [
		# --- Section 1: Discovery and First Contact (13 lines) ---

		# Kael approaches — something unusual
		DialogueLine.create(
			"Kael",
			"This isn't a memory loop. Memory loops are simple"
			+ " -- one emotion, one moment, repeating.",
		),
		DialogueLine.create(
			"Kael",
			"This sounds like... a conversation.",
		),

		# Discovery of the fragment
		DialogueLine.create(
			"Kael",
			"What is this? The chromatic shifts are all wrong."
			+ " Blue to violet to white and back, like it's..."
			+ " breathing.",
		),
		DialogueLine.create(
			"Kael",
			"The emotional register is layered. Contentment and"
			+ " anxiety and curiosity all at once. Echoes don't"
			+ " do that.",
		),

		# Attempt to collect — fragment resists
		DialogueLine.create(
			"Kael",
			"Okay. Easy does it.",
		),
		DialogueLine.create(
			"Kael",
			"...! It flared. It pushed back. That's -- Echoes"
			+ " don't resist collection.",
		),

		# Lyra speaks — the moment that changes everything
		DialogueLine.create(
			"Lyra",
			"...can you hear me?",
		),
		DialogueLine.create(
			"Kael",
			"...",
		),
		DialogueLine.create(
			"Kael",
			"What did you just say?",
		),
		DialogueLine.create(
			"Lyra",
			"You can hear me. Oh-- I wasn't sure anyone"
			+ " would. It's been so long.",
		),

		# Kael's shock and analysis
		DialogueLine.create(
			"Kael",
			"That's not possible. Echoes are recordings."
			+ " They don't have present tense.",
		),
		DialogueLine.create(
			"Kael",
			"But you did. Didn't you?",
		),

		# Kael touches the fragment — sensory flash
		DialogueLine.create(
			"Kael",
			"When I touched it, I felt something. Old paper."
			+ " A lab coat. A city that doesn't exist anymore."
			+ " A heartbeat. Not mine.",
		),

		# --- Section 2: Identity and Structured Fragmentation (8 lines) ---

		# Lyra reveals herself
		DialogueLine.create(
			"Lyra",
			"My name is Lyra. I was a researcher, before the"
			+ " Severance. My memories fractured when the world"
			+ " broke, but I held on.",
		),
		DialogueLine.create(
			"Lyra",
			"Most of what I was scattered. But the core --"
			+ " the part that thinks, that remembers being a"
			+ " person -- I kept that.",
		),

		# Structured fragmentation — how she's different
		DialogueLine.create(
			"Kael",
			"How? Every Echo I've found is a replay. A single"
			+ " emotion on a loop. How are you still... you?",
		),
		DialogueLine.create(
			"Lyra",
			"Because I was already structured when I"
			+ " crystallized. Connected to the Resonance"
			+ " network at the moment of collapse. My"
			+ " consciousness fragmented along existing"
			+ " pathways -- not randomly.",
		),
		DialogueLine.create(
			"Lyra",
			"The pieces retained coherence. Memory. Self."
			+ " Or at least, some of me did.",
		),
		DialogueLine.create(
			"Lyra",
			"I'm not complete. There are gaps. Large ones."
			+ " I remember my name, my work, fragments of"
			+ " who I was. But there are things I should know"
			+ " -- important things -- that are just... static.",
		),
		DialogueLine.create(
			"Kael",
			"Your other fragments. They're out there"
			+ " somewhere?",
		),
		DialogueLine.create(
			"Lyra",
			"Scattered. When the network shattered, pieces"
			+ " of me went with it. Each one holds memories,"
			+ " knowledge, parts of who I was. If they were"
			+ " brought close enough, I could reintegrate them.",
		),

		# --- Section 3: The Sealed Truth (5 lines) ---

		DialogueLine.create(
			"Lyra",
			"There's something else. Something I almost"
			+ " remember. About the Severance. A truth I knew"
			+ " before everything came apart.",
		),
		DialogueLine.create(
			"Lyra",
			"I think I sealed myself in this room. To keep"
			+ " it safe. A truth someone didn't want known.",
		),
		DialogueLine.create(
			"Kael",
			"You sealed yourself? For three hundred years?",
		),
		DialogueLine.create(
			"Lyra",
			"I can feel the shape of it, but the content"
			+ " is in the missing pieces. I need to be more"
			+ " whole to remember.",
		),
		DialogueLine.create(
			"Kael",
			"...That's a long time to protect something"
			+ " you can't even remember.",
		),

		# --- Section 4: Resonance Energy and Fading (3 lines) ---

		DialogueLine.create(
			"Lyra",
			"I should tell you -- I can't sustain this much"
			+ " longer. This formation has been running on"
			+ " residual emotional energy for centuries."
			+ " Running on fumes.",
		),
		DialogueLine.create(
			"Lyra",
			"Human emotional energy. Genuine feeling. That's"
			+ " what powers consciousness, even crystallized"
			+ " consciousness. And I'm almost out.",
		),
		DialogueLine.create(
			"Kael",
			"What happens if you run out?",
		),

		# --- Section 5: The Warning (4 lines) ---

		DialogueLine.create(
			"Lyra",
			"I fade. Slowly. My coherence degrades until"
			+ " I'm just another Echo -- a loop with no one"
			+ " inside it anymore.",
		),
		DialogueLine.create(
			"Lyra",
			"And it's not just me. Something terrible is"
			+ " happening. The other echoes -- the fragments"
			+ " -- they're being drained. Consumed. Someone"
			+ " is harvesting them.",
		),
		DialogueLine.create(
			"Kael",
			"Harvesting echoes? For what?",
		),
		DialogueLine.create(
			"Lyra",
			"I don't know yet. But I can feel them"
			+ " disappearing. Voices going quiet, one by one.",
		),

		# --- Section 6: Emotional Connection (4 lines) ---

		DialogueLine.create(
			"Lyra",
			"Your Resonance is unusual. When you touched"
			+ " the fragment, I could feel you listening."
			+ " Actually listening. Not extracting. Not"
			+ " analyzing.",
		),
		DialogueLine.create(
			"Kael",
			"That's just how I do things. I don't purge"
			+ " Echoes. I keep them.",
		),
		DialogueLine.create(
			"Lyra",
			"Because you think someone should remember."
			+ " I heard that, when you first touched me."
			+ " That's why I reached for you.",
		),
		DialogueLine.create(
			"Kael",
			"I mean... someone should.",
		),

		# --- Section 7: Fragment Quest Hook (4 lines) ---

		DialogueLine.create(
			"Lyra",
			"My other fragments. I can feel them, but not"
			+ " clearly. Deeper in the ruins. My sense of"
			+ " them is fragmented too.",
		),
		DialogueLine.create(
			"Lyra",
			"Be careful. The deeper ruins are more"
			+ " dangerous. The crystal corruption is thicker,"
			+ " and the Echoes there are older.",
		),
		DialogueLine.create(
			"Kael",
			"I've handled angry Echoes before.",
		),
		DialogueLine.create(
			"Lyra",
			"Not like these. These remember why they're"
			+ " angry.",
		),

		# --- Section 8: Resolve and Closing (7 lines) ---

		DialogueLine.create(
			"Kael",
			"I've spent years collecting memories that other"
			+ " hunters would purge. Hundreds of echoes."
			+ " Someone's past deserves to be remembered.",
		),
		DialogueLine.create(
			"Kael",
			"If someone's destroying them... and you're"
			+ " fading... I can't just walk away from that.",
		),
		DialogueLine.create(
			"Lyra",
			"You'd help me? You don't even know what I am.",
		),
		DialogueLine.create(
			"Kael",
			"You're a person who's been alone for a very"
			+ " long time. That's enough for now.",
		),
		DialogueLine.create(
			"Lyra",
			"Thank you, Kael.",
		),
		DialogueLine.create(
			"Kael",
			"Come on. Let's get out of these ruins. I know"
			+ " someone who might understand what you are.",
		),
		DialogueLine.create(
			"Kael",
			"Let's find you, Lyra.",
		),
	]
