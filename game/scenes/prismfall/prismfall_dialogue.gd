class_name PrismfallDialogue
extends RefCounted

## Flag-reactive NPC dialogue for Prismfall town scene.
## All functions are static: take a flags dictionary, return PackedStringArray.


static func get_innkeeper_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("lyras_truth_seen", false):
		return PackedStringArray([
			"You look like you've seen something terrible"
			+ " down in the canyon. I know that look.",
			"Rest as long as you need. The room's yours.",
		])
	if flags.get("prismfall_arrived", false):
		return PackedStringArray([
			"Welcome to the Prism's Edge! Best views"
			+ " in the Steppes, and I'm not just saying"
			+ " that because I charge extra for the"
			+ " balcony rooms.",
			"The canyon lights up at dawn. Worth waking"
			+ " early for, if you're the type.",
			"You look road-weary. Rest here tonight."
			+ " Your party has been fully restored.",
		])
	return PackedStringArray([
		"Welcome, traveler! The Prism's Edge has"
		+ " rooms with a view of the canyon. Crystal"
		+ " light at dawn is something else entirely.",
		"First time in Prismfall? You picked a good"
		+ " season. The traders are in from every region.",
	])


static func get_shopkeeper_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("lyras_truth_seen", false):
		return PackedStringArray([
			"Word is something big happened in the canyon."
			+ " The crystal traders are nervous. Prices might"
			+ " go up.",
			"Stock up while you can. I've got steel and"
			+ " crystal gear, best you'll find south of"
			+ " Emberhearth.",
		])
	if flags.get("prismfall_arrived", false):
		return PackedStringArray([
			"Prismfall Arms, at your service. We stock"
			+ " equipment from every region — steel from"
			+ " the Federation, crystal-forged from the"
			+ " Steppes, herbs from the Tangle.",
			"Heading into the canyon? You'll want"
			+ " something sturdier than what you're"
			+ " carrying.",
		])
	return PackedStringArray([
		"Prismfall Arms — best selection in the"
		+ " southern Steppes. Browse at your leisure.",
	])


static func get_archivist_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("lyras_truth_seen", false):
		return PackedStringArray([
			"The Resonance burst from the canyon..."
			+ " our instruments detected it all the way up"
			+ " here. Whatever you found down there, it was"
			+ " significant.",
			"The Convergence. We have fragments of records"
			+ " that mention it. Most scholars thought it was"
			+ " myth. A unified consciousness, they said,"
			+ " impossible.",
			"Yet here we are. Three hundred years of"
			+ " fragments and echoes, and the truth was"
			+ " buried in crystal the whole time.",
		])
	if flags.get("prismfall_arrived", false):
		return PackedStringArray([
			"The Archives contain records from seventeen"
			+ " pre-Severance research stations. Most are"
			+ " fragmentary, but some mention a global"
			+ " consciousness network.",
			"Your crystal fragment... may I? Fascinating."
			+ " The resonance signature matches samples"
			+ " from deep in the canyon. Sixty million"
			+ " years of crystallized memory down there.",
			"The Crystalline Warden guards the deepest"
			+ " formations. Old records describe it as"
			+ " a living geological structure. Be careful"
			+ " if you descend.",
		])
	return PackedStringArray([
		"Welcome to the Prismfall Archives. We collect"
		+ " and preserve pre-Severance records. Most are"
		+ " fragments, but every piece matters.",
		"If you're an Echo hunter, we may have work for"
		+ " you. The canyon produces uncatalogued echoes"
		+ " regularly.",
	])


static func get_trader_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("lyras_truth_seen", false):
		return PackedStringArray([
			"The crystal traders pulled out overnight."
			+ " Something spooked them. Canyon's been"
			+ " humming louder than usual.",
		])
	return PackedStringArray([
		"Goods from every corner of Aethermoor pass"
		+ " through this market. Emberhearth steel,"
		+ " Tangle herbs, Federation tech parts.",
		"Best prices you'll find south of the Wastes.",
	])


static func get_canyon_resident_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("lyras_truth_seen", false):
		return PackedStringArray([
			"Did you feel that? The whole canyon shook"
			+ " earlier. The crystals went bright white"
			+ " for a second. Never seen that before.",
		])
	return PackedStringArray([
		"I've lived on the canyon edge for twenty years."
		+ " The crystal light at dawn never gets old.",
		"Watch your step near the south path. The"
		+ " canyon drops off sharp down there.",
	])
