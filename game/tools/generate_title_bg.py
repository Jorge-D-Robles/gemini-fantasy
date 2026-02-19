from PIL import Image, ImageDraw, ImageFilter
import random
import math

def generate_title_bg(width=640, height=360, filename="game/ui/title_screen/title_bg.png"):
    img = Image.new("RGB", (width, height), "black")
    draw = ImageDraw.Draw(img)

    # 1. Sky Gradient (Deep Twilight Purple to Dark Blue)
    top_color = (20, 10, 40) # Deep dark purple
    bottom_color = (60, 30, 90) # Lighter purple twilight
    
    for y in range(height):
        # Linear interpolation
        t = y / height
        r = int(top_color[0] * (1 - t) + bottom_color[0] * t)
        g = int(top_color[1] * (1 - t) + bottom_color[1] * t)
        b = int(top_color[2] * (1 - t) + bottom_color[2] * t)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    # 2. Distant Stars / Echo Fragments
    for _ in range(200):
        x = random.randint(0, width)
        y = random.randint(0, int(height * 0.7))
        brightness = random.randint(100, 255)
        # Cyan tint for "Echo Fragments"
        color = (brightness, 255, 255) if random.random() > 0.7 else (brightness, brightness, brightness)
        img.putpixel((x, y), color)

    # 3. Resonance Nexus (Center Background)
    center_x = width // 2
    beam_width = 30
    nexus_color = (100, 200, 255)
    
    # Draw a vertical beam that fades out
    for i in range(beam_width):
        alpha = int(255 * (1 - abs(i - beam_width/2) / (beam_width/2)))
        # Simple line drawing
        x = center_x - beam_width // 2 + i
        # Draw from bottom up to mid-sky
        draw.line([(x, height), (x, height // 4)], fill=nexus_color)

    # 4. Floating Islands (Mid-ground)
    island_colors = [(50, 40, 60), (40, 30, 50)]
    
    for _ in range(6):
        ix = random.randint(20, width - 20)
        iy = random.randint(height // 3, height // 2 + 50)
        isize = random.randint(20, 50)
        
        # Draw rough shape
        points = []
        num_points = 8
        for i in range(num_points):
            angle = i * (math.pi * 2) / num_points
            r = isize * (0.7 + random.random() * 0.6)
            px = ix + math.cos(angle) * r
            py = iy + math.sin(angle) * r * 0.5 # Flattened
            points.append((px, py))
        
        draw.polygon(points, fill=random.choice(island_colors))

    # 5. Foreground Cliff (Silhouette)
    cliff_color = (15, 10, 25) # Very dark purple/black
    cliff_points = []
    
    # Start bottom left
    cliff_points.append((0, height))
    
    # Generate jagged top edge across bottom 1/3 of screen
    current_x = 0
    current_y = height - 100 # Start height
    
    while current_x < width:
        # Steps
        step_x = random.randint(20, 60)
        step_y = random.randint(-20, 20)
        
        current_x += step_x
        current_y += step_y
        
        # Clamp y
        if current_y < height // 2 + 50: current_y = height // 2 + 50
        if current_y > height: current_y = height
        
        cliff_points.append((current_x, current_y))
    
    # Finish polygon
    cliff_points.append((width, height)) # Bottom right
    cliff_points.append((0, height)) # Bottom left
    
    draw.polygon(cliff_points, fill=cliff_color)

    # 6. Resonance Crystals (Glowing Cyan) embedded in cliff
    crystal_color = (0, 255, 255)
    
    # Attempt to place crystals roughly along the cliff edge
    # We can iterate through the points we generated or just scatter randomly in bottom area
    for _ in range(12):
        cx = random.randint(0, width)
        cy = random.randint(height - 120, height - 10)
        
        # Check if cy is roughly "below" the horizon line at that x?
        # Simplified: Just draw if in lower area.
        if cy > height - 100:
             size = random.randint(3, 8)
             # Draw diamond
             points = [
                 (cx, cy - size),
                 (cx + size, cy),
                 (cx, cy + size),
                 (cx - size, cy)
             ]
             draw.polygon(points, fill=crystal_color)

    img.save(filename)
    print(f"Generated title background at {filename}")

if __name__ == "__main__":
    generate_title_bg()
