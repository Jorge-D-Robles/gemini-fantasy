extends BattleState
## Party wiped. Show Game Over screen.


func enter(_context: Dictionary = {}) -> void:
	print("--- DEFEAT ---")
	print("The party has fallen...")
	battle_manager.battle_lost.emit()
	await get_tree().create_timer(2.0).timeout
	SceneManager.change_scene("res://ui/game_over/game_over.tscn")
