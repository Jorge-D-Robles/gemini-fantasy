# game/entities/

Reusable scene prefabs for game objects placed in overworld and battle scenes.
See root `CLAUDE.md` for project-wide conventions.

## Subdirectory Index

| Directory | Purpose |
|-----------|---------|
| `player/` | Player character — movement, facing, interaction |
| `npc/` | Base NPC scene — dialogue, facing player |
| `interactable/` | Generic interactable with pluggable strategy |
| `interactable/strategies/` | Concrete `InteractionStrategy` implementations |
| `companion/` | Companion followers that trail behind the player |
| `battle/` | Visual battler scenes for combat (enemy + party) |

---

## player/ — Player

**Files:** `player.gd`, `player.tscn`

**Node hierarchy:**
```
Player (CharacterBody2D) — class_name Player
  CollisionShape2D
  AnimatedSprite2D         ← built at runtime from kael_overworld.png
  InteractionRay (RayCast2D) ← 24px forward cast, updates with facing
  Camera2D
```

**Key behavior:**
- 4-directional movement via `move_left/right/up/down` + `run` input actions
- Facing enum (`DOWN/UP/LEFT/RIGHT`) drives `InteractionRay` direction and animation
- `interact` action → `InteractionRay.force_raycast_update()` → calls `collider.interact()` if present
- Emits `interacted_with(target)` signal and calls `EventBus.emit_player_interacted()`
- `GameManager.game_state_changed` → `set_movement_enabled()` (only moves in OVERWORLD state)
- Adds self to group `"player"` — other nodes use `get_first_node_in_group("player")`
- `_setup_animations()` builds `SpriteFrames` at runtime: `walk_down`, `idle_down`, etc.
  Guard: if `load(SPRITE_PATH)` returns null, logs error and skips

**Public API:**
- `set_movement_enabled(enabled: bool)` — freeze/unfreeze player
- `get_facing_direction() -> Vector2` — current facing as unit vector

---

## companion/ — Companion Followers

**Files:** `companion_controller.gd`, `companion_follower.gd`

**CompanionController** (`class_name CompanionController`, `extends Node`):
- Manages all follower entities that trail behind the player
- Records player position history buffer (MAX_HISTORY=200 frames)
- Assigns follower positions directly from the buffer (FOLLOW_OFFSET=15 frames apart)
- Connects to `PartyManager.party_changed` and `GameManager.game_state_changed`
- Rebuilds followers when party changes; pauses when not in OVERWORLD state
- Filters Kael from followers by ID (`KAEL_ID = &"kael"`)
- `_ready()` calls `parent.move_child(self, 0)` to ensure companions render behind player via tree order
- Cleans up signal connections in `_exit_tree()`

**CompanionFollower** (`class_name CompanionFollower`, `extends Node2D`):
- Single follower entity with `AnimatedSprite2D` built at runtime from 3x4 sprite sheet
- `setup(sprite_path, char_id)` — loads texture, builds 8 animations (walk/idle x 4 directions)
- `set_facing(Facing)` / `set_moving(bool)` — driven by controller
- `SPRITE_SCALE = Vector2(0.55, 0.75)`, renders behind player via tree order (CompanionController is first child of Entities)

**Wiring in scene scripts** (added at end of `_ready()`):
```gdscript
var player_node := get_tree().get_first_node_in_group("player") as Node2D
if player_node:
    var companion_ctrl := CompanionController.new()
    companion_ctrl.setup(player_node)
    $Entities.add_child(companion_ctrl)
```

**Static helpers** (testable without scene tree):
- `CompanionController.compute_followers_needed(party)` — filters Kael from party
- `CompanionController.compute_history_index(idx, size, offset)` — history buffer lookup
- `CompanionFollower.build_sprite_frames(texture)` — creates SpriteFrames from 3x4 sheet
- `CompanionFollower.compute_facing_from_direction(dir)` — Vector2 to Facing enum

---

## npc/ — NPC

**Files:** `npc.gd`, `npc.tscn`

**Node hierarchy:**
```
NPC (StaticBody2D) — class_name NPC
  CollisionShape2D
  Sprite2D
  InteractionArea (Area2D)
    CollisionShape2D
```

