class_name ScorchedRoadMap
extends RefCounted

## Tilemap data constants for The Scorched Road route scene.
## Ancient highway between Emberhearth and southern steppes. Volcanic ash
## and cracked earth dominate with gray stone outcrops and rare amber clay.
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
const ROWS: int = 24

# ---------- PROCEDURAL GROUND CONFIG ----------

const GROUND_NOISE_SEED: int = 77701
const GROUND_NOISE_FREQ: float = 0.06
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
# Dark earth dominant (ash-covered highway), gray stone in patches,
# amber clay rare (heated exposed clay).
const OPEN_BIOME_THRESHOLDS: Array[Dictionary] = [
	{"threshold": 0.35,  "biome": Biome.AMBER_EARTH},
	{"threshold": -0.25, "biome": Biome.DARK_EARTH},
	{"threshold": -1.0,  "biome": Biome.GRAY_STONE},
]

const VARIANT_HASH_SEED: int = 77702

# -- Paths: sandy/tan variants from TF_TERRAIN row 9 --
const PATH_TILES: Array[Vector2i] = [
	Vector2i(1, 9), Vector2i(2, 9),
	Vector2i(3, 9), Vector2i(4, 9),
]
const PATH_HASH_SEED: int = 77703

# -- Detail scatter: ashlands rocks (source 1 = ASHLANDS_OBJECTS) --
const DETAIL_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 0), "source_id": 1, "density": 0.05},
	{"atlas": Vector2i(1, 0), "source_id": 1, "density": 0.04},
	{"atlas": Vector2i(2, 0), "source_id": 1, "density": 0.03},
]

# ---------- BORDER: ashlands rocks along east/west edges ----------
const BORDER_VARIANT_LEGEND: Dictionary = {
	"R": [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
	],
}
const BORDER_HASH_SEED: int = 77704

# ---------- SOLID TILES ----------
const SOLID_TILES: Dictionary = {
	1: [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
	],
}

# ---------- MAP DATA (40 cols x 24 rows) ----------

# Path map: cracked highway running north-south.
# North entry (cols 18-21) from Emberhearth, south exit.
const PATH_MAP: Array[String] = [
	"                                        ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                   PPPP                 ",
	"                   PPPP                 ",
	"                  PPPP                  ",
	"                 PPPP                   ",
	"                 PPPP                   ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                   PPPP                 ",
	"                   PPPP                 ",
	"                  PPPP                  ",
	"                 PPPP                   ",
	"                 PPPP                   ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                  PPPP                  ",
	"                                        ",
]

# Border map — ashlands rocks along east/west edges.
# 'R' = rock variant (fill_layer_with_variants picks from 6 variants).
const BORDER_MAP: Array[String] = [
	"RRR                                  RRR",
	"RR                                    RR",
	"R                                      R",
	"                                        ",
	"                                        ",
	"R                                      R",
	"                                        ",
	"                                        ",
	"                                        ",
	"R                                      R",
	"RR                                    RR",
	"R                                      R",
	"                                        ",
	"                                        ",
	"R                                      R",
	"                                        ",
	"                                        ",
	"                                        ",
	"R                                      R",
	"                                        ",
	"                                        ",
	"R                                      R",
	"RR                                    RR",
	"RRR                                  RRR",
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
