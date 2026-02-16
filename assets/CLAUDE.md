# Gemini Fantasy - Asset Index & Usage Guide

This document catalogs all sprite assets for the Gemini Fantasy JRPG and provides guidance on when and how to use them in Godot 4.5.

## Directory Structure

```
assets/
├── sprites/
│   ├── characters/     # Playable party member sprites
│   ├── enemies/        # Enemy and boss sprites
│   ├── items/          # Item icons and world sprites
│   └── effects/        # Visual effects (attacks, magic, status)
├── tilesets/
│   ├── cindral_wastes/       # Volcanic wasteland tiles
│   ├── verdant_tangle/       # Overgrown forest tiles
│   ├── crystalline_steppes/  # Crystal field tiles
│   ├── ironcoast/            # Industrial/urban tiles
│   └── hollows/              # Reality-warped tiles
├── ui/
│   ├── battle/         # Battle UI elements
│   ├── menus/          # Menu screens and windows
│   └── icons/          # Status icons, ability icons
├── audio/
│   ├── music/          # Background music tracks
│   ├── sfx/            # Sound effects
│   └── ambient/        # Ambient loops
└── fonts/              # Custom fonts
```

---

## Character Sprites

**Location**: `assets/sprites/characters/`

### Playable Characters

Each character requires the following sprite sets:

#### Required Sprite States
1. **Overworld Sprites** (32x32 or 48x48)
   - 4-directional idle (down, up, left, right)
   - 4-directional walk cycles (4 frames each)
   - Interaction pose (talking, examining)

2. **Battle Sprites** (64x64 or larger)
   - Idle animation (breathing, subtle movement)
   - Attack animations (physical attack windup → strike → recovery)
   - Skill/magic cast animations
   - Take damage animation
   - Victory pose
   - KO/defeat state
   - Defend/guard pose

3. **Portrait Sprites** (various sizes)
   - Dialogue portrait (neutral)
   - Emotional variants (happy, sad, angry, surprised, worried)
   - Menu portrait (small, 32x32)

### Character List

#### Kael Voss (Protagonist)
- **Files Needed**: `kael_overworld.png`, `kael_battle.png`, `kael_portraits.png`
- **Visual Notes**:
  - Short dark hair with crystalline highlights
  - Mismatched eyes (amber/pale blue)
  - Fingerless gloves
  - Adventurer's clothing with pockets
  - Weathered journal as accessory
- **Battle Style**: Balanced fighter-mage, uses Echo abilities
- **Animation Priority**: Echo summoning effects, versatile attack styles

#### Iris Mantle
- **Files Needed**: `iris_overworld.png`, `iris_battle.png`, `iris_portraits.png`
- **Visual Notes**:
  - Tall, dark skin with ritual scarring
  - Long braided black hair
  - Cybernetic left arm (Resonance-powered)
  - Modified Initiative armor (insignias removed)
- **Battle Style**: Tech specialist with gadgets and prosthetic attacks
- **Animation Priority**: Arm transformations, tech deployments

#### Garrick "Old Iron" Thorne
- **Files Needed**: `garrick_overworld.png`, `garrick_battle.png`, `garrick_portraits.png`
- **Visual Notes**:
  - Barrel-chested, gray beard and hair
  - Heavy plate armor (pre-Severance alloy)
  - Massive shield with scratched-out emblem
  - Burn scars on arms/chest
- **Battle Style**: Tank/support, shield-based defense
- **Animation Priority**: Shield blocks, protective stances

#### Nyx
- **Files Needed**: `nyx_overworld.png`, `nyx_battle.png`, `nyx_portraits.png`
- **Visual Notes**:
  - Child-sized (appears 10-12)
  - Shifts between solid and shadow
  - Eyes like starfields (points of light)
  - Crystalline darkness "hair" that floats
  - Occasionally translucent
  - No visible mouth
