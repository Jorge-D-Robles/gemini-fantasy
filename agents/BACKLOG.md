# Backlog

All tickets not in the current sprint. Sorted by milestone, then priority.

---

## Tilemap Overhaul — Top Priority

### T-0251
- Title: Hard-ban A5 sheets — update AGENT_RULES + map_builder.gd deprecation warnings
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M1
- Depends: —
- Refs: agents/AGENT_RULES.md, game/systems/map_builder.gd, .claude/agents/tilemap-builder.md, docs/best-practices/11-tilemaps-and-level-design.md

**Goal:** Establish a project-wide, unbreakable ban on RPGMaker A5 autotile sheets (any `*A5*` or `*tileA5*` file). These sheets have a layout where columns within a row are NOT freely mixable — placing tiles from different columns of the same row produces visible seam artifacts. We have been unknowingly shipping broken-looking tilemaps because of this.

**What to change:**

1. **`agents/AGENT_RULES.md`** — Add a prominent `## HARD BANS` section at the top, before any other rules:
   ```
   ## HARD BANS (never do these — no exceptions)

   - **Never use A5 autotile sheets** — any file matching `*A5*`, `*tileA5*`, or `*_A5_*` in its name
     is an RPGMaker autotile sheet where columns within a row produce seam artifacts when mixed.
     Use TF_TERRAIN (`TimeFantasy_TILES/TILESETS/terrain.png`) for outdoor ground,
     TF_DUNGEON for dungeon/ruins ground, and B-sheets (`tf_*_tileB_*.png`) for objects.
   - **Never use `set_cells_terrain_connect()`** without pre-configured Terrain Sets (we don't have them).
   - **Never carpet-bomb decorations** — no percentage-based coverage, no noise-driven object scatter
     that fires on every cell. Every decoration must be intentional and sparse.
   ```

2. **`game/systems/map_builder.gd`** — Add `@warning_ignore` comment and deprecation notice to every A5 constant:
   ```gdscript
   ## @deprecated Use TF_TERRAIN or TF_DUNGEON instead. A5 sheets are RPGMaker autotile
   ## format — columns within a row produce seam artifacts when mixed in Godot.
   const FAIRY_FOREST_A5_A: String = "res://assets/tilesets/tf_ff_tileA5_a.png"
   ```
   Add this `## @deprecated` doc comment above EVERY `*A5*` constant.

3. **`.claude/agents/tilemap-builder.md`** — In the Tile Atlas Reference section, add a bold warning box:
   ```
   > ⛔ BANNED: Never use A5 sheets (any MapBuilder constant ending in _A5, _A5_A, _A5_B, etc.)
   > These are RPGMaker autotile sheets. Using them produces seam artifacts in Godot.
   > ALL ground layers must use TF_TERRAIN, TF_DUNGEON, TF_OUTSIDE, TF_CASTLE, or TF_INSIDE.
   ```

4. **`docs/best-practices/11-tilemaps-and-level-design.md`** — Add "A5 Usage" to the Anti-Patterns table as CRITICAL severity.

**No code changes to scenes yet** — that's T-0253 through T-0256. This ticket is documentation + deprecation warnings only.

**Tests:** None required — this is documentation only.

---

### T-0252
- Title: Enhance tilemap review workflow — web search comparison + A5 blocking check + mandate dual review in build-tilemap skill
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M1
- Depends: T-0251
- Refs: .claude/agents/tilemap-reviewer-adversarial.md, .claude/skills/build-tilemap/SKILL.md

**Goal:** The adversarial tilemap reviewer must (a) do a web search for published JRPG reference screenshots before scoring, (b) auto-fail any map that uses A5 sheets, and (c) be a mandatory gate in the build-tilemap skill before any tilemap is allowed to commit.

**Change 1 — `.claude/agents/tilemap-reviewer-adversarial.md`:**

After Step 2 (View the Tile Sheets), add a new **Step 2.5 — Web Search for JRPG Reference**:

```markdown
### Step 2.5 — Search for Professional JRPG Reference Screenshots

Before scoring, ground yourself in what professional pixel art looks like. Do all 3 searches:

```
WebSearch("Chrono Trigger pixel art overworld screenshot SNES tilemap")
WebSearch("Final Fantasy 6 town map screenshot pixel art")
WebSearch("JRPG pixel art 16x16 tileset top-down organic forest dungeon")
```

Read at least 2 result images. Note specifically:
- How varied is the ground? (Multiple terrain types? Irregular patches?)
- How sparse are the decorations? (Less than you think — professionals use very few)
- Do paths meander or are they straight? (Real paths curve and vary in width)
- How do multi-tile objects anchor the space? (Trees, buildings as landmarks)

You WILL compare the submitted tilemap against these references when scoring.
```

Also add a new anti-pattern check to Step 5 — **A5 Sheet Usage (INSTANT FAIL)**:
```markdown
#### A5 Sheet Usage — INSTANT FAIL
- Does the scene script reference any constant ending in `_A5`, `_A5_A`, `_A5_B`?
- Is `FAIRY_FOREST_A5_A`, `RUINS_A5`, `OVERGROWN_RUINS_A5`, or any other A5 constant in the atlas_paths?
- Run: `Grep(pattern="A5", path="game/scenes/<scene_name>/")`
- **If ANY A5 reference is found: this is an automatic REJECT with score 1/5.**
- **Fix:** Replace A5 ground sheets with TF_TERRAIN (outdoor) or TF_DUNGEON (dungeon/ruins).
```

Also update Rule #8 in the Rules section:
```
8. **A5 usage is a hard REJECT** — If you find any A5 sheet in atlas_paths, score 1/5 and REJECT immediately. Do not soften this. A5 sheets produce seam artifacts and are banned from all new tilemap work.
```

Update the Anti-Pattern Checklist in the output format to add:
```
- [ ] A5 sheet usage: <INSTANT FAIL if found / PASS>
- [ ] Reference comparison: Does this approach the quality of the Chrono Trigger/FF6 screenshots? <YES/NO — details>
```

**Change 2 — `.claude/skills/build-tilemap/SKILL.md`:**

After Step 7 (Final Visual Quality Check), add a new mandatory **Step 8 — Dual Reviewer Gate**:

```markdown
## Step 8 — MANDATORY: Dual Reviewer Sign-Off Before Committing

**Do NOT commit the final tilemap without passing both reviewers.** Spawn them in parallel:

```gdscript
# In your agent, spawn both reviewers simultaneously:
Task(subagent_type="tilemap-reviewer-adversarial", prompt="Review tilemap for <scene_name>: <what changed>")
Task(subagent_type="tilemap-reviewer-neutral", prompt="Review tilemap for <scene_name>: <what changed>")
```

**Consensus rules:**
- Both APPROVE → commit and push
- Any REVISE → apply fixes, re-screenshot, re-review
- Any REJECT → rework the offending layers, re-screenshot, re-review

**You cannot merge a tilemap that has not passed both reviewers.** This is non-negotiable. If you are blocked by a reviewer, fix the specific issues they identified — do not argue or skip.
```

**Tests:** None required — documentation only.

---

### T-0253
- Title: Redo Roothollow tilemap — TF_TERRAIN biome system, dual-reviewer sign-off required
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0251, T-0252
- Refs: game/scenes/roothollow/roothollow.gd, game/scenes/roothollow/roothollow_maps.gd

**Goal:** Roothollow is a cozy fairy forest village — the safe hub town. Its tilemap currently uses `FAIRY_FOREST_A5_A` for all ground tiles (rows 8, 2, 6, 10, 14 — all A5 format). Replace entirely with TF_TERRAIN flat 16×16 tiles using a proper biome+hash system. The village should look lived-in: grass paths, packed earth around buildings, flower patches near the inn, varied terrain around the forest border.

**Architecture:**
- Source 0: `TF_TERRAIN` (replaces `FAIRY_FOREST_A5_A`) — all ground and paths
- Source 1: `MUSHROOM_VILLAGE` (keep — B-sheet, already correct format)
- Source 2: `FOREST_OBJECTS` (keep — B-sheet)
- Source 3: `STONE_OBJECTS` (keep — B-sheet)

**Implementation:**

1. **Read `terrain.png` visually** before choosing any coordinates. terrain.png layout reference (verify by reading the PNG):
   - Row 1, cols 2–11: Bright green grass
   - Row 2, cols 1–11: Muted/secondary green
   - Row 6, cols 1–8: Warm brown earth/dirt
   - Row 9, cols 1–16: Sandy/tan (good for cobble paths)
   - Row 10+: Verify visually — may have stone path tiles
   - **Cols 22+: BANNED — RPGMaker auto-tiles section**

2. **`roothollow_maps.gd`** — Replace `GROUND_ENTRIES` format with the `BIOME_TILES` + `OPEN_BIOME_THRESHOLDS` + `pick_tile()` pattern from `VerdantForestMap`. Add `enum Biome` BEFORE the constants. Biomes for Roothollow:
   - `BRIGHT_GREEN`: village square and inn garden (vibrant grass)
   - `MUTED_GREEN`: forest border and shaded areas
   - `DIRT`: well-worn earth around buildings, market stalls, paths
   - Pick TF_TERRAIN coordinates by reading the PNG — confirm visually

3. **Path legend** — Replace A5 row 10 path tiles with TF_TERRAIN equivalent. Row 9 (sandy/tan) is a good cobble path choice for a village. Confirm by reading terrain.png.

4. **Detail legend** — Replace A5 row 14 flower tiles with TF_TERRAIN or STONE_OBJECTS equivalents. Read the PNG to confirm.

5. **`roothollow.gd`** — Change `atlas_paths[0]` from `MapBuilder.FAIRY_FOREST_A5_A` to `MapBuilder.TF_TERRAIN`. Replace `build_noise_layer()` with `_fill_ground_with_variants()` pattern (same as verdant_forest.gd).

**Process:**
- Run `/run-tests` before starting to get a clean baseline
- Build ground layer → `/scene-preview roothollow.tscn --full-map` → evaluate
- Build paths → screenshot → evaluate
- Build detail/mushrooms → screenshot → evaluate
- Final: spawn both tilemap reviewers in parallel (T-0252 adds the mandatory gate to build-tilemap)
- Both must APPROVE before committing
- Run `/run-tests` — all tests pass before commit

---

### T-0254
- Title: Redo Overgrown Ruins tilemap — TF_DUNGEON + B-sheets, no A5
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0251, T-0252
- Refs: game/scenes/overgrown_ruins/overgrown_ruins.gd, game/scenes/overgrown_ruins/overgrown_ruins_map.gd

**Goal:** Overgrown Ruins is the game's starting area — ancient golden ruins overgrown with vegetation. Its tilemap currently uses `FAIRY_FOREST_A5_A` for ground (A5 format, rows 8/6/10) and `RUINS_A5` for golden walls/floors (A5 format). Replace both with flat 16×16 equivalents. The scene should feel like crumbling stone dungeon floors with patches of overgrown vegetation forcing through the cracks.

**Architecture:**
- Source 0: `TF_DUNGEON` (replaces `FAIRY_FOREST_A5_A`) — stone dungeon floor tiles, flat 16×16
- Source 1: `RUINS_OBJECTS` (`tf_B_ruins2.png`) — already B-sheet; golden ruins wall/object tiles (keep as source 1, verify which tiles in this sheet can serve as structural elements)
- Source 2: `OVERGROWN_RUINS_OBJECTS` (`tf_B_ruins3.png`) — already B-sheet; overgrown objects (keep)

**Implementation:**

1. **Read `dungeon.png` visually** before choosing ground coordinates. Also read `tf_B_ruins2.png` to see what structural/wall tiles are available in B-sheet format.

2. **`overgrown_ruins_map.gd`** — Replace `GROUND_ENTRIES` with the `BIOME_TILES` + `pick_tile()` pattern. Biomes for Overgrown Ruins:
   - `STONE_FLOOR`: dominant — cracked dungeon stone (TF_DUNGEON coords — read PNG to identify)
   - `DIRT_CRACKED`: overgrown earth pushing through (TF_DUNGEON or TF_TERRAIN row 6 coords)
   - `VEGETATION`: patches of green overgrowth (TF_TERRAIN row 1 or 2 coords)

   Use low noise frequency (0.05–0.07) for large organic patches. The ruins should feel like stone with vegetation bursting through in clusters, not uniform.

3. **Remove `RUINS_A5` from atlas_paths** in `overgrown_ruins.gd`. If structural wall tiles are needed, find them in `tf_B_ruins2.png` (B-sheet) or `TF_DUNGEON` (flat tiles) — read both PNGs visually.

4. The `OVERGROWN_RUINS_OBJECTS` B-sheet source stays — it provides decorative objects and is already the correct format.

**Process:**
- Run `/run-tests` for baseline
- Iterate layer by layer with `/scene-preview --full-map` after each
- Final: dual reviewer gate (both must APPROVE)
- Run `/run-tests` — all pass before commit

---

### T-0255
- Title: Redo Prismfall Approach tilemap — complete TF_TERRAIN migration (code still uses A5 coords)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0251, T-0252
- Refs: game/scenes/prismfall_approach/prismfall_approach.gd, game/scenes/prismfall_approach/prismfall_approach_map.gd

**Goal:** The Prismfall Approach documentation was updated to say it uses TF_TERRAIN, but the actual code never got migrated. `prismfall_approach.gd` still passes `MapBuilder.FAIRY_FOREST_A5_A` as source 0, and `prismfall_approach_map.gd` has a GROUND_ENTRIES comment still labeled `(FAIRY_FOREST_A5_A, source 0)` with A5 atlas coordinates (`Vector2i(0, 2)`, `Vector2i(0, 10)`, `Vector2i(0, 6)` — these are A5 row indices, not TF_TERRAIN). Path legend also uses A5 coordinate `Vector2i(0, 4)`.

