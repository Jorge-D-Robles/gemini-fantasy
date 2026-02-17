# Godot 4.5 Asset Import Best Practices

## Sprite Import Settings
For all pixel art assets, ensure the following settings in the Import tab:

1.  **Texture Filter**: `Nearest` (essential to prevent blurring).
2.  **Compression**: `Lossless` (prevents artifacts).
3.  **Mipmaps**: `Off`.
4.  **Repeat**: `Disabled`.

## Node Configuration
- **AnimatedSprite2D**: Use for all characters and animated objects. Set `texture_filter` to `Inherit` (which should be `Nearest` at the project level).
- **TileMapLayer**: Set the `TileSet` resource to use `Nearest` filter for its Atlas Sources.

## Directory Structure
- Characters: `game/assets/sprites/characters/`
- Enemies: `game/assets/sprites/enemies/`
- Icons: `game/assets/sprites/items/` or `game/assets/ui/icons/`
- Tilesets: `game/assets/tilesets/`
