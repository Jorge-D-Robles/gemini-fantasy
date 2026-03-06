# game/autoloads/

Global singleton scripts registered in `project.godot`. All are autoloaded at startup and accessible by name from any script. **Do not add `class_name`** to autoload scripts — they are already global singletons.

## File Index

| File | Autoload Name | Purpose |
|------|--------------|---------|
| `game_manager.gd` | `GameManager` | Game state machine + scene transitions with fade |
| `audio_manager.gd` | `AudioManager` | BGM crossfade playback + SFX pool (8 players) |
| `ui_layer.gd` | `UILayer` | Persistent UI layer (HUD, DialogueBox, PauseMenu) |
| `dialogue_manager.gd` | `DialogueManager` | Dialogue queue flow; emits signals consumed by DialogueBox UI |
| `party_manager.gd` | `PartyManager` | Party roster, active/reserve members, runtime HP/EE state |
| `battle_manager.gd` | `BattleManager` | Initiates battle scene transitions; wraps `battle_scene.tscn` |
| `equipment_manager.gd` | `EquipmentManager` | Per-character equipment slots + stat bonuses + serialize |
| `save_manager.gd` | `SaveManager` | JSON save/load to `user://saves/` slot files |
| `event_bus.gd` | `EventBus` | Central signal hub — decoupled relay for gameplay events |
| `inventory_manager.gd` | `InventoryManager` | Item dictionary + gold; also emits `EventBus.item_acquired` |
| `quest_manager.gd` | `QuestManager` | Quest accept/objective progress/complete/fail + serialize |
| `reputation_manager.gd` | `ReputationManager` | Faction reputation tracking (Shepherds, Initiative, Free Resonants) + tiers + pricing + serialize |
| `bond_manager.gd` | `BondManager` | Character bond levels (D-C-B-A-S), point awards from battles/camps, combat bonuses + serialize |

## Key APIs

### GameManager
```gdscript
GameManager.push_state(GameManager.GameState.CUTSCENE)
GameManager.pop_state()
GameManager.change_scene("res://scenes/foo/foo.tscn", fade_duration, spawn_point)
GameManager.current_state  # GameState enum value
```
**Signals:** `game_state_changed(old, new)`, `scene_changed(path)`, `transition_started/midpoint/finished`
**States:** `OVERWORLD, BATTLE, DIALOGUE, MENU, CUTSCENE`

### AudioManager
```gdscript
AudioManager.play_bgm(stream)          # crossfades if already playing
AudioManager.stop_bgm()
AudioManager.play_sfx(stream)                                  # NORMAL priority (round-robin)
AudioManager.play_sfx(stream, AudioManager.SfxPriority.CRITICAL)  # always plays; finds free player
AudioManager.play_sfx(stream, AudioManager.SfxPriority.AMBIENT)   # skips if all 8 players busy
```
Uses audio buses named `"BGM"` and `"SFX"`.

### DialogueManager
```gdscript
DialogueManager.start_dialogue(lines: Array[DialogueLine])
DialogueManager.advance()              # called by UI on confirm input
DialogueManager.select_choice(index)
DialogueManager.is_active() -> bool
await DialogueManager.dialogue_ended
```
**Signals:** `dialogue_started`, `dialogue_ended`, `line_displayed(speaker, text, portrait)`, `choice_presented(choices: Array[String])`, `choice_selected(index: int)`

### PartyManager
```gdscript
PartyManager.add_character(data: Resource)   # auto-routes active/reserve
PartyManager.get_active_party() -> Array[Resource]
PartyManager.get_hp(character_id: StringName) -> int
PartyManager.set_hp(character_id, value)
PartyManager.heal_all()
```
Max 4 active, 4 reserve. Runtime HP/EE keyed by `BattlerData.id`.

### BattleManager
```gdscript
BattleManager.start_battle(enemy_group: Array[Resource], can_escape: bool)
BattleManager.is_in_battle() -> bool
```
**Signals:** `battle_started`, `battle_ended(victory: bool)`
Guards: blocked if dialogue active, not in OVERWORLD state, or transitioning.

### EventBus
```gdscript
EventBus.emit_npc_interaction_ended(npc_name)
EventBus.emit_interactable_used(interactable_name)
EventBus.emit_enemy_defeated(enemy_id)
EventBus.emit_item_acquired(item_id, quantity)
EventBus.emit_area_entered(area_name)   # auto-called on scene_changed
```
Entities call `emit_*` helpers; listeners connect to the signals directly.

### InventoryManager
```gdscript
InventoryManager.add_item(id: StringName, count: int)
InventoryManager.remove_item(id, count) -> bool
InventoryManager.has_item(id) -> bool
InventoryManager.gold  # int property
InventoryManager.add_gold(amount)
InventoryManager.get_usable_items() -> Array[ItemData]   # battle-usable only
```

