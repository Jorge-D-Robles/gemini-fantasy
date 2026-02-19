extends GutTest

## Tests for NPC interaction indicator — floating icon above NPC head.

var _npc: Node


func before_each() -> void:
	_npc = load("res://entities/npc/npc.gd").new()
	_npc.name = "TestNPC"
	# NPC needs a Sprite2D and InteractionArea to function
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	_npc.add_child(sprite)
	var area := Area2D.new()
	area.name = "InteractionArea"
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	area.add_child(shape)
	_npc.add_child(area)


func after_each() -> void:
	if _npc and is_instance_valid(_npc):
		if _npc.get_parent():
			remove_child(_npc)
		_npc.free()


func test_default_indicator_type_is_none() -> void:
	assert_eq(_npc.indicator_type, NPC.IndicatorType.NONE)


func test_indicator_none_creates_no_label() -> void:
	add_child(_npc)
	assert_null(_npc._indicator)


func test_indicator_chat_creates_label() -> void:
	_npc.indicator_type = NPC.IndicatorType.CHAT
	add_child(_npc)
	assert_not_null(_npc._indicator)
	assert_eq(_npc._indicator.text, "...")


func test_indicator_quest_shows_exclamation() -> void:
	_npc.indicator_type = NPC.IndicatorType.QUEST
	add_child(_npc)
	assert_not_null(_npc._indicator)
	assert_eq(_npc._indicator.text, "!")


func test_indicator_quest_active_shows_question() -> void:
	_npc.indicator_type = NPC.IndicatorType.QUEST_ACTIVE
	add_child(_npc)
	assert_not_null(_npc._indicator)
	assert_eq(_npc._indicator.text, "?")


func test_indicator_shop_shows_dollar() -> void:
	_npc.indicator_type = NPC.IndicatorType.SHOP
	add_child(_npc)
	assert_not_null(_npc._indicator)
	assert_eq(_npc._indicator.text, "$")


func test_indicator_hidden_initially() -> void:
	_npc.indicator_type = NPC.IndicatorType.CHAT
	add_child(_npc)
	assert_false(_npc._indicator.visible)


func test_indicator_positioned_above_sprite() -> void:
	_npc.indicator_type = NPC.IndicatorType.CHAT
	add_child(_npc)
	assert_lt(_npc._indicator.position.y, 0.0)


func test_indicator_z_index_is_one() -> void:
	_npc.indicator_type = NPC.IndicatorType.CHAT
	add_child(_npc)
	assert_eq(_npc._indicator.z_index, 1)


func test_indicator_tween_starts() -> void:
	_npc.indicator_type = NPC.IndicatorType.QUEST
	add_child(_npc)
	assert_not_null(_npc._indicator_tween)
	assert_true(_npc._indicator_tween.is_running())


func test_indicator_tween_killed_on_exit() -> void:
	_npc.indicator_type = NPC.IndicatorType.QUEST
	add_child(_npc)
	var tween: Tween = _npc._indicator_tween
	remove_child(_npc)
	assert_false(tween.is_running())


func test_indicator_type_changed_after_ready() -> void:
	add_child(_npc)
	assert_null(_npc._indicator)
	_npc.indicator_type = NPC.IndicatorType.SHOP
	assert_not_null(_npc._indicator)
	assert_eq(_npc._indicator.text, "$")


func test_enum_values() -> void:
	assert_eq(NPC.IndicatorType.NONE, 0)
	assert_eq(NPC.IndicatorType.CHAT, 1)
	assert_eq(NPC.IndicatorType.QUEST, 2)
	assert_eq(NPC.IndicatorType.QUEST_ACTIVE, 3)
	assert_eq(NPC.IndicatorType.SHOP, 4)
