class_name VerdantForestEncounters
extends RefCounted

## Encounter pool builder for Verdant Forest.
## Accepts loaded enemy resources (null-safe) and returns the weighted pool.
## Testable without a live scene — pass null for absent enemies.


static func build_pool(
	creeping_vine: Resource,
	ash_stalker: Resource,
	hollow_specter: Resource,
	ancient_sentinel: Resource,
	gale_harpy: Resource,
	ember_hound: Resource,
) -> Array[EncounterPoolEntry]:
	var pool: Array[EncounterPoolEntry] = []

	# Common encounters — basic forest enemies
	if creeping_vine:
		pool.append(EncounterPoolEntry.create(
			[creeping_vine] as Array[Resource], 2.0,
		))
		pool.append(EncounterPoolEntry.create(
			[creeping_vine, creeping_vine] as Array[Resource], 1.5,
		))
	if ash_stalker:
		pool.append(EncounterPoolEntry.create(
			[ash_stalker] as Array[Resource], 2.0,
		))
	if hollow_specter:
		pool.append(EncounterPoolEntry.create(
			[hollow_specter] as Array[Resource], 1.5,
		))
		pool.append(EncounterPoolEntry.create(
			[hollow_specter, hollow_specter] as Array[Resource], 0.8,
		))
	if ancient_sentinel:
		pool.append(EncounterPoolEntry.create(
			[ancient_sentinel] as Array[Resource], 1.0,
		))

	# Mixed encounters
	if creeping_vine and ash_stalker:
		pool.append(EncounterPoolEntry.create(
			[creeping_vine, ash_stalker] as Array[Resource], 1.0,
		))
	if hollow_specter and creeping_vine:
		pool.append(EncounterPoolEntry.create(
			[hollow_specter, creeping_vine] as Array[Resource], 1.0,
		))

	# Uncommon encounters — mid-tier enemies
	if gale_harpy:
		pool.append(EncounterPoolEntry.create(
			[gale_harpy] as Array[Resource], 0.8,
		))
	if ember_hound:
		pool.append(EncounterPoolEntry.create(
			[ember_hound] as Array[Resource], 0.8,
		))
	if gale_harpy and ember_hound:
		pool.append(EncounterPoolEntry.create(
			[gale_harpy, ember_hound] as Array[Resource], 0.4,
		))

	return pool
