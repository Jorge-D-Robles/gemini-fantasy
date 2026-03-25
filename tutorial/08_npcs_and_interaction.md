# Module 8: NPCs and Interaction

## What We Have So Far

A two-area game world with scene transitions, a data layer with Resource classes for items, characters, and NPCs, and an animated player with a state machine.

## What We're Building This Module

NPCs that stand in Willowbrook, face the player when approached, and respond to an interaction button press. We'll build a reusable NPC scene driven by `NPCData` resources, and create the interaction detection system.

## The Interaction Pattern

Most JRPGs use the same interaction flow:

1. Player walks near an NPC
2. A visual prompt appears (a floating "!" or "A" icon)
3. Player presses the interact button
4. The NPC faces the player
5. Something happens (dialogue starts, shop opens, quest updates)

We need three things to make this work:
- A way to **detect** nearby interactable objects
- A way to **signal** "the player wants to interact"
- A way for each interactable to **respond** differently

## Setting Up the Interact Input Action

First, let's define a custom input action for interaction.

1. Go to **Project → Project Settings → Input Map**.
2. At the top, type `interact` in the "Add New Action" field and click **Add**.
3. Click the **+** button next to the new `interact` action.
4. Press the key you want to use — **Z** is traditional for JRPGs, or use **Enter/Space**.
5. Add a second binding for gamepad: click **+** again, choose **Joypad Button**, and select the **A/Cross** button.

Now `Input.is_action_just_pressed("interact")` works for both keyboard and gamepad.

> **See:** [Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html) — setting up and using custom input actions.

## The NPC Scene

Create a reusable NPC scene that can represent any character — a shopkeeper, an innkeeper, a traveler — by swapping out data.

### Scene Structure

Create a `res://npcs/` folder (this holds reusable entity scenes, separate from the area scenes in `scenes/`). Create `res://npcs/npc.tscn`:

```
NPC (CharacterBody2D)
├── Sprite (AnimatedSprite2D)
├── CollisionShape2D
├── InteractionZone (Area2D)
│   └── InteractionShape (CollisionShape2D)
└── InteractionPrompt (Label)
```

**Why CharacterBody2D?** Even though NPCs don't move, using CharacterBody2D makes them solid — the player collides with them and can't walk through them. StaticBody2D would also work, but CharacterBody2D is more flexible if we later want NPCs to wander.

### Node Configuration

**Sprite (AnimatedSprite2D)** — The NPC's visual. For now, if you don't have NPC sprite sheets, set up single-frame animations using the Godot icon, just like we did for the player fallback in Module 5. Create `idle_down`, `idle_up`, `idle_left`, `idle_right` animations with the icon as the single frame. You can replace these with real NPC sprites later.

**CollisionShape2D** — The NPC's physical body. Same "feet-only" approach as the player.
- Shape: `RectangleShape2D`, small (e.g., 12x8)
- Offset downward to align with the sprite's feet

**InteractionZone (Area2D)** — A larger area around the NPC that detects when the player is nearby.
- Its CollisionShape should be **larger** than the body — a circle with radius ~24px works well.
- This is the "can interact" range.

**InteractionPrompt (Label)** — A text label showing "!" that appears above the NPC when the player is in range. Using a Label instead of a Sprite2D means we don't need any art assets.
- Set **Text** to `!`
- Set **Horizontal Alignment** to `Center`
- Position it above the sprite (e.g., `Vector2(-4, -20)`)
- Set **Visible** to `false` initially
- Optionally increase the font size in Theme Overrides

### The NPC Script

Create `res://npcs/npc.gd`:

