# Core Game Mechanics

## Overview

A turn-based JRPG with emphasis on emotional storytelling, tactical combat, and meaningful progression. Inspired by Final Fantasy VI, Chrono Trigger, and modern innovations like Persona 5.

---

## Combat System

### Turn-Based Battle Flow

**ATB (Active Time Battle) Variant**:
- Characters have speed stats that determine turn order
- Turn order displayed on left side of screen
- Can see upcoming 5-10 turns to plan strategies
- Some abilities can manipulate turn order (delays, haste, slow)
- Time flows during menu selection (can be paused in accessibility options)

**Battle Structure**:
1. **Encounter** - Enemies appear (random encounters in dungeons, visible overworld)
2. **Initiative** - Turn order calculated based on Speed + Resonance state
3. **Turns** - Each character selects action when their turn arrives
4. **Resolution** - Actions execute with animations and effects
5. **Victory/Defeat** - Experience, items, story progression

### Core Actions

Every character can perform basic actions:

**ATTACK**
- Physical melee/ranged attack with equipped weapon
- Builds Resonance gauge (more on this below)
- Can target single enemy or (with certain weapons) multiple
- Critical hits based on Luck stat + positioning

**DEFEND**
- Reduce incoming damage by 50%
- Build Resonance gauge faster
- Some characters have special defend abilities (Garrick can protect allies)

**ITEM**
- Use consumable items from inventory
- Doesn't consume Resonance
- Can target self or allies
- Some items can be thrown at enemies

