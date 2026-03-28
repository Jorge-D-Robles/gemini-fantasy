extends Area2D
## A zone that triggers a scene transition when the player enters.

@export_file("*.tscn") var target_scene: String
@export var target_spawn_point: String = "default"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneManager.change_scene(target_scene, target_spawn_point)
