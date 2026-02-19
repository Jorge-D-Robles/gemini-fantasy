class_name RoothollowMaps
extends RefCounted

## Tilemap data constants for Roothollow scene.
## Separated from roothollow.gd to stay under the 1000-line limit.

# -- Map dimensions --
const MAP_COLS: int = 40
const MAP_ROWS: int = 28

# -- Ground: organic terrain patches (all col 0 to avoid seams) --
# G = Bright green grass (row 8) — dominant open areas ~60%
# D = Dirt/earth (row 2) — around buildings, path edges ~20%
# E = Dark earth/roots (row 6) — forest border transition ~20%
const GROUND_LEGEND: Dictionary = {
	"G": Vector2i(0, 8),
	"D": Vector2i(0, 2),
	"E": Vector2i(0, 6),
}

# -- Paths: gray stone from A5_A row 10 --
const PATH_LEGEND: Dictionary = {
	"S": Vector2i(0, 10),
}

# -- Detail: flower accents from A5_A row 14 (source 0) --
const DETAIL_LEGEND: Dictionary = {
	"f": Vector2i(0, 14),
	"F": Vector2i(1, 14),
	"b": Vector2i(2, 14),
	"B": Vector2i(3, 14),
}

# -- Mushroom ground decorations (source 1 = MUSHROOM_VILLAGE) --
const MUSHROOM_DECOR_LEGEND: Dictionary = {
	"m": Vector2i(0, 0),
	"M": Vector2i(1, 0),
	"n": Vector2i(2, 0),
}

# -- Stone ground decorations (source 3 = STONE_OBJECTS) --
const STONE_DECOR_LEGEND: Dictionary = {
	"r": Vector2i(0, 0),
	"R": Vector2i(1, 0),
	"o": Vector2i(0, 1),
}

# -- Forest border canopy (source 2 = FOREST_OBJECTS) --
# Single canopy center tile for uniform fill — avoids checkerboard
const BORDER_LEGEND: Dictionary = {
	"T": Vector2i(1, 1),
}

# -- Mushroom building rooftops (source 1, AbovePlayer layer) --
# Tile coords verified: mushroom caps are LEFT side (cols 0-7)
# Large red mushroom: rows 8-10 cols 2-6 (cap dome, middle, brim)
# Medium red mushroom: rows 3-4 cols 1-5 (cap dome, brim)
# Brown/gold mushroom: rows 12-13 cols 4-8 (cap dome, brim)
const ROOF_LEGEND: Dictionary = {
	# Inn (large red mushroom cap)
	"a": Vector2i(2, 8), "b": Vector2i(3, 8),
	"c": Vector2i(4, 8), "d": Vector2i(5, 8),
	"e": Vector2i(1, 9), "f": Vector2i(2, 9),
	"g": Vector2i(3, 9), "h": Vector2i(4, 9),
	"i": Vector2i(5, 9), "j": Vector2i(6, 9),
	"k": Vector2i(1, 10), "l": Vector2i(2, 10),
	"m": Vector2i(3, 10), "n": Vector2i(4, 10),
	"o": Vector2i(5, 10), "p": Vector2i(6, 10),
	# Shop (medium red mushroom cap)
	"q": Vector2i(1, 3), "r": Vector2i(2, 3),
	"s": Vector2i(3, 3), "t": Vector2i(4, 3),
	"u": Vector2i(0, 4), "v": Vector2i(1, 4),
	"w": Vector2i(2, 4), "x": Vector2i(3, 4),
	"y": Vector2i(4, 4), "z": Vector2i(5, 4),
	# Elder (brown/gold mushroom cap)
	"H": Vector2i(4, 12), "I": Vector2i(5, 12),
	"J": Vector2i(6, 12), "K": Vector2i(7, 12),
	"L": Vector2i(3, 13), "N": Vector2i(4, 13),
	"O": Vector2i(5, 13), "P": Vector2i(6, 13),
	"Q": Vector2i(7, 13), "R": Vector2i(8, 13),
}

# -- Mushroom building walls (source 1, Objects layer) --
# Collision-enabled stem/wall tiles (left side of sheet)
const BUILDING_LEGEND: Dictionary = {
	# Inn stem: row 11, cols 2-5
	"1": Vector2i(2, 11), "2": Vector2i(3, 11),
	"3": Vector2i(4, 11), "4": Vector2i(5, 11),
	# Shop stem: row 5, cols 2-4
	"a": Vector2i(2, 5), "b": Vector2i(3, 5),
	"c": Vector2i(4, 5),
	# Elder stem: row 14, cols 4-7
	"g": Vector2i(4, 14), "h": Vector2i(5, 14),
	"i": Vector2i(6, 14), "j": Vector2i(7, 14),
}

# ===== Text maps (40 cols x 28 rows) =====

