class_name RootHollowNightEvents
extends RefCounted

## Priority logic for Roothollow innkeeper rest night events.
## GarrickNightScene (garrick_met_lyra gate) takes priority over
## CampThreeFires (garrick_recruited gate) so the most recent story beat
## plays first. The deferred event fires on the next rest.

const EVENT_GARRICK_NIGHT: StringName = &"garrick_night"
const EVENT_CAMP_THREE_FIRES: StringName = &"camp_three_fires"
const EVENT_NONE: StringName = &""


## Returns which night event should fire after the innkeeper rest,
## or EVENT_NONE if no event is eligible.
## flags: Dictionary from EventFlags.get_all_flags()
static func compute_innkeeper_night_event(flags: Dictionary) -> StringName:
	# Priority 1: GarrickNightScene — gate: garrick_met_lyra
	if flags.get("garrick_met_lyra", false) and \
			not flags.get("garrick_night_scene", false):
		return EVENT_GARRICK_NIGHT

	# Priority 2: CampThreeFires — gate: garrick_recruited
	if flags.get("garrick_recruited", false) and \
			not flags.get("camp_scene_three_fires", false):
		return EVENT_CAMP_THREE_FIRES

	return EVENT_NONE
