class_name EventFlags
extends Node

## Global event flag tracker. Prevents story events from replaying.
## Registered as an autoload so all scenes can check/set flags.

var _flags: Dictionary = {}


func set_flag(flag_name: String) -> void:
	_flags[flag_name] = true


func has_flag(flag_name: String) -> bool:
	return _flags.has(flag_name)


func clear_flag(flag_name: String) -> void:
	_flags.erase(flag_name)


func get_all_flags() -> Dictionary:
	return _flags.duplicate()


func load_flags(data: Dictionary) -> void:
	_flags = data.duplicate()
