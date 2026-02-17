#!/usr/bin/env python3
"""Generate all pixel art sprite assets for Gemini Fantasy."""

import os
import random
from PIL import Image, ImageDraw

BASE = os.path.dirname(os.path.abspath(__file__))


def mkdir(path):
    os.makedirs(os.path.join(BASE, os.path.dirname(path)), exist_ok=True)


def save(img, rel_path):
    full = os.path.join(BASE, rel_path)
    mkdir(rel_path)
    img.save(full)
    print(f"  Created: {rel_path}")


# ---------------------------------------------------------------------------
# Color palettes
# ---------------------------------------------------------------------------
GRASS_GREENS = [
    (34, 139, 34), (46, 150, 46), (40, 145, 40), (50, 160, 50),
]
DARK_GRASS = (20, 100, 20)
DIRT_BROWN = (139, 119, 80)
DIRT_LIGHT = (160, 140, 100)
WATER_BLUE = (40, 80, 200)
WATER_LIGHT = (70, 120, 220)
TREE_GREEN_DARK = (20, 80, 20)
TREE_GREEN = (30, 110, 30)
TREE_GREEN_LIGHT = (50, 140, 50)
COBBLE_GREY = (130, 130, 130)
COBBLE_DARK = (100, 100, 100)
STONE_TAN = (180, 165, 140)
STONE_CRACK = (150, 135, 110)
MOSS_GREEN = (80, 140, 80)
TRUNK_BROWN = (100, 70, 40)
TRUNK_DARK = (80, 55, 30)
BUSH_GREEN = (40, 120, 40)
CLIFF_GREY = (80, 80, 90)
BRIDGE_BROWN = (140, 100, 50)
DOOR_BROWN = (120, 80, 40)
WALL_GREY = (110, 110, 120)
VINE_GREEN = (50, 130, 50)

# Character colors
SKIN = (255, 220, 177)
SKIN_SHADOW = (230, 190, 150)
HAIR_BROWN = (100, 65, 30)
TUNIC_BLUE = (50, 100, 180)
TUNIC_BLUE_SHADOW = (35, 75, 140)
PANTS_BROWN = (100, 80, 50)
PANTS_SHADOW = (80, 60, 35)
SHOE_DARK = (60, 45, 25)
EYE_COLOR = (30, 30, 50)

NPC1_TUNIC = (50, 140, 60)
NPC1_TUNIC_SHADOW = (35, 110, 45)
NPC1_HAIR = (170, 170, 170)

NPC2_TUNIC = (160, 70, 40)
NPC2_TUNIC_SHADOW = (130, 55, 30)
NPC2_HAIR = (60, 40, 20)

# Building colors
WOOD_BROWN = (130, 90, 50)
WOOD_DARK = (100, 65, 35)
WOOD_LIGHT = (160, 120, 70)
ROOF_BROWN = (90, 55, 30)
ROOF_DARK = (70, 40, 20)
WINDOW_YELLOW = (240, 210, 80)
WINDOW_FRAME = (80, 55, 30)
DOOR_COLOR = (100, 65, 35)