The Prismfall Approach is the Crystalline Steppes — an open, arid rocky landscape with scrubland, bare earth, and a cobble road leading south. It should feel dry and desolate, distinct from Verdant Forest.

**Architecture:**
- Source 0: `TF_TERRAIN` (already declared as the plan, just needs the code to match)
- Source 1: `STONE_OBJECTS` (keep — B-sheet, correct format)

**Implementation:**

1. **Read `terrain.png` visually** to find appropriate steppe/arid coords:
   - Sandy/tan tiles (row 9) — the steppes feel dry, sandy
   - Brown earth (row 6) — barren patches
   - Possibly a rocky/gray variant — check if terrain.png has stone rows
   - **Avoid bright green grass — this is NOT a forest**

2. **`prismfall_approach_map.gd`** — Full migration:
   - Remove the `GROUND_ENTRIES` approach entirely
   - Add `enum Biome { SANDY, BROWN_EARTH, ROCKY }` BEFORE constants
   - Add `BIOME_TILES` dictionary with TF_TERRAIN coordinates (read PNG to confirm)
   - Add `OPEN_BIOME_THRESHOLDS`, `VARIANT_HASH_SEED`
   - Add `pick_tile()` and `get_biome_for_noise()` static methods
   - Rename comment from `# ---------- TILE LEGENDS (FAIRY_FOREST_A5_A, source 0) ----------` to `# ---------- TILE LEGENDS (TF_TERRAIN, source 0) ----------`
   - Replace PATH_LEGEND coordinate `Vector2i(0, 4)` with actual TF_TERRAIN path tile (row 9 sandy cobble is likely correct — verify visually)
   - Remove `FOLIAGE_NOISE_*` constants (no foliage on barren steppes)

3. **`prismfall_approach.gd`** — Change `atlas_paths[0]` from `MapBuilder.FAIRY_FOREST_A5_A` to `MapBuilder.TF_TERRAIN`. Replace `build_noise_layer()` with `_fill_ground_with_variants()` pattern.

**Process:**
- Run `/run-tests` baseline
- Build ground → `/scene-preview --full-map` → evaluate (should look dry, steppe-like)
- Build paths → screenshot → evaluate
- Final: dual reviewer gate (both must APPROVE)
- Run `/run-tests` — all pass before commit

---

### T-0256
- Title: Redo Overgrown Capital tilemap — TF_DUNGEON + B-sheets, no A5
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0251, T-0252
- Refs: game/scenes/overgrown_capital/overgrown_capital.gd, game/scenes/overgrown_capital/overgrown_capital_map.gd

**Goal:** The Overgrown Capital is a sprawling ruined city — the most complex dungeon scene. Its tilemap currently uses `FAIRY_FOREST_A5_A` (source 0 ground) and `RUINS_A5` (source 1 structural) — both A5 format. The capital should feel like a grand ancient city that has been reclaimed by nature: cracked stone plazas, collapsed archways, vines through golden walls, with distinct districts visible.

**Architecture:**
- Source 0: `TF_DUNGEON` (replaces `FAIRY_FOREST_A5_A`) — stone dungeon floor for urban ruins
- Source 1: `RUINS_OBJECTS` (`tf_B_ruins2.png`) — already B-sheet (replaces `RUINS_A5` as structural source)
- Source 2: `OVERGROWN_RUINS_OBJECTS` (`tf_B_ruins3.png`) — already B-sheet (keep)

**Implementation:**

1. **Read `dungeon.png` visually** for ground floor tiles. Read `tf_B_ruins2.png` to understand what structural tiles are available in B-sheet format. Also search:
   ```
   WebSearch("pixel art top-down ruins city tilemap JRPG")
   WebSearch("Chrono Trigger Zeal ruins pixel art screenshot")
   ```

2. **`overgrown_capital_map.gd`** — Full migration to `BIOME_TILES` + `pick_tile()` pattern. Biomes for the Capital:
   - `GRAND_STONE`: polished stone plaza floors (TF_DUNGEON fancy floor tiles)
   - `CRACKED_STONE`: weathered/cracked stone (TF_DUNGEON worn variants)
   - `OVERGROWN`: earth and vegetation reclaiming the streets (TF_TERRAIN row 1 or 6)

3. **`overgrown_capital.gd`** — Change atlas_paths to use `MapBuilder.TF_DUNGEON` for source 0, `MapBuilder.RUINS_OBJECTS` for source 1, `MapBuilder.OVERGROWN_RUINS_OBJECTS` for source 2. Replace `build_noise_layer()` with `_fill_ground_with_variants()`.

4. The authored structural map data (walls, corridors, district layouts) in the map arrays may need significant redesign if it referenced specific A5 row tiles. Read the existing map arrays in `overgrown_capital_map.gd` before deciding whether to keep the authored layout or redesign it.

**Process:**
- Run `/run-tests` baseline
- Ground layer first → `/scene-preview --full-map`
- Structural layer → screenshot → evaluate
- Detail/debris → screenshot → evaluate
- Final: dual reviewer gate (both must APPROVE)
- Run `/run-tests` — all pass before commit

---

### T-0257
- Title: Final purge — remove A5 constants from map_builder.gd after all scenes migrated
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: T-0253, T-0254, T-0255, T-0256
- Refs: game/systems/map_builder.gd, game/systems/CLAUDE.md, game/scenes/CLAUDE.md

**Goal:** After all existing scenes have been migrated off A5 sheets (T-0253 through T-0256), delete the A5 constants from `map_builder.gd` entirely. This makes the ban enforced at the code level — future agents cannot use A5 even accidentally since the constants no longer exist.

**Scope:**
1. **Verify zero A5 usage** before deleting:
   ```bash
   grep -r "A5" game/scenes/ game/events/ game/systems/ --include="*.gd"
   ```
   If any A5 reference remains, that scene must be migrated first (file a new ticket).

2. **Delete from `map_builder.gd`** all constants matching `*A5*`:
   - `FAIRY_FOREST_A5_A`, `FAIRY_FOREST_A5_B`
   - `RUINS1_A5`, `RUINS_A5`, `OVERGROWN_RUINS_A5`
   - `GIANT_TREE_A5_EXT`, `GIANT_TREE_A5_INT`
   - `ASHLANDS_A5`
   - `ATLANTIS_A5_A`, `ATLANTIS_A5_B`
   - `DARK_DIMENSION_A5`
   - `STEAMPUNK_A5_DUNGEON`, `STEAMPUNK_A5_INT`, `STEAMPUNK_A5_TRAIN`
   - `SEWERS_A5`

3. **Update `game/systems/CLAUDE.md`** — Remove A5 from the Pre-defined texture path constants list.

4. **Update `game/scenes/CLAUDE.md`** — Remove the Legacy A5 entries from the MapBuilder Constants Reference.

5. Run `/run-tests` — all tests pass. If any test fails because it referenced a deleted constant, update the test.

**Do NOT delete this ticket early.** It must wait until T-0253, T-0254, T-0255, and T-0256 are all marked done.

---

## Bugs — High Priority

### T-0250
- Title: Fix EnemyBattler.choose_action() typed array mismatch (battle crash)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: —
- Refs: game/systems/battle/states/enemy_turn_state.gd:25, game/systems/battle/enemy_battler.gd:25, game/systems/battle/battle_scene.gd:13-14

**Error:**
```
Invalid type in function 'choose_action' in base 'Node2D (EnemyBattler)'.
The array of argument 1 (Array[PartyBattler]) does not have the same element type
as the expected typed array argument.
```

**Root cause:**
`battle_scene.party_battlers` is `Array[PartyBattler]` and `battle_scene.enemy_battlers` is `Array[EnemyBattler]`. `EnemyBattler.choose_action()` declares its parameters as `Array[Battler]`. GDScript 4 typed arrays are invariant — `Array[PartyBattler]` cannot be passed where `Array[Battler]` is expected, even though `PartyBattler extends Battler`.

**Fix options (pick one):**
1. Convert at call site in `enemy_turn_state.gd` using `.assign()` before passing:
   ```gdscript
   var party: Array[Battler] = []; party.assign(battle_scene.party_battlers)
   var allies: Array[Battler] = []; allies.assign(battle_scene.enemy_battlers)
   var action := enemy.choose_action(party, allies)
   ```
2. Change `battle_scene.party_battlers` / `enemy_battlers` to `Array[Battler]` and downcast at use sites.

Option 1 is the minimal, safe fix. Regression test: verify `choose_action` is called without error for each AI type (BASIC, AGGRESSIVE, DEFENSIVE, SUPPORT, BOSS).

---

## M0 — Foundation

### T-0175
- Title: Add fade-in on BGM stack pop/restore to prevent audio snap
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Started: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0117, T-0128
- Refs: game/autoloads/audio_manager.gd
- Notes: pop_bgm() resumes overworld track at saved position but volume snaps immediately to _bgm_volume_db. Should fade from 0.0 to _bgm_volume_db over 0.5s (half normal crossfade). compute_bgm_restore_fade_duration() static helper. 2+ tests.

### T-0174
- Title: Add Iris personal quest stub to quest log after recruitment
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0081, T-0090
- Refs: docs/story/character-quests/iris-engineers-oath.md, game/data/quests/
- Notes: After iris_recruited, create QuestData .tres "The Engineer's Oath: Pending" with one objective: "Understand why Iris left the Initiative." Single-stage narrative breadcrumb. QuestManager auto-accepts on iris_recruited flag. compute_should_auto_accept_iris_quest(flags) static helper. 3+ tests.

### T-0173
- Title: Add Garrick personal quest stub to quest log after recruitment
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0082, T-0090
- Refs: docs/story/character-quests/garrick-three-burns.md, game/data/quests/
- Notes: After garrick_recruited, create QuestData .tres "Something He Carries" with one objective: "Travel with Garrick and learn his story." Single-stage narrative breadcrumb. QuestManager auto-accepts on garrick_recruited flag in GarrickRecruitment.trigger(). compute_should_auto_accept_garrick_quest(flags) static helper. 3+ tests.

### T-0172
- Title: Add party banter trigger scaffold — BanterManager static helper
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0081, T-0082
- Refs: docs/story/camp-scenes/party-banter.md, game/scenes/verdant_forest/verdant_forest.gd
- Notes: Lightweight static class BanterManager (RefCounted, no autoload). compute_eligible_banters(party_ids, flags, location) returns Array of eligible banter keys. Enables T-0169 and future banters without per-scene boilerplate. 5+ tests verifying eligibility conditions.

### T-0171
- Title: Add Overgrown Capital entry scene — 3-person party gate dialogue on entry
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: T-0085
- Refs: docs/story/act1/05-into-the-capital.md (Scene 1), game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Chapter 5 Scene 1 gate dialogue (4-5 lines): Garrick reacts to scale of ruins, Iris reports crystal density and pre-Sev population, Kael quiet. Gated by garrick_recruited AND overgrown_capital_entry_seen flag (one-shot). Trigger on scene entry via call_deferred. Static module pattern from T-0162. 3+ tests.

### T-0170
- Title: Disambiguate innkeeper rest options — priority logic for night events
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0148, T-0135
- Refs: game/scenes/roothollow/roothollow.gd, game/events/camp_three_fires.gd, game/events/garrick_night_scene.gd
- Notes: Innkeeper fires CampThreeFires or GarrickNightScene from same handler. If both flags are unset, GarrickNightScene (garrick_met_lyra gate) takes priority over CampThreeFires (garrick_recruited gate) per story order. compute_innkeeper_night_event(flags) static helper for TDD. 3+ tests.

### T-0169
- Title: Add Iris-Kael overworld banter — BOND-01 "Knife Lessons" post-Chapter-3 scene
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0081
- Refs: docs/story/camp-scenes/party-banter.md (BOND-01), game/scenes/verdant_forest/verdant_forest.gd
- Notes: 5-line campfire banter at Verdant Forest after iris_recruited flag. Iris corrects Kael's knife grip. EventFlags gate: bond_01_knife_lessons. Static compute_bond01_eligible(flags, party) helper. 3+ tests.

### T-0165
- Title: Add keyboard and gamepad focus navigation to party_ui sub-screen
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: T-0020
- Refs: game/ui/party_ui/party_ui.gd, docs/best-practices/08-ui-patterns.md
- Notes: party_ui.gd wires UIHelpers.setup_focus_wrap but inter-column navigation (arrow keys to move between active and reserve panels, confirm to select, cancel to deselect) needs wiring. Match the pattern in inventory_ui.gd and shop_ui.gd. 5+ tests.

### T-0164
- Title: Wire party_changed signal from PartyManager into party_ui refresh
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Started: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0020
- Refs: game/ui/party_ui/party_ui.gd, game/autoloads/party_manager.gd
- Notes: party_ui builds its two-column display once at open time. If another system modifies the roster while the sub-screen is open, the display will be stale. Connect PartyManager.party_changed and party_state_changed to _refresh_display in open(), disconnect in close(). 3+ tests.

### T-0163
- Title: Add party swap validation feedback in party UI
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0020
- Refs: game/ui/party_ui/party_ui.gd, game/ui/party_ui/party_ui_data.gd
- Notes: compute_swap_valid() returns false for invalid swaps (edge cases like 0-size lists). Currently the UI silently ignores the action. Add a 0.3s red flash on the active member button and a transient status label. compute_swap_feedback_text() static helper for TDD. 3+ tests.

### T-0166
- Title: BUG — Defend stance clears before enemy can attack (is_defending reset in TurnEnd)
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battler.gd, game/systems/battle/states/turn_end_state.gd, game/systems/battle/states/player_turn_state.gd
- Notes: end_turn() clears is_defending immediately in TurnEnd. Enemy attacks in subsequent EnemyTurn see is_defending=false so damage is not halved. JRPG-correct behavior: is_defending should persist until the player's next turn starts. Fix: clear is_defending in PlayerTurnState.enter() for the active battler, not in end_turn(). Requires removing is_defending=false from Battler.end_turn() and updating test_end_turn_clears_defend. Also update CLAUDE.md docs for battler.end_turn().

