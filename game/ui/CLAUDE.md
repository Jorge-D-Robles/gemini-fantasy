# game/ui/

All UI screens and overlays. Each subdirectory contains a `.tscn` scene and a `.gd` script. All UI nodes extend `CanvasLayer` except `title_screen` (extends `Control`).

## Shared Modules

| File | Purpose | Usage |
|------|---------|-------|
| `ui_theme.gd` | Color palette constants (panels, text, bars, accents) | `const UITheme = preload("res://ui/ui_theme.gd")` |
| `ui_helpers.gd` | Static utilities: `clear_children()`, `setup_focus_wrap()`, `create_panel_style()` | `const UIHelpers = preload("res://ui/ui_helpers.gd")` |
| `battle_ui/battle_ui_status.gd` | Static utilities: `compute_status_badges()`, `compute_target_info()` | `const BattleUIStatus = preload("res://ui/battle_ui/battle_ui_status.gd")` |
| `battle_ui/battle_ui_victory.gd` | Static utilities: `compute_victory_display()`, `stat_abbreviation()` | `const BattleUIVictory = preload("res://ui/battle_ui/battle_ui_victory.gd")` |
| `inventory_ui/inventory_ui_filter.gd` | Static utilities: `matches_category()`, `compute_item_entries()` | `const InventoryUIFilter = preload("res://ui/inventory_ui/inventory_ui_filter.gd")` |
| `inventory_ui/inventory_ui_detail.gd` | Static utilities: `compute_equipment_stats()`, `compute_item_detail()` | `const InventoryUIDetail = preload("res://ui/inventory_ui/inventory_ui_detail.gd")` |
| `shop_ui/shop_ui_detail.gd` | Static utilities: `compute_equip_stat_lines()`, `compute_item_effect_text()`, `compute_detail_info()` | `const ShopUIDetail = preload("res://ui/shop_ui/shop_ui_detail.gd")` |
| `shop_ui/shop_ui_list.gd` | Static utilities: `compute_buy_entries()`, `compute_sell_entries()` | `const ShopUIList = preload("res://ui/shop_ui/shop_ui_list.gd")` |
| `settings_menu/settings_data.gd` | Static utilities: `percent_to_db()`, `db_to_percent()`, `apply_volume()`, `save_settings()`, `load_settings()` | `const SD = preload("res://ui/settings_menu/settings_data.gd")` |

All UI screens should import these instead of defining local color constants or utility functions.

## Subdirectory Index

| Directory | Scene Root | Layer | Purpose |
|-----------|-----------|-------|---------|
| `battle_ui/` | `CanvasLayer` | — | In-battle overlay: commands, targeting, party status, resonance, log |
| `dialogue/` | `CanvasLayer` | 15 | Typewriter dialogue box with portraits and branching choices |
| `hud/` | `CanvasLayer` | 10 | Overworld HUD: location name, gold, party HP bars, objective tracker |
| `pause_menu/` | `CanvasLayer` | 20 | In-game pause menu: party, items, quests, status panels |
| `quest_log/` | `Control` (script-only) | — | Quest log sub-screen: active/completed quests with objectives and rewards |
| `title_screen/` | `Control` | — | Title screen with animated intro and main menu buttons |
| `shop_ui/` | `CanvasLayer` | — | Shop overlay: buy/sell tabs, item list, detail panel, price display |
| `settings_menu/` | `Control` (script-only) | — | Volume sliders for Master, BGM, SFX buses with disk persistence |
| `demo_end_screen/` | `Control` | — | Demo ending: "Thanks for Playing!" with party lineup and return-to-title button |

## Color Palette

| Role | Color | Usage |
|------|-------|-------|
| Background | `(0.05, 0.03, 0.1)` deep indigo | Title screen, panel backgrounds |
| Panel fill | `(0.12, 0.07, 0.22, 0.85)` dark purple | Button normal state, menu panels |
| Panel hover | `(0.18, 0.12, 0.32, 0.9)` lighter purple | Button hover/focus state |
| Text primary | `(0.85, 0.75, 1.0)` lavender | Titles, active text |
| Text secondary | `(0.6, 0.55, 0.7)` muted lavender | Subtitles, descriptions |
| Accent gold | `(0.85, 0.75, 0.45, 0.8)` gold | Borders on hover/focus |
| Border normal | `(0.45, 0.35, 0.65, 0.6)` muted purple | Button borders in normal state |
| Battle panel | `(0.1, 0.1, 0.2, 0.85)` dark blue-purple | Battle UI panels |

## Button Styling

All menu buttons use `StyleBoxFlat` theme overrides: 3px corner radius, 1px border, 16px/4px margin. Copy `StyleBoxFlat` sub-resources from `title_screen.tscn` when adding new buttons.

