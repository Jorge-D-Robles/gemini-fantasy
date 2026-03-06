# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Chapter 12 "The Iron Coast" event:
## Party descends into Gearhaven Undercity, finds Cipher,
## escapes Initiative sweep. Cipher joins party.
## 8 scenes (7 + camp).


# --- Gate ---


func test_can_trigger_requires_rogue_decided() -> void:
	var flags := {}
	assert_false(
		IronCoast.compute_can_trigger(flags),
		"Should not trigger without rogue_decided",
	)


func test_can_trigger_true_when_rogue_decided() -> void:
	var flags := {"rogue_decided": true}
	assert_true(
		IronCoast.compute_can_trigger(flags),
		"Should trigger when rogue_decided is set",
	)


func test_can_trigger_false_when_already_done() -> void:
	var flags := {
		"rogue_decided": true,
		"cipher_recruited": true,
	}
	assert_false(
		IronCoast.compute_can_trigger(flags),
		"Should not trigger if cipher_recruited already set",
	)


# --- Scene 1: Going Down ---


func test_descent_lines_not_empty() -> void:
	var lines := IronCoast.compute_descent_lines()
	assert_gt(lines.size(), 0, "Scene 1 should have lines")


func test_descent_includes_undercity() -> void:
	var found := false
	for line in IronCoast.compute_descent_lines():
		if "Undercity" in line.text:
			found = true
			break
	assert_true(found, "Descent should mention Undercity")


# --- Scene 2: The Broken Clock ---


func test_bar_lines_not_empty() -> void:
	var lines := IronCoast.compute_bar_lines()
	assert_gt(lines.size(), 0, "Scene 2 should have lines")


func test_bar_includes_bartender() -> void:
	var found := false
	for line in IronCoast.compute_bar_lines():
		if line.speaker == "Bartender":
			found = true
			break
	assert_true(found, "Bar scene should include Bartender")


# --- Scene 3: Level Six ---


func test_server_lines_not_empty() -> void:
	var lines := IronCoast.compute_server_lines()
	assert_gt(lines.size(), 0, "Scene 3 should have lines")


func test_server_includes_infrastructure() -> void:
	var found := false
	for line in IronCoast.compute_server_lines():
		if "infrastructure" in line.text or "server" in line.text:
			found = true
			break
	assert_true(found, "Server scene should mention infrastructure")


# --- Scene 4: First Contact ---


func test_contact_lines_not_empty() -> void:
	var lines := IronCoast.compute_contact_lines()
	assert_gt(lines.size(), 0, "Scene 4 should have lines")


func test_contact_includes_cipher() -> void:
	var found := false
	for line in IronCoast.compute_contact_lines():
		if line.speaker == "Cipher":
			found = true
			break
	assert_true(found, "Contact scene should include Cipher")


# --- Scene 5: Harbor Water ---


func test_harbor_lines_not_empty() -> void:
	var lines := IronCoast.compute_harbor_lines()
	assert_gt(lines.size(), 0, "Scene 5 should have lines")


func test_harbor_includes_cipher_joining() -> void:
	var found := false
	for line in IronCoast.compute_harbor_lines():
		if line.speaker == "Cipher" and "Tonight" in line.text:
			found = true
			break
	assert_true(
		found, "Cipher should agree to stay for tonight",
	)


# --- Scene 6: The Full Picture ---


func test_briefing_lines_not_empty() -> void:
	var lines := IronCoast.compute_briefing_lines()
	assert_gt(lines.size(), 0, "Scene 6 should have lines")


func test_briefing_includes_cage() -> void:
	var found := false
	for line in IronCoast.compute_briefing_lines():
		if "Cage" in line.text:
			found = true
			break
	assert_true(
		found, "Briefing should mention Resonance Cage",
	)


# --- Scene 7: Leaving Gearhaven ---


func test_departure_lines_not_empty() -> void:
	var lines := IronCoast.compute_departure_lines()
	assert_gt(lines.size(), 0, "Scene 7 should have lines")


func test_departure_includes_ground_rules() -> void:
	var found := false
	for line in IronCoast.compute_departure_lines():
		if "ground rules" in line.text:
			found = true
			break
	assert_true(
		found, "Departure should mention ground rules",
	)


# --- Camp: Operating Systems ---


func test_camp_lines_not_empty() -> void:
	var lines := IronCoast.compute_camp_lines()
	assert_gt(lines.size(), 0, "Camp scene should have lines")


func test_camp_includes_cipher_backstory() -> void:
	var found := false
	for line in IronCoast.compute_camp_lines():
		if line.speaker == "Cipher" and "sixteen" in line.text:
			found = true
			break
	assert_true(
		found, "Camp should include Cipher's backstory",
	)


# --- Cross-scene ---


func test_total_line_count() -> void:
	var total := (
		IronCoast.compute_descent_lines().size()
		+ IronCoast.compute_bar_lines().size()
		+ IronCoast.compute_server_lines().size()
		+ IronCoast.compute_contact_lines().size()
		+ IronCoast.compute_harbor_lines().size()
		+ IronCoast.compute_briefing_lines().size()
		+ IronCoast.compute_departure_lines().size()
		+ IronCoast.compute_camp_lines().size()
	)
	assert_gte(total, 70, "Should have 70+ total lines")


func test_all_speakers_valid() -> void:
	var valid := [
		"Kael", "Lyra", "Iris", "Garrick", "Nyx",
		"Cipher", "Bartender", "Ratchet",
	]
	var all_lines: Array[DialogueLine] = []
	all_lines.append_array(IronCoast.compute_descent_lines())
	all_lines.append_array(IronCoast.compute_bar_lines())
	all_lines.append_array(IronCoast.compute_server_lines())
	all_lines.append_array(IronCoast.compute_contact_lines())
	all_lines.append_array(IronCoast.compute_harbor_lines())
	all_lines.append_array(IronCoast.compute_briefing_lines())
	all_lines.append_array(IronCoast.compute_departure_lines())
	all_lines.append_array(IronCoast.compute_camp_lines())
	for line in all_lines:
		assert_has(valid, line.speaker,
			"Speaker '%s' should be valid" % line.speaker)


func test_flag_constant() -> void:
	assert_eq(
		IronCoast.FLAG_NAME, "cipher_recruited",
		"Flag should be cipher_recruited",
	)
