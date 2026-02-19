class_name BattleUIVictory
extends RefCounted

## Static computation utilities for victory display and stat
## formatting. No instance state — all methods are static.
## Do not instantiate.


## Returns structured victory display data for the enhanced
## victory screen.
static func compute_victory_display(
	party: Array[Resource], exp: int, gold: int,
	items: Array[String], level_ups: Array[Dictionary],
) -> Dictionary:
	var exp_text := "EXP: +%d" % exp
	var gold_text := "Gold: +%d" % gold
	var items_text := "Items: "
	if items.is_empty():
		items_text += "None"
	else:
		items_text += ", ".join(items)

	# Build level-up lookup by character name
	var lu_by_name: Dictionary = {}
	for lu: Dictionary in level_ups:
		lu_by_name[lu.get("character", "")] = lu

	var members: Array[Dictionary] = []
	var level_up_messages: Array[String] = []

	for member: Resource in party:
		if not (member is CharacterData):
			continue
		var cd: CharacterData = member as CharacterData
		var name_str: String = cd.display_name
		var lu_info: Dictionary = lu_by_name.get(
			name_str, {},
		)
		var leveled: bool = not lu_info.is_empty()
		var new_level: int = lu_info.get("level", cd.level)
		var changes: Dictionary = lu_info.get("changes", {})

		members.append({
			"name": name_str,
			"portrait_path": cd.portrait_path,
			"level": new_level,
			"leveled_up": leveled,
			"stat_changes": changes,
		})

		if leveled:
			var parts: Array[String] = []
			for stat_key: String in changes:
				var val: int = changes[stat_key]
				var label := stat_abbreviation(stat_key)
				parts.append("+%d %s" % [val, label])
			var msg := "%s LEVEL UP!" % name_str
			if not parts.is_empty():
				msg += " " + ", ".join(parts)
			level_up_messages.append(msg)

	return {
		"members": members,
		"exp_text": exp_text,
		"gold_text": gold_text,
		"items_text": items_text,
		"level_up_messages": level_up_messages,
	}


## Converts a stat key to a short abbreviation for display.
static func stat_abbreviation(stat_key: String) -> String:
	match stat_key:
		"max_hp": return "HP"
		"max_ee": return "EE"
		"attack": return "ATK"
		"magic": return "MAG"
		"defense": return "DEF"
		"resistance": return "RES"
		"speed": return "SPD"
		"luck": return "LCK"
		_: return stat_key.to_upper()
