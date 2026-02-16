class_name UILayer
extends Node

## Global UI autoload. Holds HUD, DialogueBox, and PauseMenu as children
## so they persist across scene changes and don't need to be added to
## every level scene manually.

@onready var hud := $HUD
@onready var dialogue_box := $DialogueBox
@onready var pause_menu := $PauseMenu
