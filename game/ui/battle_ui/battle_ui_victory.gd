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
			level_up_messages.append(
				compute_level_up_callout_text(name_str, new_level, changes)
			)

	return {
		"members": members,
		"exp_text": exp_text,
		"gold_text": gold_text,
		"items_text": items_text,
		"level_up_messages": level_up_messages,
	}


## Generates the per-character level-up callout string shown in the
## victory screen. Format: "★ Kael reached Level 4! HP+10, ATK+2"
static func compute_level_up_callout_text(
	character: String,
	level: int,
	changes: Dictionary,
) -> String:
	var parts: Array[String] = []
	for stat_key: String in changes:
		var val: int = changes[stat_key]
		parts.append("+%d %s" % [val, stat_abbreviation(stat_key)])
	var base := "★ %s reached Level %d!" % [character, level]
	if parts.is_empty():
		return base
	return base + " " + ", ".join(parts)


## Picks the first keyboard or joypad event from events and returns a
## human-readable label. Returns fallback if no matching event is found.
## Pure function — use this for tests; compute_dismiss_prompt_text() calls
## this with live InputMap events.
static func compute_dismiss_prompt_from_events(
	events: Array[InputEvent],
	fallback: String,
) -> String:
	for event: InputEvent in events:
		if event is InputEventKey:
			var key_event: InputEventKey = event as InputEventKey
			var label: String = key_event.as_text_physical_keycode()
			if label.is_empty():
				label = key_event.as_text_keycode()
			if not label.is_empty() and label != "None":
				return label
		elif event is InputEventJoypadButton:
			var btn_event: InputEventJoypadButton = event as InputEventJoypadButton
			return _joy_button_label(btn_event.button_index)
	return fallback


## Returns the prompt text shown on the victory screen asking the
## player to dismiss. Reads live InputMap events so remapped keys display
## correctly. action_name is the InputMap action to look up.
static func compute_dismiss_prompt_text(action_name: String = "confirm") -> String:
	if not InputMap.has_action(action_name):
		return "Press [%s] to continue" % action_name
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	var label: String = compute_dismiss_prompt_from_events(events, action_name)
	return "Press [%s] to continue" % label


static func _joy_button_label(button_index: JoyButton) -> String:
	match button_index:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
		JOY_BUTTON_START: return "Start"
		JOY_BUTTON_BACK: return "Back"
		JOY_BUTTON_LEFT_SHOULDER: return "LB"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB"
		_: return "?"


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
		"hp": return "HP"
		"ee": return "EE"
		"skill_points": return "SP"
		_: return stat_key.to_upper()
