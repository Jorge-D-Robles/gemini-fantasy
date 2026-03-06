class_name ScorchedRoadEncounters
extends RefCounted

## Encounter pool builder for The Scorched Road (Cindral Wastes).
## Accepts loaded enemy resources (null-safe) and returns the weighted pool.
## Testable without a live scene — pass null for absent enemies.


static func build_pool(
	magma_crawler: Resource,
	lava_elemental: Resource,
	ash_stalker: Resource,
) -> Array[EncounterPoolEntry]:
	var pool: Array[EncounterPoolEntry] = []

	# Common — volcanic wildlife
	if ash_stalker:
		pool.append(EncounterPoolEntry.create(
			[ash_stalker] as Array[Resource], 2.0,
		))
		pool.append(EncounterPoolEntry.create(
			[ash_stalker, ash_stalker] as Array[Resource], 1.5,
		))
	if magma_crawler:
		pool.append(EncounterPoolEntry.create(
			[magma_crawler] as Array[Resource], 2.0,
		))
		pool.append(EncounterPoolEntry.create(
			[magma_crawler, magma_crawler] as Array[Resource], 1.0,
		))

	# Uncommon — elemental threats
	if lava_elemental:
		pool.append(EncounterPoolEntry.create(
			[lava_elemental] as Array[Resource], 1.5,
		))

	# Mixed encounters
	if ash_stalker and magma_crawler:
		pool.append(EncounterPoolEntry.create(
			[ash_stalker, magma_crawler] as Array[Resource], 1.0,
		))
	if lava_elemental and ash_stalker:
		pool.append(EncounterPoolEntry.create(
			[lava_elemental, ash_stalker] as Array[Resource], 0.8,
		))
	if lava_elemental and magma_crawler:
		pool.append(EncounterPoolEntry.create(
			[lava_elemental, magma_crawler] as Array[Resource], 0.6,
		))

	# Rare — volcanic ambush
	if ash_stalker and magma_crawler and lava_elemental:
		pool.append(EncounterPoolEntry.create(
			[ash_stalker, magma_crawler, lava_elemental] as Array[Resource],
			0.3,
		))

	return pool
