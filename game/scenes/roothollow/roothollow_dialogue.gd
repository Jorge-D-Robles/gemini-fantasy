class_name RoothollowDialogue
extends RefCounted

## Flag-reactive NPC dialogue for Roothollow scene.
## Each NPC has different lines based on EventFlags state.
## All functions are static: take a flags dictionary, return PackedStringArray.


static func get_maren_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"Old Iron himself, traveling with my favorite Echo"
			+ " hunter. Now that's a sight.",
			"Garrick used to pass through years ago. Always"
			+ " ordered the same thing \u2014 black tea, no sugar."
			+ " Sat in the corner and watched the door.",
			"He's a good man, Kael. Whatever he's running from,"
			+ " he's running toward something better now.",
			"You take care of each other out there."
			+ " And come back for stew when you can.",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"So you've brought company! A soldier, by the look"
			+ " of her. Or... former soldier?",
			"Don't worry, I don't pry. Anyone who fights"
			+ " alongside Kael is welcome at my table.",
			"That arm of hers... Resonance-powered, isn't it?"
			+ " Haven't seen Initiative tech this far east"
			+ " in years.",
			"I'll set out extra bowls."
			+ " You all look like you could use a real meal.",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"There you are! Half the village was worried sick."
			+ " You were gone longer than usual.",
			"You found something in the ruins?"
			+ " Something... alive?",
			"I won't pretend to understand echoes the way you"
			+ " do. But if this one can speak,"
			+ " that changes things.",
			"The world's been holding its breath for three"
			+ " hundred years, Kael."
			+ " Maybe it's finally ready to exhale.",
			"Rest here tonight. Whatever comes next,"
			+ " you'll face it better on a full stomach.",
		])
	return PackedStringArray([
		"Kael! Come in, come in. You look like you haven't"
		+ " eaten since yesterday. ...You haven't, have you?",
		"The stew's still warm."
		+ " Sit down before you fall down.",
		"I heard you're heading out to the old ruins again."
		+ " Please be careful."
		+ " The echoes have been stranger lately.",
		"A trader from Prismfall passed through last week."
		+ " Said the roads south are crawling with corrupted"
		+ " creatures. Stay close to the forest paths,"
		+ " will you?",
	])


static func get_bram_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"Garrick Thorne is with you?"
			+ " THE Garrick Thorne?"
			+ " The man's a legend around here.",
			"He saved a caravan from crystal-corrupted wolves"
			+ " ten years back. Single-handedly held the pass"
			+ " while they escaped.",
			"If he's decided to travel with you, then whatever"
			+ " you're doing must be important."
			+ " Or incredibly dangerous. ...Or both.",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"Your new friend... she's from the Ironcoast,"
			+ " isn't she? I can tell by the armor.",
			"N-not that there's anything wrong with that!"
			+ " The Federation makes good gear."
			+ " Very reliable. Very... heavily armed.",
			"Actually, if she has any contacts in the supply"
			+ " chain, I'd love an introduction."
			+ " Strictly business!",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"Everyone's talking about what you found in the"
			+ " ruins. A conscious echo?"
			+ " That's... that's not supposed to happen,"
			+ " is it?",
			"I don't like it, Kael. Change is coming, and"
			+ " change is bad for business."
			+ " Change is bad for everything.",
			"The caravan still hasn't arrived."
			+ " I'm starting to think something happened"
			+ " on the road.",
			"If you run into any traders out there, tell them"
			+ " Roothollow is paying double for medical"
			+ " supplies. Triple, even. I don't care.",
		])
	return PackedStringArray([
		"Oh, Kael. Good timing. Well... actually,"
		+ " terrible timing.",
		"The supply caravan from Prismfall is three days"
		+ " late. Three days!"
		+ " That's never happened before.",
		"I've got some basic provisions left, but the good"
		+ " equipment? Gone. Bought up by a group of"
		+ " hunters heading south.",
		"If you're heading to the ruins, I can spare a"
		+ " couple of salves."
		+ " It's not much, but it's what I've got.",
	])


