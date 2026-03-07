# Chapter 7 — NPCs and Dialogue

A JRPG world without people to talk to is just a walking simulator. NPCs give the world its personality — they deliver lore, advance quests, sell items, and make towns feel alive. Behind every conversation is a system: data flows from an NPC entity through a manager to a UI overlay, then back through input handling to advance or branch.

In Angular terms, you are about to build a service that manages a modal dialog queue, a component that renders it with animation, and entities that trigger it. The data is the `DialogueLine` Resource from the previous chapter. This chapter wires it all together.

## What We Are Building

By the end of this chapter you will have:

- A **DialogueManager** autoload that queues and steps through dialogue lines
- A **DialogueBox** UI with typewriter text reveal, portrait display, and branching choices
- An **NPC** entity (StaticBody2D) with an `interact()` method
- Player interaction via **RayCast2D** detection and duck typing
- NPC indicator icons (!, ?, $) with floating animation
- State integration — pushing DIALOGUE state to freeze the player during conversations

## The Engineering Parallel

Think of the dialogue system as three layers, each mapped to something you know:

| Layer | Game | Your World |
|-------|------|------------|
| **Data** | `DialogueLine` Resource | TypeScript interface / DTO |
| **Service** | `DialogueManager` autoload | Angular service managing a modal queue |
| **View** | `DialogueBox` CanvasLayer | Angular component subscribed to the service's Observable stream |

The NPC does not know the DialogueBox exists. The DialogueBox does not know NPCs exist. They communicate through the DialogueManager's signals — exactly like an event bus or Observable pattern. This decoupling means you can trigger dialogue from NPCs, treasure chests, cutscenes, or debug commands, and the same UI handles all of them.

## DialogueManager: The Queue Service

The DialogueManager is a global autoload — a singleton Node that lives for the entire game session. It holds an array of `DialogueLine` objects, tracks the current position, and emits signals that the UI listens to.

```gdscript
# dialogue_manager.gd — registered as autoload "DialogueManager"
extends Node

## Manages dialogue flow globally. Emits signals consumed by the DialogueBox UI.

signal dialogue_started
signal dialogue_ended
signal line_displayed(speaker: String, text: String, portrait: Texture2D)
signal choice_presented(choices: Array[String])
signal choice_selected(index: int)

var _queue: Array[DialogueLine] = []
var _current_index: int = -1
var _is_active: bool = false
var _waiting_for_advance: bool = false
var _waiting_for_choice: bool = false


func start_dialogue(lines: Array[DialogueLine]) -> bool:
	if _is_active:
		push_warning("DialogueManager: dialogue already active.")
		return false
	_queue = lines
	_current_index = -1
	_is_active = true
	_waiting_for_advance = false
	_waiting_for_choice = false

	GameManager.push_state(GameManager.GameState.DIALOGUE)
	dialogue_started.emit()
	advance()
	return true


func advance() -> void:
	if not _is_active:
		return
	if _waiting_for_choice:
		return

	_current_index += 1
	if _current_index >= _queue.size():
		_end_dialogue()
		return

	var line := _queue[_current_index]

	if line.has_choices():
		_waiting_for_choice = true
		line_displayed.emit(line.speaker, line.text, line.portrait)
		choice_presented.emit(line.choices)
	else:
		_waiting_for_advance = true
		line_displayed.emit(line.speaker, line.text, line.portrait)


func select_choice(index: int) -> void:
	if not _waiting_for_choice:
		return
	if _current_index < 0 or _current_index >= _queue.size():
		return
	var line := _queue[_current_index]
	if index < 0 or index >= line.choices.size():
		push_warning("DialogueManager: choice index %d out of range." % index)
		return
	_waiting_for_choice = false
	choice_selected.emit(index)
	advance()


func on_line_display_complete() -> void:
	_waiting_for_advance = true


func is_active() -> bool:
	return _is_active


func _end_dialogue() -> void:
	_is_active = false
	_queue.clear()
	_current_index = -1
	_waiting_for_advance = false
	_waiting_for_choice = false
	GameManager.pop_state()
	dialogue_ended.emit()
```

### The Flow

The dialogue lifecycle has five states:

