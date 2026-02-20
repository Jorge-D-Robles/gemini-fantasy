# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Roothollow NPC flag-reactive dialogue selection.
## Each NPC has different dialogue based on EventFlags state.
## Tests call static helper functions that take a flags dictionary.

var _rh: GDScript


func before_each() -> void:
	_rh = load("res://scenes/roothollow/roothollow_dialogue.gd")


func _flags(names: Array = []) -> Dictionary:
	var d := {}
	for n in names:
		d[n] = true
	return d


# -- Maren (Innkeeper) --

func test_maren_no_flags_returns_4_lines() -> void:
	var lines: PackedStringArray = _rh.get_maren_dialogue(_flags())
	assert_eq(lines.size(), 4)


func test_maren_no_flags_first_line() -> void:
	var lines: PackedStringArray = _rh.get_maren_dialogue(_flags())
	assert_string_contains(lines[0], "Come in, come in")


func test_maren_lyra_discovered() -> void:
	var lines: PackedStringArray = _rh.get_maren_dialogue(
		_flags(["opening_lyra_discovered"])
	)
	assert_eq(lines.size(), 5)
	assert_string_contains(lines[0], "Half the village was worried")


func test_maren_iris_recruited() -> void:
	var lines: PackedStringArray = _rh.get_maren_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_eq(lines.size(), 4)
	assert_string_contains(lines[0], "two days without a word")


func test_maren_iris_recruited_offers_food() -> void:
	var lines: PackedStringArray = _rh.get_maren_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_true(
		_any_line_contains(lines, "hungry")
		or _any_line_contains(lines, "meal"),
		"Maren should offer food to Iris",
	)


func test_maren_garrick_recruited() -> void:
	var lines: PackedStringArray = _rh.get_maren_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	assert_eq(lines.size(), 4)
	assert_string_contains(lines[0], "Old Iron himself")


func test_maren_garrick_flag_takes_priority() -> void:
	var lines: PackedStringArray = _rh.get_maren_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	assert_string_contains(lines[0], "Old Iron")


# -- Bram (Shopkeeper) --

func test_bram_no_flags_returns_4_lines() -> void:
	var lines: PackedStringArray = _rh.get_bram_dialogue(_flags())
	assert_eq(lines.size(), 4)


func test_bram_no_flags_first_line() -> void:
	var lines: PackedStringArray = _rh.get_bram_dialogue(_flags())
	assert_string_contains(lines[0], "Good timing")


func test_bram_lyra_discovered() -> void:
	var lines: PackedStringArray = _rh.get_bram_dialogue(
		_flags(["opening_lyra_discovered"])
	)
	assert_eq(lines.size(), 4)
	assert_string_contains(lines[0], "A conscious echo")


func test_bram_iris_recruited() -> void:
	var lines: PackedStringArray = _rh.get_bram_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_eq(lines.size(), 4)
	assert_true(
		_any_line_contains(lines, "shrine")
		or _any_line_contains(lines, "stranger"),
		"Bram should mention the shrine stranger",
	)


func test_bram_iris_recruited_mentions_refused_food() -> void:
	var lines: PackedStringArray = _rh.get_bram_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_true(
		_any_line_contains(lines, "eat")
		or _any_line_contains(lines, "food"),
		"Bram should mention that the stranger refused food",
	)


func test_bram_garrick_recruited() -> void:
	var lines: PackedStringArray = _rh.get_bram_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[0], "Garrick Thorne")


# -- Elder Thessa --

func test_thessa_no_flags_returns_5_lines() -> void:
	var lines: PackedStringArray = _rh.get_thessa_dialogue(_flags())
	assert_eq(lines.size(), 5)


func test_thessa_no_flags_first_line() -> void:
	var lines: PackedStringArray = _rh.get_thessa_dialogue(_flags())
	assert_string_contains(lines[0], "wondering when")


func test_thessa_lyra_discovered() -> void:
	var lines: PackedStringArray = _rh.get_thessa_dialogue(
		_flags(["opening_lyra_discovered"])
	)
	assert_eq(lines.size(), 5)
	assert_string_contains(lines[0], "A conscious echo")


func test_thessa_iris_recruited() -> void:
	var lines: PackedStringArray = _rh.get_thessa_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_eq(lines.size(), 4)
	assert_string_contains(lines[0], "Initiative deserter")


func test_thessa_garrick_recruited() -> void:
	var lines: PackedStringArray = _rh.get_thessa_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	assert_eq(lines.size(), 4)
	assert_string_contains(lines[0], "Garrick Thorne")


func test_thessa_garrick_mentions_prismfall() -> void:
	var lines: PackedStringArray = _rh.get_thessa_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	assert_string_contains(lines[1], "Prismfall")


func test_thessa_garrick_mentions_allies() -> void:
	var lines: PackedStringArray = _rh.get_thessa_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	assert_string_contains(lines[1], "allies")


# -- Wren (Scout) --

func test_wren_no_flags_returns_3_lines() -> void:
	var lines: PackedStringArray = _rh.get_wren_dialogue(_flags())
	assert_eq(lines.size(), 3)


