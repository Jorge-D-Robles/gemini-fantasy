class_name GearhavenDialogue
extends RefCounted

## Flag-reactive NPC dialogue for Gearhaven city.
## Dialogue changes based on story progression flags:
##   default             — first arrival
##   iron_coast_arrived  — after Chapter 12 events


static func get_innkeeper_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("iron_coast_arrived", false):
		return PackedStringArray([
			"Word travels fast in Gearhaven. The Initiative"
			+ " is stirring — more patrols, more checkpoints."
			+ " You look like you could use a quiet room."
			+ " Rest here. Your party will be restored.",
		])
	return PackedStringArray([
		"Welcome to The Brass Lantern. Best beds"
		+ " on the west side of the Harbor. The sheets"
		+ " are clean, the ale is cold, and we don't"
		+ " ask questions. Rest well.",
	])


static func get_tech_shop_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("iron_coast_arrived", false):
		return PackedStringArray([
			"The Initiative has been buying up weapons"
			+ " in bulk. Supply is tight, but I kept some"
			+ " of the good stuff in the back for paying"
			+ " customers. Take a look.",
		])
	return PackedStringArray([
		"Gearhaven Tech Emporium — finest equipment"
		+ " this side of the Federation. Resonance"
		+ " Blades, Arc Staffs, Chrome Repeaters."
		+ " If it can be forged or machined, we sell it.",
	])


static func get_armor_shop_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("iron_coast_arrived", false):
		return PackedStringArray([
			"The factory's running double shifts. The"
			+ " Initiative wants armor for their new"
			+ " recruits, but I still supply independent"
			+ " adventurers. We don't discriminate.",
		])
	return PackedStringArray([
		"Factory-fresh armor, straight from the"
		+ " foundry floor. Reinforced Coats, Alloy"
		+ " Helms — all forged right here in the"
		+ " Factory District. Nothing beats Gearhaven"
		+ " craftsmanship.",
	])


static func get_harbor_master_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("iron_coast_arrived", false):
		return PackedStringArray([
			"The Initiative closed the northern shipping"
			+ " lanes. No trade, no fishing, no nothing."
			+ " Half the harbor crews are out of work."
			+ " Something big is happening up at The Spire.",
		])
	return PackedStringArray([
		"Gearhaven Harbor — busiest port in the"
		+ " Ironcoast. Ships from everywhere dock"
		+ " here. If you need passage anywhere along"
		+ " the coast, this is the place to arrange it.",
	])


static func get_initiative_officer_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("iron_coast_arrived", false):
		return PackedStringArray([
			"Director Hale has declared a security"
			+ " emergency. All unauthorized Resonance"
			+ " research is to be reported. This is for"
			+ " the safety of all citizens.",
		])
	return PackedStringArray([
		"The Reclamation Initiative keeps Gearhaven"
		+ " safe and prosperous. Director Hale's vision"
		+ " for a united Federation benefits everyone."
		+ " Move along, citizen.",
	])


static func get_underground_contact_dialogue(
	flags: Dictionary,
) -> PackedStringArray:
	if flags.get("iron_coast_arrived", false):
		return PackedStringArray([
			"You hear things, down in the Undercity."
			+ " Whispers about secret labs beneath The"
			+ " Spire. People going in, not coming out."
			+ " If you're looking for answers, you'll"
			+ " need to go deeper.",
		])
	return PackedStringArray([
		"Psst. You look like you're not from around"
		+ " here. The Undercity has what the shops"
		+ " above don't. Echoes, information, contacts."
		+ " But everything down here has a price.",
	])
