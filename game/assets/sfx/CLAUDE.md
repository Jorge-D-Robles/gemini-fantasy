# game/assets/sfx/

Sound effect files for UI interactions and combat feedback. All `.ogg` files are gitignored — only `.import` sidecar files are committed.

## File Index

### ui/

| File | Duration | Description |
|------|----------|-------------|
| `confirm.ogg` | 0.15s | Bright rising two-tone (menu confirm, accept) |
| `cancel.ogg` | 0.17s | Descending tone (menu cancel, back) |
| `menu_open.ogg` | 0.20s | Rising frequency sweep (open menu/panel) |
| `dialogue_advance.ogg` | 0.05s | Soft blip (advance dialogue text) |

### combat/

| File | Duration | Description |
|------|----------|-------------|
| `attack_hit.ogg` | 0.12s | Noise burst + low tone (physical attack impact) |
| `magic_cast.ogg` | 0.35s | Rising shimmer with harmonics (ability/spell cast) |
| `heal_chime.ogg` | 0.48s | Ascending C-E-G-C arpeggio (healing effect) |
| `death.ogg` | 0.50s | Descending dark sweep (enemy/party defeat) |
| `critical_hit.ogg` | 0.15s | Loud noise + bright overtone (critical damage) |
| `status_apply.ogg` | 0.25s | Warbling tone (status effect applied) |

## Usage Pattern

Access paths via `SfxLibrary` constants (globally available via `class_name`):

```gdscript
var sfx := load(SfxLibrary.UI_CONFIRM) as AudioStream
if sfx:
    AudioManager.play_sfx(sfx)
```

## Notes

- All files are procedural placeholders — replace with professional SFX as needed
- Format: OGG Vorbis, 44.1kHz, mono, under 6KB each
- Loop setting: `loop=false` (default for SFX, set in .import files)
- Audio bus: SFX (routed through AudioManager's round-robin pool)