**RESONANCE** (This game's "Magic")
- Uses Resonance gauge and sometimes MP equivalent (Emotional Energy)
- Character-specific abilities
- Range from attacks to buffs to debuffs to utility
- Discussed in detail below

**ECHO** (Unique mechanic)
- Use collected Echo Fragments for special abilities
- Limited uses per battle
- Shared resource across party
- Strategic decision: use powerful Echo now or save for emergency?

---

## The Resonance System

The core mechanical and thematic pillar of the game.

### Resonance Gauge

**Building Resonance**:
- Each character has a Resonance gauge (0-100%)
- Builds by:
  - Taking damage (+5-15% depending on damage)
  - Dealing damage (+3-10% depending on damage)
  - Defending (+10%)
  - Allies reaching emotional thresholds (+5% party-wide)
  - Environmental factors (near crystals, in The Hollows, etc.)

**Using Resonance**:
- Resonance abilities require minimum gauge %
- Some abilities consume gauge entirely
- Some abilities require specific % thresholds
- High Resonance = more power but risk of "Overload"

### Resonance States

Characters have emotional states that affect combat:

**FOCUSED** (Base state)
- Normal stats, balanced performance
- Most abilities available

**RESONANT** (75%+ gauge)
- +20% damage on Resonance abilities
- Access to powerful "Resonant" tier abilities
- Visual change: character glows with crystalline energy

**OVERLOAD** (100% gauge after taking damage)
- Double damage output BUT take double damage
- Can use "Limit Break" style ultimate abilities
- High risk/high reward
- Must be managed carefully

**HOLLOW** (Special negative state)
- If KO'd while in Overload state
- Revived as "Hollow" - no emotions, 50% stats
- Cannot use Resonance abilities
- Must be "grounded" by allies using the **Ground** command (see below)
- Thematic representation of losing yourself to power

**THE GROUND COMMAND**
- Special command available to all non-Hollowed party members when an ally is Hollow.
- **Cost:** User's turn + 25% of User's Resonance Gauge.
- **Effect:** Anchors the Hollowed ally back to their identity. Removes Hollow state and restores 25% HP.
- **Thematic:** An ally literally shares their "self" to remind the Hollowed one who they are.

### Emotional Energy (EE)

Traditional MP equivalent, but tied to emotions:

- Each character has EE pool (50-200 depending on level and character)
- Abilities cost EE to use
- Restored by:
  - Items
  - Rest at camps/inns
  - "Resonance Tuning" ability (converts Resonance gauge to EE)
  - Story moments of emotional catharsis
- Different abilities cost different amounts based on emotional intensity

---

## Character Progression

### Experience and Leveling

**Traditional XP System**:
- Gain XP from battles and quest completion
- Level cap: 99 (but expect to finish main story at 50-60)
- Each level grants:
  - Stat increases (HP, EE, Strength, Magic, Defense, Resistance, Speed, Luck)
  - Ability Points (AP) for skill trees
  - Occasional new abilities

**Stat Growth**:
- Each character has different growth rates
- Kael: Balanced
- Iris: High Strength, moderate Speed
- Garrick: Very high Defense, low Speed
- Nyx: Extreme Magic, very low Defense
- Sienna: High Resistance, moderate Magic
- Cipher: Very high Speed, moderate Strength
- Lyra: Balanced Magic/Resistance
- Ash: Moderate all stats but unique abilities

### Ability Point (AP) System

**Earning AP**:
- 1-3 AP per level up
- Bonus AP from quests and story beats
- Special AP from character development moments

**Spending AP**:
- Each character has unique skill tree
- Trees have branches representing different playstyles
- Example: Iris can specialize in:
  - **Arsenal**: Heavy weapons and physical damage
  - **Engineering**: Gadgets and debuffs
  - **Cybernetics**: Enhancing her prosthetic for special abilities
- Can mix and match, but focusing gives powerful capstone abilities

**Respeccing**:
- Can reset skill trees at "Resonance Shrines" in major cities
- Costs gold (to prevent constant respeccing)
- Encourages experimentation while maintaining consequences

### Equipment System

**Weapon Types**:
- Each character has 2-3 weapon types they can use
- Kael: Swords, Daggers
- Iris: Hammers, Rifles
- Garrick: Shields (yes, shields as weapons), Maces
- Nyx: Staves, Orbs
- Sienna: Books (catalysts), Rods
- Cipher: Dual Blades, Handguns
- Lyra: Crystals, Grimoires
- Ash: Bells, Totems

**Weapon Stats**:
- Attack/Magic power
- Speed modifier
- Critical rate
- Special properties (elemental damage, status effects, unique abilities)
- Some weapons grant unique skills when equipped

**Armor Types**:
- Helmet, Chest, Accessory x2
- Provide Defense/Resistance and HP/EE bonuses
- Can have special properties (status immunity, elemental resistance, stat boosts)
- Set bonuses for wearing matching armor pieces

**Customization**:
- Weapons and armor can be **Resonance Tuned** at crafters.
- Tuning adds properties using collected Echo Fragments.
- **Tuning Slots:** Items have 1-3 slots based on rarity (Common: 1, Rare: 2, Legendary: 3).
- **Permanence:** Tuning is semi-permanent. Replacing an Echo in a slot destroys the previously equipped Echo and requires a significant RC fee.
- Creates deep customization without overwhelming complexity

---

## Echo Fragment System

### Collecting Echoes

**What are Echo Fragments?**:
- Crystallized memories found throughout the world
- Range from mundane (a child's laughter) to powerful (a warrior's last stand)
- Kael can collect them using special Echo Hunter tools

**Finding Echoes**:
- Random encounters in crystal-rich areas
- Hidden in dungeons and ruins
- Rewards from quests
- Story-specific Echoes from important events
- Can be purchased from certain merchants

**Echo Categories**:
1. **Combat Echoes** - Used in battle for special abilities
2. **Tuning Echoes** - Used to customize equipment
3. **Story Echoes** - Provide lore and worldbuilding when viewed
4. **Companion Echoes** - Unlock character backstory and bonding events

### Using Echoes in Battle

**Echo Slots**:
- Party has 6 Echo Slots total (shared resource)
- Before battle, assign collected Echoes to slots
- During battle, can use each slotted Echo once
- After battle, Echoes recharge (can be used again in next fight)

**Echo Types**:
- **Attack Echoes**: Powerful elemental or physical attacks
  - Example: "Burning Village" - Fire damage to all enemies
- **Support Echoes**: Buffs, heals, or utility
  - Example: "Mother's Comfort" - Heal party and remove status effects
- **Debuff Echoes**: Weaken enemies
  - Example: "Soldier's Fear" - Lower all enemy Defense
- **Unique Echoes**: Strange or experimental effects
  - Example: "Time Skip" - Delay all enemy turns by one position

**Echo Rarity**:
- Common (white) - Basic effects
- Uncommon (blue) - Moderate effects
- Rare (purple) - Strong effects
- Legendary (gold) - Extremely powerful effects
- Unique (rainbow) - Story-specific, one-of-a-kind effects

---

## Exploration Mechanics

### Overworld

**2D Sprite-based Movement**:
- Top-down perspective (classic JRPG style)
- Walk/run toggle
- Interact with NPCs, objects, and points of interest
- Some areas require story progression or items to access

**Fast Travel**:
- Unlock "Resonance Beacons" in major locations
- Can warp between beacons instantly
- Some remote areas have no beacons (maintains exploration challenge)

**Vehicles** (unlocked mid-game):
- **Aetherium Skiff** - Hover vehicle for crossing water and rough terrain
- Faster movement, can flee random encounters more easily
- Needed to access certain islands and areas

### Dungeons

**Linear + Exploration Hybrid**:
- Main path is clear for players who want to progress
- Optional branches with better loot and challenges
- Environmental puzzles using Resonance abilities
  - Example: Use Nyx to light crystal lanterns
  - Example: Use Iris to repair ancient machinery
  - Example: Use Cipher to hack security doors

**Dungeon Features**:
- Save points at regular intervals
- Campfire spots to rest and trigger character dialogue
- Hidden rooms with bonus chests
- Mini-bosses guarding treasure
- Environmental hazards (poison gas, crystal corruption, time anomalies)

**Puzzle Design Philosophy**:
- No obtuse "use random item on random object" puzzles
- Solutions are logical and hinted at through environment
- Can always brute-force forward (puzzles are for bonuses, not gates)
- Accessibility: can enable puzzle hints in options

---

## Camp System

### Resting Mechanics

**Setting Up Camp**:
- At designated campfire spots in dungeons/world
- Party gathers around fire (charming pixel animations)
- Fully restores HP and EE
- Can save game

**Camp Activities**:
1. **Talk** - Trigger character dialogue and bonding events
2. **Cook** - Use ingredients to make meals with temporary buffs
3. **Tune** - Modify equipment with Echo Fragments
4. **Journal** - Review story, quests, collected lore
5. **Rest** - Skip ahead to next story beat if ready

### Character Bonding

**Support Conversations**:
- Inspired by Fire Emblem support system
- Characters gain "Bond Levels" through:
  - Fighting together in battles
  - Talking at camps
  - Making choices in story that align with their values
- Bond Levels: D → C → B → A → S
- Each level unlocks dialogue scene
- S-rank unlocks for select characters as romance option

**Mechanical Benefits**:
- Higher bond = combat bonuses when near each other
- Special "Team Resonance" abilities at high bonds
- Story variations based on relationships
- Affects endings

---

## Side Content

### Side Quests

**Types**:
1. **Character Quests** - Explore party member backstories
2. **Settlement Quests** - Help towns with local problems
3. **Bounty Hunts** - Track down dangerous Echoes or creatures
4. **Collection Quests** - Gather specific items or Echoes
5. **Mystery Quests** - Investigate strange phenomena

**Rewards**:
- Unique equipment
- Rare Echo Fragments
- Character development
- Lore and worldbuilding
- Gold and items

### Mini-Games

**Echo Arena**:
- Battle arena with challenge fights
- Restrictions (no items, low level, specific party compositions)
- Leaderboards (if online features implemented)
- Unique rewards

**Resonance Archaeology**:
- Excavate pre-Severance ruins
- Mini-game involving grid-based digging
- Uncover artifacts, Echoes, and lore
- Can sell findings or keep for collection

**Card Game: "Fragments"** (Optional):
- Collectible card game using Echo Fragments as cards
- NPCs throughout world will play with you
- Building deck is separate from combat Echo collection
- Purely optional but with nice rewards for completionists

---

## Difficulty and Accessibility

### Difficulty Modes

**Story Mode**:
- Easier combat, enemies have 70% HP
- Auto-revive if party wipes (once per dungeon)
- For players who want narrative experience

**Normal Mode**:
- Balanced experience
- Designed for most players
- Fair but requires tactical thinking

**Hard Mode**:
- Enemies have 150% HP and damage
- Smarter AI, more aggressive
- For JRPG veterans

**Resonance Breaker Mode** (Unlocked after first completion):
- Enemies have 200% HP and damage
- New enemy abilities and patterns
- Permadeath option
- For masochists

### Accessibility Options

**Visual**:
- Colorblind modes
- High contrast UI option
- Adjustable text size
- Screen reader support for menus

**Audio**:
- Full subtitles with speaker labels
- Visual sound cues
- Separate volume controls (Music, SFX, Voice)

**Gameplay**:
- Auto-battle option
- Turn timer can be paused or disabled
- Puzzle hints toggle
- Can reduce/eliminate random encounters
- Quick-time events can be made automatic

**Controls**:
- Fully remappable
- One-handed mode
- Hold vs. toggle options
- Controller, keyboard, and hybrid support

---

## Progression Pacing

### Early Game (Hours 1-5)
- Introduce mechanics gradually
- Party starts with Kael alone, adds members one by one
- Tutorials are contextual and can be revisited
- First dungeon teaches basic combat
- First boss requires understanding Resonance system

### Mid Game (Hours 6-25)
- All systems unlocked
- Freedom to explore and tackle side content
- Difficulty increases, requires strategic thinking
- Equipment and Echo customization becomes important
- Character builds start to differentiate

### Late Game (Hours 26-40)
- Optional superbosses
- Grinding for best equipment
- Completing all side quests and bonds
- Multiple endings to pursue
- Post-game content (if time permits)

---

## Death and Consequences

**Party Wipe**:
- Return to last save (or auto-save if enabled)
- Keep any items used, lose any gained
- Learn from mistakes and retry

**Individual KO**:
- Character can be revived with items/abilities
- If KO'd in Overload state, revive as Hollow (see Resonance States)
- No permadeath (except in specific difficulty mode)

**Story Deaths**:
- Some characters may die in story
- These are scripted and meaningful
- Not based on combat performance
- Handle with emotional weight and respect

---

## Technical Implementation Notes (For Development)

**Battle System**:
- State machine for battle flow
- Turn queue as ordered list
- Damage calculations: (Attack - Defense) × Modifiers × Random(0.9-1.1)
- Status effects tracked per character with duration counters

**Save System**:
- Autosave after major events
- Manual save at camps and towns
- Multiple save slots
- Save data includes: story flags, inventory, character stats, world state

**Performance**:
- Pixel art sprites for characters and enemies
- Pre-rendered backgrounds for battles
- Smooth animations at 60 FPS target
- Efficient particle effects for Resonance abilities

**UI/UX**:
- Clean, readable menus inspired by modern JRPGs
- Consistent iconography
- Tooltips for everything
- Confirm/cancel standardized
- Battle UI shows all relevant info without clutter
