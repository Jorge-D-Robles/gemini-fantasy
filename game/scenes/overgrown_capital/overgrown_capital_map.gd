class_name OvergrownCapitalMap
extends RefCounted

## Tilemap data constants for Overgrown Capital dungeon.
## All legends and map arrays live here so overgrown_capital.gd stays concise.
## Visual design by tilemap-builder agent — hand-crafted district layout.

# Source 0: FAIRY_FOREST_A5_A (opaque ground tiles — mandatory for all scenes)
# Source 1: RUINS_A5 (ruins2 — golden walls and ornate floors)
# Source 2: OVERGROWN_RUINS_OBJECTS (B-sheet — objects, rubble, vines)

# Map dimensions
const COLS: int = 40
const ROWS: int = 28

# ---------- PROCEDURAL GROUND CONFIG ----------

# Ground noise — organic terrain (source 0)
# V = dense vegetation (noise > 0.35), D = dark earth (-0.15..0.35),
# F = gray stone (catch-all, noise >= -1.0)
const GROUND_NOISE_SEED: int = 54321
const GROUND_NOISE_FREQ: float = 0.09
const GROUND_NOISE_OCTAVES: int = 3
const GROUND_ENTRIES: Array[Dictionary] = [
	{"threshold": 0.35, "atlas": Vector2i(0, 8)},   # V = dense vegetation
	{"threshold": -0.15, "atlas": Vector2i(0, 6)},  # D = dark earth/roots
	{"threshold": -1.0,  "atlas": Vector2i(0, 10)}, # F = gray stone (catch-all)
]

# Detail scatter — ornate golden floor accents (source 1, ~10% coverage)
const DETAIL_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 2), "source_id": 1, "density": 0.10},
]

# Debris scatter — rubble, rocks, vines, moss (source 2)
const DEBRIS_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 2), "source_id": 2, "density": 0.05},  # pebbles
	{"atlas": Vector2i(1, 2), "source_id": 2, "density": 0.04},  # rocks
	{"atlas": Vector2i(0, 6), "source_id": 2, "density": 0.02},  # vine clump
	{"atlas": Vector2i(1, 6), "source_id": 2, "density": 0.02},  # moss clump
]

# Wall layer — structural walls (ruins2 source 1)
const WALL_LEGEND: Dictionary = {
	"W": Vector2i(0, 4),   # Golden wall (opaque)
	"G": Vector2i(0, 8),   # Dark ornamental border
}

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
# Ground/detail/debris are now procedural — see noise configs above.
# --------------------------------------------------------------------------

# Wall layer — structural walls forming dungeon boundaries.
# 'W'=golden wall (solid), 'G'=dark ornamental border (solid), '.'=navigable
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