1. **Idle** — `_is_active` is false, no dialogue running
2. **Started** — `start_dialogue()` called, first line emitted
3. **Displaying** — UI is typing out text (typewriter effect in progress)
4. **Waiting** — text fully displayed, waiting for player input to advance
5. **Choice** — choices presented, waiting for player to select one

The state transitions are driven by method calls:

```
start_dialogue() → dialogue_started signal → advance() → line_displayed signal
                                                            ↓
                                              UI typewriter finishes
                                                            ↓
                                              on_line_display_complete()
                                                            ↓
                                              Player presses interact
                                                            ↓
                                              advance() → next line or _end_dialogue()
```

For choice lines, the flow forks:

```
advance() → line_displayed + choice_presented
                                ↓
                    Player selects choice button
                                ↓
                    select_choice(index) → choice_selected signal → advance()
```

### Why push_state/pop_state?

```gdscript
GameManager.push_state(GameManager.GameState.DIALOGUE)
```

When dialogue starts, the GameManager's state changes from OVERWORLD to DIALOGUE. The player entity listens to state changes and freezes movement when the state is not OVERWORLD. This prevents the player from walking away mid-conversation.

When dialogue ends, `pop_state()` restores the previous state. Using a stack (push/pop) rather than a direct set means dialogue can interrupt other states cleanly. If dialogue starts during a cutscene, popping returns to CUTSCENE, not OVERWORLD.

### Why Return bool from start_dialogue?

```gdscript
func start_dialogue(lines: Array[DialogueLine]) -> bool:
	if _is_active:
		push_warning("DialogueManager: dialogue already active.")
		return false
```

If something tries to start dialogue while another conversation is already running, the call fails gracefully. The caller (an NPC, a chest, a cutscene) can check the return value and handle the rejection:

```gdscript
var started := DialogueManager.start_dialogue(lines)
if not started:
	# Dialogue was already active — skip this interaction
	return
```

This prevents stacked or overlapping conversations, which would corrupt the queue state.

## DialogueBox: The UI Layer

The DialogueBox is a CanvasLayer that renders dialogue text, portraits, and choices. It connects to DialogueManager's signals in `_ready()` and handles all visual presentation:

```gdscript
# dialogue_box.gd
extends CanvasLayer

## Enhanced dialogue box with typewriter, portraits, choices,
## and slide animation. Responds to DialogueManager signals.

signal dialogue_line_finished
signal dialogue_complete

const CHARS_PER_SECOND: float = 30.0
const SLIDE_DURATION: float = 0.2

var _is_typing: bool = false
var _current_tween: Tween = null
var _slide_tween: Tween = null
var _choice_buttons: Array[Button] = []

@onready var _panel: PanelContainer = $Panel
@onready var _portrait: TextureRect = %Portrait
@onready var _speaker_name: Label = %SpeakerName
@onready var _dialogue_text: RichTextLabel = %DialogueText
@onready var _advance_indicator: Label = %AdvanceIndicator
@onready var _choices_container: VBoxContainer = %ChoicesContainer


func _ready() -> void:
	_panel.visible = false
	_advance_indicator.visible = false
	_choices_container.visible = false

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.line_displayed.connect(_on_line_displayed)
	DialogueManager.choice_presented.connect(_on_choice_presented)
```

### The Typewriter Effect

The key technique is animating `RichTextLabel.visible_ratio` from 0.0 to 1.0 using a Tween:

```gdscript
func _on_line_displayed(
	speaker: String,
	text: String,
	portrait_texture: Texture2D,
) -> void:
	_speaker_name.text = speaker
	_dialogue_text.text = text
	_dialogue_text.visible_ratio = 0.0
	_advance_indicator.visible = false
	_choices_container.visible = false

	if portrait_texture:
		_portrait.texture = portrait_texture
		_portrait.visible = true
	else:
		_portrait.visible = false

	_start_typewriter(text)


func _start_typewriter(text: String) -> void:
	_is_typing = true
	_stop_tween()

	var duration := text.length() / CHARS_PER_SECOND
	_current_tween = create_tween()
	_current_tween.tween_property(
		_dialogue_text, "visible_ratio", 1.0, duration
	)
	_current_tween.tween_callback(_on_typing_finished)
```

