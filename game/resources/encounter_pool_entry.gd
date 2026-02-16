class_name EncounterPoolEntry
extends Resource

## Defines a weighted enemy group for the encounter system.

@export var enemies: Array[Resource] = []
@export var weight: float = 1.0


static func create(
	p_enemies: Array[Resource],
	p_weight: float = 1.0,
) -> EncounterPoolEntry:
	var entry := EncounterPoolEntry.new()
	entry.enemies = p_enemies
	entry.weight = p_weight
	return entry