- **Battle Style**: Wild card mage, unpredictable powerful magic
- **Animation Priority**: Reality-bending effects, shadow manipulation

#### Dr. Sienna Vex
- **Files Needed**: `sienna_overworld.png`, `sienna_battle.png`, `sienna_portraits.png`
- **Visual Notes**:
  - Tall, thin, angular features
  - Prematurely graying hair in severe bun
  - Wire-frame glasses
  - White lab coat over formal dress
  - Hands with slight tremor
- **Battle Style**: Debuffer, weakness analyzer
- **Animation Priority**: Scanning effects, technological attacks

#### Cipher
- **Files Needed**: `cipher_overworld.png`, `cipher_battle.png`, `cipher_portraits.png`
- **Visual Notes**:
  - Androgynous, shaved head
  - Circuit-like glowing tattoos
  - AR visor
  - Cyberpunk layered clothing
  - Multiple piercings
- **Battle Style**: Hacker/rogue, tech manipulation
- **Animation Priority**: Digital effects, quick movements

#### Lyra (Echo)
- **Files Needed**: `lyra_overworld.png`, `lyra_battle.png`, `lyra_portraits.png`
- **Visual Notes**:
  - Translucent crystalline form
  - Liquid crystal hair
  - Pre-Severance scientist uniform (phases through)
  - Gradually more solid as game progresses
  - Echo visual effect
- **Battle Style**: Echo mage, consciousness-based abilities
- **Animation Priority**: Fragmentation effects, memory manipulation

#### Ash (Silent Anchor)
- **Files Needed**: `ash_overworld.png`, `ash_battle.png`, `ash_portraits.png`
- **Visual Notes**:
  - Small child (age 8)
  - Silver-white drifting hair
  - Color-shifting eyes (based on emotion)
  - Ash-walker clothing
  - Barefoot, always clean
  - Crystalline patterns on skin
- **Battle Style**: Emotional buffer, party support
- **Animation Priority**: Emotional aura effects, supportive glows

---

## Enemy Sprites

**Location**: `assets/sprites/enemies/`

### Naming Convention
`[enemy_name]_[variant].png`

Example: `ash_stalker_normal.png`, `ash_stalker_elite.png`

### Enemy Sprite Requirements

Each enemy needs:
1. **Idle animation** (2-4 frames)
2. **Attack animation** (3-6 frames)
3. **Take damage flash/recoil** (1-2 frames)
4. **Death/defeat animation** (3-6 frames)

### Cindral Wastes Enemies

#### Ash Stalker
- **File**: `ash_stalker.png`
- **Description**: Canine with volcanic stone skin, ember-filled eye sockets
- **Size**: Medium (48x48)
- **Animations**: Pack behavior, ember breath effect
- **Visual FX**: Fire particles, ash trails

#### Magma Crawler
- **File**: `magma_crawler.png`
- **Description**: Centipede of cooled lava segments
- **Size**: Large (64x96)
- **Animations**: Coiling, heat wave effect
- **Visual FX**: Lava drips, heat shimmer

#### Cinder Wisp
- **File**: `cinder_wisp.png`
- **Description**: Floating ember with humanoid silhouette
- **Size**: Small (32x48)
- **Animations**: Erratic floating, self-destruct explosion
- **Visual FX**: Flame particles, smoke trails

### Verdant Tangle Enemies

#### Thornback Bear
- **File**: `thornback_bear.png`
- **Description**: Massive bear with crystalline spine thorns
- **Size**: Large (96x96)
- **Animations**: Maul attack, thorn volley, roar
- **Visual FX**: Crystal glints, ground shake

#### Creeping Vine
- **File**: `creeping_vine.png`
- **Description**: Animated vines with Resonance nodes
- **Size**: Variable (use tileable segments)
- **Animations**: Entangle, drain, poison sap
- **Visual FX**: Energy pulses through nodes

