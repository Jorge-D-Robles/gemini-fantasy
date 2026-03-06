class_name IronCoast
extends Node

## Chapter 12 — "The Iron Coast" full event.
## Party descends into Gearhaven's Undercity to find Cipher,
## the second Resonance Anchor. Initiative sweep forces escape.
## Cipher grudgingly joins.
##   Scene 1: Going Down — elevator descent into Undercity.
##   Scene 2: The Broken Clock — bar investigation, meet Ratchet.
##   Scene 3: Level Six — server farm exploration.
##   Scene 4: First Contact — meeting Cipher, Initiative ambush.
##   Scene 5: Harbor Water — post-escape, Cipher commits.
##   Scene 6: The Full Picture — Cipher's intelligence briefing.
##   Scene 7: Leaving Gearhaven — departure, ground rules.
##   Camp: Operating Systems — Kael/Cipher night talk.
## Gate: rogue_decided AND NOT cipher_recruited.
## Sets cipher_recruited flag.

signal sequence_completed

const FLAG_NAME: String = "cipher_recruited"


## Returns true when the event is eligible to fire:
##   - rogue_decided flag is set (Act II opening happened)
##   - cipher_recruited flag is NOT set (Cipher not yet found)
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("rogue_decided", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 1 — Going Down: elevator descent into Undercity.
static func compute_descent_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"Three levels down. The Broken Clock is on"
			+ " Level Four -- what the locals call the"
			+ " Shelf.",
		),
		DialogueLine.create(
			"Kael",
			"How many people live down here?",
		),
		DialogueLine.create(
			"Iris",
			"Officially? Zero. The Federation doesn't"
			+ " acknowledge the Undercity exists."
			+ " Unofficially? Five, six thousand. Deserters,"
			+ " debtors, people whose papers got lost by"
			+ " some corporate bureaucrat.",
		),
		DialogueLine.create(
			"Garrick",
			"And the law?",
		),
		DialogueLine.create(
			"Iris",
			"Down here, the law is whoever's got the"
			+ " biggest friends.",
		),
		DialogueLine.create(
			"Kael",
			"It's actually kind of beautiful.",
		),
		DialogueLine.create(
			"Iris",
			"Don't let the locals hear you say that."
			+ " Beautiful isn't the word they'd use.",
		),
		DialogueLine.create(
			"Iris",
			"Stay close. Don't stare. Don't touch"
			+ " anything that glows. And if someone offers"
			+ " to sell you authentic pre-Severance"
			+ " artifacts--",
		),
		DialogueLine.create(
			"Kael",
			"They're fake?",
		),
		DialogueLine.create(
			"Iris",
			"They're stolen. Which is worse, legally.",
		),
	]


## Scene 2 — The Broken Clock: bar investigation, Ratchet lead.
static func compute_bar_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Bartender",
			"Help you?",
		),
		DialogueLine.create(
			"Iris",
			"Three of whatever's cheapest. And"
			+ " information.",
		),
		DialogueLine.create(
			"Bartender",
			"Drinks are five credits each. Information"
			+ " depends on the question.",
		),
		DialogueLine.create(
			"Iris",
			"We're looking for someone. A tech specialist."
			+ " Works with crystal systems in unconventional"
			+ " ways.",
		),
		DialogueLine.create(
			"Kael",
			"This person doesn't use equipment. They"
			+ " interface directly with the crystal network."
			+ " Like they're part of it.",
		),
		DialogueLine.create(
			"Bartender",
			"Don't know anything about that. Drinks?",
		),
		DialogueLine.create(
			"Garrick",
			"We're not Initiative.",
		),
		DialogueLine.create(
			"Garrick",
			"I was a Shepherd for thirty years. The"
			+ " crystal in your head would've been grounds"
			+ " for purging where I come from. I'm not"
			+ " that man anymore.",
		),
		DialogueLine.create(
			"Garrick",
			"These are from purifying corrupted crystals."
			+ " Thirty years of burning things I should"
			+ " have been trying to understand. I'm done"
			+ " burning.",
		),
		DialogueLine.create(
			"Bartender",
			"There's a woman at table six. Name's"
			+ " Ratchet. She runs maintenance on the"
			+ " Undercity power grid.",
		),
		DialogueLine.create(
			"Ratchet",
			"Not interested. Whatever you're selling.",
		),
		DialogueLine.create(
			"Iris",
			"We're buying.",
		),
		DialogueLine.create(
			"Ratchet",
			"Less interested.",
		),
		DialogueLine.create(
			"Ratchet",
			"The person you're looking for. They call"
			+ " themselves Cipher. If you're from the"
			+ " Initiative, congratulations -- you've found"
			+ " breadcrumbs they left to waste your time.",
		),
		DialogueLine.create(
			"Ratchet",
			"Cipher saved my life. Crystal infection in"
			+ " my optical nerve. They put their hand on my"
			+ " face and the crystal stopped. Just stopped."
			+ " Then they pulled it out.",
		),
		DialogueLine.create(
			"Ratchet",
			"There's an old server farm on Level Six."
			+ " Cipher goes there every Thursday to pull"
			+ " data. Today is Thursday.",
		),
	]


