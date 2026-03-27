# Module 9: The Dialogue System

## What We Have So Far

NPCs in Willowbrook that detect the player and emit interaction signals. But dialogue is just `print()` output. Time to fix that.

## What We're Building This Module

A full dialogue box UI: text appears with a typewriter effect, the speaker's name is displayed, conversations span multiple pages, and the player can make choices during branching dialogue. Players spend more time reading dialogue than doing almost anything else in a JRPG, so getting the textbox right matters.

## UI Fundamentals: Control Nodes

Godot's UI system is built on **Control** nodes, a family of nodes designed specifically for user interfaces. Unlike Node2D (which uses pixel coordinates), Control nodes use **anchors**, **margins**, and **containers** to create responsive layouts.

Key Control nodes we'll use:

| Node | Purpose |
|------|---------|
| `PanelContainer` | A styled rectangle (background for our dialogue box) |
| `MarginContainer` | Adds padding around its child |
| `VBoxContainer` | Stacks children vertically |
| `HBoxContainer` | Stacks children horizontally |
| `Label` | Displays plain text |
| `RichTextLabel` | Displays text with BBCode formatting |
| `TextureRect` | Displays an image |

Control nodes automatically size and position themselves based on their parent container. This means our dialogue box will work correctly regardless of screen resolution.

> **See:** [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html), how Control nodes position themselves.

> **See:** [GUI containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html), automatic layout with VBox, HBox, Grid, and Margin containers.