```gdscript
extends CharacterBody2D
## A non-player character that can be interacted with.

signal interacted(npc: CharacterBody2D)

@export var npc_data: NPCData

var _player_in_range: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _interaction_prompt: Label = $InteractionPrompt
@onready var _interaction_zone: Area2D = $InteractionZone


func _ready() -> void:
    _interaction_zone.body_entered.connect(_on_player_entered)
    _interaction_zone.body_exited.connect(_on_player_exited)
    _interaction_prompt.visible = false

    if npc_data:
        _apply_npc_data()


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range:
        return

    if event.is_action_pressed("interact"):
        _face_player()
        get_viewport().set_input_as_handled()
        interacted.emit(self)


func _apply_npc_data() -> void:
    if npc_data.sprite_frames:
        _sprite.sprite_frames = npc_data.sprite_frames

    # Set initial facing direction
    var dir_name := _direction_to_string(npc_data.facing_direction)
    var idle_anim := "idle_" + dir_name
    if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
        _sprite.play(idle_anim)


func _face_player() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if not player:
        return

    var direction: Vector2 = (player.global_position - global_position).normalized()
    var dir_name := _direction_to_string(direction)
    var idle_anim := "idle_" + dir_name
    if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
        _sprite.play(idle_anim)


func _direction_to_string(direction: Vector2) -> String:
    if abs(direction.x) > abs(direction.y):
        return "right" if direction.x > 0 else "left"
    else:
        return "down" if direction.y >= 0 else "up"


func _on_player_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _interaction_prompt.visible = true


func _on_player_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _interaction_prompt.visible = false
```

Let's unpack the key design decisions:

### `_unhandled_input()` vs `_input()` vs `_process()`

We use **`_unhandled_input()`** instead of checking input in `_process()`. There are three input callbacks:

| Callback | When It Runs |
|----------|-------------|
| `_input(event)` | Every input event, before anything else processes it |
| `_unhandled_input(event)` | Only if no UI element or other node has consumed the event |
| `_process()` + `Input.is_action_pressed()` | Every frame, checks current input state |

`_unhandled_input()` is ideal for game-world interactions because:
- It doesn't fire when a UI menu is consuming input
- We can call `get_viewport().set_input_as_handled()` to prevent other nodes from also responding to the same press
- It's event-driven (fires once on press), not polled (checked every frame)

### The `interacted` Signal

The NPC emits `interacted(self)` when the player presses interact. It doesn't know or care what happens next — dialogue, a shop, a quest update. That's the responsibility of whatever system connects to this signal.

This is the **separation of concerns** principle. The NPC knows about proximity detection and facing. The dialogue system knows about displaying text. They communicate through signals.

### `@export var npc_data: NPCData`

Each NPC instance in the editor gets an `NPCData` resource assigned through the Inspector. Different data = different NPC. Same scene, different behavior.

## Placing NPCs in Willowbrook

Open `willowbrook.tscn` and instance the NPC scene three times:

1. Drag `npc.tscn` into the scene tree (or use Instance Child Scene).
2. Rename each instance: `Shopkeeper`, `Innkeeper`, `Traveler`.
3. Position them in appropriate spots: shopkeeper near a market stall, innkeeper by a house, traveler on the path.

**Important:** Add each NPC instance to the `npcs` group (select the NPC → **Node** tab → **Groups** → type `npcs` → click **Add**). The scene script below uses this group to find all NPCs.

For each NPC, create an NPCData `.tres` file in `res://data/npcs/` (create the folder first). Follow the same Inspector workflow from Module 7: right-click the folder → **New Resource** → search for `NPCData` → **Create**. Assign each to the corresponding NPC's `npc_data` export in the Inspector.

**`res://data/npcs/shopkeeper.tres`:**
- id: "shopkeeper"
- display_name: "Merchant Hilda"
- facing_direction: Vector2.DOWN
- dialogue_lines: ["Welcome to my shop!", "I have potions and gear for sale.", "Be careful in those woods."]

**`res://data/npcs/innkeeper.tres`:**
- id: "innkeeper"
- display_name: "Old Brennan"
- facing_direction: Vector2.DOWN
- dialogue_lines: ["Need a rest? 10 gold for a night.", "You look like you've seen some trouble."]

**`res://data/npcs/traveler.tres`:**
- id: "traveler"
- display_name: "Wandering Fynn"
- facing_direction: Vector2.LEFT
- dialogue_lines: ["I lost something precious in the Whisperwood...", "A pendant, silver with a blue stone.", "If you find it, I'd be forever grateful."]

