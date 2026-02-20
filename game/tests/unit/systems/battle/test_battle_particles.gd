extends GutTest

## Tests for BattleParticles — static visual feedback helpers for
## resonance state transitions and critical hits.

const BattleParticles = preload(
	"res://systems/battle/battle_particles.gd"
)


# ---------- resonance flash color ----------

func test_resonance_flash_color_resonant_is_gold() -> void:
	var color: Color = BattleParticles.compute_resonance_flash_color(
		Battler.ResonanceState.RESONANT,
	)
	assert_gt(color.r, 0.7, "Resonant color should have high red (gold)")
	assert_gt(color.g, 0.7, "Resonant color should have high green (gold)")
	assert_lt(color.b, 0.6, "Resonant color should have low blue (gold)")


func test_resonance_flash_color_overload_is_red() -> void:
	var color: Color = BattleParticles.compute_resonance_flash_color(
		Battler.ResonanceState.OVERLOAD,
	)
	assert_gt(color.r, 0.7, "Overload color should have high red")
	assert_lt(color.g, 0.5, "Overload color should have low green")


func test_resonance_flash_color_focused_is_white() -> void:
	var color: Color = BattleParticles.compute_resonance_flash_color(
		Battler.ResonanceState.FOCUSED,
	)
	assert_eq(color, Color.WHITE, "Focused state returns WHITE (no tint)")


func test_resonance_flash_color_hollow_is_white() -> void:
	var color: Color = BattleParticles.compute_resonance_flash_color(
		Battler.ResonanceState.HOLLOW,
	)
	assert_eq(color, Color.WHITE, "Hollow state returns WHITE (no tint)")


# ---------- should_show_resonance_flash ----------

func test_should_show_flash_focused_to_resonant() -> void:
	assert_true(
		BattleParticles.should_show_resonance_flash(
			Battler.ResonanceState.FOCUSED,
			Battler.ResonanceState.RESONANT,
		),
		"FOCUSED → RESONANT should trigger flash",
	)


func test_should_show_flash_resonant_to_overload() -> void:
	assert_true(
		BattleParticles.should_show_resonance_flash(
			Battler.ResonanceState.RESONANT,
			Battler.ResonanceState.OVERLOAD,
		),
		"RESONANT → OVERLOAD should trigger flash",
	)


func test_should_not_show_flash_on_same_state() -> void:
	assert_false(
		BattleParticles.should_show_resonance_flash(
			Battler.ResonanceState.RESONANT,
			Battler.ResonanceState.RESONANT,
		),
		"No flash when state does not change",
	)


func test_should_not_show_flash_to_focused() -> void:
	# Gauge draining back to FOCUSED should not flash (recovery is silent)
	assert_false(
		BattleParticles.should_show_resonance_flash(
			Battler.ResonanceState.RESONANT,
			Battler.ResonanceState.FOCUSED,
		),
		"Dropping back to FOCUSED should not trigger flash",
	)


func test_should_not_show_flash_to_hollow() -> void:
	# Hollow is defeat state — defeated signal handles that visual
	assert_false(
		BattleParticles.should_show_resonance_flash(
			Battler.ResonanceState.OVERLOAD,
			Battler.ResonanceState.HOLLOW,
		),
		"Entering HOLLOW should not trigger resonance flash",
	)


# ---------- critical flash ----------

func test_crit_flash_color_is_bright() -> void:
	var color: Color = BattleParticles.compute_crit_flash_color()
	# Should be a bright, near-white gold
	assert_gt(color.r, 0.8, "Crit flash should be bright (high red)")
	assert_gt(color.g, 0.8, "Crit flash should be bright (high green)")


func test_crit_flash_duration_is_positive() -> void:
	var dur: float = BattleParticles.compute_crit_flash_duration()
	assert_gt(dur, 0.0, "Crit flash duration must be positive")
	assert_lt(dur, 1.0, "Crit flash duration must be brief (< 1s)")
