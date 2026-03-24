# Module 4: The Overworld — TileMaps and Terrain

## What We Have So Far

A Player scene (CharacterBody2D with sprite and collision) that moves with keyboard input and handles physics. But the world is empty — just a blank screen.

## What We're Building This Module

The town of **Willowbrook** — Crystal Saga's starting village. We'll build it using Godot's TileMapLayer system: painting ground, paths, buildings, and water onto a grid, with collision so the player can't walk through walls.

By the end, you'll have a real place to explore.

## How TileMaps Work: A Conceptual Model

Before we touch any code, let's understand the idea.

A tilemap is a grid of small images (tiles) assembled into a larger scene — like placing mosaic tiles to create a picture. Instead of drawing an entire town as one massive image, you draw it from reusable 16x16 or 32x32 pixel pieces: a grass tile, a path tile, a wall tile, a roof tile.

Think of it like transparent sheets stacked on top of each other:

```
Layer 4: AbovePlayer  — treetops, roof overhangs (drawn on top of the player)
Layer 3: Objects      — trees, rocks, signs, fences
Layer 2: Detail       — flowers, cracks, path borders
Layer 1: Ground       — grass, dirt, water
```

Each layer is a separate **TileMapLayer** node. The ground layer covers every tile. The detail layer has sparse decorations. The object layer has things the player walks behind. The above-player layer draws on top of everything, including the player.

This is exactly how professional 2D games are built — including most of the JRPGs you've played.

> **See:** [Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html) — creating TileSet resources from tile sheets.

> **See:** [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html) — painting tiles, configuring layers, and adding physics to tiles.

## TileMapLayer, not TileMap

You may see older tutorials reference a node called `TileMap`. That node is **deprecated** as of Godot 4.3. The replacement is `TileMapLayer` — one node per layer, instead of one node with multiple internal layers.

`TileMapLayer` is simpler to use and gives you direct control over each layer as an independent node in the scene tree. Each layer can have its own z-order, visibility toggle, and physics settings.

Throughout this tutorial, we always use `TileMapLayer`.

> **See:** [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html) — the API reference for the current tilemap node.

## Getting a Tile Sheet

To build a tilemap, you need a **tile sheet** — an image file containing all your tiles arranged in a grid. For this tutorial, you have a few options:

