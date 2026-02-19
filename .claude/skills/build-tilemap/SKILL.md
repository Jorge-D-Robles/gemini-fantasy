---
name: build-tilemap
description: Design and build a visually rich multi-layer tilemap for a game scene. Improves visual quality using Time Fantasy assets, multiple atlas sources, and proper layering. Use when creating or redesigning maps.
argument-hint: <scene-name> [design-goals...]
---

# Build Tilemap

Design and build a tilemap for: **$ARGUMENTS**

ultrathink

## CRITICAL: Visual-First Workflow

**You MUST see your work at every step.** Tilemap design without visual feedback produces garbage. The workflow is:

```
For EACH layer:
  Write data → commit/push → /scene-preview --full-map → Read screenshot
  → evaluate → fix if needed → repeat until it looks correct
  → THEN move to next layer
```

**Never commit a final tilemap without capturing and evaluating a screenshot.**

## Step 1 — Search for Pixel Art Reference Images

**Before anything else**, ground yourself in what good pixel art looks like. Do at least 3 web searches:

**Scene reference:**
```
WebSearch("JRPG pixel art <location-type> screenshot RPG Maker")
WebSearch("<location-type> tilemap pixel art top-down 16x16")
```

**Object reference (for each major object you'll place):**
```
WebSearch("pixel art tree top-down 16x16 RPG sprite")
WebSearch("pixel art rock boulder tileset JRPG")
WebSearch("pixel art <object-type> sprite top-down")
```

**Published game reference:**
```
WebSearch("Chrono Trigger <location> map screenshot")
WebSearch("Final Fantasy 6 <location> pixel art")
```

Study the results. Note how trees, rocks, buildings, and terrain look in professional pixel art. You will compare your work against these references.

## Step 2 — View the Tile Sheet PNGs (MANDATORY)

**Read the actual PNG image files** before using any atlas coordinate. You can see images — use that ability.

```
Read("game/assets/tilesets/<tileset>.png")
```

For EACH tile sheet you plan to use:
1. Read the PNG file
2. Identify exactly what is at each coordinate you'll reference
3. Write down what you actually see (not what the docs claim)
4. If the docs say "pebbles" but you see a golden chest — trust your eyes

**Never use an atlas coordinate you haven't visually confirmed.**

## Step 3 — Read Tilemap Best Practices

```
Read("docs/best-practices/11-tilemaps-and-level-design.md")
```

## Step 4 — Research the Target Scene

1. Read the scene script: `game/scenes/<scene_name>/<scene_name>.gd`
2. Read the `.tscn` file for node structure
3. Read `game/systems/map_builder.gd` for API
4. Read `docs/game-design/03-world-map-and-locations.md` for location design

## Step 5 — Design the Map as a Real Place

**Describe the location in 5+ sentences before writing any code.** Then plan:

1. **Ground:** 2-3 terrain types in organic irregular patches
2. **Detail:** Sparse, intentional decorations (NOT percentage-based spam)
3. **Paths:** Meandering, 2-3 tiles wide, with terrain transitions
4. **Objects:** Multi-tile objects with 3-4 variants per type
5. **Above-player:** Canopies/roofs for depth

## Step 6 — Implement with Visual Verification After Each Layer

**For EACH layer** (ground, detail, paths, trees, objects, above-player):

1. Write the legend and map data
2. Save the file
3. Commit, push, and sync main repo:
   ```bash
   git add <file> && git commit -m "WIP: <layer> for <scene>"
   git push -u origin <branch>
   git -C /Users/robles/repos/games/gemini-fantasy pull
   ```
4. Capture screenshot:
   ```bash
   timeout 30 /Applications/Godot.app/Contents/MacOS/Godot \
     --path /Users/robles/repos/games/gemini-fantasy/game/ \
     --rendering-driver opengl3 \
     res://tools/scene_preview.tscn \
     -- --preview-scene=res://scenes/<name>/<name>.tscn \
        --output=/tmp/scene_preview.png --full-map 2>&1
   ```
5. Read and evaluate the screenshot:
   ```
   Read("/tmp/scene_preview.png")
   ```
6. Ask yourself:
   - Does this layer look correct?
   - Do the tiles look like what I expected from the PNG?
   - Is there any repeating grid pattern?
   - Does it approach the quality of my reference images?
7. **Fix and re-screenshot if anything is wrong.** Do NOT proceed blind.

## Step 7 — Final Visual Quality Check

After all layers:
1. Run `/scene-preview --full-map` one final time
2. Read the screenshot
3. Compare against reference images from Step 1
4. Verify:
   - [ ] Ground has visible terrain variety
   - [ ] Decorations are sparse and intentional (no repeating patterns)
   - [ ] Multi-tile objects are complete
   - [ ] No wrong/unexpected tile sprites
   - [ ] Scene looks hand-crafted, not procedural
5. Fix any issues before final commit

## Decoration Placement Rules

**NEVER target a coverage percentage.** Place decorations individually:
- Each one serves a purpose (path marker, age indicator, visual break)
- Vary types — never 3+ identical sprites in a row
- Leave open ground — empty space is fine
- If you see a repeating pattern in the screenshot, delete most of them
- 10 well-placed varied decorations > 100 identical scattered ones

## Wrong Tile Detection

If a tile renders differently than expected:
1. STOP — your atlas coordinate is wrong
2. Re-read the tile sheet PNG
3. Fix the legend coordinate
4. Re-screenshot to verify