# Ground terrain — organic patches of grass, dirt, dark earth
# G = bright green grass (dominant open areas)
# D = dirt/earth (around buildings, path borders, well-trodden areas)
# E = dark earth/roots (transition band at forest border edge)
# Visible balance: G ~61%, D ~18%, E ~21% (under-canopy E not counted)
# Row key:  0-3 = under canopy / forest edge transition (E)
#           4-8 = Inn zone — dirt yard around building
#           9   = scattered dirt above main road
#          10-11 = main road (paths overlay, ground is green)
#          12    = scattered dirt below main road
#          13-18 = central area with paths, shop dirt yard (cols 27-33)
#          19-23 = elder dirt yard (cols 11-18)
#          24-27 = under canopy / forest edge (E)
const GROUND_MAP: Array[String] = [
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEGGGGGGGGGGGGGDGGDGGGGGGGGGGGEEEEEEE",
	"EEEEEGGGGGDDDDGGGGDGGGGGGGGGGGGGGGEEEEEE",
	"EEEEEGGGDDDDDDDDGGDGGDGGGGGGGGGGGGEEEEEE",
	"EEEEEGGGDDDDDDDDGGGGGDGGGGGGGGGGGGGEEEEE",
	"EEEEEEGGGDDDDDDGGGGGGDGGGGGGGGGGGGEEEEEE",
	"EEEEEEDDDGDDDDDDDGGGGGDDDDGGGGDDDGEEEEEE",
	"EEEEEEGGGGGGGGGGGGGGGGGGGGGGGGGGGGEEEEEE",
	"EEEEEGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGEEEEE",
	"EEEEEDDDDDGGGGGGGGGGGGDDDGGGDDDGGGGEEEEE",
	"EEEEEGGGGGGGGGGGGGDGGGGGGGGGGGGGGGGEEEEE",
	"EEEEEGGGGGGGGGGGGGDGGDGGGGGGGGGGGGGEEEEE",
	"EEEEEGDDDGGGGGGGGGDGGGGGGGGGGGGGGGEEEEEE",
	"EEEEEGGDDGGGGGGGGGGGGDGGGGGGDDDDDGEEEEEE",
	"EEEEEEGGGGGGGGGGGGDGGGGGGGGDDDDDDDEEEEEE",
	"EEEEEEGGGGGGGGGGGGDGGDGGGGGDDDDDDGEEEEEE",
	"EEEEEEGGGGGGGDDDDDDGGGGGGGGGDDDDGGEEEEEE",
	"EEEEEGGGDDGGDDDDDDDGGDGGGGGGGGGGGGGEEEEE",
	"EEEEEGGGGGGDDDDDDDDGGGGGGGGGGGGGGGEEEEEE",
	"EEEEEGGGGGGGDDDDDDDGGGGGGGGGGGGGGEEEEEEE",
	"EEEEEEEGGGGGGDDDDGDGGDGGGGGGGGGEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
]

# Stone paths: main E-W road, N-S crossroad, plaza, approaches
const PATH_MAP: Array[String] = [
	"",
	"",
	"",
	"",
	"                   SS                   ",
	"                   SS                   ",
	"                   SS                   ",
	"          SS       SS                   ",
	"          SS       SS                   ",
	"          SSSSSSSSSSS                   ",
	"     SSSSSSSSSSSSSSSSSSSSSSSSSSSSSS     ",
	"     SSSSSSSSSSSSSSSSSSSSSSSSSSSSSS     ",
	"              SS   SSSS        SS       ",
	"              SSSSSSSSSS       SS       ",
	"              SSSSSSSSSS       SS       ",
	"              SS   SS          SS       ",
	"              SS   SS          SS       ",
	"              SS   SS          SS       ",
	"              SS   SS                   ",
	"              SS   SS                   ",
	"              SS   SS                   ",
	"              SS   SS                   ",
	"              SSSSSSSS                  ",
	"                   SS                   ",
	"",
	"",
	"",
	"",
]

# Combined ground decoration map — flower, mushroom, stone accents
# Characters: f,F,b,B = flowers (source 0, _ground_detail)
#             m,M,n   = mushroom decor (source 1, _decorations)
#             r,R,o   = stone decor (source 3, _decorations)
# Coverage: ~13% of visible open tiles (~89 decorations)
const DECOR_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"     m      F     f m       r    B      ",
	"   r     m              o     r        F",
	"     f           m   b           F      ",
	"    R           f        r f            ",
	"       n          f  b       B     r    ",
	"         b    r        o   b     o      ",
	"     F               f       o m        ",
	"                                       R",
	"    r                              F    ",
	"      r         F      f      f         ",
	"   n      b  M            F       M     ",
	"      r                       B         ",
	"                        F   b     r     ",
	"   f     f      b f   n                m",
	"     M                   M        F     ",
	"           f F    F        m    r      f",
	"      f                f      f         ",
	"    f      M         f   m      b       ",
	"                                   b    ",
	"      f    f          f m    f m        ",
	"    R         r                  M      ",
	"        f   b      R  r   b o           ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Forest border — single canopy tile, organic clearing shape