**Key behavior:**
- Exports: `npc_name`, `dialogue_lines: PackedStringArray`, `portrait_path`, `face_player: bool`, `indicator_type: IndicatorType`
- `interact()` — called by player raycast; starts `DialogueManager.start_dialogue()`
- `_face_toward_player()` — flips `sprite.flip_h` based on player X position
- Emits `interaction_started` / `interaction_ended` signals
- Calls `EventBus.emit_npc_talked_to(npc_name)` and `emit_npc_interaction_ended()`
- Adds self to group `"npcs"`
- Portrait loading is guarded with null check + `push_warning()`

**Indicator system:**
- `enum IndicatorType { NONE, CHAT, QUEST, QUEST_ACTIVE, SHOP }` — default `NONE`
- Floating Label above NPC head (position `(0, -24)`, z_index=1, font_size=10)
- Icons: CHAT=`...`, QUEST=`!`, QUEST_ACTIVE=`?`, SHOP=`$`
- Colors: QUEST/SHOP=`UITheme.TEXT_GOLD`, QUEST_ACTIVE=`UITheme.TEXT_PRIMARY`, CHAT=white
- Initially hidden; shown when player enters `InteractionArea`, hidden on exit
- Hidden during dialogue (`_is_talking`), re-shown when dialogue ends if player still in range
- Subtle bob animation (±2px, 1.2s loop, TRANS_SINE)
- Tween killed in `_exit_tree()` to prevent callbacks on freed nodes
- Can be changed at runtime via setter — creates/destroys indicator dynamically

**Usage in scene scripts:**
```gdscript
npc.indicator_type = NPC.IndicatorType.QUEST  # shows "!" in gold
npc.indicator_type = NPC.IndicatorType.SHOP   # shows "$" in gold
```

---

## interactable/ — Interactable + Strategy Pattern

**Files:** `interactable.gd`, `interactable.tscn`, `interaction_strategy.gd`

**Node hierarchy:**
```
Interactable (StaticBody2D) — class_name Interactable
  CollisionShape2D
  Sprite2D
  InteractionArea (Area2D)
    CollisionShape2D
```

**Key behavior:**
- `@export var strategy: InteractionStrategy` — assign in Inspector or scene script
- `@export var one_time: bool = true` — blocks re-use after first interaction
- `interact()` → `strategy.execute(self)`, emits `interacted`, calls `EventBus.emit_interactable_used(name)`
- Adds self to group `"interactables"`

**InteractionStrategy** (base class, `extends Resource`):
- Override `execute(owner: Node) -> void` in subclasses
- `owner` is the `Interactable` node — strategies can read `owner.has_been_used`

### strategies/

| File | Class | Exports | Behavior |
|------|-------|---------|----------|
| `sign_strategy.gd` | `SignStrategy` | `text: String` | Displays text via `DialogueManager` |
| `chest_strategy.gd` | `ChestStrategy` | `item_id`, `text` | Shows item message, sets `has_been_used` |
| `item_pickup_strategy.gd` | `ItemPickupStrategy` | `item_id`, `text` | Shows message, awaits dialogue end, calls `owner.queue_free()` |
| `door_strategy.gd` | `DoorStrategy` | `target_scene`, `spawn_point` | Calls `GameManager.change_scene()` |
| `save_point_strategy.gd` | `SavePointStrategy` | `text`, `fail_text` | Calls `SaveManager.save_game()`, shows result |

**Autoloads used by strategies:** `DialogueManager`, `GameManager`, `SaveManager`, `PartyManager`, `InventoryManager`, `EventFlags`

---

## ZoneMarker (`zone_marker.gd`) — class_name ZoneMarker

**Script-only component** (no .tscn — draws chevron via `_draw()`).

Animated directional arrow marking zone transition exits. Scene scripts instantiate via `ZoneMarker.new()`, set properties, then `add_child()`. Persistent node — lives until parent scene is freed.

```gdscript
enum Direction { LEFT, RIGHT, UP, DOWN }
var direction: Direction = Direction.RIGHT
var marker_color: Color = DEFAULT_COLOR  # gold: Color(1.0, 0.9, 0.5, 1.0)
var destination_name: String = ""        # optional label text
```

