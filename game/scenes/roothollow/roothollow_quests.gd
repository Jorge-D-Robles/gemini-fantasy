class_name RoothollowQuests
extends RefCounted

## Quest dialogue text and static quest helpers for Roothollow scene.
## All functions are static — pure data lookups and condition checks.

# Quest dialogue text keyed by quest id and phase
const QUEST_TEXT: Dictionary = {
	&"herb_gathering": {
		"offer": "One more thing \u2014 I need medicinal herbs"
			+ " from the Verdant Forest. The village supply"
			+ " is running dangerously low."
			+ " Would you gather some for me?",
		"accept": "Thank you, dear! Look for forest herbs"
			+ " growing near the clearings. I'll need three.",
		"reminder": "Any luck finding those herbs"
			+ " in the Verdant Forest?",
		"turnin": "You found them! These will keep the"
			+ " village healthy for weeks."
			+ " Take this as thanks.",
	},
	&"scouts_report": {
		"offer": "Actually \u2014 I have a job for you. Strange"
			+ " creatures keep emerging near the ruins."
			+ " I need someone to investigate and clear"
			+ " the area. Interested?",
		"accept": "Good. Head to the Overgrown Ruins, see"
			+ " what's stirring, and deal with any threats."
			+ " Report back when it's done.",
		"reminder": "How's the scouting mission going?"
			+ " Clear those creatures near the ruins"
			+ " and report back.",
		"turnin": "Solid work. The intelligence will help"
			+ " us keep Roothollow safe."
			+ " Here's your payment.",
	},
	&"elder_wisdom": {
		"offer": "Before you go \u2014 there is something I"
			+ " need. An Echo Fragment at the old village"
			+ " memorial in the Verdant Forest. It holds"
			+ " memories of Roothollow's founding."
			+ " Would you retrieve it for me?",
		"accept": "The memorial is south of the main path"
			+ " in the forest, near a cluster of stones."
			+ " Be careful \u2014 echoes there may be restless.",
		"reminder": "Have you found the memorial Echo in"
			+ " the Verdant Forest? It's near a cluster"
			+ " of stones south of the main path.",
		"turnin": "You brought it... The memories within"
			+ " are extraordinary. These are the voices"
			+ " of Roothollow's founders."
			+ " Here \u2014 you've earned this.",
	},
}


static func get_quest_offer(qid: StringName) -> String:
	return QUEST_TEXT.get(qid, {}).get("offer", "")


static func get_quest_accept(qid: StringName) -> String:
	return QUEST_TEXT.get(qid, {}).get("accept", "")


static func get_quest_reminder(qid: StringName) -> String:
	return QUEST_TEXT.get(qid, {}).get("reminder", "")


static func get_quest_turnin(qid: StringName) -> String:
	return QUEST_TEXT.get(qid, {}).get("turnin", "")


static func get_quest_offer_lines(
	qid: StringName,
) -> PackedStringArray:
	return PackedStringArray([get_quest_offer(qid)])


static func get_quest_complete_lines(
	qid: StringName,
) -> PackedStringArray:
	return PackedStringArray([get_quest_turnin(qid)])


# -- Quest completion condition checks (pure logic) --


static func should_offer_quest(
	quest_id: StringName,
	active_ids: Array,
	completed_ids: Array,
) -> bool:
	if quest_id in active_ids:
		return false
	if quest_id in completed_ids:
		return false
	return true


static func can_complete_herb_quest(herb_count: int) -> bool:
	return herb_count >= 3


static func can_complete_elder_quest(
	obj_status: Array,
) -> bool:
	return (
		obj_status.size() >= 2
		and obj_status[0]
		and not obj_status[1]
	)


static func can_complete_scouts_quest(
	ruins_visited: bool,
) -> bool:
	return ruins_visited
