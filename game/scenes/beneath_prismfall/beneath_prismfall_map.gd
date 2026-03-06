class_name BeneathPrismfallMap
extends RefCounted

## Tilemap data constants for Beneath Prismfall dungeon.
## Crystal Canyon descent — narrow carved passages through
## glowing crystal formations leading to the Warden's chamber.
##
## Source 0: TF_DUNGEON — floor (brown earth row 1) + walls (blue-gray)
## Source 1: RUINS1_OBJECTS — crystal pillars, statues, arches
## Source 2: STONE_OBJECTS — rocks, flowers, pebbles (detail)

# Map dimensions
const COLS: int = 40
const ROWS: int = 28

# ---------- PROCEDURAL GROUND CONFIG ----------

# Floor tiles — brown earth from TF_DUNGEON row 1, cols 2-5
const FLOOR_TILES: Array[Vector2i] = [
	Vector2i(2, 1), Vector2i(3, 1),
	Vector2i(4, 1), Vector2i(5, 1),
]
const FLOOR_HASH_SEED: int = 88801

# Wall tiles — blue-gray stone from TF_DUNGEON row 1, cols 6-8
const WALL_TILES: Array[Vector2i] = [
	Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1),
]
const WALL_HASH_SEED: int = 88807
const WALL_BORDER_TILE: Vector2i = Vector2i(6, 1)

# Detail scatter — rocks from STONE_OBJECTS (source 2)
const DETAIL_ENTRIES: Array[Dictionary] = [
	{"atlas": Vector2i(0, 0), "source_id": 2, "threshold": 0.35},
	{"atlas": Vector2i(1, 0), "source_id": 2, "threshold": 0.40},
]

# Crystal pillar objects (source 1 = RUINS1_OBJECTS)
const OBJECTS_LEGEND: Dictionary = {
	# Pillar pieces
	"P": Vector2i(0, 2),   # pillar base left
	"Q": Vector2i(1, 2),   # pillar base right
	"p": Vector2i(0, 1),   # pillar mid left
	"q": Vector2i(1, 1),   # pillar mid right
	# Statue elements
	"S": Vector2i(2, 2),   # statue base
	"s": Vector2i(2, 1),   # statue top
	# Wall blocks
	"W": Vector2i(8, 5),   # wall dark
	"w": Vector2i(9, 5),   # wall light
	"X": Vector2i(8, 6),   # wall bottom dark
	"x": Vector2i(9, 6),   # wall bottom light
	# Fountain / crystal formation
	"F": Vector2i(4, 2),   # fountain base (crystal pool)
}

# Above-player layer — pillar tops, arch tops (source 1)
const ABOVE_LEGEND: Dictionary = {
	"T": Vector2i(0, 0),   # pillar top left
	"U": Vector2i(1, 0),   # pillar top right
	"A": Vector2i(4, 3),   # arch top left
	"a": Vector2i(5, 3),   # arch top mid
	"D": Vector2i(6, 3),   # arch top right
}

# Solid tiles for collision (source_id -> Array[Vector2i])
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

# Ground map: W = wall (impassable), . = floor (walkable)
# Canyon layout: narrow entry from north, widening to gallery,
# narrowing to deep section, opening to Warden chamber.
const GROUND_MAP: Array[String] = [
#    0         1         2         3
#    0123456789012345678901234567890123456789
	"WWWWWWWWWWWWWWWWW......WWWWWWWWWWWWWWWWW",  # 0  entry
	"WWWWWWWWWWWWWWWW........WWWWWWWWWWWWWWWW",  # 1
	"WWWWWWWWWWWWWWW..........WWWWWWWWWWWWWWW",  # 2
	"WWWWWWWWWWWWWW............WWWWWWWWWWWWWW",  # 3
	"WWWWWWWWWWWWW..............WWWWWWWWWWWWW",  # 4
	"WWWWWWWWWWWW................WWWWWWWWWWWW",  # 5  widening
	"WWWWWWWWWWW..................WWWWWWWWWWW",  # 6
	"WWWWWWWWWW....................WWWWWWWWWW",  # 7
	"WWWWWWWWW......................WWWWWWWWW",  # 8  gallery
	"WWWWWWWW........................WWWWWWWW",  # 9
	"WWWWWWW..........................WWWWWWW",  # 10
	"WWWWWWW..........................WWWWWWW",  # 11
	"WWWWWWW..........................WWWWWWW",  # 12
	"WWWWWWWW........................WWWWWWWW",  # 13
	"WWWWWWWWW......................WWWWWWWWW",  # 14 narrowing
	"WWWWWWWWWW....................WWWWWWWWWW",  # 15
	"WWWWWWWWWWW..................WWWWWWWWWWW",  # 16
	"WWWWWWWWWWWW......WWWW......WWWWWWWWWWWW",  # 17 chokepoint
	"WWWWWWWWWWWWW.....WWWW.....WWWWWWWWWWWWW",  # 18
	"WWWWWWWWWWWW................WWWWWWWWWWWW",  # 19 opens to arena
	"WWWWWWWWWW....................WWWWWWWWWW",  # 20
	"WWWWWWWW........................WWWWWWWW",  # 21 warden chamber
	"WWWWWWW..........................WWWWWWW",  # 22
	"WWWWWWW..........................WWWWWWW",  # 23
	"WWWWWWW..........................WWWWWWW",  # 24
	"WWWWWWWW........................WWWWWWWW",  # 25
	"WWWWWWWWWW....................WWWWWWWWWW",  # 26
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",  # 27 sealed
]