#### Memory Bloom
- **File**: `memory_bloom.png`
- **Description**: Crystalline light flower
- **Size**: Small (32x48)
- **Animations**: Pollen cloud, mesmerize glow, bloom summon
- **Visual FX**: Sparkles, light rays, holographic petals

### Crystalline Steppes Enemies

#### Shard Serpent
- **File**: `shard_serpent.png`
- **Description**: Snake of interlocking crystals
- **Size**: Medium-Long (48x96)
- **Animations**: Slither, burrow, shatter
- **Visual FX**: Crystal reflections, underground movement

#### Echo Nomad
- **File**: `echo_nomad.png`
- **Description**: Translucent shifting human figure
- **Size**: Medium (48x64)
- **Animations**: Phase walk teleport, ability mirroring
- **Visual FX**: Fade in/out, afterimages

#### Prism Golem
- **File**: `prism_golem.png`
- **Description**: Geometric crystalline humanoid
- **Size**: Large (96x128)
- **Animations**: Crushing blow, magic refraction, crystal prison
- **Visual FX**: Light refraction, crystal formations

### Ironcoast Federation Enemies

#### Security Drone
- **File**: `security_drone.png`
- **Description**: Hovering sphere with weapons and Initiative logo
- **Size**: Small-Medium (48x48)
- **Animations**: Hover, scan beam, laser blast, alert
- **Visual FX**: Tech holograms, laser effects

#### Initiative Soldier
- **File**: `initiative_soldier.png`
- **Description**: Armored human with Resonance weapon
- **Size**: Medium (48x64)
- **Animations**: Rifle aim/shoot, grenade throw, stimpack use
- **Visual FX**: Muzzle flash, explosion effects

#### Industrial Hauler
- **File**: `industrial_hauler.png`
- **Description**: Modified cargo bot
- **Size**: Large (96x96)
- **Animations**: Charge, cargo drop, overload
- **Visual FX**: Sparks, cargo debris

### The Hollows Enemies

#### Time Wraith
- **File**: `time_wraith.png`
- **Description**: Multi-temporal humanoid figure
- **Size**: Medium (48x64)
- **Animations**: Temporal strike, rewind, time skip
- **Visual FX**: Time distortion, afterimages, clock effects

#### Void Spawn
- **File**: `void_spawn.png`
- **Description**: Formless shadow with wrong limb count
- **Size**: Variable (64x64)
- **Animations**: Reality tear, nullify, existence doubt
- **Visual FX**: Void particles, reality cracks

#### Fractured Self
- **File**: `fractured_self_[character].png`
- **Description**: Corrupted party member reflections
- **Size**: Matches character (48x64)
- **Animations**: Corrupted versions of party abilities
- **Visual FX**: Nightmare distortions, wrong colors

---

## Boss Sprites

**Location**: `assets/sprites/enemies/bosses/`

### Boss Sprite Requirements

Bosses need additional detail:
1. **Multiple phase variants** (visual changes at HP thresholds)
2. **Special attack animations** (unique to boss)
3. **Transition animations** (between phases)
4. **Larger sprite size** (128x128 or bigger)

### Early Game Bosses

#### The Ash King
- **File**: `ash_king.png`
- **Description**: Massive salamander with volcanic crown
- **Size**: Extra Large (192x192)
- **Phases**: Normal → Summoner → Enraged
- **Special Animations**: Volcanic eruption, magma armor, decree
- **Visual FX**: Lava flows, crown glow, massive fire effects

### Mid Game Bosses

#### Dr. Sienna Vex (Pre-Recruitment)
- **File**: `sienna_boss.png`
- **Description**: Sienna in combat armor with prototype weapons
- **Size**: Large (96x96)
- **Phases**: Tactical → Aggressive → Desperate
- **Special Animations**: Disruptor field, prototype barrage, emergency heal
- **Visual FX**: Tech effects, Resonance disruptions

