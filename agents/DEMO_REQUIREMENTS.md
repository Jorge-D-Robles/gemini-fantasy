# First Playable Demo Requirements

**Version**: 1.0
**Date**: 2026-02-16
**Goal**: A self-contained 30-60 minute playable demo covering the opening of Gemini Fantasy's Act I

---

## Executive Summary

The demo delivers the first chapter of Kael's journey: exploring the Overgrown Ruins, discovering the Conscious Echo Lyra, traveling through the Verdant Forest, recruiting Iris and Garrick, and establishing Roothollow as a home base. The player should experience the core gameplay loop — exploration, NPC dialogue, combat encounters, party building — and be left wanting more.

---

## Demo Story Flow

The demo covers the "Inciting Incident" from the main story (Act I opening). Here is the beat-by-beat flow:

### Beat 1: The Ruins (Overgrown Ruins)
- **Already implemented**: Kael explores ancient ruins alone
- Encounters Memory Blooms and Creeping Vines (tutorial-level random encounters)
- Reaches the inner chamber and discovers Lyra — a Conscious Echo
- **Opening Sequence event** plays (5 lines of dialogue)
- Player learns basic movement, interaction, and combat

### Beat 2: Through the Forest (Verdant Forest)
- Kael leaves the ruins heading toward civilization
- Random encounters with forest enemies (6 enemy types in pool)
- **Iris Recruitment event** triggers: Iris is fighting off Ash Stalkers
- Forced battle with Iris in party (2x Ash Stalker)
- Post-battle dialogue: Iris joins the party
- Player now has a 2-person party and can experience party-based combat

### Beat 3: Arriving Home (Roothollow)
- Kael and Iris arrive in Roothollow, Kael's home village
- **NPCs to talk to**: Innkeeper, shopkeeper (if shop exists), villagers, Kael's mentor
- NPCs provide world-building, hints about the ruins, and reactions to Lyra's discovery
- **Garrick Recruitment event** triggers when player approaches Garrick NPC (requires Lyra discovered + Iris recruited)
- Garrick joins the party (3-person party)
- Innkeeper heals the party

### Beat 4: Free Exploration
- Player can revisit all three areas freely
- Fight encounters in Forest and Ruins to test full party
- Talk to all NPCs for additional lore and flavor
- **Demo end state**: Player has explored all areas, recruited all available party members, and engaged in multiple battles

### Optional Beat 5: Demo Conclusion
- After recruiting Garrick, a new NPC conversation or brief cutscene hints at what comes next: "The Council at Prismfall needs to hear about this Conscious Echo. The road south is dangerous..."
- This gives the player a clear hook for the full game without requiring new areas

---

## Playable Areas

### 1. Overgrown Ruins (Starting Area)
- **Status**: Exists, functional
- **Player actions**: Walk, interact, fight encounters, trigger opening event
- **Enemies**: Memory Bloom, Creeping Vine
- **NPCs**: None (ruins are empty of friendly NPCs)
- **Transitions**: Exit east to Verdant Forest
- **Demo role**: Tutorial area, inciting incident

### 2. Verdant Forest (Connecting Area)
- **Status**: Exists, functional
- **Player actions**: Walk, fight encounters, trigger Iris event
- **Enemies**: Creeping Vine, Ash Stalker, Hollow Specter, Ancient Sentinel, Gale Harpy, Ember Hound
- **NPCs**: None (wild area)
- **Transitions**: West to Overgrown Ruins, east to Roothollow
- **Demo role**: Combat gauntlet, Iris recruitment, connecting tissue

### 3. Roothollow (Town Hub)
- **Status**: Exists, partially functional
- **Player actions**: Walk, talk to NPCs, trigger Garrick event, rest at inn
- **Enemies**: None (safe zone, no encounters)
- **NPCs**: Innkeeper, Garrick (pre-recruitment), 4-6 townfolk NPCs
- **Transitions**: West to Verdant Forest
- **Demo role**: Safe hub, story exposition, party recruitment, rest point

---

## Required Features: MVP (IN)

These features MUST be working for the demo to be playable.

### Already Implemented (Verified Working)
1. **Player movement** — 4-directional walking/running with animation
2. **NPC interaction** — Raycast-based "interact" button, triggers dialogue
3. **Dialogue system** — Speaker name, text display, multi-line conversations, choice infrastructure
4. **Scene transitions** — Fade-to-black between all 3 areas with spawn points
5. **Random encounter system** — Step-based trigger, weighted enemy pools per area
6. **Battle system** — Full turn-based combat: action select, target select, attack, defend, execute, victory/defeat
7. **Battle UI** — Action buttons, HP/EE bars, turn order display, target selection
8. **Party management** — Add characters, active party up to 4, roster tracking
9. **3 story events** — Opening Sequence, Iris Recruitment, Garrick Recruitment
10. **Event flags** — Persistent flags controlling event triggers and NPC state
11. **HUD** — Location name, gold display, party status bars, interaction prompt
12. **8 enemy data files** — Varied stats, elemental weaknesses, loot tables
13. **3 character data files** — Kael, Iris, Garrick with stats and growth rates
14. **7 ability data files** — Character-specific abilities
15. **Pause menu** — Basic pause functionality
16. **Title screen** — Game entry point

