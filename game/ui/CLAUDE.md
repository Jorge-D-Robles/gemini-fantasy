# UI Asset & Style Reference

Styling conventions and asset usage for all UI scenes.
Consult this before modifying UI to maintain visual consistency.

## Color Palette

The game uses a deep purple/indigo palette with lavender text and gold accents:

| Role | Color | Usage |
|------|-------|-------|
| Background | `(0.05, 0.03, 0.1)` deep indigo | Title screen, panel backgrounds |
| Panel fill | `(0.12, 0.07, 0.22, 0.85)` dark purple | Button normal state, menu panels |
| Panel hover | `(0.18, 0.12, 0.32, 0.9)` lighter purple | Button hover/focus state |
| Panel pressed | `(0.06, 0.03, 0.12, 0.95)` very dark | Button pressed state |
| Text primary | `(0.85, 0.75, 1.0)` lavender | Titles, active text |
| Text secondary | `(0.6, 0.55, 0.7)` muted lavender | Subtitles, descriptions |
| Text hover | `(1.0, 0.95, 0.85)` warm white | Highlighted/focused text |
| Accent gold | `(0.85, 0.75, 0.45, 0.8)` gold | Borders on hover/focus, ornamental lines |
| Border normal | `(0.45, 0.35, 0.65, 0.6)` muted purple | Button borders in normal state |
| Disabled | `(0.4, 0.38, 0.5, 0.5)` dim gray | Disabled button text and borders |
| Battle panel | `(0.1, 0.1, 0.2, 0.85)` dark blue-purple | Battle UI panels |

## Font Sizes (at 640x360 viewport)

| Element | Size | Scene |
|---------|------|-------|
| Game title | 36 | Title screen |
| Subtitle | 11 | Title screen |
| Menu buttons | 14 | Title screen, pause menu |
| Version label | 10 | Title screen |
| Location name | 12 | HUD |
| Dialogue speaker | 12 | Dialogue box |
| Dialogue text | 10 | Dialogue box |
| Battle commands | 12 | Battle UI |
| Battle log | 9 | Battle UI |
| Character names | 10 | Party panels |
| Turn order | 9 | Battle UI top bar |

## Button Styling

All menu buttons use `StyleBoxFlat` theme overrides with 5 states:

| Property | Value |
|----------|-------|
| Corner radius | 3px (all corners) |
| Border width | 1px (all sides) |
| Content margin | 16px horizontal, 4px vertical |
| Normal | Dark purple fill, muted purple border |
| Hover/Focus | Lighter purple fill, gold border |
| Pressed | Very dark fill, dimmed border |
| Disabled | Transparent fill, barely visible border |

When adding new buttons to any UI scene, copy these `StyleBoxFlat` sub-resources from `title_screen.tscn` to keep styling consistent.

## Focus Navigation

- All menu screens implement keyboard/gamepad navigation
- Vertical wrap-around: last item wraps to first and vice versa
- First interactive element grabs focus on `_ready()`
- Use `focus_neighbor_top/bottom` for explicit navigation chains

## UI Scenes

### Title Screen (`title_screen/`)
- Dark indigo background with gold ornamental separator lines framing the title
- Fade-in tween: title (1s) -> subtitle (0.5s) -> menu (0.5s) -> version (0.3s)
- 3 styled buttons: New Game, Continue (disabled if no save), Settings
- No external texture assets — all Godot built-in nodes + StyleBoxFlat

### HUD (`hud/`)
- Transparent CanvasLayer overlay (layer 10)
- Top bar: location label (left), gold counter (right)
- Right panel: party status (4 slots with HP/EE bars)
- Bottom: interaction prompt label

### Battle UI (`battle_ui/`)
- Dark blue-purple panel theme
- Top bar: turn order with portrait icons
- Bottom: portrait (52x52), command menu (5 buttons), party status + resonance bar
- Submenus: skills and items (scrollable, overlaying command menu)
- Victory/defeat modal screens
- **Portrait assets:** `kael_portrait.png`, `iris_portrait.png`, `garrick_portrait.png` from `tf-faces-6.11.20/transparent/1x/`

### Dialogue Box (`dialogue/`)
- CanvasLayer (layer 15) — above HUD
- Portrait (80x80, left side, optional) + speaker name + RichTextLabel with BBCode
- Choice buttons container + advance indicator
- **Portrait assets:** same as battle UI (from `tf-faces-6.11.20/transparent/1x/`)

### Pause Menu (`pause_menu/`)
- CanvasLayer (layer 20) — above everything
- Dim overlay (0.6 opacity black)
- Left: navigation buttons (Party, Items, Status, Quit to Title)
- Right: scrollable content panel

## Z-Order (CanvasLayer)

| Layer | Value | Purpose |
|-------|-------|---------|
| HUD | 10 | Always visible during gameplay |
| Dialogue | 15 | Above HUD when active |
| Pause Menu | 20 | Above everything when paused |