func test_wren_no_flags_first_line() -> void:
	var lines: PackedStringArray = _rh.get_wren_dialogue(_flags())
	assert_string_contains(lines[0], "western trail")


func test_wren_lyra_discovered() -> void:
	var lines: PackedStringArray = _rh.get_wren_dialogue(
		_flags(["opening_lyra_discovered"])
	)
	assert_eq(lines.size(), 4)
	assert_string_contains(lines[0], "came back from the ruins")


func test_wren_iris_recruited() -> void:
	var lines: PackedStringArray = _rh.get_wren_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[0], "deserter")


func test_wren_iris_recruited_welcomes_deserter() -> void:
	var lines: PackedStringArray = _rh.get_wren_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_true(
		_any_line_contains(lines, "deserter")
		or _any_line_contains(lines, "undercover"),
		"Wren should challenge or accept Iris as deserter",
	)


func test_wren_garrick_recruited() -> void:
	var lines: PackedStringArray = _rh.get_wren_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	assert_eq(lines.size(), 2)
	assert_string_contains(lines[0], "reputation")


# -- Garrick (Pre-Recruitment) --

func test_garrick_no_flags_returns_3_lines() -> void:
	var lines: PackedStringArray = _rh.get_garrick_casual_dialogue(
		_flags()
	)
	assert_eq(lines.size(), 3)


func test_garrick_no_flags_first_line() -> void:
	var lines: PackedStringArray = _rh.get_garrick_casual_dialogue(
		_flags()
	)
	assert_string_contains(lines[0], "Echo hunter")


func test_garrick_lyra_discovered() -> void:
	var lines: PackedStringArray = _rh.get_garrick_casual_dialogue(
		_flags(["opening_lyra_discovered"])
	)
	assert_eq(lines.size(), 4)
	assert_string_contains(lines[0], "Word travels fast")


# -- Lina (Child) --

func test_lina_no_flags_returns_4_lines() -> void:
	var lines: PackedStringArray = _rh.get_lina_dialogue(_flags())
	assert_eq(lines.size(), 4)


func test_lina_no_flags_first_line() -> void:
	var lines: PackedStringArray = _rh.get_lina_dialogue(_flags())
	assert_string_contains(lines[0], "Look what I found")


func test_lina_lyra_discovered() -> void:
	var lines: PackedStringArray = _rh.get_lina_dialogue(
		_flags(["opening_lyra_discovered"])
	)
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[0], "acting all serious")


func test_lina_iris_recruited() -> void:
	var lines: PackedStringArray = _rh.get_lina_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[0], "shrine")


func test_lina_iris_recruited_mentions_horse() -> void:
	var lines: PackedStringArray = _rh.get_lina_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_true(
		_any_line_contains(lines, "horse"),
		"Lina should ask about the horse when Iris is recruited",
	)


func test_lina_garrick_recruited() -> void:
	var lines: PackedStringArray = _rh.get_lina_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[0], "knight who fought a dragon")


# -- Flag Priority Tests --

func test_flag_priority_garrick_over_iris() -> void:
	var with_garrick: PackedStringArray = _rh.get_maren_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	var with_iris: PackedStringArray = _rh.get_maren_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_ne(with_garrick[0], with_iris[0])


func test_flag_priority_iris_over_lyra() -> void:
	var with_iris: PackedStringArray = _rh.get_bram_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	var with_lyra: PackedStringArray = _rh.get_bram_dialogue(
		_flags(["opening_lyra_discovered"])
	)
	assert_ne(with_iris[0], with_lyra[0])


# -- Regional Slang Verification --


func _any_line_contains(
	lines: PackedStringArray,
	substring: String,
) -> bool:
	for line in lines:
		if line.contains(substring):
			return true
	return false


func _has_tangle_slang(lines: PackedStringArray) -> bool:
	return (
		_any_line_contains(lines, "root deep")
		or _any_line_contains(lines, "overgrown")
		or _any_line_contains(lines, "memory bloom")
	)


func test_maren_uses_tangle_slang() -> void:
	var states: Array[Array] = [
		[],
		["opening_lyra_discovered"],
		["opening_lyra_discovered", "iris_recruited"],
		[
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		],
	]
	for state in states:
		var lines: PackedStringArray = _rh.get_maren_dialogue(
			_flags(state)
		)
		assert_true(
			_has_tangle_slang(lines),
			"Maren should use Tangle slang in state: %s" % [
				str(state),
			],
		)


func test_bram_uses_tangle_slang() -> void:
	var states: Array[Array] = [
		[],
		["opening_lyra_discovered"],
		["opening_lyra_discovered", "iris_recruited"],
		[
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		],
	]
	for state in states:
		var lines: PackedStringArray = _rh.get_bram_dialogue(
			_flags(state)
		)
		assert_true(
			_has_tangle_slang(lines),
			"Bram should use Tangle slang in state: %s" % [
				str(state),
			],
		)


