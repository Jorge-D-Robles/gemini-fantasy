class_name OvergrownCapitalEncounters
extends RefCounted

## Encounter pool builder for Overgrown Capital dungeon.
## Accepts loaded enemy resources (null-safe) and returns the weighted pool.
## Testable without a live scene — pass null for absent enemies.
## Enemies per design doc (05-dungeon-designs.md):
##   Market District: Memory Blooms, Creeping Vines
##   Residential Quarter: Memory Blooms, Echo Nomads (added via T-0209)
## Hollow Specter intentionally excluded — not in design doc for Capital.


static func build_pool(
	memory_bloom: Resource,
	creeping_vine: Resource,
	echo_nomad: Resource = null,
) -> Array[EncounterPoolEntry]:
	var pool: Array[EncounterPoolEntry] = []

	if memory_bloom:
		pool.append(EncounterPoolEntry.create(
			[memory_bloom] as Array[Resource], 3.0,
		))
		pool.append(EncounterPoolEntry.create(
			[memory_bloom, memory_bloom] as Array[Resource], 1.5,
		))
	if creeping_vine:
		pool.append(EncounterPoolEntry.create(
			[creeping_vine] as Array[Resource], 1.0,
		))
		if memory_bloom:
			pool.append(EncounterPoolEntry.create(
				[memory_bloom, creeping_vine] as Array[Resource], 1.0,
			))
	if echo_nomad:
		pool.append(EncounterPoolEntry.create(
			[echo_nomad] as Array[Resource], 1.5,
		))
		if memory_bloom:
			pool.append(EncounterPoolEntry.create(
				[memory_bloom, echo_nomad] as Array[Resource], 1.0,
			))

	return pool