### T-0167
- Title: Add playtime accumulation gate — prevent ticking during battle or cutscene
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0130
- Refs: game/autoloads/game_manager.gd
- Notes: T-0130 adds playtime_seconds incremented in _process. Without a gate, playtime accumulates during BATTLE and CUTSCENE states, inflating reported time. Add compute_should_tick_playtime(state) static helper, gate increment to OVERWORLD state only. 2+ tests.

### T-0168
- Title: Verify and fix enemy turn routing through ActionExecuteState for consistent crit behavior
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0143, T-0156
- Refs: game/systems/battle/states/enemy_turn_state.gd, game/systems/battle/states/action_execute_state.gd
- Notes: Supersedes T-0156. Confirm whether EnemyTurnState routes through ActionExecuteState (crits already applied). If not, wire BattlerDamage.roll_crit(attacker.luck) and apply_crit() into the enemy damage path. Also confirm COMBAT_CRITICAL_HIT SFX plays on enemy crits. 3+ tests verifying enemy crit roll uses 5% + luck*0.5% formula.

### T-0162
- Title: Add Verdant Forest traversal dialogue — party comments heading to Overgrown Capital
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0085
- Refs: docs/story/act1/04-old-iron.md (End of Chapter hook), game/scenes/verdant_forest/verdant_forest.gd
- Notes: After garrick_recruited flag is set, the three-person party crosses the Verdant Forest toward Overgrown Ruins. Add a 3-4 line on-entry dialogue gated by garrick_recruited (and forest_traversal_full_party flag to fire once only). Garrick notes crystal density, Iris assesses threat level, Kael orients the group. 3+ tests.

### T-0008
- Title: Replace has_method/has_signal with proper typing in autoloads
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/battle_manager.gd, game/autoloads/dialogue_manager.gd
- Notes: Uses duck-typing instead of specific class types. Low priority — works but not type-safe.

### T-0009
- Title: Implement party healing at rest points in Roothollow
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd
- Notes: Placeholder comment for party healing logic. Partially addressed by innkeeper healing (T-0029).

### T-0010
- Title: Add return type hints to all methods
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/entities/battle/enemy_battler.gd, game/systems/battle/battle_scene.gd, game/autoloads/battle_manager.gd
- Notes: Numerous methods missing explicit -> void or return type hints.

### T-0011
- Title: Add doc comments to signals and public methods
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battle_scene.gd, game/systems/battle/battler.gd
- Notes: Many signals and public methods lack ## doc comments.

### T-0018
- Title: Build skill tree framework
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: T-0019
- Refs: docs/mechanics/character-abilities.md, game/resources/ability_data.gd
- Notes: SkillTreeData Resource. Unlock nodes with skill points on level up. Character-specific trees per design doc.

### T-0023
- Title: Implement camp/rest system
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: T-0009
- Refs: docs/game-design/01-core-mechanics.md, game/ui/camp_menu/camp_menu.gd, game/entities/interactable/strategies/camp_strategy.gd
- Notes: Rest at designated points. Full HP/EE restore. Optional bonding scenes. Camp menu UI. CampMenuData static helper; CampMenu script-only Control (Rest + Leave Camp); CampStrategy opens from any Interactable. Follow-up: place campfire interactable in Verdant Forest.

### T-0024
- Title: Implement fast travel system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: none
- Refs: docs/game-design/03-world-map-and-locations.md
- Notes: Unlock fast travel points as discovered. World map selection UI. Transition animations. Re-milestoned from M0 (T-0185) — full system build, out of scope for M0 close.

### T-0025
- Title: Build bonding system framework
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: none
- Refs: docs/game-design/01-core-mechanics.md, docs/lore/03-characters.md
- Notes: BondData Resource. Affinity tracking between characters. Bond events at camp. Re-milestoned from M0 (T-0185) — full system build, out of scope for M0 close.

### T-0026
- Title: Build debug console
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: docs/IMPLEMENTATION_GUIDE.md
- Notes: Toggle with ~ key. Commands: add_item, set_level, heal_all, teleport, start_battle.

---

## S03 — Demo Polish & Completeness

### Bug Fixes

### T-0049
- Title: BUG — Verdant Forest camera limit cuts off bottom row
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: critical
- Milestone: M0
- Depends: none
- Refs: game/scenes/verdant_forest/verdant_forest.tscn
- Notes: GROUND_MAP has 25 rows (400px tall) but Camera2D limit_bottom is 384 (24 rows). Bottom 16px of map is inaccessible. Fix: change limit_bottom to 400 in the .tscn Camera2D node.

### T-0050
- Title: BUG — Overgrown Ruins spawn position check uses Vector2.ZERO comparison
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/overgrown_ruins/overgrown_ruins.gd (lines 226-228)
- Notes: Checks `player_node.global_position == Vector2.ZERO` as spawn condition. Fragile — should always set spawn position or use a "first_entry" flag.

---

### Battle UI & Background

### T-0051
- Title: Add battle background sprite and scene backdrop
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: critical
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battle_scene.tscn, game/systems/battle/battle_scene.gd
- Notes: BattleBackground Sprite2D node exists but has no texture. Combat occurs against transparent overworld — breaks immersion, makes UI hard to read. Source backgrounds from Time Fantasy packs. Consider multiple backgrounds that change based on encounter area (forest, ruins, town).

### T-0052
- Title: Color-code battle log messages by type
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd
- Notes: Battle log shows plain white text. Color-code: red for damage, green for healing, yellow for status effects, blue for resonance, white for neutral. Use RichTextLabel BBCode. Add subtle fade-in animation.

### T-0053
- Title: Add floating damage numbers above targets
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/action_execute_state.gd
- Notes: Spawn a floating Label on damage: rises and fades out above target. Red for damage, green for healing, gold for criticals. Create reusable DamagePopup scene. Tween position + alpha over 0.8s.

### T-0054
- Title: Add status effect icons/badges on battler panels
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd, game/resources/status_effect_data.gd
- Notes: No visual indicator of active status effects on party/enemy panels. Add small icon badges (poison=green, burn=fire, buff=up arrow) next to battler names. Show remaining duration.

### T-0055
- Title: Improve battle target selector with name label and highlight
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd
- Notes: Current selector is just a yellow ">" arrow. Add enemy name label, subtle highlight on selected sprite, HP bar preview.

### T-0056
- Title: Enhance victory screen with portraits and level-up display
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/victory_state.gd, game/ui/battle_ui/battle_ui.gd
- Notes: Add character portraits, animated XP bar fill, "LEVEL UP!" callout with stat gains, item icons for loot drops, gold coin icon.

### T-0057
- Title: Improve turn order display with current actor highlight
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd
- Notes: Turn order bar shows abbreviated names in small text. Add larger text, active character border/glow, slide animation on order change, ally=blue vs enemy=red.

### T-0058
- Title: Add screen shake on heavy damage
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battle_scene.gd
- Notes: Camera jitter when character takes >25% max HP damage. 3-4 frame shake, 2-3px offset. Reusable shake function on battle Camera2D.

---

### Tilemap Quality

### T-0059
- Title: Roothollow — add AbovePlayer tilemap layer and consolidate tree sprites
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd, game/scenes/roothollow/roothollow.tscn, docs/best-practices/11-tilemaps-and-level-design.md
- Notes: CRITICAL tilemap violation. Missing AbovePlayer TileMapLayer (z_index=2) for forest border canopy. Uses 10+ manual Sprite2D + StaticBody2D trees (expensive, inconsistent). Add AbovePlayer layer with canopy tiles from FOREST_OBJECTS. Remove manual Tree01-Tree10 and collision nodes. Let TreesBorder tilemap handle rendering/collision. Verify with /scene-preview.

### T-0060
- Title: Roothollow — reduce ground detail density from 50% to 15%
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd
- Notes: DETAIL_MAP has ~50% tile coverage. Best practice is 5-15%. Remove 60-70% of f/F/b/B characters. Concentrate remaining accents in town plaza area and scattered clearings. Verify with /scene-preview.

### T-0061
- Title: Overgrown Ruins — separate debris layer and fix z-index ambiguity
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Two MapBuilder.build_layer() calls on same GroundDetail layer. Should separate into distinct Debris layer. Also Walls and Objects both at z_index=0 — set Objects to z_index=1.

### T-0062
- Title: Add boundary collision walls to all map edges
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd, game/scenes/verdant_forest/verdant_forest.gd, game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Player can walk to the very edge of maps. Add invisible StaticBody2D collision walls around all map perimeters (or use tilemap collision on border tiles). Ensure transition zones are properly placed before the boundary. Consider shared helper function for generating boundary walls.

---

### Audio & Music

### T-0063
- Title: Source and import BGM tracks for demo areas
- Status: done
- Assigned: user
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/assets/music/
- Notes: DONE — 12 OGG tracks already imported at game/assets/music/ with .import files generated. Tracks: Battle Theme Organ, Battle! Intro, Castle, Desert Theme, Epic Boss Battle 1st section, Main Character, My Hometown, Peaceful Days, Success!, Town Theme Day, Town Theme Night, Welcoming Heart Piano.
- Completed: 2026-02-18

### T-0064
- Title: Integrate BGM playback into all scenes and battle system
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/scenes/roothollow/roothollow.gd, game/scenes/verdant_forest/verdant_forest.gd, game/scenes/overgrown_ruins/overgrown_ruins.gd, game/autoloads/battle_manager.gd, game/systems/battle/battle_scene.gd, game/systems/battle/states/victory_state.gd
- Notes: 12 BGM tracks exist at res://assets/music/. Wire AudioManager.play_bgm() into all relevant game events. Suggested mapping — Roothollow: "Town Theme Day.ogg" or "My Hometown.ogg". Verdant Forest: "Peaceful Days.ogg". Overgrown Ruins: "Castle.ogg". Standard battles: "Battle Theme Organ.ogg" (use "Battle! Intro.ogg" as optional intro). Boss battles: "Epic Boss Battle 1st section.ogg". Victory: "Success!.ogg". Title screen: "Main Character.ogg" or "Welcoming Heart Piano.ogg". Implementation: load each track in scene _ready() or as preloaded const, call AudioManager.play_bgm(stream). Battle music: play on battle start, restore area BGM on battle end (save reference to current area track before battle). Victory jingle: play "Success!.ogg" in victory_state.gd, then resume area BGM after results screen. All load() calls must null-check. Crossfade between tracks using AudioManager's built-in fade_time parameter.

### T-0065
- Title: Add battle music (standard encounters and boss)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/autoloads/battle_manager.gd
- Notes: MERGED INTO T-0064. This ticket is superseded — battle music integration is now part of the unified BGM integration task T-0064.

### T-0066
- Title: Add UI sound effects (menu, dialogue, buttons)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/ui/dialogue/dialogue_box.gd
- Notes: SFX for: menu open/close, button hover/select, dialogue advance, choice select. Wire AudioManager.play_sfx() into UI scripts. No SFX assets exist yet — will need to source or create.

### T-0067
- Title: Add combat sound effects (attack, magic, heal, death)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/systems/battle/states/action_execute_state.gd
- Notes: SFX: physical attack hit, magic cast, healing chime, enemy death, critical hit, status effect apply, resonance overload. Wire into action_execute_state.gd. No SFX assets exist yet — will need to source or create.

### T-0068
- Title: Build settings/options menu with volume sliders
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: T-0064
- Refs: docs/best-practices/08-ui-patterns.md, game/autoloads/audio_manager.gd
- Notes: Options screen from pause menu + title screen. Volume sliders: Master, BGM, SFX. Persist to user://settings.json. Wire to AudioServer bus volumes.

---

### Code Refactoring — Reusable Components

### T-0069
- Title: Extract shared UI helpers (colors, focus nav, panel styles, clear_children)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd, game/ui/inventory_ui/inventory_ui.gd, game/ui/shop_ui/shop_ui.gd, game/ui/pause_menu/pause_menu.gd
- Notes: 4 UI files duplicate: PANEL_BG/PANEL_BORDER color constants, _clear_children(), _setup_focus_wrap(), StyleBoxFlat creation, TEXT_PRIMARY/TEXT_SECONDARY. Create game/ui/ui_helpers.gd with static methods and shared constants. Update all 4 files. Saves 40+ lines of duplication. Add tests.

### T-0070
- Title: Split battler.gd into damage calculator, resonance controller, and status manager
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battler.gd (518 lines)
- Notes: 6 distinct responsibilities. Extract: battler_damage.gd (damage formulas), battler_resonance.gd (resonance state transitions), battler_status.gd (status effect tracking). Keep core HP/EE/stats in battler.gd (~200 lines). Must NOT break existing tests.

### T-0071
- Title: Centralize game balance constants into game_balance.gd
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battler.gd (lines 32-50)
- Notes: 27 magic constants hardcoded: RESONANCE_MAX, DEFENSE_SCALING_DIVISOR, HOLLOW_STAT_PENALTY, etc. Create game/systems/game_balance.gd as single source of truth. Enables easy tuning without hunting through battler.gd.

### T-0072
- Title: Create scene_paths.gd for centralized scene path constants
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd, game/scenes/verdant_forest/verdant_forest.gd, game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Each scene script defines own path constants (VERDANT_FOREST_PATH, ROOTHOLLOW_PATH, etc). Duplicated across 3+ files. Create game/constants/scene_paths.gd. Prevents path typos.

### T-0073
- Title: Split roothollow.gd into tilemap, dialogue, and quest handler modules
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd (985 lines)
- Notes: Largest file. Combines tilemap building, NPC dialogue trees, NPC management, flag-driven dialogue. Extract: roothollow_tilemap.gd, roothollow_dialogue.gd, roothollow_quests.gd. Main becomes orchestrator (~200 lines).

