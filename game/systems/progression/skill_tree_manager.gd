class_name SkillTreeManager
extends RefCounted

## Static utility for skill tree unlock logic.
## Pure functions — no side effects. Callers apply the result.
##
## Usage:
##   if SkillTreeManager.compute_can_unlock(node, char.unlocked_skill_ids, char.skill_points):
##       var result := SkillTreeManager.compute_unlock_result(node, ...)
##       if result["success"]:
##           char.skill_points = result["remaining_sp"]
##           char.unlocked_skill_ids = result["unlocked_ids"]


## Returns true if the node can be unlocked given the current state.
## Conditions:
##   - node is not already in unlocked_ids
##   - available_sp >= node.ap_cost
##   - all node.required_node_ids are present in unlocked_ids
static func compute_can_unlock(
	node: SkillTreeNodeData,
	unlocked_ids: Array[StringName],
	available_sp: int,
) -> bool:
	if node.id in unlocked_ids:
		return false
	if available_sp < node.ap_cost:
		return false
	for req: StringName in node.required_node_ids:
		if req not in unlocked_ids:
			return false
	return true


## Attempts to unlock a node. Returns a result dictionary:
##   "success": bool
##   "unlocked_ids": Array[StringName]  — updated copy (input unchanged)
##   "remaining_sp": int                — updated SP count
## The input arrays are never mutated.
static func compute_unlock_result(
	node: SkillTreeNodeData,
	unlocked_ids: Array[StringName],
	available_sp: int,
) -> Dictionary:
	if not compute_can_unlock(node, unlocked_ids, available_sp):
		return {
			"success": false,
			"unlocked_ids": unlocked_ids.duplicate(),
			"remaining_sp": available_sp,
		}
	var new_ids: Array[StringName] = unlocked_ids.duplicate()
	new_ids.append(node.id)
	return {
		"success": true,
		"unlocked_ids": new_ids,
		"remaining_sp": available_sp - node.ap_cost,
	}
