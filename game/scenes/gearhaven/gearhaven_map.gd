class_name GearhavenMap
extends RefCounted

## Tilemap data constants for Gearhaven city scene.
## Sprawling steampunk coastal metropolis — largest city in the game.
## Industrial stone and metal ground, cobblestone paths, factory smoke.
##
## Ground uses TimeFantasy_TILES/TILESETS/terrain.png (flat 16x16 grid).
## Each biome maps to a row in terrain.png with multiple column variants.
## Variants are picked by position hash for organic, non-repeating coverage.

# terrain.png flat-tile rows:
#   Row 6: warm brown earth/amber (cols 1-5)
#   Row 8: gray stone (cols 1-4)
#   Row 11: dark brown earth (cols 1-5)
enum Biome { GRAY_STONE, DARK_EARTH, AMBER_EARTH }

# -- Map dimensions --
const COLS: int = 40
const ROWS: int = 30

# ---------- PROCEDURAL GROUND CONFIG ----------

const GROUND_NOISE_SEED: int = 66601
const GROUND_NOISE_FREQ: float = 0.08
const GROUND_NOISE_OCTAVES: int = 3

const BIOME_TILES: Dictionary = {
	Biome.GRAY_STONE: [
		Vector2i(1, 8), Vector2i(2, 8),
		Vector2i(3, 8), Vector2i(4, 8),
	],
	Biome.DARK_EARTH: [
		Vector2i(1, 11), Vector2i(2, 11), Vector2i(3, 11),
		Vector2i(4, 11), Vector2i(5, 11),
	],
	Biome.AMBER_EARTH: [
		Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6),
		Vector2i(4, 6), Vector2i(5, 6),
	],
}

# Noise thresholds — sorted high-to-low; first match wins.
# Gray stone dominant (cobblestone city), dark earth in factory areas,
# amber earth rare (exposed harbor ground).
const OPEN_BIOME_THRESHOLDS: Array[Dictionary] = [
	{"threshold": 0.25,  "biome": Biome.AMBER_EARTH},
	{"threshold": -0.35, "biome": Biome.GRAY_STONE},
	{"threshold": -1.0,  "biome": Biome.DARK_EARTH},
]

const VARIANT_HASH_SEED: int = 66602

# -- Paths: sandy/tan variants from TF_TERRAIN row 9 --
const PATH_TILES: Array[Vector2i] = [
	Vector2i(1, 9), Vector2i(2, 9),
	Vector2i(3, 9), Vector2i(4, 9),
]
const PATH_HASH_SEED: int = 66603

# ---------- BUILDING OBJECTS ----------
# Source 1 = STEAMPUNK_CITY1 — industrial objects, fences, barrels.
# Source 2 = STEAMPUNK_CITY2 — gray brick building facades.
# Source 3 = STEAMPUNK_CITY2C — red brick building facades (district flavor).

# Building walls — source 1 (STEAMPUNK_CITY1)
const BUILDING_LEGEND: Dictionary = {
	# Metal wall sections
	"W": Vector2i(0, 4),
	"w": Vector2i(1, 4),
	"X": Vector2i(0, 5),
	"x": Vector2i(1, 5),
	# Barrels and crates
	"B": Vector2i(8, 12),
	"b": Vector2i(9, 12),
	# Fences
	"F": Vector2i(10, 10),
	"f": Vector2i(11, 10),
	# Stone blocks
	"S": Vector2i(0, 12),
	"s": Vector2i(1, 12),
}

# Gray building facades — source 2 (STEAMPUNK_CITY2)
const BUILDING2_LEGEND: Dictionary = {
	"H": Vector2i(0, 4),
	"h": Vector2i(1, 4),
	"J": Vector2i(2, 4),
	"K": Vector2i(0, 5),
	"k": Vector2i(1, 5),
	"L": Vector2i(2, 5),
	"D": Vector2i(8, 8),
	"d": Vector2i(9, 8),
}

# Red brick facades — source 3 (STEAMPUNK_CITY2C)
const BUILDING3_LEGEND: Dictionary = {
	"A": Vector2i(0, 4),
	"a": Vector2i(1, 4),
	"C": Vector2i(2, 4),
	"E": Vector2i(0, 5),
	"e": Vector2i(1, 5),
	"G": Vector2i(2, 5),
}

# Rooftop — source 2 (STEAMPUNK_CITY2) above-player
const ROOF_LEGEND: Dictionary = {
	"T": Vector2i(0, 2),
	"t": Vector2i(1, 2),
	"U": Vector2i(2, 2),
	"V": Vector2i(0, 3),
	"v": Vector2i(1, 3),
	"Y": Vector2i(2, 3),
}

# Detail — source 1 (STEAMPUNK_CITY1) ground decorations
const DETAIL_LEGEND: Dictionary = {
	"r": Vector2i(0, 13),
	"p": Vector2i(1, 13),
}

# ---------- SOLID TILES ----------
const SOLID_TILES: Dictionary = {
	1: [
		Vector2i(0, 4), Vector2i(1, 4),
		Vector2i(0, 5), Vector2i(1, 5),
		Vector2i(8, 12), Vector2i(9, 12),
		Vector2i(0, 12), Vector2i(1, 12),
	],
	2: [
		Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4),
		Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5),
	],
	3: [
		Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4),
		Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5),
	],
}

# ---------- MAP DATA (40 cols x 30 rows) ----------

# Path map: main avenues through the city.
# Central north-south boulevard + east-west cross streets.
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
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                                        ",
]

# Building map — steampunk city1 industrial objects (source 1).
# Factory quarter (west), harbor area (east).
const BUILDING_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"   Ss                            Ss     ",
	"                                        ",
	"   FffF                      FffF       ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"  WwWw                        WwWw      ",
	"  XxXx                        XxXx      ",
	"  WwWw       Bb               WwWw      ",
	"  XxXx                        XxXx      ",
	"                                        ",
	"                                        ",
	"       Bb                  Bb           ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"  WwWw                        WwWw      ",
	"  XxXx                        XxXx      ",
	"                                        ",
	"                                        ",
	"  Ss            Bb              Ss      ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Gray building facades — source 2 (High Rise / Spire districts).
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
	" HhJ                               HhJ  ",
	" KkL                               KkL  ",
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
]

# Red brick facades — source 3 (Factory / Harbor districts).
const BUILDING3_MAP: Array[String] = [
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
	"                                        ",
	" AaC                               AaC  ",
	" EeG                               EeG  ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Gray rooftop map — source 2 (High Rise / Spire).
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
	" TtU                               TtU  ",
	" VvY                               VvY  ",
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
	" TtU                               TtU  ",
	" VvY                               VvY  ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]

# Detail map — sparse ground decorations (source 1).
const DECOR_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"        r                     p         ",
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
	"     p                            r     ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"  r                                p    ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
]


# ---------- STATIC HELPERS ----------


## Return the Biome int for a given noise value.
static func get_biome_for_noise(noise_val: float) -> int:
	for entry: Dictionary in OPEN_BIOME_THRESHOLDS:
		if noise_val >= float(entry.get("threshold", -1.0)):
			return int(entry.get("biome", Biome.DARK_EARTH))
	return Biome.DARK_EARTH


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