`visible_ratio` is a property on `RichTextLabel` (not `Label` — this is important). It controls what fraction of the text is visible, from 0.0 (nothing) to 1.0 (everything). By tweening this property, characters appear one at a time, creating the classic JRPG typewriter effect.

The duration scales with text length. A 30-character line takes 1 second at 30 characters per second. A 90-character line takes 3 seconds. This ensures consistent reading speed regardless of line length.

**Why RichTextLabel instead of Label?** `Label` does not have `visible_ratio`. It shows all text immediately. `RichTextLabel` adds text manipulation features including `visible_ratio` for partial text display, BBCode formatting support, and `visible_characters` for integer-based control. For a dialogue system, you need `RichTextLabel`.

### Skip and Advance

Players should be able to skip the typewriter animation or advance to the next line:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if _choices_container.visible:
		return

	if event.is_action_pressed("interact"):
		if _is_typing:
			_skip_typing()
		else:
			DialogueManager.advance()
		get_viewport().set_input_as_handled()


func _skip_typing() -> void:
	_stop_tween()
	_dialogue_text.visible_ratio = 1.0
	_on_typing_finished()


func _on_typing_finished() -> void:
	_is_typing = false
	_advance_indicator.visible = true
	DialogueManager.on_line_display_complete()
	dialogue_line_finished.emit()
```

The interact button does double duty: if text is still typing, it skips to the end. If text is fully displayed, it advances to the next line. This is the standard JRPG convention — press once to skip animation, press again to continue.

`get_viewport().set_input_as_handled()` prevents the input from propagating further. Without this, the interact button might also trigger whatever the player was facing, causing the same NPC to start a new dialogue immediately.

### Slide Animation

The dialogue panel slides in from the bottom when dialogue starts and slides out when it ends:

```gdscript
func _on_dialogue_started() -> void:
	if _slide_tween and _slide_tween.is_valid():
		_slide_tween.kill()
	_panel.visible = true
	_panel.position.y = _panel.size.y
	_slide_tween = create_tween()
	_slide_tween.tween_property(_panel, "position:y", 0.0, SLIDE_DURATION)


func _on_dialogue_ended() -> void:
	_stop_tween()
	if _slide_tween and _slide_tween.is_valid():
		_slide_tween.kill()
	_slide_tween = create_tween()
	_slide_tween.tween_property(
		_panel, "position:y", _panel.size.y, SLIDE_DURATION
	)
	_slide_tween.tween_callback(func() -> void: _panel.visible = false)
	dialogue_complete.emit()
```

The pattern: move the panel to its hidden position (`position.y = panel height`, off-screen below), then tween to 0 (on-screen). On exit, reverse the tween and hide when complete.

Always kill existing tweens before starting new ones. If the player rapidly triggers dialogue start/end, multiple competing tweens would fight over the panel's position.

### Branching Choices

When a `DialogueLine` has choices, the manager emits `choice_presented`. The DialogueBox creates buttons dynamically:

```gdscript
func _on_choice_presented(choices: Array[String]) -> void:
	_clear_choices()
	_choices_container.visible = true

	for i in choices.size():
		var btn := Button.new()
		btn.text = choices[i]
		btn.pressed.connect(_on_choice_selected.bind(i))
		_choices_container.add_child(btn)
		_choice_buttons.append(btn)

	if not _choice_buttons.is_empty():
		_choice_buttons[0].grab_focus()


func _on_choice_selected(index: int) -> void:
	_choices_container.visible = false
	_clear_choices()
	DialogueManager.select_choice(index)


func _clear_choices() -> void:
	for btn in _choice_buttons:
		btn.queue_free()
	_choice_buttons.clear()
```

Buttons are created at runtime, not pre-placed in the scene. This handles any number of choices dynamically. Each button's `pressed` signal is connected to a callback with `bind(i)` — this captures the choice index so the handler knows which option was selected.

`grab_focus()` on the first button ensures keyboard/gamepad navigation works immediately. Without it, the player would have to click or tab to a button before using the D-pad.

### Tween Cleanup

Tweens must be killed when the node exits the scene tree, otherwise they fire callbacks on freed objects:

```gdscript
func _exit_tree() -> void:
	if _slide_tween and _slide_tween.is_valid():
		_slide_tween.kill()
	_stop_tween()


