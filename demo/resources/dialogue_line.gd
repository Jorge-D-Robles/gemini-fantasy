extends Resource
class_name DialogueLine
## A single line of dialogue with speaker information and optional choices.

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var choices: Array[String] = []
