class_name PrismfallApproachMap
extends RefCounted

## Tilemap data constants for the Prismfall Approach (Crystalline Steppes).
## All legends and map arrays live here so prismfall_approach.gd stays concise.
## Map: 40 cols x 24 rows (640 x 384 px).
## Theme: open rocky steppes leading south toward Prismfall canyon.
##
## Ground uses TimeFantasy_TILES/TILESETS/terrain.png (flat 16x16 grid).
## Each biome maps to a row in terrain.png with multiple column variants.
## Variants are picked by position hash for organic, non-repeating coverage.

# Biome zones — noise threshold -> biome, position hash -> column variant.
# terrain.png flat-tile rows:
#   Row 6: warm brown earth/amber (cols 1-5)
#   Row 8: gray stone (cols 1-4)
#   Row 11: dark brown earth (cols 1-5)
enum Biome { AMBER_EARTH, GRAY_STONE, DARK_EARTH }

# Map dimensions
const COLS: int = 40
const ROWS: int = 24

# ---------- PROCEDURAL GROUND CONFIG ----------

# Ground noise — rocky steppe terrain (source 0 = TF_TERRAIN).
const GROUND_NOISE_SEED: int = 99887
const GROUND_NOISE_FREQ: float = 0.05
const GROUND_NOISE_OCTAVES: int = 3

const BIOME_TILES: Dictionary = {
	Biome.AMBER_EARTH: [
		Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6),
		Vector2i(4, 6), Vector2i(5, 6),
	],
	Biome.GRAY_STONE: [
		Vector2i(1, 8), Vector2i(2, 8),
		Vector2i(3, 8), Vector2i(4, 8),
	],
	Biome.DARK_EARTH: [
		Vector2i(1, 11), Vector2i(2, 11), Vector2i(3, 11),
		Vector2i(4, 11), Vector2i(5, 11),
	],
}

# Noise thresholds — sorted high-to-low; first match wins.
# Gray stone is dominant (middle band), amber earth is rare (high noise),
# dark earth fills edges (low noise catch-all).
const OPEN_BIOME_THRESHOLDS: Array[Dictionary] = [
	{"threshold": 0.3,  "biome": Biome.AMBER_EARTH},
	{"threshold": -0.4, "biome": Biome.GRAY_STONE},
	{"threshold": -1.0, "biome": Biome.DARK_EARTH},
]

# Position hash seed — mixed with (x, y) to pick column variant within a biome.
const VARIANT_HASH_SEED: int = 99891

# Detail scatter — scattered rocks flanking the path (source 1 = STONE_OBJECTS)
const DETAIL_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 0), "source_id": 1, "density": 0.06},  # small rock
	{"atlas": Vector2i(1, 0), "source_id": 1, "density": 0.05},  # rock variant
	{"atlas": Vector2i(2, 0), "source_id": 1, "density": 0.04},  # pebble cluster
]

# Path tiles — sandy/tan from TF_TERRAIN row 9, position-hashed for variety.
const PATH_TILES: Array[Vector2i] = [
	Vector2i(2, 9), Vector2i(3, 9),
	Vector2i(4, 9), Vector2i(5, 9),
]
const PATH_HASH_SEED: int = 99889

# ---------- MAP DATA (40 cols x 24 rows) ----------
# Ground and detail are now procedural — see noise configs above.

# Path: amber cobble road, 4 tiles wide (cols 18-21), rows 2-22.
# ' ' = no tile (transparent overlay), 'P' = path tile.
# Each row exactly 40 chars: ' '×18 + 'P'×4 + ' '×18 = 40.
const PATH_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
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