func _stop_tween() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_current_tween = null
```

This is the Godot equivalent of unsubscribing from an Observable in `ngOnDestroy()`. Failure to clean up tweens causes "attempting to call on a freed object" errors — one of the most common Godot bugs.

## The DialogueBox Scene Tree

The DialogueBox is a `.tscn` scene with this node hierarchy:

```
DialogueBox (CanvasLayer) — layer 15, above HUD
  Panel (PanelContainer)
    MarginContainer
      HBoxContainer
        Portrait (TextureRect) — unique name %Portrait
        VBoxContainer
          SpeakerName (Label) — unique name %SpeakerName
          DialogueText (RichTextLabel) — unique name %DialogueText
          AdvanceIndicator (Label) — unique name %AdvanceIndicator
      ChoicesContainer (VBoxContainer) — unique name %ChoicesContainer
```

**CanvasLayer** with layer 15 ensures the dialogue box renders above the game world and above the HUD (layer 10), but below the pause menu (layer 20). This layering prevents the game world from obscuring text.

**Unique names** (`%Portrait`, `%SpeakerName`, etc.) are accessed with the `%` prefix in `@onready` vars. This decouples the script from the exact node path — you can reorganize the scene tree without breaking references.

The DialogueBox is a permanent child of the `UILayer` autoload. It is instantiated once at game start and persists across scene changes. It shows and hides itself in response to DialogueManager signals, never creating or destroying instances.

## The NPC Entity

An NPC is a StaticBody2D with collision, a sprite, and an interaction area. When the player's raycast hits the NPC's collision shape, the player calls `interact()`:

```gdscript
# npc.gd
class_name NPC
extends StaticBody2D

## Base NPC entity. Supports dialogue via DialogueManager
## and optionally faces the player on interaction.

signal interaction_started
signal interaction_ended

@export var npc_name: String = ""
@export var dialogue_lines: PackedStringArray = []
@export var portrait_path: String = ""
@export var face_player: bool = true

var _is_talking: bool = false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("npcs")


func interact() -> void:
	if dialogue_lines.is_empty():
		return
	if _is_talking:
		return

	if face_player:
		_face_toward_player()

	_is_talking = true
	interaction_started.emit()

	var lines: Array[DialogueLine] = []
	var portrait: Texture2D = null
	if not portrait_path.is_empty():
		portrait = load(portrait_path) as Texture2D
		if portrait == null:
			push_warning(
				"NPC '%s': portrait failed to load '%s'"
				% [npc_name, portrait_path]
			)

	for line_text in dialogue_lines:
		lines.append(DialogueLine.create(npc_name, line_text, portrait))

	var started := DialogueManager.start_dialogue(lines)
	if started:
		DialogueManager.dialogue_ended.connect(
			_on_dialogue_ended, CONNECT_ONE_SHOT
		)
	else:
		_is_talking = false


func _face_toward_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dir: Vector2 = (
		(player.global_position - global_position).normalized()
	)
	if absf(dir.x) > absf(dir.y):
		sprite.flip_h = dir.x < 0.0


func _on_dialogue_ended() -> void:
	_is_talking = false
	interaction_ended.emit()
	var bus := get_node_or_null("/root/EventBus")
	if bus:
		bus.emit_npc_interaction_ended(npc_name)
```

### Exports as Configuration

The NPC's data is configured through exports:

```gdscript
@export var npc_name: String = ""
@export var dialogue_lines: PackedStringArray = []
@export var portrait_path: String = ""
@export var face_player: bool = true
```

`dialogue_lines` is a `PackedStringArray` — a flat array of strings. In the inspector, you get an expandable list where you type each line. The NPC's `interact()` method converts these into `DialogueLine` Resources at runtime using the factory method from the previous chapter:

```gdscript
for line_text in dialogue_lines:
	lines.append(DialogueLine.create(npc_name, line_text, portrait))
