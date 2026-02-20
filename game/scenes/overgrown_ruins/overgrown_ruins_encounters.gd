class_name OvergrownRuinsEncounters
extends RefCounted

## Encounter pool builder for Overgrown Ruins.
## Accepts loaded enemy resources (null-safe) and returns the weighted pool.
## Testable without a live scene — pass null for absent enemies.


static func build_pool(
	memory_bloom: Resource,
	creeping_vine: Resource,
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

	return pool