## Scene 3 — Level Six: server farm exploration.
static func compute_server_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"This is ancient infrastructure. Pre-Severance"
			+ " data storage. Most of it's corrupted beyond"
			+ " recovery, but the hardware itself... the"
			+ " Initiative would kill for this equipment.",
		),
		DialogueLine.create(
			"Kael",
			"Maybe that's why Cipher uses it. Hiding in"
			+ " plain sight.",
		),
		DialogueLine.create(
			"Garrick",
			"It's cold here. My skin's crawling."
			+ " Something here is active.",
		),
		DialogueLine.create(
			"Iris",
			"That's not random. That's a signal.",
		),
		DialogueLine.create(
			"Kael",
			"Or a warning.",
		),
	]


## Scene 4 — First Contact: meeting Cipher, Initiative ambush.
static func compute_contact_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Took you long enough.",
		),
		DialogueLine.create(
			"Cipher",
			"Relax, Military. I've been watching you"
			+ " since the elevator. Camera network on"
			+ " Level Two, motion sensors on Four, and"
			+ " Ratchet sent me a message.",
		),
		DialogueLine.create(
			"Cipher",
			"Let me save you the pitch. You're Kael Voss,"
			+ " Resonance Anchor. You're Iris Mantle,"
			+ " deserter with a faulty prosthetic. And"
			+ " you're Garrick Thorne, ex-Shepherd,"
			+ " currently questioning everything.",
		),
		DialogueLine.create(
			"Kael",
			"You already know everything.",
		),
		DialogueLine.create(
			"Cipher",
			"I know everything the Initiative's network"
			+ " knows. I've been in their systems for eight"
			+ " months. Their security is embarrassing.",
		),
		DialogueLine.create(
			"Cipher",
			"What I don't know is why I should go with"
			+ " you.",
		),
		DialogueLine.create(
			"Iris",
			"You're in danger.",
		),
		DialogueLine.create(
			"Cipher",
			"I've been in danger since I was sixteen."
			+ " I've outrun, outhacked, and outlasted every"
			+ " team they've sent.",
		),
		DialogueLine.create(
			"Garrick",
			"The Initiative is building a device called"
			+ " the Resonance Cage. It needs Anchors as"
			+ " power sources. Not operators. Batteries.",
		),
		DialogueLine.create(
			"Cipher",
			"I know about the Cage. I've seen the"
			+ " schematics. Vex has been sourcing materials"
			+ " for two years.",
		),
		DialogueLine.create(
			"Kael",
			"And you didn't tell anyone?",
		),
		DialogueLine.create(
			"Cipher",
			"Tell who? The Free Resonants have no teeth."
			+ " The Shepherds would kill me for being an"
			+ " Anchor. I was handling it. Corrupting their"
			+ " data, misdirecting their search teams.",
		),
		DialogueLine.create(
			"Cipher",
			"Initiative sweep team. Twelve agents, Level"
			+ " Four, working down. They've sealed the main"
			+ " elevator. They've got Resonance dampeners.",
		),
		DialogueLine.create(
			"Iris",
			"How did they find us?",
		),
		DialogueLine.create(
			"Cipher",
			"They didn't find you. They found me. My last"
			+ " data pull tripped a new firewall. I was"
			+ " sloppy. I was distracted.",
		),
		DialogueLine.create(
			"Cipher",
			"There's a conduit shaft that vents to the"
			+ " harbor waterline. Ten-meter vertical climb"
			+ " and a three-meter drop into the ocean.",
		),
		DialogueLine.create(
			"Garrick",
			"I can climb.",
		),
		DialogueLine.create(
			"Cipher",
			"In full plate?",
		),
		DialogueLine.create(
			"Garrick",
			"I've climbed worse in worse.",
		),
		DialogueLine.create(
			"Kael",
			"Come with us. Not because we're heroes. Not"
			+ " because we've got a plan. Because you've"
			+ " been alone down here for sixteen years and"
			+ " it's not working.",
		),
		DialogueLine.create(
			"Cipher",
			"Alone keeps me alive.",
		),
		DialogueLine.create(
			"Cipher",
			"Fine. But I'm not joining your quest. I'm"
			+ " making a tactical retreat with available"
			+ " assets. There's a difference.",
		),
		DialogueLine.create(
			"Iris",
			"Whatever you need to call it. Move.",
		),
	]


