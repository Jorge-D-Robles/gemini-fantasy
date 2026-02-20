extends GutTest

## Tests for T-0184: Skill tree .tres seed — 24 SkillTreeData files + 4 CharacterData updates.
## Verifies file existence, load integrity, node counts, ID uniqueness, and prerequisite chains.


const _FULL_TREE_PATHS: Array[String] = [
	"res://data/skill_trees/kael_hunter_path.tres",
	"res://data/skill_trees/kael_memory_path.tres",
	"res://data/skill_trees/kael_bridge_path.tres",
	"res://data/skill_trees/iris_arsenal_path.tres",
	"res://data/skill_trees/iris_engineering_path.tres",
	"res://data/skill_trees/iris_cybernetics_path.tres",
	"res://data/skill_trees/garrick_fortress_path.tres",
	"res://data/skill_trees/garrick_redemption_path.tres",
	"res://data/skill_trees/garrick_judgment_path.tres",
	"res://data/skill_trees/nyx_chaos_path.tres",
	"res://data/skill_trees/nyx_identity_path.tres",
	"res://data/skill_trees/nyx_hollows_path.tres",
]

const _STUB_TREE_PATHS: Array[String] = [
	"res://data/skill_trees/lyra_scholar_path.tres",
	"res://data/skill_trees/lyra_warrior_path.tres",
	"res://data/skill_trees/lyra_echo_path.tres",
	"res://data/skill_trees/sienna_research_path.tres",
	"res://data/skill_trees/sienna_experimentation_path.tres",
	"res://data/skill_trees/sienna_redemption_path.tres",
	"res://data/skill_trees/cipher_infiltration_path.tres",
	"res://data/skill_trees/cipher_combat_path.tres",
	"res://data/skill_trees/cipher_anchor_path.tres",
	"res://data/skill_trees/ash_silence_path.tres",
	"res://data/skill_trees/ash_harmony_path.tres",
	"res://data/skill_trees/ash_future_path.tres",
]


func _load_skill_tree(path: String) -> SkillTreeData:
	return load(path) as SkillTreeData


func _load_character(path: String) -> CharacterData:
	return load(path) as CharacterData


# -- test 1: all 24 skill tree files load correctly --


func test_all_skill_tree_files_load() -> void:
	var all_paths: Array[String] = []
	all_paths.append_array(_FULL_TREE_PATHS)
	all_paths.append_array(_STUB_TREE_PATHS)
	for path in all_paths:
		var tree := _load_skill_tree(path)
		assert_not_null(tree, "Expected SkillTreeData at: " + path)
		assert_true(tree is SkillTreeData, "Expected SkillTreeData type at: " + path)


# -- test 2-5: CharacterData references 3 skill trees each --


func test_kael_has_three_skill_trees() -> void:
	var char_data := _load_character("res://data/characters/kael.tres")
	assert_not_null(char_data)
	assert_eq(char_data.skill_trees.size(), 3, "Kael should have 3 skill trees")
	for tree in char_data.skill_trees:
		assert_not_null(tree, "Kael skill tree entry should not be null")


func test_iris_has_three_skill_trees() -> void:
	var char_data := _load_character("res://data/characters/iris.tres")
	assert_not_null(char_data)
	assert_eq(char_data.skill_trees.size(), 3, "Iris should have 3 skill trees")
	for tree in char_data.skill_trees:
		assert_not_null(tree, "Iris skill tree entry should not be null")


func test_garrick_has_three_skill_trees() -> void:
	var char_data := _load_character("res://data/characters/garrick.tres")
	assert_not_null(char_data)
	assert_eq(char_data.skill_trees.size(), 3, "Garrick should have 3 skill trees")
	for tree in char_data.skill_trees:
		assert_not_null(tree, "Garrick skill tree entry should not be null")


func test_lyra_has_three_skill_trees() -> void:
	var char_data := _load_character("res://data/characters/lyra.tres")
	assert_not_null(char_data)
	assert_eq(char_data.skill_trees.size(), 3, "Lyra should have 3 skill trees")
	for tree in char_data.skill_trees:
		assert_not_null(tree, "Lyra skill tree entry should not be null")


# -- test 6: full-documented character trees have exactly 6 nodes --


func test_full_character_trees_have_six_nodes() -> void:
	for path in _FULL_TREE_PATHS:
		var tree := _load_skill_tree(path)
		assert_not_null(tree)
		assert_eq(tree.nodes.size(), 6, "Full tree should have 6 nodes: " + path)