#### The Shepherd Inquisitor
- **File**: `shepherd_inquisitor.png`
- **Description**: Zealot in ceremonial armor with purification crystals
- **Size**: Large (96x128)
- **Phases**: Righteous → Reinforced → Martyrdom
- **Special Animations**: Purging light, judgment, fanatic's resolve
- **Visual FX**: Holy light, crystal glows

#### Echo Amalgamation
- **File**: `echo_amalgamation.png`
- **Description**: Nightmarish fusion of hundreds of Echoes
- **Size**: Extra Large (192x192)
- **Phases**: Random → Patterned → Coherent
- **Special Animations**: Memory overload, absorption, final memory
- **Visual FX**: Constantly shifting forms, memory fragments

### Late Game Bosses

#### Director Vex Thornwright
- **File**: `director_vex.png`
- **Description**: Corporate suit with integrated Resonance tech
- **Size**: Large (96x128)
- **Phases**: Tactical → Connected → Desperate → Crystalline
- **Special Animations**: Executive decision, market correction, cage pulse
- **Visual FX**: Corporate tech, crystal corruption spreading

#### Prophet Null
- **File**: `prophet_null.png`
- **Description**: Hooded figure with hidden crystal form
- **Size**: Large (96x128)
- **Phases**: Holy → Crystal Revealed → Mad
- **Special Animations**: Null zone, prophet's vision, martyr's end
- **Visual FX**: Holy/crystal hybrid effects

#### The Convergence Fragment
- **File**: `convergence_fragment.png`
- **Description**: Ever-shifting form representing all humanity
- **Size**: Extra Large (256x256)
- **Phases**: Dynamic based on player choices
- **Special Animations**: Perfected party abilities
- **Visual FX**: Reality warping, all visual elements combined

---

## Item Sprites

**Location**: `assets/sprites/items/`

### Icon Sizes
- **Inventory Icons**: 32x32
- **World Sprites**: 32x32 (if item appears in overworld)
- **UI Large Icons**: 64x64 (for item details/shops)

### Item Categories

#### Consumables
- `potion_health.png` - Standard HP restoration
- `potion_ee.png` - EE/energy restoration
- `potion_resonance.png` - Resonance gauge restoration
- `elixir_full.png` - Full HP/EE restoration
- `antidote.png` - Poison cure
- `echo_shard.png` - Revive fallen ally
- `stimpack.png` - Temporary stat boost

#### Equipment (Icons)
- Weapons: `weapon_[type]_[name].png`
- Armor: `armor_[slot]_[name].png`
- Accessories: `accessory_[name].png`

#### Key Items
- `resonance_key.png` - Story progression items
- `echo_fragment_[name].png` - Echo collection items
- `ancient_artifact.png` - Lore/quest items

#### Crafting Materials
- `crystal_shard_[color].png` - Various crystal types
- `beast_part_[type].png` - Monster materials
- `tech_component_[name].png` - Initiative tech parts

---

## Visual Effects

**Location**: `assets/sprites/effects/`

### Effect Sprite Sheets

Use sprite sheets with consistent frame timing for effects.

#### Attack Effects
- `slash_effect.png` - Physical melee strikes (8 frames)
- `pierce_effect.png` - Piercing attacks (6 frames)
- `impact_effect.png` - Blunt impacts (6 frames)
- `projectile_[type].png` - Arrows, bullets, etc.

#### Magic Effects
- `fire_cast.png` - Fire magic casting/projectile
- `ice_cast.png` - Ice magic effects
- `lightning_cast.png` - Electric effects
- `holy_light.png` - Light/holy magic
- `dark_void.png` - Dark/void magic
- `resonance_pulse.png` - Resonance-based abilities

#### Echo Effects
- `echo_summon.png` - Echo ability activation (10 frames)
- `echo_discharge.png` - Echo ability impact
- `resonance_buildup.png` - Gauge building effect
- `overload_aura.png` - Overload state visual