## Scene 5 — Harbor Water: post-escape, Cipher commits.
static func compute_harbor_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Sixteen years. Sixteen years of operating"
			+ " infrastructure and I just swan-dived out"
			+ " of it.",
		),
		DialogueLine.create(
			"Kael",
			"You can rebuild.",
		),
		DialogueLine.create(
			"Cipher",
			"That's not the point. I had a system."
			+ " Redundancies. Backup locations, cached"
			+ " supplies, three different identities."
			+ " And it's all burned.",
		),
		DialogueLine.create(
			"Cipher",
			"Sorry. You didn't cause this. The Initiative"
			+ " did.",
		),
		DialogueLine.create(
			"Iris",
			"Scared.",
		),
		DialogueLine.create(
			"Cipher",
			"Don't put words in my--",
		),
		DialogueLine.create(
			"Iris",
			"I deserted two years ago. I know exactly"
			+ " what this feels like. The part where the"
			+ " ground under your feet turns out to be"
			+ " paper and the only thing between you and"
			+ " the bottom is the people next to you.",
		),
		DialogueLine.create(
			"Cipher",
			"You get it.",
		),
		DialogueLine.create(
			"Iris",
			"I get it.",
		),
		DialogueLine.create(
			"Garrick",
			"Cipher -- are you with us? Not forever. Not"
			+ " a commitment. Just tonight.",
		),
		DialogueLine.create(
			"Cipher",
			"Tonight. And then we reassess.",
		),
		DialogueLine.create(
			"Kael",
			"That's all we're asking.",
		),
		DialogueLine.create(
			"Cipher",
			"Also, someone needs to tell me about this"
			+ " Lyra. An actual Conscious Echo? The"
			+ " theoretical models say that's impossible.",
		),
	]


