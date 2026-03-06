class_name EmberhearthMap
extends RefCounted

## Tilemap data constants for Emberhearth city scene.
## Volcanic caldera city with dark earth, gray stone, and amber clay ground.
##
## Ground uses TimeFantasy_TILES/TILESETS/terrain.png (flat 16x16 grid).
## Each biome maps to a row in terrain.png with multiple column variants.
## Variants are picked by position hash for organic, non-repeating coverage.

# terrain.png flat-tile rows:
#   Row 6: warm brown earth/amber (cols 1-5)
#   Row 8: gray stone (cols 1-4)
#   Row 11: dark brown earth (cols 1-5)
enum Biome { DARK_EARTH, GRAY_STONE, AMBER_EARTH }

# -- Map dimensions --
const COLS: int = 40
const ROWS: int = 28

# ---------- PROCEDURAL GROUND CONFIG ----------

const GROUND_NOISE_SEED: int = 88801
const GROUND_NOISE_FREQ: float = 0.07
const GROUND_NOISE_OCTAVES: int = 3

const BIOME_TILES: Dictionary = {
	Biome.DARK_EARTH: [
		Vector2i(1, 11), Vector2i(2, 11), Vector2i(3, 11),
		Vector2i(4, 11), Vector2i(5, 11),
	],
	Biome.GRAY_STONE: [
		Vector2i(1, 8), Vector2i(2, 8),
		Vector2i(3, 8), Vector2i(4, 8),
	],
	Biome.AMBER_EARTH: [
		Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6),
		Vector2i(4, 6), Vector2i(5, 6),
	],
}

# Noise thresholds — sorted high-to-low; first match wins.
# Dark earth dominant (volcanic ash), gray stone in patches,
# amber earth rare (clay near buildings).
const OPEN_BIOME_THRESHOLDS: Array[Dictionary] = [
	{"threshold": 0.3,  "biome": Biome.AMBER_EARTH},
	{"threshold": -0.3, "biome": Biome.DARK_EARTH},
	{"threshold": -1.0, "biome": Biome.GRAY_STONE},
]

const VARIANT_HASH_SEED: int = 88802

# -- Paths: sandy/tan variants from TF_TERRAIN row 9 --
const PATH_TILES: Array[Vector2i] = [
	Vector2i(1, 9), Vector2i(2, 9),
	Vector2i(3, 9), Vector2i(4, 9),
]
const PATH_HASH_SEED: int = 88803

# ---------- CALDERA BORDER ----------
# Ashlands rock objects (source 1 = ASHLANDS_OBJECTS) — 6+ variants
# for organic caldera rim via fill_layer_with_variants().
# tf_B_ashlands_1.png: row 0-1 have rock/cliff pieces.
const BORDER_VARIANT_LEGEND: Dictionary = {
	"R": [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
	],
}
const BORDER_HASH_SEED: int = 88804

# ---------- BUILDING OBJECTS ----------
# Source 2 = STEAMPUNK_CITY1 — industrial objects, fences, barrels.
# Source 3 = STEAMPUNK_CITY2 — building walls, rooftops, windows.
# Steampunk city1 (16x16 grid):
#   Row 4-5: dark metal walls, pipes
#   Row 6-7: barrels, crates, storage
#   Row 10-11: wooden fences, gates
#   Row 12-13: stone blocks, rubble
# Steampunk city2 (16x16 grid):
#   Row 0-3: large buildings (multi-tile)
#   Row 4-7: building variants, rooftops
#   Row 8-11: windows, doors, wall details
#   Row 12-15: flower boxes, ground detail

# Building walls — source 2 (STEAMPUNK_CITY1)
const BUILDING_LEGEND: Dictionary = {
	# Metal wall sections (dark industrial)
	"W": Vector2i(0, 4),   # wall dark left
	"w": Vector2i(1, 4),   # wall dark right
	"X": Vector2i(0, 5),   # wall bottom left
	"x": Vector2i(1, 5),   # wall bottom right
	# Barrels and crates
	"B": Vector2i(8, 12),  # barrel
	"b": Vector2i(9, 12),  # crate
	# Fences
	"F": Vector2i(10, 10), # fence post
	"f": Vector2i(11, 10), # fence rail
	# Stone blocks
	"S": Vector2i(0, 12),  # stone block
	"s": Vector2i(1, 12),  # stone rubble
}

