extends GutTest

## Tests for VerdantForestBond01 — BOND-01 "Knife Lessons" eligibility and
## dialogue data. Iris corrects Kael's knife grip in a 5+ line campfire banter.

const Bond01 = preload(
	"res://scenes/verdant_forest/verdant_forest_bond01_dialogue.gd"
)


# ---------- flag helpers ----------

func test_get_bond01_flag_is_bond_01_knife_lessons() -> void:
	assert_eq(
		Bond01.get_bond01_flag(),
		"bond_01_knife_lessons",
		"One-shot flag should be bond_01_knife_lessons",
	)


func test_get_bond01_gate_flag_is_iris_recruited() -> void:
	assert_eq(
		Bond01.get_bond01_gate_flag(),
		"iris_recruited",
		"Gate flag should be iris_recruited",
	)


# ---------- eligibility ----------

func test_eligible_when_iris_recruited_and_both_in_party() -> void:
	var flags := {"iris_recruited": true}
	var party := [&"kael", &"iris"]
	assert_true(
		Bond01.compute_bond01_eligible(flags, party),
		"Should be eligible when iris_recruited and both are in party",
	)


func test_not_eligible_without_iris_recruited_flag() -> void:
	var party := [&"kael", &"iris"]
	assert_false(
		Bond01.compute_bond01_eligible({}, party),
		"Not eligible when iris_recruited flag is absent",
	)


func test_not_eligible_when_already_played() -> void:
	var flags := {
		"iris_recruited": true,
		"bond_01_knife_lessons": true,
	}
	var party := [&"kael", &"iris"]
	assert_false(
		Bond01.compute_bond01_eligible(flags, party),
		"Not eligible when bond_01_knife_lessons already set",
	)


func test_not_eligible_when_iris_not_in_party() -> void:
	var flags := {"iris_recruited": true}
	var party := [&"kael"]
	assert_false(
		Bond01.compute_bond01_eligible(flags, party),
		"Not eligible when Iris is missing from party",
	)


func test_not_eligible_when_kael_not_in_party() -> void:
	var flags := {"iris_recruited": true}
	var party := [&"iris"]
	assert_false(
		Bond01.compute_bond01_eligible(flags, party),
		"Not eligible when Kael is missing from party",
	)


func test_not_eligible_when_party_is_empty() -> void:
	var flags := {"iris_recruited": true}
	assert_false(
		Bond01.compute_bond01_eligible(flags, []),
		"Not eligible with empty party",
	)


# ---------- dialogue data ----------

func test_dialogue_returns_array() -> void:
	var lines := Bond01.get_bond01_lines()
	assert_true(lines is Array, "get_bond01_lines() should return an Array")


func test_dialogue_has_five_or_more_lines() -> void:
	var lines := Bond01.get_bond01_lines()
	assert_gte(lines.size(), 5, "BOND-01 should have at least 5 lines")


func test_dialogue_lines_have_speaker_and_text_keys() -> void:
	for line in Bond01.get_bond01_lines():
		assert_has(line, "speaker")
		assert_has(line, "text")


func test_dialogue_has_iris_and_kael_speakers() -> void:
	var speakers: Array = []
	for line in Bond01.get_bond01_lines():
		if line["speaker"] not in speakers:
			speakers.append(line["speaker"])
	assert_has(speakers, "Iris", "Iris must speak in BOND-01")
	assert_has(speakers, "Kael", "Kael must speak in BOND-01")


func test_dialogue_references_knife_or_grip() -> void:
	var all_text: String = ""
	for line in Bond01.get_bond01_lines():
		all_text += line["text"].to_lower()
	assert_true(
		"knife" in all_text or "grip" in all_text or "holding" in all_text,
		"BOND-01 should reference the knife/grip lesson",
	)
