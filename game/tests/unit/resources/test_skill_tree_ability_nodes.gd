extends GutTest

## Tests for T-0107: Verify tier-3 "New Ability" nodes have unlocks_ability wired.
## Each full skill tree path has one ability-granting tier-3 node (not the capstone).
## Some paths have no ability-granting nodes (e.g. Hunter Path = all passives).
## Stub trees have their single tier-3 node wired to an ability.

# Mapping: tree_path -> [node_id, expected_ability_id]
# null means no ability-granting tier-3 node in that tree.
const _ABILITY_NODE_MAP: Dictionary = {
	# Kael: Hunter has no ability nodes, Memory + Bridge have one each
	"res://data/skill_trees/kael_hunter_path.tres": null,
	"res://data/skill_trees/kael_memory_path.tres": [
		&"kael_memory_storm", &"memory_storm",
	],
	"res://data/skill_trees/kael_bridge_path.tres": [
		&"kael_reality_weaver", &"reality_weaver_kael",
	],
	# Iris: All three paths have one ability node each
	"res://data/skill_trees/iris_arsenal_path.tres": [
		&"iris_devastation", &"devastation",
	],
	"res://data/skill_trees/iris_engineering_path.tres": [
		&"iris_sabotage", &"sabotage",
	],
	"res://data/skill_trees/iris_cybernetics_path.tres": [
		&"iris_overcharge", &"overcharge",
	],
	# Garrick: All three paths have one ability node each
	"res://data/skill_trees/garrick_fortress_path.tres": [
		&"garrick_bulwark", &"bulwark",
	],
	"res://data/skill_trees/garrick_redemption_path.tres": [
		&"garrick_sanctuary", &"sanctuary",
	],
	"res://data/skill_trees/garrick_judgment_path.tres": [
		&"garrick_divine_judgment", &"divine_judgment",
	],
	# Nyx: All three paths have one ability node each
	"res://data/skill_trees/nyx_chaos_path.tres": [
		&"nyx_chaos_storm", &"chaos_storm",
	],
	"res://data/skill_trees/nyx_identity_path.tres": [
		&"nyx_i_am_real", &"i_am_real",
	],
	"res://data/skill_trees/nyx_hollows_path.tres": [
		&"nyx_reality_weaver_skill", &"reality_weaver_nyx",
	],
	# Stub trees: single tier-3 node gets wired
	"res://data/skill_trees/lyra_scholar_path.tres": [
		&"lyra_echo_scholar", &"echo_scholar",
	],
	"res://data/skill_trees/lyra_warrior_path.tres": [
		&"lyra_warrior_apex", &"blade_of_memory",
	],
	"res://data/skill_trees/lyra_echo_path.tres": [
		&"lyra_echo_apex", &"echo_weaver",
	],
	"res://data/skill_trees/sienna_research_path.tres": [
		&"sienna_breakthrough", &"research_breakthrough",
	],
	"res://data/skill_trees/sienna_experimentation_path.tres": [
		&"sienna_perfect_catalyst", &"volatile_experiment",
	],
	"res://data/skill_trees/sienna_redemption_path.tres": [
		&"sienna_absolution", &"redemption_surge",
	],
	"res://data/skill_trees/cipher_infiltration_path.tres": [
		&"cipher_ghost_protocol", &"shadow_strike",
	],
	"res://data/skill_trees/cipher_combat_path.tres": [
		&"cipher_assassinate", &"combat_overdrive",
	],
	"res://data/skill_trees/cipher_anchor_path.tres": [
		&"cipher_unshakeable", &"anchor_point",
	],
	"res://data/skill_trees/ash_silence_path.tres": [
		&"ash_perfect_silence", &"absolute_silence",
	],
	"res://data/skill_trees/ash_harmony_path.tres": [
		&"ash_harmonics", &"perfect_harmony",
	],
	"res://data/skill_trees/ash_future_path.tres": [
		&"ash_chosen_path", &"future_sight",
	],
}


func _find_node(tree: SkillTreeData, node_id: StringName) -> SkillTreeNodeData:
	for node in tree.nodes:
		if node.id == node_id:
			return node
	return null


func test_ability_granting_nodes_have_abilities() -> void:
	for path in _ABILITY_NODE_MAP:
		var mapping: Variant = _ABILITY_NODE_MAP[path]
		if mapping == null:
			continue
		var tree: SkillTreeData = load(path) as SkillTreeData
		assert_not_null(tree, "Tree must load: %s" % path)
		var node_id: StringName = mapping[0]
		var expected_ability_id: StringName = mapping[1]
		var node: SkillTreeNodeData = _find_node(tree, node_id)
		assert_not_null(
			node, "Node '%s' not found in %s" % [node_id, path]
		)
		assert_not_null(
			node.unlocks_ability,
			"Node '%s' in %s must have unlocks_ability set" % [node_id, path]
		)
		assert_eq(
			node.unlocks_ability.id, expected_ability_id,
			"Node '%s' should unlock '%s', got '%s'" % [
				node_id, expected_ability_id, node.unlocks_ability.id,
			]
		)


func test_ability_granting_nodes_have_valid_costs() -> void:
	for path in _ABILITY_NODE_MAP:
		var mapping: Variant = _ABILITY_NODE_MAP[path]
		if mapping == null:
			continue
		var tree: SkillTreeData = load(path) as SkillTreeData
		assert_not_null(tree)
		var node_id: StringName = mapping[0]
		var node: SkillTreeNodeData = _find_node(tree, node_id)
		assert_not_null(node)
		if node.unlocks_ability:
			assert_true(
				node.unlocks_ability.ee_cost > 0,
				"Ability '%s' must have ee_cost > 0" % node.unlocks_ability.id
			)


func test_hunter_path_has_no_ability_nodes() -> void:
	var tree: SkillTreeData = load(
		"res://data/skill_trees/kael_hunter_path.tres"
	) as SkillTreeData
	assert_not_null(tree)
	for node in tree.nodes:
		assert_null(
			node.unlocks_ability,
			"Hunter Path node '%s' should be passive (null ability)" % node.id
		)
