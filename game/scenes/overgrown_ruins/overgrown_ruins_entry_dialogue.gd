class_name OvergrownRuinsEntryDialogue
extends RefCounted

## Static dialogue data for the Overgrown Capital entry scene.
## Fires once when the full party (including Garrick) first enters the ruins.
## All functions are static: pure data, no scene dependency.
## Source: docs/story/act1/05-into-the-capital.md — Scene 1 "The Gates"


## Returns dialogue lines for the party's first entry into the Overgrown Capital.
## Gated by garrick_recruited; fires once via overgrown_capital_entry_seen.
##   Kael: awe at the scale. Iris: analytical crystal density report.
##   Garrick: grief for the people who lived here. Navigation call.
static func get_entry_lines() -> Array:
	return [
		{
			"speaker": "Kael",
			"text": "I've seen the outer edges. Never this deep.",
		},
		{
			"speaker": "Iris",
			"text": "Crystal density is off the charts."
				+ " The entire city is one massive formation"
				+ " \u2014 layer upon layer of growth."
				+ " Three hundred years of accumulation.",
		},
		{
			"speaker": "Garrick",
			"text": "...There were people here.",
		},
		{
			"speaker": "Iris",
			"text": "About two million,"
				+ " based on pre-Severance census records.",
		},
		{
			"speaker": "Garrick",
			"text": "Two million people."
				+ " And now\u2014 [gestures] \u2014this.",
		},
		{
			"speaker": "Iris",
			"text": "Signal is northeast."
				+ " We go through the market district,"
				+ " then north to the research quarter.",
		},
		{
			"speaker": "Garrick",
			"text": "I'll take point.",
		},
	]


## Returns the one-shot flag that prevents this dialogue from firing twice.
static func get_entry_flag() -> String:
	return "overgrown_capital_entry_seen"


## Returns the gate flag that must be set before the dialogue fires.
static func get_entry_gate_flag() -> String:
	return "garrick_recruited"
