# Backlog

All tickets not in the current sprint. Sorted by milestone, then priority.
Completed and superseded tickets are in `agents/COMPLETED.md`.

---

## M1 — Act I: The Echo Thief

### T-0107
- Title: Implement full character ability trees for all party members
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0018
- Refs: docs/mechanics/character-abilities.md
- Notes: 8 characters x 10-15 abilities = 80-120 definitions.

### T-0226
- Title: Overgrown Capital playtest pass — end-to-end Chapter 5 flow verification
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0211, T-0224
- Refs: game/tools/playtest_presets/, docs/story/act1/05-into-the-capital.md
- Notes: Full Chapter 5 flow: enter from Verdant Forest, collect Market echoes, activate Market Purification Node, navigate Entertainment District, activate Entertainment Purification Node, collect Lyra Fragment 2, trigger Last Gardener, trigger Leaving Capital, exit to Verdant Forest. Create/update overgrown_capital playtest preset JSON. Verify save/load round-trip persists echo IDs and cleared purification flags. Log discovered bugs as new BACKLOG entries.

### T-0206
- Title: Add The Performer mini-boss in Entertainment District of Overgrown Capital
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: T-0190
- Refs: docs/game-design/05-dungeon-designs.md (Entertainment District), docs/game-design/02-enemy-design.md
- Notes: Echo manifestation mini-boss in the theater. Create performer.tres EnemyData (BOSS AI, ~180 HP, dramatic_echo AoE magic + resonance drain ability). Trigger zone in theater area. Pre/post-battle 4-5 line dialogue. Flag: performer_encountered. 4+ tests.

### T-0214
- Title: Add Research Quarter Resonance terminal puzzle — unlock Palace District path
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: T-0195, T-0191
- Refs: docs/game-design/05-dungeon-designs.md, game/entities/interactable/
- Notes: Player collects two Resonance Crystal key items (one from Market, one from Entertainment) and uses them on the terminal. ResonanceTerminalStrategy extends InteractionStrategy. Checks inventory for both crystals, on success sets research_terminal_activated flag. Create resonance_crystal_market.tres and resonance_crystal_entertainment.tres (ItemData, key item type). compute_terminal_can_activate(inventory) static helper. 5+ tests.

### T-0218
- Title: Add Survivor's Diary collectible in Residential Quarter — post-Severance survival lore
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/02-main-story.md, game/entities/interactable/
- Notes: Emotionally significant lore item in a Residential Quarter room. Interactable one_time=true, 4-5 line dialogue. Flag: survivors_diary_read. compute_diary_entries() static helper. 3+ tests.

### T-0207
- Title: Add Government Center sub-area to Overgrown Capital — political debate echoes and hidden bunker
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190
- Refs: docs/game-design/05-dungeon-designs.md (Government Center), docs/lore/04-echo-catalog.md
- Notes: Capitol building area. Create 1-2 Story Echo .tres about political dissent re: Resonance regulation. Hidden bunker secret area with rare echo. 3+ tests.

### T-0213
- Title: Add Merchant's Regret optional mini-boss to Overgrown Capital Market District
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, game/data/enemies/
- Notes: Create game/data/enemies/merchants_regret.tres (EnemyData: BOSS AI, ~200 HP, coin_shower AoE + desperate_bargain debuff). Trigger zone in Market stall cluster. Pre-battle 2-line dialogue. Flag: merchants_regret_encountered. compute_merchants_regret_can_trigger(flags) static helper. 3+ tests.

### T-0215
- Title: Add hidden VIP lounge in Entertainment District — legendary echo collectible
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/04-echo-catalog.md
- Notes: Secret area accessible via hidden stage entrance in theater area. Create game/data/echoes/final_performance.tres (EchoData: LEGENDARY rarity, STORY echo_type, 3-line lore about a performer's last show before The Severance). MemorialEchoStrategy. Flag: vip_lounge_found. compute_vip_lounge_eligible(flags) helper. 3+ tests.

### T-0216
- Title: Add rooftop garden secret area to Residential Quarter — rare echo collectible
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/04-echo-catalog.md
- Notes: Secret rooftop area accessible via collapsed building rubble path. Create game/data/echoes/rooftop_garden.tres (EchoData: RARE rarity, STORY echo_type, family tending a garden above the city). MemorialEchoStrategy with 2-3 line vision. Flag: rooftop_garden_found. 3+ tests.

### T-0217
- Title: Add hidden archives secret room in Government Center — Historical Records lore
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0190, T-0211
- Refs: docs/game-design/05-dungeon-designs.md, game/entities/interactable/
- Notes: Secret room in Government Center accessible via collapsed wall. Plain dialogue Interactable (one_time=true) with 3-line lore dump about pre-Severance political history. Flag: hidden_archives_found. compute_archives_lore_text() static helper. 2+ tests.

### T-0024
- Title: Implement fast travel system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: none
- Refs: docs/game-design/03-world-map-and-locations.md
- Notes: Unlock fast travel points as discovered. World map selection UI. Transition animations.

### T-0025
- Title: Build bonding system framework
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: none
- Refs: docs/game-design/01-core-mechanics.md, docs/lore/03-characters.md
- Notes: BondData Resource. Affinity tracking between characters. Bond events at camp.

### T-0109
- Title: Add weather and time-of-day visual system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: none
- Refs: docs/game-design/06-audio-design.md
- Notes: Day/night cycle, weather effects. CanvasModulate for lighting, GPUParticles2D for weather.

### T-0110
- Title: Implement crafting system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0012
- Refs: docs/game-design/01-core-mechanics.md
- Notes: Combine materials into items. Recipe system, crafting UI, material gathering.

---

## M2 — Act II: The Weight of Echoes

*(Tickets will be created during M2 sprint planning.)*

---

## M3 — Act III: Convergence

*(Tickets will be created during M3 sprint planning.)*

---

## M4 — Optional Content & Polish

*(Tickets will be created during M4 sprint planning.)*

---

## M5 — Release Readiness

*(Tickets will be created during M5 sprint planning.)*

---

## Unscheduled

*(Tickets with no milestone assigned yet. Move to a milestone section when scheduled.)*