#### Status Effects
- `status_burn.png` - Fire DoT effect
- `status_poison.png` - Poison DoT effect
- `status_freeze.png` - Frozen state
- `status_stun.png` - Stunned state
- `status_buff.png` - Generic buff glow
- `status_debuff.png` - Generic debuff particles
- `hollow_corruption.png` - Hollow state effect

#### Environmental Effects
- `dust_cloud.png` - Movement in ash/dust
- `water_splash.png` - Water interactions
- `crystal_sparkle.png` - Crystal interactions
- `portal_effect.png` - Teleport/warp effects

---

## Tileset Assets

**Location**: `assets/tilesets/`

### Tileset Structure

Each region needs:
1. **Ground tiles** (various terrain types)
2. **Wall/obstacle tiles** (collision)
3. **Decoration tiles** (non-collision details)
4. **Animated tiles** (water, lava, etc.)
5. **Autotile sets** (seamless terrain)

### Cindral Wastes Tileset
- **File**: `cindral_wastes_tileset.png`
- **Palette**: Blacks, grays, reds, oranges
- **Tiles Include**:
  - Volcanic rock ground
  - Ash-covered areas
  - Lava flows (animated)
  - Charred wood/structures
  - Steam vents (animated)
  - Obsidian formations
  - Ember particles (overlay)

### Verdant Tangle Tileset
- **File**: `verdant_tangle_tileset.png`
- **Palette**: Deep greens, browns, crystal blues
- **Tiles Include**:
  - Overgrown forest floor
  - Dense foliage
  - Crystal-corrupted trees
  - Vine walls
  - Glowing mushrooms (animated)
  - Ancient ruins covered in plants
  - Thorny barriers

### Crystalline Steppes Tileset
- **File**: `crystalline_steppes_tileset.png`
- **Palette**: Blues, whites, crystal refractions
- **Tiles Include**:
  - Grass with crystal growths
  - Pure crystal ground
  - Crystal formations (various sizes)
  - Prism structures (refractive)
  - Wind-blown grass (animated)
  - Crystal dust (overlay)
  - Nomad campsites

### Ironcoast Federation Tileset
- **File**: `ironcoast_tileset.png`
- **Palette**: Grays, blues, metallic sheens
- **Tiles Include**:
  - Metal floor panels
  - Concrete/pavement
  - Industrial walls
  - Tech panels (some animated)
  - Cargo containers
  - Initiative logos/signage
  - Broken/sparking tech (animated)

### The Hollows Tileset
- **File**: `hollows_tileset.png`
- **Palette**: Shifting, reality-warped colors
- **Tiles Include**:
  - Impossible geometry ground
  - Reality-torn areas (void)
  - Temporal distortion zones (animated)
  - Crystallized time fragments
  - Memory shards
  - Paradox structures
  - Corruption spread (animated)

---

## UI Assets

**Location**: `assets/ui/`

### Battle UI

#### HUD Elements (`assets/ui/battle/`)
- `hp_bar.png` - HP gauge frame and fill
- `ee_bar.png` - EE/energy gauge
- `resonance_gauge.png` - Resonance meter with segments
- `turn_order_frame.png` - Turn queue display background
- `turn_icon_frame.png` - Individual turn indicator
- `action_menu_frame.png` - Battle command menu
- `target_cursor.png` - Enemy/ally selection cursor
- `damage_numbers.png` - Sprite font for damage display

#### Battle Effects UI
- `status_icon_[effect].png` - All status effect icons (32x32)
- `element_icon_[type].png` - Elemental type indicators
- `weakness_indicator.png` - Enemy weakness revealed icon
- `miss_text.png` - "MISS" display
- `critical_text.png` - "CRITICAL" display

### Menu UI

#### Main Menus (`assets/ui/menus/`)
- `menu_frame_large.png` - Main menu windows (9-slice)
- `menu_frame_small.png` - Sub-menu windows (9-slice)
- `button_normal.png` - Default button state
- `button_hover.png` - Mouse hover state
- `button_pressed.png` - Click/select state
- `cursor_main.png` - Menu selection cursor
- `divider_line.png` - Section separators

