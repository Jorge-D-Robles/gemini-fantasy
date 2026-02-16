class_name BattlerData
extends Resource

## Base data resource for all combatants in battle.
## Extended by CharacterData (party members) and EnemyData (enemies).

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Base Stats")
@export var max_hp: int = 100
@export var max_ee: int = 50
@export var attack: int = 10
@export var magic: int = 10
@export var defense: int = 10
@export var resistance: int = 10
@export var speed: int = 10
@export var luck: int = 10

@export_group("Abilities")
@export var abilities: Array[Resource] = []