func test_thessa_uses_tangle_slang() -> void:
	var states: Array[Array] = [
		[],
		["opening_lyra_discovered"],
		["opening_lyra_discovered", "iris_recruited"],
		[
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		],
	]
	for state in states:
		var lines: PackedStringArray = _rh.get_thessa_dialogue(
			_flags(state)
		)
		assert_true(
			_has_tangle_slang(lines),
			"Thessa should use Tangle slang in state: %s" % [
				str(state),
			],
		)


func test_wren_uses_tangle_slang() -> void:
	var states: Array[Array] = [
		[],
		["opening_lyra_discovered"],
		["opening_lyra_discovered", "iris_recruited"],
		[
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		],
	]
	for state in states:
		var lines: PackedStringArray = _rh.get_wren_dialogue(
			_flags(state)
		)
		assert_true(
			_has_tangle_slang(lines),
			"Wren should use Tangle slang in state: %s" % [
				str(state),
			],
		)


func test_garrick_uses_fire_metaphor() -> void:
	var lines: PackedStringArray = (
		_rh.get_garrick_casual_dialogue(_flags())
	)
	assert_true(
		_any_line_contains(lines, "burned")
		or _any_line_contains(lines, "fire")
		or _any_line_contains(lines, "ash"),
		"Garrick should use fire/ash metaphor",
	)


func test_garrick_no_tangle_slang() -> void:
	var default_lines: PackedStringArray = (
		_rh.get_garrick_casual_dialogue(_flags())
	)
	var lyra_lines: PackedStringArray = (
		_rh.get_garrick_casual_dialogue(
			_flags(["opening_lyra_discovered"])
		)
	)
	assert_false(
		_has_tangle_slang(default_lines),
		"Garrick should not use Tangle slang (default)",
	)
	assert_false(
		_has_tangle_slang(lyra_lines),
		"Garrick should not use Tangle slang (lyra)",
	)


# -- Iris Arrival Cutscene --

func test_iris_arrival_lines_count() -> void:
	var lines: Array = _rh.get_iris_arrival_lines()
	assert_eq(lines.size(), 6)


func test_iris_arrival_first_speaker_is_iris() -> void:
	var lines: Array = _rh.get_iris_arrival_lines()
	assert_eq(lines[0]["speaker"], "Iris")


func test_iris_arrival_first_line_mentions_trees() -> void:
	var lines: Array = _rh.get_iris_arrival_lines()
	assert_string_contains(lines[0]["text"], "trees")


func test_iris_arrival_has_kael_lines() -> void:
	var lines: Array = _rh.get_iris_arrival_lines()
	var found := false
	for line in lines:
		if line["speaker"] == "Kael":
			found = true
			break
	assert_true(found, "Arrival dialogue should include Kael lines")


func test_iris_arrival_last_line_mentions_nice() -> void:
	var lines: Array = _rh.get_iris_arrival_lines()
	assert_string_contains(lines.back()["text"], "nice")


func test_iris_arrival_flag_name_not_empty() -> void:
	var flag: String = _rh.get_iris_arrival_flag()
	assert_false(flag.is_empty(), "Arrival flag must not be empty")


# -- Thessa Briefing (garrick_recruited one-time scene) --

func _any_brief_line_contains(
	lines: Array,
	substring: String,
) -> bool:
	for line in lines:
		if line["text"].contains(substring):
			return true
	return false


func test_thessa_briefing_count() -> void:
	var lines: Array = _rh.get_thessa_briefing_lines()
	assert_eq(lines.size(), 7)


func test_thessa_briefing_first_speaker() -> void:
	var lines: Array = _rh.get_thessa_briefing_lines()
	assert_eq(lines[0]["speaker"], "Elder Thessa")


func test_thessa_briefing_mentions_capital() -> void:
	var lines: Array = _rh.get_thessa_briefing_lines()
	assert_true(
		_any_brief_line_contains(lines, "Capital"),
		"Briefing should mention the Overgrown Capital",
	)


func test_thessa_briefing_mentions_research_quarter() -> void:
	var lines: Array = _rh.get_thessa_briefing_lines()
	assert_true(
		_any_brief_line_contains(lines, "research quarter"),
		"Briefing should mention the research quarter",
	)


func test_thessa_briefing_mentions_time_constraint() -> void:
	var lines: Array = _rh.get_thessa_briefing_lines()
	assert_true(
		_any_brief_line_contains(lines, "time")
		or _any_brief_line_contains(lines, "constraint"),
		"Briefing should establish a time constraint",
	)


func test_thessa_briefing_has_tangle_slang() -> void:
	var lines: Array = _rh.get_thessa_briefing_lines()
	assert_true(
		_any_brief_line_contains(lines, "root deep")
		or _any_brief_line_contains(lines, "overgrown"),
		"Thessa should use Tangle slang in briefing",
	)


func test_thessa_briefing_flag_not_empty() -> void:
	var flag: String = _rh.get_thessa_briefing_flag()
	assert_false(flag.is_empty(), "Briefing flag must not be empty")
