---
name: nano-banana-pro
description: Generate professional "Time Fantasy" style game assets using the Nano Banana Pro reasoning image engine. Use when you need new sprites, tiles, or icons that match the JRPG aesthetic of Gemini Fantasy, following Godot 4.5 best practices.
---

# Nano Banana Pro: Asset Generation

This skill enables the generation of game assets that match the professional, SNES-era pixel art style of "Time Fantasy." It uses a "reasoning image engine" workflow to ensure high-quality, consistent output.

## Workflow

1.  **Requirement Analysis**: Define the asset type (Character, Enemy, Tile, UI, FX).
2.  **Style Reference**: Consult [STYLE_GUIDE.md](references/STYLE_GUIDE.md) for palette and dimension requirements.
3.  **Scene Planning**: Determine grid size (16x16 base) and animation frames (e.g., 3x4 walk sheet).
4.  **Generation Selection**:
    - **Prompt Generation**: Generate a professional prompt for the Nano Banana Pro AI engine.
    - **Procedural Fallback**: If a quick placeholder is needed, generate a Python/PIL script to create the asset.
5.  **Import Configuration**: Specify Godot 4.5 import settings (Nearest filter, Lossless compression).

## Asset Specification

- **Characters**: 16x24 to 32x32 sprites. 3 columns x 4 rows for walk cycles.
- **Enemies**: 48x48 (Medium) to 128x128 (Boss).
- **Tiles**: 16x16 base. A5 for terrain, B for objects.
- **UI/Icons**: 32x32 or 64x64.

## Usage Example

"Generate a new character 'Iris' in Time Fantasy style."

1. Analyze Iris's design (Tall, dark skin, cybernetic arm).
2. Generate the [NANO BANANA PRO PROMPT] block.
3. Provide the file destination: `game/assets/sprites/characters/iris_overworld.png`.
4. Provide Godot import steps.

## Reference Material

- **Style Guide**: See [STYLE_GUIDE.md](references/STYLE_GUIDE.md) for detailed palette and grid rules.
- **Godot Integration**: See [GODOT_IMPORT.md](references/GODOT_IMPORT.md) for import settings.