## battle_ui/battle_ui.gd

### Signals (consumed by battle states)
```gdscript
signal command_selected(command: String)  # "attack" | "skill" | "item" | "defend" | "flee"
signal target_selected(target: Battler)
signal skill_selected(ability: Resource)
signal item_selected(item: Resource)
signal submenu_cancelled
signal target_cancelled
```

### Public API
```gdscript
func show_command_menu(battler: Battler) -> void
func hide_command_menu() -> void
func show_skill_submenu(abilities: Array[Resource]) -> void
func show_item_submenu(items: Array[Resource]) -> void
func show_target_selector(targets: Array[Battler], callback: Callable) -> void
func update_party_status(party: Array[Battler]) -> void
func update_turn_order(queue: Array[Battler]) -> void
func update_resonance(gauge_value: float, state: Battler.ResonanceState) -> void
func add_battle_log(text: String, log_type: int = UITheme.LogType.INFO) -> void
func show_victory(exp: int, gold: int, items: Array[String]) -> void
func show_defeat() -> void
```

**Portraits:** `kael_portrait.png`, `iris_portrait.png`, `garrick_portrait.png` from `tf-faces-6.11.20/transparent/1x/` (192x96 sheet, first 96x96 face shown)

## dialogue/dialogue_box.gd

### Signals
```gdscript
signal dialogue_line_finished
signal dialogue_complete
```

### Auto-connects to DialogueManager
- `dialogue_started` -> slides panel in
- `dialogue_ended` -> slides panel out, emits `dialogue_complete`
- `line_displayed(speaker, text, portrait_texture)` -> typewriter effect (30 chars/sec)
- `choice_presented(choices: Array[String])` -> shows choice buttons

**Input:** `interact` = skip typewriter or advance; `cancel` = skip typewriter only

## hud/hud.gd

### API
```gdscript
@export var location_name: String
func show_interaction_prompt(text: String) -> void
func hide_interaction_prompt() -> void
func update_party_display() -> void
func set_gold(amount: int) -> void
func update_objective_tracker() -> void
static func compute_tracker_state(qm: Node) -> Dictionary  # pure logic, testable
```

### Auto-connects to
- `PartyManager.party_changed` / `party_state_changed` -> refreshes party HP
- `GameManager.game_state_changed` / `scene_changed` -> show/hide
- `InventoryManager.gold_changed` -> syncs gold label
- `QuestManager.quest_accepted` / `quest_progressed` / `quest_completed` / `quest_failed` -> updates objective tracker

## pause_menu/pause_menu.gd

Opens on `menu` input action. Pauses scene tree. Pushes `GameManager.GameState.MENU`.

### Signals
```gdscript
signal menu_opened
signal menu_closed
```

**Buttons:** Party, Items, Quests, Status, Quit to Title
**Sub-screens:** Items opens inventory_ui, Quests opens quest_log (both hide menu panel + pause label, restore on close with focus)
**Rules:** Only opens during `OVERWORLD` and not during transitions. `process_mode = PROCESS_MODE_ALWAYS`.

## quest_log/quest_log.gd

Script-only Control opened from pause menu as a sub-screen. No `.tscn` file.

### Signals
```gdscript
signal quest_log_closed
```

### Public API
```gdscript
func open() -> void
func close() -> void
static func compute_quest_list(qm: Node, show_completed: bool) -> Array[Dictionary]
# Returns: [{id, title, quest_type, description, objectives: [{text, completed}], rewards: {gold, exp, items}}]
```

**Tabs:** Active / Completed — switches which quests are displayed
**Detail panel:** Quest name (gold), type tag, description, objectives with checkmarks, reward summary
**Empty state:** Shows "No active quests" / "No completed quests" when list is empty
**Close:** `cancel` input action emits `quest_log_closed`

## title_screen/title_screen.gd

### Signals
```gdscript
signal new_game_pressed
signal continue_pressed
signal settings_pressed
```

**Buttons:** New Game -> overgrown_ruins; Continue -> loads save slot 0; Settings -> signal only
**Fade-in tween:** title (1s) -> subtitle (0.5s) -> menu (0.5s) -> version (0.3s)

## UI Conventions

- Focus navigation wired in `_ready()` with wrapping pattern
- `_unhandled_input` for cancel/navigation, never `_input`
- Dynamic UI rebuilt by clearing children and recreating (not updated in-place)
- Styles applied programmatically with `StyleBoxFlat` — no theme resource file
- Font sizes: title=36, buttons=14, HUD labels=12, dialogue=10, battle log=9

## Dependencies

GameManager, PartyManager, InventoryManager, DialogueManager, SaveManager, EquipmentManager, QuestManager, EventFlags autoloads. `Battler` class for ResonanceState enum.