#### Character Menu
- `character_frame.png` - Character info display
- `equipment_slot.png` - Equipment slot backgrounds
- `stat_icon_[stat].png` - HP, EE, ATK, DEF, etc. icons
- `level_up_effect.png` - Level up celebration effect

#### Inventory Menu
- `inventory_grid.png` - Item grid background
- `item_slot.png` - Individual item slot
- `item_selected.png` - Selected item highlight
- `category_tab_[type].png` - Item category tabs
- `sort_icon.png` - Sorting options

#### Echo Menu
- `echo_collection_frame.png` - Echo display area
- `echo_slot_empty.png` - Empty Echo slot
- `echo_slot_filled.png` - Equipped Echo slot
- `rarity_frame_[rarity].png` - Common, Rare, Legendary borders
- `echo_equipped_indicator.png` - Shows Echo is equipped

### Icons (`assets/ui/icons/`)

#### Ability Icons (64x64)
Create unique icons for each ability type:
- Physical attacks: `icon_ability_[name].png`
- Magic spells: `icon_magic_[name].png`
- Echo abilities: `icon_echo_[name].png`
- Support skills: `icon_support_[name].png`

#### Status Icons (32x32)
- `icon_status_burn.png`
- `icon_status_poison.png`
- `icon_status_freeze.png`
- `icon_status_stun.png`
- `icon_status_haste.png`
- `icon_status_slow.png`
- `icon_status_overload.png`
- `icon_status_hollow.png`
- `icon_status_shield.png`
- `icon_status_regen.png`

---

## Technical Specifications

### Sprite Import Settings (Godot 4.5)

#### For Pixel Art (Recommended)
```
Import As: Texture2D
Compression: Lossless
Filter: Nearest
Mipmaps: Off
Repeat: Disabled
```

#### For High-Res Art
```
Import As: Texture2D
Compression: Lossy
Filter: Linear
Mipmaps: On (for scaled sprites)
Repeat: Disabled
```

### Sprite Sheet Configuration

For animated sprites, use the following convention:

**Filename**: `character_action_framecount.png`
- Example: `kael_walk_4.png` (4 frames of walk animation)

**Frame Layout**: Horizontal strip (left to right)
- Frame 1 | Frame 2 | Frame 3 | Frame 4

**Godot Setup**:
1. Import sprite sheet
2. Create `AnimatedSprite2D` node
3. In SpriteFrames panel, set Hframes to frame count
4. Set animation FPS (typically 8-12 for walk cycles)

### Recommended Sprite Resolutions

| Asset Type | Minimum | Recommended | Max |
|-----------|---------|-------------|-----|
| Character Overworld | 32x32 | 48x48 | 64x64 |
| Character Battle | 64x64 | 96x96 | 128x128 |
| Character Portrait | 64x64 | 128x128 | 256x256 |
| Common Enemy | 32x32 | 48x48 | 96x96 |
| Boss Enemy | 96x96 | 128x128 | 256x256 |
| Item Icon | 32x32 | 32x32 | 64x64 |
| UI Element | Varies | Varies | Varies |
| Tileset Tile | 16x16 | 32x32 | 64x64 |

### Color Palette Guidelines

**Cindral Wastes**: #2B2B2B, #4A4A4A, #8B0000, #FF4500, #FFA500

**Verdant Tangle**: #1A3A1A, #2D5016, #4A7023, #8FBC8F, #00CED1

**Crystalline Steppes**: #E0F7FF, #87CEEB, #4682B4, #B0E0E6, #FFFFFF

**Ironcoast Federation**: #36454F, #708090, #A9A9A9, #4169E1, #FF6347

**The Hollows**: #1C1C1C, #4B0082, #8B008B, #9400D3, #FF00FF

### Transparency & Masking

