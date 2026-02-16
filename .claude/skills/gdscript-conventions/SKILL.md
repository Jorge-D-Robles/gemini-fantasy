---
name: gdscript-conventions
description: GDScript coding conventions and patterns reference for this project. Loaded automatically when writing GDScript to ensure consistent code style.
user-invocable: false
---

# GDScript Conventions for Gemini Fantasy

This project follows the official Godot GDScript style guide. These conventions must be applied to all code written for this project.

## Static Typing (mandatory)

Every variable, parameter, and return type must be explicitly typed:

```gdscript
# Variables
var health: int = 100
var speed: float = 200.0
var direction := Vector2.ZERO  # := only when type is obvious
var items: Array[Item] = []

# Functions
func take_damage(amount: int) -> void:
    health -= amount

func get_direction() -> Vector2:
    return direction

# Onready (explicit type required)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
```

## Script Declaration Order

```gdscript
@tool                           # 01. annotations
class_name MyClass              # 02. class name
extends CharacterBody2D         # 03. extends
## Brief description.           # 04. doc comment
##
## Extended description.


signal died                     # 05. signals
signal health_changed(new_health: int)


enum State {                    # 06. enums
    IDLE,
    WALKING,
    ATTACKING,
}


const MAX_HEALTH: int = 100     # 07. constants


@export var speed: float = 200.0        # 09. exports
@export var attack_power: int = 10


var health: int = MAX_HEALTH            # 10. regular vars
var _current_state: State = State.IDLE  # private with _


@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D  # 11. onready


func _ready() -> void:                 # 12. virtual methods
    pass


func _physics_process(delta: float) -> void:
    pass


func take_damage(amount: int) -> void:  # 13. public methods
    health -= amount
    health_changed.emit(health)
    if health <= 0:
        died.emit()


func _update_animation() -> void:       # 14. private methods
    pass
```

## Naming

| What | Convention | Example |
|------|-----------|---------|
| Files | snake_case | `player_character.gd` |
| Classes | PascalCase | `class_name PlayerCharacter` |
| Functions | snake_case | `func get_attack_power():` |
| Variables | snake_case | `var current_target` |
| Private | underscore prefix | `var _internal`, `func _helper():` |
| Signals | past tense | `signal door_opened` |
| Constants | CONSTANT_CASE | `const MAX_SPEED = 200` |
| Enums | PascalCase name, CONSTANT_CASE members | `enum Element { FIRE, WATER }` |

## Formatting

- **Tabs** for indentation
- **Two blank lines** between functions
- Lines under **100 chars** (prefer 80)
- **Trailing commas** in multiline collections
- **Double quotes** for strings
- `and`/`or`/`not` (not `&&`/`||`/`!`)
- No unnecessary parentheses in conditions
- Spaces around operators: `x = 5`, not `x=5`

## Signal Patterns

```gdscript
# Declaring signals (past tense, descriptive params)
signal health_changed(new_health: int)
signal item_collected(item: Item)
signal battle_ended(victory: bool)

# Connecting in _ready
func _ready() -> void:
    health_changed.connect(_on_health_changed)
    $InteractionZone.body_entered.connect(_on_body_entered)

# Emitting
func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)

# Handler naming: _on_<source>_<signal_name>
func _on_health_changed(new_health: int) -> void:
    pass

func _on_body_entered(body: Node2D) -> void:
    pass
```

## Node References

```gdscript
# GOOD: Cached @onready references
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

# BAD: Fetching every frame
func _process(delta: float) -> void:
    get_node("AnimatedSprite2D").play("idle")  # Don't do this
```

## Resource Patterns

```gdscript
# Custom resource class
class_name Item
extends Resource

@export var name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var value: int = 0

# Using resources
@export var weapon: Item
var inventory: Array[Item] = []

# Loading resources
const POTION: Item = preload("res://data/items/potion.tres")
```
