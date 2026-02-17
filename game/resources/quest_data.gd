class_name QuestData
extends Resource

## Defines a quest's objectives, rewards, and prerequisites.

enum QuestType {
	MAIN,
	SIDE,
	CHARACTER,
	BOUNTY,
	COLLECTION,
}

@export_group("Identity")
@export var id: StringName = &""
@export var title: String = ""
@export_multiline var description: String = ""

@export_group("Objectives")
@export var objectives: Array[String] = []

@export_group("Rewards")
@export var reward_gold: int = 0
@export var reward_exp: int = 0
@export var reward_item_ids: Array[StringName] = []

@export_group("Type")
@export var quest_type: QuestType = QuestType.MAIN

@export_group("Prerequisites")
@export var prerequisites: Array[String] = []
