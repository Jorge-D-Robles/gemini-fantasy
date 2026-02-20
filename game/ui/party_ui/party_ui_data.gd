extends RefCounted

## Static helpers for the Party Management UI.
## All methods are pure functions — no scene dependencies — so they are
## fully unit-testable without a live Godot scene tree.


## Returns a display dictionary for a single party member.
## If pm is provided, reads runtime HP from PartyManager; otherwise
## falls back to the character's max_hp as the starting current value.
static func compute_member_display(member: Resource, pm: Node) -> Dictionary:
	var max_hp: int = member.max_hp if "max_hp" in member else 0
	var current_hp: int = max_hp
	if pm != null and "id" in member:
		var id: StringName = member.id
		if pm.has_method("get_hp"):
			current_hp = pm.get_hp(id)
	return {
		"name": member.display_name if "display_name" in member else "",
		"level": member.level if "level" in member else 0,
		"max_hp": max_hp,
		"current_hp": current_hp,
		"attack": member.attack if "attack" in member else 0,
		"magic": member.magic if "magic" in member else 0,
		"defense": member.defense if "defense" in member else 0,
		"resistance": member.resistance if "resistance" in member else 0,
		"speed": member.speed if "speed" in member else 0,
	}


## Returns true if the given active/reserve index pair is valid for a swap.
## active_size and reserve_size are the current lengths of each list.
static func compute_swap_valid(
	active_index: int,
	reserve_index: int,
	active_size: int,
	reserve_size: int,
) -> bool:
	if active_index < 0 or active_index >= active_size:
		return false
	if reserve_index < 0 or reserve_index >= reserve_size:
		return false
	return true


## Returns equipment slot display names for a character.
## Each slot key maps to the equipped item's display_name, or an em-dash
## if nothing is equipped. em is the EquipmentManager node (or null).
static func compute_equipment_slots(
	character_id: StringName,
	em: Node,
) -> Dictionary:
	const EMPTY: String = "\u2014"
	if em == null or not em.has_method("get_all_equipment"):
		return {
			"weapon": EMPTY,
			"helmet": EMPTY,
			"chest": EMPTY,
			"accessory_0": EMPTY,
			"accessory_1": EMPTY,
		}
	var raw: Dictionary = em.get_all_equipment(character_id)
	var result: Dictionary = {}
	for key: String in ["weapon", "helmet", "chest", "accessory_0", "accessory_1"]:
		var item: Object = raw.get(key)
		if item != null and "display_name" in item:
			result[key] = item.display_name
		else:
			result[key] = EMPTY
	return result


## Returns display sections for the party panel.
## Result keys: active (Array[Dictionary]), reserve (Array[Dictionary]),
## has_reserve (bool).
static func compute_panel_sections(
	active: Array[Resource],
	reserve: Array[Resource],
	pm: Node,
) -> Dictionary:
	var active_entries: Array[Dictionary] = []
	for member: Resource in active:
		active_entries.append(compute_member_display(member, pm))
	var reserve_entries: Array[Dictionary] = []
	for member: Resource in reserve:
		reserve_entries.append(compute_member_display(member, pm))
	return {
		"active": active_entries,
		"reserve": reserve_entries,
		"has_reserve": not reserve_entries.is_empty(),
	}
