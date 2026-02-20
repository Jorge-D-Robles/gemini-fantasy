class_name OvergrownCapitalMap
extends RefCounted

## Tilemap data constants for Overgrown Capital dungeon.
## All legends and map arrays live here so overgrown_capital.gd stays concise.
## Visual design is intentionally sparse in this skeleton — the tilemap-builder
## agent iterates on DETAIL_MAP, WALL_MAP, DEBRIS_MAP, and OBJECTS_MAP separately.

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
	"p": Vector2i(0, 2),   # Small pebbles
	"r": Vector2i(1, 2),   # Scattered rocks
	"v": Vector2i(0, 6),   # Vine fragment
	"m": Vector2i(1, 6),   # Moss clump
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
	"g": Vector2i(2, 4),   # Vine growth
	"h": Vector2i(3, 4),   # Moss patch
}

# --------------------------------------------------------------------------
# Map arrays — 28 rows x 40 cols each (640x448 px)
# '.' = empty cell (no tile placed on that layer)
# Visual design by tilemap-builder agent; skeleton uses minimal placeholder.
# --------------------------------------------------------------------------

# Ground layer — fully tiled with gray stone skeleton floor.
# District boundaries and terrain variety will be layered in by tilemap-builder.
const GROUND_MAP: Array[String] = [
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
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

# Detail layer — ornate floor accents. Sparse skeleton; tilemap-builder fills in.
const DETAIL_MAP: Array[String] = [
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

# Debris layer — ground-level rubble. Tilemap-builder fills in.
const DEBRIS_MAP: Array[String] = [
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

# Wall layer — structural walls. Tilemap-builder fills in district walls.
const WALL_MAP: Array[String] = [
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

# Objects layer — props, rubble, vines. Tilemap-builder fills in.
const OBJECTS_MAP: Array[String] = [
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