### QuestManager
```gdscript
QuestManager.accept_quest(quest: Resource)
QuestManager.complete_objective(quest_id, objective_index)
QuestManager.is_quest_active(quest_id) -> bool
QuestManager.is_quest_completed(quest_id) -> bool
QuestManager.serialize() -> Dictionary
QuestManager.deserialize(data, quest_resources)
```

### EquipmentManager
```gdscript
EquipmentManager.equip(character_id, equipment: EquipmentData) -> EquipmentData  # returns old
EquipmentManager.get_stat_bonuses(character_id) -> Dictionary  # attack/magic/defense/etc.
EquipmentManager.serialize() -> Dictionary
EquipmentManager.deserialize(data)
```
Slots: `weapon`, `helmet`, `chest`, `accessory_0`, `accessory_1`.

### ReputationManager
```gdscript
ReputationManager.add_reputation(faction_id: StringName, amount: int)
ReputationManager.get_reputation(faction_id: StringName) -> int
ReputationManager.set_reputation(faction_id: StringName, value: int)
ReputationManager.get_tier(faction_id: StringName) -> Tier
ReputationManager.get_price_modifier(faction_id: StringName) -> float
ReputationManager.has_tier(faction_id: StringName, min_tier: Tier) -> bool
ReputationManager.get_all_reputations() -> Dictionary
ReputationManager.reset_all()
ReputationManager.serialize() -> Dictionary
ReputationManager.deserialize(data: Dictionary)
```
**Signals:** `reputation_changed(faction_id, old_value, new_value)`
**Faction IDs:** `SHEPHERDS`, `INITIATIVE`, `FREE_RESONANTS` (StringName constants)
**Tiers:** `HOSTILE` (-100..-50), `UNFRIENDLY` (-49..-10), `NEUTRAL` (-9..9), `FRIENDLY` (10..49), `ALLIED` (50..100)
**Price modifiers:** HOSTILE=1.5, UNFRIENDLY=1.2, NEUTRAL=1.0, FRIENDLY=0.9, ALLIED=0.8

### BondManager
```gdscript
BondManager.add_bond_points(char_a: StringName, char_b: StringName, amount: int)
BondManager.get_bond_level(char_a, char_b) -> BondData.BondLevel  # D/C/B/A/S
BondManager.get_bond_points(char_a, char_b) -> int
BondManager.get_party_combat_bonus(party_ids: Array[StringName]) -> Dictionary  # {damage_bonus, defense_bonus}
BondManager.award_battle_bond_points(party_ids)  # +2 per pair
BondManager.award_camp_bond_points(party_ids)    # +3 per pair
BondManager.serialize() -> Dictionary
BondManager.deserialize(data: Dictionary)
BondManager.reset_all()
```
**Signals:** `bond_level_changed(char_a, char_b, old_level, new_level)`
**Auto-connects:** `BattleManager.battle_ended` in `_ready()` — awards +2 per pair on victory.
**Combat bonus caps:** 40% max damage bonus, 25% max defense bonus across all active pairs.

### SaveManager
```gdscript
SaveManager.save_game(slot, party, inventory, flags, scene_path, player_pos, equipment, quests, playtime, echo_mgr, rep_mgr, bond_mgr)
SaveManager.load_save_data(slot) -> Dictionary
SaveManager.apply_save_data(data, party, inventory, flags, equipment, quests, echo_mgr, rep_mgr, bond_mgr)
SaveManager.has_save(slot) -> bool
```
Format: JSON at `user://saves/save_N.json`, version field = `1`.

## Dependencies

- `EventBus` connects to `GameManager.scene_changed` in `_ready()`
- `DialogueManager` calls `GameManager.push_state/pop_state`
- `BattleManager` calls `GameManager`, `DialogueManager`, `PartyManager`
- `InventoryManager` calls `EventBus.emit_item_acquired` on add
- `QuestManager` reads `EventFlags.has_flag` for prerequisites
- `SaveManager` calls `ReputationManager.serialize/deserialize` when `rep_mgr` is passed
- `SaveManager` calls `BondManager.serialize/deserialize` when `bond_mgr` is passed
- `BondManager` connects to `BattleManager.battle_ended` for auto-awarding bond points

## Conventions

- No `class_name` on any autoload — access via autoload name only
- All autoloads use `push_warning` for invalid input, `push_error` for critical failures
- Return `bool` for operations that can fail (e.g., `remove_item`, `remove_gold`)
- Use `CONNECT_ONE_SHOT` for callbacks that should fire exactly once
