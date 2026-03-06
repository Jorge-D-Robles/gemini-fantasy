class_name PrismfallMap
extends RefCounted

## Tilemap data constants for the Prismfall town scene.
## Crystal trading town on the edge of a canyon — gray stone streets,
## crystal/stone buildings, sandy market paths.
##
## Ground uses TimeFantasy_TILES/TILESETS/terrain.png (flat 16x16 grid).
## Buildings use tf_B_ruins1.png (crystal pillars, statues, archways).
## Detail uses tf_ff_tileB_stone.png (rocks, flowers, pebbles).

# Biome zones — gray stone dominant for a city-on-rock feel.
# terrain.png flat-tile rows:
#   Row 7: blue-gray stone (cols 1-4)
#   Row 8: gray stone (cols 1-4)
#   Row 11: dark brown earth (cols 1-5)
enum Biome { GRAY_STONE, BLUE_STONE, DARK_STONE }

# Map dimensions
const COLS: int = 40
const ROWS: int = 28

# ---------- PROCEDURAL GROUND CONFIG ----------

# Ground noise — stone city terrain (source 0 = TF_TERRAIN).
const GROUND_NOISE_SEED: int = 77701
const GROUND_NOISE_FREQ: float = 0.08
const GROUND_NOISE_OCTAVES: int = 3

const BIOME_TILES: Dictionary = {
	Biome.GRAY_STONE: [
		Vector2i(1, 8), Vector2i(2, 8),
		Vector2i(3, 8), Vector2i(4, 8),
	],
	Biome.BLUE_STONE: [
		Vector2i(1, 7), Vector2i(2, 7),
		Vector2i(3, 7), Vector2i(4, 7),
	],
	Biome.DARK_STONE: [
		Vector2i(1, 11), Vector2i(2, 11),
		Vector2i(3, 11), Vector2i(4, 11),
	],
}

# Noise thresholds — gray stone dominant, blue-stone accent, dark edges.
const OPEN_BIOME_THRESHOLDS: Array[Dictionary] = [
	{"threshold": 0.2,  "biome": Biome.BLUE_STONE},
	{"threshold": -0.3, "biome": Biome.GRAY_STONE},
	{"threshold": -1.0, "biome": Biome.DARK_STONE},
]

const VARIANT_HASH_SEED: int = 77702

# -- Paths: sandy/tan variants from TF_TERRAIN row 9 --
const PATH_TILES: Array[Vector2i] = [
	Vector2i(1, 9), Vector2i(2, 9),
	Vector2i(3, 9), Vector2i(4, 9),
]
const PATH_HASH_SEED: int = 77703

# -- Detail: flower/rock accents (source 2 = STONE_OBJECTS) --
const DETAIL_LEGEND: Dictionary = {
	"r": Vector2i(0, 0),
	"R": Vector2i(1, 0),
	"f": Vector2i(0, 1),
}

# -- Building walls (source 1 = RUINS1_OBJECTS) --
# Crystal pillars, statue bases, stone walls from tf_B_ruins1.png.
# Viewed the sheet: rows 0-3 have pillars/statues, rows 4-7 have bridges/arches,
# rows 8-11 have the triangular building and walls, rows 12-15 have skulls/rubble.
const BUILDING_LEGEND: Dictionary = {
	# Pillar pieces
	"P": Vector2i(0, 2),   # pillar base left
	"Q": Vector2i(1, 2),   # pillar base right
	"p": Vector2i(0, 1),   # pillar mid left
	"q": Vector2i(1, 1),   # pillar mid right
	# Stone wall sections
	"W": Vector2i(8, 5),   # wall block dark
	"w": Vector2i(9, 5),   # wall block light
	"X": Vector2i(8, 6),   # wall block bottom dark
	"x": Vector2i(9, 6),   # wall block bottom light
	# Statue elements
	"S": Vector2i(2, 2),   # statue base
	"s": Vector2i(2, 1),   # statue top
	# Bridge/arch horizontal
	"B": Vector2i(4, 4),   # bridge left
	"b": Vector2i(5, 4),   # bridge mid
	"C": Vector2i(6, 4),   # bridge right
	# Fountain
	"F": Vector2i(4, 2),   # fountain base
}