### T-0074
- Title: Split battle_ui.gd into composable panel components
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: T-0069
- Refs: game/ui/battle_ui/battle_ui.gd (570 lines)
- Notes: Extract: battle_command_menu.gd, battle_party_display.gd, battle_target_selector.gd, battle_log_display.gd. Each becomes a scene component.

### T-0075
- Title: Split inventory_ui.gd into category manager, detail panel, and applicator
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: T-0069
- Refs: game/ui/inventory_ui/inventory_ui.gd (658 lines)
- Notes: Extract: inventory_category_filter.gd, inventory_detail_panel.gd, inventory_item_applicator.gd. Main composes these components.

### T-0076
- Title: Split shop_ui.gd into buy panel, sell panel, and character selector
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: T-0069
- Refs: game/ui/shop_ui/shop_ui.gd (522 lines)
- Notes: Extract buy mode into shop_buy_panel.gd, sell mode into shop_sell_panel.gd, character selection into shop_character_selector.gd.

### T-0077
- Title: Split verdant_forest.gd and overgrown_ruins.gd into tilemap/encounter/dialogue modules
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0073
- Refs: game/scenes/verdant_forest/verdant_forest.gd (381 lines), game/scenes/overgrown_ruins/overgrown_ruins.gd (377 lines)
- Notes: Same pattern as roothollow. Lower priority since <400 lines.

### T-0078
- Title: Create reusable asset loader helper with consistent null-check pattern
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/party_manager.gd, game/scenes/roothollow/roothollow.gd
- Notes: load() calls scattered with inconsistent error handling. Create game/systems/asset_loader.gd with static method that always null-checks and logs descriptive errors.

---

### Story & Narrative — Script Alignment

### T-0079
- Title: Expand opening sequence to match Chapter 1 story script
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/events/opening_sequence.gd, docs/story/act1/chapter-01-the-collector.md
- Notes: Current opening is 6 lines. Chapter 1 script has 650+ words. Expand to 20-30 lines: Kael's internal thoughts, familiarity with ruins, Lyra's first voice, his shock. Reference story script for dialogue and emotional beats.

### T-0080
- Title: Expand Lyra discovery dialogue to match story script (~50 lines)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: T-0079
- Refs: game/events/opening_sequence.gd, docs/story/act1/chapter-02-a-voice-in-the-crystal.md
- Notes: Lyra's introduction is minimal. Chapter 2 has extensive dialogue: confusion about consciousness, fragmented memories, Kael's conflicted response. Expand post-discovery sequence with 30-50 lines.

### T-0081
- Title: Expand Iris recruitment to match Chapter 3 story script
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/events/iris_recruitment.gd, docs/story/act1/chapter-03-the-deserter.md
- Notes: Current: pre-battle (1 line) + post-battle (2 lines). Chapter 3 has: Initiative confrontation, Iris's backstory, chase sequence, decision to desert. Expand to 15-25 lines.

### T-0082
- Title: Expand Garrick recruitment to match story script
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/events/garrick_recruitment.gd, docs/story/act1/chapter-03-the-deserter.md
- Notes: Expand with 10-20 lines capturing his gruff, guilt-laden character voice. Backstory as penitent knight, reasons for being at shrine, reluctant agreement to join.

### T-0083
- Title: Update Roothollow NPC dialogue to match story scripts and style guide
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd, docs/story/camp-scenes/npc-dialogue.md, docs/story/STYLE_GUIDE.md
- Notes: Cross-reference NPC lines against npc-dialogue.md. Apply voice patterns from STYLE_GUIDE.md (regional slang, character-specific speech). Ensure flag states match correctly.

### T-0084
- Title: Add companion follower sprites in overworld
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/entities/player/player.gd, game/autoloads/party_manager.gd
- Notes: After recruiting party members, they only appear in party menu — not visible in overworld. Add follower sprites trailing behind player (delayed movement). AnimatedSprite2D with walk sprite system. Show/hide based on PartyManager roster. Breadcrumb trail of recent player positions.

### T-0085
- Title: Implement Chapter 4 content — Garrick's deeper story at the shrine
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: T-0082
- Refs: docs/story/act1/chapter-04-fragments-of-tomorrow.md
- Notes: After Garrick recruitment, continue with deeper character introductions and first fragment quest. Shrine scene dialogue, bonding moments, narrative hook driving party forward.

### T-0086
- Title: Add demo ending sequence with "Thanks for playing" screen
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: T-0085
- Refs: game/events/, game/ui/title_screen/
- Notes: After demo content complete: "Thanks for playing" screen, party portrait lineup, playtime display, hint at full game. Option to return to title. Replace Elder Thessa conclusion with cinematic ending.

---

### Visual Markers & Player Navigation

### T-0087
- Title: Add on-screen objective tracker UI
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/ui/hud/hud.gd, game/autoloads/quest_manager.gd
- Notes: Small HUD panel (top-right) showing current active quest name and objective text. Auto-update on quest progress. Toggle visibility. Pull from QuestManager. 2-3 lines max.

### T-0088
- Title: Add visual markers for zone transitions (sparkle/arrow effects)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.tscn, game/scenes/verdant_forest/verdant_forest.tscn, game/scenes/overgrown_ruins/overgrown_ruins.tscn
- Notes: Zone exits are invisible. Add animated arrows, particle sparkles, or glowing borders at each exit. AnimatedSprite2D or GPUParticles2D. Include label like "To Verdant Forest ->".

### T-0089
- Title: Add NPC interaction indicators (speech bubble icon above head)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/entities/npc/npc.gd, game/entities/interactable/interactable.gd
- Notes: No visual indicator that NPCs are interactable. Add floating speech bubble / "!" for quests / "?" for info above NPC heads when player in range. Different icons for: quest available, quest in progress, shop, general chat.

### T-0090
- Title: Add quest log/journal UI screen
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/quest_manager.gd, docs/best-practices/08-ui-patterns.md
- Notes: QuestManager tracks quests but no UI to view them. Quest log from pause menu: active quests with objectives + completion, completed quests (grayed), descriptions, reward previews. VBoxContainer + ScrollContainer. Focus nav.

### T-0091
- Title: Add area name display on zone transitions
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/game_manager.gd, game/ui/hud/hud.gd
- Notes: Display area name prominently for 2-3s on entering new zone (centered, large text, fade-in/fade-out). Triggered by GameManager after scene change. Tween animation.

### T-0092
- Title: Add tutorial hints for controls on first playthrough
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/event_flags.gd, game/ui/dialogue/dialogue_box.gd
- Notes: Contextual tutorial popups on first occurrence: "Press [interact] to talk", "Press [cancel] for pause menu", "Walk into glowing area to travel." Use EventFlags for show-once. Non-intrusive, any-key dismiss.

### T-0093
- Title: Add fragment tracker / compass UI for story objectives
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0087
- Refs: docs/story/act1/chapter-02-a-voice-in-the-crystal.md, game/ui/hud/hud.gd
- Notes: Story describes fragment tracker that pulses toward objectives. Small HUD crystal icon with directional arrow. Could simplify to pulsing when near objective. Lower priority — text tracker may suffice.

---

### Demo Completeness

### T-0094
- Title: Implement battle ability animations and visual effects
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/action_execute_state.gd, game/resources/ability_data.gd
- Notes: No VFX when abilities used. Add per-element effects: fire (orange particles), ice (blue), healing (green), physical (slash). AnimatedSprite2D or GPUParticles2D. Link to AbilityData.element. Check pixel_animations_gfxpack.

### T-0095
- Title: Add battler idle animations in combat
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/entities/battle/party_battler_scene.gd, game/entities/battle/enemy_battler_scene.gd
- Notes: Sprites static during combat. Add idle bob (sine wave Y, 2px amplitude, 2s period). Different phases per battler. Attack animation: quick lunge (4px, 0.15s). Hit animation: red flash (modulate tween).

### T-0096
- Title: Add particle effects for healing, resonance, and criticals
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0094
- Notes: Healing aura, resonance overload energy, critical hit star burst, status effect mist. GPUParticles2D. Reusable particle scenes.

### T-0097
- Title: Add save point visual markers in scenes
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/entities/interactable/strategies/save_point_strategy.gd
- Notes: Save points have no distinctive visual. Add glowing crystal sprite or shimmering pillar. AnimatedSprite2D with slow pulse. Visually distinct from other interactables.

### T-0098
- Title: Add overworld encounter warning (grass rustle before battle)
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/systems/encounter/encounter_system.gd
- Notes: Random encounters trigger without warning. Add 0.5s warning: screen edge flash, grass rustle particles, or camera zoom. Audio cue if SFX available.

### T-0099
- Title: Add transition animations between zones (beyond fade)
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/game_manager.gd
- Notes: Currently only fade-to-black. Add variety: slide transitions, iris wipe for dungeons, screen shatter for boss encounters. TransitionEffect scene with multiple types.

---

### Polish & Quality of Life

### T-0100
- Title: Add NPC idle animations (breathing, head turn, fidget)
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/entities/npc/npc.gd
- Notes: NPCs are static sprites. Add subtle breathing (scale Y oscillation), head turn, fidget. AnimationPlayer or Tween. Check npc-animations pack for animated sprites.

### T-0101
- Title: Implement party formation and swap UI in pause menu
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: T-0020
- Refs: game/ui/pause_menu/pause_menu.gd, game/autoloads/party_manager.gd
- Notes: Pause menu lacks party management. View all members with stats/equipment, swap positions, character detail view. Reuse patterns from inventory_ui. Focus navigation.

### T-0102
- Title: Add minimap or compass to HUD
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/hud/hud.gd
- Notes: No minimap/compass. Start with compass (simpler), upgrade to minimap later. Low priority for 3-scene demo.

### T-0159
- Title: Fix Verdant Forest south canopy gap — extend AbovePlayer layer to rows 15-24
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/verdant_forest/verdant_forest.gd (CANOPY_MAP), docs/best-practices/11-tilemaps-and-level-design.md
- Notes: CANOPY_MAP has no entries in rows 15-24. The south forest has TREE_MAP tiles and TRUNK_MAP trunk placements (rows 17-23) but no AbovePlayer canopy overlay — breaking the walk-under depth effect that works in the north half. Extend CANOPY_MAP with 2x2 canopy tiles above each south-half trunk position using existing CANOPY_LEGEND keys. Run /scene-preview --full-map after. 2+ tests verifying south rows have non-empty CANOPY_MAP data.

### T-0160
- Title: Wire quest-NPC indicator refresh on QuestManager signals
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0089, T-0090
- Refs: game/scenes/roothollow/roothollow.gd, game/autoloads/quest_manager.gd, game/entities/npc/npc.gd
- Notes: Supersedes T-0112. NPC indicator_type computed once at scene load; quest progress while in scene doesn't refresh indicators. Connect QuestManager.quest_accepted, quest_progressed, quest_completed signals to re-evaluate NPC indicators in roothollow.gd. Static compute_npc_indicator_type(npc_id) helper for TDD. 4+ tests.

### T-0156
- Title: Verify and wire enemy crit attacks through ActionExecute state
- Status: superseded
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0143
- Refs: game/systems/battle/states/enemy_turn_state.gd, game/systems/battle/states/action_execute_state.gd
- Notes: T-0143 added crit rolls in _execute_attack() inside ActionExecuteState. Confirm whether EnemyTurnState routes through ActionExecute (if so, crits already apply to enemies). If enemies use a separate execution path, wire BattlerDamage.roll_crit(attacker.luck) + apply_crit() there. 3+ tests verifying enemy crit chance matches the 5%+luck*0.5% formula.

### T-0158
- Title: Add hit flash animation on battler sprites when taking damage
- Status: done
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/entities/battle/party_battler_scene.gd, game/entities/battle/enemy_battler_scene.gd
- Notes: SUPERSEDED — play_damage_anim() already implements white+red flash with position recoil shake in both battler scenes, wired to _on_damage_taken() via battler.damage_taken signal. Functionality fully present.

### T-0180
- Title: Place campfire interactable in Verdant Forest
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: T-0023
- Refs: game/scenes/verdant_forest/verdant_forest.gd, game/entities/interactable/strategies/camp_strategy.gd
- Notes: T-0023 completed CampStrategy but placed no campfire in any scene. Add a campfire Interactable in the Verdant Forest clearing (mid-map, off the path). Wire CampStrategy as its strategy. one_time=false so it is usable repeatedly. Acceptance: player can interact with campfire to open CampMenu (Rest + Leave Camp). 3+ tests verifying campfire is present and CampStrategy wired correctly.

### T-0181
- Title: M0 hygiene sweep — type hints, return types, and doc comments in autoloads and core scripts
- Status: done
- Assigned: claude
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/, game/systems/battle/battler.gd, game/systems/battle/battle_scene.gd
- Notes: Combines T-0008, T-0010, T-0011. Single targeted sweep: (1) Replace has_method/has_signal duck-typing with typed references. (2) Add return type annotations on methods missing them. (3) Add doc comments to public signals and methods in autoloads and battle scripts. Run gdlint to verify no new warnings. No behavior changes — pure code quality. 0 new tests required (existing 1536 must stay green).

