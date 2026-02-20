class_name OvergrownCapitalMap
extends RefCounted

## Tilemap data constants for Overgrown Capital dungeon.
## All legends and map arrays live here so overgrown_capital.gd stays concise.
## Visual design by tilemap-builder agent — hand-crafted district layout.

# Source 0: FAIRY_FOREST_A5_A (opaque ground tiles — mandatory for all scenes)
# Source 1: RUINS_A5 (ruins2 — golden walls and ornate floors)
# Source 2: OVERGROWN_RUINS_OBJECTS (B-sheet — objects, rubble, vines)

# Ground layer — gray stone throughout (fairy forest source 0)
# F = gray stone floor (dominant), D = dark earth/roots, V = vegetation
const GROUND_LEGEND: Dictionary = {
	"F": Vector2i(0, 10),  # Gray stone floor (opaque, cross-scene consistent)
	"D": Vector2i(0, 6),   # Dark earth/roots — district border texture
	"V": Vector2i(0, 8),   # Dense vegetation — nature reclaiming the capital
}

# Ground detail — ornate golden floor accents (ruins2 source 1)
const DETAIL_LEGEND: Dictionary = {
	"O": Vector2i(0, 2),   # Ornate golden floor tile (market stalls, key areas)
}

# Ground debris — small rubble at ground level (B-sheet source 2)
const DEBRIS_LEGEND: Dictionary = {
	"p": Vector2i(0, 2),   # Small pebbles / reddish rubble fragments
	"r": Vector2i(1, 2),   # Scattered rocks
	"v": Vector2i(0, 6),   # Green round vegetation clump
	"m": Vector2i(1, 6),   # Green round vegetation variant
}

# Wall layer — structural walls (ruins2 source 1)
const WALL_LEGEND: Dictionary = {
	"W": Vector2i(0, 4),   # Golden wall (opaque)
	"G": Vector2i(0, 8),   # Dark ornamental border
}

# Objects layer — B-sheet ruins objects (source 2)
const OBJECTS_LEGEND: Dictionary = {
	"a": Vector2i(2, 0),   # Carved stone block
	"b": Vector2i(0, 4),   # Green bush
	"d": Vector2i(0, 0),   # Stone rubble
	"e": Vector2i(1, 4),   # Green bush variant
	"f": Vector2i(3, 0),   # Small rubble piece
	"g": Vector2i(2, 4),   # Vine growth
	"h": Vector2i(3, 4),   # Moss patch
	"i": Vector2i(5, 0),   # Crumbled pillar
}

# Above-player layer — vine overhangs and arch canopy (B-sheet source 2)
const ABOVE_LEGEND: Dictionary = {
	"v": Vector2i(0, 6),   # Round vine canopy piece (left)
	"w": Vector2i(1, 6),   # Round vine canopy piece (right)
	"b": Vector2i(0, 4),   # Bush overhang
	"c": Vector2i(1, 4),   # Bush overhang variant
}

# --------------------------------------------------------------------------
# Map arrays — 28 rows x 40 cols each (640x448 px)
# '.' = empty cell (no tile placed on that layer)
#
# District layout:
#   Row  0-5:  Palace District approach — narrow corridor, dense walls
#   Row  6-12: Research Quarter (west cols 2-22) + Entertainment (east)
#   Row 13-18: Residential Quarter (west cols 2-19) + Entertainment (east)
#   Row 19-27: Market District — broad stone streets, entry zone
# --------------------------------------------------------------------------

# Ground layer — fully tiled with organic terrain patches.
# F=gray stone (corridors, open), D=dark earth (borders), V=vegetation (reclaimed)
const GROUND_MAP: Array[String] = [
	"FFFFFFDDDDDDDDDFFFFFFFFFFFFFFFFFDDDDFFFF",
	"FFFFDDDVVDDDDDDFFFFFFFFFFFFFFFFFFDDVVFFF",
	"FFFFDDDVVVDDDDFFFFFFFFFFFFFFFFFDDDVVVFFF",
	"FFFFDDDVVVFFFFFFFFFFFFFFFFFFFFFFFDDVVDFF",
	"FFFFFDDDDDDDDDFFFFFFFFFFFFFFFFFDDDDDDFFF",
	"FFFFFDDDDDDDDFFFFFFFFFFFFFFFFFDDDDDDDFFF",
	"FFDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFDDDVVFFFFFFFFFFFFFFFFFFFFFFFDDFFDDDFFF",
	"FFDDVVVFFFFFFFFFFFFFFFFFFFFFFFDDFFDDDFFF",
	"FFDDDVVFFFFFFFFFFFFFFFFFFFFFFFDDFFDDDFFF",
	"FFDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDDDFF",
	"FFDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFDDDFFFF",
	"FFDDDVVDDDFFFFFFFFFFFFFFFFFFFFFFFDDDDFFF",
	"FFDDDVVVDDFFFFFFFFFFFFFFFFFFFFFFFDDDDFFF",
	"FFDDVVVVDDFFFFFFFFFFFFFFFFFFFFFFFDDDDFFF",
	"FFDDDVVDDDFFFFFFFFFFFFFFFFFFFFFFFDDDDFFF",
	"FFDDDDDDDDFFFFFFFFFFFFFFFFFFFFFFFDDDDFFF",
	"FFDDDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
]

