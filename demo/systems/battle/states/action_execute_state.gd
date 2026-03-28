extends BattleState
## Executes the chosen action with animation.


func enter(context: Dictionary = {}) -> void:
	var battler: BattlerData = context.get("battler")
	var action: String = context.get("action", "attack")
	var target: BattlerData = context.get("target")
	var ability = context.get("ability")
	var item = context.get("item")

	match action:
		"attack":
			await _execute_attack(battler, target)
		"defend":
			_execute_defend(battler)
		"magic":
			await _execute_magic(battler, target, ability)
		"item":
			_execute_item(battler, target, item)
		"enemy_turn":
			await _execute_enemy_turn(battler)

	await get_tree().create_timer(0.3).timeout
	battle_manager._state_machine.transition_to("CheckResult")


func _execute_attack(attacker: BattlerData, target: BattlerData) -> void:
	var damage := max(1, attacker.current_attack - target.get_effective_defense() + randi_range(-2, 2))
	damage = max(1, damage)
	await _play_attack_animation(attacker)
	var actual := target.take_damage(damage)
	_spawn_damage_number(target, actual)
	battle_manager.action_executed.emit(attacker, target, actual)


func _execute_defend(battler: BattlerData) -> void:
	battler.defense_boost = battler.current_defense
	print(battler.character_data.display_name + " defends!")


func _execute_magic(caster: BattlerData, target: BattlerData, ability: Resource) -> void:
	if not ability:
		push_warning("Magic system not yet implemented.")
		return
	var damage: int = ability.power - target.get_effective_defense()
	damage = max(1, damage)
	var actual := target.take_damage(damage)
	caster.current_mp -= ability.mp_cost
	_spawn_damage_number(target, actual)


func _execute_item(user: BattlerData, target: BattlerData, item: ItemData) -> void:
	if not item:
		return
	if item.hp_restore > 0:
		var healed := target.heal(item.hp_restore)
		_spawn_damage_number(target, healed, true)
	InventoryManager.remove_item(item)


func _execute_enemy_turn(battler: BattlerData) -> void:
	var targets := battle_manager.get_alive_party()
	if targets.is_empty():
		return
	if battler.enemy_data:
		var command: Dictionary = AIController.choose_enemy_action(
			battler, battler.enemy_data, targets, battle_manager.get_alive_enemies(),
		)
		var target: BattlerData = command.get("target", targets[0])
		match command.get("action", "attack"):
			"attack":
				await _execute_attack(battler, target)
			"defend":
				_execute_defend(battler)
	else:
		var target: BattlerData = targets[randi() % targets.size()]
		await _execute_attack(battler, target)


func _play_attack_animation(attacker: BattlerData) -> void:
	var sprite := _find_battler_sprite(attacker)
	if not sprite:
		return
	var direction := -1.0 if attacker.is_player_controlled else 1.0
	var original_pos: Vector2 = sprite.position
	var tween := create_tween()
	tween.tween_property(sprite, "position:x", original_pos.x + 30.0 * direction, 0.15)
	tween.tween_interval(0.1)
	tween.tween_property(sprite, "position:x", original_pos.x, 0.15)
	await tween.finished


func _find_battler_sprite(battler: BattlerData) -> Node2D:
	for sprite in get_tree().get_nodes_in_group("battler_sprites"):
		if sprite.battler_data == battler:
			return sprite
	return null


func _spawn_damage_number(target: BattlerData, amount: int, is_heal: bool = false) -> void:
	var sprite_node := _find_battler_sprite(target)
	if not sprite_node:
		return
	var label := Label.new()
	label.text = str(amount)
	label.add_theme_color_override("font_color", Color.GREEN if is_heal else Color.WHITE)
	label.z_index = 100
	sprite_node.add_child(label)
	label.position = Vector2(0, -20)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", -50.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)
