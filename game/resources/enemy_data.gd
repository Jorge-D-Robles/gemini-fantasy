class_name EnemyData
extends BattlerData

## Defines an enemy's AI behavior, elemental affinities, rewards, and loot.

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

@export_group("Behavior")
@export var ai_type: AiType = AiType.BASIC

@export_group("Rewards")
@export var exp_reward: int = 10
@export var gold_reward: int = 5

@export_group("Elemental Affinities")
@export var weaknesses: Array[Element] = []
@export var resistances: Array[Element] = []

@export_group("Visuals")
@export var sprite_path: String = ""

@export_group("Loot")
@export var loot_table: Array[Dictionary] = []