### T-0228
- Title: Test cleanup — delete constant-value, enum-ordinal, and has_signal/has_method assertions
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/tests/unit/systems/battle/test_critical_hit.gd, game/tests/unit/resources/test_enemy_data.gd, game/tests/unit/resources/test_character_data.gd, game/tests/unit/events/test_garrick_recruitment.gd, game/tests/unit/events/test_opening_sequence.gd, game/tests/unit/autoloads/test_audio_manager_volume.gd
- Notes: Delete tests that only assert a constant/enum equals its hardcoded literal (e.g. `assert_eq(GameBalance.CRIT_BASE_CHANCE, 0.05)`), or just check default field values on a freshly constructed Resource (e.g. `assert_eq(c.max_hp, 100)`), or use `has_signal()`/`has_method()` reflection (e.g. `test_has_sequence_completed_signal`). These tests verify the GDScript interpreter, not game behavior — they always pass unless the constant itself changes, in which case the fix is trivial. Affected patterns: test_critical_hit.gd (3 constant tests), test_enemy_data.gd (ai_type/element enum ordinal tests), test_character_data.gd (default field tests), test_garrick_recruitment.gd (path constants, has_signal, has_method), test_opening_sequence.gd (path constants, has_signal, has_method), and any similar tests found across the suite. Expected reduction: ~80-100 tests.

### T-0229
- Title: Test cleanup — slim event dialogue tests to contract and logic only
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: T-0228
- Refs: game/tests/unit/events/
- Notes: Event test files (test_opening_sequence.gd, test_garrick_recruitment.gd, test_iris_recruitment.gd, test_garrick_meets_lyra.gd, test_garrick_night_scene.gd, test_camp_three_fires.gd, test_after_capital_camp.gd, test_leaving_capital.gd, test_last_gardener_encounter.gd, test_nyx_introduction.gd, test_demo_ending.gd, test_boss_encounter.gd) each have 8-12 tests that assert: exact speaker at position 0 or -1, exact speaker count, exact line count, or whether a specific keyword appears in dialogue text. These fail on any dialogue edit and provide no behavioral signal. Delete them. Keep only: non-empty array check, conditional helper logic (e.g. compute_should_auto_accept_*), and signal contracts that verify actual game mechanics. Expected reduction: ~100-120 tests.

### T-0230
- Title: Test cleanup — slim NPC scene dialogue tests to flag-routing only
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: T-0228
- Refs: game/tests/unit/scenes/test_roothollow_dialogue.gd, game/tests/unit/scenes/test_verdant_forest_dialogue.gd, game/tests/unit/scenes/test_roothollow_quests.gd
- Notes: test_roothollow_dialogue.gd is 591 lines covering 6 NPCs across 4 flag states each. Most tests assert: `lines.size() == N` (exact count per flag state) and `lines[0].contains("specific phrase")` (exact text). These break on any dialogue edit. The valuable tests are: flag priority ordering (garrick > iris > lyra), slang verification (all states use Tangle slang), and routing changes (flag X produces different dialogue than flag Y). Delete line-count and exact-text assertions. Keep routing and meta-behavioral tests. Apply same pattern to verdant_forest_dialogue.gd and any similar file. Expected reduction: ~80-100 tests.

### T-0231
- Title: Test cleanup — consolidate fragmented audio manager test files
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/tests/unit/autoloads/test_audio_manager_pause.gd, game/tests/unit/autoloads/test_audio_manager_stack.gd, game/tests/unit/autoloads/test_audio_manager_volume.gd, game/tests/unit/autoloads/test_audio_manager_sfx_priority.gd
- Notes: AudioManager is tested across 4 separate files (pause, stack, volume, sfx_priority) plus test_battle_manager_bgm.gd. Merge into a single test_audio_manager.gd. During the merge, audit each test: delete pure constant assertions (see T-0228), keep behavioral tests (volume persists across plays, stack push/pop restores BGM, process_mode_always invariant). Expected: net reduction of ~15-20 tests from duplicates and constant assertions, plus cleaner organization.

### T-0232
- Title: Test cleanup — remove playtest infrastructure tests that duplicate production behavior
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/tests/unit/systems/test_playtest_actions.gd, game/tests/unit/systems/test_playtest_capture.gd, game/tests/unit/systems/test_playtest_config.gd
- Notes: The playtest runner has 74 tests across 3 files (actions=36, capture=17, config=21 approx). Audit each: delete tests that only assert a constant action name equals a string literal, or that a dictionary key exists, or default config values. Keep tests that verify validation logic (invalid actions rejected, required fields caught), merging behavior (CLI args override defaults), and filename generation logic. Expected reduction: ~25-35 tests.

### T-0233
- Title: Code health — fix remaining gdlint violations
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/entities/interactable/interaction_strategy.gd, game/tests/unit/systems/battle/test_status_icons.gd
- Notes: Two categories. (1) interaction_strategy.gd:8 — `execute(owner: Node)` is a virtual method base stub; `owner` is used in the signature for subclass contract but not in the body. gdlint flags it as unused-argument. Fix: rename parameter to `_owner` (underscore prefix is the GDScript convention for intentionally unused params). (2) test_status_icons.gd:225,237,249 — three lambda filter lines exceed 100-char limit. Break each onto two lines. No behavior change. After fix, gdlint must show 0 new violations in non-addon game code.

### T-0234
- Title: Code health — remove dead legacy wrapper methods from Battler
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battler.gd, game/tests/unit/systems/battle/test_battle_actions.gd, game/tests/unit/systems/battle/test_status_icons.gd, game/tests/unit/systems/battle/test_status_effects.gd, game/tests/unit/systems/battle/test_battle_state_persistence.gd
- Notes: battler.gd has 4 dead methods: `apply_status_effect(effect: StringName)` (wraps `apply_status`), `remove_status_effect(effect: StringName)` (wraps `remove_status`), `has_status_effect(effect: StringName)` (wraps `has_status`), and `check_resonance_state()` (trivial getter returning `resonance_state` directly, zero callers). The three `*_status_effect` wrappers are called in test files only — migrate those test call sites to the canonical `apply_status`/`remove_status`/`has_status` API. Then delete all four methods from battler.gd. No behavior change. All existing tests must remain green after migration.

### T-0235
- Title: Code health — eliminate ScenePaths duplication in game_manager.gd
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/game_manager.gd, game/systems/scene_paths.gd
- Notes: `compute_transition_type()` in game_manager.gd (lines 54-67) declares three local `const` strings — ROOTHOLLOW, VERDANT_FOREST, OVERGROWN_RUINS — that are exact duplicates of constants already defined in `ScenePaths`. Replace the local consts with `ScenePaths.ROOTHOLLOW`, `ScenePaths.VERDANT_FOREST`, and `ScenePaths.OVERGROWN_RUINS`. Also replace `Color(0.0, 0.0, 0.0, 0.0)` with `Color.TRANSPARENT` and `Color(0.0, 0.0, 0.0, 1.0)` with `Color.BLACK` in `_setup_transition_layer()`. No behavior change. Existing tests must remain green.

### T-0236
- Title: Code health — add resonance-state color constants to UITheme; replace magic Color values in battle_ui.gd
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/ui/ui_theme.gd, game/ui/battle_ui/battle_ui.gd
- Notes: `update_resonance()` in battle_ui.gd uses 8 inline `Color()` literals (fill + text for each of FOCUSED/RESONANT/OVERLOAD/HOLLOW states). These should be named constants in UITheme. Add: `RESONANCE_FOCUSED_BAR`, `RESONANCE_FOCUSED_TEXT`, `RESONANCE_RESONANT_BAR`, `RESONANCE_RESONANT_TEXT`, `RESONANCE_OVERLOAD_BAR`, `RESONANCE_OVERLOAD_TEXT`, `RESONANCE_HOLLOW_BAR`, `RESONANCE_HOLLOW_TEXT`. Also add `BATTLE_PANEL_INNER_BG := Color(0.06, 0.06, 0.12, 0.7)` for the inner submenu panels. Update battle_ui.gd to use all new constants. No behavior change. No new tests required — existing battle UI tests must remain green.

### T-0237
- Title: Code health — consolidate AudioManager crossfade duplication
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd

### T-0238
- Title: Code health — break down enemy_turn_state.enter() 130-line god method
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/enemy_turn_state.gd

### T-0239
- Title: Code health — deduplicate battle_scene._spawn_party and _spawn_enemies
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battle_scene.gd
- Notes: `_spawn_party()` (lines 105-130) and `_spawn_enemies()` (lines 132-155) share 15+ identical lines: iterate data array, create battler, initialize_from_data, connect signals, instantiate visual scene, bind visual to logic, add to node. Extract `_spawn_battlers(data_array: Array, battler_class: GDScript, scene_class: PackedScene, parent: Node, is_enemy: bool) -> Array[Battler]` and call it from both methods. No behavior change.

### T-0240
- Title: Code health — extract equipment_manager.gd SLOT_KEYS constant
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/equipment_manager.gd

### T-0241
- Title: Code health — split quest_manager.deserialize() into focused helpers
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/quest_manager.gd

### T-0242
- Title: Code health — extract pause_menu.gd open/close subscene boilerplate
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/ui/pause_menu/pause_menu.gd

### T-0243
- Title: Code health — extract hud.gd duplicate popup setup functions
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/ui/hud/hud.gd
- Notes: hud.gd has 6 near-identical popup setup blocks (lines 339-357, 376-395, 397-415, 450-467, 491-506, 509-526). Each creates a Label, sets font_size/color/alignment/position, and returns it. Extract `_create_popup_label(text: String, font_size: int, color: Color, position: Vector2) -> Label` that all 6 callers use. No behavior change.

### T-0244
- Title: Code health — create EventFlagRegistry for magic flag string constants
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/events/event_flags.gd, game/events/opening_sequence.gd, game/events/boss_encounter.gd, game/events/garrick_recruitment.gd, game/events/iris_recruitment.gd, game/events/nyx_introduction.gd, game/events/last_gardener_encounter.gd, game/events/leaving_capital.gd, game/events/after_capital_camp.gd, game/events/camp_three_fires.gd, game/events/garrick_night_scene.gd, game/events/garrick_meets_lyra.gd, game/events/demo_ending.gd, game/scenes/roothollow/roothollow.gd
- Notes: Every event script and some scene scripts define a local `FLAG_NAME` const or use flag strings inline. Create `game/events/event_flag_registry.gd` (`class_name EventFlagRegistry`) with all flag name constants (e.g., `const OPENING_LYRA_DISCOVERED := "opening_lyra_discovered"`, `const GARRICK_RECRUITED := "garrick_recruited"`, etc.). Audit all usages of `EventFlags.has_flag(...)` / `EventFlags.set_flag(...)` across event and scene scripts; replace string literals with `EventFlagRegistry.*`. No behavior change — only string constant extraction.

### T-0245
- Title: Code health — add BattleActionExecutor to deduplicate attack/ability execution between states
- Status: done
- Completed: 2026-02-20
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: T-0238
- Refs: game/systems/battle/states/action_execute_state.gd, game/systems/battle/states/enemy_turn_state.gd
- Notes: `_execute_attack()` in action_execute_state.gd and the attack block in enemy_turn_state.gd share ~50 lines of copy-paste (crit roll, damage call, sound, UI log, anim). `_execute_ability()` and its enemy counterpart share another ~50 lines. StatusEffectData creation appears in both files identically. Extract a static `BattleActionExecutor` class (game/systems/battle/battle_action_executor.gd) with: `static func execute_attack(attacker, target, scene) -> void` and `static func execute_ability(attacker, ability, target, scene) -> void`. Both states call these. No behavior change. Existing battle tests must remain green.

### T-0246
- Title: Reconcile BACKLOG.md — sync done/todo statuses for completed sprint tasks
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: high
- Milestone: M0
- Depends: none
- Notes: Updated 43 tasks from todo→done (T-0228–T-0245 code health sprint, T-0191–T-0225 M1 sprint completions, T-0248 Nyx recruitment). Pure documentation update, 0 behavior changes.

---

## M1 — Act I: The Echo Thief

### T-0103
- Title: Implement Chapter 5 — The Overgrown Capital dungeon
- Status: superseded
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0085
- Refs: docs/story/act1/chapter-05-overgrown-capital.md, docs/game-design/05-dungeon-designs.md
- Notes: Superseded by T-0190 (tilemap skeleton), T-0191 (Lyra Fragment 2 + vision), T-0192 (Last Gardener), T-0193 (post-dungeon camp), T-0194 (Story Echo .tres), T-0195 (Purification Node). Work against those sub-tasks instead.

### T-0247
- Title: Verify and wire Nyx introduction trigger zone in Verdant Forest
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: high
- Milestone: M1
- Depends: T-0225, T-0191
- Notes: T-0225 created NyxIntroduction event and tests. Verdant_forest.gd already has _maybe_trigger_nyx_introduction() wired via call_deferred in _ready(). Trigger gates on compute_can_trigger(flags) which requires garrick_recruited + lyra_fragment_2_collected + NOT nyx_introduction_seen. DONE — already implemented.

### T-0248
- Title: Recruit Nyx into party — create nyx.tres and wire PartyManager.add_character() after introduction
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0225, T-0247
- Refs: game/events/nyx_introduction.gd, game/data/characters/, docs/lore/03-characters.md
- Notes: nyx.tres CharacterData does not exist. Create game/data/characters/nyx.tres (CharacterData: id="nyx", display_name="Nyx", level 5, stats per lore doc — element DARKNESS). NyxIntroduction.trigger() should call PartyManager.add_character() at end of dialogue. compute_nyx_character_data() static helper returns resource path. Set nyx_recruited flag. 5+ tests verifying nyx.tres loads, has correct stats, and party add is called.

### T-0249
- Title: Chapter 7 "A Village Burns" story event scaffold
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Milestone: M1
- Depends: T-0191, T-0248
- Refs: docs/story/act1/07-a-village-burns.md, game/events/
- Notes: docs/story/act1/07-a-village-burns.md has a complete chapter script. Create game/events/village_burns.gd implementing Scenes 1-2 (~20-25 lines). Gate on lyra_fragment_2_collected AND nyx_met AND NOT village_burns_seen. VillageBurns.compute_can_trigger(flags) static helper. Set village_burns_seen flag. 5+ tests.

