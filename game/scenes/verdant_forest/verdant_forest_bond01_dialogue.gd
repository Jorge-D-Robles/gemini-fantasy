class_name VerdantForestBond01Dialogue
extends RefCounted

## BOND-01: "Knife Lessons" — Iris corrects Kael's knife grip at a campfire
## in the Verdant Forest. Triggers once after iris_recruited flag, when both
## Iris and Kael are in the active party.
## Source: docs/story/camp-scenes/bonding-conversations.md — BOND-01


## Returns the one-shot flag that prevents replay.
static func get_bond01_flag() -> String:
	return "bond_01_knife_lessons"


## Returns the gate flag required before the scene can fire.
static func get_bond01_gate_flag() -> String:
	return "iris_recruited"


## Returns true when both eligibility conditions are met:
##   1. iris_recruited gate flag is set
##   2. bond_01_knife_lessons one-shot flag is NOT set
##   3. Both "iris" and "kael" are present in party_ids
## party_ids: Array of StringName character IDs from PartyManager.get_active_party()
static func compute_bond01_eligible(flags: Dictionary, party_ids: Array) -> bool:
	if not flags.get("iris_recruited", false):
		return false
	if flags.get("bond_01_knife_lessons", false):
		return false
	return (StringName("iris") in party_ids or "iris" in party_ids) \
		and (StringName("kael") in party_ids or "kael" in party_ids)


## Returns the 5-line BOND-01 dialogue exchange.
static func get_bond01_lines() -> Array:
	return [
		{
			"speaker": "Iris",
			"text": "You're holding it wrong.",
		},
		{
			"speaker": "Kael",
			"text": "I've been carving these since I was twelve.",
		},
		{
			"speaker": "Iris",
			"text": "Military wood-carving. Thumb on the spine, index"
				+ " curled, blade angled away. The angle means"
				+ " you never cut toward your palm.",
		},
		{
			"speaker": "Kael",
			"text": "Huh. That's actually better.",
		},
		{
			"speaker": "Iris",
			"text": "\u2026The knife thing is real, though."
				+ " Keep using that grip.",
		},
	]
