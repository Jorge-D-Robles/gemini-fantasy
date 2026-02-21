class_name OvergrownRuinsMap
extends RefCounted

## Tilemap data constants for Overgrown Ruins.
## All legends and map arrays live here so overgrown_ruins.gd stays concise.

# Source 0: FAIRY_FOREST_A5_A (opaque ground tiles)
# Source 1: RUINS_A5 (ruins2 — opaque golden walls)
# Source 2: OVERGROWN_RUINS_OBJECTS (B-sheet — objects)

# Map dimensions
const COLS: int = 40
const ROWS: int = 24

# ---------- PROCEDURAL GROUND CONFIG ----------

# Ground noise — organic terrain distribution (source 0)
# V = dense vegetation (noise > 0.3), D = dark earth (-0.2..0.3),
# F = gray stone (catch-all, noise >= -1.0)
const GROUND_NOISE_SEED: int = 12345
const GROUND_NOISE_FREQ: float = 0.08
const GROUND_NOISE_OCTAVES: int = 3
const GROUND_ENTRIES: Array[Dictionary] = [
	{"threshold": 0.3,  "atlas": Vector2i(0, 8)},   # V = dense vegetation
	{"threshold": -0.2, "atlas": Vector2i(0, 6)},   # D = dark earth/roots
	{"threshold": -1.0, "atlas": Vector2i(0, 10)},  # F = gray stone (catch-all)
]

# Detail scatter — ornate golden floor accents (source 1, ~12% coverage)
const DETAIL_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 2), "source_id": 1, "density": 0.12},
]

# Debris scatter — rubble, rocks, vines, moss (source 2)
const DEBRIS_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 2), "source_id": 2, "density": 0.07},  # pebbles
	{"atlas": Vector2i(1, 2), "source_id": 2, "density": 0.06},  # rocks
	{"atlas": Vector2i(0, 6), "source_id": 2, "density": 0.03},  # vine fragment
	{"atlas": Vector2i(1, 6), "source_id": 2, "density": 0.03},  # moss clump
]

# Wall layer — structural walls (ruins2 source 1)
const WALL_LEGEND: Dictionary = {
	"W": Vector2i(0, 4),   # Golden Egyptian wall (opaque)
	"G": Vector2i(0, 8),   # Dark ornamental border (opaque)
}

# Objects layer — B-sheet ruins objects (source 2)
const OBJECTS_LEGEND: Dictionary = {
	"a": Vector2i(2, 0),   # Carved stone block
	"b": Vector2i(0, 4),   # Green bush
	"c": Vector2i(4, 0),   # Dark carved ornament
	"d": Vector2i(0, 0),   # Stone rubble
	"e": Vector2i(1, 4),   # Green bush variant
	"f": Vector2i(3, 0),   # Small rubble piece
	"g": Vector2i(2, 4),   # Vine growth
	"h": Vector2i(3, 4),   # Moss patch
	"i": Vector2i(5, 0),   # Crumbled pillar
	"1": Vector2i(4, 2),   # Teal face top-left
	"2": Vector2i(5, 2),   # Teal face top-center
	"3": Vector2i(6, 2),   # Teal face top-right
	"4": Vector2i(4, 3),   # Teal face bottom-left
	"5": Vector2i(5, 3),   # Teal face bottom-center
	"6": Vector2i(6, 3),   # Teal face bottom-right
	"7": Vector2i(8, 2),   # Gold face top-left
	"8": Vector2i(9, 2),   # Gold face top-right
	"9": Vector2i(8, 3),   # Gold face bottom-left
	"0": Vector2i(9, 3),   # Gold face bottom-right
}

# ---------- STRUCTURAL MAP DATA (40 cols x 24 rows) ----------
# Ground/detail/debris are now procedural — see noise configs above.

# Sacred Chamber (north), Main Corridor (center), South Gallery
const WALL_MAP: Array[String] = [
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
	"WWWWWWWWWWWWWWWWGG            GGWWWWWWWW",
	"WWWWWWWWWWWWWWWWG              GWWWWWWWW",
	"WWWWWWWWWWWWWWWWG              GWWWWWWWW",
	"WWWWWWWWWWWWWWWWG              GWWWWWWWW",
	"WWWWWWWWWWWWWWWWG              GWWWWWWWW",
	"WWWWWWWWWWWWWWWWGG            GGWWWWWWWW",
	"WWWWWWWWWWWWWWWWWWWW      WWWWWWWWWWWWWW",
	"WW        WWWWWWWWWW      WWWWWWWWWWWWWW",
	"WW                                  WWWW",
	"WW                                    WW",
	"WW                                    WW",
	"WW                                  WWWW",
	"WW        WWWWWWWWWW      WWWWWWWWWWWWWW",
	"WWWW    WWWWWWWWWWWWWW  WWWWWWWWWW  WWWW",
	"WW                                    WW",
	"WW          WW              WW        WW",
	"WW                                    WW",
	"WW          WW              WW        WW",
	"WW                                    WW",
	"WW                                    WW",
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
]

# B-sheet objects: face statues, stone blocks, bushes, vegetation (source 1)
const OBJECTS_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                  d    123    f         ",
	"                       456              ",
	"                  f              d      ",
	"                       a                ",
	"                                        ",
	"                                        ",
	"     d  f                         f d   ",
	"   b       e                  e    b    ",
	"      f                          f      ",
	"                   f                    ",
	"   e       b                  b    e    ",
	"     d  f                         f d   ",
	"                                        ",
	"   b  f                             e   ",
	"         a    e             h    f      ",
	"      d          78       b      g      ",
	"            f    90    c          d     ",
	"   e     b                    i         ",
	"   b  f    d               e     f  d   ",
	"                                        ",
	"                                        ",
]
