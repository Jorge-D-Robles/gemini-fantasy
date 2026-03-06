class_name EmberhearthDialogue
extends RefCounted

## Flag-reactive NPC dialogue for Emberhearth city.
## Dialogue changes based on story progression flags:
##   default       — first arrival, before Ash is found
##   ash_found     — after FireAndAsh event completes
##   siege_started — during/after Siege of Emberhearth


static func get_innkeeper_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("ash_found", false):
		return PackedStringArray([
			"The Ash Walkers brought that child here"
			+ " weeks ago. Strange one — never speaks,"
			+ " but you can feel something when they're"
			+ " near. Rest well, traveler.",
		])
	return PackedStringArray([
		"Welcome to The Cooling Stone. The caldera"
		+ " keeps us warm, and the geothermal vents"
		+ " heat the water. Rest here and your party"
		+ " will be fully restored.",
	])


static func get_blacksmith_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("ash_found", false):
		return PackedStringArray([
			"The volcanic ore here makes the finest"
			+ " steel in the Wastes. With what's coming,"
			+ " you'll need every edge I can forge.",
		])
	return PackedStringArray([
		"The Forge Quarter has been hammering steel"
		+ " since before the Severance. The volcanic"
		+ " heat gives our blades an edge no other"
		+ " smithy can match.",
	])


static func get_shopkeeper_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("ash_found", false):
		return PackedStringArray([
			"Stock up while you can. The Shepherds"
			+ " have been spotted on the Scorched Road."
			+ " Prices haven't changed — we look after"
			+ " our own here.",
		])
	return PackedStringArray([
		"We trade in everything the caravans bring"
		+ " through. Weapons, armor, supplies — the"
		+ " Rim market has it all. Take a look.",
	])


static func get_kamara_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("ash_found", false):
		return PackedStringArray([
			"The child you seek is sacred to us. The"
			+ " Ash Walkers have guarded them since the"
			+ " day they appeared in the caldera — born"
			+ " from the Resonance itself. Treat them"
			+ " with reverence.",
		])
	return PackedStringArray([
		"The Ash Walkers have walked these wastes"
		+ " for generations. We guide travelers through"
		+ " the volcanic passages and guard the old"
		+ " ways. You are welcome in Emberhearth, but"
		+ " tread carefully in The Deep.",
	])


static func get_refugee_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("ash_found", false):
		return PackedStringArray([
			"First we lost our homes to the Resonance"
			+ " storms. Now they say an army is coming."
			+ " Where do we go from here?",
		])
	return PackedStringArray([
		"The Rim isn't much, but it's shelter. The"
		+ " caldera walls keep the ash storms out, and"
		+ " the geothermal vents keep us warm. We've"
		+ " built what we can from salvage.",
	])