# -- test 7: stub character trees have exactly 3 nodes --


func test_stub_character_trees_have_three_nodes() -> void:
	for path in _STUB_TREE_PATHS:
		var tree := _load_skill_tree(path)
		assert_not_null(tree)
		assert_eq(tree.nodes.size(), 3, "Stub tree should have 3 nodes: " + path)


# -- test 8: node IDs are unique across all 3 paths for each character --


func test_node_ids_are_unique_across_all_paths_per_character() -> void:
	var character_path_groups: Dictionary = {
		"kael": [
			"res://data/skill_trees/kael_hunter_path.tres",
			"res://data/skill_trees/kael_memory_path.tres",
			"res://data/skill_trees/kael_bridge_path.tres",
		],
		"iris": [
			"res://data/skill_trees/iris_arsenal_path.tres",
			"res://data/skill_trees/iris_engineering_path.tres",
			"res://data/skill_trees/iris_cybernetics_path.tres",
		],
		"garrick": [
			"res://data/skill_trees/garrick_fortress_path.tres",
			"res://data/skill_trees/garrick_redemption_path.tres",
			"res://data/skill_trees/garrick_judgment_path.tres",
		],
		"nyx": [
			"res://data/skill_trees/nyx_chaos_path.tres",
			"res://data/skill_trees/nyx_identity_path.tres",
			"res://data/skill_trees/nyx_hollows_path.tres",
		],
		"lyra": [
			"res://data/skill_trees/lyra_scholar_path.tres",
			"res://data/skill_trees/lyra_warrior_path.tres",
			"res://data/skill_trees/lyra_echo_path.tres",
		],
		"sienna": [
			"res://data/skill_trees/sienna_research_path.tres",
			"res://data/skill_trees/sienna_experimentation_path.tres",
			"res://data/skill_trees/sienna_redemption_path.tres",
		],
		"cipher": [
			"res://data/skill_trees/cipher_infiltration_path.tres",
			"res://data/skill_trees/cipher_combat_path.tres",
			"res://data/skill_trees/cipher_anchor_path.tres",
		],
		"ash": [
			"res://data/skill_trees/ash_silence_path.tres",
			"res://data/skill_trees/ash_harmony_path.tres",
			"res://data/skill_trees/ash_future_path.tres",
		],
	}

	for char_name in character_path_groups:
		var seen_ids: Dictionary = {}
		var paths: Array = character_path_groups[char_name]
		for path in paths:
			var tree := _load_skill_tree(path)
			assert_not_null(tree)
			for node in tree.nodes:
				var node_id: StringName = node.id
				assert_false(
					seen_ids.has(node_id),
					"Duplicate node ID '%s' for character '%s'" % [node_id, char_name]
				)
				seen_ids[node_id] = true


# -- test 9: node tiers and ap_costs are valid --


func test_node_tiers_and_ap_costs_are_valid() -> void:
	var all_paths: Array[String] = []
	all_paths.append_array(_FULL_TREE_PATHS)
	all_paths.append_array(_STUB_TREE_PATHS)
	for path in all_paths:
		var tree := _load_skill_tree(path)
		assert_not_null(tree)
		for node in tree.nodes:
			assert_true(
				node.tier >= 1 and node.tier <= 3,
				"tier must be 1-3, got %d in %s" % [node.tier, path]
			)
			assert_true(
				node.ap_cost >= 1,
				"ap_cost must be >= 1, got %d in %s" % [node.ap_cost, path]
			)


# -- test 10: prerequisite chain integrity --
# Every required_node_id references a valid node ID within the same SkillTreeData.


func test_prerequisite_chain_integrity() -> void:
	var all_paths: Array[String] = []
	all_paths.append_array(_FULL_TREE_PATHS)
	all_paths.append_array(_STUB_TREE_PATHS)
	for path in all_paths:
		var tree := _load_skill_tree(path)
		assert_not_null(tree)
		var valid_ids: Dictionary = {}
		for node in tree.nodes:
			valid_ids[node.id] = true
		for node in tree.nodes:
			for req_id in node.required_node_ids:
				assert_true(
					valid_ids.has(req_id),
					"required_node_id '%s' not found in tree '%s' (file: %s)" % [
						req_id, tree.id, path
					]
				)
