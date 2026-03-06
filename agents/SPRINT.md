# Current Sprint

Sprint: S07-act1-scenes-and-enemies
Milestone: M1
Goal: Build remaining Act I scenes (Prismfall town, dungeon), enemy sets, shop system, and story events
Started: 2026-03-06
Closed: —

## Velocity
- Completed: 6
- Added mid-sprint: 3
- Rolled over: 0

---

## Active

### T-0286
- Title: Complete Chapter 9 "Beneath Prismfall" event — Lyra's truth and Convergence reveal
- Status: in-progress
- Assigned: claude
- Priority: high
- Milestone: M1
- Tags: story, events
- Depends: —
- Blocked-by: —
- Refs: docs/story/act1/09-beneath-prismfall.md
- Started: 2026-03-06

---

## Queue

### T-0278
- Title: Build Prismfall town scene — Act I hub
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: scene, tilemap
- Depends: —
- Blocked-by: —
- Refs: docs/game-design/03-world-map-and-locations.md, game/scenes/

### T-0280
- Title: Wire Prismfall Approach → Prismfall town scene transition
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: scene, wiring
- Depends: T-0278
- Blocked-by: —
- Refs: game/scenes/prismfall_approach/

### T-0279
- Title: Build Beneath Prismfall dungeon scene — Act I climax location
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: scene, tilemap, dungeon
- Depends: T-0278
- Blocked-by: —
- Refs: docs/game-design/05-dungeon-designs.md, game/scenes/

---

## Done This Sprint

- T-0290: Create crystal dungeon enemy set — Crystal Sentinel (DEFENSIVE, crystal_slam/crystal_shell/shard_barrage), Resonance Wisp (SUPPORT, resonance_mend/resonance_bolt/haste_pulse), Prism Guardian (BOSS, crushing_blow/prismatic_beam/refract), 9 abilities, 22 tests
- T-0292: Create Prismfall town shop — steel_hammer, steel_mace, iron_helm (3 new equipment), prismfall_arms.tres (14 items: weapons, armor, consumables), 14 tests
- T-0283: Complete Chapter 6 "Born from Nothing" — nyx_born_from_nothing.gd with 52 dialogue lines across 3 scenes (discoveries, campfire lore, Garrick/Nyx night bonding), 10 tests
- T-0284: Complete Chapter 7 "A Village Burns" — expanded village_burns.gd with 56 dialogue lines across 5 scenes (approach, Sera confrontation, aftermath/Morin, leaving/goodbyes, camp/Kael-Iris), BattleChoice enum, 16 tests
- T-0285: Complete Chapter 8 "The Crystal City" — expanded crystal_city_arrival.gd with 59 dialogue lines across 4 scenes (arrival, Archives/Lyra, evening dinner/Garrick-Mara/Lorne, camp/Iris-Kael), 14 tests
- T-0320: Create Cindral Wastes enemy set — Magma Crawler (DEFENSIVE, crush/harden/heat_wave), Lava Elemental (AGGRESSIVE, magma_blast/eruption/flame_shield), Ash Stalker upgraded with bite/ember_breath/howl, 9 new abilities, 13 tests