static func get_thessa_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"A conscious Echo, and now Garrick Thorne at your"
			+ " side. The winds of change blow faster than"
			+ " I expected.",
			"The Council at Prismfall must hear about this."
			+ " A conscious Echo changes everything we"
			+ " thought we knew about the Severance.",
			"The road south is dangerous \u2014 corrupted beasts,"
			+ " Shepherd patrols, and worse."
			+ " But you have allies now.",
			"An Echo hunter, an engineer, and a penitent"
			+ " knight. The echoes brought you together for a"
			+ " reason. Trust that.",
			"Go, Kael. Prismfall awaits. And when the path"
			+ " divides, trust each other more than you trust"
			+ " the world. This is only the beginning.",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"An Initiative deserter."
			+ " Interesting company you're keeping.",
			"Don't look surprised \u2014 I recognize the armor"
			+ " modifications. She's stripped the insignias,"
			+ " but the alloy is unmistakable."
			+ " Gearhaven titanium-crystal composite.",
			"The fact that she left the Initiative tells me"
			+ " more about her character than anything she"
			+ " could say. It takes courage to walk away"
			+ " from power.",
			"But be careful. The Initiative doesn't let its"
			+ " assets go quietly. If they're looking for"
			+ " her, they may eventually look here.",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"A conscious echo. I've read theories... fragments"
			+ " of old research papers recovered from the"
			+ " capital. But I never believed it possible.",
			"Do you know what this means, Kael? Echoes are"
			+ " crystallized memory \u2014 fragments of lives"
			+ " lived and lost. If one has achieved"
			+ " consciousness...",
			"...then the boundary between what was and what"
			+ " is may be thinner than we thought.",
			"The Shepherds of Silence would destroy her on"
			+ " sight. The Reclamation Initiative would cage"
			+ " her and study her."
			+ " Neither can learn of this.",
			"Protect her, Kael. And listen to what she has to"
			+ " say. The dead don't speak without reason.",
		])
	return PackedStringArray([
		"Ah, Kael. I was wondering when you'd visit."
		+ " The crystals in my study have been humming"
		+ " all morning.",
		"You're heading to the ruins again. I can see it"
		+ " in your eyes \u2014 that restless look you get"
		+ " when the echoes call.",
		"Before you go, a word of caution. The echoes in"
		+ " the old capital have been... different lately."
		+ " More coherent. Almost purposeful.",
		"In all my years studying Resonance, I've never"
		+ " felt anything like it. It's as if something"
		+ " buried is trying to wake up.",
		"Trust your instincts out there. You've always had"
		+ " an unusual connection to the echoes."
		+ " That's a gift, not a curse.",
	])


static func get_wren_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"I know Garrick by reputation. Twenty years of"
			+ " guarding trade routes, purifying corrupted"
			+ " zones, the whole legend.",
			"With him, Iris, and you? You might actually"
			+ " survive what's out there."
			+ " High praise from me.",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"Your new companion handles herself well."
			+ " I watched her take down a crystal-shard"
			+ " serpent near the forest edge without"
			+ " breaking stride.",
			"That arm of hers packs a punch. Literally."
			+ " The serpent didn't know what hit it.",
			"Good. You're going to need someone who can"
			+ " fight. The creatures between here and the"
			+ " ruins aren't getting any friendlier.",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"You came back from the ruins looking like you'd"
			+ " seen a ghost."
			+ " Or... whatever's worse than a ghost.",
			"Look, I don't need details. But if something's"
			+ " changing in there, I need to know."
			+ " My job is keeping this village safe.",
			"The Verdant Forest has been restless since you"
			+ " got back. More echo activity, more corrupted"
			+ " beasts. Like something stirred them up.",
			"If you're going out again, stick to the main"
			+ " paths. And maybe bring a friend or two.",
		])
	return PackedStringArray([
		"Heading out? The western trail's clear, but I"
		+ " wouldn't stray too far south. Saw tracks.",
		"Big ones. Not wolves. Something... wrong."
		+ " Crystal growths where the paw prints"
		+ " should be.",
		"The forest is getting worse. Used to be you'd"
		+ " see a corrupted creature once a month."
		+ " Now it's every other day.",
	])


static func get_garrick_casual_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"Word travels fast in a small village."
			+ " You found something unusual in the ruins.",
			"A conscious echo... I once served people who"
			+ " would have called that an abomination."
			+ " I've since learned not to trust their"
			+ " definitions.",
			"You're in over your head, kid. No offense."
			+ " What you've found \u2014 it'll attract attention."
			+ " The kind that arrives with swords drawn.",
			"If I were you, I'd find allies. Real ones."
			+ " Not the kind who smile when they want"
			+ " something.",
		])
	return PackedStringArray([
		"Hmm. You're young for an Echo hunter. Then again,"
		+ " the young ones are usually the bravest."
		+ " Or the most foolish.",
		"Don't take that the wrong way."
		+ " I've been both in my time.",
		"This village... it's peaceful. Reminds me of"
		+ " places that don't exist anymore."
		+ " Enjoy it while it lasts.",
	])


static func get_lina_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("garrick_recruited", false):
		return PackedStringArray([
			"The big man with the shield told me a story"
			+ " about a knight who fought a dragon made"
			+ " of memories!",
			"He's kinda scary but also kinda nice."
			+ " Like a grumpy grandpa.",
			"Are you going on an adventure? A REAL adventure?"
			+ " Bring me back something cool!",
		])
	if flags.get("iris_recruited", false):
		return PackedStringArray([
			"Your friend has a SHINY ARM!"
			+ " Is it made of crystal? Can I touch it?",
			"She said maybe later."
			+ " That's grown-up talk for no, isn't it?",
		])
	if flags.get("opening_lyra_discovered", false):
		return PackedStringArray([
			"Everyone's acting all serious today."
			+ " Did something happen?",
			"My pretty rock started glowing last night!"
			+ " Just for a second. Then it stopped.",
			"Mama told me to throw it away, but I hid it"
			+ " under my pillow instead."
			+ " Don't tell, okay?",
		])
	return PackedStringArray([
		"Kael! Kael! Look what I found by the river!",
		"It's a pretty rock. See how it shines? Mama says"
		+ " it's just quartz, but I think it's an echo."
		+ " A tiny one.",
		"When I hold it up to my ear, I can almost hear"
		+ " someone singing. Is that weird?",
		"When I grow up, I want to be an Echo hunter like"
		+ " you! I'll have a big journal and everything!",
	])
