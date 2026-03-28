extends Area2D
## Marks a region where random encounters can happen.

@export var encounters: Array[EncounterData] = []
@export var encounter_rate: float = 0.6

@onready var _encounter_system: Node = $"../../EncounterSystem"


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _encounter_system:
		_encounter_system.enter_zone(encounters, encounter_rate)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and _encounter_system:
		_encounter_system.exit_zone()
