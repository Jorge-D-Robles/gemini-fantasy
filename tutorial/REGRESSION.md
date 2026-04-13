# Tutorial Regression Checklist

Known-fixed issues from previous review passes. Reviewers MUST verify these haven't reappeared or been reintroduced by subsequent edits. Check each item and flag any regressions.

This file is NOT included in the tutorial website (build.js only picks up files matching `^\d{2}_*.md`).

## API Correctness

- [ ] **`scene_changed` not `tree_changed`:** All `await get_tree().tree_changed` or `await tree.tree_changed` must be `scene_changed`. Affects: modules 07, 08, 14, 19, 22, 23. Verified against `docs/godot-docs/classes/class_scenetree.rst`.
- [ ] **`get_node_or_null` not `Engine.has_singleton` for autoloads:** `Engine.has_singleton()` checks engine singletons (Input, AudioServer), not custom autoloads. Use `get_node_or_null("/root/AutoloadName")`. Affects: module 20 (`turn_in_quest`).
- [ ] **`hp_restore` not `effect_value`:** ItemData uses `hp_restore` as the field name, not `effect_value`. The data-driven example in module 09 must match.

## Cross-Module Data Consistency

- [ ] **HP carry-over in `initialize_from_character()`:** Must use `character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp` (same for `current_mp`). Without this, module 18's carry-over system is broken. Affects: modules 14, 19 (cheat sheet).
- [ ] **`max_mp` in enemy conversion:** `crystal_cavern.gd`'s enemy CharacterData conversion must include `char_data.max_mp = ed.max_mp`. Affects: module 17.
- [ ] **`scene_path` not `scene_name` in save slot dialog:** `get_slot_info()` returns `scene_path`, not `scene_name`. The display code must use `info.get("scene_path", "").get_file().get_basename()`. Affects: module 22.
- [ ] **BattlerData cheat sheet includes `current_mp`:** The module 19 BattlerData snippet must include `var current_mp: int = 0`.

## Input Handling

- [ ] **Dialogue choice bypass guard:** `_unhandled_input()` in dialogue_box.gd must return early when `_choice_container.visible` is true. Without this, the `interact` action skips choice buttons. Affects: module 11 (both incremental and complete code listings).
- [ ] **Save slot dialog, not hardcoded slot 1:** Continue and Retry buttons must use the SaveSlotDialog from module 22, not `SaveManager.load_game(1)`. Affects: module 25 (title screen and game over screen).

## Forward/Backward References

- [ ] **Collision layers/masks:** Module 03's note must be self-contained (explain layer/mask concept inline). Must NOT promise "we'll cover collision layers in Module 5" because module 05 covers tile physics layers, not the node-level layer/mask system.
- [ ] **`user://` forward reference:** Module 01 must specify "Module 22" for the `user://` prefix, not leave it vague.
- [ ] **"Next Module" teasers:** Module 18 must mention module 19 (review) before module 20. Modules should not skip review modules in their teasers.
- [ ] **Cross-reference module numbers:** Module 21 references must use correct numbers: Resources = Module 9, dialogue = Module 11, inventory = Module 12, flags = Module 20. Not the old numbering (7, 9, 10, 16).

## Editor Instructions & Warnings

- [ ] **Tile size before atlas:** Module 05 must have a `> **Warning:**` callout (not inline text) about setting tile size before creating an atlas source.
- [ ] **Global tile collision warning:** Module 05 must warn that marking a tile as solid in the TileSet applies across ALL layers sharing that TileSet.
- [ ] **Y-sort on Objects TileMapLayer:** Module 06 must have a `> **Warning:**` callout about enabling `y_sort_enabled` on the Objects TileMapLayer itself, not just the parent.
- [ ] **NPC placement in YSortGroup:** Module 10 must specify that NPCs go inside the YSortGroup node.
- [ ] **DialogueBox placement:** Module 11 must specify that DialogueBox is a direct child of the scene root (not inside YSortGroup), matching the `$DialogueBox` path.
- [ ] **PanelContainer anchor setup:** Module 11 must explain that "Bottom Wide" preset sets top anchor to 1.0, and the reader must manually change it to 0.75.
- [ ] **SceneManager process_mode:** Module 07 must set `process_mode = Always` during initial SceneManager scene setup, not retroactively in module 12.
- [ ] **Pause menu group setup:** Module 25 must have explicit instructions for adding InventoryScreen and QuestLog nodes to their respective groups (`inventory_screens`, `quest_logs`) in every area scene.

## Code Consistency

- [ ] **`_play_attack_animation` uses local position:** Module 15 must show only one version of this function, using `sprite.position` (local) not `sprite_node.global_position`. Both the inline and complete listing must match.
- [ ] **Collision shape motivation:** Module 06 must explain why the shape changes from `Vector2(14, 10)` (Godot icon) to `Vector2(12, 8)` (character sprite).

## File Paths & Missing Instructions

- [ ] **ShopData file path:** Module 21 must specify `res://resources/shop_data.gd` before the ShopData code block.
- [ ] **Placeholder tile creation:** Module 16 must give concrete steps for creating a placeholder tile PNG (image editor, dimensions, colors), not say "draw directly onto a new atlas."
- [ ] **DialogueBox/InventoryScreen in Crystal Cavern:** Module 16 must tell the reader to instance these in the CrystalCavern scene.
- [ ] **Exit zone wiring in Crystal Cavern:** Module 16 must show how to set up exit zones with specific `target_scene` and `target_spawn` values, referencing module 07's pattern.
- [ ] **Dialogue pipeline integration:** Module 20 must show how `_get_dialogue_for_npc()` replaces the existing `npc.npc_data.dialogue` lookup in `_on_npc_interacted()`.
- [ ] **Audio placeholder instructions:** Module 24 must give specific steps for creating silent OGG files for testing, not just mention Audacity generically.

## Style Rules

- [ ] **No double dashes as punctuation:** No `--` used as em-dashes anywhere in tutorial prose. Code comments using `--` for separators are also banned. Use colons, em-dashes, semicolons, or sentence breaks.
- [ ] **Starter layout for Willowbrook:** Module 05 must include a concrete starter layout (ASCII grid or equivalent) for readers who have never designed a tilemap.
- [ ] **Option A skip navigation:** Module 06 must tell Option A readers exactly which heading to skip to and where they rejoin the main flow.

## Module Structure

- [ ] **Autoload Reference Card in Module 25:** Module 25 introduces PauseMenu as the 8th autoload. It must include the final Autoload Reference Card with all 8 entries (SceneManager, InventoryManager, GameManager, QuestManager, PartyManager, SaveManager, MusicManager, PauseMenu).
- [ ] **"What You Should See" in Module 26:** Module 26 is a content module (not a review module), so it must include the "What You Should See" section per CLAUDE.md module anatomy rules.

## Banned Words and Style

- [ ] **No "landscape" in Module 05:** Line 194 previously used the banned AI word "landscape." Must use alternative phrasing (e.g., "surrounding wilderness").

## Factual Accuracy

- [ ] **Godot founding date:** Module 01 says development began in 2007 (not 2001).