### T-0104
- Title: Implement Chapters 6-10 story events and dialogue
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: high
- Milestone: M1
- Depends: T-0248, T-0249
- Refs: docs/story/act1/
- Notes: Remaining Act I chapters. New areas, character development, faction conflicts. Updated dependency from T-0103 (superseded) to T-0248+T-0249.

### T-0105
- Title: Build Prismfall Approach area
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: high
- Milestone: M1
- Depends: T-0248
- Refs: docs/game-design/03-world-map-and-locations.md, docs/story/act1/08-the-crystal-city.md
- Notes: New overworld area (Crystalline Steppes approach to Prismfall). Tilemap (crystal formations, steppes terrain), encounters, NPCs, transitions from Verdant Forest → Prismfall. Updated dependency from T-0103 (superseded) to T-0248.

### T-0106
- Title: Implement Echo Fragment collection system
- Status: superseded
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: none
- Refs: docs/lore/04-echo-catalog.md, docs/game-design/01-core-mechanics.md
- Notes: Superseded by T-0182 (EchoManager autoload), T-0189 (SaveManager wiring), T-0187 (Journal UI). The full Echo collection pipeline is complete.

### T-0107
- Title: Implement full character ability trees for all party members
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0018
- Refs: docs/mechanics/character-abilities.md
- Notes: 8 characters x 10-15 abilities = 80-120 definitions.

### T-0108
- Title: Build faction reputation system
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: none
- Refs: docs/game-design/04-side-quests.md, docs/lore/01-world-overview.md
- Notes: Track reputation with Shepherds, Initiative, factions. Affects dialogue, prices, quest availability.

### T-0109
- Title: Add weather and time-of-day visual system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: none
- Refs: docs/game-design/06-audio-design.md
- Notes: Day/night cycle, weather effects. CanvasModulate for lighting, GPUParticles2D for weather.

### T-0110
- Title: Implement crafting system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0012
- Refs: docs/game-design/01-core-mechanics.md
- Notes: Combine materials into items. Recipe system, crafting UI, material gathering.

### T-0150
- Title: Add Garrick character quest scaffold — QuestData .tres and quest hook
- Status: superseded
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0082
- Notes: SUPERSEDED by T-0173 (completed 2026-02-20) which created the QuestData .tres and auto-accept helper for Garrick's "Something He Carries" quest stub.

### T-0151
- Title: Add Iris character quest scaffold — QuestData .tres and quest hook
- Status: superseded
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0081
- Notes: SUPERSEDED by T-0174 (completed 2026-02-20) which created the QuestData .tres and auto-accept helper for Iris's "The Engineer's Oath" quest stub.

### T-0182
- Title: Implement EchoFragment Resource and EchoManager autoload — core collection system
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: none
- Refs: docs/lore/04-echo-catalog.md, docs/game-design/01-core-mechanics.md, game/resources/, game/autoloads/
- Notes: Core M1 mechanic. EchoFragment Resource (id, display_name, lore_text, rarity enum, echo_type enum). EchoManager autoload: collect_echo(id), has_echo(id), get_collected_echoes(), save/load integration via SaveManager. Place 2-3 Act I story echo .tres files in game/data/echoes/. Wire MemorialEchoStrategy to collect echo on activation. echo_collected signal. HUD: echo count badge (small, top-left). 10+ tests covering collect, duplicate prevention, save/load round-trip.

### T-0183
- Title: Build Prismfall Approach overworld scene — ruined road connecting forest to Capital
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0103
- Refs: docs/game-design/03-world-map-and-locations.md, docs/game-design/05-dungeon-designs.md, docs/story/act1/05-into-the-capital.md
- Notes: New overworld area. Ruined approach road with crystallized vegetation. 40x25 tilemap using Fairy Forest A5_A + Ruins A5 accent tiles. 4-5 enemy encounter pool (harder than Verdant Forest). Two exit triggers: south to OvergrownRuins, north to OvgrCapitalDungeon (stub). At least 2 NPCs with lore flavor. Standard module split (PrismfallMap + PrismfallEncounters). Visual verification with /scene-preview --full-map required. 8+ tests.

### T-0184
- Title: Seed ability tree .tres files for all 8 party members
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: high
- Milestone: M1
- Depends: T-0018
- Refs: docs/mechanics/character-abilities.md, game/data/characters/, game/data/abilities/
- Notes: T-0018 built the SkillTreeData framework. Create game/data/skill_trees/<char_id>_tree.tres for: kael, iris, garrick, lyra + serana, maren, dane, theron. Each tree: 8-10 SkillTreeNodeData nodes per docs/mechanics/character-abilities.md. Wire into CharacterData.skill_trees. 6+ tests verifying tree structure for at least 2 characters.

### T-0112
- Title: Wire quest-NPC indicator updates on quest state change
- Status: done
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0089
- Refs: game/scenes/roothollow/roothollow.gd, game/autoloads/quest_manager.gd
- Notes: SUPERSEDED by T-0160 (more specific, M0-scoped, includes TDD plan). T-0160 covers the same scope with explicit signal connections and static helper for testability.

### T-0113
- Title: Add interaction prompt label near player when ray hits target
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0089
- Refs: game/entities/player/player.gd, game/ui/hud/hud.gd
- Notes: Small HUD hint ("[E] Talk") when player InteractionRay detects target. May overlap with T-0092 (tutorial hints).

### T-0115
- Title: BUG — Pause menu party panel shows max HP/EE instead of current HP/EE
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/ui/pause_menu/pause_menu.gd
- Notes: _create_member_info() reads member.max_hp and displays both values as max. Should read PartyManager runtime HP/EE state. Visible bug for demo players.

### T-0116
- Title: Disable or stub Settings button on title screen
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/ui/title_screen/title_screen.gd
- Notes: Resolved by T-0068 — settings menu is fully implemented.

### T-0117
- Title: Implement BGM stack in AudioManager for battle music restore
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/autoloads/battle_manager.gd
- Notes: push_bgm()/pop_bgm() stack to save/restore overworld music across battle transitions. Required for T-0064 to work end-to-end.

### T-0122
- Title: Add AudioBus volume persistence — save/restore BGM+SFX volumes across sessions
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: T-0068
- Refs: game/autoloads/audio_manager.gd
- Notes: Superseded by T-0068 — SettingsData persists BGM/SFX/Master volumes to user://settings.json.

### T-0123
- Title: BUG — Overworld BGM restore timing after battle may produce audio glitch
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/battle_manager.gd, game/autoloads/audio_manager.gd
- Notes: Resolved by T-0117 — push_bgm()/pop_bgm() stack cleanly saves and restores overworld BGM across battle transitions.

### T-0124
- Title: BUG — XP computed and displayed in victory screen but never applied to party members
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/victory_state.gd, game/systems/progression/level_manager.gd
- Notes: victory_state.gd computes total_exp and passes to show_victory() for display only. No call to LevelManager.add_xp() exists. Characters never level up. Fix: iterate party data, call add_xp(), log level-ups.

### T-0127
- Title: Add playtime display to save/load screen
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/save_manager.gd, game/ui/title_screen/title_screen.gd
- Notes: Save slots show no playtime. SaveManager serializes a timestamp field. Compute elapsed hours:minutes and display in each slot label. Acceptance: each save slot shows "XX:XX" playtime alongside location name. 4+ tests.

### T-0130
- Title: Add live playtime accumulation to GameManager for save slot display
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/game_manager.gd, game/autoloads/save_manager.gd
- Notes: SaveManager accepts playtime param but nothing accumulates it. Add playtime_seconds to GameManager, increment in _process during OVERWORLD/MENU. Wire into save calls. Prerequisite for T-0127. 4+ tests.

### T-0132
- Title: Add "Defend" status badge on party battler panels during combat
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd, game/systems/battle/battler.gd
- Notes: Battler.is_defending is tracked but the battle UI shows no visual indicator. Add a "DEF" badge (similar to status effect badges from T-0054) that appears when is_defending is true. Reuse UITheme.get_status_color() pattern. 3+ tests.

### T-0133
- Title: Add save slot summary (location + timestamp) on Continue button
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/title_screen/title_screen.gd, game/autoloads/save_manager.gd
- Notes: Continue button shows no save context. Add a label showing saved scene name and timestamp. Use compute_area_display_name() for location. 3+ tests.

### T-0138
- Title: Add scrollable battle log with history
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd
- Notes: Battle log currently shows fixed lines with oldest pushed off. Add ScrollContainer wrapping RichTextLabel. Auto-scroll to bottom on new entry. 3+ tests.

### T-0139
- Title: Source SFX assets from Time Fantasy packs for UI and combat
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, docs/game-design/06-audio-design.md
- Notes: T-0066 and T-0067 require SFX files to exist. Search /Users/robles/repos/games/assets/ for WAV/OGG SFX in Time Fantasy packs. Copy to game/assets/sfx/ui/ and game/assets/sfx/combat/ using /copy-assets workflow. Minimum set — UI: confirm, cancel, menu-open, dialogue-advance. Combat: attack-hit, magic-cast, heal-chime, death, critical-hit, status-apply. All files need .import entries. 3+ tests verifying load paths.

### T-0140
- Title: Refactor AudioManager to support named SFX channels with priority
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0139
- Refs: game/autoloads/audio_manager.gd
- Notes: Current round-robin SFX pool has no priority system. Add SfxPriority enum (CRITICAL, NORMAL, AMBIENT). Critical sounds (combat hits, death) always claim next free player. Ambient sounds skip if all pool players are busy. 5+ tests.

### T-0141
- Title: Add accessibility tooltips and keyboard shortcut hints to settings menu
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0068
- Refs: game/ui/settings_menu/settings_menu.gd, docs/game-design/06-audio-design.md
- Notes: Add tooltip text on each slider explaining what it controls, keyboard left/right arrow hint label, and reset-to-default button per slider. 3+ tests for compute_slider_tooltip() static function.

### T-0144
- Title: Build playtest runner — core scene with state injection and screenshot capture
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: critical
- Milestone: M0
- Depends: none
- Refs: docs/game-design/09-playtest-runner.md, game/tools/scene_preview.gd
- **RESERVED: This ticket is part of the playtest runner feature (T-0144..T-0147). Skip this and pick another task unless you were specifically assigned to implement the playtest runner.**
- Notes: Phase 1 of playtest runner. Create playtest_runner.tscn/gd in game/tools/. JSON config parsing (--config=) + inline CLI arg fallback. State injection: party (PartyManager.add_character), flags (EventFlags.set_flag), inventory (InventoryManager.add_item), gold. Scene navigation via GameManager.change_scene(). Basic actions: wait, screenshot, move (via InputEventAction). Report JSON output (screenshots, errors, final state). Timeout safety exit. Update game/tools/CLAUDE.md.

### T-0145
- Title: Add full action set to playtest runner (dialogue, battle, input simulation)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: critical
- Milestone: M0
- Depends: T-0144
- Refs: docs/game-design/09-playtest-runner.md
- **RESERVED: This ticket is part of the playtest runner feature (T-0144..T-0147). Skip this and pick another task unless you were specifically assigned to implement the playtest runner.**
- Notes: Phase 2 of playtest runner. Input simulation via Input.parse_input_event(): interact, cancel, menu. Dialogue actions: advance_dialogue, wait_dialogue (await DialogueManager.is_active() == false), select_choice. Battle actions: trigger_battle (BattleManager.start_battle), wait_battle. State actions: wait_state, set_flag, log. Equipment injection (EquipmentManager.equip). Quest injection (QuestManager.accept_quest). Error collection via push_error monitoring. Periodic screenshot capture (capture_interval_seconds). Auto-screenshot on error (capture_on_error).

### T-0146
- Title: Create /playtest skill and preset configs for common test scenarios
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: high
- Milestone: M0
- Depends: T-0145
- Refs: docs/game-design/09-playtest-runner.md
- **RESERVED: This ticket is part of the playtest runner feature (T-0144..T-0147). Skip this and pick another task unless you were specifically assigned to implement the playtest runner.**
- Notes: Phase 3 of playtest runner. Create /playtest Claude Code skill wrapping Godot CLI invocation. Preset configs in game/tools/playtest_presets/ as JSON files: new_game (empty state, title screen), early_game (kael only, ruins), mid_game (3 party, roothollow), late_game (full party, all flags), battle_test (immediate battle), boss_test (boss encounter), dialogue_test (NPC interaction), full_walkthrough (automated demo playthrough). Inline CLI args: --scene, --party, --flags, --gold, --screenshot-after. Update root CLAUDE.md with /playtest usage and preset docs.

### T-0147
- Title: Add battle auto-play mode to playtest runner for combat balance testing
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Priority: medium
- Milestone: M0
- Depends: T-0145
- Refs: docs/game-design/09-playtest-runner.md
- **RESERVED: This ticket is part of the playtest runner feature (T-0144..T-0147). Skip this and pick another task unless you were specifically assigned to implement the playtest runner.**
- Notes: Phase 4 of playtest runner (optional). AI-driven party actions during playtested battles — auto-select attack on random enemy. Battle outcome logging: victory/defeat, total turns, per-character HP remaining, abilities used, items consumed. Balance data CSV export for tuning. Configurable party AI strategy (aggressive/balanced/defensive). Multiple battle runs for statistical analysis.

### T-0148
- Title: Add camp scene "Three Around a Fire" — Garrick, Iris, Kael evening dialogue
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0085
- Refs: docs/story/act1/04-old-iron.md (Camp Scene), game/events/
- Notes: Camp fire scene where Garrick cooks stew and party plans Overgrown Capital run. Triggers at Roothollow inn after garrick_met_lyra flag. 3 optional camp dialogue snippets (about shield, Kael, Iris). Main tactical-planning sequence ~15 lines. EventFlags gate: camp_scene_three_fires. New event file game/events/camp_three_fires.gd. 5+ tests.