# -- Rooftop / above-player elements (source 1 = RUINS1_OBJECTS) --
const ROOF_LEGEND: Dictionary = {
	"T": Vector2i(0, 0),   # pillar top left
	"U": Vector2i(1, 0),   # pillar top right
	"A": Vector2i(4, 3),   # arch top left
	"a": Vector2i(5, 3),   # arch top mid
	"D": Vector2i(6, 3),   # arch top right
}

# -- Solid tiles for collision (source_id -> Array[Vector2i]) --
const SOLID_TILES: Dictionary = {
	1: [
		Vector2i(0, 1), Vector2i(1, 1),   # pillar mid
		Vector2i(0, 2), Vector2i(1, 2),   # pillar base
		Vector2i(2, 1), Vector2i(2, 2),   # statue
		Vector2i(8, 5), Vector2i(9, 5),   # wall top
		Vector2i(8, 6), Vector2i(9, 6),   # wall bottom
		Vector2i(4, 2),                     # fountain
	],
}

# ---------- MAP DATA (40 cols x 28 rows) ----------

# Path map: sandy paths connecting districts.
# North entry (col 18-21), branching to market (center), inn (east), archives (west).
const PATH_MAP: Array[String] = [
	"                                        ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"        PPPPPPPPPPPPPPPPPPPPPPPP        ",
	"        PPPPPPPPPPPPPPPPPPPPPPPP        ",
	"        PP        PPPP        PP        ",
	"        PP        PPPP        PP        ",
	"        PP  PPPPPPPPPPPPPPPP  PP        ",
	"        PP  PPPPPPPPPPPPPPPP  PP        ",
	"        PP  PP            PP  PP        ",
	"        PP  PP            PP  PP        ",
	"        PP  PP            PP  PP        ",
	"        PP  PP            PP  PP        ",
	"        PP  PPPPPPPPPPPPPPPP  PP        ",
	"        PP  PPPPPPPPPPPPPPPP  PP        ",
	"        PPPPPPPPPPPPPPPPPPPPPPPP        ",
	"        PPPPPPPPPPPPPPPPPPPPPPPP        ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                                        ",
]

# Building map: crystal/stone structures from RUINS1_OBJECTS.
# Inn area (east, rows 11-18), Archives (west, rows 11-18),
# Market stalls (center, rows 13-19), entry arch (north, row 4-5).
const BUILDING_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                 PbbQ                   ",
	"                 pbbq                   ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"    PQ                          PQ      ",
	"    pq       S          S       pq      ",
	"             s          s               ",
	"                                        ",
	"     WwWw                  WwWw         ",
	"     XxXx                  XxXx         ",
	"     WwWw        F         WwWw         ",
	"     XxXx                  XxXx         ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"              S          S              ",
	"              s          s              ",
	"                                        ",
]

# Roof/above-player map: pillar tops, arch tops.
const ROOF_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                 AaD                    ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"    TU                          TU      ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Detail/decoration map: sparse rocks and flowers.
const DECOR_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	" r          R                     f     ",
	"                                        ",
	"                                        ",
	"                                        ",
	"      f                       R         ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"  R                                r    ",
	"                                        ",
	"                                        ",
	"       f                   R            ",
	"                                        ",
	"                                        ",
]


# ---------- STATIC HELPERS ----------


## Return the Biome int for a given noise value.
static func get_biome_for_noise(noise_val: float) -> int:
	for entry: Dictionary in OPEN_BIOME_THRESHOLDS:
		if noise_val >= float(entry.get("threshold", -1.0)):
			return int(entry.get("biome", Biome.GRAY_STONE))
	return Biome.GRAY_STONE


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
