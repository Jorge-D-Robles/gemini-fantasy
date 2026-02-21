class_name PrismfallApproachMap
extends RefCounted

## Tilemap data constants for the Prismfall Approach (Crystalline Steppes).
## All legends and map arrays live here so prismfall_approach.gd stays concise.
## Map: 40 cols x 24 rows (640 x 384 px).
## Theme: open rocky steppes leading south toward Prismfall canyon.

# ---------- TILE LEGENDS (FAIRY_FOREST_A5_A, source 0) ----------

# Ground — rocky steppe terrain.
# S = gray stone (dominant steppe, row 10), A = amber earth (path edges, row 2),
# D = dark cliff (border, row 6)
const GROUND_LEGEND: Dictionary = {
	"S": Vector2i(0, 10),
	"A": Vector2i(0, 2),
	"D": Vector2i(0, 6),
}

# Path — amber cobble road running north-south (row 4).
const PATH_LEGEND: Dictionary = {
	"P": Vector2i(0, 4),
}

# Ground detail — scattered rocks (STONE_OBJECTS, source 1).
const DETAIL_LEGEND: Dictionary = {
	"r": Vector2i(0, 0),
	"R": Vector2i(1, 0),
	"c": Vector2i(2, 0),
	"B": Vector2i(3, 0),
}

# ---------- MAP DATA (40 cols x 24 rows) ----------

# Ground: rocky steppe terrain.
# Each row is exactly 40 chars.
# Rows 0-1: dark cliff (north boundary)
# Rows 2-22: open steppes — stone with amber near path center (cols 18-21)
# Row 23: dark cliff (south boundary)
#
# CLIFF  = "D"×40
# ROCKY  = "D"×2 + "S"×36 + "D"×2 = 40
# AMBER  = "D"×2 + "S"×16 + "A"×4 + "S"×16 + "D"×2 = 40
const GROUND_MAP: Array[String] = [
	"DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
	"DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSAAAASSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSAAAASSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSAAAASSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSAAAASSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSAAAASSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSAAAASSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSAAAASSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSAAAASSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDD",
	"DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
]

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

# Detail: scattered rocks on the sides (STONE_OBJECTS, source 1).
# ~20% coverage, flanking the path — left (cols 3-13) and right (cols 27-37).
# Each row exactly 40 chars. Rows 0-1 and 23 are empty.
const DETAIL_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"   r               R     r           R  ",
	"                                        ",
	"       r       R            r     R     ",
	"                                        ",
	"   r               R     r           R  ",
	"                                        ",
	"       r       R            r     R     ",
	"                                        ",
	"   r               R     r           R  ",
	"                                        ",
	"       r       R            r     R     ",
	"                                        ",
	"   r               R     r           R  ",
	"                                        ",
	"       r       R            r     R     ",
	"                                        ",
	"   r               R     r           R  ",
	"                                        ",
	"       r       R            r     R     ",
	"                                        ",
	"   r               R     r           R  ",
	"                                        ",
]
