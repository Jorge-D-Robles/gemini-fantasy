# Merged Tutorial Part II: Building the World

This generated file combines the tutorial Markdown files for this tutorial part.

## Included Files

- `05_tilemaps_and_terrain.md`
- `06_player_character.md`
- `07_scene_transitions.md`
- `08_part_ii_review.md`

---

<!-- Source: 05_tilemaps_and_terrain.md -->

# Module 5: The Overworld: TileMaps and Terrain

## What We Have So Far

A Player scene (CharacterBody2D with sprite and collision) that moves with keyboard input and handles physics. But the world is empty, just a blank screen.

## What We're Building This Module

The town of **Willowbrook**, Crystal Saga's starting village. We'll build it using Godot's TileMapLayer system: painting ground, paths, buildings, and water onto a grid, with collision so the player can't walk through walls.

By the end, you'll have a real place to explore.

## How TileMaps Work: A Conceptual Model

Imagine drawing the entire overworld of Chrono Trigger as a single image. It would be enormous, impossible to edit without redrawing entire sections, and you could not add collision without manually painting invisible walls on top. Tilemaps solve all of this. Because every grass patch uses the same 16x16 tile, the game only stores that tile image once and stamps it across the map. Editing is fast: to widen a path, you repaint a few cells instead of redrawing a building. And collision is built in: you mark wall tiles as solid once, and every wall in the game blocks the player automatically. This is why nearly every 2D RPG from Final Fantasy to Stardew Valley uses tilemaps.

Before we touch any code, here's the core idea.

A tilemap is a grid of small images (tiles) assembled into a larger scene, like placing mosaic tiles to create a picture. Instead of drawing an entire town as one massive image, you draw it from reusable 16x16 or 32x32 pixel pieces: a grass tile, a path tile, a wall tile, a roof tile.

Think of it like transparent sheets stacked on top of each other:

```
Layer 4: AbovePlayer:  treetops, roof overhangs (drawn on top of the player)
Layer 3: Objects:      trees, rocks, signs, fences
Layer 2: Detail:       flowers, cracks, path borders
Layer 1: Ground:       grass, dirt, water
```

Each layer is a separate **TileMapLayer** node. The ground layer covers every tile. The detail layer has sparse decorations. The object layer has things the player walks behind. The above-player layer draws on top of everything, including the player.

This is exactly how professional 2D games are built, including most of the JRPGs you've played.

> **See:** [Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html), creating TileSet resources from tile sheets.

> **See:** [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html), painting tiles, configuring layers, and adding physics to tiles.

## TileMapLayer, not TileMap

You may see older tutorials reference a node called `TileMap`. That node is **deprecated** as of Godot 4.3. The replacement is `TileMapLayer`, one node per layer, instead of one node with multiple internal layers.

`TileMapLayer` is simpler to use and gives you direct control over each layer as an independent node in the scene tree. Each layer can have its own z-order, visibility toggle, and physics settings.

Throughout this tutorial, we always use `TileMapLayer`.

> **See:** [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html), the API reference for the current tilemap node.

## Getting a Tile Sheet

To build a tilemap, you need a **tile sheet**, an image file containing all your tiles arranged in a grid.

For this tutorial, we recommend **Kenney's Tiny Town pack**, a free, public-domain tileset that includes everything we need:

1. Go to [kenney.nl/assets/tiny-town](https://kenney.nl/assets/tiny-town) and click **Download**.
2. Extract the ZIP file.
3. In the extracted folder, find `tilemap_packed.png` (at the root of the ZIP, not in a subfolder).
4. Create a `tilesets` folder in your project: right-click in the **FileSystem** dock → **New Folder** → name it `tilesets`.
5. Copy `tilemap_packed.png` into `res://tilesets/` (drag it into the FileSystem dock, or copy it into the folder on disk).
6. Rename it to `town_tiles.png` if you like, or keep the original name.

This sheet contains grass, paths, water, walls, trees, buildings, and more, all in a 16x16 grid. It's everything we need for Willowbrook.

> **Alternatives:** If you can't download assets, you can create a minimal placeholder. Open any image editor, create a 80x16 PNG with five 16x16 colored squares: green (#4a7c3f) for grass, brown (#8b6914) for path, blue (#3b6bb5) for water, gray (#808080) for walls, and tan (#c4a882) for floor. Save as `res://tilesets/town_tiles.png`. You can replace it with real art later.

For Crystal Saga, we need at least these tile types:
- Grass (walkable ground)
- Path/dirt (walkable)
- Water (not walkable)
- Wall/building exterior (not walkable)
- Building interior floor (walkable)

> **JRPG Pattern:** Most classic JRPGs use 16x16 pixel tiles. Some use 32x32 for more detail. The choice affects the overall aesthetic. We'll use **16x16** tiles for an authentic retro feel. You can use 32x32 if you prefer a more detailed look.

## Creating the TileSet

A **TileSet** is a resource that tells Godot how to interpret your tile sheet: where each tile is, how big they are, and what properties they have (collision, animation, etc.).

### Step 1: Create the Town Scene

1. Create a new scene (Scene → New Scene).
2. Add a **Node2D** as the root. Rename it to `Willowbrook`.
3. Create the folder structure first: right-click in the **FileSystem** dock → **New Folder** → name it `scenes`. Then right-click `scenes` → **New Folder** → name it `willowbrook`. Save as `res://scenes/willowbrook/willowbrook.tscn`.

### Step 2: Add the First TileMapLayer

1. With `Willowbrook` selected, add a child **TileMapLayer** node.
2. Rename it to `Ground`.

### Step 3: Create a TileSet

1. Select the `Ground` node.
2. In the Inspector, find the **Tile Set** property.
3. Click it and choose **New TileSet**.
4. Click the TileSet resource to expand it in the **Inspector** (right panel). Find the **Tile Size** property and set it to `16x16` (or your tile size).

> **Warning:** You must set the tile size before creating an atlas source. If the tile size doesn't match your tile sheet's grid, Godot will slice the image incorrectly, and every tile coordinate will be wrong. Set it first, then add the atlas.

### Step 4: Create an Atlas Source

The TileSet panel appears at the bottom of the editor.

1. In the TileSet panel, click the **+** button to add a source.
2. Choose **Atlas**.
3. Drag your tile sheet image (`town_tiles.png`) into the **Texture** property.
4. Godot will ask if you want to **create tiles automatically**. Click **Yes**.

You should see your tile sheet with a grid overlay. Each grid cell is one tile, and Godot has created a tile entry for each one.

> **Note:** If Godot doesn't prompt you automatically, click the three-dot menu (⋮) in the TileSet panel and choose **Create Tiles in Non-Transparent Texture Regions**. If that option isn't available, make sure your Tile Size matches your tile sheet's grid.

> **Warning:** If the grid doesn't align with your tiles, double-check that the **Tile Size** in the TileSet matches your tile sheet's grid size. Misaligned grids are the #1 tileset setup problem.

### Step 5: Save the TileSet as an External Resource

If you leave the TileSet embedded in one layer, each additional layer gets its own separate copy. When you later add collision to a wall tile, you would have to add it in four separate TileSets (one per layer) and keeping them synchronized becomes a nightmare. Saving the TileSet as an external `.tres` file means all layers reference the same data. Change a tile's collision once, and it applies everywhere.

Right now, the TileSet is embedded inside the `Ground` node. We want to share it across multiple layers.

1. Click the dropdown arrow next to the TileSet property.
2. Choose **Save** (or **Save As**).
3. Save it to `res://tilesets/town_tileset.tres`.

Now we can assign this same TileSet to other TileMapLayer nodes.

## Setting Up Multiple Layers

Add three more TileMapLayer nodes as children of `Willowbrook`:

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── Objects (TileMapLayer)
└── AbovePlayer (TileMapLayer)
```

For each new layer:
1. Set the **Tile Set** property to your saved `town_tileset.tres` (drag it from the FileSystem dock or click Load).

The layers are drawn in tree order: `Ground` first (bottom), `AbovePlayer` last (top). The player sprite should render between `Objects` and `AbovePlayer`. We'll handle this with Y-sorting in Module 6.

### Why Four Layers?

| Layer | Purpose | Example Tiles |
|-------|---------|---------------|
| Ground | Covers every cell. The base terrain. | Grass, dirt, water, stone |
| Detail | Sparse decorations on top of ground. | Flowers, path edges, cracks |
| Objects | Things the player walks behind (lower half) or in front of (upper half). | Trees, rocks, fences, signs |
| AbovePlayer | Drawn on top of everything, including the player. | Treetop canopy, roof overhangs, bridge railings |

This layering creates depth. The player walks on the ground, behind trees, and under overhanging roofs, all without any complex rendering tricks.

## Painting Tiles

Now for the fun part. Select a TileMapLayer node and start painting:

1. Select the `Ground` layer in the scene tree.
2. The TileMap editor panel appears at the bottom of the screen.
3. Select a tile from the tile palette (your tile sheet is shown as a grid of clickable tiles).
4. Click or click-and-drag in the viewport to paint tiles.

### Painting Tools

The TileMap editor toolbar offers several painting tools. All of them work in the **2D viewport**, not in the TileSet panel itself. Select a tile from the palette, then paint in the viewport.

| Tool | What It Does | Shortcut |
|------|-------------|----------|
| Paint | Place one tile at a time (click or drag) | Default mode |
| Line | Draw a straight line of tiles between two points | Hold **Shift** while in Paint mode |
| Rectangle | Fill a rectangular area with one drag | Hold **Ctrl+Shift** while in Paint mode |
| Bucket Fill | Fill a contiguous region with the selected tile | Separate tool button |
| Eraser | Remove tiles | **Right-click** in any mode |
| Picker | Grab a tile from the viewport to use as your brush | Hold **Ctrl** and click in Paint mode |

The Line and Rectangle modes are temporary holds, not separate tool buttons. You stay in Paint mode and hold the modifier keys when you need them. This is faster than switching tools constantly.

**Selecting multiple tiles:** In the TileSet palette at the bottom, click and drag to select a rectangular group of tiles. When you paint with a multi-tile selection, the entire group is placed as one unit. This is how you place multi-tile objects like buildings, large trees, or decorative structures that span several cells.

**Randomization:** If you select multiple individual tiles (Shift+click in the palette), the Paint tool randomly picks one of them for each cell you paint. This is useful for ground variation — select three or four grass variants, then paint freely and the ground gets natural-looking variety without you placing each variant by hand.

**Scattering:** Set the Scattering value above 0 in the TileMap toolbar to randomly skip cells while painting. Treat this as a rough-in tool only. For Crystal Saga, final decoration should be hand-edited: a few flowers by a path, cracks near old stone, grass tufts where they make visual sense. Do not leave broad percentage-painted decoration in the finished map.

> **See:** [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html), the official guide covering all painting tools, randomization, scattering, and patterns.

### Building Willowbrook

This is the creative part. You're designing a town by painting tiles directly in the Godot editor — there's no "right answer" and no grid template to follow. Think about what a small starting village looks like in the JRPGs you've played: a few buildings connected by paths, some trees and natural features, and a clear exit leading to the next area.

**Design goals for Willowbrook:**

- **Paths** that connect buildings and lead to an exit on the south edge (the player will walk to the forest in Module 7)
- **Two or three buildings** (a shop, an inn, and an elder's house are enough for now)
- **Some water** on one side — a pond or a stream running along an edge
- **Trees** around the perimeter to create natural boundaries and make the town feel nestled in the surrounding wilderness
- **Open space** — don't fill every cell. Leave room for the player to walk around, and leave some grass visible. Real towns have empty space.

**If you've never designed a tilemap before,** here's a starter layout to work from. You can modify it freely; the goal is to give you a concrete starting point rather than a blank canvas:

```
Key: . = grass, # = path, W = water, T = tree, B = building, _ = exit

          North
    T T T T T T T T T T
    T . . . B B . . . T
    T . . . # # . . . T
    T . B B # # . . . T
    T . . . # # B B . T
    T . . . # # . . . T
    T W W . # # . . . T
    T W W . # # . . . T
    T . . . # # . . . T
    T T T T _ _ T T T T
          South (exit)
```

Place buildings as 2x2 or 3x2 clusters of wall/roof tiles. The path runs north-south through town, with branches to each building. Water sits in the west. Trees ring the perimeter. The south edge has a gap for the exit to the forest (Module 7).

**Paint it layer by layer:**

1. **Ground layer first.** Select the `Ground` layer in the scene tree. Pick a grass tile from the palette. Use **Bucket Fill** to cover a generous area (around 30x20 tiles or larger — you can always shrink it later). Now switch to the **Paint** tool, select a path or dirt tile, and paint the paths by hand. Drag them in natural shapes: a main road through town, a few branches to the buildings. Add water tiles along one edge. Press **F6** to run the scene and walk around. Adjust until it feels like a good size — not so small that it's cramped, not so large that it's empty.

2. **Objects layer.** Select the `Objects` layer. Paint buildings as rectangular clusters of wall and roof tiles. Place trees around the edges and between buildings. Add fences, signs, or rocks where they make sense. Use **Ctrl+click** (Picker) to grab tiles from the viewport when you want to reuse something you already placed. If your tile sheet has multi-tile objects (like a 2x2 tree), select all the tiles as a group in the palette and place them together.

3. **Detail layer.** Select the `Detail` layer. This is for the finishing touches: flowers along paths, cracks in stone, grass variations over the base ground, path border tiles that soften the edge between dirt and grass. **Keep it sparse and intentional.** Place a few details where the player's eye should go. If you use Scattering to sketch ideas, immediately hand-edit the result so the final map does not look sprayed on.

4. **AbovePlayer layer.** If you have treetop canopy tiles or roof overhangs, place them on this layer. Anything here draws on top of the player sprite, which creates the illusion of walking under trees or into doorways.

After each layer, press **F6** to run and walk around. Does it look right? Is there enough room to move? Are the buildings visible? Adjust as you go.

> **Tip:** Middle-click and drag to pan the viewport. Scroll wheel to zoom. Right-click erases, and **Ctrl+click** picks a tile from the viewport. Get comfortable with these controls and painting goes fast.

## Adding Collision to Tiles

Right now, the player walks through everything. We need to mark certain tiles as solid.

### Step 1: Add a Physics Layer to the TileSet

1. Select any TileMapLayer node to access the TileSet.
2. In the Inspector, expand the TileSet resource.
3. Under **Physics Layers**, click **Add Element**.
4. This creates a physics layer that tiles can use for collision.

### Step 2: Mark Tiles as Solid

1. In the TileSet panel (bottom of editor), click the **Paint** tab (not "Setup" or "Select").
2. In the paint property dropdown (left side of the panel), select **Physics Layer 0**.
3. Now click on each tile that should be solid: wall tiles, water tiles, tree trunks, and building exteriors. Each click fills the tile with a blue collision rectangle.
4. If you need to remove collision from a tile, right-click it to clear it.

> **Alternative method:** If you prefer more control, switch to the **Select** tab instead. Click on a tile, then in the properties panel on the right, expand **Physics → Physics Layer 0**. Click **Add Collision Polygon**, or right-click the collision area and choose **Reset to default tile shape** to fill the entire tile. The Paint method above is faster for marking many tiles at once.

Repeat until every tile type that should block the player has collision: walls, water, tree trunks, building exteriors.

> **Note:** You only need to set collision on the tile *definition* in the TileSet, not on each placed tile individually. Once a tile type has collision, every instance of that tile on the map is solid.

> **Warning:** All four TileMapLayers share the same TileSet, so a tile marked as solid will block the player on *any* layer it appears. If the player seems stuck in open areas, check whether a ground tile (like grass or dirt) was accidentally given collision. Only mark tiles that should actually block movement: walls, water, tree trunks, and building exteriors.

### Step 3: Test It

First, resize the player's collision shape to fit the tile-based world. Open `player/player.tscn`, select the `CollisionShape2D` node, and in the Inspector set the shape's **Size** to `Vector2(14, 10)` and **Position** to `Vector2(0, 4)`. The 64x64 collision from Module 3 was sized for the Godot icon, and it's far too large for 16x16 tile corridors. The smaller shape represents the player's feet, so they can walk through tile-width paths.

Instance the Player scene into `Willowbrook` (drag `player/player.tscn` from the FileSystem dock into the viewport). Run with **F6** (which runs the current scene directly, not F5, which runs the main scene). Try walking into walls and water. The player should collide and slide along surfaces.

> **Note:** Your main scene is still `main.tscn` from Module 1. That's fine; we use F6 to test Willowbrook directly. In Module 7, we'll build a proper SceneManager and set up scene transitions.

## Camera2D: Following the Player

Play any early Legend of Zelda game and you will feel the camera snap rigidly to Link's position, where every pixel of movement translates directly to camera movement, which feels jittery at high speeds. Modern JRPGs like OMORI use camera smoothing so the viewport glides gently to follow the player, creating a more cinematic feel. Camera limits are equally important: without them, the camera reveals the void beyond the map edge when the player walks near a boundary, breaking the illusion that this is a real place. Pokemon never lets you see past the edge of a route for exactly this reason.

If your map is larger than the screen, you need a camera. Open the Player scene (`player.tscn`) and add a **Camera2D** node as a child:

```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
└── Camera2D
```

Select the Camera2D and set these properties in the Inspector:

- **Enabled:** `true` (should be by default)
- **Position Smoothing → Enabled:** `true`
- **Position Smoothing → Speed:** `5.0`

The camera now follows the player with a slight smoothing effect, which feels much better than rigid 1:1 tracking.

### Camera Limits

To prevent the camera from showing empty space beyond the map edges, set camera limits:

In the Camera2D Inspector:
- **Limit → Left:** `0`
- **Limit → Top:** `0`
- **Limit → Right:** your map's width in pixels (e.g., `640`)
- **Limit → Bottom:** your map's height in pixels (e.g., `480`)

To calculate your map's pixel dimensions: count the tiles you painted horizontally and vertically, then multiply by the tile size. For example, a 40×30 map with 16px tiles is 640×480 pixels. If you're unsure of your exact count, use a generous estimate like `800` × `600`. You can fine-tune later.

> **See:** [Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html), covering all Camera2D properties including limits, zoom, smoothing, and drag margins.

## Pixel-Perfect Rendering Checklist

If your tiles look blurry, have gaps between them, or shimmer when the camera moves, check these settings:

1. **Project Settings → Rendering → Textures → Default Texture Filter:** `Nearest` (set in Module 1)
2. **Project Settings → Display → Window → Stretch → Mode:** `canvas_items`
3. **Camera2D → Position Smoothing:** Keep the speed moderate (3-8). Very high values can cause sub-pixel jitter.
4. **Import settings on tile sheet:** Select the PNG in FileSystem, go to the Import tab, ensure **Filter** is `Nearest` (or `Off`). Click **Reimport**.

> **See:** [Viewport and canvas transforms](https://docs.godotengine.org/en/stable/tutorials/2d/2d_transforms.html), explaining how coordinates, viewports, and rendering relate in 2D.

> **Warning:** Blurry tiles and "pixel swimming" (tiles that seem to jitter by one pixel as the camera scrolls) are the most common visual issues in pixel art games. The fix is almost always in the texture filter and viewport stretch settings.

## Organizing the Scene

Your Willowbrook scene should now look like this:

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── Objects (TileMapLayer)
├── AbovePlayer (TileMapLayer)
└── Player (player.tscn instance)
```

Later (in Module 7), the Player will be spawned by the SceneManager rather than placed directly in the scene. But for now, having it here lets us test immediately.

## A Note on Tile Art

You're probably looking at your map and thinking it looks... rough. That's okay. Programmer art is a rite of passage. The important thing is that the *systems* work: the layers, the collision, the camera.

When you're ready, you can:
- Find free tile packs (Kenney, OpenGameArt, itch.io)
- Commission custom art
- Learn pixel art yourself (Aseprite is the standard tool)

Swapping the art is just changing the tile sheet image and reassigning it in the TileSet. The map layout, collision, and layer structure stay the same.

## Engineering Contract

- **Global state:** None; the map is scene-local content.
- **Public surface:** Named TileMapLayer nodes (`Ground`, `Detail`, `Objects`, `AbovePlayer`) that later modules can rely on.
- **Invariant:** Collision belongs on blocking tiles, visual decoration stays sparse and intentional, and player walkable space stays readable.
- **Failure behavior:** Bad tile coordinates or missing collision are corrected in the TileSet/scene before scripting depends on them.
- **Copy semantics:** TileSet and atlas resources are shared project assets; scene edits reference them rather than cloning them.

## Engine Gotcha

TileMapLayer is the Godot 4 workflow this series uses. Treat terrain painting and collision as editor-authored data: if a terrain set or collision layer is not configured in the TileSet, script calls cannot infer it for you.

## What We've Learned

- **TileMapLayer** nodes render grids of tiles from a **TileSet** resource.
- **TileSets** are created from tile sheet images (atlases). Set the tile size before creating the atlas.
- **Multiple layers** (Ground, Detail, Objects, AbovePlayer) create depth and visual richness.
- **Physics layers** on the TileSet make tiles solid. Set collision on the tile definition, not on each placed tile.
- **Camera2D** follows the player. Use position smoothing and limits for a polished feel.
- **Pixel-perfect settings:** `Nearest` texture filter, `canvas_items` stretch mode, and consistent tile sizes prevent blurriness and jitter.
- `TileMapLayer` replaces the deprecated `TileMap` node, using one node per layer.

## What You Should See

When you press F6 (to run the Willowbrook scene directly):
- A tiled town with ground, paths, and objects
- The player character walks around with arrow keys
- The player collides with walls, water, and solid objects
- The camera follows the player smoothly
- Tiles are crisp and pixel-perfect (no blurriness)

## Next Module

We have a town, but our player is still the Godot icon sliding around lifelessly. In **Module 6: Bringing the Player to Life**, we'll add sprite animations (walk cycles in four directions), implement a proper enum-based state machine, and add Y-sorting so the player walks behind trees and in front of paths.


---

<!-- Source: 06_player_character.md -->

# Module 6: Bringing the Player to Life

## What We Have So Far

A tiled town (Willowbrook) with collision, a camera that follows the player, and physics-based movement. But the player is still the Godot icon, sliding around without animation.

## What We're Building This Module

A fully animated player character with four-directional walk cycles, a proper state machine to manage behavior, and Y-sorting for correct depth rendering. By the end, the player character will have proper walk cycles and depth sorting. It'll look like an actual JRPG.

## Sprite Sheets and Walk Cycles

JRPG characters are typically drawn as **sprite sheets**, single images containing all animation frames arranged in a grid. A standard 4-direction character has frames like this:

```
Row 0: Walk Down:  frame 0, 1, 2, 3
Row 1: Walk Left:  frame 0, 1, 2, 3
Row 2: Walk Right: frame 0, 1, 2, 3
Row 3: Walk Up:    frame 0, 1, 2, 3
```

Each row is a direction, each column is a frame of the walk animation. Most JRPG characters use 3-4 frames per direction.

You have two options for the character sprite. **Option A** is fastest and works without downloading anything. **Option B** looks better if you have time.

### Option A: Godot Icon Fallback (recommended for first playthrough)

Use the Godot `icon.svg` as your character sprite. This is the fastest way to keep moving. Set up AnimatedSprite2D with single-frame animations using the icon for all 8 animations (`idle_down`, `idle_up`, `idle_left`, `idle_right`, `walk_down`, `walk_up`, `walk_left`, `walk_right`). The walk animations won't visually animate, but the state machine code will work correctly, and you can swap in real art later.

Skip ahead to the **"Adding Single-Frame Animations"** section below (search for that heading). You'll rejoin the main flow at **"The State Machine Pattern."** Here are the single-frame setup steps:

1. In the SpriteFrames panel, rename the `default` animation to `idle_down`.
2. Click "Add Animation" seven more times for: `idle_up`, `idle_left`, `idle_right`, `walk_down`, `walk_up`, `walk_left`, `walk_right`.
3. For each animation, drag `icon.svg` from the FileSystem dock into the frames area.
4. Set FPS to 8 and enable looping for the walk animations.

### Option B: Download a sprite sheet

Download a free character sprite sheet from one of these sources:

1. Go to [kenney.nl/assets/tiny-town](https://kenney.nl/assets/tiny-town) (the same pack from Module 5). In the extracted ZIP, `tilemap_packed.png` contains small 16x16 character tiles in the lower portion of the sheet.

2. Alternatively, search [opengameart.org](https://opengameart.org) for "JRPG character sprite sheet 16x16". Look for a sheet with **4 rows** (one per direction: down, left, right, up) and **3-4 columns** (frames per walk cycle).

> **Note:** If your sprite sheet has a different layout (e.g., 3 frames instead of 4, or rows in a different order like down/up/left/right), that's fine. Just adjust the frame selection when setting up animations below. The script we write works with any 4-direction animation names.

Save your sprite sheet to `res://player/player_spritesheet.png`.

## Setting Up AnimatedSprite2D

In the original Final Fantasy on NES, characters barely animated (they shuffled two frames when walking) and the world still felt more alive than a static sprite sliding across the screen like a chess piece. Walk cycle animation transforms a game object into a character. It conveys weight, personality, and direction. When Crono walks in Chrono Trigger, his cape bounces and his legs pump, even though it is only 4 frames of animation, it sells the illusion of a living person.

Open `player/player.tscn`. We're going to replace the `Sprite2D` with an `AnimatedSprite2D`, which handles frame-based animation natively.

1. **Delete** the existing `Sprite2D` node.
2. Add an **AnimatedSprite2D** node as a child of Player.
3. Rename it to `Sprite`.

Your scene tree:
```
Player (CharacterBody2D)
├── Sprite (AnimatedSprite2D)
├── CollisionShape2D
└── Camera2D
```

In Module 5, we resized the collision shape to `Vector2(14, 10)` to fit tile corridors. That size was matched to the Godot icon, which is wider than a typical 16x16 character sprite. Now that we're using an actual character, shrink it to fit: set the shape's **Size** to roughly `Vector2(12, 8)` and the **CollisionShape2D** node's **Position** (under Transform) to `Vector2(0, 4)` so it covers just the character's feet. We'll discuss why this "feet-only" collision matters later in this module.

### Creating a SpriteFrames Resource

A SpriteFrames resource is the animation library for a character. In games like Pokemon, every character has a consistent set of animations (walk_up, walk_down, walk_left, walk_right, idle), and the game engine picks the right one based on the character's current state and direction. By storing these as named animations, you can swap an entire character's appearance just by assigning a different SpriteFrames: replace the hero's animations with a disguise, or reuse the same walking logic for every NPC by giving each one unique SpriteFrames with their own art.

AnimatedSprite2D uses a **SpriteFrames** resource to define animations.

1. Select the `Sprite` (AnimatedSprite2D) node.
2. In the Inspector, find **Sprite Frames** and click to create a **New SpriteFrames**.
3. The SpriteFrames panel opens at the bottom of the editor.

### Adding Animations from a Sprite Sheet

In the SpriteFrames panel:

1. You'll see a `default` animation. Rename it to `idle_down`.
2. Click the **Add frames from Sprite Sheet** button (it has a grid pattern icon; hover over the buttons near the top of the SpriteFrames panel to find it).
3. Select your sprite sheet image.
4. Set the grid size to match your sheet (e.g., 4 columns × 4 rows for a 4-direction, 4-frame sheet).
5. Click the frames for the "facing down idle" pose (usually just the first frame of the down row).
6. Click **Add Frames**.

Repeat for each animation:
- `idle_down`: the standing frame facing down
- `idle_up`: standing facing up
- `idle_left`: standing facing left
- `idle_right`: standing facing right
- `walk_down`: all frames of the down walk cycle
- `walk_up`: all frames of the up walk cycle
- `walk_left`: all frames of the left walk cycle
- `walk_right`: all frames of the right walk cycle

Here's a reference table for a 4-column × 4-row sprite sheet (down/left/right/up):

| Animation | Row | Frames to Select |
|-----------|-----|-----------------|
| `idle_down` | 0 | Frame 0 only |
| `idle_left` | 1 | Frame 0 only |
| `idle_right` | 2 | Frame 0 only |
| `idle_up` | 3 | Frame 0 only |
| `walk_down` | 0 | Frames 0, 1, 2, 3 |
| `walk_left` | 1 | Frames 0, 1, 2, 3 |
| `walk_right` | 2 | Frames 0, 1, 2, 3 |
| `walk_up` | 3 | Frames 0, 1, 2, 3 |

For each walk animation, set the **FPS** to 8-10 (the number field at the top of the SpriteFrames panel, next to the loop toggle, the circular arrow icon). Also enable looping for walk animations by clicking that loop toggle. Idle animations can stay at the default speed since they're typically a single frame (or 2-3 frames for a breathing animation).

> **Warning:** Animation names must match **exactly** what the script expects. The code constructs names like `"walk_down"` and `"idle_left"` dynamically. If you name an animation `Walk_Down` or `walkdown`, it won't be found. Use all lowercase with an underscore: `idle_down`, `walk_up`, etc.

> **See:** [2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html), covering both AnimatedSprite2D and AnimationPlayer approaches to 2D animation.

> **See:** [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html), the full API reference.

### The Alternative: Sprite2D + AnimationPlayer

There's another way to animate sprites in Godot: using a regular `Sprite2D` with an `AnimationPlayer` that keyframes the `frame` property or `region_rect`. This approach is more powerful (you can animate any property), but more complex to set up.

For character walk cycles, `AnimatedSprite2D` is simpler and perfectly adequate. We'll use `AnimationPlayer` later for UI animations and battle effects where we need to animate multiple properties simultaneously.

> **See:** [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html), for when you need to animate arbitrary properties.

## The State Machine Pattern

Right now, our player script is simple: check input, set velocity, move. But as we add features, the logic gets tangled:

- Can the player move during dialogue? (No.)
- Can the player open the inventory while walking? (Yes, but movement should stop.)
- What happens when the player interacts with an NPC? (Face the NPC, stop moving, wait for dialogue to finish.)
- Can the player move during a cutscene? (No.)

Without structure, you end up with a mess of boolean flags: `is_talking`, `is_in_menu`, `can_move`, `is_cutscene_active`. Each new feature adds another flag, and the interactions between them become impossible to reason about.

The solution is a **state machine**: the player is always in exactly one state, and each state defines what the player can and can't do.

### Our Four States

```
IDLE:       standing still, can accept input
WALK:       moving, playing walk animation
INTERACT:   talking to NPC or object, movement disabled
DISABLED:   cutscene, battle transition, or menu, movement disabled
```

### The Rules

| From | To | When |
|------|----|------|
| IDLE | WALK | Movement input detected |
| WALK | IDLE | Movement input released |
| IDLE | INTERACT | Player presses interact near an NPC |
| INTERACT | IDLE | Dialogue finishes |
| Any | DISABLED | Cutscene starts / battle starts / menu opens |
| DISABLED | IDLE | Cutscene ends / battle ends / menu closes |

The key insight: **each state is a self-contained behavior.** The IDLE state checks for movement and interact input. The WALK state plays the walk animation and moves. The INTERACT state does nothing; it waits for a signal that dialogue is finished. The DISABLED state is completely inert.

This enum-based state machine is the right size for player movement: one script owns all states, and every state is only a few lines. In Module 14, battle flow gets complex enough that we switch to a node-based state machine, where each state is its own script. Same idea, different scale.

### Implementation

Replace the entire contents of `res://player/player.gd` with this state machine version:

```gdscript
extends CharacterBody2D
## The player character with state-machine-driven movement and animation.

# GDScript enums define a set of named integer constants.
# This creates State.IDLE = 0, State.WALK = 1, State.INTERACT = 2, State.DISABLED = 3.
# We use them instead of raw integers so the code reads as words, not magic numbers.
enum State { IDLE, WALK, INTERACT, DISABLED }

@export var speed: float = 200.0

var current_state: State = State.IDLE
var facing_direction: Vector2 = Vector2.DOWN  # Vector2(0, 1), positive Y is downward in Godot

@onready var sprite: AnimatedSprite2D = $Sprite


func _physics_process(_delta: float) -> void:
    match current_state:
        State.IDLE:
            _state_idle()
        State.WALK:
            _state_walk()
        State.INTERACT:
            _state_interact()
        State.DISABLED:
            _state_disabled()


func _state_idle() -> void:
    velocity = Vector2.ZERO
    _play_animation("idle")

    var direction := _get_input_direction()
    if direction != Vector2.ZERO:
        facing_direction = direction
        _change_state(State.WALK)


func _state_walk() -> void:
    var direction := _get_input_direction()

    if direction == Vector2.ZERO:
        _change_state(State.IDLE)
        return

    facing_direction = direction
    velocity = direction.normalized() * speed
    _play_animation("walk")
    move_and_slide()


func _state_interact() -> void:
    velocity = Vector2.ZERO
    # Waiting for interaction to complete. Controlled externally.


func _state_disabled() -> void:
    velocity = Vector2.ZERO
    # Completely inert: cutscene, menu, or battle transition.


func _change_state(new_state: State) -> void:
    current_state = new_state


func _get_input_direction() -> Vector2:
    return Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down"),
    )


func _play_animation(action: String) -> void:
    var direction_name := _direction_to_string(facing_direction)
    var anim_name := action + "_" + direction_name
    if sprite.sprite_frames.has_animation(anim_name):
        sprite.play(anim_name)


func _direction_to_string(direction: Vector2) -> String:
    # Determine the dominant axis for 4-directional facing
    if abs(direction.x) > abs(direction.y):
        return "right" if direction.x > 0 else "left"
    else:
        return "down" if direction.y >= 0 else "up"


## Call this from external systems to disable/enable the player.
func set_disabled(disabled: bool) -> void:
    if disabled:
        _change_state(State.DISABLED)
    else:
        _change_state(State.IDLE)


## Call this when the player starts interacting with something.
func start_interaction() -> void:
    _change_state(State.INTERACT)


## Call this when the interaction is complete.
func end_interaction() -> void:
    _change_state(State.IDLE)
```

Here's why we made these choices:

### The `match` Statement

```gdscript
match current_state:
    State.IDLE:
        _state_idle()
    State.WALK:
        _state_walk()
```

The `match` statement routes to the correct state handler each frame. Each state is a separate function with a clear name. This is much cleaner than nested `if/elif` blocks.

### Facing Direction

`facing_direction` is a `Vector2` that remembers which way the player last moved. We use it to choose the correct animation even when standing still (idle_down, idle_left, etc.).

The `_direction_to_string()` function converts a Vector2 direction into "up", "down", "left", or "right" by checking which axis has the larger magnitude. This handles diagonal input gracefully: if you press right and slightly down, you face right.

### Public Methods for External Control

`set_disabled()`, `start_interaction()`, and `end_interaction()` are **public methods** that other systems call to control the player's state. The dialogue system will call `start_interaction()` when a conversation begins and `end_interaction()` when it ends. The battle system will call `set_disabled(true)` during transitions.

This keeps the state machine's logic internal while providing a clean API for the rest of the game.

> **Spiral:** We'll revisit state machines in Module 14 when we build the battle system. The battle state machine is more complex (7+ states with complex transitions), so we'll upgrade from this enum-based approach to a **node-based** state machine. The enum approach works great for the player's 4 simple states.

## Y-Sorting: Correct Depth Ordering

Without Y-sorting, you get a common visual bug: the player walks south past a tree and the tree renders on top of them, but walking north past the same tree puts the player on top. In Final Fantasy VI, Y-sorting is what makes towns feel three-dimensional despite being flat 2D art. When Terra walks behind a market stall, the stall's roof covers her sprite. When she walks in front of it, she covers the stall. The engine draws objects sorted by their Y position: objects higher on the screen (further away) are drawn first, objects lower (closer) are drawn on top.

In a top-down 2D game, objects lower on the screen should appear in front of objects higher on the screen. This creates the illusion of depth. The player walks "behind" a tree when they're above it, and "in front of" a tree when they're below it.

Godot handles this with **Y-sort**. When enabled on a parent node, its children are drawn sorted by their Y position: lower Y values are drawn first (behind), higher Y values are drawn last (in front).

### Setting Up Y-Sort

In the Willowbrook scene:

> **Tip:** To reparent a node, drag it in the Scene dock and drop it onto the new parent node. The node moves in the tree hierarchy. You'll use this technique in the steps below.

1. Add a new **Node2D** as a child of `Willowbrook`. Rename it to `YSortGroup`.
2. In the Inspector, find **CanvasItem → Ordering → Y Sort Enabled** and turn it **on**.
3. Drag the `Objects` TileMapLayer onto `YSortGroup` to reparent it (it becomes a child of YSortGroup instead of Willowbrook).
4. Drag the `Player` instance onto `YSortGroup` the same way.
5. Select the `Objects` TileMapLayer. In the Inspector, find **CanvasItem → Ordering → Y Sort Enabled** and turn it **on** for this node too.

> **Warning:** This step is essential. Without `y_sort_enabled` on the `Objects` TileMapLayer itself, the individual tiles within the layer won't sort against the player. The entire layer renders as a single block, causing the player to appear always in front of or always behind all objects. If your trees and buildings are sorting incorrectly, this is the first thing to check.

Now set the Y Sort Origin for the Objects layer so tiles sort by their bottom edge:
1. With `Objects` still selected, find **Y Sort Origin** in the Inspector and set it to `16` (the tile height in pixels). This makes tiles sort based on their bottom edge rather than their top-left corner, which looks correct for trees, rocks, and buildings.

The AbovePlayer layer should **not** be Y-sorted with the player; it should always draw on top. Keep it outside the Y-sorted group, or set its Z-index higher.

> **See:** [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html), covering the `y_sort_enabled` property and how it affects rendering order.

### A Practical Scene Structure

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── YSortGroup (Node2D, y_sort_enabled = true)
│   ├── Objects (TileMapLayer, y_sort_origin adjusted)
│   └── Player (player.tscn instance)
└── AbovePlayer (TileMapLayer)
```

The `YSortGroup` node sorts the Objects layer tiles and the Player by their Y positions. Ground and Detail are always below everything. AbovePlayer is always on top.

## Adjusting the Collision Shape

We already set the collision shape values earlier in this module when we added the AnimatedSprite2D. This section explains the *reasoning* behind feet-only collision, so you understand why we chose those specific values.

With animated sprites, you want the collision shape to be:

- **Shorter** than the sprite, roughly the bottom third or half. This represents the player's "feet" area.
- **Offset downward** so it aligns with the feet, not the center of the sprite.

Our values (`Vector2(12, 8)` size, `Vector2(0, 4)` offset) give the player a small collision "footprint" that feels natural. The player's head and torso can overlap with objects above, but their feet are blocked by solid tiles.

> **JRPG Pattern:** Almost every JRPG uses "feet-only" collision. It's why you can walk close to a table and it looks like you're standing at the table, not being blocked a full character-width away.

## Grid-Based vs Free Movement

We've implemented **free movement**: the player moves smoothly in any direction at any time. This is what most modern JRPGs use (and what Crystal Saga will use).

The alternative is **grid-based movement**, where the player snaps from one tile to the next in discrete steps. This is what classic JRPGs (Final Fantasy I-VI, Dragon Quest I-V, Pokemon) use.

| Aspect | Free Movement | Grid-Based |
|--------|--------------|------------|
| Feel | Smooth, modern | Crisp, retro |
| Implementation | Simpler (what we've built) | More complex (tween between grid cells) |
| Collision | Per-pixel via physics | Per-tile via grid lookup |
| NPC interaction | Distance + facing direction | Adjacent tile check |
| Map alignment | Objects can be anywhere | Everything aligns to grid |

Grid-based movement is elegant for tile-heavy games but requires a different architecture (tweening between positions, checking the grid for obstacles before moving). We're using free movement because it's more flexible and natural-feeling for our scope.

## Engineering Contract

- **Global state:** None; player movement lives on the player scene instance.
- **Public surface:** The player joins the `"player"` group and exposes predictable movement/animation state.
- **Invariant:** Movement input produces one deterministic velocity per frame, then `move_and_slide()` resolves collisions.
- **Failure behavior:** Unknown or missing input actions should result in no movement, not script errors.
- **Copy semantics:** The player scene can be instanced in multiple maps; runtime state belongs to the instance.

## Engine Gotcha

`CharacterBody2D` does not move by assigning `position` directly. Set `velocity`, call `move_and_slide()`, and let Godot resolve collision against the physics world during the physics frame.

## What We've Learned

- **Sprite sheets** contain all animation frames. **AnimatedSprite2D** plays frame-based animations from a **SpriteFrames** resource.
- A **state machine** organizes player behavior into discrete states (IDLE, WALK, INTERACT, DISABLED), preventing conflicting behavior.
- The **enum + match** pattern is a clean way to implement a simple state machine.
- **Public methods** (`set_disabled`, `start_interaction`) give other systems controlled access to the state machine.
- **Y-sorting** creates correct depth ordering, where lower objects appear in front.
- **Feet-only collision** (small, low CollisionShape2D) feels natural in top-down JRPGs.
- **Free movement** is smoother and simpler than grid-based; Crystal Saga uses free movement.
- **Facing direction** persists so idle animations face the last movement direction.

## What You Should See

When you press F6 (running the Willowbrook scene):
- The player has animated walk cycles in four directions
- The player stands idle facing the last direction they moved
- Y-sorting works: the player walks behind trees and in front of paths
- Collision with the tilemap works (player stops at walls, can't walk through water)
- The feet-only collision allows the player's head to overlap slightly with objects

## Next Module

We have a living player in a real town, but there's nowhere to go. In **Module 7: Connecting Worlds**, we'll build a second area (Whisperwood Forest), create exit zones that trigger scene transitions, and build our first autoload (the SceneManager) that handles fade-to-black transitions between locations.


---

<!-- Source: 07_scene_transitions.md -->

# Module 7: Connecting Worlds: Scene Transitions

## What We Have So Far

An animated player character with a state machine, walking around the town of Willowbrook with proper collision and Y-sorting. But the town is an island, and there's no way to leave.

## What We're Building This Module

A second area (Whisperwood Forest), exit zones that detect when the player walks to the edge of a map, and a **SceneManager** autoload that handles smooth fade-to-black transitions between locations. By the end, Crystal Saga will have two areas you can walk between.

## Why Scenes Map to Locations

In a JRPG, each location is typically one scene:

- Willowbrook (town) → `willowbrook.tscn`
- Whisperwood (forest) → `whisperwood.tscn`
- Crystal Cavern (dungeon) → `crystal_cavern.tscn`
- Battle Screen → `battle.tscn`

When the player walks to the edge of town, the game transitions to the forest. When they walk to the forest entrance, it transitions back to town. This is a **scene change**: the current scene is freed (removed from memory), and the new scene is loaded and instanced.

The challenge: how do we manage these transitions cleanly? Who handles the fade effect? How does the new scene know where to spawn the player?

The answer is our first **autoload**.

## Autoloads: Your First Project Singleton

You've been using Godot-provided global singletons since Module 2. `Input`, `Engine`, `Time`, `Performance`, and `AudioServer` are built into the engine and are globally available by name.

Now we're going to create our own project autoload.

An **autoload** (also called a project singleton) is a scene or script that Godot registers under `/root`:
1. Is loaded automatically when the game starts
2. Persists across scene changes (it's never freed)
3. Is accessible from anywhere by name

This makes autoloads perfect for game-wide systems: scene management, inventory, audio, quest tracking, game state. We'll build several throughout this tutorial.

> **See:** [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html), the official guide to autoloads, including when and why to use them.

> **Warning:** Autoloads are powerful but easy to overuse. Not everything needs to be global. If a system only matters within a single scene (like the layout of a specific room), keep it local. We'll use autoloads for systems that genuinely need to persist across the entire game.

## Building the SceneManager

The SceneManager handles scene transitions: fading out, loading the new scene, fading in, and positioning the player at the correct spawn point.

### Step 1: Create the Script

Create a new folder `res://autoloads/` and a new script `res://autoloads/scene_manager.gd`:

```gdscript
extends Node
## Manages scene transitions with fade effects.
## Registered as an autoload. Accessible as SceneManager from anywhere.

signal transition_started
signal transition_finished

@onready var _color_rect: ColorRect = $TransitionLayer/ColorRect
@onready var _anim_player: AnimationPlayer = $TransitionLayer/AnimationPlayer

var _target_scene_path: String = ""
var _target_spawn_point: String = ""
var _is_transitioning: bool = false


func change_scene(scene_path: String, spawn_point: String = "default") -> void:
    if _is_transitioning:
        return

    _is_transitioning = true
    _target_scene_path = scene_path
    _target_spawn_point = spawn_point

    transition_started.emit()
    _anim_player.play("fade_out")
    await _anim_player.animation_finished

    get_tree().change_scene_to_file(_target_scene_path)

    # Wait for the new scene to be fully loaded and added to the tree.
    # change_scene_to_file() is deferred, so we need to wait for the swap.
    await get_tree().scene_changed

    _place_player_at_spawn()

    _anim_player.play("fade_in")
    await _anim_player.animation_finished

    _is_transitioning = false
    transition_finished.emit()


func _place_player_at_spawn() -> void:
    # Find the spawn point marker in the new scene
    var spawn_markers := get_tree().get_nodes_in_group("spawn_points")
    for marker in spawn_markers:
        if marker.name == _target_spawn_point:
            var player := get_tree().get_first_node_in_group("player")
            if player:
                player.global_position = marker.global_position
            return

    # If no matching spawn point, use "default"
    for marker in spawn_markers:
        if marker.name == "default":
            var player := get_tree().get_first_node_in_group("player")
            if player:
                player.global_position = marker.global_position
            return
```

### Step 2: Create the Scene

The SceneManager needs visible nodes (a ColorRect for the black overlay, an AnimationPlayer for the fade). Create a scene for it.

1. Create a new scene with `Node` as root. Rename it to `SceneManager`.
2. Set the root node's **Process → Mode** to **Always** in the Inspector. This ensures the SceneManager continues working even when the game is paused (which we'll use for the pause menu in Module 25).
3. Add a **CanvasLayer** child. Rename it to `TransitionLayer`. Set its **Layer** to `100` in the Inspector (so it draws on top of everything).

In every JRPG, the fade effects and dialogue boxes must render on top of the game world no matter where the camera is or how the scene is structured. In Earthbound, the swirling battle transition overlay covers everything: the map, the enemies, the party. A regular node would be affected by the camera's position and zoom, and could sort incorrectly with other nodes. CanvasLayer creates an entirely separate rendering surface that is immune to camera transforms and always draws at its designated layer number.

3. Inside `TransitionLayer`, add a **ColorRect** child. Set its color to black (`Color(0, 0, 0, 1)`).
4. Set the ColorRect to cover the full screen: **Layout → Anchors Preset → Full Rect** (or set all anchors to cover the viewport).
5. Set the ColorRect's **Modulate** alpha to `0` (fully transparent by default).
6. Add an **AnimationPlayer** as a child of `TransitionLayer`.

### Step 3: Create the Fade Animations

Select the AnimationPlayer and create two animations. Here's the step-by-step for the first one:

**`fade_out`** (0.3 seconds):
1. In the Animation panel at the bottom, click **Animation → New**. Name it `fade_out`.
2. Set the animation length to `0.3` (the number field next to the timeline).
3. Click **Add Track → Property Track**. Select the `ColorRect` node.
4. Choose the **`modulate`** property from the list.
5. Right-click the timeline at time `0.0` and choose **Insert Key**. Set the value's alpha to `0.0` (transparent).
6. Right-click at time `0.3` and insert another key. Set alpha to `1.0` (fully opaque/black).

> **See:** [Introduction to animations](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html), explaining how to create animations with property tracks in AnimationPlayer.

**`fade_in`** (0.3 seconds):
Same process, but reversed:
- At time 0: `modulate` alpha = `1.0` (fully black)
- At time 0.3: `modulate` alpha = `0.0` (transparent)

Attach the `scene_manager.gd` script to the root `SceneManager` node. Save the scene as `res://autoloads/scene_manager.tscn`.

> **Note:** We use a CanvasLayer with a high layer number (100) so the fade overlay draws on top of everything: UI, game world, particles, all of it. CanvasLayer nodes exist outside the normal rendering order.

> **See:** [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html), explaining how CanvasLayer works and why it's essential for UI and overlays.

### Step 4: Register the Autoload

1. Go to **Project → Project Settings → Autoload**.
2. Click the folder icon and select `res://autoloads/scene_manager.tscn`.
3. The name will auto-fill as `SceneManager`. Keep it.
4. Click **Add**.

Now `SceneManager` is globally accessible. Any script in the game can call `SceneManager.change_scene(...)`.

> **See:** [Change scenes manually](https://docs.godotengine.org/en/stable/tutorials/scripting/change_scenes_manually.html), covering the built-in `change_scene_to_file()` and why a wrapper autoload is often needed.

## Understanding `await`

The SceneManager uses `await`, a GDScript keyword that pauses the function until a signal is emitted, then resumes.

```gdscript
_anim_player.play("fade_out")
await _anim_player.animation_finished  # Pause here until the animation finishes
# ...this code runs after the animation is done
```

This makes async sequences (fade out → change scene → fade in) readable as linear code. Without `await`, you'd need callbacks or a state machine just for the transition.

`await` can wait for any signal:
```gdscript
await get_tree().create_timer(1.0).timeout  # Wait 1 second
await some_node.some_signal                  # Wait for a custom signal
```

## Exit Zones

In every JRPG from Dragon Quest to Pokemon, walking to the edge of a town seamlessly transitions you to the next area. The player never clicks a "leave town" button; they just walk south and the game detects that they have crossed an invisible boundary. The alternative, checking the player's position every frame with `if position.x > map_width` is fragile, hard-coded, and needs rewriting for every map shape. Exit zones are reusable: the same script works on every map edge, every door, and every warp point.

An **exit zone** is an Area2D that detects when the player enters it and triggers a scene change. We'll set up bidirectional exits between Willowbrook and Whisperwood.

### Creating an Exit Zone

In the Willowbrook scene, add an Area2D:

1. Add an **Area2D** child to `Willowbrook`. Rename it to `ExitToWhisperwood`.
2. Add a **CollisionShape2D** child to the Area2D.
3. Set the shape to a `RectangleShape2D` and position/size it at the map edge where the forest exit should be (e.g., along the south edge of the map).

Create a script for exit zones. Save as `res://scenes/exit_zone.gd`:

```gdscript
extends Area2D
## A zone that triggers a scene transition when the player enters.

@export_file("*.tscn") var target_scene: String
@export var target_spawn_point: String = "default"


func _ready() -> void:
    # In Module 3, we connected signals through the editor UI. That works when both
    # sender and receiver are in the same scene and you are placing nodes manually.
    # But the exit zone script is designed to be reusable: attach it to any Area2D
    # in any scene and it just works. Connecting the signal in code means the
    # connection is self-contained. As your game grows, code-based connections
    # become the standard for reusable components.
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        SceneManager.change_scene(target_scene, target_spawn_point)
```

> **Note:** The Area2D's default collision mask monitors layer 1, which is the same layer the player's CharacterBody2D is on by default. If you changed collision layers in Module 5, make sure the exit zone's **Collision → Mask** includes the player's layer.

Attach this script to `ExitToWhisperwood`. In the Inspector, set:
- **Target Scene:** `res://scenes/whisperwood/whisperwood.tscn`
- **Target Spawn Point:** `from_town`

> **Note:** `@export_file("*.tscn")` creates a file picker in the Inspector that only shows `.tscn` files. Much easier than typing paths manually.

### Player Groups

The exit zone checks `body.is_in_group("player")`. We need to add the player to this group.

**Groups** are tags you can assign to any node. A node can belong to multiple groups, and you can find all nodes in a group with `get_tree().get_nodes_in_group("name")` or get the first match with `get_tree().get_first_node_in_group("name")`. Think of them as labels for querying; they let systems find nodes without hard-coded paths.

1. Open `player.tscn`.
2. Select the `Player` (CharacterBody2D) root node.
3. Go to the **Node** tab (next to Inspector) → **Groups** section.
4. Type `player` and click **Add**.

> **See:** [Groups](https://docs.godotengine.org/en/stable/tutorials/scripting/groups.html): Godot's node tagging system. We'll use groups again in later modules for encounter zones, UI elements, and save points.

### Spawn Points

In Pokemon, walking from Route 1 into Viridian City places you at the south entrance. Flying to Viridian City places you at the Pokemon Center. Same destination, different spawn position depending on how you arrived. This is why spawn points need names: the SceneManager doesn't just load a scene, it loads a scene and places you at a specific named location.

A spawn point is a simple **Marker2D** node that marks where the player should appear. Add them to your scenes:

In `willowbrook.tscn`:
1. Add a **Marker2D** node. Rename it to `default`.
2. Position it where the player should start (town center).
3. Add it to the `spawn_points` group.
4. Add another Marker2D named `from_forest`, positioned near the south exit.
5. Add it to the `spawn_points` group too.

The SceneManager's `_place_player_at_spawn()` finds these markers by group and name, and teleports the player to the matching one.

## Building Whisperwood Forest

Create a second area to connect to:

1. Create a new folder: `res://scenes/whisperwood/`
2. Create a new scene: `Node2D` root, rename to `Whisperwood`.
3. Save as `res://scenes/whisperwood/whisperwood.tscn`.

Reuse the same TileSet from Module 5 (`town_tileset.tres`). Add TileMapLayers using the same workflow (Ground, Detail, Objects, AbovePlayer) and assign the TileSet to each. In Module 16, we'll create a dedicated dungeon tileset with a different aesthetic.

Design a simple forest area (at least 20x15 tiles). Use grass tiles for ground, tree tiles for borders, and path tiles through the center:
- Ground layer: paint grass everywhere, then carve a 3-tile-wide path winding through the middle
- Objects layer: build the north and south borders out of tree trunks, rocks, and shrubs; collision belongs on the trunk/rock tiles, not on the grass path
- AbovePlayer layer: add canopy tiles above the tree line so the player can walk "under" the leaves
- An entrance on the north side (connecting to Willowbrook)
- An exit on the south side (leading to the Crystal Cavern, which we'll build in Module 16)

**Whisperwood scene structure checklist** (make sure you have all of these):

1. `Whisperwood` (Node2D), root
2. `Ground` (TileMapLayer), grass, paths
3. `Detail` (TileMapLayer), small decorations
4. `YSortGroup` (Node2D, `y_sort_enabled = true`)
   - `Objects` (TileMapLayer, `y_sort_enabled = true`), trees, rocks
   - Player instance (`player.tscn`)
5. `AbovePlayer` (TileMapLayer), treetop canopy
6. Spawn points (Marker2D nodes, added to `spawn_points` group):
   - `from_town`: near the north entrance
   - `default`: same position as `from_town`
7. Exit zone:
   - `ExitToWillowbrook` (Area2D + `exit_zone.gd`) at the north edge, pointing to `res://scenes/willowbrook/willowbrook.tscn` with spawn point `from_forest`

If you test and see an empty forest with no player, check that you instanced `player.tscn` into the YSortGroup (not the root).

> **Note:** For now, we're placing the Player instance directly in each scene. This means there are technically multiple Player instances across scenes. That's fine because only one scene is loaded at a time. In a more complex setup, you might have the SceneManager spawn the player dynamically.

## Signal Lifecycle Across Scene Changes

An important detail to understand: when you call `get_tree().change_scene_to_file()`, the current scene is **freed**, and all its nodes are removed from the tree and deleted. This means:

1. All signal connections within that scene are cleaned up automatically (as we discussed in Module 3).
2. The SceneManager's signals (`transition_started`, `transition_finished`) still work because the SceneManager is an autoload, so it's never freed.
3. Any signals connected TO an autoload FROM a scene node are also cleaned up when the scene node is freed, so there are no dangling references.

This is why autoloads are the right home for cross-scene systems. They're the stable foundation that persists while the world changes around them.

## Testing the Flow

1. Set `willowbrook.tscn` as the main scene (Project Settings → Application → Run → Main Scene).
2. Press F5.
3. Walk the player to the south exit.
4. The screen should fade to black, then the forest appears, with the player at the `from_town` spawn point.
5. Walk north in the forest to return to Willowbrook, arriving at the `from_forest` spawn point.

If it works, congratulations. You have a connected game world.

### Troubleshooting

| Problem | Likely Cause |
|---------|-------------|
| Player doesn't trigger the exit zone | Player not in `player` group, or exit zone collision shape is missing |
| Scene changes but player is at wrong position | Spawn point name doesn't match, or spawn point isn't in `spawn_points` group |
| Fade effect not visible | CanvasLayer layer not high enough, or ColorRect not covering the screen |
| Crash on scene change | Target scene path is wrong. Check for typos in the Inspector |
| Player stuck after transition | `_is_transitioning` flag not reset. Check `await` chain |

## The Autoload Reference Card

We'll maintain this running table throughout the tutorial, adding each new autoload as we build it:

| Autoload | Module | Purpose |
|----------|--------|---------|
| **SceneManager** | 7 | Scene transitions with fade effects |

*Updated in future modules as we add more autoloads.*

## Engineering Contract

- **Global state:** `SceneManager` is a project autoload registered under `/root/SceneManager`.
- **Public surface:** `change_scene(scene_path, spawn_id)`, transition signals, and spawn-point lookup.
- **Invariant:** Scene paths and spawn IDs are stable strings shared by exits, maps, and future save/load.
- **Failure behavior:** Missing scenes or spawn points should log a clear error and fall back safely.
- **Copy semantics:** Scene changes replace scene instances; persistent data must live outside the outgoing scene.

## Engine Gotcha

`change_scene_to_file()` is deferred. Any code that needs the new scene's nodes must wait for `SceneTree.scene_changed` before looking up the player or spawn points.

## What We've Learned

- **Autoloads** are globally accessible singletons that persist across scene changes. `SceneManager` is our first custom one.
- `Input`, `Engine`, `Time`, etc. are Godot's built-in autoloads; you've been using them since Module 2.
- **`get_tree().change_scene_to_file()`** is Godot's built-in scene change, but it's abrupt. A SceneManager adds fade transitions and spawn point management.
- **`await`** pauses a function until a signal fires, making async sequences readable as linear code.
- **Area2D exit zones** detect the player and trigger scene changes.
- **Spawn points** (Marker2D nodes in groups) tell the SceneManager where to place the player in the new scene.
- **CanvasLayer** with a high layer number draws overlays on top of everything.
- Signal connections are **automatically cleaned up** when scene nodes are freed. Autoload signals persist.
- **`@export_file("*.tscn")`** creates a filtered file picker in the Inspector.

## What You Should See

When you press F5:
- Playing in Willowbrook, walking to the south edge triggers a fade-to-black
- The Whisperwood forest fades in with the player at the entrance
- Walking north in the forest fades back to Willowbrook
- Transitions are smooth (0.3s fade out, 0.3s fade in)
- Player appears at the correct spawn point each time

## Next Module

We can explore two areas now, but the world feels empty. Before we add NPCs and dialogue, we need to establish our **data architecture**. In **Module 9: Resources, The Data Layer**, we'll learn how to define game data (items, characters, NPC info) as reusable, editor-friendly Resource classes. This is the foundation every system from inventory to combat will build on.


---

<!-- Source: 08_part_ii_review.md -->

# Module 8: Part II Review and Cheat Sheet

This module is a review and quick reference for everything covered in Part II (Modules 5-7). No new code, no new features. Just a consolidated look at what you built and a cheat sheet you can flip back to when you need a reminder.

## Part II in Review

At the start of Part II, you had a Player scene (CharacterBody2D with a sprite and collision) that could move around and handle physics. But the "world" was a blank screen. There was nothing to see, nothing to collide with, and nowhere to go.

Over three modules, you turned that blank canvas into a real game world. You built the town of Willowbrook tile-by-tile using TileMapLayers, layering ground, paths, objects, and treetops into a scene with actual depth. You replaced the sliding Godot icon with a sprite-animated player character driven by a proper state machine, one that knows whether it's idle, walking, interacting, or disabled. You added Y-sorting so the player walks behind trees and in front of paths. And you connected Willowbrook to a second area, Whisperwood Forest, via exit zones and a SceneManager autoload that handles fade-to-black transitions and spawn point placement.

The result is the skeleton of a real JRPG: two connected areas you can walk between, with an animated hero, tile-based collision, camera smoothing, and clean scene transitions. Everything from here forward (NPCs, dialogue, inventory, combat) builds on this.

### Module 5: The Overworld — TileMaps and Terrain

- Built Willowbrook using **TileMapLayer** nodes (the replacement for the deprecated `TileMap` node), one per layer: Ground, Detail, Objects, and AbovePlayer.
- Created a **TileSet** resource from a tile sheet image, configured atlas sources, and shared the TileSet across all layers.
- Added **physics layers** to the TileSet so wall, water, and building tiles block the player, set once on the tile definition and applied to every instance automatically.
- Attached a **Camera2D** to the player with position smoothing and edge limits so the camera follows smoothly without showing empty space beyond the map.
- Configured **pixel-perfect rendering**: `Nearest` texture filter, `canvas_items` stretch mode, and consistent tile sizes to prevent blurriness and sub-pixel jitter.

### Module 6: Bringing the Player to Life

- Replaced the static Sprite2D with an **AnimatedSprite2D** driven by a **SpriteFrames** resource, with eight named animations: `idle_down/up/left/right` and `walk_down/up/left/right`.
- Implemented an **enum-based state machine** with four states (IDLE, WALK, INTERACT, DISABLED) and a `match` statement that routes each frame to the correct state handler.
- Added **public methods** (`set_disabled()`, `start_interaction()`, `end_interaction()`) so external systems can control the player without reaching into the state machine internals.
- Set up **Y-sorting** with a `YSortGroup` Node2D so the player renders in front of or behind objects based on vertical position, and used a **feet-only collision shape** for natural-feeling tile interaction.
- Tracked **facing direction** as a persistent Vector2 so idle animations face the last movement direction.

### Module 7: Connecting Worlds — Scene Transitions

- Built a **SceneManager autoload** that wraps `get_tree().change_scene_to_file()` with fade-out/fade-in transitions using a CanvasLayer, ColorRect, and AnimationPlayer.
- Learned what **autoloads** (singletons) are: nodes that load at startup, persist across scene changes, and are accessible by name from any script. Godot's built-in `Input`, `Engine`, and `Time` are autoloads; SceneManager is our first custom one.
- Created **exit zones** (Area2D nodes with a script) that detect the player entering and call `SceneManager.change_scene()` with a target scene path and spawn point name.
- Used **Marker2D nodes** in the `spawn_points` group as named spawn locations, so the SceneManager can place the player at the right spot after each transition.
- Used **`await`** to write the async fade-out / scene-change / fade-in sequence as readable linear code instead of a chain of callbacks.

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|----------------|------------|
| TileMapLayer | A node that renders a grid of tiles from a TileSet | Builds entire game worlds from small, reusable tile images | Module 5 |
| TileSet | A resource defining tile properties (atlas, collision, size) | Single source of truth for tile behavior; shared across layers | Module 5 |
| Atlas source | A tile sheet image mapped to a grid within a TileSet | Lets you paint tiles from a sprite sheet | Module 5 |
| Physics layer (tiles) | Collision data on tile definitions | Makes tiles solid without per-instance configuration | Module 5 |
| Camera2D | A node that controls the viewport's visible area | Follows the player, prevents showing empty space | Module 5 |
| AnimatedSprite2D | A node that plays frame-based animations from SpriteFrames | Character walk cycles, idle poses, direction-based animation | Module 6 |
| SpriteFrames | A resource holding named animation sequences | Defines frame order, FPS, and looping for each animation | Module 6 |
| State machine (enum) | A pattern where an enum tracks the current state and a `match` routes behavior | Prevents conflicting behaviors; each state is self-contained | Module 6 |
| Facing direction | A persistent Vector2 remembering the last movement direction | Idle animations face the correct way when the player stops | Module 6 |
| Y-sort | Rendering children by Y position (lower = in front) | Creates depth illusion in top-down 2D games | Module 6 |
| Autoload (singleton) | A scene/script that loads at startup and persists across scene changes | Global systems (scene management, inventory, audio) that survive scene swaps | Module 7 |
| SceneManager | Our custom autoload that handles scene transitions | Fade effects, spawn point placement, transition-safe scene changes | Module 7 |
| Exit zone | An Area2D that triggers a scene change when the player enters | Connects areas together at map edges | Module 7 |
| Spawn point | A Marker2D node in the `spawn_points` group | Tells the SceneManager where to place the player in a new scene | Module 7 |
| `await` | A keyword that pauses a function until a signal fires | Makes async sequences (fade out, change scene, fade in) readable as linear code | Module 7 |
| CanvasLayer | A node that renders on a separate layer outside normal draw order | Overlays (fade effect, UI) that draw on top of everything | Module 7 |

## Cheat Sheet

### TileMapLayer Setup

The full workflow for creating a tilemap from scratch:

1. **Create a TileSet resource:**
   - Add a TileMapLayer node to your scene.
   - In the Inspector, click Tile Set and choose New TileSet.
   - Set Tile Size (e.g., `16x16`) **before** creating an atlas.

2. **Add an atlas source:**
   - In the TileSet panel (bottom of editor), click **+** and choose Atlas.
   - Drag your tile sheet PNG into the Texture property.
   - Click Yes when prompted to create tiles automatically.

3. **Save the TileSet externally:**
   - Click the dropdown arrow next to the TileSet property in the Inspector.
   - Choose Save As, and save to something like `res://tilesets/town_tileset.tres`.

4. **Add more layers:**
   - Add additional TileMapLayer nodes as siblings.
   - Assign the same saved TileSet to each one.

5. **Add collision:**
   - Expand the TileSet resource in the Inspector. Under Physics Layers, click Add Element.
   - In the TileSet panel, switch to the Paint tab, select Physics Layer 0, and click each tile that should be solid.

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)        (tileset: town_tileset.tres)
├── Detail (TileMapLayer)        (tileset: town_tileset.tres)
├── Objects (TileMapLayer)       (tileset: town_tileset.tres)
└── AbovePlayer (TileMapLayer)   (tileset: town_tileset.tres)
```

### Tile Painting and Layers

**Layer organization:**

| Layer | Purpose | What Goes Here |
|-------|---------|----------------|
| Ground | Base terrain, covers every cell | Grass, dirt, water, stone |
| Detail | Sparse decorations over ground | Flowers, path edges, cracks |
| Objects | Things the player walks behind/in front of | Trees, rocks, fences, buildings |
| AbovePlayer | Always drawn on top of the player | Treetop canopy, roof overhangs |

**Collision setup:**
- Add a Physics Layer to the TileSet resource (Inspector, not per-node).
- Paint collision onto tile *definitions* in the TileSet panel's Paint tab.
- Every instance of that tile gets collision automatically.

**Painting tips:**
- Right-click while painting erases.
- Use **Ctrl+click** to eyedropper-pick a tile from the viewport.
- Use Bucket Fill for the ground layer first, then paint paths over it.
- Keep Detail sparse: a few flowers per area, not one on every tile.
- Scroll wheel zooms, middle-click-drag pans.

### Sprite Animations (AnimatedSprite2D)

**Setting up from a sprite sheet:**

1. Add an AnimatedSprite2D node. Create a New SpriteFrames resource on it.
2. In the SpriteFrames panel, rename `default` to `idle_down`.
3. Click the grid icon ("Add frames from Sprite Sheet"), select your sheet, set the grid size.
4. Click the frames you want, then Add Frames.
5. Repeat for all eight animations.

**Required animation names** (the script constructs these dynamically):

| Animation | Frames | Looping |
|-----------|--------|---------|
| `idle_down` | 1 frame (standing) | No |
| `idle_up` | 1 frame | No |
| `idle_left` | 1 frame | No |
| `idle_right` | 1 frame | No |
| `walk_down` | 3-4 frames | Yes |
| `walk_up` | 3-4 frames | Yes |
| `walk_left` | 3-4 frames | Yes |
| `walk_right` | 3-4 frames | Yes |

Set walk animation FPS to 8-10. Names must be **exact** (all lowercase, underscore separator) or the script won't find them.

**Playing animations from code:**

```gdscript
func _play_animation(action: String) -> void:
    var direction_name := _direction_to_string(facing_direction)
    var anim_name := action + "_" + direction_name
    if sprite.sprite_frames.has_animation(anim_name):
        sprite.play(anim_name)
```

### The State Machine Pattern (Enum-Based)

Define states as an enum, track the current state, and use `match` to route each frame to the correct handler. Each state is a separate function with clear responsibilities.

```gdscript
enum State { IDLE, WALK, INTERACT, DISABLED }

var current_state: State = State.IDLE


func _physics_process(_delta: float) -> void:
    match current_state:
        State.IDLE:
            _state_idle()
        State.WALK:
            _state_walk()
        State.INTERACT:
            _state_interact()
        State.DISABLED:
            _state_disabled()


func _change_state(new_state: State) -> void:
    current_state = new_state
```

**State handlers** are self-contained. IDLE checks for input and transitions to WALK. WALK moves the player and transitions back to IDLE when input stops. INTERACT and DISABLED do nothing; they wait for external systems to release them.

**Transition rules:**

| From | To | Trigger |
|------|----|---------|
| IDLE | WALK | Movement input detected |
| WALK | IDLE | Movement input released |
| IDLE | INTERACT | Player presses interact near an NPC |
| INTERACT | IDLE | Dialogue finishes |
| Any | DISABLED | Cutscene, battle, or menu starts |
| DISABLED | IDLE | Cutscene, battle, or menu ends |

**External control:** other systems change the player's state through public methods, never by setting the enum directly:

```gdscript
func set_disabled(disabled: bool) -> void:
    if disabled:
        _change_state(State.DISABLED)
    else:
        _change_state(State.IDLE)


func start_interaction() -> void:
    _change_state(State.INTERACT)


func end_interaction() -> void:
    _change_state(State.IDLE)
```

### Y-Sorting

Y-sort makes children of a node render sorted by their Y position: higher on screen (lower Y value) draws first (behind), lower on screen (higher Y value) draws last (in front). This creates the illusion that the player walks behind trees and in front of paths.

**Setup:**

1. Create a Node2D child named `YSortGroup`.
2. Enable **CanvasItem > Ordering > Y Sort Enabled** on it.
3. Move the Objects TileMapLayer and the Player instance into `YSortGroup`.
4. Enable **Y Sort Enabled** on the Objects TileMapLayer too (so individual tiles sort against the player, not the entire layer as a block).
5. Set the Objects layer's **Y Sort Origin** to your tile height (e.g., `16`) so tiles sort by their bottom edge.

**Scene structure with Y-sort:**

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── YSortGroup (Node2D, y_sort_enabled = true)
│   ├── Objects (TileMapLayer, y_sort_enabled = true, y_sort_origin = 16)
│   └── Player (player.tscn instance)
└── AbovePlayer (TileMapLayer)
```

Ground and Detail are always behind everything. AbovePlayer is always on top. The YSortGroup handles the dynamic sorting between the player and objects.

### Scene Transitions and the SceneManager

**The SceneManager autoload** handles fade-out, scene change, and fade-in as a single async sequence. It lives at `res://autoloads/scene_manager.tscn` and is registered in Project Settings > Autoload.

**Changing scenes from any script:**

```gdscript
SceneManager.change_scene("res://scenes/whisperwood/whisperwood.tscn", "from_town")
```

The first argument is the scene file path. The second is the name of the Marker2D spawn point in the target scene. If omitted, it defaults to `"default"`.

**How it works internally:**

```gdscript
func change_scene(scene_path: String, spawn_point: String = "default") -> void:
    if _is_transitioning:
        return
    _is_transitioning = true
    _target_scene_path = scene_path
    _target_spawn_point = spawn_point

    transition_started.emit()
    _anim_player.play("fade_out")
    await _anim_player.animation_finished

    get_tree().change_scene_to_file(_target_scene_path)
    await get_tree().scene_changed

    _place_player_at_spawn()

    _anim_player.play("fade_in")
    await _anim_player.animation_finished

    _is_transitioning = false
    transition_finished.emit()
```

**Spawn point placement:** the SceneManager finds Marker2D nodes in the `spawn_points` group and teleports the player to the one whose name matches:

```gdscript
func _place_player_at_spawn() -> void:
    var spawn_markers := get_tree().get_nodes_in_group("spawn_points")
    for marker in spawn_markers:
        if marker.name == _target_spawn_point:
            var player := get_tree().get_first_node_in_group("player")
            if player:
                player.global_position = marker.global_position
            return
```

**Exit zones** are Area2D nodes with this script:

```gdscript
extends Area2D
## A zone that triggers a scene transition when the player enters.

@export_file("*.tscn") var target_scene: String
@export var target_spawn_point: String = "default"


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        SceneManager.change_scene(target_scene, target_spawn_point)
```

### Autoloads

**What they are:** A scene or script that loads when the game starts, persists across all scene changes, and is accessible globally by name. Godot's built-in `Input`, `Engine`, and `Time` are autoloads. SceneManager is our first custom one.

**How to register one:**

1. Go to Project > Project Settings > Autoload.
2. Click the folder icon and select your `.tscn` or `.gd` file.
3. The name auto-fills (e.g., `SceneManager`). Click Add.

**When to use them:** Systems that need to survive scene changes and be accessible from anywhere: scene management, inventory, audio, game state. If a system only matters within one scene, keep it local.

**Signal lifecycle:** When a scene is freed (during a scene change), all signal connections from its nodes are cleaned up automatically. Autoload signals persist because autoloads are never freed. This is why cross-scene systems belong in autoloads.

**Autoload reference card** (updated as we build more):

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects and spawn point placement |

### Camera2D

**Setup:** Add a Camera2D as a child of the Player node.

```
Player (CharacterBody2D)
├── Sprite (AnimatedSprite2D)
├── CollisionShape2D
└── Camera2D
```

**Key properties in the Inspector:**

| Property | Value | Why |
|----------|-------|-----|
| Enabled | `true` | Makes this the active camera |
| Position Smoothing > Enabled | `true` | Smooth follow instead of rigid tracking |
| Position Smoothing > Speed | `5.0` | Balance between responsive and smooth (3-8 is the sweet spot) |
| Limit > Left | `0` | Prevent showing empty space left of the map |
| Limit > Top | `0` | Prevent showing empty space above the map |
| Limit > Right | map width in pixels | e.g., `640` for a 40-tile-wide map with 16px tiles |
| Limit > Bottom | map height in pixels | e.g., `480` for a 30-tile-tall map with 16px tiles |

**Pixel-perfect checklist** (check all four if tiles look blurry or jittery):

1. Project Settings > Rendering > Textures > Default Texture Filter: **Nearest**
2. Project Settings > Display > Window > Stretch > Mode: **canvas_items**
3. Camera2D Position Smoothing Speed: moderate (3-8)
4. Tile sheet import settings: Filter set to **Nearest** (or Off)

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| TileSet tile size doesn't match the tile sheet grid | Grid overlay is misaligned; tiles are cut off or overlap | Set Tile Size in the TileSet resource **before** creating the atlas. Must match your sprite sheet's grid (e.g., 16x16). |
| Collision set on the wrong layer | Player walks through walls, or can't walk on paths | Verify you added collision to the tile *definition* in the TileSet panel's Paint tab, not to a specific placed tile. Check that the physics layer index matches. |
| Animation name mismatch | Player freezes or plays the wrong animation | Names must be exact: `idle_down`, `walk_left`, etc. All lowercase, underscore separator. No spaces, no capitals. |
| Player not in the `player` group | Exit zones don't trigger; SceneManager can't find the player | Select the Player root node, go to Node tab > Groups, type `player`, click Add. |
| Spawn point not in the `spawn_points` group | Player appears at (0, 0) after a scene transition | Select each Marker2D spawn point, add it to the `spawn_points` group. The marker's node name must match the spawn point string passed to `change_scene()`. |
| Y-sort not enabled on the Objects TileMapLayer | Player is always in front of (or always behind) all objects | Enable Y Sort Enabled on both the YSortGroup Node2D **and** the Objects TileMapLayer. Set Y Sort Origin on the Objects layer to your tile height. |
| Texture filter set to Linear | Tiles look blurry, pixel art is smeared | Project Settings > Rendering > Textures > Default Texture Filter: Nearest. Also check the import settings on each tile sheet PNG. |
| Exit zone collision shape missing or mis-sized | Walking to the map edge does nothing | Make sure the Area2D has a CollisionShape2D child with a shape (RectangleShape2D) that covers the exit area. Check that the Area2D's collision mask includes the player's layer. |

## Official Godot Documentation

Everything referenced in Part II, organized by category. Bookmark the ones you find yourself looking up repeatedly.

### Tilemap System

- [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html): the node that renders a grid of tiles (replaces the deprecated TileMap)
- [TileSet](https://docs.godotengine.org/en/stable/classes/class_tileset.html): the resource that defines tile properties, atlas sources, and physics layers
- [Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html): tutorial on creating and configuring TileSets
- [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html): tutorial on painting tiles and setting up layers

### Player and Animation

- [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html): physics body for player movement with `move_and_slide()`
- [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html): node that plays frame-based animations from a SpriteFrames resource
- [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html): resource holding named animation sequences with frames, FPS, and loop settings
- [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html): alternative animation approach for keyframing arbitrary properties
- [2D Sprite Animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html): tutorial covering both AnimatedSprite2D and AnimationPlayer approaches
- [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html): defines the shape used for physics collision
- [RectangleShape2D](https://docs.godotengine.org/en/stable/classes/class_rectangleshape2d.html): rectangular collision shape used for player feet and exit zones

### Camera and Rendering

- [Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html): viewport camera with smoothing, limits, zoom, and drag margins
- [Viewport and Canvas Transforms](https://docs.godotengine.org/en/stable/tutorials/2d/2d_transforms.html): how coordinates, viewports, and rendering relate in 2D

### Y-Sorting and Rendering Order

- [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html): base class for all 2D nodes; covers `y_sort_enabled`, visibility, modulate, and draw order
- [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html): 2D node used as the YSortGroup container

### Scene Transitions and Autoloads

- [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html): official guide to creating and registering autoloads
- [Change Scenes Manually](https://docs.godotengine.org/en/stable/tutorials/scripting/change_scenes_manually.html): the built-in `change_scene_to_file()` and why you often wrap it
- [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html): the tree that manages all nodes; provides `change_scene_to_file()`, `get_nodes_in_group()`, and `get_first_node_in_group()`
- [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html): renders on a separate layer; used for the fade overlay and UI
- [ColorRect](https://docs.godotengine.org/en/stable/classes/class_colorrect.html): solid-color rectangle used as the black fade overlay
- [Introduction to Animations](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html): creating property track animations in AnimationPlayer

### Interaction and Detection

- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html): trigger zone for detecting overlapping bodies (used for exit zones)
- [Marker2D](https://docs.godotengine.org/en/stable/classes/class_marker2d.html): lightweight position marker used for spawn points

### Input

- [Input](https://docs.godotengine.org/en/stable/classes/class_input.html): the global input singleton; `get_axis()`, `is_action_pressed()`
- [InputEvent](https://docs.godotengine.org/en/stable/classes/class_inputevent.html): base class for all input events

### GDScript

- [@export_file](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html): export annotation that creates a filtered file picker in the Inspector
- [Awaiting Signals](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals): how `await` pauses a function until a signal fires

## What's Next

In Part III, we add interactivity. **Module 9: Resources, the Data Layer** introduces Godot's Resource system, where we build custom data types for items, characters, and NPCs. This data layer is what the dialogue, inventory, and combat systems all read from.
