class_name SkillTreeNodeData
extends Resource

## Defines a single node in a character's skill tree.
## Nodes have a cost in AP (skill points) and may require other nodes to be
## unlocked first. Optionally grants an ability when unlocked.

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Tree Position")
## Tier 1 = entry nodes, Tier 2 = mid nodes (require Tier 1), Tier 3 = advanced.
@export var tier: int = 1
## IDs of nodes that must be unlocked before this node becomes available.
@export var required_node_ids: Array[StringName] = []

@export_group("Cost")
## Skill points (AP) required to unlock this node.
@export var ap_cost: int = 1

@export_group("Reward")
## Optional ability unlocked when this node is purchased.
## Leave null for passive stat-only nodes.
@export var unlocks_ability: AbilityData = null