> **JRPG Pattern:** Notice how the traveler's dialogue sets up a side quest. We're not implementing the quest system yet (that's Module 16), but the dialogue seeds the idea in the player's mind. Classic JRPGs do this constantly — NPCs hint at things that become important later.

### Using the Player's INTERACT State

When the player interacts with an NPC, we should transition the player to the INTERACT state (Module 5). For now, let's connect this simply in the Willowbrook scene script.

Create `res://scenes/willowbrook/willowbrook.gd` and attach it to the root `Willowbrook` node (if you already have a script attached from a previous module, replace its contents):

```gdscript
extends Node2D
## The town of Willowbrook — Crystal Saga's starting village.


func _ready() -> void:
    # Connect NPC interaction signals
    for npc in get_tree().get_nodes_in_group("npcs"):
        npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: CharacterBody2D) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("start_interaction"):
        player.start_interaction()

    # For now, just print the dialogue. Module 9 will add the real dialogue UI.
    if npc.npc_data:
        for line in npc.npc_data.dialogue_lines:
            print(npc.npc_data.display_name + ": " + line)

    # End interaction after a short delay (placeholder)
    await get_tree().create_timer(0.5).timeout
    if player and player.has_method("end_interaction"):
        player.end_interaction()
```

This is a temporary placeholder — in Module 9, we'll replace the `print()` calls with a proper dialogue box. But it demonstrates the flow: NPC detects interaction → emits signal → scene script handles it → player enters INTERACT state → interaction completes → player returns to IDLE.

## Interaction Detection: RayCast2D Alternative

We used Area2D on the NPC for detection. There's an alternative approach: a **RayCast2D** on the player that points in the facing direction.

```
Player (CharacterBody2D)
├── Sprite
├── CollisionShape2D
├── Camera2D
└── InteractRay (RayCast2D)   ← points forward, detects NPCs
```

The RayCast approach:
- Points in the player's facing direction
- Checks if it hits an interactable
- The interact button only works if the ray is hitting something

**Pros:** More precise — you can only interact with what you're facing. No "interacting with the NPC behind you" situations.
**Cons:** More setup, requires updating the ray direction when the player turns.

Both approaches are valid. We're using the Area2D approach because it's simpler to set up and understand. If you want to switch later, the NPC's `interacted` signal works the same either way.

> **See:** [RayCast2D](https://docs.godotengine.org/en/stable/classes/class_raycast2d.html) — for the ray-based detection approach.

## What We've Learned

- **Custom input actions** (`interact`) work with both keyboard and gamepad. Define them in Project Settings → Input Map.
- The **interaction pattern**: Area2D detection zone → prompt appears → player presses interact → NPC responds via signal.
- **`_unhandled_input()`** is the right callback for game-world interactions — it respects UI focus and can mark events as handled.
- **`get_viewport().set_input_as_handled()`** prevents multiple nodes from responding to the same input.
- **`@export var npc_data: NPCData`** lets each NPC instance use different data without a separate script.
- The `interacted` signal keeps NPCs decoupled from dialogue, shops, and quests.
- **Scene scripts** (like `willowbrook.gd`) wire NPCs to game systems. The NPC doesn't know about dialogue; the scene connects them.
- The player's **INTERACT state** (Module 5) freezes movement during interactions.

## What You Should See

When you press F6 (running Willowbrook):
- Three NPCs stand in town
- Walking near an NPC shows an interaction prompt icon
- Walking away hides the prompt
- Pressing the interact key near an NPC:
  - The NPC faces the player
  - Dialogue lines print to the Output panel
  - The player stops moving for a moment
  - The player resumes normal movement after the interaction

## Next Module

We can interact with NPCs, but the dialogue is just `print()` output. In **Module 9: The Dialogue System**, we'll build a proper dialogue box UI with a typewriter text effect, speaker names, multi-page conversations, and choice/branching dialogue. The NPCs will finally talk like real JRPG characters.