### T-0149
- Title: Add Spring Shrine interactable south of Roothollow — Garrick meeting location
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: T-0082
- Refs: docs/story/act1/04-old-iron.md (Scene 2), game/scenes/roothollow/roothollow.gd
- Notes: Chapter 4 Scene 2 places the Garrick recruitment at a spring shrine south of Roothollow. Add a trigger zone in Roothollow or Verdant Forest scene that activates garrick_recruitment event when approached (after iris_recruited, before garrick_recruited). Shrine should have a glowing crystal interactable. 4+ tests.

### T-0153
- Title: Seed luck stat in CharacterData .tres files for Kael, Iris, Garrick, Lyra
- Status: done
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/data/characters/, game/resources/character_data.gd
- Notes: SUPERSEDED — all four CharacterData .tres files already have non-zero luck values (Kael=10, Iris=8, Garrick=8, Lyra=12) set during Sprint S02 character data creation. These feed directly into BattlerDamage.compute_crit_chance() in T-0143. No code changes needed.

### T-0154
- Title: Add camp/rest trigger zone at Roothollow inn entrance for T-0148 camp event
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0148
- Refs: game/scenes/roothollow/roothollow.gd, game/entities/interactable/strategies/innkeeper_strategy.gd
- Notes: Already implemented — roothollow.gd _on_innkeeper_finished() calls NightEvents.compute_innkeeper_night_event() which auto-triggers CampThreeFires after innkeeper heal when garrick_recruited flag is set. No separate trigger zone needed.

### T-0155
- Title: Wire dismiss prompt text to InputMap for remappable key display
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0129
- Refs: game/ui/battle_ui/battle_ui.gd, game/ui/battle_ui/battle_ui_victory.gd
- Notes: compute_dismiss_prompt_text("interact") uses a static string. Wire to InputMap.action_get_events("interact") to dynamically show the actual key binding. Groundwork for future remapping feature. 2+ tests verifying prompt updates for keyboard vs joypad events.

### T-0176
- Title: Reconcile BACKLOG.md — mark all COMPLETED.md tickets as done
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: high
- Milestone: M0
- Depends: none
- Refs: agents/BACKLOG.md, agents/COMPLETED.md
- Notes: BACKLOG.md still shows ~80 M0 tickets as Status: todo that are confirmed done in COMPLETED.md and SPRINT.md. All completed tickets need their Status updated to done with Completed: date. Pure documentation update, no code changes. Acceptance: every ticket in BACKLOG.md that appears in COMPLETED.md has Status: done.

### T-0177
- Title: Wire SfxPriority.CRITICAL to combat death and crit SFX calls
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Milestone: M0
- Depends: T-0140
- Refs: game/systems/battle/states/action_execute_state.gd, game/systems/battle/states/enemy_turn_state.gd
- Notes: T-0140 added the SfxPriority system but existing play_sfx() calls in combat state scripts still use default NORMAL priority. Death SFX and critical hit SFX should use SfxPriority.CRITICAL so they always play even when 8 ambient/attack sounds are active simultaneously. UI_CONFIRM and ATTACK_HIT remain NORMAL. DEATH and COMBAT_CRITICAL_HIT should be CRITICAL. 4+ tests verifying correct priority is passed per SFX type.

### T-0178
- Title: Add read-only control bindings display to settings menu
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0068
- Refs: game/ui/settings_menu/settings_menu.gd, docs/IMPLEMENTATION_GUIDE.md
- Notes: compute_control_bindings()/compute_action_label()/compute_action_key_label() static helpers in SettingsData; Controls section (GridContainer) in settings_menu.gd; 8 tests (1518 total passing). PR #240 merged.

### T-0179
- Title: Add interaction prompt near player for interactable objects (supersedes T-0113)
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: T-0089
- Refs: game/entities/player/player.gd, game/ui/hud/hud.gd, game/ui/hud/interaction_hint.gd
- Notes: NPC indicators (T-0089) are above NPC heads but the player has no HUD cue. When InteractionRay detects an interactable, show a small [E] Interact label in HUD bottom-center. Supersedes T-0113 — mark T-0113 superseded. compute_interaction_hint_text(action_name) static helper using InputMap. 3+ tests.

### T-0185
- Title: Re-milestone fast travel and bonding system — move T-0024 and T-0025 to M1
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M0
- Depends: none
- Notes: Doc-only change. Updated T-0024 and T-0025 Milestone from M0 to M1. Both are full system builds (world map UI, affinity tracking) out of scope for M0 close.