```

This is a pragmatic compromise. For simple NPCs with static dialogue, exporting raw strings is faster than creating `.tres` files for every line. For complex dialogue with branching, choices, and portraits that change mid-conversation, you would load pre-built `DialogueLine` arrays from Resources instead.

### Face the Player

```gdscript
func _face_toward_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dir: Vector2 = (
		(player.global_position - global_position).normalized()
	)
	if absf(dir.x) > absf(dir.y):
		sprite.flip_h = dir.x < 0.0
```

When the player talks to an NPC, the NPC turns to face them. The implementation is simple: compute the direction vector from NPC to player, and if the horizontal component is larger, flip the sprite to face left or right. NPCs using a single-direction sprite only need horizontal flipping — no separate left/right animations.

`get_first_node_in_group("player")` is Godot's loose coupling pattern. The NPC does not hold a reference to the player node — it looks it up by group membership. This works because the player adds itself to the `"player"` group in its own `_ready()`.

### CONNECT_ONE_SHOT

```gdscript
DialogueManager.dialogue_ended.connect(
	_on_dialogue_ended, CONNECT_ONE_SHOT
)
```

This connection auto-disconnects after firing once. Without it, each time the player talks to this NPC, a new connection would be added, and `_on_dialogue_ended` would fire multiple times after future conversations — a classic memory leak in event-driven systems.

`CONNECT_ONE_SHOT` is the Godot equivalent of RxJS's `take(1)` operator or `{ once: true }` in `addEventListener()`.

### EventBus Integration

```gdscript
var bus := get_node_or_null("/root/EventBus")
if bus:
	bus.emit_npc_interaction_ended(npc_name)
```

After dialogue ends, the NPC notifies the EventBus. This allows other systems (quest tracking, tutorials, achievements) to react to NPC conversations without knowing about the NPC directly. The quest system might listen for `npc_interaction_ended("Elder Maren")` to advance an objective.

The null check (`get_node_or_null`) makes the NPC testable in isolation — tests can run without the EventBus autoload present.

## Player Interaction: RayCast2D

The player detects interactable objects using a RayCast2D that extends in the facing direction. When the interact input fires, the player checks what the ray is hitting:

```gdscript
# In player.gd

@onready var interaction_ray: RayCast2D = $InteractionRay


func _unhandled_input(event: InputEvent) -> void:
	if not _can_move:
		return
	if event.is_action_pressed("interact"):
		_try_interact()
		get_viewport().set_input_as_handled()


func _try_interact() -> void:
	interaction_ray.force_raycast_update()
	if not interaction_ray.is_colliding():
		return

	var collider := interaction_ray.get_collider()
	if collider and collider.has_method("interact"):
		collider.interact()
		interacted_with.emit(collider)
```

### How the RayCast Works

A RayCast2D is an invisible line that extends from the node's position in a specified direction. Each physics frame, Godot checks what the ray intersects. The key methods:

- `force_raycast_update()` — forces an immediate collision check (raycasts normally update once per physics frame)
- `is_colliding()` — returns true if the ray hit something
- `get_collider()` — returns the physics body the ray hit

The ray's direction changes with the player's facing:

```gdscript
func _update_ray_direction() -> void:
	match facing:
		Facing.DOWN:
			interaction_ray.target_position = Vector2(0, RAY_LENGTH)
		Facing.UP:
			interaction_ray.target_position = Vector2(0, -RAY_LENGTH)
		Facing.LEFT:
			interaction_ray.target_position = Vector2(-RAY_LENGTH, 0)
		Facing.RIGHT:
			interaction_ray.target_position = Vector2(RAY_LENGTH, 0)
```

`RAY_LENGTH` is typically 24 pixels — enough to reach the NPC standing one tile away, but not so far that you interact with distant objects.

### Duck Typing: has_method("interact")

```gdscript
if collider and collider.has_method("interact"):
	collider.interact()
