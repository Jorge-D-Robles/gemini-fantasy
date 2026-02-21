class_name PrismfallApproachEncounters
extends RefCounted

## Encounter pool builder for Prismfall Approach (Crystalline Steppes).
## Accepts loaded enemy resources (null-safe) and returns the weighted pool.
## Testable without a live scene — pass null for absent enemies.


static func build_pool(
	gale_harpy: Resource,
	cinder_wisp: Resource,
	hollow_specter: Resource,
	ancient_sentinel: Resource,
	ember_hound: Resource,
) -> Array[EncounterPoolEntry]:
	var pool: Array[EncounterPoolEntry] = []

	# Common — open steppe fliers and wisps
	if gale_harpy:
		pool.append(EncounterPoolEntry.create(
			[gale_harpy] as Array[Resource], 2.0,
		))
		pool.append(EncounterPoolEntry.create(
			[gale_harpy, gale_harpy] as Array[Resource], 1.5,
		))
	if cinder_wisp:
		pool.append(EncounterPoolEntry.create(
			[cinder_wisp] as Array[Resource], 2.0,
		))
		pool.append(EncounterPoolEntry.create(
			[cinder_wisp, cinder_wisp] as Array[Resource], 1.0,
		))

	# Uncommon — spectral and sentinel threats
	if hollow_specter:
		pool.append(EncounterPoolEntry.create(
			[hollow_specter] as Array[Resource], 1.5,
		))
	if ancient_sentinel:
		pool.append(EncounterPoolEntry.create(
			[ancient_sentinel] as Array[Resource], 1.0,
		))
	if ember_hound:
		pool.append(EncounterPoolEntry.create(
			[ember_hound] as Array[Resource], 1.5,
		))

	# Mixed encounters
	if gale_harpy and cinder_wisp:
		pool.append(EncounterPoolEntry.create(
			[gale_harpy, cinder_wisp] as Array[Resource], 1.0,
		))
	if hollow_specter and gale_harpy:
		pool.append(EncounterPoolEntry.create(
			[hollow_specter, gale_harpy] as Array[Resource], 0.8,
		))
	if ember_hound and cinder_wisp:
		pool.append(EncounterPoolEntry.create(
			[ember_hound, cinder_wisp] as Array[Resource], 0.6,
		))

	return pool
