---
name: build-tilemap
description: Design and build a visually rich multi-layer tilemap for a game scene. Improves visual quality using Time Fantasy assets, multiple atlas sources, and proper layering. Use when creating or redesigning maps.
argument-hint: <scene-name> [design-goals...]
---

# Build Tilemap

Design and build a tilemap for: **$ARGUMENTS**

ultrathink

## Step 1 — Search for JRPG Reference Images

**Before anything else**, search for visual reference from published JRPGs. This prevents the common trap of building a "tile grid" instead of a believable place.

```
WebSearch("JRPG pixel art <location-type> screenshot RPG Maker Time Fantasy")
```

Search 2-3 queries for the type of scene you're building (town, forest, dungeon). Study how professional maps handle:
- Building placement (staggered along roads, not in grid rows)
- Tree clustering (natural groups with varied spacing)
- Path flow (winding, varying width)
- Ground terrain variety (grass, dirt, stone in organic patches)
- Environmental storytelling details (barrels, signs, gardens, fences)

## Step 2 — Read Tilemap Best Practices

Read the tilemap and level design best practices:

```
Read("docs/best-practices/11-tilemaps-and-level-design.md")
```

## Step 3 — Research the Target Scene

1. **Read the scene script** to understand current tilemap setup, legends, map arrays, and functional code (transitions, encounters, events):
   ```
   Read("game/scenes/<scene_name>/<scene_name>.gd")
   ```
2. **Read the scene file** (`.tscn`) to understand node structure and TileMapLayer nodes:
   ```
   Read("game/scenes/<scene_name>/<scene_name>.tscn")
   ```
3. **Read the MapBuilder utility** to understand the API:
   ```
   Read("game/systems/map_builder.gd")
   ```
4. **Read the design doc** for the location:
   ```
   Read("docs/game-design/03-world-map-and-locations.md")
   ```

## Step 4 — Check Available Tile Sheets

1. **Read what's already in the project**:
   ```
   Glob("game/assets/tilesets/*.png")
   ```
2. **Check MapBuilder constants** for registered tile sheets
3. **If more tile sheets are needed**, copy the ENTIRE pack from the asset directory (not just one file):
   ```bash
   cp /Users/robles/repos/games/assets/<pack>/tile*.png /Users/robles/repos/games/gemini-fantasy/game/assets/tilesets/
   cp /Users/robles/repos/games/assets/<pack>/tile*.png <current-worktree>/game/assets/tilesets/
   ```
   Or use `/copy-assets`. Always import all tile sheets from a pack so the full palette is available.

## Step 5 — Look Up Godot Docs

Call the `godot-docs` subagent for tilemap-related classes:
```
Task(subagent_type="godot-docs", prompt="Look up TileMapLayer. I need set_cell, local_to_map, z_index, collision_enabled properties. Also look up TileSetAtlasSource for creating atlas sources programmatically.")
```

## Step 6 — Design the Map as a Real Place

**Before writing any code, describe the location in words.** What would you see if you were standing here? Write 3-5 sentences, then translate that vision into a map layout.

Plan:

1. **Map dimensions**: Calculate from current map size or design requirements
2. **Layer stack**: Ground, GroundDetail, Paths, Trees, Objects (collision), AbovePlayer
3. **Atlas sources**: A5 sheet for terrain (source 0), B sheet(s) for objects (source 1+)
4. **Terrain zones**: Where does grass meet dirt? Where is stone paving? Design natural terrain transitions in organic, irregular patches — not a uniform fill
5. **Collision tiles**: Which B-sheet tiles need physics collision
6. **Environmental details**: What small objects make this place feel lived-in? (Barrels, fences, gardens, signs, logs, benches)
7. **Gameplay clearances**: Ensure spawn points, exits, NPC positions, and event zones remain accessible

## Step 7 — Implement

Modify the scene script's `_setup_tilemap()` function and related constants:

1. **Add new MapBuilder constants** if using new tile sheets (edit `map_builder.gd`)
2. **Write legends using multiple terrain types** for organic ground:
   - 2-3 terrain rows (grass, dirt, stone) in natural patches
   - ONE column per terrain patch (different columns of the same row create seam artifacts)
   - B-sheet objects for trees, buildings, rocks, environmental details
   - B-sheet ground decorations at 15-30% coverage (pebbles, flowers, moss)
3. **Redesign text map arrays:**
   - Ground: organic terrain patches — grass, dirt, stone in natural transitions
   - Trees: varied clusters with multiple types, not uniform walls
   - Paths: meandering, 2-3 tiles wide
   - Detail: liberal ground decoration coverage (15-30%)
4. **Add missing TileMapLayer nodes** to the `.tscn` file if needed
5. **Add collision data** for solid tiles from all atlas sources
6. **Pass `source_id` parameter** for B-sheet layers: `MapBuilder.build_layer(layer, map, legend, 1)`
7. **Preserve all functional code** — transitions, encounters, events, spawn points

### Design Quality Checklist

- [ ] Ground uses multiple terrain types in organic patches (NOT uniform single-tile fill)
- [ ] Ground detail layer adds 15-30% coverage (pebbles, flowers, moss, grass tufts)
- [ ] Trees/Objects layer uses multiple B-sheet object variants (not one repeated sprite)
- [ ] AbovePlayer layer creates depth (canopy, rooftops the player walks behind)
- [ ] Paths meander naturally, 2-3 tiles wide minimum, with terrain transitions along edges
- [ ] Clearings and open spaces have organic (non-rectangular) shapes
- [ ] Map has visual landmarks/focal points (large tree, well, fountain, archway)
- [ ] Environmental storytelling details present (barrels by shop, garden by house, etc.)
- [ ] All spawn points and exits remain accessible
- [ ] Collision is set on tree trunks, rocks, buildings, walls
- [ ] `source_id` parameter passed correctly for B-sheet layers
- [ ] Scene looks like it was designed by a human artist, not procedurally generated

## Step 7 — Verify

1. **Check that all referenced tile coordinates exist** in the tile sheets (A5: cols 0-7, rows 0-15; B: cols 0-15, rows 0-15)
2. **Check map dimensions match** — all rows in a map array must be the same length
3. **Check collision setup** — all solid tiles are listed
4. **Check z_index settings** on TileMapLayer nodes
5. **Check that functional code still works** — scene transitions, encounter system, event triggers
6. **Check that only A5 and B sheets are used**

## Step 8 — Report

Summarize:
1. What changed (layers added, legends expanded, maps redesigned)
2. New tile sheets used
3. Map dimensions
4. Visual description of the result
5. Any editor tasks for the user (reopen Godot, etc.)