## Scene 6 — The Full Picture: Cipher's intelligence briefing.
static func compute_briefing_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Crash course. I've been inside the"
			+ " Initiative's classified network for eight"
			+ " months. Here's what I know.",
		),
		DialogueLine.create(
			"Cipher",
			"Three Resonance Anchors. Kael -- that's you."
			+ " Me. And a third, location unknown but the"
			+ " Initiative has a team in the Cindral Wastes"
			+ " looking. Code name: Asset Ember.",
		),
		DialogueLine.create(
			"Kael",
			"The Cindral Wastes. Lyra said north.",
		),
		DialogueLine.create(
			"Lyra",
			"That aligns with what I sensed. A young"
			+ " signal. Strong but uncontrolled.",
		),
		DialogueLine.create(
			"Cipher",
			"The Resonance Cage. Vex's masterpiece."
			+ " Designed to contain the Convergence using"
			+ " three Anchors as stabilization points."
			+ " Without all three, it can't function.",
		),
		DialogueLine.create(
			"Iris",
			"So if we keep even one Anchor away from"
			+ " Vex--",
		),
		DialogueLine.create(
			"Cipher",
			"The Cage can't activate. But here's the fun"
			+ " part. Vex isn't just building the Cage."
			+ " He's been running parallel operations"
			+ " across all five domains.",
		),
		DialogueLine.create(
			"Cipher",
			"He's got agents in the Shepherd hierarchy."
			+ " He's been funding both sides of every"
			+ " conflict. Every war, every refugee crisis"
			+ " feeds back into the Cage somehow.",
		),
		DialogueLine.create(
			"Garrick",
			"That's monstrous.",
		),
		DialogueLine.create(
			"Cipher",
			"It's efficient. Which is worse.",
		),
		DialogueLine.create(
			"Kael",
			"How long until the Cage is operational?",
		),
		DialogueLine.create(
			"Cipher",
			"Based on supply chain data... three months."
			+ " Maybe four. Vex doesn't hit complications."
			+ " He plans around them.",
		),
		DialogueLine.create(
			"Nyx",
			"What happens to the Anchors inside?",
		),
		DialogueLine.create(
			"Cipher",
			"The power requirements are significant. An"
			+ " Anchor inside the Cage would need constant"
			+ " Resonance output. Indefinitely.",
		),
		DialogueLine.create(
			"Nyx",
			"Would they still be themselves?",
		),
		DialogueLine.create(
			"Cipher",
			"No. They'd be Hollow within days. Conscious"
			+ " but empty. A living battery. That's what"
			+ " I've been running from.",
		),
		DialogueLine.create(
			"Lyra",
			"Then we have three months to make sure that"
			+ " never happens.",
		),
		DialogueLine.create(
			"Cipher",
			"You're not possible. A Conscious Echo"
			+ " maintaining identity across three hundred"
			+ " years of fragmentation. The energy"
			+ " requirements alone should have dissipated"
			+ " you centuries ago.",
		),
		DialogueLine.create(
			"Lyra",
			"And yet here I am.",
		),
		DialogueLine.create(
			"Cipher",
			"Which means either our understanding of Echo"
			+ " mechanics is wrong, or you're something"
			+ " different from what you're telling us.",
		),
		DialogueLine.create(
			"Lyra",
			"Everyone is hiding something, Cipher. The"
			+ " question is whether they're hiding it from"
			+ " others or from themselves.",
		),
		DialogueLine.create(
			"Cipher",
			"Cryptic. I hate cryptic. But fine. I'm"
			+ " monitoring your Resonance output. If"
			+ " something doesn't add up, I'll know.",
		),
	]


## Scene 7 — Leaving Gearhaven: departure, Cipher's ground rules.
static func compute_departure_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"For the record, I'm establishing ground"
			+ " rules. One: don't touch my equipment."
			+ " Two: don't ask me to open up or share"
			+ " my feelings.",
		),
		DialogueLine.create(
			"Cipher",
			"Three: if I say we need to move, we move."
			+ " Four: if staying is more dangerous than"
			+ " being alone, I leave. No hard feelings.",
		),
		DialogueLine.create(
			"Iris",
			"Those are reasonable.",
		),
		DialogueLine.create(
			"Kael",
			"Fair enough.",
		),
		DialogueLine.create(
			"Cipher",
			"You're not going to argue?",
		),
		DialogueLine.create(
			"Kael",
			"Would it help?",
		),
		DialogueLine.create(
			"Cipher",
			"No.",
		),
		DialogueLine.create(
			"Nyx",
			"Cipher. Your tattoos are very beautiful."
			+ " Do they hurt?",
		),
		DialogueLine.create(
			"Cipher",
			"They're Resonance channels. They help me"
			+ " interface with--",
		),
		DialogueLine.create(
			"Nyx",
			"But they're also beautiful. Both things can"
			+ " be true.",
		),
		DialogueLine.create(
			"Cipher",
			"Yeah. Both things can be true. Thanks, kid.",
		),
		DialogueLine.create(
			"Lyra",
			"We should move. The Cindral Wastes are a"
			+ " week's travel on foot.",
		),
		DialogueLine.create(
			"Iris",
			"There's a supply route through the mountain"
			+ " pass. Smuggler-maintained. Cuts the journey"
			+ " to four days.",
		),
		DialogueLine.create(
			"Garrick",
			"Dangerous?",
		),
		DialogueLine.create(
			"Iris",
			"Everything's dangerous. At least this is"
			+ " dangerous and fast.",
		),
		DialogueLine.create(
			"Kael",
			"One Anchor found. One to go. Then we figure"
			+ " out what comes next.",
		),
		DialogueLine.create(
			"Cipher",
			"I love how you say that like what comes next"
			+ " isn't possibly the end of the world.",
		),
		DialogueLine.create(
			"Kael",
			"I'm choosing to take it one apocalypse at"
			+ " a time.",
		),
	]


