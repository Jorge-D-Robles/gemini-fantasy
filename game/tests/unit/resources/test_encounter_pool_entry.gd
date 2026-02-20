extends GutTest

## Tests for EncounterPoolEntry resource — factory method and defaults.

const Helpers = preload("res://tests/helpers/test_helpers.gd")


func test_create_with_enemies_and_default_weight() -> void:
	var enemy_data := EnemyData.new()
	enemy_data.id = &"test_enemy"
	var enemies: Array[Resource] = [enemy_data]
	var entry := EncounterPoolEntry.create(enemies)
	assert_eq(entry.enemies.size(), 1)
	assert_eq(entry.enemies[0], enemy_data)
	assert_almost_eq(entry.weight, 1.0, 0.001)


func test_create_with_custom_weight() -> void:
	var enemy_data := EnemyData.new()
	var enemies: Array[Resource] = [enemy_data]
	var entry := EncounterPoolEntry.create(enemies, 3.5)
	assert_almost_eq(entry.weight, 3.5, 0.001)


func test_create_with_multiple_enemies() -> void:
	var e1 := EnemyData.new()
	e1.id = &"enemy_a"
	var e2 := EnemyData.new()
	e2.id = &"enemy_b"
	var enemies: Array[Resource] = [e1, e2]
	var entry := EncounterPoolEntry.create(enemies, 2.0)
	assert_eq(entry.enemies.size(), 2)
	assert_eq((entry.enemies[0] as EnemyData).id, &"enemy_a")
	assert_eq((entry.enemies[1] as EnemyData).id, &"enemy_b")


func test_create_returns_new_instance_each_call() -> void:
	var enemies: Array[Resource] = []
	var a := EncounterPoolEntry.create(enemies)
	var b := EncounterPoolEntry.create(enemies)
	assert_ne(a, b)
