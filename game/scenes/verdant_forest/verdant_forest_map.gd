class_name VerdantForestMap
extends RefCounted

## Tilemap data constants for Verdant Forest.
## All legends and map arrays live here so verdant_forest.gd stays concise.
##
## Ground uses TimeFantasy_TILES/TILESETS/terrain.png (flat 16×16 grid).
## Each biome maps to a row in terrain.png with multiple column variants.
## Variants are picked by position hash for organic, non-repeating coverage.

# Biome zones — noise threshold → biome, position hash → column variant.
# terrain.png flat-tile rows (avoid cols 22+ which are RPGMaker auto-tiles):
#   Row 1: bright green grass     (cols 2-11)
#   Row 2: muted/shaded green     (cols 1-11)
#   Row 6: warm brown earth/dirt  (cols 1-8)
enum Biome { BRIGHT_GREEN, MUTED_GREEN, DIRT }

# Map dimensions
const COLS: int = 40
const ROWS: int = 25

# ---------- PROCEDURAL GROUND CONFIG ----------

# Ground noise — organic terrain patches (source 0 = TF_TERRAIN).
const GROUND_NOISE_SEED: int = 77777
const GROUND_NOISE_FREQ: float = 0.06
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
# Dirt threshold tightened from -0.15 to -0.25 so dirt patches stay at map edges.
const OPEN_BIOME_THRESHOLDS: Array[Dictionary] = [
	{"threshold": 0.15,  "biome": Biome.BRIGHT_GREEN},
	{"threshold": -0.25, "biome": Biome.MUTED_GREEN},
	{"threshold": -1.0,  "biome": Biome.DIRT},
]

# Position hash seed — mixed with (x, y) to pick column variant within a biome.
const VARIANT_HASH_SEED: int = 31415

# Detail scatter — rocks, flowers, leaves (source 2 = STONE_OBJECTS).
# Sparse: ~8% total coverage, biome-constrained to grass cells only.
const DETAIL_NOISE_SEED: int = 77778
const DETAIL_NOISE_FREQ: float = 0.22
const DETAIL_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 0), "source_id": 2, "density": 0.02},
	{"atlas": Vector2i(1, 0), "source_id": 2, "density": 0.015},
	{"atlas": Vector2i(0, 1), "source_id": 2, "density": 0.015},
	{"atlas": Vector2i(2, 1), "source_id": 2, "density": 0.01},
	{"atlas": Vector2i(0, 2), "source_id": 2, "density": 0.01},
	{"atlas": Vector2i(1, 2), "source_id": 2, "density": 0.01},
]

# ---------- TILE LEGENDS ----------

# Path layer — sandy/tan dirt path tiles from terrain.png row 9 (source 0)
# Single-legend entry used by build_layer(); variant selection in _fill_paths.
const PATH_LEGEND: Dictionary = {
	"P": Vector2i(2, 9),
}

# 4 sandy/tan variants for position-hashed path variety.
const PATH_TILES: Array[Vector2i] = [
	Vector2i(1, 9), Vector2i(2, 9),
	Vector2i(3, 9), Vector2i(4, 9),
]
const PATH_HASH_SEED: int = 77779

# Dense forest fill — canopy center for impenetrable borders
# (FOREST_OBJECTS, source 1)
const TREE_LEGEND: Dictionary = {
	"T": Vector2i(1, 1),
}

# Individual tree trunks — 4 variants (FOREST_OBJECTS, source 1)
# Placed in clearings and transition zones for distinct silhouettes
const TRUNK_LEGEND: Dictionary = {
	"A": Vector2i(8, 7),   # Tree type A — trunk base
	"B": Vector2i(10, 7),  # Tree type B — trunk base variant
	"C": Vector2i(8, 5),   # Tree type C — trunk mid-segment
	"D": Vector2i(10, 5),  # Tree type D — trunk mid-segment variant
}

# Tree canopies — 8 types x 4 tiles each (FOREST_OBJECTS, source 1)
# Rows 0-1: Types A-D (darker, rounder canopies)
# Rows 2-3: Types E-H (lighter, rounder canopy variants)
# Each 2x2 canopy sits 2 rows above its trunk on AbovePlayer layer.
const CANOPY_LEGEND: Dictionary = {
	# Type A canopy (2x2) — round dark-edged crown
	"1": Vector2i(0, 0),   # top-left
	"2": Vector2i(1, 0),   # top-right
	"3": Vector2i(0, 1),   # bottom-left
	"4": Vector2i(1, 1),   # bottom-right
	# Type B canopy (2x2) — broad crown variant
	"5": Vector2i(2, 0),
	"6": Vector2i(3, 0),
	"7": Vector2i(2, 1),
	"8": Vector2i(3, 1),
	# Type C canopy (2x2) — wide spread crown
	"a": Vector2i(4, 0),
	"b": Vector2i(5, 0),
	"c": Vector2i(4, 1),
	"d": Vector2i(5, 1),
	# Type D canopy (2x2) — dense leaf cluster
	"e": Vector2i(6, 0),
	"f": Vector2i(7, 0),
	"g": Vector2i(6, 1),
	"h": Vector2i(7, 1),
	# Type E canopy (2x2) — lighter round crown (rows 2-3)
	"i": Vector2i(0, 2),
	"j": Vector2i(1, 2),
	"k": Vector2i(0, 3),
	"l": Vector2i(1, 3),
	# Type F canopy (2x2) — lighter broad crown
	"m": Vector2i(2, 2),
	"n": Vector2i(3, 2),
	"o": Vector2i(2, 3),
	"p": Vector2i(3, 3),
	# Type G canopy (2x2) — lighter spread crown
	"q": Vector2i(4, 2),
	"r": Vector2i(5, 2),
	"s": Vector2i(4, 3),
	"t": Vector2i(5, 3),
	# Type H canopy (2x2) — lighter dense cluster
	"u": Vector2i(6, 2),
	"v": Vector2i(7, 2),
	"w": Vector2i(6, 3),
	"x": Vector2i(7, 3),
}

