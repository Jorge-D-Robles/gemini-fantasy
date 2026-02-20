class_name SkillTreeData
extends Resource

## Defines one skill path (e.g. "Hunter Path") for a character.
## A character typically has 3 paths, each with a SkillTreeData resource.
## Node unlock state lives on CharacterData (unlocked_skill_ids).

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Nodes")
## All nodes belonging to this path, in any order.
## Use required_node_ids on each node to define the unlock progression.
@export var nodes: Array[SkillTreeNodeData] = []