```

This is duck typing — "if it has an `interact()` method, call it." The player does not check `if collider is NPC` or `if collider is Interactable`. It does not need to know what type the object is. It only cares whether the object can be interacted with.

This is the same principle as TypeScript's structural typing or Go's implicit interfaces. Any StaticBody2D with an `interact()` method is interactable — NPCs, chests, signs, doors, save points. The player handles all of them with one line of code.

## NPC Indicator Icons

NPCs can display floating icons above their heads to communicate their role to the player. A `!` means a quest is available. A `?` means a quest is in progress. A `$` means a shop:

```gdscript
enum IndicatorType {
	NONE = 0,
	CHAT = 1,
	QUEST = 2,
	QUEST_ACTIVE = 3,
	SHOP = 4,
}

const _INDICATOR_ICONS: Dictionary = {
	IndicatorType.CHAT: "...",
	IndicatorType.QUEST: "!",
	IndicatorType.QUEST_ACTIVE: "?",
	IndicatorType.SHOP: "$",
}

@export var indicator_type: IndicatorType = IndicatorType.NONE:
	set(value):
		indicator_type = value
		if is_node_ready():
			_update_indicator()
```

The indicator is a Label node created dynamically when the type is set. It floats above the NPC with a subtle bob animation:

```gdscript
func _update_indicator() -> void:
	if _indicator_tween:
		_indicator_tween.kill()
		_indicator_tween = null
	if _indicator:
		_indicator.queue_free()
		_indicator = null

	if indicator_type == IndicatorType.NONE:
		return

	_indicator = Label.new()
	_indicator.text = _INDICATOR_ICONS.get(indicator_type, "")
	_indicator.position = Vector2(0.0, -24.0)
	_indicator.z_index = 1
	_indicator.visible = false
	add_child(_indicator)

	_indicator_tween = create_tween()
	_indicator_tween.set_loops(0)
	_indicator_tween.set_trans(Tween.TRANS_SINE)
	_indicator_tween.tween_property(
		_indicator, "position:y", -26.0, 0.6
	)
	_indicator_tween.tween_property(
		_indicator, "position:y", -22.0, 0.6
	)