# ===========================================================================
# TILE ATLAS (128x128, 8x8 grid of 16x16 tiles)
# ===========================================================================
def generate_tile_atlas():
    img = Image.new("RGBA", (128, 128), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    def fill_tile(col, row, color):
        x0, y0 = col * 16, row * 16
        draw.rectangle([x0, y0, x0 + 15, y0 + 15], fill=color)

    def put(x, y, color):
        if 0 <= x < 128 and 0 <= y < 128:
            img.putpixel((x, y), color)

    # --- Row 0: Grass, Dirt, Water, Dark Grass ---
    random.seed(42)

    # 4 grass tiles with slight variation
    for i in range(4):
        x0, y0 = i * 16, 0
        base = GRASS_GREENS[i]
        fill_tile(i, 0, base)
        # Add pixel detail
        for _ in range(12):
            px = x0 + random.randint(0, 15)
            py = y0 + random.randint(0, 15)
            shade = tuple(max(0, min(255, c + random.randint(-20, 20))) for c in base)
            put(px, py, shade + (255,))

    # 2 dirt path tiles
    for i in range(2):
        x0, y0 = (4 + i) * 16, 0
        fill_tile(4 + i, 0, DIRT_BROWN)
        for _ in range(10):
            px = x0 + random.randint(0, 15)
            py = y0 + random.randint(0, 15)
            put(px, py, DIRT_LIGHT + (255,))

    # Water tile
    fill_tile(6, 0, WATER_BLUE)
    x0 = 6 * 16
    for _ in range(8):
        px = x0 + random.randint(0, 15)
        py = random.randint(0, 15)
        put(px, py, WATER_LIGHT + (255,))

    # Dark grass
    fill_tile(7, 0, DARK_GRASS)
    x0 = 7 * 16
    for _ in range(8):
        px = x0 + random.randint(0, 15)
        py = random.randint(0, 15)
        shade = (25, 110, 25, 255)
        put(px, py, shade)

    # --- Row 1: Tree canopy (4 tiles), cobble, flower, stone wall, vine wall ---
    # Tree canopy top-left
    fill_tile(0, 1, TREE_GREEN_DARK)
    for yy in range(16, 32):
        for xx in range(0, 16):
            if (xx + yy) % 5 == 0:
                put(xx, yy, TREE_GREEN_LIGHT + (255,))
            elif (xx * yy) % 7 == 0:
                put(xx, yy, TREE_GREEN + (255,))

    # Tree canopy top-right
    fill_tile(1, 1, TREE_GREEN_DARK)
    for yy in range(16, 32):
        for xx in range(16, 32):
            if (xx + yy) % 5 == 0:
                put(xx, yy, TREE_GREEN_LIGHT + (255,))
            elif (xx * yy) % 7 == 0:
                put(xx, yy, TREE_GREEN + (255,))

    # Tree canopy bottom-left
    fill_tile(2, 1, TREE_GREEN)
    for yy in range(16, 32):
        for xx in range(32, 48):
            if (xx + yy) % 4 == 0:
                put(xx, yy, TREE_GREEN_DARK + (255,))

    # Tree canopy bottom-right
    fill_tile(3, 1, TREE_GREEN)
    for yy in range(16, 32):
        for xx in range(48, 64):
            if (xx + yy) % 4 == 0:
                put(xx, yy, TREE_GREEN_DARK + (255,))

    # Cobblestone
    x0, y0 = 4 * 16, 1 * 16
    fill_tile(4, 1, COBBLE_GREY)
    # Draw stone pattern
    for sy in range(0, 16, 4):
        for sx in range(0, 16, 5):
            offset = 2 if (sy // 4) % 2 == 1 else 0
            rx = x0 + (sx + offset) % 16
            ry = y0 + sy
            put(rx, ry, COBBLE_DARK + (255,))
            put(rx + 1, ry, COBBLE_DARK + (255,))

    # Flower patch (grass with flower dots)
    fill_tile(5, 1, GRASS_GREENS[0])
    x0, y0 = 5 * 16, 1 * 16
    flowers = [(255, 50, 50), (255, 255, 50), (200, 50, 255), (255, 150, 200)]
    for _ in range(6):
        fx = x0 + random.randint(1, 14)
        fy = y0 + random.randint(1, 14)
        put(fx, fy, random.choice(flowers) + (255,))

    # Stone wall
    x0, y0 = 6 * 16, 1 * 16
    fill_tile(6, 1, WALL_GREY)
    for sy in range(0, 16, 5):
        for sx in range(0, 16):
            put(x0 + sx, y0 + sy, (80, 80, 90, 255))
    for sx in range(0, 16, 6):
        offset = 3 if (sx // 6) % 2 == 0 else 0
        for sy in range(0, 16):
            put(x0 + sx, y0 + (sy + offset) % 16, (80, 80, 90, 255))

    # Vine wall
    x0, y0 = 7 * 16, 1 * 16
    fill_tile(7, 1, WALL_GREY)
    # Add vines
    for vy in range(0, 16, 2):
        vx = 3 + (vy % 4)
        put(x0 + vx, y0 + vy, VINE_GREEN + (255,))
        put(x0 + vx + 8, y0 + vy, VINE_GREEN + (255,))
        if vy % 4 == 0:
            put(x0 + vx + 1, y0 + vy, VINE_GREEN + (255,))

    # --- Row 2: stone floor, cracked stone, moss stone, tree trunk,
    #            bush, cliff edge, bridge plank, door ---
    # Stone floor
    fill_tile(0, 2, STONE_TAN)
    # Cracked stone
    fill_tile(1, 2, STONE_TAN)
    x0, y0 = 1 * 16, 2 * 16
    # Draw cracks
    for i in range(3, 12):
        put(x0 + i, y0 + i, STONE_CRACK + (255,))
        put(x0 + i + 1, y0 + i, STONE_CRACK + (255,))
    for i in range(5, 10):
        put(x0 + i, y0 + 14 - i, STONE_CRACK + (255,))

    # Moss stone
    fill_tile(2, 2, STONE_TAN)
    x0, y0 = 2 * 16, 2 * 16
    for _ in range(15):
        mx = x0 + random.randint(0, 15)
        my = y0 + random.randint(0, 15)
        put(mx, my, MOSS_GREEN + (255,))

    # Tree trunk
    x0, y0 = 3 * 16, 2 * 16
    fill_tile(3, 2, GRASS_GREENS[0])
    for ty in range(0, 16):
        for tx in range(5, 11):
            c = TRUNK_BROWN if tx < 8 else TRUNK_DARK
            put(x0 + tx, y0 + ty, c + (255,))

    # Bush
    x0, y0 = 4 * 16, 2 * 16
    fill_tile(4, 2, GRASS_GREENS[0])
    for by in range(4, 14):
        for bx in range(3, 13):
            dist = abs(bx - 8) + abs(by - 9)
            if dist < 7:
                c = BUSH_GREEN if (bx + by) % 3 != 0 else TREE_GREEN_LIGHT
                put(x0 + bx, y0 + by, c + (255,))

    # Cliff edge
    x0, y0 = 5 * 16, 2 * 16
    for cy in range(0, 16):
        for cx in range(0, 16):
            if cy < 6:
                put(x0 + cx, y0 + cy, CLIFF_GREY + (255,))
            elif cy < 8:
                shade = (60, 60, 70, 255) if cx % 3 == 0 else CLIFF_GREY + (255,)
                put(x0 + cx, y0 + cy, shade)
            else:
                put(x0 + cx, y0 + cy, (50, 50, 60, 255))

    # Bridge plank
    x0, y0 = 6 * 16, 2 * 16
    fill_tile(6, 2, BRIDGE_BROWN)
    for bx in range(0, 16):
        for by in [0, 5, 10, 15]:
            put(x0 + bx, y0 + by, TRUNK_DARK + (255,))
    # Horizontal grain
    for by in range(0, 16, 3):
        for bx in range(0, 16):
            if random.random() < 0.3:
                put(x0 + bx, y0 + by, TRUNK_DARK + (255,))

    # Door tile
    x0, y0 = 7 * 16, 2 * 16
    fill_tile(7, 2, DOOR_BROWN)
    # Door frame
    for dy in range(0, 16):
        put(x0, y0 + dy, TRUNK_DARK + (255,))
        put(x0 + 15, y0 + dy, TRUNK_DARK + (255,))
    for dx in range(0, 16):
        put(x0 + dx, y0, TRUNK_DARK + (255,))
    # Doorknob
    put(x0 + 12, y0 + 9, WINDOW_YELLOW + (255,))
    put(x0 + 12, y0 + 10, WINDOW_YELLOW + (255,))

    # --- Rows 3-7: Fill with useful variations ---
    # Row 3: more grass/terrain
    for i in range(8):
        fill_tile(i, 3, GRASS_GREENS[i % 4])
        x0 = i * 16
        y0 = 3 * 16
        for _ in range(8):
            px = x0 + random.randint(0, 15)
            py = y0 + random.randint(0, 15)
            shade = tuple(max(0, min(255, c + random.randint(-15, 15)))
                          for c in GRASS_GREENS[i % 4])
            put(px, py, shade + (255,))

    # Row 4: sand/desert variations
    sand_base = (210, 190, 140)
    for i in range(8):
        fill_tile(i, 4, sand_base)
        x0 = i * 16
        y0 = 4 * 16
        for _ in range(10):
            px = x0 + random.randint(0, 15)
            py = y0 + random.randint(0, 15)
            shade = tuple(max(0, min(255, c + random.randint(-15, 15)))
                          for c in sand_base)
            put(px, py, shade + (255,))

    # Row 5: snow/ice variations
    snow_base = (230, 235, 245)
    for i in range(8):
        fill_tile(i, 5, snow_base)
        x0 = i * 16
        y0 = 5 * 16
        for _ in range(8):
            px = x0 + random.randint(0, 15)
            py = y0 + random.randint(0, 15)
            shade = tuple(max(0, min(255, c + random.randint(-10, 10)))
                          for c in snow_base)
            put(px, py, shade + (255,))

    # Row 6: dark dungeon floor
    dungeon_base = (60, 55, 65)
    for i in range(8):
        fill_tile(i, 6, dungeon_base)
        x0 = i * 16
        y0 = 6 * 16
        for _ in range(6):
            px = x0 + random.randint(0, 15)
            py = y0 + random.randint(0, 15)
            shade = tuple(max(0, min(255, c + random.randint(-10, 10)))
                          for c in dungeon_base)
            put(px, py, shade + (255,))

    # Row 7: lava/cave
    lava_base = (180, 50, 20)
    cave_base = (50, 45, 55)
    for i in range(4):
        fill_tile(i, 7, lava_base)
        x0 = i * 16
        y0 = 7 * 16
        for _ in range(8):
            px = x0 + random.randint(0, 15)
            py = y0 + random.randint(0, 15)
            put(px, py, (220, 100, 30, 255))
    for i in range(4, 8):
        fill_tile(i, 7, cave_base)
        x0 = i * 16
        y0 = 7 * 16
        for _ in range(6):
            px = x0 + random.randint(0, 15)
            py = y0 + random.randint(0, 15)
            put(px, py, (65, 60, 70, 255))

    save(img, "game/assets/tilesets/overworld_tiles.png")


# ===========================================================================
# CHARACTER SPRITE HELPER
# ===========================================================================
def draw_character_frame(img, fx, fy, direction, frame,
                         tunic, tunic_shadow, hair_color,
                         pants=PANTS_BROWN, pants_shadow=PANTS_SHADOW):
    """Draw a 16x16 character frame at (fx, fy) offset.

    direction: 0=down, 1=left, 2=right, 3=up
    frame: 0=walk1, 1=idle, 2=walk2
    """
    def put(x, y, color):
        px, py = fx + x, fy + y
        if 0 <= px < img.width and 0 <= py < img.height:
            img.putpixel((px, py), color + (255,))

    # Head position: centered around x=7,8 (2px wide head area)
    # Head: rows 1-5, body: rows 6-11, legs: rows 12-14, feet: row 15

    # --- HAIR (top of head) ---
    if direction == 3:  # UP - show back of hair
        for hx in range(5, 11):
            put(hx, 1, hair_color)
        for hx in range(4, 12):
            put(hx, 2, hair_color)
        for hx in range(4, 12):
            put(hx, 3, hair_color)
        # Back of head still hair
        for hx in range(5, 11):
            put(hx, 4, hair_color)
        for hx in range(5, 11):
            put(hx, 5, hair_color)
    else:
        # Hair top
        for hx in range(5, 11):
            put(hx, 1, hair_color)
        for hx in range(4, 12):
            put(hx, 2, hair_color)

        # Face area (rows 3-5)
        if direction == 0:  # DOWN - face visible
            for hx in range(4, 12):
                put(hx, 3, SKIN)
            for hx in range(4, 12):
                put(hx, 4, SKIN)
            for hx in range(5, 11):
                put(hx, 5, SKIN)
            # Eyes
            put(5, 4, EYE_COLOR)
            put(6, 4, EYE_COLOR)
            put(9, 4, EYE_COLOR)
            put(10, 4, EYE_COLOR)
        elif direction == 1:  # LEFT
            for hx in range(4, 12):
                put(hx, 3, SKIN)
            for hx in range(4, 12):
                put(hx, 4, SKIN)
            for hx in range(5, 11):
                put(hx, 5, SKIN)
            # Left-facing eye
            put(5, 4, EYE_COLOR)
            put(6, 4, EYE_COLOR)
            # Hair on right side
            put(11, 3, hair_color)
            put(11, 4, hair_color)
        elif direction == 2:  # RIGHT
            for hx in range(4, 12):
                put(hx, 3, SKIN)
            for hx in range(4, 12):
                put(hx, 4, SKIN)
            for hx in range(5, 11):
                put(hx, 5, SKIN)
            # Right-facing eye
            put(9, 4, EYE_COLOR)
            put(10, 4, EYE_COLOR)
            # Hair on left side
            put(4, 3, hair_color)
            put(4, 4, hair_color)

    # --- BODY / TUNIC (rows 6-11) ---
    for by in range(6, 12):
        width_start = 5
        width_end = 11
        if by == 6:
            width_start = 5
            width_end = 11
        elif by >= 10:
            width_start = 6
            width_end = 10

        for bx in range(width_start, width_end):
            if bx < (width_start + width_end) // 2:
                put(bx, by, tunic)
            else:
                put(bx, by, tunic_shadow)

        # Arms on sides
        if 7 <= by <= 10:
            if direction == 1:  # LEFT - arm on right side
                put(width_end, by, tunic)
            elif direction == 2:  # RIGHT - arm on left side
                put(width_start - 1, by, tunic)
            else:
                put(width_start - 1, by, tunic)
                put(width_end, by, tunic_shadow)

    # --- LEGS (rows 12-14) ---
    leg_left_x = 6
    leg_right_x = 9

    if frame == 0:  # walk1 - left leg forward
        for ly in range(12, 15):
            put(leg_left_x, ly, pants)
            put(leg_left_x + 1, ly, pants_shadow)
            if ly == 12:
                put(leg_right_x, ly, pants)
                put(leg_right_x + 1, ly, pants_shadow)
            else:
                put(leg_right_x + 1, ly, pants)
                put(leg_right_x + 2, ly, pants_shadow)
        # Feet
        put(leg_left_x, 15, SHOE_DARK)
        put(leg_left_x + 1, 15, SHOE_DARK)
        put(leg_right_x + 1, 15, SHOE_DARK)
        put(leg_right_x + 2, 15, SHOE_DARK)
    elif frame == 1:  # idle - legs together
        for ly in range(12, 15):
            put(leg_left_x, ly, pants)
            put(leg_left_x + 1, ly, pants_shadow)
            put(leg_right_x, ly, pants)
            put(leg_right_x + 1, ly, pants_shadow)
        # Feet
        put(leg_left_x, 15, SHOE_DARK)
        put(leg_left_x + 1, 15, SHOE_DARK)
        put(leg_right_x, 15, SHOE_DARK)
        put(leg_right_x + 1, 15, SHOE_DARK)
    elif frame == 2:  # walk2 - right leg forward
        for ly in range(12, 15):
            put(leg_right_x, ly, pants)
            put(leg_right_x + 1, ly, pants_shadow)
            if ly == 12:
                put(leg_left_x, ly, pants)
                put(leg_left_x + 1, ly, pants_shadow)
            else:
                put(leg_left_x - 1, ly, pants)
                put(leg_left_x, ly, pants_shadow)
        # Feet
        put(leg_right_x, 15, SHOE_DARK)
        put(leg_right_x + 1, 15, SHOE_DARK)
        put(leg_left_x - 1, 15, SHOE_DARK)
        put(leg_left_x, 15, SHOE_DARK)


def generate_character_sheet(rel_path, tunic, tunic_shadow, hair_color,
                             pants=PANTS_BROWN, pants_shadow=PANTS_SHADOW):
    """Generate a 48x64 character sprite sheet (3 cols x 4 rows of 16x16)."""
    img = Image.new("RGBA", (48, 64), (0, 0, 0, 0))

    for row, direction in enumerate([0, 1, 2, 3]):  # down, left, right, up
        for col, frame in enumerate([0, 1, 2]):  # walk1, idle, walk2
            fx = col * 16
            fy = row * 16
            draw_character_frame(
                img, fx, fy, direction, frame,
                tunic, tunic_shadow, hair_color, pants, pants_shadow,
            )

    save(img, rel_path)


# ===========================================================================
# BUILDING SPRITES
# ===========================================================================
def generate_lodge():
    """160x96 brown wooden inn with peaked roof, windows, door."""
    img = Image.new("RGBA", (160, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Main building body
    draw.rectangle([20, 35, 139, 89], fill=WOOD_BROWN)
    # Wood panel lines
    for y in range(35, 90, 6):
        draw.line([(20, y), (139, y)], fill=WOOD_DARK)

    # Peaked roof
    # Draw triangle roof
    for y in range(0, 36):
        x_start = 80 - int((36 - y) * 2.2)
        x_end = 80 + int((36 - y) * 2.2)
        x_start = max(0, x_start)
        x_end = min(159, x_end)
        for x in range(x_start, x_end + 1):
            c = ROOF_BROWN if (x + y) % 4 != 0 else ROOF_DARK
            img.putpixel((x, y), c + (255,))

    # Roof edge
    draw.line([(2, 35), (157, 35)], fill=ROOF_DARK)

    # Windows (2 on each side)
    for wx in [35, 60, 100, 125]:
        draw.rectangle([wx, 50, wx + 12, 62], fill=WINDOW_FRAME)
        draw.rectangle([wx + 2, 52, wx + 10, 60], fill=WINDOW_YELLOW)
        # Window cross
        draw.line([(wx + 6, 52), (wx + 6, 60)], fill=WINDOW_FRAME)
        draw.line([(wx + 2, 56), (wx + 10, 56)], fill=WINDOW_FRAME)

    # Door (centered)
    draw.rectangle([72, 60, 88, 89], fill=DOOR_COLOR)
    draw.rectangle([73, 61, 87, 88], fill=(110, 75, 40))
    # Door handle
    img.putpixel((85, 76), WINDOW_YELLOW + (255,))
    img.putpixel((85, 77), WINDOW_YELLOW + (255,))

    # Chimney
    draw.rectangle([125, 5, 135, 35], fill=COBBLE_GREY)
    for sy in range(5, 35, 4):
        draw.line([(125, sy), (135, sy)], fill=COBBLE_DARK)

    # Foundation
    draw.rectangle([18, 90, 141, 95], fill=COBBLE_GREY)

    save(img, "game/assets/sprites/buildings/lodge_clean.png")


def generate_hut():
    """128x112 smaller wooden hut with rounded roof."""
    img = Image.new("RGBA", (128, 112), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Main body
    draw.rectangle([20, 50, 107, 105], fill=WOOD_BROWN)
    for y in range(50, 106, 5):
        draw.line([(20, y), (107, y)], fill=WOOD_DARK)

    # Rounded roof (arch shape)
    cx, cy = 64, 50
    for y in range(15, 51):
        dy = y - cy
        half_width = int(((1 - (dy / 35.0) ** 2) ** 0.5) * 55) if abs(dy / 35.0) <= 1 else 0
        if half_width > 0:
            for x in range(cx - half_width, cx + half_width + 1):
                if 0 <= x < 128 and 0 <= y < 112:
                    c = ROOF_BROWN if (x + y) % 3 != 0 else ROOF_DARK
                    img.putpixel((x, y), c + (255,))

    # Window
    draw.rectangle([35, 65, 52, 80], fill=WINDOW_FRAME)
    draw.rectangle([37, 67, 50, 78], fill=WINDOW_YELLOW)
    draw.line([(43, 67), (43, 78)], fill=WINDOW_FRAME)

    # Another window
    draw.rectangle([75, 65, 92, 80], fill=WINDOW_FRAME)
    draw.rectangle([77, 67, 90, 78], fill=WINDOW_YELLOW)
    draw.line([(83, 67), (83, 78)], fill=WINDOW_FRAME)

    # Door
    draw.rectangle([53, 75, 73, 105], fill=DOOR_COLOR)
    draw.rectangle([55, 77, 71, 104], fill=(110, 75, 40))
    img.putpixel((69, 91), WINDOW_YELLOW + (255,))
    img.putpixel((69, 92), WINDOW_YELLOW + (255,))

    # Foundation
    draw.rectangle([18, 106, 109, 111], fill=COBBLE_GREY)

    save(img, "game/assets/sprites/buildings/hut.png")


def generate_tree_small():
    """24x32 small bush/sapling on transparent bg."""
    img = Image.new("RGBA", (24, 32), (0, 0, 0, 0))

    def put(x, y, c):
        if 0 <= x < 24 and 0 <= y < 32:
            img.putpixel((x, y), c + (255,))

    # Trunk
    for y in range(20, 30):
        put(11, y, TRUNK_BROWN)
        put(12, y, TRUNK_BROWN)
        put(13, y, TRUNK_DARK)

    # Canopy (round blob)
    random.seed(100)
    for y in range(4, 22):
        for x in range(2, 22):
            dx = x - 12
            dy = y - 12
            if dx * dx + dy * dy < 64:
                c = BUSH_GREEN if (x + y) % 3 != 0 else TREE_GREEN_LIGHT
                put(x, y, c)

    save(img, "game/assets/sprites/buildings/tree_small.png")


def generate_tree_medium():
    """32x48 medium leafy tree."""
    img = Image.new("RGBA", (32, 48), (0, 0, 0, 0))

    def put(x, y, c):
        if 0 <= x < 32 and 0 <= y < 48:
            img.putpixel((x, y), c + (255,))

    # Trunk
    for y in range(30, 46):
        for x in range(14, 19):
            c = TRUNK_BROWN if x < 17 else TRUNK_DARK
            put(x, y, c)

    # Ground base
    for x in range(12, 21):
        put(x, 46, TRUNK_DARK)
        put(x, 47, TRUNK_DARK)

    # Canopy (larger circle)
    for y in range(2, 32):
        for x in range(1, 31):
            dx = x - 16
            dy = y - 16
            if dx * dx + dy * dy < 170:
                if (x + y) % 4 == 0:
                    c = TREE_GREEN_LIGHT
                elif (x * y) % 5 == 0:
                    c = TREE_GREEN_DARK
                else:
                    c = TREE_GREEN
                put(x, y, c)

    save(img, "game/assets/sprites/buildings/tree_medium.png")


def generate_tree_tall():
    """32x72 tall tree with visible trunk."""
    img = Image.new("RGBA", (32, 72), (0, 0, 0, 0))

    def put(x, y, c):
        if 0 <= x < 32 and 0 <= y < 72:
            img.putpixel((x, y), c + (255,))

    # Trunk (tall)
    for y in range(35, 70):
        for x in range(14, 19):
            c = TRUNK_BROWN if x < 17 else TRUNK_DARK
            put(x, y, c)

    # Root base
    for x in range(12, 21):
        put(x, 70, TRUNK_DARK)
        put(x, 71, TRUNK_DARK)
    put(11, 70, TRUNK_DARK)
    put(21, 70, TRUNK_DARK)

    # Canopy (tall oval shape — like a pine)
    for y in range(2, 38):
        radius = 14 - abs(y - 18) * 0.6
        if radius < 3:
            radius = 3
        for x in range(0, 32):
            dx = x - 16
            if abs(dx) < radius:
                if (x + y) % 4 == 0:
                    c = TREE_GREEN_DARK
                elif (x + y) % 3 == 0:
                    c = TREE_GREEN_LIGHT
                else:
                    c = TREE_GREEN
                put(x, y, c)

    save(img, "game/assets/sprites/buildings/tree_tall.png")


def generate_signpost():
    """16x24 wooden signpost."""
    img = Image.new("RGBA", (16, 24), (0, 0, 0, 0))

    def put(x, y, c):
        if 0 <= x < 16 and 0 <= y < 24:
            img.putpixel((x, y), c + (255,))

    # Post
    for y in range(8, 23):
        put(7, y, TRUNK_BROWN)
        put(8, y, TRUNK_BROWN)

    # Base
    put(6, 23, TRUNK_DARK)
    put(7, 23, TRUNK_DARK)
    put(8, 23, TRUNK_DARK)
    put(9, 23, TRUNK_DARK)

    # Sign plank
    for y in range(3, 10):
        for x in range(2, 14):
            c = WOOD_LIGHT if y < 7 else WOOD_BROWN
            put(x, y, c)

    # Sign border
    for x in range(2, 14):
        put(x, 3, WOOD_DARK)
        put(x, 9, WOOD_DARK)
    for y in range(3, 10):
        put(2, y, WOOD_DARK)
        put(13, y, WOOD_DARK)

    save(img, "game/assets/sprites/buildings/signpost.png")


# ===========================================================================
# MAIN
# ===========================================================================
def main():
    print("Generating pixel art assets for Gemini Fantasy...")
    print()

    print("[Tile Atlas]")
    generate_tile_atlas()
    print()

    print("[Player Sprite - Kael]")
    generate_character_sheet(
        "game/assets/sprites/characters/kael_overworld.png",
        TUNIC_BLUE, TUNIC_BLUE_SHADOW, HAIR_BROWN,
    )
    print()

    print("[NPC 1 - Elder/Innkeeper]")
    generate_character_sheet(
        "game/assets/sprites/characters/npc_char1.png",
        NPC1_TUNIC, NPC1_TUNIC_SHADOW, NPC1_HAIR,
    )
    print()

    print("[NPC 2 - Scout/Shopkeeper]")
    generate_character_sheet(
        "game/assets/sprites/characters/npc_char2.png",
        NPC2_TUNIC, NPC2_TUNIC_SHADOW, NPC2_HAIR,
    )
    print()

    print("[Buildings]")
    generate_lodge()
    generate_hut()
    generate_tree_small()
    generate_tree_medium()
    generate_tree_tall()
    generate_signpost()
    print()

    print("All assets generated successfully!")


if __name__ == "__main__":
    main()