### Needs Implementation (Required for Demo)

#### P0 — Absolutely Required (Demo is broken without these)

17. **Multi-line NPC dialogue content** — Current NPCs have placeholder single-line dialogue. Each NPC needs 3-8 lines of lore-appropriate dialogue. Some NPCs need flag-reactive dialogue (different lines before/after Lyra discovery or party recruitment).
    - Innkeeper: Welcome, rest offer, town gossip
    - Shopkeeper NPC: Flavor dialogue (no functional shop needed for P0)
    - Elder/Mentor NPC: Exposition about ruins, echo fragments, warnings
    - Townfolk (3-4): World-building, local concerns, reactions to events
    - Garrick (pre-recruit): Hints at his Shepherd past

18. **Item usage in battle** — The "Item" button exists in battle UI but items cannot actually be used. Need:
    - InventoryManager autoload (add/remove/query items)
    - Battle integration: Item button opens item list, selecting an item uses it on target
    - Starting inventory: 3x Potion, 1x Ether (given at game start or found in ruins)
    - Item data already exists (.tres files for Potion, Ether, Antidote, Phoenix Down, Resonance Tonic)

19. **Battle victory rewards** — Currently battles end with no rewards. Need:
    - Display EXP gained (visual only for demo if leveling isn't ready)
    - Display gold gained
    - Display items dropped (based on enemy loot tables)
    - Gold tracked in GameManager or a new Economy autoload

20. **Innkeeper healing** — The innkeeper interaction currently shows placeholder text. Need actual HP/EE restoration for all party members. Requires persistent HP/EE tracking on CharacterData or a runtime state layer.

21. **Party HP/EE persistence** — Currently, party members always start battles at full HP/EE because there's no persistent state between battles. The demo must track HP/EE across encounters so healing and items matter. Without this, combat has no stakes.

#### P1 — Strongly Recommended (Demo feels incomplete without these)

22. **Save point** — A save crystal in Roothollow. The save_point_strategy already exists as an InteractionStrategy. Need SaveManager autoload to serialize: party roster, event flags, player position/scene, HP/EE state, inventory.

23. **Basic XP and leveling** — Characters gain XP from battles and can level up. Even a simple system (XP → level → stat boost notification) makes the combat loop feel rewarding. Leveling data (growth rates) already exists on CharacterData.

24. **Resonance abilities** — The "Resonance" button exists in battle UI. At minimum, each of the 3 characters should have 1 usable Resonance ability:
    - Kael: Echo Strike or Resonance Pulse (damage)
    - Iris: EMP Burst (damage/debuff)
    - Garrick: Guardian's Stand or Purifying Light (defense/heal)
    - Ability data already exists as .tres files
    - Requires EE cost deduction and ability effect execution in battle

25. **Demo conclusion trigger** — After recruiting Garrick, a brief event or NPC conversation hints at the next chapter. This gives narrative closure to the demo segment.

#### P2 — Nice to Have (Polish, not required for playability)

26. **Basic status effects** — Poison from Creeping Vine, maybe a buff from Garrick's ability. Would make combat more tactical.

27. **Treasure chests** — 1-2 chests in the Overgrown Ruins containing items. The chest_strategy InteractionStrategy already exists. Just needs InventoryManager integration.

28. **Shop system** — Buy/sell items at Roothollow shopkeeper. Would make gold meaningful. Can be deferred since items can be given as starting inventory and battle drops.

29. **Resonance gauge visual** — Show the Resonance gauge building in battle. Thematic but not mechanically necessary for demo scope.

30. **Opening title crawl** — A brief text intro before the Overgrown Ruins explaining the world context. "300 years ago, The Severance shattered civilization..."

31. **Battle transition animation** — Screen effect when entering/exiting battle (flash, swirl, etc.) instead of just fade-to-black.

32. **Equipment system** — Equip weapons/armor. Can be deferred for demo since default stats are adequate for demo-length content.

33. **Quest journal** — Track objectives. Not needed for demo's linear structure.

34. **Overworld minimap** — Not needed for 3 small areas.

---

## Features Explicitly OUT of Demo

These are NOT part of the demo, even if they exist in design docs:

- **Nyx, Sienna, Cipher, Lyra, Ash** — Only Kael, Iris, Garrick are recruitable
- **Act I climax and beyond** — No Shepherd attack, no Prismfall, no Initiative capture
- **Emberhearth, Gearhaven, Prismfall, Crystalline Steppes** — Only Verdant Tangle region
- **The Hollows** — End-game content
- **Echo Fragment collection system** — Echoes exist as data but collection/equipping is post-demo
- **Echo usage in battle** — "Echo" button deferred
- **Skill trees** — Post-demo progression
- **Camp system / bonding** — Post-demo
- **Fast travel / beacons** — Only 3 areas, not needed
- **Vehicles** — Mid-game unlock
- **Side quests** — Demo is linear
- **Boss fights** — Demo encounters are all regular enemies
- **Difficulty modes** — Single difficulty for demo
- **Character portraits in dialogue** — Nice to have but not blocking (PNGs are gitignored, may not be imported)
- **Music / SFX** — Audio files are gitignored; demo can be silent. If AudioManager is wired and files exist, great, but not a requirement
- **Overload / Hollow states** — Complex Resonance mechanics deferred
- **Party swap UI** — Only 3 members, all active, no need to swap
- **Debug console** — Developer convenience, not player-facing

---

## Character Specs for Demo

### Kael Voss (Available from start)
- **Role**: Balanced fighter-mage, protagonist
- **Starting level**: 1
- **Abilities**: Attack, Defend, Echo Strike (Resonance, if P1 implemented)
- **Personality in dialogue**: Curious, empathetic, slightly nervous about Lyra discovery
- **Demo arc**: Goes from solo ruin explorer to party leader with a mission

### Iris Mantle (Recruited in Verdant Forest)
- **Role**: Physical DPS / tech specialist
- **Starting level**: 1
- **Abilities**: Attack, Defend, EMP Burst (Resonance, if P1 implemented)
- **Personality in dialogue**: Cynical, pragmatic, intrigued by Lyra
- **Demo arc**: Lone wolf who joins out of scientific curiosity

### Garrick "Old Iron" Thorne (Recruited in Roothollow)
- **Role**: Tank / support
- **Starting level**: 1
- **Abilities**: Attack, Defend, Guardian's Stand (Resonance, if P1 implemented)
- **Personality in dialogue**: Stoic, protective, brief but weighty words
- **Demo arc**: Experienced warrior who recognizes the gravity of a Conscious Echo

---

## NPC Roster for Roothollow

### Required NPCs (P0)

1. **Innkeeper ("Mara")** — Runs The Hollow Rest inn. Warm, motherly. Heals party on interaction. Dialogue covers: welcome, town history, warnings about the forest.

2. **Elder Rowan** — Village elder / Kael's mentor figure. Exposition NPC. Dialogue covers: what Echo Fragments are, the ruins' history, reaction to Lyra, urging Kael to seek the Council at Prismfall. Flag-reactive: different lines before/after Lyra discovery.

3. **Townfolk — Brin (Farmer)** — Worried about crystal corruption spreading to crops. Provides grounded perspective on how The Severance affects daily life.

4. **Townfolk — Vessa (Merchant)** — Runs the general store. Dialogue is flavor-only for P0 (functional shop is P2). Comments on trade routes being dangerous.

5. **Townfolk — Dael (Child)** — Asks Kael about the ruins, wants to be an Echo Hunter someday. Light-hearted contrast to the heavier themes.

6. **Garrick NPC (pre-recruitment)** — Stands near the village entrance. If player talks to him before recruitment conditions are met, he gives generic "dangerous times" dialogue. When conditions are met, the recruitment event auto-triggers.

### Optional NPCs (P2)

7. **Townfolk — Old Wren (Storyteller)** — Tells brief tales about The Severance and the old capital
8. **Townfolk — Guard** — Comments on increased monster activity near the ruins

---

## Success Criteria

The demo is "playable" when ALL of these are true:

### Must Pass (P0)
- [ ] Player can start a new game from the title screen
- [ ] Player controls Kael in the Overgrown Ruins
- [ ] Walking into the Lyra zone triggers the opening sequence dialogue
- [ ] Player can fight and win random encounters in the Ruins (solo Kael)
- [ ] Player can transition from Ruins → Forest → Roothollow and back
- [ ] Walking into the Iris zone in the Forest triggers recruitment event + battle
- [ ] After Iris recruitment, Iris appears in battle as a party member
- [ ] Walking near Garrick in Roothollow (after Lyra + Iris flags set) triggers Garrick recruitment
- [ ] After Garrick recruitment, Garrick appears in battle as a party member
- [ ] Player can talk to at least 4 NPCs in Roothollow with meaningful dialogue (3+ lines each)
- [ ] NPC dialogue references the world, story, and current events (not placeholder text)
- [ ] Battles use Attack and Defend commands correctly
- [ ] Items can be used in battle (Potions heal HP)
- [ ] Battles display victory rewards (at minimum: gold gained)
- [ ] HP/EE persists between battles (damage carries over)
- [ ] Innkeeper restores party HP/EE
- [ ] The game does not crash during normal play through all 3 areas
- [ ] All existing tests pass (222+ tests green)

### Should Pass (P1)
- [ ] Player can save at a save point in Roothollow
- [ ] Player can load a saved game from the title screen
- [ ] Characters gain XP from battles and can level up
- [ ] Each character has at least 1 Resonance ability usable in battle
- [ ] A demo conclusion event plays after Garrick recruitment
- [ ] Gold is tracked and displayed on HUD

### Nice to Have (P2)
- [ ] Basic status effects work in battle (poison, defense buff)
- [ ] 1-2 treasure chests in Overgrown Ruins give items
- [ ] Shop NPC sells basic items
- [ ] Resonance gauge visible in battle UI
- [ ] Opening text crawl provides world context
- [ ] Battle transitions have visual flair (not just fade)

---

## Technical Dependencies

The following backlog tickets from `agents/BACKLOG.md` are required or relevant:

| Ticket | Title | Demo Priority | Notes |
|--------|-------|---------------|-------|
| T-0012 | Build inventory system | **P0** | Required for item usage in battle and loot |
| T-0019 | Implement leveling and XP system | P1 | Makes combat loop rewarding |
| T-0014 | Build save/load system | P1 | Save points in Roothollow |
| T-0015 | Resonance gauge UI + overload/hollow | P1 (partial) | Only need gauge display + ability usage, not overload/hollow |
| T-0017 | Implement status effect system | P2 | Adds tactical depth |
| T-0009 | Party healing at rest points | **P0** | Innkeeper healing |
| T-0022 | Build shop system | P2 | Roothollow shopkeeper |
| T-0013 | Build equipment system | OUT | Not needed for demo |
| T-0016 | Build quest tracking | OUT | Demo is linear |
| T-0018 | Build skill tree framework | OUT | Post-demo |

### New Work Not in Backlog
- **NPC dialogue content authoring** — Writing 50-80 lines of dialogue for 6+ NPCs
- **Party HP/EE persistence layer** — Runtime state tracking between battles
- **Battle victory screen / rewards** — Gold, XP, item drops display
- **Starting inventory setup** — Give player items at game start
- **Demo conclusion event** — Brief cutscene/dialogue after full party assembled
- **Flag-reactive NPC dialogue** — NPCs say different things based on story progress

---

## Estimated Scope

| Category | Items | Estimated Effort |
|----------|-------|-----------------|
| P0 (Must Have) | 7 features | Medium-Large |
| P1 (Should Have) | 5 features | Medium |
| P2 (Nice to Have) | 7 features | Small-Medium each |
| Content (Dialogue) | ~80 lines across 6 NPCs | Small |
| Content (Demo Event) | 1 new event script | Small |
| Testing | Tests for all new systems | Included in each feature |

The P0 features constitute the minimum playable demo. P0 + P1 together make a polished, complete-feeling demo. P2 items are stretch goals that improve quality but aren't blocking.

---

## Appendix: Current Codebase Inventory

### Autoloads (6)
- GameManager — State machine, scene transitions
- BattleManager — Battle initiation and transitions
- PartyManager — Party roster and active party
- DialogueManager — Dialogue queue and flow control
- AudioManager — Audio bus management
- UILayer — HUD and UI overlay management

### Scenes (3)
- Overgrown Ruins — Starting dungeon area
- Verdant Forest — Overworld connecting area
- Roothollow — Town hub

### Battle System (20 scripts)
- BattleScene, BattleStateMachine, Battler, PartyBattler, EnemyBattler
- TurnQueue
- 8 battle states: Start, TurnQueue, ActionSelect, TargetSelect, PlayerTurn, EnemyTurn, ActionExecute, TurnEnd, Victory, Defeat
- BattleUI

### Resources (9 types)
- AbilityData, BattlerData, CharacterData, EnemyData, EchoData, ItemData
- DialogueLine, EncounterPoolEntry, BattleAction

### Data Files (27 .tres)
- 3 characters (Kael, Iris, Garrick)
- 8 enemies
- 7 abilities
- 4 echoes
- 5 items

### Events (3)
- OpeningSequence (Lyra discovery)
- IrisRecruitment (Forest encounter + battle)
- GarrickRecruitment (Roothollow dialogue)

### Tests
- 222 passing unit tests covering battle system, resources, autoloads, and entities
