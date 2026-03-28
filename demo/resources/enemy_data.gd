extends Resource
class_name EnemyData
## Data definition for an enemy combatant.

enum AIType { AGGRESSIVE, CAUTIOUS, BALANCED }

@export var id: String = ""
@export var display_name: String = ""
@export var sprite: Texture2D
@export var ai_type: AIType = AIType.BALANCED

@export_group("Stats")
@export var max_hp: int = 30
@export var max_mp: int = 0
@export var attack: int = 8
@export var defense: int = 3
@export var speed: int = 5

@export_group("Rewards")
@export var xp_reward: int = 10
@export var gold_reward: int = 5
@export var drop_item: ItemData
@export_range(0.0, 1.0) var drop_chance: float = 0.25
