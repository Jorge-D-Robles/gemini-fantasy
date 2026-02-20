class_name HudCompass
extends RefCounted

## Static helper for the HUD zone compass widget.
## Computes directional neighbor labels for the current overworld scene.
## All functions are static: pure logic, no scene dependency.

const SP = preload("res://systems/scene_paths.gd")

## Unicode arrow constants — west and east only for the linear world map.
const ARROW_WEST: String = "\u2190"
const ARROW_EAST: String = "\u2192"

## Adjacency map: scene path -> west neighbor name, east neighbor name.
## Empty string means no neighbor in that direction.
const ZONE_NEIGHBORS: Dictionary = {
	SP.ROOTHOLLOW: {"west": "", "east": "Verdant Forest"},
	SP.VERDANT_FOREST: {"west": "Roothollow", "east": "Overgrown Ruins"},
	SP.OVERGROWN_RUINS: {"west": "Verdant Forest", "east": ""},
}


## Returns a compass string showing adjacent zone names with directional arrows.
## Example: "← Roothollow  → Overgrown Ruins"
## Returns "" for non-overworld scenes.
static func compute_compass_text(scene_path: String) -> String:
	if not ZONE_NEIGHBORS.has(scene_path):
		return ""
	var neighbors: Dictionary = ZONE_NEIGHBORS[scene_path]
	var parts: PackedStringArray = PackedStringArray()
	var west: String = neighbors.get("west", "")
	var east: String = neighbors.get("east", "")
	if not west.is_empty():
		parts.append("%s %s" % [ARROW_WEST, west])
	if not east.is_empty():
		parts.append("%s %s" % [ARROW_EAST, east])
	return "  ".join(parts)


## Returns true if the zone compass should be shown for this scene.
static func compute_compass_visible(scene_path: String) -> bool:
	return ZONE_NEIGHBORS.has(scene_path)