### T-0186
- Title: Wire MemorialEchoStrategy to EchoManager.collect_echo() after T-0182
- Status: superseded
- Assigned: claude
- Notes: Folded into T-0182. MemorialEchoStrategy echo_id export and EchoManager.collect_echo() wiring were delivered as part of T-0182 (PR #244). HUD echo badge signal wiring was also delivered in T-0182.

### T-0187
- Title: Build Echo Collection Journal UI (view collected echoes in pause menu)
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Depends: T-0182
- Refs: docs/lore/04-echo-catalog.md, game/ui/pause_menu/pause_menu.gd
- Notes: Script-only Control opened from pause menu (same pattern as quest_log.gd). Two panels: list of collected echoes and detail panel showing name, rarity badge, echo_type, lore_text, Kael notes. compute_echo_list() and compute_echo_detail() static helpers for TDD. "Echoes" button added to pause menu. Collection count label: "Echoes: X / 42". 6+ tests.

### T-0188
- Title: Place campfire interactable in Overgrown Ruins
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0023
- Refs: game/scenes/overgrown_ruins/overgrown_ruins.gd, game/entities/interactable/strategies/camp_strategy.gd
- Notes: Mirror of T-0180. Place a CampStrategy-powered Interactable in the Overgrown Ruins clearing. one_time=false. compute_ruins_campfire_name() and compute_ruins_campfire_position() static helpers. 3+ tests.

### T-0189
- Title: Wire EchoManager into all SaveManager call sites
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M1
- Depends: T-0182
- Refs: game/entities/interactable/strategies/save_point_strategy.gd, game/systems/battle/states/defeat_state.gd, game/ui/title_screen/title_screen.gd
- Notes: Three save/load call sites do not yet pass EchoManager — save_point_strategy.gd (save_game), defeat_state.gd (apply_save_data), title_screen.gd (apply_save_data). Pass EchoManager as the trailing optional arg to ensure echo collection persists through save/load. 3+ tests verifying round-trip via each call site.

### T-0190
- Title: Implement Chapter 5 Overgrown Capital dungeon tilemap and navigation skeleton
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: high
- Milestone: M1
- Depends: T-0103
- Refs: docs/story/act1/05-into-the-capital.md, docs/game-design/05-dungeon-designs.md, game/scenes/
- Notes: Create game/scenes/overgrown_capital/ with overgrown_capital.tscn + .gd. Multi-district layout: outer gate, Market District, Entertainment District, Research Quarter, Palace District approach. 40x32+ tilemap using Ruins A5 + Overgrown Ruins Objects. MapBuilder module split (OvergrownCapitalMap + OvergrownCapitalEncounters). Two save point interactables. Exit triggers south to OvergrownRuins. Visual verify /scene-preview --full-map. 8+ tests.

### T-0191
- Title: Add Lyra's Fragment 2 collectible and Chapter 5 Research Quarter vision sequence
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0190, T-0182
- Refs: docs/story/act1/05-into-the-capital.md (Scene 4), docs/lore/04-echo-catalog.md, game/autoloads/echo_manager.gd
- Notes: Scene 4 from Chapter 5 script. Create game/data/echoes/lyra_fragment_2.tres. Place MemorialEchoStrategy in Research Quarter. On collect: 8-10 line vision (Lyra's lab — Marcus Cole, 140-day countdown, "I'm sorry"); set flag lyra_fragment_2_collected. Also add 4-5 line gate dialogue (Iris reads nameplate). compute_research_quarter_lines() static helper. 6+ tests.

### T-0192
- Title: Add The Last Gardener encounter — optional boss with three-choice resolution
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Depends: T-0190
- Refs: docs/story/act1/05-into-the-capital.md (Scene 5), docs/game-design/02-enemy-design.md
- Notes: Trigger zone after Research Quarter. Three choices: peaceful pass, Greenhouse Seed side-quest hook, boss battle. Wire to flag gardener_resolution ("peaceful"/"quest"/"defeated"). compute_gardener_choice_result() static helper. 5+ tests verifying all three branches.

### T-0193
- Title: Add Chapter 5 post-dungeon camp scene — "After the Capital" campfire dialogue
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Depends: T-0191
- Refs: docs/story/act1/05-into-the-capital.md (Camp Scene), game/events/
- Notes: 10-line campfire dialogue: Iris and Garrick acknowledge past roles, Kael's "Neither of you is that person anymore" beat. New event file game/events/after_capital_camp.gd. Gated by lyra_fragment_2_collected AND NOT after_capital_camp_seen. compute_after_capital_lines() helper. 5+ tests.

### T-0194
- Title: Seed Story Echo .tres files for Act I Overgrown Capital collection spots
- Status: superseded
- Assigned: unassigned
- Notes: Superseded by T-0197 which seeded all four target echo .tres files (Morning Commute, Family Dinner, Warning Ignored, The First Crack). PR #250.
- Priority: medium
- Milestone: M1
- Depends: T-0182, T-0190
- Refs: docs/lore/04-echo-catalog.md, game/data/echoes/
- Notes: 3-4 Story Echo .tres files for Chapter 5 dungeon. Candidates: "Morning Commute" (Market District), "Family Dinner" (residential ruins), "Warning Ignored" (Research Quarter meeting room), "The First Crack" (Resonance Nexus stub). Each needs .tres + MemorialEchoStrategy interactable in the dungeon. 4+ tests verifying unique IDs and collectibility.

### T-0195
- Title: Implement Purification Node mechanic for crystal-blocked dungeon paths
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0190
- Refs: docs/story/act1/05-into-the-capital.md (Scene 2-3), game/entities/interactable/
- Notes: PurificationNodeStrategy (extends InteractionStrategy). One-time use. On activate: set flag node_<id>_cleared, emit node_cleared(node_id) signal, clear collision/visual. compute_node_active_state(flags, node_id) static helper. Placed at Market->Entertainment and Entertainment->Research exits. 4+ tests.

### T-0196
- Title: Add ScenePaths constant for Overgrown Capital and mark T-0106 superseded
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M1
- Depends: none
- Refs: game/systems/scene_paths.gd, agents/BACKLOG.md
- Notes: (1) Add OVERGROWN_CAPITAL constant to scene_paths.gd so transition triggers have a typed path. (2) T-0106 Status update done in BACKLOG.md. 1 test verifying constant is non-empty.

### T-0197
- Title: Seed Story Echo .tres files for Act I (Morning Commute, Family Dinner, Warning Ignored, The First Crack)
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: high
- Milestone: M1
- Depends: T-0182
- Refs: docs/lore/04-echo-catalog.md, game/data/echoes/, game/resources/echo_data.gd
- Notes: Create 4 Story Echo .tres files: morning_commute.tres (Common, Story), family_dinner.tres (Common, Story), warning_ignored.tres (Uncommon, Story), the_first_crack.tres (Rare, Story). Each needs id, display_name, rarity, echo_type, lore_text, kael_notes. 4+ tests verifying unique IDs, rarity values, non-empty lore_text.

### T-0198
- Title: Refactor MemorialEchoStrategy to support generic echo placement (not tied to elder_wisdom quest)
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: high
- Milestone: M1
- Depends: T-0182
- Refs: game/entities/interactable/strategies/memorial_echo_strategy.gd, docs/story/act1/05-into-the-capital.md
- Notes: Add require_quest_id: StringName = &"" export. When empty, just show vision_lines dialogue, collect echo, set has_been_used=true. When set, preserve existing quest-objective-complete behavior. compute_should_collect(echo_id, require_quest_id, quest_active, obj_done) static helper. 6+ tests.

### T-0199
- Title: Place Morning Commute and Family Dinner echo interactables in Overgrown Capital Market District
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Depends: T-0190, T-0197, T-0198
- Refs: docs/story/act1/05-into-the-capital.md (Scene 2), docs/lore/04-echo-catalog.md
- Notes: Two EchoInteractableStrategy interactables in Market District. Vision dialogue 2-3 lines each. compute_market_echo_positions() static helper. 4+ tests.

### T-0200
- Title: Add Leaving the Capital scene — post-dungeon processing dialogue (Chapter 5 Scene 6)
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Depends: T-0191
- Refs: docs/story/act1/05-into-the-capital.md (Scene 6), game/events/
- Notes: 9-line dialogue: Garrick on loss of two million people, Iris on Initiative guilt, Kael on the choice behind the Severance. New event file game/events/leaving_capital.gd. Gated by lyra_fragment_2_collected AND NOT leaving_capital_seen. compute_leaving_capital_lines() helper. 5+ tests.

### T-0201
- Title: Place childs_laughter echo interactable in Verdant Forest at camp clearing
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: medium
- Milestone: M1
- Depends: T-0182, T-0198
- Refs: docs/lore/04-echo-catalog.md (childs_laughter — Verdant Tangle), game/scenes/verdant_forest/verdant_forest.gd
- Notes: Place one-time EchoInteractableStrategy at Vector2(352, 192) near campfire in Verdant Forest. Vision line: "Pure joy. A child chasing fireflies through a summer field, before The Severance." Gives players first in-world echo pickup before the dungeon. compute_forest_echo_position() helper. 3+ tests.

### T-0202
- Title: Update T-0104 dependency from T-0103 to T-0191 (narrative pivot is Lyra Fragment 2)
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: none
- Refs: agents/BACKLOG.md
- Notes: T-0104 (Chapters 6-10) currently depends on T-0103 which is superseded. Update dependency to T-0191 (Lyra's Fragment 2 + Research Quarter vision) which is the actual narrative gate for Act I Chapter 5 completion. Doc-only change.

### T-0203
- Title: Mark T-0194 superseded by T-0197 in BACKLOG (done via T-0198 tracker update)
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Priority: low
- Milestone: M1
- Depends: none
- Notes: Applied as part of task planner recommendations. T-0194 now marked superseded in BACKLOG.md.

### T-0204
- Title: Update T-0183 dependency from T-0103 to T-0190 (Prismfall Approach needs Capital dungeon first)
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: none
- Refs: agents/BACKLOG.md
- Notes: T-0183 (Prismfall Approach overworld scene) depends on T-0103 which is superseded. T-0190 (Overgrown Capital tilemap skeleton) is the real gate. Doc-only change, no code.

### T-0205
- Title: Seed and place Residential Quarter echo interactables in Overgrown Capital
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Depends: T-0190, T-0197
- Refs: docs/game-design/05-dungeon-designs.md (Residential Quarter), docs/lore/04-echo-catalog.md
- Notes: Create 2 Story Echo .tres for personal home memories in Residential Quarter ruins (e.g., family_dinner.tres already exists; one new family-themed echo). Place MemorialEchoStrategy interactables in residential area. 4+ tests verifying unique IDs and placement.

### T-0206
- Title: Add The Performer mini-boss in Entertainment District of Overgrown Capital
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: T-0190
- Refs: docs/game-design/05-dungeon-designs.md (Entertainment District), docs/game-design/02-enemy-design.md
- Notes: Echo manifestation mini-boss in the theater. Create performer.tres EnemyData (BOSS AI, ~180 HP, dramatic_echo AoE magic + resonance drain ability). Trigger zone in theater area. Pre/post-battle 4-5 line dialogue. Flag: performer_encountered. 4+ tests.

### T-0207
- Title: Add Government Center sub-area to Overgrown Capital — political debate echoes and hidden bunker
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190
- Refs: docs/game-design/05-dungeon-designs.md (Government Center), docs/lore/04-echo-catalog.md
- Notes: Capitol building area. Create 1-2 Story Echo .tres about political dissent re: Resonance regulation. Hidden bunker secret area with rare echo. 3+ tests.

### T-0208
- Title: Source or assign BGM for Overgrown Capital dungeon scene
- Status: superseded
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190
- Refs: docs/game-design/06-audio-design.md, game/assets/music/
- Notes: Superseded by T-0210. Echoes of the Capital.ogg was already imported; T-0210 wires it directly.

### T-0209
- Title: Add Echo Nomad enemy to Overgrown Capital encounter pool
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0190
- Refs: docs/game-design/02-enemy-design.md, game/scenes/overgrown_capital/overgrown_capital_encounters.gd, game/data/enemies/
- Notes: Create game/data/enemies/echo_nomad.tres (EnemyData: REGULAR AI, ~90 HP, magic-biased, Echo Manifestation type). Add as 3rd entry in OvergrownCapitalEncounters.build_pool() alongside Memory Bloom and Creeping Vine. Acceptance: pool has 3+ entries, echo_nomad.tres loads correctly. Check Time Fantasy packs for translucent humanoid sprite first. 4+ tests verifying pool size and echo_nomad entry presence.

### T-0210
- Title: Wire dedicated Echoes of the Capital BGM for Overgrown Capital (replace Castle.ogg placeholder)
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0190
- Refs: game/scenes/overgrown_capital/overgrown_capital.gd, game/assets/music/Echoes of the Capital.ogg
- Notes: T-0190 uses Castle.ogg with a placeholder comment. Echoes of the Capital.ogg is already imported at res://assets/music/Echoes of the Capital.ogg. Change SCENE_BGM_PATH constant. Must be done before T-0212 (transition wiring) to avoid BGM stack collision with Overgrown Ruins. 1 test verifying the constant differs from overgrown_ruins SCENE_BGM_PATH.

### T-0211
- Title: Tilemap visual design for Overgrown Capital — three-district layout
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0190
- Refs: docs/game-design/05-dungeon-designs.md, game/scenes/overgrown_capital/overgrown_capital_map.gd, docs/best-practices/11-tilemaps-and-level-design.md
- Notes: Use tilemap-builder agent to design full visual layout for the 40x28 dungeon. Three visually distinct district aesthetics: Market (overgrown stalls, broad streets), Entertainment (theater ruin silhouette, ornate floor), Research Quarter (lab aesthetic, crystal growth). AbovePlayer layer for overhanging ruins. Place Purification Node blocker positions. MUST use /scene-preview --full-map after each district layer. Single agent only — no parallel tilemap work. 6+ tests verifying district tile density and bounds.

### T-0212
- Title: Wire Verdant Forest → Overgrown Capital transition (add ExitToCapital trigger)
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0190, T-0196
- Refs: game/scenes/verdant_forest/verdant_forest.gd, game/scenes/verdant_forest/verdant_forest.tscn, game/scenes/overgrown_capital/overgrown_capital.tscn, game/systems/scene_paths.gd
- Notes: Add ExitToCapital Area2D to verdant_forest.tscn (north edge). Wire in verdant_forest.gd with garrick_recruited flag gate — shows 1-line hint if not yet recruited ("The path north is not safe without the full party."). ZoneMarker UP direction "Overgrown Capital". Add SpawnFromForest Marker2D to overgrown_capital.tscn + register group "spawn_from_forest". Handler: GameManager.change_scene(SP.OVERGROWN_CAPITAL, FADE_DURATION, "spawn_from_forest"). compute_capital_exit_requires_garrick() static helper for TDD. 5+ tests.

### T-0213
- Title: Add Merchant's Regret optional mini-boss to Overgrown Capital Market District
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, game/data/enemies/
- Notes: Create game/data/enemies/merchants_regret.tres (EnemyData: BOSS AI, ~200 HP, coin_shower AoE + desperate_bargain debuff). Trigger zone in Market stall cluster. Pre-battle 2-line dialogue. Flag: merchants_regret_encountered. compute_merchants_regret_can_trigger(flags) static helper. 3+ tests.

### T-0214
- Title: Add Research Quarter Resonance terminal puzzle — unlock Palace District path
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: T-0195, T-0191
- Refs: docs/game-design/05-dungeon-designs.md, game/entities/interactable/
- Notes: Player collects two Resonance Crystal key items (one from Market, one from Entertainment) and uses them on the terminal. ResonanceTerminalStrategy extends InteractionStrategy. Checks inventory for both crystals, on success sets research_terminal_activated flag. Create resonance_crystal_market.tres and resonance_crystal_entertainment.tres (ItemData, key item type). compute_terminal_can_activate(inventory) static helper. 5+ tests.

### T-0215
- Title: Add hidden VIP lounge in Entertainment District — legendary echo collectible
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/04-echo-catalog.md
- Notes: Secret area accessible via hidden stage entrance in theater area. Create game/data/echoes/final_performance.tres (EchoData: LEGENDARY rarity, STORY echo_type, 3-line lore about a performer's last show before The Severance). MemorialEchoStrategy. Flag: vip_lounge_found. compute_vip_lounge_eligible(flags) helper. 3+ tests.

### T-0216
- Title: Add rooftop garden secret area to Residential Quarter — rare echo collectible
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/04-echo-catalog.md
- Notes: Secret rooftop area accessible via collapsed building rubble path. Create game/data/echoes/rooftop_garden.tres (EchoData: RARE rarity, STORY echo_type, family tending a garden above the city). MemorialEchoStrategy with 2-3 line vision. Flag: rooftop_garden_found. 3+ tests.

### T-0217
- Title: Add hidden archives secret room in Government Center — Historical Records lore
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, game/entities/interactable/
- Notes: Secret room in Government Center accessible via collapsed wall. Plain dialogue Interactable (one_time=true) with 3-line lore dump about pre-Severance political history. Flag: hidden_archives_found. compute_archives_lore_text() static helper. 2+ tests.

### T-0218
- Title: Add Survivor's Diary collectible in Residential Quarter — post-Severance survival lore
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/02-main-story.md, game/entities/interactable/
- Notes: Emotionally significant lore item in a Residential Quarter room. Interactable one_time=true, 4-5 line dialogue. Flag: survivors_diary_read. compute_diary_entries() static helper. 3+ tests.

### T-0219
- Title: Build skill tree UI screen — view and unlock nodes from pause menu
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0018, T-0184
- Refs: docs/mechanics/character-abilities.md, game/resources/skill_tree_data.gd, docs/best-practices/08-ui-patterns.md
- Notes: Script-only SkillTreeUI Control (same pattern as echo_journal.gd). Character tab per party member. Node list with name, SP cost, unlocked/locked/available state, parent dependency shown. Confirm button spends skill_points from CharacterData. compute_skill_tree_entries(char_data) and compute_node_state(node, char_data) static helpers for TDD. "Skill Tree" button added to pause menu. 8+ tests.

### T-0220
- Title: Mark T-0008, T-0010, T-0011 as done — superseded by T-0181 hygiene sweep
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Notes: T-0181 (M0 hygiene sweep) explicitly combined and addressed T-0008 (replace has_method duck-typing), T-0010 (add return type hints), T-0011 (add doc comments). Update their Status to done with Superseded note pointing to T-0181. Doc-only change, 0 tests required.

### T-0221
- Title: Seed AbilityData .tres files for Kael's full ability set (7 abilities)
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0018, T-0184
- Refs: docs/mechanics/character-abilities.md (Kael Voss section), game/data/abilities/, game/resources/ability_data.gd
- Notes: Create 7 AbilityData .tres files from design doc: echo_strike, resonance_pulse, memory_weave, adaptive_strike, echo_fusion, reality_anchor, convergence_touch. Stats per docs/mechanics/character-abilities.md (EE costs, damage types, elements). 7+ tests verifying EE cost, damage_stat type, and non-empty display_name per ability.

### T-0222
- Title: Seed AbilityData .tres files for Iris and Garrick full ability sets
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: high
- Milestone: M1
- Depends: T-0018, T-0184
- Refs: docs/mechanics/character-abilities.md (Iris and Garrick sections), game/data/abilities/
- Notes: Iris: heavy_strike, emp_burst, overclock, shrapnel_shot, prototype_deploy, resonance_disruptor, railgun (7 abilities). Garrick: guardians_stand, purifying_light, shield_bash, martyrs_resolve, crystal_purge, unbreakable, last_stand (7 abilities). Stats per design doc. 10+ tests covering at least one ability per character.

### T-0223
- Title: Seed AbilityData .tres files for Nyx and Lyra (4-ability stubs each)
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Milestone: M1
- Depends: T-0018
- Refs: docs/mechanics/character-abilities.md (Nyx and Lyra sections), game/data/abilities/
- Notes: Nyx: void_bolt, phase_shift, reality_break, shadow_bind (first 4 of 7). Lyra: echo_mend, memory_strike, resonance_shield, fragment_vision (matches existing ability refs in lyra.tres). 6+ tests.

### T-0224
- Title: Place save point interactable in Overgrown Capital Market District
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0190
- Refs: game/scenes/overgrown_capital/overgrown_capital.gd (compute_market_save_point_position), game/entities/interactable/strategies/save_point_strategy.gd
- Notes: overgrown_capital.gd declares compute_market_save_point_position() returning Vector2(160.0, 368.0) but no save point Interactable is instantiated in _ready(). Add _setup_save_point() creating an Interactable with SavePointStrategy at that position. indicator_type=SAVE. one_time=false. Also add compute_research_save_point_position() returning Vector2(448.0, 80.0) and a second save point at the Research Quarter entrance per dungeon design doc. 4+ tests.

### T-0225
- Title: Add Chapter 6 Nyx introduction scene — "Born from Nothing" Hollows border encounter
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: high
- Milestone: M1
- Depends: T-0191
- Refs: docs/story/act1/06-born-from-nothing.md, game/events/, game/scenes/verdant_forest/verdant_forest.gd
- Notes: docs/story/act1/06-born-from-nothing.md has a complete script for Nyx's arrival. Create game/events/nyx_introduction.gd implementing Scenes 1-3 (~20-25 lines). Gate on garrick_recruited AND lyra_fragment_2_collected AND NOT nyx_introduction_seen. NyxIntroduction.compute_can_trigger(flags) static helper. Flags set: nyx_introduction_seen, nyx_met. 5+ tests.

### T-0226
- Title: Overgrown Capital playtest pass — end-to-end Chapter 5 flow verification
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0211, T-0224
- Refs: game/tools/playtest_presets/, docs/story/act1/05-into-the-capital.md
- Notes: Full Chapter 5 flow: enter from Verdant Forest, collect Market echoes, activate Market Purification Node, navigate Entertainment District, activate Entertainment Purification Node, collect Lyra Fragment 2, trigger Last Gardener, trigger Leaving Capital, exit to Verdant Forest. Create/update overgrown_capital playtest preset JSON. Verify save/load round-trip persists echo IDs and cleared purification flags. Log discovered bugs as new BACKLOG entries.

### T-0227
- Title: Place campfire interactable in Overgrown Capital Market District
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: T-0023, T-0190
- Refs: game/scenes/overgrown_capital/overgrown_capital.gd, game/entities/interactable/strategies/camp_strategy.gd
- Notes: Add _setup_campfire() in overgrown_capital.gd placing CampStrategy Interactable near market rest area. compute_capital_campfire_position() static helper returning Vector2(128.0, 352.0) (col 8, row 22, near save point). one_time=false. 3+ tests verifying in-bounds position and correct strategy type.

---

## M2 — Act II: The Weight of Echoes

(Tickets will be created during M2 sprint planning.)

---

## M3 — Act III: Convergence

(Tickets will be created during M3 sprint planning.)

---

## M4 — Optional Content & Polish

(Tickets will be created during M4 sprint planning.)

---

## M5 — Release Readiness

(Tickets will be created during M5 sprint planning.)
