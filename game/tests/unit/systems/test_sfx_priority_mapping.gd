extends GutTest

## Tests for SfxLibrary.compute_sfx_priority() — verifies CRITICAL vs NORMAL
## priority mapping per SFX path.

const SfxLib := preload("res://systems/sfx_library.gd")
const AMScript := preload("res://autoloads/audio_manager.gd")


func test_combat_death_priority_is_critical() -> void:
	assert_eq(
		SfxLib.compute_sfx_priority(SfxLib.COMBAT_DEATH),
		AMScript.SfxPriority.CRITICAL,
		"COMBAT_DEATH must be CRITICAL priority — must always play even if pool busy",
	)


func test_combat_critical_hit_priority_is_critical() -> void:
	assert_eq(
		SfxLib.compute_sfx_priority(SfxLib.COMBAT_CRITICAL_HIT),
		AMScript.SfxPriority.CRITICAL,
		"COMBAT_CRITICAL_HIT must be CRITICAL priority — audible feedback for crit mechanic",
	)


func test_combat_attack_hit_priority_is_normal() -> void:
	assert_eq(
		SfxLib.compute_sfx_priority(SfxLib.COMBAT_ATTACK_HIT),
		AMScript.SfxPriority.NORMAL,
		"COMBAT_ATTACK_HIT should be NORMAL priority — round-robin, droppable if pool full",
	)


func test_combat_magic_cast_priority_is_normal() -> void:
	assert_eq(
		SfxLib.compute_sfx_priority(SfxLib.COMBAT_MAGIC_CAST),
		AMScript.SfxPriority.NORMAL,
		"COMBAT_MAGIC_CAST should be NORMAL priority",
	)


func test_combat_heal_chime_priority_is_normal() -> void:
	assert_eq(
		SfxLib.compute_sfx_priority(SfxLib.COMBAT_HEAL_CHIME),
		AMScript.SfxPriority.NORMAL,
		"COMBAT_HEAL_CHIME should be NORMAL priority",
	)


func test_ui_confirm_priority_is_normal() -> void:
	assert_eq(
		SfxLib.compute_sfx_priority(SfxLib.UI_CONFIRM),
		AMScript.SfxPriority.NORMAL,
		"UI_CONFIRM should be NORMAL priority",
	)


func test_critical_paths_array_contains_death_and_crit() -> void:
	assert_true(
		SfxLib.COMBAT_DEATH in SfxLib.CRITICAL_PRIORITY_PATHS,
		"CRITICAL_PRIORITY_PATHS must contain COMBAT_DEATH",
	)
	assert_true(
		SfxLib.COMBAT_CRITICAL_HIT in SfxLib.CRITICAL_PRIORITY_PATHS,
		"CRITICAL_PRIORITY_PATHS must contain COMBAT_CRITICAL_HIT",
	)


func test_critical_paths_array_does_not_contain_attack_hit() -> void:
	assert_false(
		SfxLib.COMBAT_ATTACK_HIT in SfxLib.CRITICAL_PRIORITY_PATHS,
		"COMBAT_ATTACK_HIT must NOT be in CRITICAL_PRIORITY_PATHS",
	)
