extends GutTest

## Tests for SkillTreeUI static helpers.
## T-0219: compute_node_state and compute_skill_tree_entries cover unlock logic.

const SkillTreeUI = preload("res://ui/skill_tree_ui/skill_tree_ui.gd")

const _CHAR_DATA_SCRIPT := preload("res://resources/character_data.gd")
const _NODE_DATA_SCRIPT := preload("res://resources/skill_tree_node_data.gd")
const _TREE_DATA_SCRIPT := preload("res://resources/skill_tree_data.gd")

var _char: CharacterData
var _node_a: SkillTreeNodeData
var _node_b: SkillTreeNodeData
var _node_c: SkillTreeNodeData


func before_each() -> void:
	_char = _CHAR_DATA_SCRIPT.new()
	_char.skill_points = 3
	_char.unlocked_skill_ids = []

	_node_a = _NODE_DATA_SCRIPT.new()
	_node_a.id = &"node_a"
	_node_a.display_name = "Node A"
	_node_a.description = "First node"
	_node_a.ap_cost = 1
	_node_a.required_node_ids = []

	_node_b = _NODE_DATA_SCRIPT.new()
	_node_b.id = &"node_b"
	_node_b.display_name = "Node B"
	_node_b.description = "Second node"
	_node_b.ap_cost = 2
	_node_b.required_node_ids = [&"node_a"]

	_node_c = _NODE_DATA_SCRIPT.new()
	_node_c.id = &"node_c"
	_node_c.display_name = "Node C"
	_node_c.description = "Third node"
	_node_c.ap_cost = 1
	_node_c.required_node_ids = []

	var tree := _TREE_DATA_SCRIPT.new()
	tree.id = &"test_path"
	tree.display_name = "Test Path"
	var nodes: Array[SkillTreeNodeData] = [_node_a, _node_b, _node_c]
	tree.nodes = nodes

	var trees: Array[Resource] = [tree]
	_char.skill_trees = trees


func test_node_state_locked_when_sp_insufficient() -> void:
	_char.skill_points = 0
	assert_eq(
		SkillTreeUI.compute_node_state(_node_a, _char),
		"locked",
		"Must be locked when SP < ap_cost",
	)


func test_node_state_available_when_prereqs_met_and_sp_sufficient() -> void:
	assert_eq(
		SkillTreeUI.compute_node_state(_node_a, _char),
		"available",
		"Tier-1 node with no prereqs must be available when SP >= ap_cost",
	)


func test_node_state_locked_when_prereq_not_met() -> void:
	assert_eq(
		SkillTreeUI.compute_node_state(_node_b, _char),
		"locked",
		"Must be locked when required node not yet unlocked",
	)


func test_node_state_unlocked_when_id_in_unlocked_ids() -> void:
	_char.unlocked_skill_ids = [&"node_a"]
	assert_eq(
		SkillTreeUI.compute_node_state(_node_a, _char),
		"unlocked",
		"Must be unlocked when id is in unlocked_skill_ids",
	)


func test_node_state_available_after_prereq_unlocked() -> void:
	_char.unlocked_skill_ids = [&"node_a"]
	assert_eq(
		SkillTreeUI.compute_node_state(_node_b, _char),
		"available",
		"Must be available once prereq is met and SP is sufficient",
	)


func test_entries_returns_correct_count_for_path() -> void:
	var entries: Array[Dictionary] = SkillTreeUI.compute_skill_tree_entries(_char)
	assert_eq(entries.size(), 3, "Must return one entry per node in the path")


func test_entries_node_has_required_keys() -> void:
	var entries: Array[Dictionary] = SkillTreeUI.compute_skill_tree_entries(_char)
	var e: Dictionary = entries[0]
	assert_true(e.has("id"), "Entry must have id")
	assert_true(e.has("display_name"), "Entry must have display_name")
	assert_true(e.has("ap_cost"), "Entry must have ap_cost")
	assert_true(e.has("state"), "Entry must have state")
	assert_true(e.has("required_node_ids"), "Entry must have required_node_ids")
	assert_true(e.has("path_name"), "Entry must have path_name")


func test_entries_state_unlocked_for_unlocked_node() -> void:
	_char.unlocked_skill_ids = [&"node_a"]
	var entries: Array[Dictionary] = SkillTreeUI.compute_skill_tree_entries(_char)
	var matched := entries.filter(func(e: Dictionary) -> bool: return e["id"] == &"node_a")
	assert_eq(matched.size(), 1, "Must find node_a entry")
	assert_eq(matched[0]["state"], "unlocked", "node_a must show as unlocked")


func test_entries_state_available_for_tier1_no_prereq_with_sp() -> void:
	var entries: Array[Dictionary] = SkillTreeUI.compute_skill_tree_entries(_char)
	var matched := entries.filter(func(e: Dictionary) -> bool: return e["id"] == &"node_a")
	assert_eq(matched[0]["state"], "available", "node_a must be available with no prereqs and SP >= 1")


func test_entries_returns_empty_for_char_with_no_skill_trees() -> void:
	var trees: Array[Resource] = []
	_char.skill_trees = trees
	var entries: Array[Dictionary] = SkillTreeUI.compute_skill_tree_entries(_char)
	assert_eq(entries.size(), 0, "Must return empty list when no skill trees defined")


func test_sp_label_format() -> void:
	assert_eq(SkillTreeUI.compute_sp_label(5), "SP: 5")


func test_sp_label_zero() -> void:
	assert_eq(SkillTreeUI.compute_sp_label(0), "SP: 0")


func test_entries_path_name_populated() -> void:
	var entries: Array[Dictionary] = SkillTreeUI.compute_skill_tree_entries(_char)
	assert_eq(entries[0]["path_name"], "Test Path", "path_name must match SkillTreeData.display_name")
