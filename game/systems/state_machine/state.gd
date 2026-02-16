class_name State
extends Node

## Base class for state machine states. Override enter/exit/process methods.

var state_machine: StateMachine


func enter() -> void:
	pass


func exit() -> void:
	pass


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass
