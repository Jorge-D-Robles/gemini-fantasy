extends GutTest

## Tests for SkillTreeManager — unlock logic for skill tree nodes.
## Also covers CharacterData skill_points/unlocked_skill_ids and
## LevelManager awarding 1 skill point per level-up.

const SkillTreeManagerScript := preload(
	"res://systems/progression/skill_tree_manager.gd"
)

var _node_a: SkillTreeNodeData
var _node_b: SkillTreeNodeData  # requires _node_a
var _node_c: SkillTreeNodeData  # ap_cost = 3


func before_each() -> void:
	_node_a = SkillTreeNodeData.new()
	_node_a.id = &"node_a"
	_node_a.display_name = "Node A"
	_node_a.tier = 1
	_node_a.ap_cost = 1
	_node_a.required_node_ids = []

	_node_b = SkillTreeNodeData.new()
	_node_b.id = &"node_b"
	_node_b.display_name = "Node B"
	_node_b.tier = 2
	_node_b.ap_cost = 1
	_node_b.required_node_ids = [&"node_a"]

	_node_c = SkillTreeNodeData.new()
	_node_c.id = &"node_c"
	_node_c.display_name = "Node C (expensive)"
	_node_c.tier = 1
	_node_c.ap_cost = 3
	_node_c.required_node_ids = []


# --- compute_can_unlock ---

func test_can_unlock_with_sufficient_ap_and_no_deps() -> void:
	var unlocked: Array[StringName] = []
	assert_true(
		SkillTreeManagerScript.compute_can_unlock(_node_a, unlocked, 1),
		"Should unlock when AP >= cost and no deps required",
	)


func test_cannot_unlock_with_insufficient_ap() -> void:
	var unlocked: Array[StringName] = []
	assert_false(
		SkillTreeManagerScript.compute_can_unlock(_node_c, unlocked, 2),
		"Should not unlock when AP < cost (need 3, have 2)",
	)


func test_cannot_unlock_already_unlocked_node() -> void:
	var unlocked: Array[StringName] = [&"node_a"]
	assert_false(
		SkillTreeManagerScript.compute_can_unlock(_node_a, unlocked, 5),
		"Should not unlock a node that is already unlocked",
	)


func test_cannot_unlock_when_dependency_missing() -> void:
	var unlocked: Array[StringName] = []
	assert_false(
		SkillTreeManagerScript.compute_can_unlock(_node_b, unlocked, 5),
		"Should not unlock node_b when node_a is not unlocked",
	)


func test_can_unlock_when_dependency_is_met() -> void:
	var unlocked: Array[StringName] = [&"node_a"]
	assert_true(
		SkillTreeManagerScript.compute_can_unlock(_node_b, unlocked, 1),
		"Should unlock node_b when node_a is unlocked and AP is sufficient",
	)


func test_can_unlock_with_excess_ap() -> void:
	var unlocked: Array[StringName] = []
	assert_true(
		SkillTreeManagerScript.compute_can_unlock(_node_a, unlocked, 99),
		"Should unlock when AP far exceeds cost",
	)


# --- compute_unlock_result ---

func test_unlock_result_success_decrements_sp() -> void:
	var unlocked: Array[StringName] = []
	var result := SkillTreeManagerScript.compute_unlock_result(_node_a, unlocked, 5)
	assert_true(result["success"], "Unlock should succeed")
	assert_eq(result["remaining_sp"], 4, "SP should decrease by ap_cost (1)")


func test_unlock_result_success_adds_id_to_list() -> void:
	var unlocked: Array[StringName] = []
	var result := SkillTreeManagerScript.compute_unlock_result(_node_a, unlocked, 1)
	assert_true(result["success"])
	assert_true(
		&"node_a" in result["unlocked_ids"],
		"node_a should be in the returned unlocked_ids list",
	)


func test_unlock_result_does_not_mutate_input_list() -> void:
	var unlocked: Array[StringName] = []
	SkillTreeManagerScript.compute_unlock_result(_node_a, unlocked, 5)
	assert_eq(unlocked.size(), 0, "Original unlocked array must not be modified")


func test_unlock_result_fail_preserves_sp() -> void:
	var unlocked: Array[StringName] = []
	var result := SkillTreeManagerScript.compute_unlock_result(_node_c, unlocked, 2)
	assert_false(result["success"], "Unlock should fail with insufficient AP")
	assert_eq(result["remaining_sp"], 2, "SP should be unchanged on failure")


func test_unlock_result_fail_preserves_unlocked_list() -> void:
	var unlocked: Array[StringName] = [&"node_a"]
	var result := SkillTreeManagerScript.compute_unlock_result(_node_b, unlocked, 0)
	assert_false(result["success"])
	assert_eq(result["unlocked_ids"].size(), 1, "unlocked_ids should be unchanged on failure")


# --- CharacterData skill tree fields ---

func test_character_data_has_skill_points_field() -> void:
	var c := CharacterData.new()
	assert_eq(c.skill_points, 0, "CharacterData.skill_points should default to 0")


func test_character_data_has_unlocked_skill_ids_field() -> void:
	var c := CharacterData.new()
	assert_eq(
		c.unlocked_skill_ids.size(),
		0,
		"CharacterData.unlocked_skill_ids should default to empty",
	)


func test_character_data_has_skill_trees_field() -> void:
	var c := CharacterData.new()
	assert_eq(
		c.skill_trees.size(),
		0,
		"CharacterData.skill_trees should default to empty",
	)


# --- LevelManager skill point award ---

func test_level_up_increments_character_skill_points() -> void:
	var c := CharacterData.new()
	c.id = &"test_hero"
	c.level = 1
	c.skill_points = 0
	LevelManager.level_up(c)
	assert_eq(c.skill_points, 1, "level_up() should award 1 skill point")


func test_level_up_returns_skill_points_in_changes_dict() -> void:
	var c := CharacterData.new()
	c.id = &"test_hero"
	c.level = 1
	c.skill_points = 0
	var changes := LevelManager.level_up(c)
	assert_has(changes, "skill_points", "changes dict should include 'skill_points' key")
	assert_eq(changes["skill_points"], 1, "skill_points change should be 1")


func test_multiple_level_ups_accumulate_skill_points() -> void:
	var c := CharacterData.new()
	c.id = &"test_hero"
	c.max_hp = 100
	c.max_ee = 50
	c.attack = 10
	c.magic = 10
	c.defense = 10
	c.resistance = 10
	c.speed = 10
	c.luck = 10
	c.hp_growth = 10.0
	c.ee_growth = 5.0
	c.attack_growth = 1.5
	c.magic_growth = 1.5
	c.defense_growth = 1.5
	c.resistance_growth = 1.5
	c.speed_growth = 1.0
	c.luck_growth = 1.0
	c.level = 1
	c.skill_points = 0
	c.current_xp = 0
	LevelManager.add_xp(c, 1000)  # enough for L2 (400) and L3 (900)
	assert_eq(c.skill_points, 2, "Two level-ups should award 2 skill points total")