> **See:** [Control node gallery](https://docs.godotengine.org/en/stable/tutorials/ui/control_node_gallery.html), visual catalog of all Control nodes.

## The DialogueLine Resource

Before building the UI, we need to define the data format for dialogue. We created a basic `NPCData` with `dialogue_lines: Array[String]` in Module 7. Now we'll make a proper dialogue line resource.

Create `res://resources/dialogue_line.gd`:

```gdscript
extends Resource
class_name DialogueLine
## A single line of dialogue with speaker information.

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
```

Now update `NPCData` in `res://resources/npc_data.gd` to use it:

```gdscript
extends Resource
class_name NPCData
## Data for a non-player character in the overworld.

@export var id: String = ""
@export var display_name: String = ""
@export var sprite_frames: SpriteFrames
@export var facing_direction: Vector2 = Vector2.DOWN

@export_group("Dialogue")
@export var dialogue: Array[DialogueLine] = []
```

The `dialogue` array replaces the old `dialogue_lines`. Update each NPC `.tres` file to use the new format:

1. Open the `.tres` file (e.g., `shopkeeper.tres`) in the Inspector.
2. The old `dialogue_lines` field will be gone (replaced by `dialogue`). Click the `dialogue` array.
3. Click **Add Element**. An empty slot appears.
4. Click the empty slot and choose **New DialogueLine**.
5. Expand the new DialogueLine and fill in `speaker_name` (e.g., "Merchant Hilda") and `text` (the dialogue line). Leave `portrait` empty for now.
6. Repeat for each line of dialogue.

> **Tip:** Creating sub-resources inside arrays can feel clunky at first. Each array element needs to be clicked, then "New DialogueLine" selected, then expanded to fill in fields. It's tedious but straightforward.

> **Spiral:** This is the Resource pattern from Module 7 in action. We define a data type (`DialogueLine`), use it in another Resource (`NPCData`), and the editor gives us a clean UI for editing dialogue without touching code.

## Building the Dialogue Box Scene

Create `res://ui/dialogue_box/dialogue_box.tscn`:

### Scene Tree

```
DialogueBox (CanvasLayer, layer = 10)
└── PanelContainer
    └── MarginContainer
        └── VBoxContainer
            ├── SpeakerLabel (Label)
            └── TextLabel (RichTextLabel)
```

### Node Configuration

**DialogueBox (CanvasLayer)**
- Layer: `10` (draws above the game world but below the SceneManager's transition overlay at layer 100)

**PanelContainer**
- Anchors: Bottom-wide (left=0, right=1, bottom=1, top=~0.75)
- This makes the panel span the full width at the bottom of the screen, taking up about 25% of the height
- Layout → **Anchor Preset**: choose "Bottom Wide" from the preset menu

**MarginContainer**
- Under Theme Overrides → Constants, set margins: left=16, right=16, top=12, bottom=12

**SpeakerLabel (Label)**
- Text: "" (empty, filled at runtime)
- Horizontal Alignment: Left
- Add a bold font or increase font size to distinguish the speaker name

**TextLabel (RichTextLabel)**
- BBCode Enabled: `true`
- Fit Content: `true`
- Scroll Active: `false`
- Text: "" (empty, filled at runtime)

The result is a dark panel at the bottom of the screen with a speaker name on top and dialogue text below, the classic JRPG textbox.

## The Typewriter Effect

The typewriter effect reveals text character by character, as if being typed. This is a staple of JRPG dialogue and gives the player time to read along.

We achieve this by tweening `visible_ratio` on the RichTextLabel:

```gdscript
# visible_ratio goes from 0.0 (no text visible) to 1.0 (all text visible)
var tween := create_tween()
tween.tween_property(text_label, "visible_ratio", 1.0, duration)
```

Why `visible_ratio` and not `visible_characters`?

- **`visible_characters`** is an `int`, the number of characters shown. Tweening it produces discrete jumps (0 chars, 1 char, 2 chars). For short lines, this looks choppy.
- **`visible_ratio`** is a `float` from 0.0 to 1.0. Tweening it produces smooth character-by-character reveal at a consistent rate regardless of line length.

> **See:** [RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html), the `visible_ratio` and `visible_characters` properties.

> **See:** [BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html), formatting text with colors, bold, italics, and more.

## The Dialogue Box Script

Create `res://ui/dialogue_box/dialogue_box.gd`:

```gdscript
extends CanvasLayer
## Displays dialogue with a typewriter effect.

signal dialogue_started
signal dialogue_finished
signal line_advanced

@export var characters_per_second: float = 30.0

var _lines: Array[DialogueLine] = []
var _current_line_index: int = 0
var _is_typing: bool = false
var _current_tween: Tween = null

@onready var _panel: PanelContainer = $PanelContainer
@onready var _speaker_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerLabel
@onready var _text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/TextLabel


func _ready() -> void:
    _panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
    if not _panel.visible:
        return

    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
        get_viewport().set_input_as_handled()

        if _is_typing:
            # Skip the typewriter effect: show all text immediately
            _skip_typing()
        else:
            # Advance to the next line
            _advance()


func start_dialogue(lines: Array[DialogueLine]) -> void:
    if lines.is_empty():
        return

    _lines = lines
    _current_line_index = 0
    _panel.visible = true
    dialogue_started.emit()
    _show_current_line()


func _show_current_line() -> void:
    var line: DialogueLine = _lines[_current_line_index]

    _speaker_label.text = line.speaker_name
    _speaker_label.visible = line.speaker_name != ""
    _text_label.text = line.text
    _text_label.visible_ratio = 0.0

    _start_typing()


func _start_typing() -> void:
    _is_typing = true

    # Calculate duration based on text length and speed
    var char_count: int = _text_label.get_total_character_count()
    var duration: float = char_count / characters_per_second

    # Kill any existing tween before creating a new one
    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()

    _current_tween = create_tween()
    _current_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
    _current_tween.finished.connect(_on_typing_finished)


func _skip_typing() -> void:
    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()
    _text_label.visible_ratio = 1.0
    _is_typing = false


func _on_typing_finished() -> void:
    _is_typing = false


func _advance() -> void:
    _current_line_index += 1
    line_advanced.emit()

    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _close() -> void:
    _panel.visible = false
    _lines.clear()
    _current_line_index = 0
    dialogue_finished.emit()
```

### Key Design Points

**Two-press interaction:**
- First press while text is typing: **skip** to show all text immediately.
- Press when text is fully shown: **advance** to the next line or close.

This is the standard JRPG dialogue control. Players who read fast can skip ahead, while slow readers have time.

**Tween lifecycle management:**
```gdscript
if _current_tween and _current_tween.is_valid():
    _current_tween.kill()
```

Before creating a new tween, we kill any existing one. This prevents overlapping tweens if the player advances quickly. `create_tween()` tweens are automatically cleaned up when the creating node is freed, but we might create multiple tweens during a single dialogue sequence.

> **Warning:** A Tween stored in a variable can outlive its creating node if the variable is held elsewhere. In our case, `_current_tween` is a member of the dialogue box itself, so it's cleaned up when the box is freed. But be careful with Tweens passed between objects.

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html), the Tween API, including `kill()`, `is_valid()`, and chaining methods.

## Connecting Dialogue to NPCs

Now we'll wire the dialogue system into the game. Add the dialogue box to the scene.

### Option A: Instance in Each Scene

Add an instance of `dialogue_box.tscn` to each scene that needs dialogue (Willowbrook, Whisperwood, etc.).

### Option B: Make It an Autoload (Better)

Since dialogue can happen anywhere, it's a good candidate for global access. But instead of a full autoload, we can instance it in the SceneManager (which is already an autoload and has a CanvasLayer).

For simplicity, we'll use **Option A** for now: instance the dialogue box in Willowbrook. We can refactor to a global approach later.

Replace the contents of `willowbrook.gd` (the Module 8 version with `print()` dialogue is now obsolete):

```gdscript
extends Node2D
## The town of Willowbrook, Crystal Saga's starting village.

@onready var _dialogue_box: CanvasLayer = $DialogueBox


func _ready() -> void:
    _dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

    for npc in get_tree().get_nodes_in_group("npcs"):
        npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: CharacterBody2D) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("start_interaction"):
        player.start_interaction()

    if npc.npc_data and not npc.npc_data.dialogue.is_empty():
        _dialogue_box.start_dialogue(npc.npc_data.dialogue)


func _on_dialogue_finished() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("end_interaction"):
        player.end_interaction()
```

The flow:
1. Player presses interact near an NPC
2. NPC emits `interacted`
3. `willowbrook.gd` receives the signal
4. Player enters INTERACT state (frozen)
5. Dialogue box starts displaying lines
6. Player presses interact to advance through lines
7. When all lines are shown, `dialogue_finished` emits
8. Player returns to IDLE state

## Choice Dialogue (Branching)

Some dialogue needs player choices: "Yes/No" questions, multiple response options. We'll extend the system to support this.

First, **replace the entire contents of `res://resources/dialogue_line.gd`** with this updated version that adds a `choices` field:

```gdscript
extends Resource
class_name DialogueLine
## A single line of dialogue with speaker information and optional choices.

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var choices: Array[String] = []  # Empty = no choice, just advance
```

When `choices` is non-empty, instead of advancing on press, we show choice buttons.

Add a ChoiceContainer node to the dialogue box scene:

1. Open `dialogue_box.tscn`.
2. Select the **VBoxContainer** (the one containing SpeakerLabel and TextLabel).
3. Add a **VBoxContainer** child to it. Rename it to `ChoiceContainer`.
4. This is where choice buttons will appear dynamically.

Your updated scene tree:

```
DialogueBox (CanvasLayer)
└── PanelContainer
    └── MarginContainer
        └── VBoxContainer
            ├── SpeakerLabel (Label)
            ├── TextLabel (RichTextLabel)
            └── ChoiceContainer (VBoxContainer)
                # Buttons are added dynamically
```

Add the following to `dialogue_box.gd`: a new signal, a new `@onready` variable, and **replace** the existing `_show_current_line()` and `_advance()` methods with these updated versions. Also add the new `_show_choices()` and `_on_choice_pressed()` methods:

```gdscript
signal choice_made(choice_index: int)

@onready var _choice_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ChoiceContainer


func _show_current_line() -> void:
    var line: DialogueLine = _lines[_current_line_index]

    _speaker_label.text = line.speaker_name
    _speaker_label.visible = line.speaker_name != ""
    _text_label.text = line.text
    _text_label.visible_ratio = 0.0

    # Clear old choices
    for child in _choice_container.get_children():
        child.queue_free()
    _choice_container.visible = false

    _start_typing()


func _advance() -> void:
    var current_line: DialogueLine = _lines[_current_line_index]

    # If this line has choices, show them instead of advancing
    if not current_line.choices.is_empty() and _choice_container.get_child_count() == 0:
        _show_choices(current_line.choices)
        return

    _current_line_index += 1
    line_advanced.emit()

    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _show_choices(choices: Array[String]) -> void:
    _choice_container.visible = true

    for i in choices.size():
        var button := Button.new()
        button.text = choices[i]
        button.pressed.connect(_on_choice_pressed.bind(i))
        _choice_container.add_child(button)

    # Focus the first button for keyboard/gamepad navigation
    await get_tree().process_frame
    if _choice_container.get_child_count() > 0:
        _choice_container.get_child(0).grab_focus()


func _on_choice_pressed(index: int) -> void:
    choice_made.emit(index)
    _choice_container.visible = false

    # Clear choices and advance
    for child in _choice_container.get_children():
        child.queue_free()

    _current_line_index += 1
    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()
```

### The Complete `dialogue_box.gd`

After merging the base script with the choice additions, your complete file should look like this:

```gdscript
extends CanvasLayer
## Displays dialogue with a typewriter effect and optional choices.

signal dialogue_started
signal dialogue_finished
signal line_advanced
signal choice_made(choice_index: int)

@export var characters_per_second: float = 30.0

var _lines: Array[DialogueLine] = []
var _current_line_index: int = 0
var _is_typing: bool = false
var _current_tween: Tween = null

@onready var _panel: PanelContainer = $PanelContainer
@onready var _speaker_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerLabel
@onready var _text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/TextLabel
@onready var _choice_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ChoiceContainer


func _ready() -> void:
    _panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
    if not _panel.visible:
        return

    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
        get_viewport().set_input_as_handled()

        if _is_typing:
            _skip_typing()
        else:
            _advance()


func start_dialogue(lines: Array[DialogueLine]) -> void:
    if lines.is_empty():
        return

    _lines = lines
    _current_line_index = 0
    _panel.visible = true
    dialogue_started.emit()
    _show_current_line()


func _show_current_line() -> void:
    var line: DialogueLine = _lines[_current_line_index]

    _speaker_label.text = line.speaker_name
    _speaker_label.visible = line.speaker_name != ""
    _text_label.text = line.text
    _text_label.visible_ratio = 0.0

    # Clear old choices
    for child in _choice_container.get_children():
        child.queue_free()
    _choice_container.visible = false

    _start_typing()


func _start_typing() -> void:
    _is_typing = true

    var char_count: int = _text_label.get_total_character_count()
    var duration: float = char_count / characters_per_second

    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()

    _current_tween = create_tween()
    _current_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
    _current_tween.finished.connect(_on_typing_finished)


func _skip_typing() -> void:
    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()
    _text_label.visible_ratio = 1.0
    _is_typing = false


func _on_typing_finished() -> void:
    _is_typing = false


func _advance() -> void:
    var current_line: DialogueLine = _lines[_current_line_index]

    if not current_line.choices.is_empty() and _choice_container.get_child_count() == 0:
        _show_choices(current_line.choices)
        return

    _current_line_index += 1
    line_advanced.emit()

    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _show_choices(choices: Array[String]) -> void:
    _choice_container.visible = true

    for i in choices.size():
        var button := Button.new()
        button.text = choices[i]
        button.pressed.connect(_on_choice_pressed.bind(i))
        _choice_container.add_child(button)

    await get_tree().process_frame
    if _choice_container.get_child_count() > 0:
        _choice_container.get_child(0).grab_focus()


func _on_choice_pressed(index: int) -> void:
    choice_made.emit(index)
    _choice_container.visible = false

    for child in _choice_container.get_children():
        child.queue_free()

    _current_line_index += 1
    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _close() -> void:
    _panel.visible = false
    _lines.clear()
    _current_line_index = 0
    dialogue_finished.emit()
```

> **Note:** In this basic implementation, choices don't affect what happens next; the dialogue continues linearly. In Module 16 (Quests), we'll connect choices to game flags that change story outcomes.

> **Note:** `grab_focus()` on the first button enables keyboard/gamepad navigation. Players can use up/down arrows to select and Enter/interact to confirm, no mouse needed. This is critical for JRPGs.

> **See:** [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html), how focus works for keyboard/gamepad UI navigation.

## Styling the Dialogue Box

The default PanelContainer looks plain. You can style it with a theme:

1. Select the PanelContainer.
2. In the Inspector, find **Theme Override → Styles → Panel**.
3. Create a **New StyleBoxFlat**.
4. Set:
   - **BG Color:** A dark blue or dark gray (e.g., `Color(0.1, 0.1, 0.2, 0.9)`)
   - **Border Width:** 2px on all sides
   - **Border Color:** White or light blue
   - **Corner Radius:** 4px for slightly rounded corners

This gives you the classic JRPG text box look. You can refine it later with custom fonts and themes.

## Freezing the Player During Dialogue

This is already handled by our state machine (Module 5). When `start_interaction()` is called, the player enters INTERACT state and stops processing input. When `end_interaction()` is called, the player returns to IDLE.

The dialogue box's `_unhandled_input` handles the interact/accept buttons for advancing text. Since the player's INTERACT state doesn't consume input events, the dialogue box can receive them normally.

## What We've Learned

- **Control nodes** (PanelContainer, MarginContainer, VBoxContainer, Label, RichTextLabel) create responsive UI layouts.
- **CanvasLayer** renders UI on top of the game world at a specified layer.
- The **typewriter effect** uses `visible_ratio` (a float, tweened from 0.0 to 1.0) for smooth character reveal.
- **Two-press interaction:** first press skips typing, second press advances to the next line.
- **Choice dialogue** uses dynamically created Buttons with `grab_focus()` for keyboard navigation.
- **`DialogueLine`** is a Resource with speaker name, text, and optional choices, giving you clean data separation.
- **Tween lifecycle:** kill existing tweens before creating new ones. `create_tween()` tweens are auto-cleaned when the node is freed.
- `_unhandled_input()` respects UI focus: the dialogue box gets input events after UI buttons have had their chance.

## What You Should See

When you press F6 (running Willowbrook):
- Walk up to an NPC and press interact
- A dialogue box appears at the bottom of the screen
- The speaker's name is shown above the text
- Text appears character by character (typewriter effect)
- Press interact to skip the typing (text appears instantly)
- Press interact again to advance to the next line
- After the last line, the dialogue box disappears
- The player can move again

To test the choice system, edit one of your NPC `.tres` files (e.g., the innkeeper) and add `["Yes", "No"]` to the `choices` array on the last `DialogueLine`. When that line appears, two buttons should show up instead of auto-advancing. Selecting a choice dismisses the buttons and continues.

## Next Module

We have NPCs who talk. In **Module 10: The Inventory System**, we'll build an inventory the player can open with a menu key, display items in a grid, and use consumable items like potions. This is the first game system that requires both data (Resources from Module 7) and UI (patterns from this module) working together.
