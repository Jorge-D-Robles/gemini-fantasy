extends GutTest

## Tests for T-0107: Verify all 8 party members have correct abilities wired.
## Each character must have the design-doc abilities loaded and accessible.


const _CHARACTER_PATHS: Dictionary = {
	"kael": "res://data/characters/kael.tres",
	"iris": "res://data/characters/iris.tres",
	"garrick": "res://data/characters/garrick.tres",
	"nyx": "res://data/characters/nyx.tres",
	"lyra": "res://data/characters/lyra.tres",
	"sienna": "res://data/characters/sienna.tres",
	"cipher": "res://data/characters/cipher.tres",
	"ash": "res://data/characters/ash.tres",
}

# Design-doc ability IDs per character (basic abilities only, not skill tree).
const _EXPECTED_ABILITIES: Dictionary = {
	"kael": [
		&"echo_strike", &"resonance_pulse", &"memory_weave",
		&"adaptive_strike", &"echo_fusion", &"reality_anchor",
		&"convergence_touch",
	],
	"iris": [
		&"heavy_strike", &"emp_burst", &"overclock",
		&"shrapnel_shot", &"prototype_deploy", &"resonance_disruptor",
		&"railgun",
	],
	"garrick": [
		&"guardians_stand", &"purifying_light", &"shield_bash",
		&"martyrs_resolve", &"crystal_purge", &"unbreakable",
		&"last_stand",
	],
	"nyx": [
		&"void_bolt", &"phase_shift", &"reality_break",
		&"shadow_bind", &"emotional_storm", &"existence_flux",
		&"un_being",
	],
	"lyra": [
		&"memory_strike", &"echo_mend", &"resonance_shield",
		&"fragment_vision", &"ancient_wisdom", &"memory_cascade",
		&"echo_restoration",
	],
	"sienna": [
		&"analyze_weakness", &"toxic_injection", &"neural_disrupt",
		&"data_extraction", &"chemical_burn", &"experimental_serum",
		&"mind_break",
	],
	"cipher": [
		&"quick_slash", &"hack_system", &"smoke_bomb",
		&"blade_flurry", &"system_override", &"cloaking_field",
		&"execution_protocol",
	],
	"ash": [
		&"calming_presence", &"emotional_wave", &"silent_scream",
		&"empathic_shield", &"harmonic_burst",
	],
}


func test_all_characters_load() -> void:
	for char_name in _CHARACTER_PATHS:
		var path: String = _CHARACTER_PATHS[char_name]
		var data: CharacterData = load(path) as CharacterData
		assert_not_null(
			data, "CharacterData '%s' must load from %s" % [char_name, path]
		)
		assert_eq(
			data.id, StringName(char_name),
			"CharacterData id must be '%s'" % char_name
		)


func test_each_character_has_correct_ability_count() -> void:
	for char_name in _EXPECTED_ABILITIES:
		var path: String = _CHARACTER_PATHS[char_name]
		var data: CharacterData = load(path) as CharacterData
		assert_not_null(data)
		var expected_count: int = _EXPECTED_ABILITIES[char_name].size()
		assert_eq(
			data.abilities.size(), expected_count,
			"'%s' should have %d abilities, got %d" % [
				char_name, expected_count, data.abilities.size(),
			]
		)


func test_each_character_has_correct_ability_ids() -> void:
	for char_name in _EXPECTED_ABILITIES:
		var path: String = _CHARACTER_PATHS[char_name]
		var data: CharacterData = load(path) as CharacterData
		assert_not_null(data)
		var actual_ids: Array[StringName] = []
		for ability in data.abilities:
			actual_ids.append(ability.id)
		var expected: Array = _EXPECTED_ABILITIES[char_name]
		for expected_id in expected:
			assert_true(
				actual_ids.has(expected_id),
				"'%s' missing ability '%s'" % [char_name, expected_id]
			)


func test_all_abilities_have_valid_fields() -> void:
	for char_name in _CHARACTER_PATHS:
		var path: String = _CHARACTER_PATHS[char_name]
		var data: CharacterData = load(path) as CharacterData
		assert_not_null(data)
		for ability in data.abilities:
			var a: AbilityData = ability as AbilityData
			assert_not_null(
				a, "'%s' has non-AbilityData in abilities array" % char_name
			)
			assert_true(
				a.id != &"",
				"ability id must not be empty for '%s'" % char_name
			)
			assert_true(
				a.display_name != "",
				"ability display_name must not be empty for '%s'" % char_name
			)
