class_name BanterManager
extends RefCounted

## Lightweight static registry for party banter eligibility.
## Scenes call compute_eligible_banters() to discover which banters can fire
## without duplicating condition logic per scene.
##
## Each banter entry:
##   key       — one-shot EventFlags key and lookup identifier
##   gate      — flag that must be set ("" = no gate)
##   party     — all member IDs that must be in active party
##   locations — if non-empty, current location must match one entry

const BANTERS: Array = [
	{
		"key": "bond_01_knife_lessons",
		"gate": "iris_recruited",
		"party": ["iris", "kael"],
		"locations": ["verdant_forest"],
	},
]


## Returns banter keys eligible to fire given current party, flags, location.
## party_ids: Array of character ID strings from PartyManager
## flags: Dictionary from EventFlags.get_all_flags()
## location: String matching the current scene name
static func compute_eligible_banters(
	party_ids: Array,
	flags: Dictionary,
	location: String,
) -> Array[String]:
	var eligible: Array[String] = []
	for entry: Dictionary in BANTERS:
		if _is_eligible(entry, party_ids, flags, location):
			eligible.append(entry["key"])
	return eligible


static func _is_eligible(
	entry: Dictionary,
	party_ids: Array,
	flags: Dictionary,
	location: String,
) -> bool:
	# One-shot guard — already played
	if flags.get(entry["key"], false):
		return false
	# Gate flag not yet set
	var gate: String = entry.get("gate", "")
	if gate != "" and not flags.get(gate, false):
		return false
	# Location filter
	var locations: Array = entry.get("locations", [])
	if not locations.is_empty() and location not in locations:
		return false
	# All required party members present
	for member_id: String in entry.get("party", []):
		if member_id not in party_ids and StringName(member_id) not in party_ids:
			return false
	return true
