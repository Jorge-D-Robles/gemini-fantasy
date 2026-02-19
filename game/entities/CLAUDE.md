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
- Exports: `npc_name`, `dialogue_lines: Array[String]`, `portrait_path`, `face_player: bool`
- `interact()` — called by player raycast; starts `DialogueManager.start_dialogue()`
- `_face_toward_player()` — flips `sprite.flip_h` based on player X position
- Emits `interaction_started` / `interaction_ended` signals
- Calls `EventBus.emit_npc_talked_to(npc_name)` and `emit_npc_interaction_ended()`
- Adds self to group `"npcs"`
- Portrait loading is guarded with null check + `push_warning()`

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

## battle/ — Battle Battler Scenes

### EnemyBattlerScene (`enemy_battler_scene.gd`)

**Node hierarchy:**
```
EnemyBattlerScene (Node2D)
  Sprite2D         ← atlas-cropped to center column, row 0 of sprite sheet
  AnimationPlayer  ← "attack", "damage", "death" (fallback tweens if missing)
  HPBar (ProgressBar)
  DamageLabel (Label)
```

- `@export var enemy_data: EnemyData` — set by BattleManager when instantiating
- `bind_battler(target: EnemyBattler)` — wires `hp_changed`, `damage_taken`, `defeated` signals
- Animation methods: `play_attack_anim()`, `play_damage_anim()`, `play_death_anim()`, `show_damage_number()`
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
  DamageLabel (Label)
```

- `@export var character_data: CharacterData`
- `bind_battler(target: PartyBattler)` — wires `hp_changed`, `ee_changed`, `damage_taken`, `status_effect_applied/removed`, `defeated`
- `update_bars()` — refreshes HP and EE bar values
- `show_damage_number(amount)` / `show_heal_number(amount)` — red/green floating label
- Status icons: 2-char abbreviations shown in `StatusIcons` HBoxContainer

---

## Conventions

- Every entity adds itself to a named group in `_ready()` for loose coupling
- `interact()` is the standard method called by the player raycast
- All `load()` calls are guarded: null check + `push_error()`/`push_warning()`
- Signals flow: entity signal → `EventBus` emission (both are emitted when applicable)
- Battle scene animations fall back to code tweens if AnimationPlayer clips are absent
