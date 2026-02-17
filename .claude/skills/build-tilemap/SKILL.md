---
name: build-tilemap
description: Design and build a visually rich multi-layer tilemap for a game scene. Improves visual quality using Time Fantasy assets, multiple atlas sources, and proper layering. Use when creating or redesigning maps.
argument-hint: <scene-name> [design-goals...]
---

# Build Tilemap

Design and build a tilemap for: **$ARGUMENTS**

ultrathink

## Step 1 — Read Tilemap Best Practices

Read the tilemap and level design best practices:

```
Read("docs/best-practices/11-tilemaps-and-level-design.md")
```

## Step 2 — Research the Target Scene

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

## Step 3 — Check Available Tile Sheets

1. **Read what's already in the project**:
   ```
   Glob("game/assets/tilesets/*.png")
   ```
2. **Check MapBuilder constants** for registered tile sheets
3. **If more tile sheets are needed**, copy from the asset packs:
   ```
   /copy-assets <description of needed tileset>
   ```
   Or manually:
   ```bash
   cp /Users/robles/repos/games/assets/<pack>/<file> /Users/robles/repos/games/gemini-fantasy/game/assets/tilesets/<filename>
   cp /Users/robles/repos/games/assets/<pack>/<file> <current-worktree>/game/assets/tilesets/<filename>
   ```

## Step 4 — Look Up Godot Docs

Call the `godot-docs` subagent for tilemap-related classes:
```
Task(subagent_type="godot-docs", prompt="Look up TileMapLayer. I need set_cell, local_to_map, z_index, collision_enabled properties. Also look up TileSetAtlasSource for creating atlas sources programmatically.")
```

## Step 5 — Design the New Tilemap

Plan the map layout before writing code:

1. **Map dimensions**: Calculate from current map size or design requirements
2. **Layer stack**: Ground, GroundDetail, Paths, Trees, Objects (collision), AbovePlayer
3. **Atlas sources**: A5 sheet for terrain (source 0), B sheet(s) for objects (source 1+)
4. **Tile selection**: Pick ONE tile per terrain type (single-tile fill rule)
5. **Collision tiles**: Which B-sheet tiles need physics collision
6. **Gameplay clearances**: Ensure spawn points, exits, NPC positions, and event zones remain accessible

## Step 6 — Implement

Modify the scene script's `_setup_tilemap()` function and related constants:

1. **Add new MapBuilder constants** if using new tile sheets (edit `map_builder.gd`)
2. **Write legends following single-tile fill rule:**
   - ONE Vector2i per ground terrain type
   - ONE Vector2i per path type
   - B-sheet objects for trees, buildings, rocks
   - Sparse accents from different A5 rows (not columns)
3. **Redesign text map arrays:**
   - Ground: uniform single-character fill (e.g., all "G")
   - Trees: organic borders with irregular clearing edges
   - Paths: meandering, 2-3 tiles wide
   - Detail: sparse (5-15% coverage), never adjacent accents
4. **Add missing TileMapLayer nodes** to the `.tscn` file if needed
5. **Add collision data** for solid tiles from all atlas sources
6. **Pass `source_id` parameter** for B-sheet layers: `MapBuilder.build_layer(layer, map, legend, 1)`
7. **Preserve all functional code** — transitions, encounters, events, spawn points

### Design Principles Checklist

- [ ] Ground layer uses ONE tile for entire fill (single-tile fill rule)
- [ ] Visual variety comes from B-sheet objects, not A5 column mixing
- [ ] Ground detail layer adds sparse (5-15%) accents from different A5 rows
- [ ] Trees/Objects layer uses B-format sheets with collision
- [ ] AbovePlayer layer creates depth (canopy, rooftops)
- [ ] Paths meander naturally, 2-3 tiles wide minimum
- [ ] Clearings have organic (non-rectangular) shapes
- [ ] Map has visual landmarks/focal points
- [ ] All spawn points and exits remain accessible
- [ ] Collision is set on forest fill, tree trunks, rocks, buildings, walls
- [ ] `source_id` parameter passed correctly for B-sheet layers

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
