class_name VerdantForestMap
extends RefCounted

## Tilemap data constants for Verdant Forest.
## All legends and map arrays live here so verdant_forest.gd stays concise.

# ---------- TILE LEGENDS ----------

# Ground layer — organic multi-terrain patches (A5_A, source 0)
# G = bright green vegetation (dominant ~50%), open clearings
# g = muted green variant (row 9), adds variety without seam artifacts
# D = dirt/earth (20%), flanking paths, around tree trunk bases
# E = dark earth/roots (15%), under dense forest canopy, transition zones
const GROUND_LEGEND: Dictionary = {
	"G": Vector2i(0, 8),
	"g": Vector2i(0, 9),
	"D": Vector2i(0, 2),
	"E": Vector2i(0, 6),
}

# Path layer — single dirt path tile (A5_A row 4, source 0)
const PATH_LEGEND: Dictionary = {
	"P": Vector2i(0, 4),
}

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

# Ground: organic multi-terrain patches
# G = bright green vegetation, D = dirt/earth, E = dark earth/roots
# North/south forest edges = E, clearings = G, paths/dirt zones = D
const GROUND_MAP: Array[String] = [
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEGGEEEEEEEEGGGGGGGEEEGGEEEEEEEEE",
	"EEEEEEEGGGDGGGEEEGGGGGDGGGGGGGGGGEEEEEEE",
	"EEEEEEDGGGGGGGGDGGGGGGGGGGGDGGGGGDEEEEEE",
	"EEEEEGGGgGGGGGGGDDDDDDGGGGGGGGGgGGGGEEEE",
	"EEEEGGGGGGGGgGGGDDDDDDGGGGgGGGGGGGGGEEEE",
	"EEEEGDGGGGGGGGGGGDDDDDDGGGGGGGGGgDGGEEEE",
	"EEEEEGGDGGGEEEGDDDDDDGGGEEEEDGGGgGEEEEEE",
	"GDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDG",
	"GDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDG",
	"EEEEEGGDGGGEEEGGGGGGGGGGGGEEDGGGgGEEEEEE",
	"EEEEEEEGGGEEEEEGGEEEEGGEEEEEGGGEEEEEEEEE",
	"EEEEEEEEEDDEEEEEEEEEEEEEEEEEEDDEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEGGGGGGGGGGGGGGGGEEEEEEEEEEEE",
	"EEEEEEEEEEGGGgGGDDDDDDDDGGGGgGEEEEEEEEEE",
	"EEEEEEEEEGGGgGGDDDDDDDDGGGgGGEEEEEEEEEEE",
	"EEEEEEEEGGGgGGDDDDDDDDDDGGGgGGEEEEEEEEEE",
	"EEEEEEEEGGGGgGGGGGGgGGGGGgGGGGEEEEEEEEEE",
	"EEEEEEEEEEGGGGgGGGGgGGGGGEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
	"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
]

# Dense forest borders with organic clearing and chokepoint exits
# Rows 0-2:  solid forest wall (north border)
# Rows 3-4:  forest thins — scattered gaps appear
# Rows 5-8:  clearing for Iris zone — open interior, tree edges
# Row 9:     scattered tree clusters below clearing
# Rows 10-11: main east-west corridor (fully open, passage to edges)
# Row 12:    scattered tree clusters above south forest
# Rows 13-14: forest returns, dense transition
# Rows 15-24: solid forest wall (south border)
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
# 4 variants (A-D) for visual variety. Collision blocks player.
# Vertical alignment: trunk row Y sits below canopy rows Y-2, Y-1.
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

# Tree canopies on AbovePlayer — 4 types (FOREST_OBJECTS, source 1)
# Each 2x2 canopy sits 1-2 rows above its trunk position.
# Player walks under these for depth effect.
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

# Ground detail — scattered rocks, flowers, leaves (STONE_OBJECTS, source 2)
# ~72 tiles for ~23% coverage in open areas — dense in clearings, sparse near edges
const DETAIL_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                    l  r     l          ",
	"        F   r     l  f   R  l F         ",
	"       f R  l F   r  f  p l   o r       ",
	"      l f R  p l      F r  f l o R      ",
	"     r F  l s f         L r F  p l      ",
	"        f R l o        s F  l r f       ",
	"      r   l           F pl     r f      ",
	"                                        ",
	"                                        ",
	"      l   F    r f  p l Ro     f s      ",
	"        r      l      f      R          ",
	"         l                              ",
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
