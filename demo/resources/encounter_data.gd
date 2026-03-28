extends Resource
class_name EncounterData
## Defines a possible random encounter: which enemies appear as a group.

@export var enemies: Array[EnemyData] = []
@export_range(0.0, 1.0) var weight: float = 1.0
