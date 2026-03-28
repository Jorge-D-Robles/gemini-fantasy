extends Resource
class_name QuestData
## Defines a quest with objectives, rewards, and state.

enum QuestState { NOT_STARTED, ACTIVE, COMPLETE, TURNED_IN }

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export_group("Objectives")
@export var objectives: Array[String] = []
@export var objective_flags: Array[String] = []

@export_group("Rewards")
@export var xp_reward: int = 0
@export var gold_reward: int = 0
@export var reward_items: Array[ItemData] = []
@export var completion_flag: String = ""