- Use **PNG with alpha channel** for all sprites
- Ensure clean edges (no semi-transparent halos)
- For pixel art, use **hard edges only** (no anti-aliasing)
- For effects, alpha blending is acceptable

---

## Asset Creation Checklist

When adding new sprites to the project:

### Pre-Creation
- [ ] Check if similar asset already exists
- [ ] Verify size/resolution requirements
- [ ] Confirm color palette matches region/theme
- [ ] Plan animation frame count

### During Creation
- [ ] Use consistent art style across all assets
- [ ] Maintain proper sprite dimensions
- [ ] Use appropriate color depth
- [ ] Create in layers for easy editing
- [ ] Export with transparency

### Post-Creation
- [ ] Save source file (.psd, .aseprite, etc.) to `assets/_source/`
- [ ] Export as PNG
- [ ] Name file according to convention
- [ ] Place in correct directory
- [ ] Import into Godot with correct settings
- [ ] Test in-engine (scale, animation, collision)
- [ ] Update this CLAUDE.md index

### Testing
- [ ] Sprite renders correctly at target resolution
- [ ] Animations play smoothly
- [ ] Colors match palette/theme
- [ ] Transparency works as expected
- [ ] Sprite aligns properly with hitboxes
- [ ] No visual artifacts or clipping

---

## Common Godot Sprite Usage Patterns

### Character Overworld Setup

```gdscript
# Character controller script
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Animation names: "idle_down", "walk_down", "idle_up", "walk_up", etc.
	animated_sprite.play("idle_down")

func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		animated_sprite.play("idle_" + get_direction_string())
	else:
		animated_sprite.play("walk_" + get_direction_string())
```

### Battle Sprite Setup

```gdscript
# Battle combatant script
extends Node2D

@onready var sprite: AnimatedSprite2D = $BattleSprite

func play_attack_animation() -> void:
	sprite.play("attack")
	await sprite.animation_finished
	sprite.play("idle")

func take_damage_visual() -> void:
	sprite.play("hurt")
	# Flash effect
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	await sprite.animation_finished
	sprite.play("idle")
```

### Effect Spawning

```gdscript
# Effect spawner
const EFFECT_SCENE = preload("res://scenes/effects/generic_effect.tscn")

func spawn_effect(effect_name: String, position: Vector2) -> void:
	var effect := EFFECT_SCENE.instantiate()
	effect.position = position
	effect.play_effect(effect_name)
	get_tree().root.add_child(effect)
```

### UI Icon Display

```gdscript
# Inventory slot
extends TextureRect

func set_item(item: Item) -> void:
	if item:
		texture = load("res://assets/sprites/items/" + item.icon_path)
	else:
		texture = null
```

---

## Placeholder Assets

Until final art is created, use these placeholder conventions:

### Colored Squares for Characters
- Kael: Amber/Blue split square (64x64)
- Iris: Dark purple square with cyan accent
- Garrick: Gray square with shield icon
- Nyx: Black square with white stars
- Sienna: White square with red cross
- Cipher: Magenta/Cyan glitch pattern
- Lyra: Transparent blue with crystal pattern
- Ash: Silver-white with color-shifting border

### Colored Shapes for Enemies
- Small enemies: 32x32 colored circles
- Medium enemies: 48x48 colored triangles
- Large enemies: 64x64 colored rectangles
- Bosses: 128x128 colored diamonds

### Icon Placeholders
Use Godot's built-in icons or simple geometric shapes with labels

---

## Asset Pipeline Workflow

### Step 1: Design
1. Review game design docs for visual requirements
2. Create concept sketches
3. Get feedback from team
4. Finalize design

### Step 2: Creation
1. Create in art software (Aseprite, Photoshop, etc.)
2. Follow sprite specifications above
3. Export as PNG with transparency
4. Save source files to `assets/_source/`

### Step 3: Integration
1. Place PNG in appropriate `assets/` subdirectory
2. Import into Godot project
3. Configure import settings
4. Create necessary scene/resource files
5. Test in-game