# Ground detail — rocks, flowers, leaves (STONE_OBJECTS, source 2)
const DETAIL_LEGEND: Dictionary = {
	"r": Vector2i(0, 0),   # Small rock
	"R": Vector2i(1, 0),   # Rock variant
	"s": Vector2i(2, 0),   # Pebble cluster
	"f": Vector2i(0, 1),   # Orange flower
	"F": Vector2i(2, 1),   # Flower variant
	"l": Vector2i(0, 2),   # Green leaf
	"L": Vector2i(1, 2),   # Green leaf variant
	"p": Vector2i(3, 0),   # Pebble variant
	"o": Vector2i(1, 1),   # Flower cluster
}

# ---------- MAP DATA (40 cols x 25 rows) ----------
# Ground is procedural — see noise configs and BIOME_TILES above.

# Dense forest borders with organic clearing and chokepoint exits
const TREE_MAP: Array[String] = [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTT  TT  TTTT       TTT  TTTTTTTTT",
	"TTTTTTT        TT                TTTTTTT",
	"TTTTT                              TTTTT",
	"TTTTT                               TTTT",
	"TTTT                                TTTT",
	"TTTT                                TTTT",
	"TTTTT       TT            TT       TTTTT",
	"                                        ",
	"                                        ",
	"TTTTT       TT            TT       TTTTT",
	"TTTTTTT   TTTTT  TTTT  TTTTT   TTTTTTTTT",
	"TTTTTTTTT  TTTTTTTTTTTTTTTTTT  TTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTT  TTTTTTTTTTTTTTT  TTTTTTTTTTTT",
	"TTTTTTT   TTTTT  TTTT  TTTTT   TTTTTTTTT",
	"TTTTTT       TT            TT       TTTT",
	"TTTT                                TTTT",
	"TTTTT                              TTTTT",
	"TTTTT       TT            TT       TTTTT",
	"TTTTTTT        TT                TTTTTTT",
	"TTTTTTTTT  TT  TTTT       TTT  TTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]

# Individual tree trunks at clearing edges (FOREST_OBJECTS, source 1)
const TRUNK_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"  A    B    C    D    A    B    C    D  ",
	"    B         D              A     C    ",
	"           A           C                ",
	"      A         B           D     C     ",
	"                                        ",
	"                      A                 ",
	"      B                           D     ",
	"        B                    C          ",
	"                                        ",
	"                                        ",
	"        B                    D          ",
	"                                        ",
	"          A                   C         ",
	"                                        ",
	"                                        ",
	"   B       C    D       A        B      ",
	"     D   A          B         C         ",
	"            A         D         B       ",
	"              C           A             ",
	"        D          B                    ",
	"          A              C              ",
	"    D           B          A       C    ",
	"                                        ",
]

# Tree canopies on AbovePlayer — placed 1-2 rows above trunk (FOREST_OBJECTS, source 1)
const CANOPY_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"          12          ab                ",
	"     12   34   56     cd   ef    ab     ",
	"     34        78          gh    cd     ",
	"                     12                 ",
	"     56              34          ef     ",
	"     7856                   ab   gh     ",
	"       78                   cd          ",
	"                                        ",
	"       56                   ef          ",
	"       78                   gh          ",
	"         12                  ab         ",
	"         34                  cd         ",
	"                                        ",
	"  56      ab   ef      12       56      ",
	"  78ef  12cd   gh  56  34    ab 78      ",
	"    gh  34 12      78ef      cd  56     ",
	"           34ab      gh  12      78     ",
	"       ef    cd   56     34             ",
	"       gh12       78    ab              ",
	"   ef    34    56       cd12      ab    ",
	"   gh          78         34      cd    ",
	"                                        ",
	"                                        ",
]

# Dirt path — branches from corridor up to Iris clearing
const PATH_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                  PP                    ",
	"                  PPP                   ",
	"                 PPPP                   ",
	"                PPPPP                   ",
	" PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP ",
	" PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP ",
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
