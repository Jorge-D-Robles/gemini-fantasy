# Milestones

Project milestones derived from `docs/IMPLEMENTATION_GUIDE.md` and `docs/game-design/` documents.

---

## M0 — Foundation
**Status:** in-progress
**Goal:** Resolve tech debt, build remaining core systems, achieve vertical-slice readiness.

### Scope
- [x] State machine framework (generic + battle)
- [x] Scene transition system (GameManager)
- [x] Input handling (player movement, interaction)
- [x] Battle system (turn queue, state machine, action execution)
- [x] Character data resources (CharacterData, BattlerData)
- [x] Enemy data resources (EnemyData)
- [x] Ability data resources (AbilityData)
- [x] Item data resources (ItemData)
- [x] Echo data resources (EchoData)
- [x] Encounter system
- [x] Dialogue system (DialogueManager + DialogueBox)
- [x] Battle UI (action select, target select)
- [x] HUD (overworld)
- [x] Title screen
- [x] Pause menu
- [x] Player entity (movement, interaction)
- [x] NPC entity (dialogue trigger)
- [x] Interactable entity (chests, signs, save points)
- [x] Audio bus layout (BGM, SFX)
- [x] Event flag system
- [ ] Add class_name to all autoloads
- [ ] Extract TurnQueue into own scene
- [ ] Refactor Interactable into composition pattern
- [ ] Replace Dictionary-based dialogue/encounter data with Resources
- [ ] Replace meta-based state communication with typed BattleAction
- [ ] Use AnimatedSprite2D for player animation
- [ ] Wire unconnected signals to EventBus
- [ ] Replace has_method/has_signal with proper typing
- [ ] Add return type hints to all methods
- [ ] Inventory system (autoload + data)
- [ ] Equipment system (equip/unequip, stat modifiers)
- [ ] Save/load system (SaveManager autoload)
- [ ] Resonance gauge UI + overload/hollow mechanics
- [ ] Status effect system
- [ ] Skill tree framework
- [ ] Leveling / XP system
- [ ] Quest tracking system (QuestManager autoload)
- [ ] Party management UI (swap members, view stats)
- [ ] Inventory UI (items, equipment)
- [ ] Shop system
- [ ] Camp / rest system (HP/EE restoration)
- [ ] Fast travel system
- [ ] Bonding system framework
- [ ] Debug console

---

## M1 — Act I: The Echo Thief
**Status:** not-started
**Goal:** Playable Act I — Kael's journey from Roothollow through the Verdant Tangle and Cindral Wastes.

### Scope
- [ ] Party members: Kael (refine), Iris (refine), Garrick (refine), Lyra (new)
- [ ] Region: Verdant Tangle (expand from existing forest/ruins)
- [ ] Region: Cindral Wastes (new)
- [ ] Settlement: Roothollow (expand — shops, quests, full NPCs)
- [ ] Settlement: Ashveil Outpost (new)
- [ ] Settlement: Embercradle (new)
- [ ] Dungeon: Whispering Grotto (story dungeon)
- [ ] Dungeon: Cinderfall Mine (story dungeon)
- [ ] Act I main story events and cutscenes
- [ ] Act I boss encounters
- [ ] Act I enemy roster (8-10 enemy types)
- [ ] Act I Echo Fragments (story + combat)
- [ ] Act I side quests (Verdant Tangle + Cindral Wastes)
- [ ] Act I NPC roster and dialogue
- [ ] Region-appropriate tilesets and art
- [ ] Act I BGM and SFX

---

## M2 — Act II: The Weight of Echoes
**Status:** not-started
**Goal:** Playable Act II — Crystalline Steppes and Ironcoast regions.

### Scope
- [ ] Party members: Theron (new), Mira (new), Zara (new)
- [ ] Region: Crystalline Steppes (new)
- [ ] Region: Ironcoast Dominion (new)
- [ ] Settlement: Aetherwatch (new)
- [ ] Settlement: Ironport (new)
- [ ] Dungeon: Resonance Spire (story dungeon)
- [ ] Dungeon: Drowned Archives (story dungeon)
- [ ] Dungeon: Steelworks Depths (story dungeon)
- [ ] Act II main story events and cutscenes
- [ ] Act II boss encounters
- [ ] Act II enemy roster (10-12 enemy types)
- [ ] Act II Echo Fragments
- [ ] Act II side quests (Crystalline Steppes + Ironcoast)
- [ ] Act II NPC roster and dialogue
- [ ] Echo Tuning system implementation
- [ ] Faction reputation system
- [ ] Region-appropriate tilesets and art
- [ ] Act II BGM and SFX

---

## M3 — Act III: Convergence
**Status:** not-started
**Goal:** Playable Act III — The Hollows, final confrontations, multiple endings.

### Scope
- [ ] Party member: Vex (new — final party member)
- [ ] Region: The Hollows (new)
- [ ] Dungeon: The Hollow Throne (final story dungeon)
- [ ] Dungeon: Memory Nexus (story dungeon)
- [ ] Act III main story events and cutscenes
- [ ] 4 endings implementation (Severance, Synthesis, Sacrifice, Silence)
- [ ] Final boss: The Conductor
- [ ] Final boss: alternate forms per ending path
- [ ] Act III enemy roster (8-10 enemy types)
- [ ] Act III Echo Fragments (endgame)
- [ ] Act III side quests
- [ ] Ending-specific epilogues
- [ ] Point of no return system
- [ ] Region-appropriate tilesets and art
- [ ] Act III BGM and SFX

---

## M4 — Optional Content & Polish
**Status:** not-started
**Goal:** Optional dungeons, mini-games, full audio, balance pass.

### Scope
- [ ] Optional dungeon: Ancient Resonance Chamber
- [ ] Optional dungeon: Echoing Abyss
- [ ] Optional dungeon: Timeworn Coliseum
- [ ] Mini-games (fishing, card game, arena)
- [ ] Full BGM implementation (all regions, battles, events)
- [ ] Full SFX implementation
- [ ] Adaptive audio system (battle intensity, region transitions)
- [ ] Complete side quest content (60+ quests)
- [ ] Complete NPC schedules and dialogue
- [ ] Balance tuning pass (enemies, abilities, items, economy)
- [ ] Animation polish (battle effects, transitions)
- [ ] Achievement/completion tracking

---

## M5 — Release Readiness
**Status:** not-started
**Goal:** Full QA, performance optimization, export builds.

### Scope
- [ ] Full playthrough QA (all 4 endings)
- [ ] Performance profiling and optimization
- [ ] Memory leak audit
- [ ] Save/load compatibility testing
- [ ] Input remapping + controller support
- [ ] Accessibility features (text size, colorblind modes)
- [ ] Export: Windows build
- [ ] Export: Linux build
- [ ] Export: macOS build
- [ ] Export: Web build (if feasible)
- [ ] Crash reporting / error logging
- [ ] Final balance adjustments
- [ ] Credits sequence
