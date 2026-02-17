# UI Asset Usage and Style Guide

Reference for UI styling conventions across the game. Consult before creating or modifying UI screens.

## Title Screen (`title_screen/`)

**Layout:** Full-screen Control with centered VBoxContainer for title and menu.

**Color Palette:**
- Background: `Color(0.05, 0.03, 0.1, 1)` — deep indigo/near-black
- Title text: `Color(0.85, 0.75, 1.0, 1)` — soft lavender
- Subtitle text: `Color(0.6, 0.55, 0.7, 1)` — muted purple
- Version text: `Color(0.4, 0.4, 0.5, 1)` — dim gray

**Font Sizes:**
- Title: 32px
- Subtitle: 12px
- Menu buttons: 14px
- Version label: 10px

**Animation:** Sequential fade-in using Tween — title (1.0s), subtitle (0.5s), menu (0.5s), version (0.3s).

**Focus Navigation:** Vertical wrap-around (New Game -> Continue -> Settings -> New Game). Continue button disabled when no save data exists.

## Common UI Conventions

**Font Sizes:**
| Element | Size |
|---------|------|
| Screen titles | 32px |
| Section headers | 18-20px |
| Body text / buttons | 14px |
| Subtitles / captions | 12px |
| Version / fine print | 10px |

**Color Themes:**
- Dark backgrounds with light text (high contrast for readability)
- Purple/lavender accent colors match the "Gemini Fantasy" fantasy aesthetic
- Muted/dim colors for secondary information (subtitles, version)

**Button Styling:**
- Default Godot Button theme (no custom theme resource yet)
- Font size 14px for all menu buttons
- Vertical VBoxContainer with 8px separation

**Focus Navigation:**
- All menu screens must implement keyboard/gamepad navigation
- Vertical wrap-around: last item -> first item and vice versa
- First interactive element grabs focus on screen ready