- **Chevron**: 6px filled polygon via `_draw()`, points in `direction`
- **Alpha pulse**: `modulate:a` tweens 0.3-1.0 over 1.2s (infinite loop, TRANS_SINE)
- **Directional bob**: position tweens +/-3px along arrow axis over 1.6s (infinite loop)
- **Destination label**: optional `Label` child created when `destination_name` is set (font_size=7, centered below chevron)
- **z_index = 1**: above ground, below AbovePlayer canopy (z_index=2)
- **Cleanup**: `_exit_tree()` kills both tweens to prevent callbacks on freed nodes

**Usage in scene scripts:**
```gdscript
var marker := ZoneMarker.new()
marker.direction = ZoneMarker.Direction.LEFT
marker.destination_name = "Verdant Forest"
marker.position = _exit_to_forest.position + Vector2(12, 0)
add_child(marker)
```

---

## battle/ — Battle Battler Scenes

### DamagePopup (`damage_popup.gd`) — class_name DamagePopup

**Script-only component** (no .tscn — creates Label child in `_ready()`).

Reusable floating damage/heal number. Battler scenes instantiate via `DamagePopup.new()`, `add_child()`, then `setup()`. Self-destructs via `queue_free()` after tween animation.

```gdscript
enum PopupType { DAMAGE, HEAL, CRITICAL }
func setup(amount: int, type: PopupType = PopupType.DAMAGE) -> void
```

- **DAMAGE**: red text (`UITheme.LOG_DAMAGE`), plain number
- **HEAL**: green text (`UITheme.LOG_HEAL`), "+N" format
- **CRITICAL**: gold text (`UITheme.POPUP_CRITICAL`), "N!" format, larger font (14 vs 10)
- Animation: float up 30px over 0.8s, fade after 0.3s delay, random X offset [-8, 8]
- Multiple popups can coexist simultaneously (fire-and-forget, not awaitable)

### EnemyBattlerScene (`enemy_battler_scene.gd`)

**Node hierarchy:**
```
EnemyBattlerScene (Node2D)
  Sprite2D         ← atlas-cropped to center column, row 0 of sprite sheet
  AnimationPlayer  ← "attack", "damage", "death" (fallback tweens if missing)
  HPBar (ProgressBar)
```

- `@export var enemy_data: EnemyData` — set by BattleManager when instantiating
- `bind_battler(target: EnemyBattler)` — wires `hp_changed`, `damage_taken`, `defeated` signals
- Animation methods: `play_attack_anim()`, `play_damage_anim()`, `play_death_anim()`
- `show_damage_number(amount)` / `show_heal_number(amount)` — spawns DamagePopup (fire-and-forget)
- All animation methods are `await`-able (return after tween/anim finishes)

### PartyBattlerScene (`party_battler_scene.gd`)

**Node hierarchy:**
```
PartyBattlerScene (Node2D)
  Sprite2D         ← flipped horizontally (flip_h = true), 2x scale
  AnimationPlayer
  HPBar (ProgressBar)  ← 48×4px, positioned at (-24, -54)
  EEBar (ProgressBar)  ← 48×3px, positioned at (-24, -49)
  StatusIcons (HBoxContainer) ← Label icons added per status effect
```

- `@export var character_data: CharacterData`
- `bind_battler(target: PartyBattler)` — wires `hp_changed`, `ee_changed`, `damage_taken`, `status_effect_applied/removed`, `defeated`
- `update_bars()` — refreshes HP and EE bar values
- `show_damage_number(amount)` / `show_heal_number(amount)` — spawns DamagePopup (fire-and-forget)
- Status icons: 2-char abbreviations shown in `StatusIcons` HBoxContainer

---

## Conventions

- Every entity adds itself to a named group in `_ready()` for loose coupling
- `interact()` is the standard method called by the player raycast
- All `load()` calls are guarded: null check + `push_error()`/`push_warning()`
- Signals flow: entity signal → `EventBus` emission (both are emitted when applicable)
- Battle scene animations fall back to code tweens if AnimationPlayer clips are absent
