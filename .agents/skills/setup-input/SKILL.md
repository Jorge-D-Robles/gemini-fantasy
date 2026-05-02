---
name: setup-input
description: Configure input actions for the game. Add new input actions to project.godot and create the corresponding input handling code. Use when adding player controls, menu navigation, or interaction inputs.
argument-hint: <action-name-or-description> [key-bindings...]
disable-model-invocation: true
---

# Set Up Input Actions

Configure input actions for: **$ARGUMENTS**

## Step 1 — Research (MANDATORY — do not skip)

**You MUST complete ALL of these before writing any code:**

1. **Call the `godot-docs` subagent** for input classes:
   ```
   Task(subagent_type="godot-docs", prompt="Look up Input, InputEvent, and InputMap. I need properties, methods, and tutorials for InputEvent handling, input examples, and gamepad/controller support.")
   ```
2. **Read the node lifecycle best practices** (input callbacks have specific ordering):
   ```
   Read("docs/best-practices/05-node-lifecycle.md")
   ```

## Step 2 — Define Input Actions

Standard JRPG input actions:

### Movement
| Action | Keyboard | Gamepad | Description |
|--------|----------|---------|-------------|
| `move_up` | W, Up | Left Stick Up, D-Pad Up | Move character up |
| `move_down` | S, Down | Left Stick Down, D-Pad Down | Move character down |
| `move_left` | A, Left | Left Stick Left, D-Pad Left | Move character left |
| `move_right` | D, Right | Left Stick Right, D-Pad Right | Move character right |

### Interaction
| Action | Keyboard | Gamepad | Description |
|--------|----------|---------|-------------|
| `interact` | E, Enter | A / Cross | Talk to NPC, pick up item, confirm |
| `cancel` | Escape, Backspace | B / Circle | Cancel, close menu, go back |
| `menu` | Tab, M | Start | Open/close pause menu |
| `run` | Shift | X / Square (hold) | Sprint/run |

### Combat
| Action | Keyboard | Gamepad | Description |
|--------|----------|---------|-------------|
| `attack` | Space, Z | A / Cross | Basic attack in combat |
| `defend` | X | Y / Triangle | Defend in combat |
| `skill_menu` | C | RB / R1 | Open skill selection |
| `item_menu` | V | LB / L1 | Open item selection |
| `flee` | F | Select / Back | Attempt to flee |

### UI Navigation (built-in Godot actions)
- `ui_accept` — Already mapped to Enter, Space, Gamepad A
- `ui_cancel` — Already mapped to Escape, Gamepad B
- `ui_up/down/left/right` — Already mapped to arrows, gamepad d-pad

## Step 3 — Modify project.godot

Read the current `game/project.godot` file and add input actions to the `[input]` section.

### Input Action Format in project.godot

```ini
[input]

move_up={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194320,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
```

**Important**: The input action format in project.godot is very verbose. It is easier and more reliable to instruct the user to add input actions via the Godot editor: **Project > Project Settings > Input Map**. Only modify project.godot directly if you are confident in the format.

## Step 4 — Create Input Handling Code

### Movement Input Pattern

```gdscript
func _physics_process(delta: float) -> void:
    var input_dir := Input.get_vector(
            "move_left", "move_right",
            "move_up", "move_down",
    )
    velocity = input_dir * speed
    move_and_slide()
```

### Action Input Pattern

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        _try_interact()
    elif event.is_action_pressed("menu"):
        _toggle_menu()
    elif event.is_action_pressed("cancel"):
        _handle_cancel()
```

### Input State Checking

```gdscript
# In _process or _physics_process
if Input.is_action_pressed("run"):
    speed = RUN_SPEED
else:
    speed = WALK_SPEED

# Just pressed (single frame)
if Input.is_action_just_pressed("attack"):
    _start_attack()
```

## Step 5 — Report

After setup, report:
1. Input actions added or recommended
2. Code patterns created
3. **Editor tasks** — which actions the user needs to add via Project Settings > Input Map (with specific key/button bindings)
4. How existing scripts should reference these actions
