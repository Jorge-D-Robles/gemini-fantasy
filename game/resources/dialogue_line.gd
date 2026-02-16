class_name DialogueLine
extends Resource

## A single line of dialogue with optional speaker, portrait, and choices.

@export var speaker: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var choices: Array[String] = []


func has_choices() -> bool:
	return not choices.is_empty()


static func create(
	p_speaker: String,
	p_text: String,
	p_portrait: Texture2D = null,
	p_choices: Array[String] = [],
) -> DialogueLine:
	var line := DialogueLine.new()
	line.speaker = p_speaker
	line.text = p_text
	line.portrait = p_portrait
	line.choices = p_choices
	return line
