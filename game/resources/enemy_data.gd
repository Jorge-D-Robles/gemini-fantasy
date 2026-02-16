class_name EnemyData
extends Resource

## Defines an enemy's stats, AI behavior, abilities, and loot.

enum AiType {
	BASIC,
	AGGRESSIVE,
	DEFENSIVE,
	SUPPORT,
	BOSS,
}

enum Element {
	NONE,
	FIRE,
	ICE,
	WATER,
	WIND,
	EARTH,
	LIGHT,
	DARK,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Stats")
@export var max_hp: int = 50
@export var max_ee: int = 0
@export var attack: int = 10
@export var magic: int = 10
@export var defense: int = 10
@export var resistance: int = 10
@export var speed: int = 10

@export_group("Rewards")
@export var exp_reward: int = 10
@export var gold_reward: int = 5

@export_group("Abilities")
@export var abilities: Array[Resource] = []

@export_group("Elemental Affinities")
@export var weaknesses: Array[Element] = []
@export var resistances: Array[Element] = []

@export_group("Behavior")
@export var ai_type: AiType = AiType.BASIC

@export_group("Visuals")
@export var sprite_path: String = ""

@export_group("Loot")
@export var loot_table: Array[Dictionary] = []
