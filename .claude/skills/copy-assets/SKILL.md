---
name: copy-assets
description: Copy art/audio assets from Time Fantasy packs into the Godot project. Handles finding the right source file, copying to both main repo and worktree, and verifying the copy. Use when adding new sprites, tilesets, or audio to the game.
argument-hint: <what-you-need> [details...]
---

# Copy Assets

Copy assets for: **$ARGUMENTS**

## Step 1 — Identify What You Need

Determine the asset type and likely source pack:

| Need | Pack to Search | Subdirectory in Pack |
|------|---------------|---------------------|
| Forest/town tiles | `tf_fairyforest_12.28.20/1x/` | Root — TileA5, TileB PNGs |
| Ruin/dungeon tiles | `tf_ruindungeons/16/` | Root — TileA5, TileB PNGs |
| Giant tree tiles | `tf_giant-tree/RPGMAKER-100/` | Root |
| Farm/fort tiles | `tf_farmandfort/` | Look for 16px or 1x subfolder |
| Character walk sprites | `tf_fairyforest_12.28.20/1x/characters/` | Or `beast_tribes/100/`, `tf_dwarfvelf_v1.2/regularsize/` |
| NPC animations | `npc-animations/rpgmaker/1/` | Subfolders by NPC type |
| Battle sprites | `tf_svbattle/` | Hero battle animations |
| Boss/enemy sprites | `tf_mythicalbosses/100/` | Per-monster folders |
| Battle VFX | `pixel_animations_gfxpack/` | By element/effect type |
| Icons | `icons_8.13.20/fullcolor/` | `16/`, `24/`, `32/` sizes |
| Face portraits | `tf-faces-6.11.20/transparent/1x/` | Per-character PNGs |
| Winter tiles | `TimeFantasy_Winter/tiles/` | Root |

## Step 2 — Search the Source Packs

The source asset packs are at: `/Users/robles/repos/games/assets/`

```bash
# List available packs
ls /Users/robles/repos/games/assets/

# Search within a pack for specific files
find /Users/robles/repos/games/assets/<pack-name>/ -name "*.png" | head -20

# Search by keyword across all packs
find /Users/robles/repos/games/assets/ -iname "*<keyword>*.png"
```

When in doubt, **visually inspect** the PNG using the Read tool — it displays images.

## Step 3 — Determine Destination

| Asset Type | Destination in `game/assets/` |
|-----------|------------------------------|
| Tile sheets (A5, B format) | `tilesets/` |
| Character walk sprites | `sprites/characters/` |
| Building/structure sprites | `sprites/buildings/` |
| Enemy sprites | `sprites/enemies/` |
| Battle VFX sprites | `sprites/effects/` |
| Face portraits | `portraits/` |
| UI/item icons | `icons/` |
| Background music | `audio/bgm/` |
| Sound effects | `audio/sfx/` |

## Step 4 — Copy to BOTH Locations

**CRITICAL**: Assets must exist in the main repo (where Godot runs) AND the current worktree (if using one).

```bash
# Main repo (ALWAYS do this)
MAIN_REPO="/Users/robles/repos/games/gemini-fantasy/game/assets"
mkdir -p "$MAIN_REPO/<subdir>"
cp "<source_path>" "$MAIN_REPO/<subdir>/<filename>"

# Worktree (do this if working in a worktree)
WORKTREE="/Users/robles/repos/games/gemini-fantasy/.worktrees/<branch>/game/assets"
mkdir -p "$WORKTREE/<subdir>"
cp "<source_path>" "$WORKTREE/<subdir>/<filename>"
```

**Naming convention**: Keep the original filename when possible. If renaming for clarity, use `snake_case` and be descriptive (e.g., `kael_overworld.png`, not `char1.png`).

## Step 5 — Verify

1. Confirm the file exists in both locations:
   ```bash
   ls -la /Users/robles/repos/games/gemini-fantasy/game/assets/<subdir>/<filename>
   ls -la /Users/robles/repos/games/gemini-fantasy/.worktrees/<branch>/game/assets/<subdir>/<filename>
   ```

2. Check that the `res://` path you'll use in GDScript maps correctly:
   - `res://assets/tilesets/foo.png` → `game/assets/tilesets/foo.png`
   - `res://assets/sprites/characters/bar.png` → `game/assets/sprites/characters/bar.png`

3. Remind the user: **Reopen the Godot editor** after adding new PNGs so Godot generates `.import` files.

## Step 6 — Report

List all copied assets:
- Source path
- Destination path (both main repo and worktree)
- The `res://` path to use in GDScript
- Reminder to reopen Godot editor for import

## Important Notes

- **PNGs are gitignored** (`game/assets/**/*.png`) — they will NOT be committed to git
- **`.import` files ARE tracked** — Godot generates these alongside PNGs after first import
- If `load()` returns null at runtime, the asset hasn't been imported — reopen the editor
- Always use **1x / 16px base size** variants from the Time Fantasy packs
- Use the Read tool to visually inspect PNGs before copying to confirm you have the right asset
