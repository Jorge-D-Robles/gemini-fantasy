class_name DoorStrategy
extends InteractionStrategy

## Transitions to another scene at an optional spawn point.

@export_file("*.tscn") var target_scene: String = ""
@export var spawn_point: String = ""


func execute(_owner: Node) -> void:
	if target_scene.is_empty():
		return
	GameManager.change_scene(target_scene, GameManager.FADE_DURATION, spawn_point)
