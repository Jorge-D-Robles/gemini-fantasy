class_name BeneathPrismfallEncounters
extends RefCounted

## Encounter pool builder for Beneath Prismfall dungeon.
## Crystal canyon enemies: crystal_sentinel, resonance_wisp.
## Boss (prism_guardian) is a scripted encounter, not random.


static func build_pool(
	crystal_sentinel: Resource,
	resonance_wisp: Resource,
) -> Array[EncounterPoolEntry]:
	var pool: Array[EncounterPoolEntry] = []

	if crystal_sentinel:
		pool.append(EncounterPoolEntry.create(
			[crystal_sentinel] as Array[Resource], 25.0,
		))
		pool.append(EncounterPoolEntry.create(
			[crystal_sentinel, crystal_sentinel] as Array[Resource],
			15.0,
		))

	if resonance_wisp:
		pool.append(EncounterPoolEntry.create(
			[resonance_wisp] as Array[Resource], 20.0,
		))
		pool.append(EncounterPoolEntry.create(
			[resonance_wisp, resonance_wisp] as Array[Resource],
			10.0,
		))

	if crystal_sentinel and resonance_wisp:
		pool.append(EncounterPoolEntry.create(
			[crystal_sentinel, resonance_wisp] as Array[Resource],
			20.0,
		))
		pool.append(EncounterPoolEntry.create(
			[
				crystal_sentinel, crystal_sentinel, resonance_wisp,
			] as Array[Resource],
			10.0,
		))

	return pool
