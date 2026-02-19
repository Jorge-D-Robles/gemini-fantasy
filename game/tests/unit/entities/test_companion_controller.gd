extends GutTest

## Tests for CompanionController static logic.

const CC = preload("res://entities/companion/companion_controller.gd")
const Helpers = preload("res://tests/helpers/test_helpers.gd")


func _make_char_data(id: StringName) -> Resource:
	var data: Resource = Helpers.make_character_data({"id": id})
	return data


func test_compute_followers_needed_empty_party() -> void:
	var party: Array[Resource] = []
	var result: Array[Resource] = CC.compute_followers_needed(party)
	assert_eq(result.size(), 0)


func test_compute_followers_needed_solo_kael() -> void:
	var party: Array[Resource] = [_make_char_data(&"kael")]
	var result: Array[Resource] = CC.compute_followers_needed(party)
	assert_eq(result.size(), 0, "Solo Kael needs no followers")


func test_compute_followers_needed_skips_kael_by_id() -> void:
	var party: Array[Resource] = [
		_make_char_data(&"kael"),
		_make_char_data(&"iris"),
		_make_char_data(&"garrick"),
	]
	var result: Array[Resource] = CC.compute_followers_needed(party)
	assert_eq(result.size(), 2, "Should have 2 followers")
	assert_eq(result[0].id, &"iris")
	assert_eq(result[1].id, &"garrick")


func test_compute_followers_needed_kael_not_first() -> void:
	var party: Array[Resource] = [
		_make_char_data(&"iris"),
		_make_char_data(&"kael"),
		_make_char_data(&"garrick"),
	]
	var result: Array[Resource] = CC.compute_followers_needed(party)
	assert_eq(result.size(), 2, "Should still skip Kael by ID")
	assert_eq(result[0].id, &"iris")
	assert_eq(result[1].id, &"garrick")


func test_compute_history_index_normal() -> void:
	# follower 0 with history=100, offset=15 -> 100-1-(0+1)*15 = 84
	var idx: int = CC.compute_history_index(0, 100, 15)
	assert_eq(idx, 84)


func test_compute_history_index_second_follower() -> void:
	# follower 1 with history=100, offset=15 -> 100-1-(1+1)*15 = 69
	var idx: int = CC.compute_history_index(1, 100, 15)
	assert_eq(idx, 69)


func test_compute_history_index_short_history_clamps() -> void:
	# follower 0 with history=5, offset=15 -> max(0, 5-1-15) = 0
	var idx: int = CC.compute_history_index(0, 5, 15)
	assert_eq(idx, 0, "Should clamp to 0 when history is short")


func test_compute_history_index_exact_boundary() -> void:
	# follower 0 with history=16, offset=15 -> 16-1-15 = 0
	var idx: int = CC.compute_history_index(0, 16, 15)
	assert_eq(idx, 0)


func test_compute_history_index_empty_history() -> void:
	var idx: int = CC.compute_history_index(0, 0, 15)
	assert_eq(idx, 0, "Empty history should return 0")