# Objects layer: crystal pillars, statues, wall blocks
const OBJECTS_MAP: Array[String] = [
	"                                        ",  # 0
	"                                        ",  # 1
	"                                        ",  # 2
	"                                        ",  # 3
	"                                        ",  # 4
	"            PQ            PQ            ",  # 5
	"            pq            pq            ",  # 6
	"                                        ",  # 7
	"                  F                     ",  # 8
	"        PQ                    PQ        ",  # 9
	"        pq        S          pq         ",  # 10
	"                  s                     ",  # 11
	"                                        ",  # 12
	"        PQ                    PQ        ",  # 13
	"                                        ",  # 14
	"                                        ",  # 15
	"                                        ",  # 16
	"            WwWw    WwWw                ",  # 17
	"            XxXx    XxXx                ",  # 18
	"                                        ",  # 19
	"                                        ",  # 20
	"                  F                     ",  # 21
	"        S                    S          ",  # 22
	"        s                    s          ",  # 23
	"                                        ",  # 24
	"                                        ",  # 25
	"                                        ",  # 26
	"                                        ",  # 27
]

# Above-player layer: pillar tops
const ABOVE_MAP: Array[String] = [
	"                                        ",  # 0
	"                                        ",  # 1
	"                                        ",  # 2
	"                                        ",  # 3
	"                                        ",  # 4
	"            TU            TU            ",  # 5
	"                                        ",  # 6
	"                                        ",  # 7
	"                                        ",  # 8
	"        TU                    TU        ",  # 9
	"                                        ",  # 10
	"                                        ",  # 11
	"                                        ",  # 12
	"        TU                    TU        ",  # 13
	"                                        ",  # 14
	"                                        ",  # 15
	"                                        ",  # 16
	"                                        ",  # 17
	"                                        ",  # 18
	"                                        ",  # 19
	"                                        ",  # 20
	"                                        ",  # 21
	"                                        ",  # 22
	"                                        ",  # 23
	"                                        ",  # 24
	"                                        ",  # 25
	"                                        ",  # 26
	"                                        ",  # 27
]

# Detail/decoration map: sparse rocks
const DECOR_MAP: Array[String] = [
	"                                        ",  # 0
	"                                        ",  # 1
	"                                        ",  # 2
	"                                        ",  # 3
	"                                        ",  # 4
	"                                        ",  # 5
	"                                        ",  # 6
	"                                        ",  # 7
	"                                        ",  # 8
	"                                        ",  # 9
	"                                        ",  # 10
	"                                        ",  # 11
	"                                        ",  # 12
	"                                        ",  # 13
	"                                        ",  # 14
	"                                        ",  # 15
	"                                        ",  # 16
	"                                        ",  # 17
	"                                        ",  # 18
	"                                        ",  # 19
	"                                        ",  # 20
	"                                        ",  # 21
	"                                        ",  # 22
	"                                        ",  # 23
	"                                        ",  # 24
	"                                        ",  # 25
	"                                        ",  # 26
	"                                        ",  # 27
]


# ---------- STATIC HELPERS ----------


## Pick a floor tile variant using position hash.
static func pick_floor_tile(x: int, y: int) -> Vector2i:
	var idx: int = (
		abs(x * 73 + y * 31 + FLOOR_HASH_SEED) % FLOOR_TILES.size()
	)
	return FLOOR_TILES[idx]


## Pick a wall tile variant using position hash.
static func pick_wall_tile(x: int, y: int) -> Vector2i:
	var idx: int = (
		abs(x * 73 + y * 31 + WALL_HASH_SEED) % WALL_TILES.size()
	)
	return WALL_TILES[idx]