## Camp — Operating Systems: Kael/Cipher night talk.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Can't sleep?",
		),
		DialogueLine.create(
			"Cipher",
			"Sleep is for people who don't have bounties.",
		),
		DialogueLine.create(
			"Kael",
			"What was it like? Touching the network for"
			+ " the first time.",
		),
		DialogueLine.create(
			"Cipher",
			"I was sixteen. Factory job -- electronics"
			+ " recycling. I grabbed a terminal still"
			+ " connected to the crystal grid and"
			+ " everything opened up. Like I'd been hearing"
			+ " the world through a wall and someone pulled"
			+ " the wall away.",
		),
		DialogueLine.create(
			"Cipher",
			"I could feel the data. Not read it -- feel"
			+ " it. Every message, every transaction, every"
			+ " surveillance feed. And underneath, this"
			+ " hum. Deep. Old. Like something sleeping.",
		),
		DialogueLine.create(
			"Kael",
			"The Convergence.",
		),
		DialogueLine.create(
			"Cipher",
			"I didn't know that then. I just knew it"
			+ " scared me. Then the Initiative kicked in"
			+ " my door three days later and I've been"
			+ " running since.",
		),
		DialogueLine.create(
			"Kael",
			"I'm sorry.",
		),
		DialogueLine.create(
			"Cipher",
			"Don't be sorry. Be effective. You said"
			+ " something in the server farm. That being"
			+ " alone makes you sloppy. Was that real?",
		),
		DialogueLine.create(
			"Kael",
			"I don't do an inspirational leader thing."
			+ " I do a barely holding it together and"
			+ " hoping nobody notices thing.",
		),
		DialogueLine.create(
			"Cipher",
			"That's weirdly reassuring. Because it means"
			+ " you're not performing. You're just scared"
			+ " and doing it anyway.",
		),
		DialogueLine.create(
			"Cipher",
			"That's not nothing.",
		),
		DialogueLine.create(
			"Cipher",
			"Get some sleep, Anchor. Tomorrow we figure"
			+ " out how to cross a continent while being"
			+ " hunted by everyone.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 1: Going Down — elevator descent
	DialogueManager.start_dialogue(compute_descent_lines())
	await DialogueManager.dialogue_ended

	# Scene 2: The Broken Clock — bar investigation
	DialogueManager.start_dialogue(compute_bar_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: Level Six — server farm
	DialogueManager.start_dialogue(compute_server_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: First Contact — meeting Cipher, ambush
	DialogueManager.start_dialogue(compute_contact_lines())
	await DialogueManager.dialogue_ended

	# Scene 5: Harbor Water — post-escape
	DialogueManager.start_dialogue(compute_harbor_lines())
	await DialogueManager.dialogue_ended

	# Scene 6: The Full Picture — intelligence briefing
	DialogueManager.start_dialogue(compute_briefing_lines())
	await DialogueManager.dialogue_ended

	# Scene 7: Leaving Gearhaven — departure
	DialogueManager.start_dialogue(compute_departure_lines())
	await DialogueManager.dialogue_ended

	# Camp: Operating Systems — night talk
	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()
