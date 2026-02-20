class_name OvergrownRuinsMap
extends RefCounted

## Tilemap data constants for Overgrown Ruins.
## All legends and map arrays live here so overgrown_ruins.gd stays concise.

# Source 0: FAIRY_FOREST_A5_A (opaque ground tiles)
# Source 1: RUINS_A5 (ruins2 — opaque golden walls)
# Source 2: OVERGROWN_RUINS_OBJECTS (B-sheet — objects)

# Ground layer — organic terrain patches (fairy forest source 0)
# F = gray stone floor (dominant ~60%), D = dark earth/roots (~25%),
# V = dense vegetation (~15%)
const GROUND_LEGEND: Dictionary = {
	"F": Vector2i(0, 10),  # Gray stone floor (confirmed opaque)
	"D": Vector2i(0, 6),   # Dark earth/roots — wall edges and corners
	"V": Vector2i(0, 8),   # Dense vegetation — nature reclaiming ruins
}

# Ground detail — ornate golden floor (ruins2 source 1)
const DETAIL_LEGEND: Dictionary = {
	"O": Vector2i(0, 2),   # Ornate golden floor tile
}

# Ground debris — small rubble from B-sheet (source 2, on GroundDebris)
const DEBRIS_LEGEND: Dictionary = {
	"p": Vector2i(0, 2),   # Small pebbles
	"r": Vector2i(1, 2),   # Scattered rocks
	"v": Vector2i(0, 6),   # Vine fragment
	"m": Vector2i(1, 6),   # Moss clump
}

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

# ---------- MAP DATA (40 cols x 24 rows) ----------

# 40 cols x 24 rows — organic terrain patches
# F = gray stone (corridors, open areas), D = dark earth (wall edges),
# V = vegetation (nature reclaiming the ruins)
# Under walls (W/G in WALL_MAP) the ground is invisible, so F is fine.
const GROUND_MAP: Array[String] = [
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFDDDDDDDDDDDDFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFDDDDDDDDDVVDDDFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFDDDFFFFFVVVVDDFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFDDDFFFFFVVVVVDFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFDDDDDFFDDVVVDDFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFDDDDFFDDDDDDFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFDFFFFDFFFFFFFFFFFFFF",
	"FFDDDVVDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFDDDVVFFFFFFFFFFFFFFFFFFFFFFFFFFVDDFFFF",
	"FFDDVVVVFFFFFFFFFFFFFFFFFFFFFFFFFVVVDDFF",
	"FFDDDVVVFFFFFFFFFFFFFFFFFFFFFFFFFFVVDDFF",
	"FFDDDVVFFFFFFFFFFFFFFFFFFFFFFFFFFVVDFFFF",
	"FFDDDVVDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFDDDDFFFFFFFFFFFFFFFFFFFFFFFFFFDDFFFF",
	"FFDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDDDFF",
	"FFDDVVFFFFFDFFDFFFFFFFFFFFFDFFDFFFVVDDFF",
	"FFDVVVVFFFFFFFFFFFFFFFFFFFFFFFFFFVVVDDFF",
	"FFDDVVVFFFFDFFDFFFFFFFFFFFFDFFDFFFVVDDFF",
	"FFDDVVFFFFFFFFFFFFFFFFFFFFFFFFFFFVVDDDFF",
	"FFDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDDDFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
]

# Ornate golden floor accents — ruins2 decorative tiles in key areas
# Expanded coverage to ~20% — golden floor in sacred chamber, side alcoves,
# gallery intersections
const DETAIL_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                  OOOOOOOO  OO          ",
	"                  OOOOOOO    O          ",
	"                  OOOOOOO               ",
	"                  OOOOOOOO   O          ",
	"                                        ",
	"                     OOOO               ",
	"   OOOO                                 ",
	"   OO  OO                         OO    ",
	"   OO                             OOOO  ",
	"   OO                              OOO  ",
	"   OO  OO                         OO    ",
	"   OOOO                                 ",
	"                                        ",
	"   OOOOO      OOO       OOO      OOOO   ",
	"   O                                OO  ",
	"              OOO       OOO          O  ",
	"   O                                OO  ",
	"   O  OO      OOO       OOO        OO   ",
	"   OOO                            OOO   ",
	"                                        ",
	"                                        ",
]

# Scattered debris from B-sheet (on GroundDebris layer)
# 15-25% coverage in walkable areas — denser near walls and objects
const DEBRIS_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                   mp   rrp             ",
	"                              r         ",
	"                            v r         ",
	"                 m                      ",
	"                                        ",
	"                   p       mm           ",
	"                         p              ",
	"       r                 p              ",
	"      p        r       rp r  r  v       ",
	"  r      rp  v  m   r   p p   v r       ",
	"      m v  v        p   p p  rrr        ",
	"  r   v      m r  rrrr vm     r         ",
	"  r     r                r              ",
	"                      v                 ",
	"  p     rp p      p    m    r        r  ",
	"     ppp   p      v   p  p    m pr v    ",
	"        p  p     rp        p            ",
	"  r v     mr   r       p       p   m    ",
	"         vp v      rm      p     m      ",
	"        pv            r rpr             ",
	"                                        ",
	"                                        ",
]

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
