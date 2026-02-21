class_name OvergrownCapitalMap
extends RefCounted

## Tilemap data constants for Overgrown Capital dungeon.
## All legends and map arrays live here so overgrown_capital.gd stays concise.
## Visual design by tilemap-builder agent — hand-crafted district layout.

# Source 0: TF_DUNGEON (flat 16x16 dungeon tiles — floor + walls)
# Source 1: RUINS_OBJECTS (tf_B_ruins2.png — transparent detail scatter)
# Source 2: OVERGROWN_RUINS_OBJECTS (B-sheet — objects, rubble, vines)

# Map dimensions
const COLS: int = 40
const ROWS: int = 28

# ---------- PROCEDURAL GROUND CONFIG ----------

# Noise seed — still used for detail/debris scatter derivation
const GROUND_NOISE_SEED: int = 54321

# Floor tiles — warm brown earth from TF_DUNGEON row 1, cols 2-5
const FLOOR_TILES: Array[Vector2i] = [
	Vector2i(2, 1), Vector2i(3, 1),
	Vector2i(4, 1), Vector2i(5, 1),
]
const FLOOR_HASH_SEED: int = 54327

# Wall tiles — cool blue-gray stone from TF_DUNGEON row 1, cols 6-8
const WALL_TILES: Array[Vector2i] = [
	Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1),
]
const WALL_HASH_SEED: int = 54331
const WALL_BORDER_TILE: Vector2i = Vector2i(6, 1)

# Detail scatter — small transparent debris from RUINS_OBJECTS row 6 (source 1)
const DETAIL_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(8, 6), "source_id": 1, "density": 0.04},
	{"atlas": Vector2i(9, 6), "source_id": 1, "density": 0.03},
	{"atlas": Vector2i(13, 6), "source_id": 1, "density": 0.03},
	{"atlas": Vector2i(14, 6), "source_id": 1, "density": 0.02},
]

# Debris scatter — rubble, rocks, vines, moss (source 2)
const DEBRIS_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 2), "source_id": 2, "density": 0.05},  # pebbles
	{"atlas": Vector2i(1, 2), "source_id": 2, "density": 0.04},  # rocks
	{"atlas": Vector2i(0, 6), "source_id": 2, "density": 0.02},  # vine clump
	{"atlas": Vector2i(1, 6), "source_id": 2, "density": 0.02},  # moss clump
]

# Objects layer — B-sheet ruins objects (source 2)
const OBJECTS_LEGEND: Dictionary = {
	"a": Vector2i(2, 0),   # Carved stone block
	"b": Vector2i(0, 4),   # Green bush
	"d": Vector2i(0, 0),   # Stone rubble
	"e": Vector2i(1, 4),   # Green bush variant
	"f": Vector2i(3, 0),   # Small rubble piece
	"g": Vector2i(2, 4),   # Vine growth
	"h": Vector2i(3, 4),   # Moss patch
	"i": Vector2i(5, 0),   # Crumbled pillar
}

# Above-player layer — vine overhangs and arch canopy (B-sheet source 2)
const ABOVE_LEGEND: Dictionary = {
	"v": Vector2i(0, 6),   # Round vine canopy piece (left)
	"w": Vector2i(1, 6),   # Round vine canopy piece (right)
	"b": Vector2i(0, 4),   # Bush overhang
	"c": Vector2i(1, 4),   # Bush overhang variant
}

# --------------------------------------------------------------------------
# Map arrays — 28 rows x 40 cols each (640x448 px)
# '.' = empty cell (no tile placed on that layer)
#
# District layout:
#   Row  0-5:  Palace District approach — narrow corridor, dense walls
#   Row  6-12: Research Quarter (west cols 2-22) + Entertainment (east)
#   Row 13-18: Residential Quarter (west cols 2-19) + Entertainment (east)
#   Row 19-27: Market District — broad stone streets, entry zone
#
# Ground is position-hashed; detail/debris are noise-scattered.
# --------------------------------------------------------------------------

# Wall layer — structural walls forming dungeon boundaries (source 0).
# 'W'=hashed blue-gray stone (solid), 'G'=fixed border accent (solid), '.'=navigable
const WALL_MAP: Array[String] = [
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
	"WW....WWWWWWWWG............GWWWWWWWW..WW",
	"WW....WWWWWWWWG............GWWWWWWWW..WW",
	"WW....WWWWWWWW..............WWWWWWWW..WW",
	"WW....WWWWWWWWG............GWWWWWWWW..WW",
	"WW....GWWWWWWWGG..........GGWWWWWWWG..WW",
	"WW............................WWWWWW..WW",
	"WW.............................WWWWW..WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WWWWWWWWWWWWWWWWWWWW..WWWWWWWWWWWWWWWWWW",
]

# Objects layer — props, rubble, vines from B-sheet (source 2).
const OBJECTS_MAP: Array[String] = [
	"........................................",
	"........................................",
	"....b...............g..............e....",
	"........................................",
	"....g...............h..............b....",
	"........................................",
	"...d...........a........................",
	"........f...............................",
	"....b.........e................d........",
	"........................................",
	"...g..............................f.....",
	".......i................................",
	"........................................",
	"....e.......b...........................",
	"........................................",
	"........................................",
	"...b.........g..........................",
	"........f...............................",
	"........................................",
	"........................................",
	"........................................",
	".....d...........f.............a........",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	".....f..........d...............f.......",
	"........................................",
]

# Above-player layer — vine overhangs creating depth (B-sheet source 2).
# Sparse placement over palace corridors and district transitions.
const ABOVE_PLAYER_MAP: Array[String] = [
	"........................................",
	"........................................",
	"...vw............................vw.....",
	"........................................",
	"...bc............................bc.....",
	"........................................",
	"........................................",
	"........................................",
	"...vw...................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"...bc...................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
]


# ---------- STATIC HELPERS ----------


static func pick_floor_tile(x: int, y: int) -> Vector2i:
	var idx: int = abs(x * 73 + y * 31 + FLOOR_HASH_SEED) % FLOOR_TILES.size()
	return FLOOR_TILES[idx]


static func pick_wall_tile(x: int, y: int) -> Vector2i:
	var idx: int = abs(x * 73 + y * 31 + WALL_HASH_SEED) % WALL_TILES.size()
	return WALL_TILES[idx]
