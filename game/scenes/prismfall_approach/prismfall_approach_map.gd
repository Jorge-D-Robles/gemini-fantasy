class_name PrismfallApproachMap
extends RefCounted

## Tilemap data constants for the Prismfall Approach (Crystalline Steppes).
## All legends and map arrays live here so prismfall_approach.gd stays concise.
## Map: 40 cols x 24 rows (640 x 384 px).
## Theme: open rocky steppes leading south toward Prismfall canyon.

# Map dimensions
const COLS: int = 40
const ROWS: int = 24

# ---------- PROCEDURAL GROUND CONFIG ----------

# Ground noise — rocky steppe terrain (source 0)
# A = amber earth (noise > 0.3, rare outcrops), S = gray stone (dominant),
# D = dark cliff (catch-all — biases to dark at map edges via noise)
const GROUND_NOISE_SEED: int = 99887
const GROUND_NOISE_FREQ: float = 0.05
const GROUND_NOISE_OCTAVES: int = 3
const GROUND_ENTRIES: Array[Dictionary] = [
	{"threshold": 0.3,  "atlas": Vector2i(0, 2), "foliage": false},  # A = amber earth (rare)
	{"threshold": -0.4, "atlas": Vector2i(0, 10), "foliage": false}, # S = gray stone (dominant)
	{"threshold": -1.0, "atlas": Vector2i(0, 6), "foliage": false},  # D = dark cliff (catch-all)
]

# Detail scatter — scattered rocks flanking the path (source 1)
const DETAIL_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 0), "source_id": 1, "density": 0.06},  # small rock
	{"atlas": Vector2i(1, 0), "source_id": 1, "density": 0.05},  # rock variant
	{"atlas": Vector2i(2, 0), "source_id": 1, "density": 0.04},  # pebble cluster
]

# Foliage noise — no foliage on barren steppes (defined for API consistency)
const FOLIAGE_NOISE_SEED: int = 88888
const FOLIAGE_NOISE_FREQ: float = 0.15
const FOLIAGE_THRESHOLD: float = 1.0  # threshold=1.0 means nothing fires

# ---------- TILE LEGENDS (FAIRY_FOREST_A5_A, source 0) ----------

# Path — amber cobble road running north-south (row 4).
const PATH_LEGEND: Dictionary = {
	"P": Vector2i(0, 4),
}

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

# Detail is now procedural — see DETAIL_ENTRIES above.
