# Gemini Fantasy - Game Design Documentation

## Project Overview

**Genre**: 2D Turn-Based JRPG
**Engine**: Godot
**Art Style**: Time Fantasy pixel art assets
**Inspirations**: Final Fantasy VI, Chrono Trigger, Persona 5
**Estimated Playtime**: 40+ hours (main story)
**Target Platforms**: PC (initial), potential console ports

---

## Documentation Structure

This documentation is organized into three main categories:

### 📖 Lore & World Building (`/docs/lore/`)

The narrative foundation of Aethermoor.

1. **[World Overview](lore/01-world-overview.md)**
   - Geography and the Five Domains
   - The Severance event and its aftermath
   - Current political factions
   - Magic system (Resonance)
   - Core themes and world state

2. **[Main Story](lore/02-main-story.md)**
   - Complete plot outline (Acts I-III)
   - Multiple endings system
   - Key story beats and branching paths
   - Character arcs and development
   - Narrative innovations

3. **[Characters](lore/03-characters.md)**
   - Playable party members (8 detailed characters)
   - Major antagonists
   - Supporting NPCs
   - Character relationships and bonds
   - Design philosophy

### 🎮 Game Design (`/docs/game-design/`)

Core systems and gameplay mechanics.

1. **[Core Mechanics](game-design/01-core-mechanics.md)**
   - Combat system (ATB variant)
   - Resonance gauge system
   - Character progression (XP, AP, skill trees)
   - Equipment and customization
   - Echo Fragment system
   - Exploration mechanics
   - Camp and bonding system
   - Difficulty and accessibility

2. **[Enemy Design](game-design/02-enemy-design.md)**
   - Enemy categories and philosophy
   - Bestiary by region (30+ enemy types)
   - Boss encounters (story and optional)
   - Superboss designs
   - AI patterns and balance

3. **[World Map & Locations](game-design/03-world-map-and-locations.md)**
   - Full world map structure
   - Major cities and towns (detailed)
   - Dungeon designs and layouts
   - Secret areas and exploration
   - Regional themes and progression

### ⚙️ Mechanics (`/docs/mechanics/`)

Detailed mechanical systems and implementation details.

1. **[Character Abilities](mechanics/character-abilities.md)**
   - Complete ability lists for all 8 party members
   - Skill tree breakdowns
   - Limit Break systems
   - Ability progression and unlocks
   - Build variety and synergies

---

## Quick Start Guide

### For Writers/Narrative Designers
Start with:
1. [World Overview](lore/01-world-overview.md) - Understand the setting
2. [Main Story](lore/02-main-story.md) - See the narrative structure
3. [Characters](lore/03-characters.md) - Meet the cast

### For Game Designers/Developers
Start with:
1. [Core Mechanics](game-design/01-core-mechanics.md) - Understand core systems
2. [Character Abilities](mechanics/character-abilities.md) - See combat design
3. [World Map & Locations](game-design/03-world-map-and-locations.md) - Plan implementation scope

### For Artists
Start with:
1. [Characters](lore/03-characters.md) - Character designs and descriptions
2. [World Map & Locations](game-design/03-world-map-and-locations.md) - Environmental themes
3. [Enemy Design](game-design/02-enemy-design.md) - Enemy concepts

---

## Core Pillars

### 1. Meaningful Narrative
- Tackles complex themes (identity, memory, progress vs. preservation)
- Morally gray factions with legitimate perspectives
- Player choices matter and have consequences
- Character-driven story with deep relationships

### 2. Strategic Combat
- Turn-based with active time elements
- Resource management (Resonance gauge, EE, Echoes)
- Risk-reward mechanics (Overload system)
- Tactical depth without overwhelming complexity

### 3. Emotional Resonance
- Magic system tied to emotions and memories
- Character bonding affects gameplay and story
- Environmental storytelling through Echoes
- Themes of hope, connection, and identity

### 4. Exploration & Discovery
- Handcrafted world with meaningful secrets
- Echo collection creates narrative breadcrumbs
- Optional content that rewards curiosity
- Multiple paths and approaches

### 5. Accessibility
- Multiple difficulty modes
- Comprehensive accessibility options
- Flexible gameplay styles
- Story can be experienced by all skill levels

---

## Unique Selling Points

### What Makes This JRPG Different?

**1. The Echo System**
- Collectible memory fragments that serve as:
  - Combat resources (like summons but more flexible)
  - Lore delivery (environmental storytelling)
  - Equipment customization (tuning system)
  - Character development (companion Echoes)

**2. Resonance Risk-Reward**
- Power comes at cost (risk of becoming Hollow)
- Managing emotional energy creates tension
- Overload state is powerful but dangerous
- Thematic integration with narrative

**3. Modern JRPG Sensibilities**
- Quality of life features (fast travel, auto-save, skip options)
- Accessibility without compromising challenge
- Respectful representation (gender, sexuality, disability, mental health)
- Subverts JRPG tropes while honoring the genre

**4. Branching Narrative with Real Stakes**
- Four distinct endings (plus variations)
- Moral choices without "correct" answers
- Character deaths can occur based on choices
- World state changes based on player actions

**5. No Filler Content**
- Every encounter designed with purpose
- No grinding required (strategy > levels)
- Side quests with narrative weight
- Respect for player time