# Symmetric 3-5 tile border on each side
const BORDER_MAP: Array[String] = [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ",
	"TTTT                              TTTTT",
	"TTT                                TTTT",
	"TTTT                               TTTT",
	"TTT                                 TTT",
	"TTT                                 TTT",
	"TTTT                                TTT",
	"TTTTT                              TTTT",
	"TTT                                 TTT",
	"TTT                                  TT",
	"TTTT                                TTT",
	"TTT                                 TTT",
	"TTTT                                TTT",
	"TTTT                                TTT",
	"TTT                                TTTT",
	"TTTT                                TTT",
	"TTTTT                              TTTT",
	"TTT                                 TTT",
	"TTT                                  TT",
	"TTTT                                TTT",
	"TTT                                TTTT",
	"TTTT                              TTTTT",
	"TTTTTT                          TTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]

# Mushroom house caps (source 1, AbovePlayer)
# Inn: rows 4-6 — 4 wide dome, 6 wide cap, 6 wide brim
# Shop: rows 16-17 — 4 wide dome, 6 wide brim
# Elder: rows 20-21 — 4 wide dome, 6 wide brim
const ROOF_MAP: Array[String] = [
	"",
	"",
	"",
	"",
	"          abcd                          ",
	"         efghij                         ",
	"         klmnop                         ",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"                            qrst        ",
	"                           uvwxyz       ",
	"",
	"",
	"             HIJK                       ",
	"            LNOPQR                      ",
	"",
	"",
	"",
	"",
	"",
	"",
]

# Mushroom house walls/stems (source 1, Objects with collision)
# Inn stem: rows 7-7, cols 10-13 (4 wide)
# Shop stem: rows 18-18, cols 28-30 (3 wide)
# Elder stem: rows 22-22, cols 13-16 (4 wide)
const BUILDING_MAP: Array[String] = [
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"          1234                          ",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"                            abc         ",
	"",
	"",
	"",
	"             ghij                       ",
	"",
	"",
	"",
	"",
	"",
]

# -- Forest canopy overlay (source 2, AbovePlayer layer) --
# Overhanging canopy at inner border edges — player walks under (z_index=2)
# Tiles from first round canopy formation in FOREST_OBJECTS:
# @ = right-side tile (transparent right edge) → placed at LEFT clearing edge
# ! = center fill (solid green) → top/bottom bands
# # = left-side tile (transparent left edge) → placed at RIGHT clearing edge
const CANOPY_LEGEND: Dictionary = {
	"!": Vector2i(1, 1),
	"@": Vector2i(2, 1),
	"#": Vector2i(0, 1),
}

# Canopy overlay follows BORDER_MAP inner edge, 1 tile into clearing.
# Top/bottom bands: full clearing width. Side edges: 1 tile per side.
# No overlap with ROOF_MAP positions (canopy at edges, roofs in center).
const CANOPY_MAP: Array[String] = [
	"",
	"",
	"",
	"    !@#! @!#! #!@! @!#!!@!#!@#!!@!#",
	"   @  !          !    #    @   !  #",
	"    @!                            #!",
	"   @!                              !#",
	"   @                                #",
	"    @                               #",
	"     @                            #",
	"   @                                #",
	"   @                                 #",
	"    @                               #",
	"   @                                #",
	"    @                               #",
	"    @                               #",
	"   @                               #",
	"    @                               #",
	"     @                            #",
	"   @                                #",
	"   @                                 #",
	"    @                               #",
	"   @                               #",
	"    #!@#! @!#! @!#! !@#!!@!#!@#!!@!",
	"      @!#! @!#!!@!# !@!#!@#!",
	"",
	"",
	"",
]

# Solid tile definitions for collision
# Source 1 = MUSHROOM_VILLAGE stems, Source 2 = FOREST_OBJECTS border
const SOLID_TILES: Dictionary = {
	1: [
		# Inn stem tiles (row 11, cols 2-5)
		Vector2i(2, 11), Vector2i(3, 11),
		Vector2i(4, 11), Vector2i(5, 11),
		# Shop stem tiles (row 5, cols 2-4)
		Vector2i(2, 5), Vector2i(3, 5),
		Vector2i(4, 5),
		# Elder stem tiles (row 14, cols 4-7)
		Vector2i(4, 14), Vector2i(5, 14),
		Vector2i(6, 14), Vector2i(7, 14),
	],
	2: [
		# Forest canopy fill
		Vector2i(1, 1),
	],
}
