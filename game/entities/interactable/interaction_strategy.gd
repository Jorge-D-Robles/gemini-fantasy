class_name InteractionStrategy
extends Resource

## Base class for interaction strategies. Subclass this to define
## behavior for different interactable types (sign, chest, door, etc.).


func execute(_owner: Node) -> void:
	push_warning("InteractionStrategy.execute() not overridden.")