---

## Development Phases (Proposed)

### Phase 1: Prototype (Months 1-3)
- Basic combat system implementation
- Simple overworld with 1-2 test areas
- Core Resonance mechanics
- 2-3 playable characters with limited abilities
- Combat testing and balance

**Deliverable**: Playable combat prototype demonstrating core loop

### Phase 2: Vertical Slice (Months 4-6)
- First 2-3 hours of game fully realized
- Roothollow → Overgrown Capital section
- Kael + 2 party members fully implemented
- Complete Echo system
- First boss encounter
- Character bonding system

**Deliverable**: Polished vertical slice for testing/feedback

### Phase 3: Core Content (Months 7-14)
- All 5 regions created
- Main story path implemented (Acts I-III)
- All 8 characters implemented
- All major bosses
- Core side quest content
- Save/load system

**Deliverable**: Main story playthrough start to finish

### Phase 4: Content Complete (Months 15-18)
- All side quests implemented
- Optional dungeons and superbosses
- Multiple endings
- Echo collection completion
- Mini-games and bonus content
- Achievement system

**Deliverable**: Feature-complete game

### Phase 5: Polish & Balance (Months 19-22)
- Combat balance tuning
- Difficulty mode adjustments
- Bug fixing
- Performance optimization
- Accessibility feature refinement
- Narrative polish

**Deliverable**: Release candidate

### Phase 6: Launch Preparation (Months 23-24)
- Marketing materials
- Platform certification (if console)
- Localization (if applicable)
- Day 1 patch preparation
- Community management setup

**Deliverable**: Launch-ready product

---

## Technical Considerations (Godot)

### Asset Integration
- Time Fantasy assets provide:
  - Character sprites and animations
  - Environment tilesets
  - UI elements
  - Effects and particles

### Key Systems to Implement
1. **Battle System**
   - Turn-based state machine
   - ATB timing system
   - Damage calculation engine
   - Status effect manager

2. **Character System**
   - Stat management
   - Equipment system
   - Skill tree implementation
   - Experience/leveling

3. **World System**
   - Overworld navigation
   - Dungeon generation/design
   - NPC interaction
   - Event triggers

4. **Echo System**
   - Collection tracking
   - Battle integration
   - Tuning mechanics
   - Lore delivery

5. **UI/UX**
   - Battle interface
   - Menu systems
   - Inventory management
   - Map and navigation

6. **Save/Load**
   - Multiple save slots
   - Auto-save functionality
   - Cloud save support (if applicable)

7. **Audio**
   - Music system with transitions
   - Sound effects
   - Voice acting support (future)

---

## Scope Management

### Must-Have (Core)
- Main story (Acts I-III)
- 8 playable characters
- Combat system with Resonance
- Echo collection basics
- 5 regions with major locations
- Core side quests
- Multiple endings

### Should-Have (Enhanced)
- All side quests
- Optional dungeons
- Superbosses
- Mini-games
- Complete Echo collection
- Full character bonding

### Could-Have (Stretch)
- New Game+
- Additional endings
- Post-game content
- Challenge modes
- Cosmetic options
- Photo mode

### Won't-Have (Out of Scope)
- Multiplayer
- Procedural generation (except specific Hollows sections)
- Voice acting (initial release)
- 3D graphics
- Real-time combat

---

## Success Metrics

### Gameplay
- Average playtime: 35-45 hours (main story)
- Completion rate: Target 40%+ (reasonable for JRPGs)
- Side quest engagement: Target 60%+ try at least one
- Multiple playthrough rate: Target 15%+

### Narrative
- Ending distribution: Each ending should be chosen by at least 10% of players
- Character favoritism: All characters should be liked by at least 15% of players
- Story satisfaction: Target 75%+ positive feedback

### Technical
- Performance: Stable 60 FPS on target platforms
- Bug rate: <5 critical bugs at launch
- Load times: <5 seconds for most transitions
- Accessibility: 90%+ of players can play comfortably

---

## Next Steps

1. **Prototype Development**
   - Implement basic combat in Godot
   - Test Resonance gauge mechanics
   - Create simple test encounter

2. **Asset Organization**
   - Catalog Time Fantasy assets
   - Plan character sprite assignments
   - Create asset pipeline

3. **Story Scripting**
   - Write detailed dialogue for Act I
   - Create cutscene storyboards
   - Develop character interaction trees

4. **Technical Documentation**
   - Create GDD (Game Design Document) from this foundation
   - Document technical specifications
   - Create implementation roadmap

---

## Credits & Acknowledgments

**Original Concept**: [Your Name/Team]
**Art Assets**: Time Fantasy by Finalbossblues
**Engine**: Godot Engine
**Inspirations**: Final Fantasy series (Square Enix), Chrono Trigger (Square), Persona series (Atlus)

---

## Version History

- **v1.0** (2026-02-15): Initial documentation created
  - Complete world building
  - Full story outline
  - Character designs
  - Core mechanics
  - Combat and progression systems
  - World map and locations
  - Character abilities and skill trees

---

## Contact & Feedback

[Your contact information or repository links here]

---

*"Every ending is a memory waiting to begin again. What will you create?"*