```

The indicator starts hidden and becomes visible when the player enters the NPC's interaction area (an Area2D child). This prevents icons from cluttering the screen when NPCs are far away:

```gdscript
func _on_body_entered_range(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	if _indicator and not _is_talking:
		_indicator.visible = true


func _on_body_exited_range(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = false
	if _indicator:
		_indicator.visible = false
```

During dialogue, the indicator hides (you do not need a `!` floating over someone's head while they are talking to you). When dialogue ends, it reappears if the player is still in range.

### Setter with is_node_ready()

```gdscript
@export var indicator_type: IndicatorType = IndicatorType.NONE:
	set(value):
		indicator_type = value
		if is_node_ready():
			_update_indicator()
```

The setter guard `is_node_ready()` prevents `_update_indicator()` from running before `_ready()` — which happens when Godot loads the scene and sets export values during construction. Without this guard, `add_child()` inside `_update_indicator()` would fail because the node is not yet in the tree.

This pattern applies to any setter that needs to modify child nodes: always check `is_node_ready()`.

## The NPC Scene Tree

```
NPC (StaticBody2D) — class_name NPC
  CollisionShape2D          ← physics collision for raycast detection
  Sprite2D                  ← NPC visual
  InteractionArea (Area2D)  ← proximity detection for indicator visibility
    CollisionShape2D        ← larger than the NPC's body collision
```

The NPC has two collision shapes for different purposes:

1. The **body CollisionShape2D** is a direct child of the StaticBody2D. This is what the player's RayCast2D hits when checking for interactable objects. It matches the NPC's visual size.

2. The **InteractionArea CollisionShape2D** is inside an Area2D. This is a larger radius that detects when the player is nearby. It controls indicator visibility (show the `!` when the player is close) but does not block movement.

This two-shape design is standard in JRPGs: tight collision for interaction detection, loose area for proximity awareness.

## Wiring It All Together

Here is the complete signal flow for a player talking to an NPC:

```
1. Player presses "interact"
   → Player._try_interact()
   → RayCast2D.force_raycast_update()
   → RayCast2D.get_collider() returns the NPC

2. Player calls NPC.interact()
   → NPC faces player
   → NPC builds DialogueLine array
   → NPC calls DialogueManager.start_dialogue(lines)

3. DialogueManager queues lines
   → Pushes DIALOGUE state (player freezes)
   → Emits dialogue_started
   → Calls advance() → emits line_displayed

4. DialogueBox receives line_displayed
   → Sets speaker name, portrait, text
   → Starts typewriter tween on visible_ratio
   → Player sees text appearing character by character

5. Player presses "interact" during typing
   → DialogueBox._skip_typing() — reveals all text
   → Or, if typing is done, calls DialogueManager.advance()

6. After last line, DialogueManager._end_dialogue()
   → Pops DIALOGUE state (player unfreezes)
   → Emits dialogue_ended
   → DialogueBox slides panel out
   → NPC._on_dialogue_ended() fires (one-shot connection)
   → NPC emits interaction_ended
   → EventBus.emit_npc_interaction_ended(npc_name)
```

Six systems participate in this flow, and none of them hold direct references to each other. The NPC knows about `DialogueManager` (an autoload), but not the `DialogueBox`. The `DialogueBox` knows about `DialogueManager`, but not any NPC. The player knows about `interact()` as a method, but not about any specific interactable type.

## Placing NPCs in a Scene

In a scene script, you create and configure NPCs programmatically:

```gdscript
func _setup_npcs() -> void:
	var elder := preload("res://entities/npc/npc.tscn").instantiate()
	elder.npc_name = "Elder Maren"
	elder.dialogue_lines = PackedStringArray([
		"Welcome to the village, traveler.",
		"The forest has been restless lately.",
		"Be careful if you venture beyond the tree line.",
	])
	elder.portrait_path = "res://assets/portraits/maren_portrait.png"
	elder.indicator_type = NPC.IndicatorType.QUEST
	elder.position = Vector2(176, 144)
	$Entities.add_child(elder)
```

Or you can place NPCs in the scene editor — drag the `npc.tscn` scene into the viewport, then configure exports in the inspector. Both approaches work. Scene scripts are better for NPCs whose dialogue changes based on game state (flags, quest progress). The inspector is better for static NPCs with fixed dialogue.

## Awaiting Dialogue Completion

Sometimes you need to wait for a dialogue to finish before continuing — for example, in a cutscene or an event script:

```gdscript
func _run_cutscene() -> void:
	var lines: Array[DialogueLine] = [
		DialogueLine.create("Kael", "What happened here?"),
		DialogueLine.create("Iris", "It looks like the village was attacked."),
	]
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	# Dialogue is now complete — continue the cutscene
	_start_next_scene()
```

The `await` keyword pauses the function until the `dialogue_ended` signal fires. This is Godot's coroutine mechanism — equivalent to `await` in TypeScript async functions, but waiting on signals rather than Promises.

## Common Mistakes

**Forgetting to kill tweens in _exit_tree().** If the DialogueBox or NPC is freed while a tween is running, the tween's callback fires on a freed object. Always kill tweens in `_exit_tree()`.

**Not using CONNECT_ONE_SHOT for dialogue_ended.** Each `interact()` call adds a new connection. After 10 conversations, `_on_dialogue_ended` fires 10 times. Use `CONNECT_ONE_SHOT` or manually disconnect after each conversation.

**Using Label instead of RichTextLabel.** `Label` does not have `visible_ratio`. If you use Label for the dialogue text, the typewriter effect will not work. Use `RichTextLabel`.

**Letting input propagate during dialogue.** Without `get_viewport().set_input_as_handled()`, the interact button press passes through to the player, potentially triggering movement or another interaction. Always consume the input.

**Starting dialogue when already active.** If the player spams the interact button, `start_dialogue()` gets called while a conversation is already running. The `_is_active` guard prevents queue corruption, but the NPC must also handle the `false` return value.

**Hardcoding NPC references.** Do not store a direct `var npc: NPC` reference on the player. Use `get_first_node_in_group()` for loose coupling. NPCs come and go across scenes — hard references break when scenes change.

## What Is Next

You have a complete dialogue system: data (DialogueLine), service (DialogueManager), and view (DialogueBox), connected through signals with clean state management. But dialogue is just one kind of interaction. In the next chapter, you will build a generic interactable system using the Strategy pattern, handling chests, signs, doors, and save points with a single entity class and pluggable behavior.
