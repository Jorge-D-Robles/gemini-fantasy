class_name RoothollowMaps
extends RefCounted

## Tilemap data constants for Roothollow scene.
## Separated from roothollow.gd to stay under the 1000-line limit.
##
## Ground uses TimeFantasy_TILES/TILESETS/terrain.png (flat 16x16 grid).
## Each biome maps to a row in terrain.png with multiple column variants.
## Variants are picked by position hash for organic, non-repeating coverage.

# Biome zones — noise threshold -> biome, position hash -> column variant.
# terrain.png flat-tile rows (avoid cols 22+ which are RPGMaker auto-tiles):
#   Row 1: bright green grass     (cols 2-8)
#   Row 2: muted/shaded green     (cols 1-7)
#   Row 6: warm brown earth/dirt  (cols 1-6)
enum Biome { BRIGHT_GREEN, MUTED_GREEN, DIRT }

# -- Map dimensions --
const MAP_COLS: int = 40
const MAP_ROWS: int = 28

# ---------- PROCEDURAL GROUND CONFIG ----------

# Ground noise — organic terrain patches (source 0 = TF_TERRAIN).
const GROUND_NOISE_SEED: int = 55543
const GROUND_NOISE_FREQ: float = 0.10
const GROUND_NOISE_OCTAVES: int = 4

const BIOME_TILES: Dictionary = {
	Biome.BRIGHT_GREEN: [
		Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1),
		Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1),
	],
	Biome.MUTED_GREEN: [
		Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2),
		Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2),
	],
	Biome.DIRT: [
		Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6),
		Vector2i(4, 6), Vector2i(5, 6), Vector2i(6, 6),
	],
}

# Noise thresholds — sorted high-to-low; first match wins.
const OPEN_BIOME_THRESHOLDS: Array[Dictionary] = [
	{"threshold": 0.15,  "biome": Biome.BRIGHT_GREEN},
	{"threshold": -0.15, "biome": Biome.MUTED_GREEN},
	{"threshold": -1.0,  "biome": Biome.DIRT},
]

# Position hash seed — mixed with (x, y) to pick column variant within a biome.
const VARIANT_HASH_SEED: int = 55544

# -- Paths: sandy/tan variants from TF_TERRAIN row 9 --
# Position hash picks among 4 column variants for per-tile variety.
const PATH_TILES: Array[Vector2i] = [
	Vector2i(1, 9), Vector2i(2, 9),
	Vector2i(3, 9), Vector2i(4, 9),
]
const PATH_HASH_SEED: int = 55545
const PATH_LEGEND: Dictionary = {
	"S": Vector2i(2, 9),
}

# -- Detail: flower/pebble accents (source 3 = STONE_OBJECTS) --
const DETAIL_LEGEND: Dictionary = {
	"f": Vector2i(0, 1),
	"F": Vector2i(1, 1),
	"b": Vector2i(2, 1),
	"B": Vector2i(2, 0),
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

# Ground is now procedural — see GROUND_ENTRIES above.

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
# Characters: f,F,b,B = flowers (source 3 = STONE_OBJECTS, _ground_detail)
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
	"TTTT                              TTTTTT",
	"TTT                                TTTTT",
	"TTTT                               TTTTT",
	"TTT                                 TTTT",
	"TTT                                 TTTT",
	"TTTT                                TTTT",
	"TTTTT                              TTTTT",
	"TTT                                 TTTT",
	"TTT                                  TTT",
	"TTTT                                TTTT",
	"TTT                                 TTTT",
	"TTTT                                TTTT",
	"TTTT                                TTTT",
	"TTT                                TTTTT",
	"TTTT                                TTTT",
	"TTTTT                              TTTTT",
	"TTT                                 TTTT",
	"TTT                                  TTT",
	"TTTT                                TTTT",
	"TTT                                TTTTT",
	"TTTT                              TTTTTT",
	"TTTTTT                          TTTTTTTT",
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
	"    @!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#",
	"   @                               #",
	"    @                              #",
	"   @                                #",
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
	"    @!   !!  !!!  !! !!!  !!  ! !!#",
	"      @!!  !!  !!!  !! !!  !!#",
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

# ---------- STATIC HELPERS ----------


## Return the Biome int for a given noise value.
static func get_biome_for_noise(noise_val: float) -> int:
	for entry: Dictionary in OPEN_BIOME_THRESHOLDS:
		if noise_val >= float(entry.get("threshold", -1.0)):
			return int(entry.get("biome", Biome.DIRT))
	return Biome.DIRT


## Pick a tile atlas coord for (x, y) using noise + position hash.
static func pick_tile(noise_val: float, x: int, y: int) -> Vector2i:
	var biome: int = get_biome_for_noise(noise_val)
	var variants: Array = BIOME_TILES[biome]
	var idx: int = abs(x * 73 + y * 31 + VARIANT_HASH_SEED) % variants.size()
	return variants[idx]


## Pick a path tile variant for (x, y) using position hash.
static func pick_path_tile(x: int, y: int) -> Vector2i:
	var idx: int = abs(x * 73 + y * 31 + PATH_HASH_SEED) % PATH_TILES.size()
	return PATH_TILES[idx]