### Step 4: Documentation
1. Update this CLAUDE.md file with new asset info
2. Document any special usage requirements
3. Note any dependencies or related assets

---

## Asset Maintenance

### Regular Audits
- **Monthly**: Check for unused assets
- **Per milestone**: Verify all required assets exist
- **Before release**: Optimize file sizes and formats

### Optimization Tips
- Use sprite atlases for related sprites (reduces draw calls)
- Compress large textures where quality loss is acceptable
- Remove unused frames from animation sheets
- Use texture filtering appropriately (Nearest for pixel art)

### Version Control
- Commit source files to `_source/` directory
- Don't commit large binary working files (use .gitignore)
- Use descriptive commit messages for asset changes
- Tag major asset revision milestones

---

## FAQ

**Q: What resolution should I use for pixel art vs HD art?**
A: This project uses **pixel art style**. Stick to multiples of 16 (16x16, 32x32, 48x48, 64x64) for consistency.

**Q: Can I mix art styles?**
A: No. Maintain consistent pixel art style across all sprites for visual cohesion.

**Q: How many animation frames do character walk cycles need?**
A: Minimum 4 frames per direction (8 directions = 32 frames total). For smoother animation, use 6-8 frames per direction.

**Q: Should effects be separate sprites or part of character sprites?**
A: **Separate sprites**. Effects are reusable across multiple characters and enemies.

**Q: How do I handle sprite scaling in Godot?**
A: Set Filter to **Nearest** for pixel art to prevent blurriness. Use integer scaling only (2x, 3x, never 1.5x).

**Q: Where do I put sprite source files (.psd, .aseprite)?**
A: In `assets/_source/` directory (not tracked by Godot, optionally tracked by git).

---

## Quick Reference: Asset Locations

| Asset Type | Location | File Format |
|-----------|----------|-------------|
| Character Overworld | `assets/sprites/characters/` | PNG |
| Character Battle | `assets/sprites/characters/` | PNG |
| Character Portraits | `assets/sprites/characters/` | PNG |
| Enemy Sprites | `assets/sprites/enemies/` | PNG |
| Boss Sprites | `assets/sprites/enemies/bosses/` | PNG |
| Item Icons | `assets/sprites/items/` | PNG |
| Visual Effects | `assets/sprites/effects/` | PNG |
| Tilesets | `assets/tilesets/` | PNG |
| Battle UI | `assets/ui/battle/` | PNG |
| Menu UI | `assets/ui/menus/` | PNG |
| Icons | `assets/ui/icons/` | PNG |
| Music | `assets/audio/music/` | OGG |
| SFX | `assets/audio/sfx/` | WAV/OGG |
| Ambient | `assets/audio/ambient/` | OGG |
| Fonts | `assets/fonts/` | TTF/OTF |

---

## Contributing New Assets

When adding assets to this project:

1. **Follow the naming convention**: `[type]_[name]_[variant].png`
2. **Use the correct directory structure** as outlined above
3. **Update this CLAUDE.md** with new asset information
4. **Test in Godot** before committing
5. **Optimize file size** without sacrificing quality
6. **Include source files** in `_source/` if applicable

---

## Tools & Resources

### Recommended Software
- **Aseprite**: Pixel art animation (paid)
- **GIMP**: Free image editing
- **Krita**: Free digital painting
- **Inkscape**: Vector graphics (for UI elements)

### Helpful Godot Resources
- [Godot 2D Sprite Documentation](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html)
- [AnimatedSprite2D Documentation](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html)
- [TileMap Documentation](https://docs.godotengine.org/en/stable/classes/class_tilemap.html)

### Asset Reference Sites
- OpenGameArt.org (CC-licensed game assets)
- itch.io (indie game assets, many free)
- Kenney.nl (free game assets)

---

**Last Updated**: 2026-02-15
**Maintained By**: Claude Code
**Project**: Gemini Fantasy JRPG
