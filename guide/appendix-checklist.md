# Appendix C: Project Checklist

Use this checklist to verify your JRPG demo is feature-complete and shippable. Check items off as you confirm they work in an actual playthrough — not just in isolation, but wired together in the full game loop.

## Core Systems

- [ ] Player moves in four directions with correct animation
- [ ] Player collides with walls and solid objects
- [ ] Player interacts with NPCs and interactables via RayCast2D
- [ ] Camera follows the player with appropriate limits
- [ ] Scene transitions work between at least two areas (fade or slide)
- [ ] Spawn points position the player correctly after each transition
- [ ] GameManager state stack pushes and pops correctly (OVERWORLD → DIALOGUE → OVERWORLD)
- [ ] Game does not freeze or softlock when transitioning between states

## Battle System

- [ ] Random encounters trigger after walking a threshold number of steps
- [ ] Battle scene loads with correct party members and enemy group
- [ ] Turn queue orders battlers by speed
- [ ] Player can select Attack, Defend, Ability, Item, and Escape
- [ ] Attack command deals damage to selected target
- [ ] Defend command reduces incoming damage
- [ ] Abilities cost EE and deal correct damage/healing
- [ ] Items can be used from inventory during battle
- [ ] Escape attempt succeeds or fails with appropriate feedback
- [ ] Enemy AI selects actions and targets
- [ ] Damage numbers display on hit
- [ ] Status effects apply, tick, and expire
- [ ] Elemental strengths and weaknesses modify damage
- [ ] Victory screen shows XP, gold, and level-ups
- [ ] Defeat screen shows Game Over with options
- [ ] Battle ends cleanly — overworld resumes, music restores

## Data Layer

- [ ] At least 3 CharacterData resources with unique stats and abilities
- [ ] At least 4 EnemyData resources with distinct AI types
- [ ] At least 5 AbilityData resources (damage, healing, status)
- [ ] At least 3 ItemData resources (HP heal, EE heal, status cure)
- [ ] At least 3 EquipmentData resources (weapon, armor, accessory)
- [ ] At least 1 QuestData resource with multiple objectives
- [ ] All Resource fields are populated — no empty required fields

## Party and Progression

- [ ] Party roster supports active (up to 4) and reserve members
- [ ] New characters can be recruited and added to the roster
- [ ] Runtime HP/EE tracked per character
- [ ] Level-up increases stats based on growth rates
- [ ] XP awards after battle are correct
- [ ] Equipment can be changed and affects combat stats
- [ ] Stat bonuses from equipment aggregate correctly across all slots

## Inventory and Economy

- [ ] Items can be found (chests, quest rewards)
- [ ] Items can be purchased from shops
- [ ] Items can be used in and out of battle
- [ ] Gold is earned from battles and quest rewards
- [ ] Gold is spent at shops
- [ ] Inventory UI displays current items with counts
- [ ] Shop UI shows buy/sell with price and gold balance

## Quests

- [ ] Quests can be accepted from NPCs
- [ ] Quest objectives track progress (kill count, item collection, talk-to)
- [ ] Quest completion grants rewards (gold, XP, items)
- [ ] Quest log UI shows active and completed quests
- [ ] HUD objective tracker updates in real time

## Save and Load

- [ ] Save point interaction opens save slot dialog
- [ ] Game state serializes to JSON (party, inventory, equipment, quests, flags, position)
- [ ] Save file writes to user directory without errors
- [ ] Load restores all state correctly (round-trip verified)
- [ ] Player spawns at correct position after load
- [ ] Continue option on title screen only appears when saves exist
- [ ] Multiple save slots work independently

## Dialogue

- [ ] Dialogue box displays speaker name and text
- [ ] Portrait displays next to dialogue text (when available)
- [ ] Player advances dialogue with confirm input
- [ ] Dialogue choices display as selectable options
- [ ] Choice selection triggers correct branch
- [ ] Dialogue ends cleanly — game state returns to previous

## UI

- [ ] Title screen with New Game, Continue, and Settings
- [ ] HUD shows party HP bars, location name, objective
- [ ] Pause menu accessible during overworld
- [ ] Pause menu shows party stats and equipment
- [ ] Battle UI shows command menu, HP/EE bars, turn indicator
- [ ] Target selector highlights valid targets
- [ ] All menus navigable by keyboard/gamepad (no mouse required)
- [ ] Menu focus states are visually distinct

## Content

- [ ] At least 2 explorable areas connected by transitions
- [ ] At least 1 safe town area with NPCs, shop, and save point
- [ ] At least 1 combat area with random encounters
- [ ] NPCs have dialogue that reacts to story flags
- [ ] At least 1 interactable chest with loot
- [ ] At least 1 completable quest from start to finish
- [ ] World feels cohesive — consistent art style across areas

## Audio

- [ ] Unique BGM per area (town, overworld, dungeon)
- [ ] Battle BGM plays during combat
- [ ] BGM crossfades when changing areas
- [ ] Victory fanfare plays after battle
- [ ] SFX for menu navigation (cursor move, confirm, cancel)
- [ ] SFX for battle actions (attack hit, ability cast, heal)
- [ ] Audio does not clip, pop, or cut off abruptly

## Visual Polish

- [ ] Scene transitions are smooth (no flicker, no pop-in)
- [ ] Damage numbers animate (rise and fade)
- [ ] Screen shake on heavy hits
- [ ] Tilemaps have visual variety (no repeating grid patterns)
- [ ] AbovePlayer layer creates depth (walking under tree canopies)
- [ ] No visual artifacts at screen edges or scene boundaries

## Testing

- [ ] Unit tests pass for all static utility classes
- [ ] Unit tests pass for all autoload logic (add/remove/query)
- [ ] Unit tests pass for state machine transitions
- [ ] Unit tests pass for save/load round-trip
- [ ] gdlint reports no style violations
- [ ] Full playthrough from new game to save/load without crashes

## Export

- [ ] Export templates installed for target platform
- [ ] Export preset configured (name, icon, resources)
- [ ] Exported build launches and runs correctly
- [ ] Exported build matches editor behavior (no missing resources)
- [ ] Build file size is reasonable (check for accidentally included source assets)