# Building walls — source 3 (STEAMPUNK_CITY2)
const BUILDING2_LEGEND: Dictionary = {
	# Building facade pieces
	"H": Vector2i(0, 4),   # house wall left
	"h": Vector2i(1, 4),   # house wall mid
	"J": Vector2i(2, 4),   # house wall right
	"K": Vector2i(0, 5),   # house base left
	"k": Vector2i(1, 5),   # house base mid
	"L": Vector2i(2, 5),   # house base right
	# Windows and doors
	"D": Vector2i(8, 8),   # door
	"d": Vector2i(9, 8),   # window
}

# Rooftop — source 3 (STEAMPUNK_CITY2) above-player
const ROOF_LEGEND: Dictionary = {
	"T": Vector2i(0, 2),   # roof left
	"t": Vector2i(1, 2),   # roof mid
	"U": Vector2i(2, 2),   # roof right
	"V": Vector2i(0, 3),   # roof edge left
	"v": Vector2i(1, 3),   # roof edge mid
	"Y": Vector2i(2, 3),   # roof edge right
}

# Detail — source 2 (STEAMPUNK_CITY1) ground decorations
const DETAIL_LEGEND: Dictionary = {
	"r": Vector2i(0, 13),  # rubble small
	"p": Vector2i(1, 13),  # rubble pile
}

# ---------- SOLID TILES ----------
const SOLID_TILES: Dictionary = {
	1: [
		# Ashlands border rocks
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
	],
	2: [
		# Steampunk city1 walls
		Vector2i(0, 4), Vector2i(1, 4),
		Vector2i(0, 5), Vector2i(1, 5),
		# Barrels
		Vector2i(8, 12), Vector2i(9, 12),
		# Stone blocks
		Vector2i(0, 12), Vector2i(1, 12),
	],
	3: [
		# Steampunk city2 building walls
		Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4),
		Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5),
	],
}

# ---------- MAP DATA (40 cols x 28 rows) ----------

# Path map: sandy paths connecting districts.
# North entry (cols 18-21), central plaza, south exit.
const PATH_MAP: Array[String] = [
	"                                        ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"       PPPPPPPPPPPPPPPPPPPPPPPPP        ",
	"       PPPPPPPPPPPPPPPPPPPPPPPPP        ",
	"       PP         PPPP         PP       ",
	"       PP         PPPP         PP       ",
	"       PP   PPPPPPPPPPPPPPPP   PP       ",
	"       PP   PPPPPPPPPPPPPPPP   PP       ",
	"       PP   PP            PP   PP       ",
	"       PP   PP            PP   PP       ",
	"       PP   PP            PP   PP       ",
	"       PP   PP            PP   PP       ",
	"       PP   PPPPPPPPPPPPPPPP   PP       ",
	"       PP   PPPPPPPPPPPPPPPP   PP       ",
	"       PPPPPPPPPPPPPPPPPPPPPPPPP        ",
	"       PPPPPPPPPPPPPPPPPPPPPPPPP        ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                                        ",
]

# Caldera border map — ashlands rocks along edges.
# 'R' = rock variant (fill_layer_with_variants picks from 6+ variants).
const BORDER_MAP: Array[String] = [
	"RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR",
	"RR                                    RR",
	"R                                      R",
	"R                                      R",
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
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"R                                      R",
	"RR                                    RR",
	"RRRRRRRRRRRR              RRRRRRRRRRRRRR",
]

# Building map — steampunk city objects (source 2).
# Inn area (east), Forge Quarter (west), central plaza.
const BUILDING_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"    Ss                          Ss      ",
	"                                        ",
	"    FffF                    FffF        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"   WwWw                      WwWw       ",
	"   XxXx                      XxXx       ",
	"   WwWw        Bb            WwWw       ",
	"   XxXx                      XxXx       ",
	"                                        ",
	"                                        ",
	"         Bb                Bb           ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"   WwWw                      WwWw       ",
	"   XxXx                      XxXx       ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Building2 map — steampunk city2 building facades (source 3).
# Inn (east rows 10-14), shop (west rows 10-14).
const BUILDING2_MAP: Array[String] = [
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
	"  HhJ                            HhJ    ",
	"  KkL                            KkL    ",
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
	"  HhJ                            HhJ    ",
	"  KkL                            KkL    ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Roof map — above-player (source 3).
const ROOF_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"  TtU                            TtU    ",
	"  VvY                            VvY    ",
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
	"  TtU                            TtU    ",
	"  VvY                            VvY    ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Detail map — sparse ground decorations (source 2).
const DECOR_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"          r                   p         ",
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
	"       p                          r     ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"    r                              p    ",
	"                                        ",
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
