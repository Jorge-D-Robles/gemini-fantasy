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


## Builds an array of DialogueLines from alternating speaker/text pairs.
## Warns and ignores the last entry if [param raw_lines] has an odd count.
static func build_from_pairs(
	raw_lines: Array[String],
	source_name: String = "",
) -> Array[DialogueLine]:
	if raw_lines.size() % 2 != 0:
		var label: String = source_name if not source_name.is_empty() else "DialogueLine"
		push_warning(
			"%s: raw_lines has odd count (%d); last entry ignored."
			% [label, raw_lines.size()]
		)
	var result: Array[DialogueLine] = []
	var i := 0
	while i + 1 < raw_lines.size():
		result.append(DialogueLine.create(raw_lines[i], raw_lines[i + 1]))
		i += 2
	return result
