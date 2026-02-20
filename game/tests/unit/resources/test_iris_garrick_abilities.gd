extends GutTest

## Tests for Iris and Garrick full ability sets (10 new AbilityData .tres files).
## T-0222: Verifies EE cost, resonance cost, damage_stat, target_type, and display_name.

const _OVERCLOCK := preload("res://data/abilities/overclock.tres")
const _SHRAPNEL_SHOT := preload("res://data/abilities/shrapnel_shot.tres")
const _PROTOTYPE_DEPLOY := preload("res://data/abilities/prototype_deploy.tres")
const _RESONANCE_DISRUPTOR := preload("res://data/abilities/resonance_disruptor.tres")
const _RAILGUN := preload("res://data/abilities/railgun.tres")

const _SHIELD_BASH := preload("res://data/abilities/shield_bash.tres")
const _MARTYRS_RESOLVE := preload("res://data/abilities/martyrs_resolve.tres")
const _CRYSTAL_PURGE := preload("res://data/abilities/crystal_purge.tres")
const _UNBREAKABLE := preload("res://data/abilities/unbreakable.tres")
const _LAST_STAND := preload("res://data/abilities/last_stand.tres")


# --- Iris abilities ---

func test_overclock_stats() -> void:
	assert_eq(_OVERCLOCK.ee_cost, 30, "Overclock must cost 30 EE")
	assert_eq(_OVERCLOCK.target_type, 4, "Overclock targets SELF (4)")
	assert_false(_OVERCLOCK.status_effect.is_empty(), "Overclock must have a status_effect")
	assert_false(_OVERCLOCK.display_name.is_empty(), "Overclock must have a display_name")


func test_shrapnel_shot_stats() -> void:
	assert_eq(_SHRAPNEL_SHOT.ee_cost, 35, "Shrapnel Shot must cost 35 EE")
	assert_eq(_SHRAPNEL_SHOT.damage_stat, 0, "Shrapnel Shot uses ATTACK stat (0)")
	assert_gt(_SHRAPNEL_SHOT.damage_base, 0, "Shrapnel Shot must have positive damage_base")
	assert_false(_SHRAPNEL_SHOT.display_name.is_empty(), "Shrapnel Shot must have a display_name")


func test_prototype_deploy_stats() -> void:
	assert_eq(_PROTOTYPE_DEPLOY.ee_cost, 40, "Prototype Deploy must cost 40 EE")
	assert_eq(_PROTOTYPE_DEPLOY.resonance_cost, 40.0, "Prototype Deploy requires 40% Resonance")
	assert_eq(_PROTOTYPE_DEPLOY.target_type, 4, "Prototype Deploy targets SELF (4)")
	assert_false(
		_PROTOTYPE_DEPLOY.display_name.is_empty(), "Prototype Deploy must have a display_name"
	)


func test_resonance_disruptor_stats() -> void:
	assert_eq(_RESONANCE_DISRUPTOR.ee_cost, 50, "Resonance Disruptor must cost 50 EE")
	assert_eq(_RESONANCE_DISRUPTOR.target_type, 1, "Resonance Disruptor targets ALL_ENEMIES (1)")
	assert_false(
		_RESONANCE_DISRUPTOR.status_effect.is_empty(),
		"Resonance Disruptor must have a status_effect",
	)
	assert_false(
		_RESONANCE_DISRUPTOR.display_name.is_empty(),
		"Resonance Disruptor must have a display_name",
	)


func test_railgun_stats() -> void:
	assert_eq(_RAILGUN.ee_cost, 70, "Railgun must cost 70 EE")
	assert_eq(_RAILGUN.resonance_cost, 60.0, "Railgun requires 60% Resonance")
	assert_eq(_RAILGUN.damage_stat, 0, "Railgun uses ATTACK stat (0)")
	assert_gt(_RAILGUN.damage_base, 200, "Railgun must be an extreme damage move (>200)")
	assert_false(_RAILGUN.display_name.is_empty(), "Railgun must have a display_name")


# --- Garrick abilities ---

func test_shield_bash_stats() -> void:
	assert_eq(_SHIELD_BASH.ee_cost, 22, "Shield Bash must cost 22 EE")
	assert_eq(_SHIELD_BASH.damage_stat, 0, "Shield Bash uses ATTACK stat (0)")
	assert_gt(_SHIELD_BASH.damage_base, 0, "Shield Bash must have positive damage_base")
	assert_eq(_SHIELD_BASH.status_effect, "stun", "Shield Bash must have stun status_effect")
	assert_false(_SHIELD_BASH.display_name.is_empty(), "Shield Bash must have a display_name")


func test_martyrs_resolve_stats() -> void:
	assert_eq(_MARTYRS_RESOLVE.ee_cost, 35, "Martyr's Resolve must cost 35 EE")
	assert_eq(_MARTYRS_RESOLVE.resonance_cost, 30.0, "Martyr's Resolve requires 30% Resonance")
	assert_eq(_MARTYRS_RESOLVE.target_type, 4, "Martyr's Resolve targets SELF (4)")
	assert_false(
		_MARTYRS_RESOLVE.display_name.is_empty(), "Martyr's Resolve must have a display_name"
	)


func test_crystal_purge_stats() -> void:
	assert_eq(_CRYSTAL_PURGE.ee_cost, 40, "Crystal Purge must cost 40 EE")
	assert_eq(_CRYSTAL_PURGE.target_type, 1, "Crystal Purge targets ALL_ENEMIES (1)")
	assert_eq(_CRYSTAL_PURGE.damage_stat, 1, "Crystal Purge uses MAGIC stat (1)")
	assert_gt(_CRYSTAL_PURGE.damage_base, 0, "Crystal Purge must have positive damage_base")
	assert_false(_CRYSTAL_PURGE.display_name.is_empty(), "Crystal Purge must have a display_name")


func test_unbreakable_stats() -> void:
	assert_eq(_UNBREAKABLE.ee_cost, 50, "Unbreakable must cost 50 EE")
	assert_eq(_UNBREAKABLE.resonance_cost, 50.0, "Unbreakable requires 50% Resonance")
	assert_eq(_UNBREAKABLE.target_type, 4, "Unbreakable targets SELF (4)")
	assert_false(
		_UNBREAKABLE.status_effect.is_empty(), "Unbreakable must have a status_effect"
	)
	assert_false(_UNBREAKABLE.display_name.is_empty(), "Unbreakable must have a display_name")


func test_last_stand_is_passive() -> void:
	assert_eq(_LAST_STAND.ee_cost, 0, "Last Stand is passive — 0 EE cost")
	assert_eq(_LAST_STAND.target_type, 4, "Last Stand targets SELF (4)")
	assert_false(
		_LAST_STAND.status_effect.is_empty(), "Last Stand must have a status_effect"
	)
	assert_false(_LAST_STAND.display_name.is_empty(), "Last Stand must have a display_name")