1. **Use a free asset pack.** [Kenney](https://kenney.nl/) has excellent free tilesets. The [1-Bit Pack](https://kenney.nl/assets/1-bit-pack) works well for prototyping.
2. **Draw your own.** Even simple colored squares work to start — green for grass, brown for paths, blue for water, gray for walls.
3. **Use a placeholder.** We'll describe the setup in terms of generic tiles. Replace them with real art whenever you're ready.

For Crystal Saga, we'll assume you have a simple tile sheet with at least these tile types:
- Grass (walkable ground)
- Path/dirt (walkable)
- Water (not walkable)
- Wall/building exterior (not walkable)
- Building interior floor (walkable)

Save your tile sheet image to `res://tilesets/town_tiles.png` (or whatever you name it).

> **JRPG Pattern:** Most classic JRPGs use 16x16 pixel tiles. Some use 32x32 for more detail. The choice affects the overall aesthetic. We'll use **16x16** tiles for an authentic retro feel — you can use 32x32 if you prefer a more detailed look.

## Creating the TileSet

A **TileSet** is a resource that tells Godot how to interpret your tile sheet — where each tile is, how big they are, and what properties they have (collision, animation, etc.).

### Step 1: Create the Town Scene

1. Create a new scene (Scene → New Scene).
2. Add a **Node2D** as the root. Rename it to `Willowbrook`.
3. Save as `res://scenes/willowbrook/willowbrook.tscn`.

### Step 2: Add the First TileMapLayer

1. With `Willowbrook` selected, add a child **TileMapLayer** node.
2. Rename it to `Ground`.

### Step 3: Create a TileSet

1. Select the `Ground` node.
2. In the Inspector, find the **Tile Set** property.
3. Click it and choose **New TileSet**.
4. Click the TileSet to expand it. Set **Tile Size** to `16x16` (or your tile size) — **you must set this before creating an atlas**.

### Step 4: Create an Atlas Source

The TileSet panel appears at the bottom of the editor.

1. In the TileSet panel, click the **+** button to add a source.
2. Choose **Atlas**.
3. Drag your tile sheet image (`town_tiles.png`) into the **Texture** property.
4. Godot will ask if you want to **create tiles automatically**. Click **Yes**.

You should see your tile sheet with a grid overlay. Each grid cell is one tile, and Godot has created a tile entry for each one.

> **Warning:** If the grid doesn't align with your tiles, double-check that the **Tile Size** in the TileSet matches your tile sheet's grid size. Misaligned grids are the #1 tileset setup problem.

### Step 5: Save the TileSet as an External Resource

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

The layers are drawn in tree order — `Ground` first (bottom), `AbovePlayer` last (top). The player sprite should render between `Objects` and `AbovePlayer`. We'll handle this with Y-sorting in Module 5.

### Why Four Layers?

| Layer | Purpose | Example Tiles |
|-------|---------|---------------|
| Ground | Covers every cell. The base terrain. | Grass, dirt, water, stone |
| Detail | Sparse decorations on top of ground. | Flowers, path edges, cracks |
| Objects | Things the player walks behind (lower half) or in front of (upper half). | Trees, rocks, fences, signs |
| AbovePlayer | Drawn on top of everything, including the player. | Treetop canopy, roof overhangs, bridge railings |

This layering creates depth. The player walks on the ground, behind trees, and under overhanging roofs — without any complex rendering tricks.

## Painting Tiles

Now for the fun part. Select a TileMapLayer node and start painting:

1. Select the `Ground` layer in the scene tree.
2. The TileMap editor panel appears at the bottom of the screen.
3. Select a tile from the tile palette (your tile sheet is shown as a grid of clickable tiles).
4. Click or click-and-drag in the viewport to paint tiles.

### Painting Tools

The TileMap editor toolbar offers several tools:

| Tool | What It Does |
|------|-------------|
| Paint | Place one tile at a time (click or drag) |
| Line | Draw a straight line of tiles |
| Rectangle | Fill a rectangular area |
| Bucket Fill | Fill a contiguous area with the same tile |
| Eraser | Remove tiles |

> **Note:** Right-click while a tool is selected to pick a tile from the viewport (like an eyedropper tool). This is faster than scrolling through the palette.

### Building Willowbrook

Here's a suggested layout for Willowbrook. You don't need to follow this exactly — make it your own.

```
Key:
G = Grass    P = Path    W = Water    B = Building
T = Tree     . = Empty

         GGGGGGGGGGGGGGGGG
        GGGTTTGGGGGTTTGGGG
       GGGTTTTGGGGTTTTGGGG
      GGGG  BBBPPBBB  GGGG
     GGGGG  BBBPPBBB  GGGGG
    GGGGGG    PPPP    GGGGGG
   GGGGGGG   PPPP   GGGGGGG
  GGGGGGGGPPPPPPPPPGGGGGGGG
  GGGGGGGGPPPPPPPPPGGGGGGGG
  GGGGTTTGPPPP PPPPGTTTTGGG
  GGGGTTTGPPPP PPPPGTTTTGGG
  GGGGGGGGPPPPPPPPPGGGGGGGG
  GGGGGWWWWWWWWWWWWWWGGGGG
  GGGWWWWWWWWWWWWWWWWWGGGG
```

Think about:
- **Paths** connecting buildings and leading to the town entrance/exit
- **Buildings** as solid rectangles (we'll use the Object layer for visual detail)
- **Water** on one edge (a pond or stream)
- **Trees** around the perimeter for a natural boundary
- An **exit** leading south (to the forest in Module 6)

Paint the `Ground` layer first (fill everything with grass, then paint paths and water over it). Then add trees and building details on the `Objects` layer. Add flowers and grass variations on the `Detail` layer.

## Adding Collision to Tiles

Right now, the player walks through everything. We need to mark certain tiles as solid.

### Step 1: Add a Physics Layer to the TileSet

1. Select any TileMapLayer node to access the TileSet.
2. In the Inspector, expand the TileSet resource.
3. Under **Physics Layers**, click **Add Element**.
4. This creates a physics layer that tiles can use for collision.

### Step 2: Mark Tiles as Solid

1. In the TileSet panel (bottom of editor), switch to the **Select** mode.
2. Click on a tile you want to be solid (e.g., a wall tile, a water tile, a tree trunk).
3. In the tile's properties panel, find **Physics → Physics Layer 0**.
4. Click the collision shape area. You can draw a polygon, or for simple tiles, right-click and choose **Reset to default tile shape** to fill the entire tile.

Repeat this for every tile type that should block the player: walls, water, tree trunks, building exteriors.

> **Note:** You only need to set collision on the tile *definition* in the TileSet — not on each placed tile individually. Once a tile type has collision, every instance of that tile on the map is solid.

### Step 3: Test It

Make sure your player's CollisionShape2D is appropriately sized (it should be smaller than a tile — roughly half-tile height works well for a JRPG character, so the player's feet collide but their head can overlap with objects above).

Instance the Player scene into `Willowbrook`. Run with F6 and try walking into walls and water. The player should collide and slide along surfaces.

## Camera2D: Following the Player

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

> **See:** [Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html) — all Camera2D properties including limits, zoom, smoothing, and drag margins.

You can calculate your map's pixel dimensions: `tile_count_x * tile_size` × `tile_count_y * tile_size`. For a 40×30 map with 16px tiles: 640×480.

## Pixel-Perfect Rendering Checklist

If your tiles look blurry, have gaps between them, or shimmer when the camera moves, check these settings:

1. **Project Settings → Rendering → Textures → Default Texture Filter:** `Nearest` (set in Module 1)
2. **Project Settings → Display → Window → Stretch → Mode:** `canvas_items`
3. **Camera2D → Position Smoothing:** Keep the speed moderate (3-8). Very high values can cause sub-pixel jitter.
4. **Import settings on tile sheet:** Select the PNG in FileSystem, go to the Import tab, ensure **Filter** is `Nearest` (or `Off`). Click **Reimport**.

> **See:** [Viewport and canvas transforms](https://docs.godotengine.org/en/stable/tutorials/2d/2d_transforms.html) — understanding how coordinates, viewports, and rendering relate in 2D.

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

Later (in Module 6), the Player will be spawned by the SceneManager rather than placed directly in the scene. But for now, having it here lets us test immediately.

## A Note on Tile Art

You're probably looking at your map and thinking it looks... rough. That's okay. Programmer art is a rite of passage. The important thing is that the *systems* work — the layers, the collision, the camera.

When you're ready, you can:
- Find free tile packs (Kenney, OpenGameArt, itch.io)
- Commission custom art
- Learn pixel art yourself (Aseprite is the standard tool)

Swapping the art is just changing the tile sheet image and reassigning it in the TileSet. The map layout, collision, and layer structure stay the same.

## What We've Learned

- **TileMapLayer** nodes render grids of tiles from a **TileSet** resource.
- **TileSets** are created from tile sheet images (atlases). Set the tile size before creating the atlas.
- **Multiple layers** (Ground, Detail, Objects, AbovePlayer) create depth and visual richness.
- **Physics layers** on the TileSet make tiles solid. Set collision on the tile definition, not on each placed tile.
- **Camera2D** follows the player. Use position smoothing and limits for a polished feel.
- **Pixel-perfect settings:** `Nearest` texture filter, `canvas_items` stretch mode, and consistent tile sizes prevent blurriness and jitter.
- `TileMapLayer` replaces the deprecated `TileMap` node — one node per layer.

## What You Should See

When you press F6 (to run the Willowbrook scene directly):
- A tiled town with ground, paths, and objects
- The player character walks around with arrow keys
- The player collides with walls, water, and solid objects
- The camera follows the player smoothly
- Tiles are crisp and pixel-perfect (no blurriness)

## Next Module

We have a town, but our player is still the Godot icon sliding around lifelessly. In **Module 5: Bringing the Player to Life**, we'll add sprite animations (walk cycles in four directions), implement a proper enum-based state machine, and add Y-sorting so the player walks behind trees and in front of paths.