# Detail layer — ornate golden floor accents.
# 'O' in Market stall areas, Entertainment theater floor, Research lab.
const DETAIL_MAP: Array[String] = [
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	".....OOO....OOO.........................",
	".....OO......OO.........................",
	"........................................",
	"........................OOO.....OO......",
	"........................OO......OOO.....",
	"........................OOO.....OOO.....",
	"........................OOOO....OOO.....",
	"........................OO......OO......",
	"........................OOO.....OOO.....",
	"........................OO......OO......",
	"........................OOO.....OOO.....",
	"........................................",
	"...OOO......OOO.......OOO......OOO......",
	"...OO........OO.......OO........OO......",
	"...OOO......OOO.......OOO......OOO......",
	"........................................",
	"...OO.......OOO........OOO......OO......",
	"...OOO.......OO........OO......OOO......",
	"........................................",
	"...OOO......OOO.......OOO......OOO......",
	"........................................",
]

# Debris layer — ground-level rubble. Sparse (20-80 total).
# Placed intentionally near walls, corners, and transitions.
const DEBRIS_MAP: Array[String] = [
	"........................................",
	".....r.........p........................",
	".....p..............................r...",
	"........................................",
	"..........p.................r...........",
	"........................................",
	"...r......m.................p.......r...",
	"........................................",
	"....v.........p...................r.....",
	"........................................",
	"...p..................................r.",
	"........................................",
	"...r.......v............................",
	"....p...................................",
	".....v.........r........................",
	"........................................",
	"....r.p.................................",
	"........................................",
	"........................................",
	"....p.......r...........m.......r.......",
	"........................................",
	"..r..........p...........r..............",
	"........................................",
	"........................................",
	"....r........m..................p.......",
	"........................................",
	"..p..........r...........p..............",
	"........................................",
]

# Wall layer — structural walls forming dungeon boundaries.
# 'W'=golden wall (solid), 'G'=dark ornamental border (solid), '.'=navigable
const WALL_MAP: Array[String] = [
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
	"WW....WWWWWWWWG............GWWWWWWWW..WW",
	"WW....WWWWWWWWG............GWWWWWWWW..WW",
	"WW....WWWWWWWW..............WWWWWWWW..WW",
	"WW....WWWWWWWWG............GWWWWWWWW..WW",
	"WW....GWWWWWWWGG..........GGWWWWWWWG..WW",
	"WW............................WWWWWW..WW",
	"WW.............................WWWWW..WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WW....................................WW",
	"WWWWWWWWWWWWWWWWWWWW..WWWWWWWWWWWWWWWWWW",
]

# Objects layer — props, rubble, vines from B-sheet (source 2).
const OBJECTS_MAP: Array[String] = [
	"........................................",
	"........................................",
	"....b...............g..............e....",
	"........................................",
	"....g...............h..............b....",
	"........................................",
	"...d...........a........................",
	"........f...............................",
	"....b.........e................d........",
	"........................................",
	"...g..............................f.....",
	".......i................................",
	"........................................",
	"....e.......b...........................",
	"........................................",
	"........................................",
	"...b.........g..........................",
	"........f...............................",
	"........................................",
	"........................................",
	"........................................",
	".....d...........f.............a........",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	".....f..........d...............f.......",
	"........................................",
]

# Above-player layer — vine overhangs creating depth (B-sheet source 2).
# Sparse placement over palace corridors and district transitions.
const ABOVE_PLAYER_MAP: Array[String] = [
	"........................................",
	"........................................",
	"...vw............................vw.....",
	"........................................",
	"...bc............................bc.....",
	"........................................",
	"........................................",
	"........................................",
	"...vw...................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"...bc...................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
	"........................................",
]
