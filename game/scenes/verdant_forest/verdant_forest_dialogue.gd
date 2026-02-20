class_name VerdantForestDialogue
extends RefCounted

## Static dialogue data for Verdant Forest entry scenes.
## All functions are static: pure data, no scene dependency.


## Returns dialogue lines for the full-party traversal moment
## (gated by garrick_recruited, fires once via forest_traversal_full_party).
## Three-person party comments as they cross toward the Overgrown Ruins:
##   Garrick notes crystal density, Iris assesses threat, Kael orients.
static func get_traversal_lines() -> Array:
	return [
		{
			"speaker": "Garrick",
			"text": "Crystal density is rising."
				+ " We're entering the old capital's growth cluster."
				+ " I've handled corruption like this before"
				+ " \u2014 it runs deeper than it looks.",
		},
		{
			"speaker": "Iris",
			"text": "Fragment tracker confirms it."
				+ " Signal's up forty percent since Roothollow."
				+ " The Initiative's survey teams will be picking"
				+ " this up too. We can't take the main path.",
		},
		{
			"speaker": "Kael",
			"text": "Overgrown Ruins are directly west."
				+ " We move fast, stay quiet \u2014 market district"
				+ " entrance, then northeast toward"
				+ " the research quarter.",
		},
		{
			"speaker": "Garrick",
			"text": "Stay close. I take point at chokepoints."
				+ " Call your targets before you act."
				+ " We keep each other alive.",
		},
	]


## Returns the one-shot flag name that prevents this dialogue from
## firing a second time.
static func get_traversal_flag() -> String:
	return "forest_traversal_full_party"


## Returns the gate flag that must be set before the dialogue fires.
static func get_traversal_gate_flag() -> String:
	return "garrick_recruited"
