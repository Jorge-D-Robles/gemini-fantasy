class_name RoothollowZone
extends RefCounted

## Zone trigger condition helpers for Roothollow scene.
## Extracted for testability — all functions are static and take
## a flags dictionary so they can be tested without a live scene.


## Returns true when the Garrick recruitment zone should fire.
## Requires both lyra discovery and iris recruitment,
## and must not have already recruited Garrick.
static func compute_garrick_zone_can_trigger(
	flags: Dictionary,
) -> bool:
	if flags.get("garrick_recruited", false):
		return false
	if not flags.get("opening_lyra_discovered", false):
		return false
	return flags.get("iris_recruited", false)


## Returns true when the Spring Shrine direction marker should
## be visible: after iris_recruited but before garrick_recruited.
static func compute_shrine_marker_visible(
	flags: Dictionary,
) -> bool:
	return (
		flags.get("iris_recruited", false)
		and not flags.get("garrick_recruited", false)
	)
