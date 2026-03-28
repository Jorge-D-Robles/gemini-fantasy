extends Resource
class_name NPCData
## Data for a non-player character in the overworld.

@export var id: String = ""
@export var display_name: String = ""
@export var sprite_frames: SpriteFrames
@export var facing_direction: Vector2 = Vector2.DOWN

@export_group("Dialogue")
@export var dialogue: Array[DialogueLine] = []
