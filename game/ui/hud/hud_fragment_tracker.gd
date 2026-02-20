class_name HudFragmentTracker
extends RefCounted

## Static helper for the fragment compass widget.
## Computes directional hints that guide the player toward the next story beat
## based on EventFlags state and current scene.
## All functions are static: pure logic, no scene dependency.


## Direction arrow characters.
const DIR_NORTH: String = "\u2191"
const DIR_NORTHEAST: String = "\u2197"
const DIR_EAST: String = "\u2192"
const DIR_SOUTH: String = "\u2193"
const DIR_WEST: String = "\u2190"
const DIR_NONE: String = ""

const SP = preload("res://systems/scene_paths.gd")


## Returns true when the signal compass should be displayed.
## Visible from opening_lyra_discovered until garrick_met_lyra (demo end).
static func compute_tracker_visible(flags: Dictionary) -> bool:
	return flags.get("opening_lyra_discovered", false) \
		and not flags.get("garrick_met_lyra", false)


## Returns the compass arrow pointing toward the next story beat.
## Returns DIR_NONE when already in the correct area or tracker is hidden.
static func compute_signal_direction(
	flags: Dictionary,
	scene_path: String,
) -> String:
	if not compute_tracker_visible(flags):
		return DIR_NONE

	var iris: bool = flags.get("iris_recruited", false)
	var garrick: bool = flags.get("garrick_recruited", false)

	if garrick:
		# Full party assembled — research quarter is NE in the ruins.
		match scene_path:
			SP.OVERGROWN_RUINS:
				return DIR_NORTHEAST
			SP.VERDANT_FOREST:
				return DIR_WEST
			SP.ROOTHOLLOW:
				return DIR_WEST

	elif iris:
		# Iris recruited — Garrick is waiting at Roothollow.
		match scene_path:
			SP.OVERGROWN_RUINS:
				return DIR_EAST
			SP.VERDANT_FOREST:
				return DIR_EAST
			SP.ROOTHOLLOW:
				# Garrick's recruitment event fires here — already in place.
				return DIR_NONE

	else:
		# Solo Kael — Iris recruitment event is in the Verdant Forest.
		match scene_path:
			SP.OVERGROWN_RUINS:
				return DIR_EAST
			SP.VERDANT_FOREST:
				# Iris zone fires here — already in place.
				return DIR_NONE
			SP.ROOTHOLLOW:
				return DIR_WEST

	return DIR_NONE


## Returns the display label ("↗ Signal") or "" when hidden/no direction.
static func compute_tracker_label(
	flags: Dictionary,
	scene_path: String,
) -> String:
	var direction: String = compute_signal_direction(flags, scene_path)
	if direction.is_empty():
		return ""
	return "%s Signal" % direction


## Returns {visible: bool, label: String} for the HUD fragment tracker widget.
static func compute_tracker_display(
	flags: Dictionary,
	scene_path: String,
) -> Dictionary:
	if not compute_tracker_visible(flags):
		return {"visible": false, "label": ""}
	var label: String = compute_tracker_label(flags, scene_path)
	return {
		"visible": not label.is_empty(),
		"label": label,
	}
